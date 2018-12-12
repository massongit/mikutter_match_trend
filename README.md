# トレンドへの追随度チェックプラグイン
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Maintainability](https://api.codeclimate.com/v1/badges/5afefdf688bc30f56e3d/maintainability)](https://codeclimate.com/github/massongit/mikutter_match_trend/maintainability)
<a href="https://developer.yahoo.co.jp/about">
<img src="https://s.yimg.jp/images/yjdn/yjdn_attbtn2_105_17.gif" width="105" height="17" title="Webサービス by Yahoo! JAPAN" alt="Webサービス by Yahoo! JAPAN" border="0" style="margin:15px 15px 15px 15px"></a>

トレンドへの追随度 (TL上のツイートの特徴語と特定のユーザーのツイートの特徴語の類似度) を算出するmikutterプラグイン

## 作者
Masaya Suzuki <suzukimasaya428@gmail.com>

## バージョン
1.0

## 動作環境
* mikutter 3.8.0

## 必要なもの
* Yahoo! JAPAN Webサービス用アプリケーションID (取得方法に関しては[ご利用ガイド - Yahoo!デベロッパーネットワーク](https://developer.yahoo.co.jp/start/)参照)

## インストールコマンド
```bash
mkdir -p ~/.mikutter/plugin; git clone https://github.com/massongit/mikutter_match_trend match_trend
```

## アルゴリズム
TL上のツイートの特徴語の集合を<a href="https://www.codecogs.com/eqnedit.php?latex=T" target="_blank"><img src="https://latex.codecogs.com/gif.latex?T" title="T" /></a>、特定のユーザーのツイートの特徴語の集合を<a href="https://www.codecogs.com/eqnedit.php?latex=U" target="_blank"><img src="https://latex.codecogs.com/gif.latex?U" title="U" /></a>としたとき、これらの集合の類似度をSimpson係数 (次式) で算出しています。  
なお、特徴語の集合内には、スコアに応じた割合で特徴語が格納されています。

<a href="https://www.codecogs.com/eqnedit.php?latex=\mathrm{simpson}(T,&space;U)=\frac{|T&space;\cap&space;U|}{\min(|T|,&space;|U|)}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\mathrm{simpson}(T,&space;U)=\frac{|T&space;\cap&space;U|}{\min(|T|,&space;|U|)}" title="\mathrm{simpson}(T, U)=\frac{|T \cap U|}{\min(|T|, |U|)}" /></a>
