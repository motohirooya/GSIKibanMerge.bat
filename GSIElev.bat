@ECHO OFF
REM GSIElev.bat
REM 基盤地図情報数値標高モデルをtifに変換する。
REM 使用方法 GSIElev.bat <ZIP file1> [ZIP file2] [ZIP file3] ...
REM 出力先は入力ファイルと同じ

REM 2025/6/12 作成


REM ---------------------------------------------
REM 
REM qgis_process-qgis.batへのパス
REM 
REM ---------------------------------------------
REM 
set QP="C:\OSGeo4W\bin\qgis_process-qgis.bat"


REM ---------------------------------------------
REM 
REM 変換処理
REM 
REM ---------------------------------------------
:label_top
REM ファイルが存在しない場合終了
if not exist "%~1"   exit /b

REM 変換 ZIP→TIF
call %QP% run quickdemforjp:quickdemforjp --distance_units=meters --area_units=m2 --ellipsoid=EPSG:7030 --INPUT=%1 --OUTPUT_GEOTIFF="%~dp1TMP_%~n1.tif" --CRS=EPSG:4326 --SEA_AT_ZERO=false

REM 圧縮
gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES "%~dp1TMP_%~n1.tif" "%~dp1%~n1.tif"

REM テンポラリの削除
del "%~dp1TMP_%~n1.tif"

REM 次のファイルへ
shift
goto :label_top

