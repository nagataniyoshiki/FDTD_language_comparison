! 二次元音響FDTD速度比較 by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/)

program FDTD_language_comparison

	integer :: NX = 300										! 空間セル数 X [pixels]
	integer :: NY = 400										! 空間セル数 Y [pixels]

	double precision :: dx = 0.01							! 空間刻み [m]
	double precision :: dt = 20.0e-6						! 時間刻み [s]

	integer :: Nstep = 1000									! 計算ステップ数 [回]

	double precision :: freq = 1.0e3						! 初期波形の周波数 [Hz]

	double precision :: rho = 1.3							! 密度ρ [kg/m^3]
	double precision :: kappa = 142.0e3						! 体積弾性率κ [Pa]

	double precision, allocatable, dimension(:,:) :: Vx		! x方向粒子速度 [m/s]
	double precision, allocatable, dimension(:,:) :: Vy		! y方向粒子速度 [m/s]
	double precision, allocatable, dimension(:,:) :: P		! 音圧 [Pa]

	! 事前準備 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	character fieldfilename*30
	double precision :: sig = 0.0
	double precision :: pi
	pi = acos(-1.0d0)		! 円周率π

	allocate( Vx(NX+1,NY) )
	Vx(:,:) = 0.0
	allocate( Vy(NX,NY+1) )
	Vy(:,:) = 0.0
	allocate( P(NX,NY) )
	P(:,:)  = 0.0

	open(10, file='waveform.txt', status='replace')


	! メインループ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	do n = 0, Nstep

		! 更新（ここが FDTD の本体）
		! 粒子速度の更新
		Vx(2:NX,:) = Vx(2:NX,:) - dt / (rho * dx) * ( P(2:NX,:) - P(1:NX-1,:) );
		Vy(:,2:NY) = Vy(:,2:NY) - dt / (rho * dx) * ( P(:,2:NY) - P(:,1:NY-1) );
		! 音圧の更新
		P(1:NX,1:NY) = P(1:NX,1:NY) - ( kappa * dt / dx ) * ( ( Vx(2:NX+1,:) - Vx(1:NX,:) ) + ( Vy(:,2:NY+1) - Vy(:,1:NY) ) );

		! 初期波形を準備（正弦波×１波 with ハン窓）
		if (n < (1.0/freq)/dt) then
			sig = (1.0-cos(2.0*pi*freq*n*dt))/2.0 * sin(2.0*pi*freq*n*dt);
		else
			sig = 0.0;
		end if

		! 音源
		P(NX/4+1,NY/3+1) = sig;

		! 波形ファイル出力（時刻, 音源, 中央点の音圧）
		write (10, "(E17.7,' ', E17.7, ' ', E17.7)"), dt*n, sig, P(NX/2+1,NY/2+1)
		write (*, "(I5,' / ', I5)"), n, Nstep

		! 音圧分布ファイル出力（50ステップ毎）
		if (mod(n, 50) == 0) then
			write (fieldfilename, '("field", I6.6, ".txt")') n
			open(20, file=fieldfilename, status='replace')
			do i = 1, NX
				do j = 1, NY
					write (20, "(E17.7, '')", advance='no'), P(i,j)
				end do
				write (20, "()")
			end do
			close(20)
		end if

	end do

	! 事後処理 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	close(10)

end program FDTD_language_comparison
