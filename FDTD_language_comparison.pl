# 二次元音響FDTD速度比較 by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/)

$NX = 300;				# 空間セル数 X [pixels]
$NY = 400;				# 空間セル数 Y [pixels]

$dx = 0.01;				# 空間刻み [m]
$dt = 20.0e-6;			# 時間刻み [s]

$Nstep = 1000;			# 計算ステップ数 [回]

$freq = 1.0e3;			# 初期波形の周波数 [Hz]

$rho = 1.3;				# 密度ρ [kg/m^3]
$kappa = 142.0e3;		# 体積弾性率κ [Pa]

# 事前準備 #########################################################
$pi = atan2(1,1) *4;	# 円周率π

open(WAVEFORMFILE,">waveform.txt");


# メインループ #########################################################
for($n=0;$n<=$Nstep;$n++){

	# 更新（ここが FDTD の本体）
	&UpdateV;
	&UpdateP;

	# 初期波形を準備（正弦波×１波 with ハン窓）
	if( $n < (1.0/$freq)/$dt ){
		$sig = (1.0-cos(2.0*$pi*$freq*$n*$dt))/2.0 * sin(2.0*$pi*$freq*$n*$dt);
	}
	else{
		$sig = 0.0;
	}

	# 音源
	$P[int($NX/4)][int($NY/3)] = $sig;

	# 波形ファイル出力（時刻, 音源, 中央点の音圧）
	printf WAVEFORMFILE ("%e\t%e\t%e\n", $dt*$n, $sig, $P[int($NX/2)][int($NY/2)]);
	printf("%5d / %5d\n", $n, $Nstep );

	# 音圧分布ファイル出力（50ステップ毎）
	if( $n % 50 == 0 ){
		$fieldfilename = sprintf( "field%.6d.txt",$n);
		open(FIELDFILE,">$fieldfilename");
		for($i=0; $i<$NX; $i++){
			for($j=0; $j<$NY; $j++){
				printf FIELDFILE ("%e\t", $P[$i][$j] );
			}
			printf FIELDFILE ("\n");
		}
		close(FIELDFILE);
	}
}

# 事後処理 #########################################################
close(WAVEFORMFILE);


# サブルーチン ############################################################

# 粒子速度の更新
sub UpdateV
{
	for($i=1;$i<$NX;$i++){
		for($j=0;$j<$NY;$j++){
			$Vx[$i][$j] += - $dt / ($rho * $dx) * ( $P[$i][$j] - $P[$i-1][$j] );
		}
	}

	for($i=0;$i<$NX;$i++){
		for($j=1;$j<$NY;$j++){
			$Vy[$i][$j] += - $dt / ($rho * $dx) * ( $P[$i][$j] - $P[$i][$j-1] );
		}
	}
}

# 音圧の更新
sub UpdateP
{
	for($i=0;$i<$NX;$i++){
		for($j=0;$j<$NY;$j++){
			$P[$i][$j] += - ( $kappa * $dt / $dx )
			               * ( ( $Vx[$i+1][$j] - $Vx[$i][$j] ) + ( $Vy[$i][$j+1] - $Vy[$i][$j] ) );
		}
	}
}
