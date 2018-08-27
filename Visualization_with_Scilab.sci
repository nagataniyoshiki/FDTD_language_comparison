// 二次元音響FDTD速度比較 by Yoshiki NAGATANI 20141109 (https://ultrasonics.jp/nagatani/fdtd/)
//  音場の可視化スクリプト for Scilab 5

h = scf(0);								// ウィンドウの準備
set(h, 'color_map',jetcolormap(64));	// 64 段階の Jet カラーマップ

interval = 50;				// ステップ刻み
Nstep = 1000;				// 総ステップ数
image_intensity = 500;		// 画像表示の明るさ

// ファイル名のループ
for n = 0:interval:Nstep

	// 音場ファイル読み込み
	fieldfilename = sprintf("field%06d.txt",n);
	field = read(fieldfilename,-1,400);

	// 音場の表示（0～64の範囲に）
	Matplot( max(0,min(64,field*image_intensity+32)), '031', rect=[0,0,size(field,2),size(field,1)] );

	// タイトル・軸の設定
	title(['step: ', string(n), ' / ', string(Nstep)]);
	xlabel('y direction');
	ylabel('x direction');

	// 画像ファイル保存
	imgfilename = sprintf("field%06d.png",n);
	xs2png(h,imgfilename);

end
