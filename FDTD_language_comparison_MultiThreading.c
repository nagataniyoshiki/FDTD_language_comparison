/* �񎟌�����FDTD���x��r by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/) */
/*  disabled file output for testing speed 20180829 */
/*  multi threading version by Yoshiki NAGATANI 20180829 */

#include <stdio.h>
#include <math.h>
#include <omp.h>
#include <time.h>

#define NX 300				/* ��ԃZ���� X [pixels] */
#define NY 400				/* ��ԃZ���� Y [pixels] */

#define dx 0.01				/* ��ԍ��� [m] */
#define dt 20.0e-6			/* ���ԍ��� [s] */

#define Nstep 10000			/* �v�Z�X�e�b�v�� [��] */

#define freq 1.0e3			/* �����g�`�̎��g�� [Hz] */

#define rho 1.3				/* ���x�� [kg/m^3] */
#define kappa 142.0e3		/* �̐ϒe������ [Pa] */

double Vx[NX+1][NY];		/* x�������q���x [m/s] */
double Vy[NX][NY+1];		/* y�������q���x [m/s] */
double P[NX][NY];			/* ���� [Pa] */

void UpdateV(),UpdateP();


/* ���C���֐� ************************************************************/

int main(void)
{
	int i,j;
	int n;
	double sig;
	FILE *waveformfile, *fieldfile;
	char fieldfilename[30];
	struct timespec time_start, time_end;

	clock_gettime(CLOCK_REALTIME, &time_start);

	/* ���O���� *********************************************************/
/*	if((waveformfile = fopen("waveform.txt","w"))==NULL){
		printf("open error [waveform.txt]\n");
		return(1);
	}*/

	/* ���q���x���z�E�������z�������� *********************************************************/
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

	/* ���C�����[�v *********************************************************/
	for(n=0;n<=Nstep;n++){

		/* �X�V�i������ FDTD �̖{�́j */
		UpdateV();
		UpdateP();

		/* �����g�`�������i�����g�~�P�g with �n�����j*/
		if( n < (1.0/freq)/dt ){
			sig = (1.0-cos(2.0*M_PI*freq*n*dt))/2.0 * sin(2.0*M_PI*freq*n*dt);
		}
		else{
			sig = 0.0;
		}

		/* ���� */
		P[(int)(NX/4)][(int)(NY/3)] = sig;

		/* �g�`�t�@�C���o�́i����, ����, �����_�̉����j */
/*		fprintf(waveformfile,"%e\t%e\t%e\n", dt*n, sig, P[(int)(NX/2)][(int)(NY/2)]);*/

		/* �������z�t�@�C���o�́i50�X�e�b�v���j */
		if( n % 50 == 0 ){
			fprintf(stderr,"%5d / %5d\r", n, Nstep );
/*			����t�@�C�����o�͂���ꍇ�͈ȉ��̃R�����g���O���ĉ����� */
/*			sprintf(fieldfilename, "field%.6d.txt",n);
			if((fieldfile = fopen(fieldfilename,"w"))==NULL){
				printf("open error [field.txt]\n");
				return(1);
			}
			for(i=0; i<NX; i++){
				for(j=0; j<NY; j++){
					fprintf(fieldfile, "%e\t", P[i][j] );
				}
				fprintf(fieldfile, "n");
			}
			fclose(fieldfile);*/
		}

	}

	/* ���㏈�� *********************************************************/
/*	fclose(waveformfile);*/

	clock_gettime(CLOCK_REALTIME, &time_end);
	fprintf(stderr, "\n Computation time: ");
	if( time_end.tv_nsec >= time_start.tv_nsec )
		fprintf(stderr,"%ld.%09ld s.\n", time_end.tv_sec - time_start.tv_sec, time_end.tv_nsec - time_start.tv_nsec);
	else
		fprintf(stderr,"%ld.%09ld s.\n", time_end.tv_sec - time_start.tv_sec - 1, (long int)1.0e9 + time_end.tv_nsec - time_start.tv_nsec);


	return(0);
}


/* �T�u���[�`�� ************************************************************/

/* ���q���x�̍X�V */
void UpdateV()
{
	int i,j;

	#pragma omp parallel for private(i)
	for(i=1;i<NX;i++){
		for(j=0;j<NY;j++){
			Vx[i][j] += - dt / (rho * dx) * ( P[i][j] - P[i-1][j] );
		}
	}

	#pragma omp parallel for private(i)
	for(i=0;i<NX;i++){
		for(j=1;j<NY;j++){
			Vy[i][j] += - dt / (rho * dx) * ( P[i][j] - P[i][j-1] );
		}
	}
}

/* �����̍X�V */
void UpdateP()
{
	int i,j;

	#pragma omp parallel for private(i)
	for(i=0;i<NX;i++){
		for(j=0;j<NY;j++){
			P[i][j] += - ( kappa * dt / dx )
			            * ( ( Vx[i+1][j] - Vx[i][j] ) + ( Vy[i][j+1] - Vy[i][j] ) );
		}
	}
}
