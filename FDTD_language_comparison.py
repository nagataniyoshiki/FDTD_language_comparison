# 二次元音響FDTD速度比較 by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/)

import sys
from scipy import *

NX = 300								# 空間セル数 X [pixels]
NY = 400								# 空間セル数 Y [pixels]

dx = 0.01								# 空間刻み [m]
dt = 20.0e-6							# 時間刻み [s]

Nstep = 1000							# 計算ステップ数 [回]

freq = 1.0e3							# 初期波形の周波数 [Hz]

rho = 1.3								# 密度ρ [kg/m^3]
kappa = 142.0e3							# 体積弾性率κ [Pa]

Vx = zeros((NX+1,NY  ), "float64")		# x方向粒子速度 [m/s]
Vy = zeros((NX,  NY+1), "float64")		# y方向粒子速度 [m/s]
P  = zeros((NX,  NY  ), "float64")		# 音圧 [Pa]


# 事前準備 #########################################################
waveformfile = open('waveform.txt', 'w')

# メインループ #########################################################
for n in range(Nstep+1):

	# 更新（ここが FDTD の本体）
	# 粒子速度の更新
	Vx[1:NX,:] += - dt / (rho * dx) * ( P[1:NX,:] - P[0:NX-1,:] )
	Vy[:,1:NY] += - dt / (rho * dx) * ( P[:,1:NY] - P[:,0:NY-1] )
	# 音圧の更新
	P[0:NX,0:NY] += - ( kappa * dt / dx )\
	                 * ( ( Vx[1:NX+1] - Vx[0:NX,:] ) + ( Vy[:,1:NY+1] - Vy[:,0:NY] ) )

	# 初期波形を準備（正弦波×１波 with ハン窓）
	if n < (1.0/freq)/dt:
		sig = (1.0-cos(2.0*pi*freq*n*dt))/2.0 * sin(2.0*pi*freq*n*dt)
	else:
		sig = 0.0

	# 音源
	P[int(NX/4),int(NY/3)] = sig

	# 波形ファイル出力（時刻, 音源, 中央点の音圧）
	waveformfile.write('%e\t%e\t%e\n' % (dt*n, sig, P[int(NX/2),int(NY/2)]))
	sys.stderr.write('%5d / %5d\r' % (n, Nstep) )

	# 音圧分布ファイル出力（50ステップ毎）
	if n % 50 == 0:
		fieldfilename = 'field%.6d.txt' % (n)
		fieldfile = open(fieldfilename,'w')
		for i in range(NX):
			for j in  range(NY):
				fieldfile.write('%e\t' % (P[i,j]))
			fieldfile.write('\n');
		fieldfile.close

# 事後処理 #########################################################
waveformfile.close
