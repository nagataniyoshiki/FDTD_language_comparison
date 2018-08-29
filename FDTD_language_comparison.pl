# �񎟌�����FDTD���x��r by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/)
#  disabled file output for testing speed 20180829

$NX = 300;				# ��ԃZ���� X [pixels]
$NY = 400;				# ��ԃZ���� Y [pixels]

$dx = 0.01;				# ��ԍ��� [m]
$dt = 20.0e-6;			# ���ԍ��� [s]

$Nstep = 10000;			# �v�Z�X�e�b�v�� [��]

$freq = 1.0e3;			# �����g�`�̎��g�� [Hz]

$rho = 1.3;				# ���x�� [kg/m^3]
$kappa = 142.0e3;		# �̐ϒe������ [Pa]

# ���O���� #########################################################
$pi = atan2(1,1) *4;	# �~������

#open(WAVEFORMFILE,">waveform.txt");


# ���C�����[�v #########################################################
for($n=0;$n<=$Nstep;$n++){

	# �X�V�i������ FDTD �̖{�́j
	&UpdateV;
	&UpdateP;

	# �����g�`�������i�����g�~�P�g with �n�����j
	if( $n < (1.0/$freq)/$dt ){
		$sig = (1.0-cos(2.0*$pi*$freq*$n*$dt))/2.0 * sin(2.0*$pi*$freq*$n*$dt);
	}
	else{
		$sig = 0.0;
	}

	# ����
	$P[int($NX/4)][int($NY/3)] = $sig;

	# �g�`�t�@�C���o�́i����, ����, �����_�̉����j
#	printf WAVEFORMFILE ("%e\t%e\t%e\n", $dt*$n, $sig, $P[int($NX/2)][int($NY/2)]);

	# �������z�t�@�C���o�́i50�X�e�b�v���j
	if( $n % 50 == 0 ){
		printf("%5d / %5d\n", $n, $Nstep );
#		����t�@�C�����o�͂���ꍇ�͈ȉ��̃R�����g���O���ĉ�����
#		$fieldfilename = sprintf( "field%.6d.txt",$n);
#		open(FIELDFILE,">$fieldfilename");
#		for($i=0; $i<$NX; $i++){
#			for($j=0; $j<$NY; $j++){
#				printf FIELDFILE ("%e\t", $P[$i][$j] );
#			}
#			printf FIELDFILE ("\n");
#		}
#		close(FIELDFILE);
	}
}

# ���㏈�� #########################################################
#close(WAVEFORMFILE);


# �T�u���[�`�� ############################################################

# ���q���x�̍X�V
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

# �����̍X�V
sub UpdateP
{
	for($i=0;$i<$NX;$i++){
		for($j=0;$j<$NY;$j++){
			$P[$i][$j] += - ( $kappa * $dt / $dx )
			               * ( ( $Vx[$i+1][$j] - $Vx[$i][$j] ) + ( $Vy[$i][$j+1] - $Vy[$i][$j] ) );
		}
	}
}
