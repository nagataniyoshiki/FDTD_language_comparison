/* 二次元音響FDTD速度比較 by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/) */

#include <stdio.h>
#include <math.h>

#define NX 300				/* 空間セル数 X [pixels] */
#define NY 400				/* 空間セル数 Y [pixels] */

#define dx 0.01				/* 空間刻み [m] */
#define dt 20.0e-6			/* 時間刻み [s] */

#define Nstep 1000			/* 計算ステップ数 [回] */

#define freq 1.0e3			/* 初期波形の周波数 [Hz] */

#define rho 1.3				/* 密度ρ [kg/m^3] */
#define kappa 142.0e3		/* 体積弾性率κ [Pa] */

double Vx[NX+1][NY];		/* x方向粒子速度 [m/s] */
double Vy[NX][NY+1];		/* y方向粒子速度 [m/s] */
double P[NX][NY];			/* 音圧 [Pa] */

void UpdateV(),UpdateP();


/* メイン関数 ************************************************************/

int main(void)
{
	int i,j;
	int n;
	double sig;
	FILE *waveformfile, *fieldfile;
	char fieldfilename[30];

	/* 事前準備 *********************************************************/
	if((waveformfile = fopen("waveform.txt","w"))==NULL){
		printf("open error [waveform.txt]\n");
		return(1);
	}

	/* 粒子速度分布・音圧分布を初期化 *********************************************************/
	for(i=0;i<NX+1;i++){
		for(j=0;j<NY;j++){
			Vx[i][j] = 0.0;
		}
	}
	for(i=0;i<NX;i++){
		for(j=0;j<NY+1;j++){
			Vy[i][j] = 0.0;
		}
	}
	for(i=0;i<NX;i++){
		for(j=0;j<NY;j++){
			P[i][j]  = 0.0;
		}
	}

	/* メインループ *********************************************************/
	for(n=0;n<=Nstep;n++){

		/* 更新（ここが FDTD の本体） */
		UpdateV();
		UpdateP();

		/* 初期波形を準備（正弦波×１波 with ハン窓）*/
		if( n < (1.0/freq)/dt ){
			sig = (1.0-cos(2.0*M_PI*freq*n*dt))/2.0 * sin(2.0*M_PI*freq*n*dt);
		}
		else{
			sig = 0.0;
		}

		/* 音源 */
		P[(int)(NX/4)][(int)(NY/3)] = sig;

		/* 波形ファイル出力（時刻, 音源, 中央点の音圧） */
		fprintf(waveformfile,"%e\t%e\t%e\n", dt*n, sig, P[(int)(NX/2)][(int)(NY/2)]);
		fprintf(stderr,"%5d / %5d\r", n, Nstep );

		/* 音圧分布ファイル出力（50ステップ毎） */
		if( n % 50 == 0 ){
			sprintf(fieldfilename, "field%.6d.txt",n);
			if((fieldfile = fopen(fieldfilename,"w"))==NULL){
				printf("open error [field.txt]\n");
				return(1);
			}
			for(i=0; i<NX; i++){
				for(j=0; j<NY; j++){
					fprintf(fieldfile, "%e\t", P[i][j] );
				}
				fprintf(fieldfile, "\n");
			}
			fclose(fieldfile);
		}

	}

	/* 事後処理 *********************************************************/
	fclose(waveformfile);

	return(0);
}


/* サブルーチン ************************************************************/

/* 粒子速度の更新 */
void UpdateV()
{
	int i,j;

	for(i=1;i<NX;i++){
		for(j=0;j<NY;j++){
			Vx[i][j] += - dt / (rho * dx) * ( P[i][j] - P[i-1][j] );
		}
	}

	for(i=0;i<NX;i++){
		for(j=1;j<NY;j++){
			Vy[i][j] += - dt / (rho * dx) * ( P[i][j] - P[i][j-1] );
		}
	}
}

/* 音圧の更新 */
void UpdateP()
{
	int i,j;

	for(i=0;i<NX;i++){
		for(j=0;j<NY;j++){
			P[i][j] += - ( kappa * dt / dx )
			            * ( ( Vx[i+1][j] - Vx[i][j] ) + ( Vy[i][j+1] - Vy[i][j] ) );
		}
	}
}
