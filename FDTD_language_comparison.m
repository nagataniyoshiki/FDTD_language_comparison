% �񎟌�����FDTD���x��r by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/)
%  disabled file output for testing speed 20180829

NX = 300;						% ��ԃZ���� X [pixels]
NY = 400;						% ��ԃZ���� Y [pixels]

dx = 0.01;						% ��ԍ��� [m]
dt = 20.0e-6;					% ���ԍ��� [s]

Nstep = 10000;					% �v�Z�X�e�b�v�� [��]

freq = 1.0e3;					% �����g�`�̎��g�� [Hz]

rho = 1.3;						% ���x�� [kg/m^3]
kappa = 142.0e3;				% �̐ϒe������ [Pa]

Vx = zeros(NX+1,NY  );			% x�������q���x [m/s]
Vy = zeros(NX,  NY+1);			% y�������q���x [m/s]
P  = zeros(NX,  NY  );			% ���� [Pa]


% ���O���� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% waveformfile = fopen('waveform.txt','w');

% ���C�����[�v %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 0:Nstep,

	% �X�V�i������ FDTD �̖{�́j
	% ���q���x�̍X�V
	Vx(2:NX,:) = Vx(2:NX,:) - dt / (rho * dx) * ( P(2:NX,:) - P(1:NX-1,:) );
	Vy(:,2:NY) = Vy(:,2:NY) - dt / (rho * dx) * ( P(:,2:NY) - P(:,1:NY-1) );
	% �����̍X�V
	P(1:NX,1:NY) = P(1:NX,1:NY) - ( kappa * dt / dx ) * ( ( Vx(2:NX+1,:) - Vx(1:NX,:) ) + ( Vy(:,2:NY+1) - Vy(:,1:NY) ) );

	% �����g�`�������i�����g�~�P�g with �n�����j
	if n < (1.0/freq)/dt
		sig = (1.0-cos(2.0*pi*freq*n*dt))/2.0 * sin(2.0*pi*freq*n*dt);
	else
		sig = 0.0;
	end

	% ����
	P(floor(NX/4+1),floor(NY/3+1)) = sig;

	% �g�`�t�@�C���o�́i����, ����, �����_�̉����j
%	fprintf(waveformfile,'%e\t%e\t%e\n', dt*n, sig, P(floor(NX/2+1),floor(NY/2+1)));

	% �������z�t�@�C���o�́i50�X�e�b�v���j
	if rem(n, 50) == 0
		fprintf('%5d / %5d\r', n, Nstep);
%		����t�@�C�����o�͂���ꍇ�͈ȉ��̃R�����g���O���ĉ�����
%		fieldfilename = sprintf('field%.6d.txt',n);
%		fieldfile = fopen(fieldfilename,'w');
%		for i = 1:NX
%			for j = 1:NY
%				fprintf(fieldfile,'%e\t',P(i,j));
%			end
%			fprintf(fieldfile,'\n');
%		end
%		fclose(fieldfile);
	end
end

% ���㏈�� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fclose(waveformfile);
