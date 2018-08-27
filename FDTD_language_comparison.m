% 二次元音響FDTD速度比較 by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/)

NX = 300;						% 空間セル数 X [pixels]
NY = 400;						% 空間セル数 Y [pixels]

dx = 0.01;						% 空間刻み [m]
dt = 20.0e-6;					% 時間刻み [s]

Nstep = 1000;					% 計算ステップ数 [回]

freq = 1.0e3;					% 初期波形の周波数 [Hz]

rho = 1.3;						% 密度ρ [kg/m^3]
kappa = 142.0e3;				% 体積弾性率κ [Pa]

Vx = zeros(NX+1,NY  );			% x方向粒子速度 [m/s]
Vy = zeros(NX,  NY+1);			% y方向粒子速度 [m/s]
P  = zeros(NX,  NY  );			% 音圧 [Pa]


% 事前準備 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
waveformfile = fopen('waveform.txt','w');

% メインループ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 0:Nstep,

	% 更新（ここが FDTD の本体）
	% 粒子速度の更新
	Vx(2:NX,:) = Vx(2:NX,:) - dt / (rho * dx) * ( P(2:NX,:) - P(1:NX-1,:) );
	Vy(:,2:NY) = Vy(:,2:NY) - dt / (rho * dx) * ( P(:,2:NY) - P(:,1:NY-1) );
	% 音圧の更新
	P(1:NX,1:NY) = P(1:NX,1:NY) - ( kappa * dt / dx ) * ( ( Vx(2:NX+1,:) - Vx(1:NX,:) ) + ( Vy(:,2:NY+1) - Vy(:,1:NY) ) );

	% 初期波形を準備（正弦波×１波 with ハン窓）
	if n < (1.0/freq)/dt
		sig = (1.0-cos(2.0*pi*freq*n*dt))/2.0 * sin(2.0*pi*freq*n*dt);
	else
		sig = 0.0;
	end

	% 音源
	P(floor(NX/4+1),floor(NY/3+1)) = sig;

	% 波形ファイル出力（時刻, 音源, 中央点の音圧）
	fprintf(waveformfile,'%e\t%e\t%e\n', dt*n, sig, P(floor(NX/2+1),floor(NY/2+1)));
	fprintf('%5d / %5d\r', n, Nstep);

	% 音圧分布ファイル出力（50ステップ毎）
	if rem(n, 50) == 0
		fieldfilename = sprintf('field%.6d.txt',n);
		fieldfile = fopen(fieldfilename,'w');
		for i = 1:NX
			for j = 1:NY
				fprintf(fieldfile,'%e\t',P(i,j));
			end
			fprintf(fieldfile,'\n');
		end
		fclose(fieldfile);
	end
end

% 事後処理 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose(waveformfile);
