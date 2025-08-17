@ECHO OFF
REM GSIKibanMerge.bat
REM 国土地理院基盤地図情報zipを解凍し、基本項目をタグごとにマージ
REM 　準備　qgis_process-qgis.bat　のパスを修正する（要QGIS 3.36以上）。
REM 　　　　国土地理院基盤地図情報基本項目のzipをダウンロードし、フォルダにまとめる。
REM 使い方　エクスプローラで、「GSIKibanMerge.bat」に「国土地理院基盤地図の.zipファイルを保存したフォルダパス」をドロップする。

REM https://github.com/motohirooya/GSIKibanMerge.bat

REM ---------------------------------------------
REM 
REM パラメータ設定
REM 
REM ---------------------------------------------

REM qgis_process-qgis.batへのパス
set QP="C:\OSGeo4W\bin\qgis_process-qgis.bat"

REM qgis_process-qgisのオプション
set OPT=--no-python --skip-loading-plugins

REM 出力形式 gpkg fgb shp
set OUTPUTFILETYPE=fgb

REM マージするタグ
set TAG=AdmArea AdmBdry AdmPt BldA BldL Cntr CommBdry CommPt Cstline DEM DEMPt DGHM DGHMPt ElevPt FGDFeature GCP LeveeEdge RailCL RdArea RdASL RdCompt RdEdg RdMgtBdry RdSgmtA RvrMgtBdry SBAPt SBArea SBBdry WA WL WStrA WStrL

REM ---------------------------------------------
REM 
REM 引数、プログラム有無の確認、初期化
REM 
REM ---------------------------------------------
REM 引数確認
IF [%1]==[] (
	echo GSIKibanMerge.bat
	echo 国土地理院基盤地図情報zipを解凍し、基本項目をタグごとにマージ
	echo 使い方　GSIKibanMerge ^<国土地理院基盤地図の*.zipファイルを保存したフォルダパス^>
	pause
	exit /b
) 

REM フォルダ、バッチファイル有無確認
for %%f in ( %1 %QP% ) do (
IF NOT EXIST %%f (
	echo %%f がありません。
	pause
	exit /b
) 
) 

REM 第1引数はzipのフォルダ、サブフォルダも対象
set FOLDER=%~1

REM 作業フォルダ
set WORK=%FOLDER%\GSIKibanMergeTMP

setlocal enabledelayedexpansion

REM ---------------------------------------------
REM 
REM workフォルダの作成、zipの解凍
REM 
REM ---------------------------------------------


IF EXIST "%WORK%" (
	echo %WORK%フォルダが既にあります。終了します。
	exit /b
) ELSE (
	mkdir "%WORK%"
) 

for /F "delims=" %%f in ('dir /b /s "%FOLDER%\*.zip"') do powershell -Command Expand-Archive "%%f" "%WORK%"


REM ---------------------------------------------
REM 
REM 基本項目のマージ
REM 
REM ---------------------------------------------
REM ogrmerge.bat へのパスを通す。
call %QP% -v

for %%t in ( %TAG% ) do (

REM 該当TAGのxmlファイルが存在する場合はマージを行う
IF EXIST "%WORK%\*%%t-*.xml" (

REM マージ,ogrmergeの出力は上書きしないので、ファイル名をユニークにする。
call ogrmerge.bat -single -o "%WORK%\GSIBadsicMergeTemp1%%t.fgb" "%WORK%\*%%t-*.xml"

REM 地理院の測地成果2024にgdalが未対応のため、暫定的にXYを入れ替え
call %QP% %OPT% run native:swapxy --INPUT="%WORK%\GSIBadsicMergeTemp1%%t.fgb" --OUTPUT="%WORK%\GSIBadsicMergeTemp2%%t.fgb"

REM 属性名の変更　fid→fidgsi
call %QP% %OPT% run native:renametablefield --INPUT="%WORK%\GSIBadsicMergeTemp2%%t.fgb" --FIELD=fid --NEW_NAME=fidgsi --OUTPUT="%FOLDER%\%%t.%OUTPUTFILETYPE%"

) 
) 


REM 国土地理院基本項目　https://fgd.gsi.go.jp/otherdata/spec/FGD_DLFileSpecV4.1.pdf
REM 	タグ名	クラス名
REM 	AdmArea	行政区画(Administrative Area)
REM 	AdmBdry	行政区画界線(Administrative Boundary)
REM 	AdmPt	行政区画代表点(Representative point of Administrative Area)
REM 	BldA	建築物(Building Area)
REM 	BldL	建築物の外周線(Building Outline)
REM 	Cntr	等高線(Contour)
REM 	CommBdry	町字界線(Community Boundary)
REM 	CommPt	町字の代表点(Representative Point of Community Area)
REM 	Cstline	海岸線(Coastline)
REM 	DEM	DEM 区画(DEM Area)
REM 	DEMPt	DEM 構成点(DEM Point)
REM 	DGHM	DGHM 区画(DGHM Area)
REM 	DGHMPt	DGHM 構成点(DGHM Point)
REM 	ElevPt	標高点(Elevation Point)
REM 	FGDFeature	基盤地図情報地物(FGD    Feature)
REM 	GCP	測量の基準点(Geodetic Control Point)
REM 	LeveeEdge	河川堤防表肩法線(Riverside Edge of Levee Crown)
REM 	RailCL	軌道の中心線(Railroad Track Centerline)
REM 	RdArea	道路域(Road Area)
REM 	RdASL	道路域分割線(Road Area Split Line)
REM 	RdCompt	道路構成線(Road Component)
REM 	RdEdg	道路縁(Road Edge)
REM 	RdMgtBdry	道路区域界線(Road Management Boundary)
REM 	RdSgmtA	道路区分面(Road Segment Area)
REM 	RvrMgtBdry	河川区域界線(River Management Boundary)
REM 	SBAPt	街区の代表点(Representative Point of Street Block Area)
REM 	SBArea	街区域(Street Block Area)
REM 	SBBdry	街区線(Street Block Boundary)
REM 	WA	水域(Water Area)
REM 	WL	水涯線(Water Line)
REM 	WStrA	水部構造物面(Waterside Structure Area)
REM 	WStrL	水部構造物線(Waterside Structure Line)

REM 履歴
REM 2023/8/6 作成
REM 2023/8/15 基本項目のDEMが数値標高モデルのDEM*を拾っていたのを修正,作業フォルダの環境変数を追加
REM 2023/10/30 ローカル限定（NAS不可）。ファイル数の制限緩和
REM 2024/2/3 osgeo4w shellではなく通常のcmdから呼び出すよう変更（osgeo4w shellはpowershellへのパスが無いので使えない）。--no-python追加（多少高速化？）
REM 2024/4/11 マージをogrmerge.batに変更。ワイルドカード指定によりcmdの文字数制限を回避。
REM 2024/5/10 数値標高モデルDEM1A　追加
REM 2025/6/12 数値標高モデルのzipまとめを削除
REM 2025/8/17 地理院の測地成果2024にgdalが未対応のため、暫定的にXYを入れ替え
