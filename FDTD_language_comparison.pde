/* 二次元音響FDTD速度比較 by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/) */

int NX = 300;							/* 空間セル数 X [pixels] */
int NY = 400;							/* 空間セル数 Y [pixels] */

double dx = 0.01;						/* 空間刻み [m] */
double dt = 20.0e-6;					/* 時間刻み [s] */

int Nstep = 1000;						/* 計算ステップ数 [回] */

double freq = 1.0e3;					/* 初期波形の周波数 [Hz] */

double rho = 1.3;						/* 密度ρ [kg/m^3] */
double kappa = 142.0e3;					/* 体積弾性率κ [Pa] */

double[][] Vx = new double[NX+1][NY];	/* x方向粒子速度 [m/s] */
double[][] Vy = new double[NX][NY+1];	/* y方向粒子速度 [m/s] */
double[][] P  = new double[NX][NY];		/* 音圧 [Pa] */

int n = 0;
double sig;
PrintWriter waveformfile,fieldfile;
String fieldfilename;

int col;								/* 画像表示用の一時変数（計算とは無関係）*/
double image_intensity = 6000;			/* 画像表示の明るさ（計算とは無関係）*/


/* 事前準備 *********************************************************/
void setup()
{
	size(400,300);
	frameRate(1000);
	waveformfile = createWriter("waveform.txt");

	/* 粒子速度分布・音圧分布を初期化 *********************************************************/
	for(int i=0;i<NX+1;i++){
		for(int j=0;j<NY;j++){
			Vx[i][j] = 0.0;
		}
	}
	for(int i=0;i<NX;i++){
		for(int j=0;j<NY+1;j++){
			Vy[i][j] = 0.0;
		}
	}
	for(int i=0;i<NX;i++){
		for(int j=0;j<NY;j++){
			P[i][j]  = 0.0;
		}
	}
}

/* メインループ *********************************************************/
void draw()
{
	PImage img = createImage( NY, NX, RGB );

	if( n <= Nstep ){
		/* 更新（ここが FDTD の本体） */
		UpdateV();
		UpdateP();

		/* 初期波形を準備（正弦波×１波 with ハン窓）
			（Processing の cos と sin は float なので Java の Math.cos と Math.sin を使う）*/
		if( n < (1.0/freq)/dt ){
			sig = (1.0-Math.cos((2.0*PI*freq*n*dt)))/2.0 * Math.sin((2.0*PI*freq*n*dt));
		}
		else{
			sig = 0.0;
		}

		/* 音源 */
		P[int(NX/4)][int(NY/3)] = sig;

		/* 波形ファイル出力（時刻, 音源, 中央点の音圧） */
		println(n);
		waveformfile.println(String.format("%e",n*dt)+"\t"+String.format("%e",sig)+"\t"+String.format("%e",P[int(NX/2)][int(NY/2)]));
		waveformfile.flush();

		/* 音圧分布ファイル出力（50ステップ毎） */
		if( n % 50 == 0 ){
			fieldfilename = "field"+String.format("%06d",n)+".txt";
			fieldfile = createWriter(fieldfilename);
			for(int i=0; i<NX; i++){
				for(int j=0; j<NY; j++){
					fieldfile.print(String.format("%e\t",P[i][j]) );
					// ↓せっかく Processing なので音場を表示してみる
					col = int((float)(P[i][j]*image_intensity));
					img.pixels[i*NY+j] = color(col,col,col);
				}
				fieldfile.print("\n");
			}
			image(img, 0, 0);
			fieldfile.flush();
			fieldfile.close();
		}

		n++;
	}

	/* 事後処理 *********************************************************/
	else{
		waveformfile.close();
		exit();
	}
}


/* サブルーチン ************************************************************/

/* 粒子速度の更新 */
void UpdateV()
{
	for(int i=1;i<NX;i++){
		for(int j=0;j<NY;j++){
			Vx[i][j] += - dt / (rho * dx) * ( P[i][j] - P[i-1][j] );
		}
	}

	for(int i=0;i<NX;i++){
		for(int j=1;j<NY;j++){
			Vy[i][j] += - dt / (rho * dx) * ( P[i][j] - P[i][j-1] );
		}
	}
}

/* 音圧の更新 */
void UpdateP()
{
	for(int i=0;i<NX;i++){
		for(int j=0;j<NY;j++){
			P[i][j] += - ( kappa * dt / dx )
			            * ( ( Vx[i+1][j] - Vx[i][j] ) + ( Vy[i][j+1] - Vy[i][j] ) );
		}
	}
}
