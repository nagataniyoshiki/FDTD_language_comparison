# 二次元音響FDTD速度比較


## 概要

二次元音響FDTD法（Two-dimensional finite-difference time-domain method）の各種プログラミング言語の速度比較デモです。用意しているのは C言語（.c），Fortran 90（.f90），Julia（.jl），MATLAB（.m），Processing 3（.pde），Perl（.pl），Python 3（.py），Scilab（.sci） の各言語のプログラムです。  
モデルは均一な気体で，モデル端面の吸収境界条件は実装していません。FDTD 法については https://ultrasonics.jp/nagatani/fdtd/ なども参照して下さい。  
計算結果の音場は Visualization_with_Scilab.sci で可視化することができます（Scilab 5 以降対応）。  
Speed_Comparison.txt は手元の環境で測ってみた結果です。ファイル出力および画面出力をオフにした状態で10000ステップ分を演算するのに掛かった時間を人力で記録しました。  


## ライセンス / License

Contents are licensed under [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/) (Creative Commons Attribution-ShareAlike 3.0 Unported License).  
これらのコンテンツはクリエイティブコモンズ [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/) ライセンスの元で公開しています。


***


長谷 芳樹 （神戸市立工業高等専門学校）  
Yoshiki NAGATANI, Kobe City College of Technology, Japan  
 https://ultrasonics.jp/nagatani/  
 https://twitter.com/nagataniyoshiki
