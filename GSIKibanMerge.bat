@ECHO OFF
REM GSIKibanMerge.bat
REM 国土地理院基盤地図情報zipを解凍し、基本項目はタグごとにマージ、数値標高モデルは種類別にzipにまとめる
REM 使い方　OSGeo4W Shellを開いて、GSIKibanMerge.bat <国土地理院基盤地図の*.zipファイルを保存したフォルダパス>
REM 既知の問題　基本項目のファイル数が多いと、cmdで使用できる文字列の最大長は 8191 文字に抵触する
REM 2023/8/6 作成
REM 2023/8/15 基本項目のDEMが数値標高モデルのDEM*を拾っていたのを修正,作業フォルダの環境変数を追加
REM https://github.com/motohirooya/GSIKibanMerge.bat

REM ---------------------------------------------
REM 
REM パラメータ設定
REM 
REM ---------------------------------------------
REM プログラムへのパス
set QGP="C:\OSGeo4W\bin\qgis_process-qgis.bat"
set PS="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

REM マージするタグ
set TAG=AdmArea AdmPt BldA Cntr CommBdry CommPt Cstline DEM DGHM ElevPt FGDFeature GCP LeveeEdge RailCL RdArea RdASL RdCompt RdEdg RdMgtBdry RdSgmtA RvrMgtBdry SBArea WA WL WStrA

REM 出力形式 gpkg fgb shp
set OUTPUTFILETYPE=fgb

REM 第1引数はzipのフォルダ、サブフォルダも対象
set FOLDER=%~1

REM 作業フォルダ
set WORK=%FOLDER%\data

REM ---------------------------------------------
REM 
REM 引数、プログラム有無の確認
REM 
REM ---------------------------------------------
IF [%1]==[] (
	echo GSIKibanMerge.bat
	echo 国土地理院基盤地図情報zipを回答し、基本項目はタグごとにマージ、数値標高モデルは種類別にzipにまとめる
	echo 使い方　OSGeo4W Shellを開いて、GSIKibanMerge.bat ^<国土地理院基盤地図の*.zipファイルを保存したフォルダパス^>
	exit /b
) 

for %%f in ( %1 %QGP% %PS% ) do (
IF NOT EXIST %%f (
	echo %%f がありません。
	exit /b
) 
) 

REM ---------------------------------------------
REM 
REM zipの解凍
REM 
REM ---------------------------------------------


IF EXIST "%WORK%" (
	echo %WORK%フォルダが既にあります。終了します。
	exit /b
) ELSE (
	mkdir "%WORK%"
) 

for /F "delims=" %%f in ('dir /b /s "%FOLDER%\*.zip"') do %PS% -Command Expand-Archive "%%f" "%WORK%"

REM ---------------------------------------------
REM 
REM 基本項目のマージ
REM 
REM ---------------------------------------------

setlocal enabledelayedexpansion
for %%t in ( %TAG% ) do (

REM xmlファイルパスの取得
set XMLFILES=
for /F "delims=" %%f in ('dir /b /s "%WORK%\*%%t-*.xml"') do set XMLFILES=!XMLFILES! --LAYERS="%%f"

REM ファイルが取得できない場合は実行しない
IF [!XMLFILES!] neq [] (
REM マージ
call %QGP% run native:mergevectorlayers !XMLFILES! --OUTPUT="%WORK%\GSIBadsicMergeTemp1.fgb"
REM 属性名の変更　fid→fidgsi
call %QGP% run native:renametablefield --INPUT="%WORK%\GSIBadsicMergeTemp1.fgb" --FIELD=fid --NEW_NAME=fidgsi --OUTPUT="%WORK%\GSIBadsicMergeTemp2.fgb"
REM 属性削除　layer;path
call %QGP% run native:deletecolumn --INPUT="%WORK%\GSIBadsicMergeTemp2.fgb" --COLUMN=layer --COLUMN=path --OUTPUT="%FOLDER%\%%t.%OUTPUTFILETYPE%"
) 
) 

REM ---------------------------------------------
REM 
REM 数値標高モデルを種類別にzipにまとめる
REM 
REM ---------------------------------------------
for %%t in ( DEM5A DEM5B DEM5C DEM10A DEM10B ) do (
IF EXIST "%WORK%\*%%t*.xml" %PS% -Command Compress-Archive -Path "%WORK%\*%%t*.xml" -DestinationPath "%FOLDER%\PACK-%%t.zip"
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
