@ECHO OFF
REM GSIElev.bat
REM ��Ւn�}��񐔒l�W�����f����tif�ɕϊ�����B
REM �g�p���@ GSIElev.bat <ZIP file1> [ZIP file2] [ZIP file3] ...
REM �o�͐�͓��̓t�@�C���Ɠ���

REM 2025/6/12 �쐬


REM ---------------------------------------------
REM 
REM qgis_process-qgis.bat�ւ̃p�X
REM 
REM ---------------------------------------------
REM 
set QP="C:\OSGeo4W\bin\qgis_process-qgis.bat"


REM ---------------------------------------------
REM 
REM �ϊ�����
REM 
REM ---------------------------------------------
:label_top
REM �t�@�C�������݂��Ȃ��ꍇ�I��
if not exist "%~1"   exit /b

REM �ϊ� ZIP��TIF
call %QP% run quickdemforjp:quickdemforjp --distance_units=meters --area_units=m2 --ellipsoid=EPSG:7030 --INPUT=%1 --OUTPUT_GEOTIFF="%~dp1TMP_%~n1.tif" --CRS=EPSG:4326 --SEA_AT_ZERO=false

REM ���k
gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co TILED=YES "%~dp1TMP_%~n1.tif" "%~dp1%~n1.tif"

REM �e���|�����̍폜
del "%~dp1TMP_%~n1.tif"

REM ���̃t�@�C����
shift
goto :label_top

