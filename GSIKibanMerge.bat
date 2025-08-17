@ECHO OFF
REM GSIKibanMerge.bat
REM ���y�n���@��Ւn�}���zip���𓀂��A��{���ڂ��^�O���ƂɃ}�[�W
REM �@�����@qgis_process-qgis.bat�@�̃p�X���C������i�vQGIS 3.36�ȏ�j�B
REM �@�@�@�@���y�n���@��Ւn�}����{���ڂ�zip���_�E�����[�h���A�t�H���_�ɂ܂Ƃ߂�B
REM �g�����@�G�N�X�v���[���ŁA�uGSIKibanMerge.bat�v�Ɂu���y�n���@��Ւn�}��.zip�t�@�C����ۑ������t�H���_�p�X�v���h���b�v����B

REM https://github.com/motohirooya/GSIKibanMerge.bat

REM ---------------------------------------------
REM 
REM �p�����[�^�ݒ�
REM 
REM ---------------------------------------------

REM qgis_process-qgis.bat�ւ̃p�X
set QP="C:\OSGeo4W\bin\qgis_process-qgis.bat"

REM qgis_process-qgis�̃I�v�V����
set OPT=--no-python --skip-loading-plugins

REM �o�͌`�� gpkg fgb shp
set OUTPUTFILETYPE=fgb

REM �}�[�W����^�O
set TAG=AdmArea AdmBdry AdmPt BldA BldL Cntr CommBdry CommPt Cstline DEM DEMPt DGHM DGHMPt ElevPt FGDFeature GCP LeveeEdge RailCL RdArea RdASL RdCompt RdEdg RdMgtBdry RdSgmtA RvrMgtBdry SBAPt SBArea SBBdry WA WL WStrA WStrL

REM ---------------------------------------------
REM 
REM �����A�v���O�����L���̊m�F�A������
REM 
REM ---------------------------------------------
REM �����m�F
IF [%1]==[] (
	echo GSIKibanMerge.bat
	echo ���y�n���@��Ւn�}���zip���𓀂��A��{���ڂ��^�O���ƂɃ}�[�W
	echo �g�����@GSIKibanMerge ^<���y�n���@��Ւn�}��*.zip�t�@�C����ۑ������t�H���_�p�X^>
	pause
	exit /b
) 

REM �t�H���_�A�o�b�`�t�@�C���L���m�F
for %%f in ( %1 %QP% ) do (
IF NOT EXIST %%f (
	echo %%f ������܂���B
	pause
	exit /b
) 
) 

REM ��1������zip�̃t�H���_�A�T�u�t�H���_���Ώ�
set FOLDER=%~1

REM ��ƃt�H���_
set WORK=%FOLDER%\GSIKibanMergeTMP

setlocal enabledelayedexpansion

REM ---------------------------------------------
REM 
REM work�t�H���_�̍쐬�Azip�̉�
REM 
REM ---------------------------------------------


IF EXIST "%WORK%" (
	echo %WORK%�t�H���_�����ɂ���܂��B�I�����܂��B
	exit /b
) ELSE (
	mkdir "%WORK%"
) 

for /F "delims=" %%f in ('dir /b /s "%FOLDER%\*.zip"') do powershell -Command Expand-Archive "%%f" "%WORK%"


REM ---------------------------------------------
REM 
REM ��{���ڂ̃}�[�W
REM 
REM ---------------------------------------------
REM ogrmerge.bat �ւ̃p�X��ʂ��B
call %QP% -v

for %%t in ( %TAG% ) do (

REM �Y��TAG��xml�t�@�C�������݂���ꍇ�̓}�[�W���s��
IF EXIST "%WORK%\*%%t-*.xml" (

REM �}�[�W,ogrmerge�̏o�͂͏㏑�����Ȃ��̂ŁA�t�@�C���������j�[�N�ɂ���B
call ogrmerge.bat -single -o "%WORK%\GSIBadsicMergeTemp1%%t.fgb" "%WORK%\*%%t-*.xml"

REM �n���@�̑��n����2024��gdal�����Ή��̂��߁A�b��I��XY�����ւ�
call %QP% %OPT% run native:swapxy --INPUT="%WORK%\GSIBadsicMergeTemp1%%t.fgb" --OUTPUT="%WORK%\GSIBadsicMergeTemp2%%t.fgb"

REM �������̕ύX�@fid��fidgsi
call %QP% %OPT% run native:renametablefield --INPUT="%WORK%\GSIBadsicMergeTemp2%%t.fgb" --FIELD=fid --NEW_NAME=fidgsi --OUTPUT="%FOLDER%\%%t.%OUTPUTFILETYPE%"

) 
) 


REM ���y�n���@��{���ځ@https://fgd.gsi.go.jp/otherdata/spec/FGD_DLFileSpecV4.1.pdf
REM 	�^�O��	�N���X��
REM 	AdmArea	�s�����(Administrative Area)
REM 	AdmBdry	�s�����E��(Administrative Boundary)
REM 	AdmPt	�s������\�_(Representative point of Administrative Area)
REM 	BldA	���z��(Building Area)
REM 	BldL	���z���̊O����(Building Outline)
REM 	Cntr	������(Contour)
REM 	CommBdry	�����E��(Community Boundary)
REM 	CommPt	�����̑�\�_(Representative Point of Community Area)
REM 	Cstline	�C�ݐ�(Coastline)
REM 	DEM	DEM ���(DEM Area)
REM 	DEMPt	DEM �\���_(DEM Point)
REM 	DGHM	DGHM ���(DGHM Area)
REM 	DGHMPt	DGHM �\���_(DGHM Point)
REM 	ElevPt	�W���_(Elevation Point)
REM 	FGDFeature	��Ւn�}���n��(FGD    Feature)
REM 	GCP	���ʂ̊�_(Geodetic Control Point)
REM 	LeveeEdge	�͐��h�\���@��(Riverside Edge of Levee Crown)
REM 	RailCL	�O���̒��S��(Railroad Track Centerline)
REM 	RdArea	���H��(Road Area)
REM 	RdASL	���H�敪����(Road Area Split Line)
REM 	RdCompt	���H�\����(Road Component)
REM 	RdEdg	���H��(Road Edge)
REM 	RdMgtBdry	���H���E��(Road Management Boundary)
REM 	RdSgmtA	���H�敪��(Road Segment Area)
REM 	RvrMgtBdry	�͐���E��(River Management Boundary)
REM 	SBAPt	�X��̑�\�_(Representative Point of Street Block Area)
REM 	SBArea	�X���(Street Block Area)
REM 	SBBdry	�X���(Street Block Boundary)
REM 	WA	����(Water Area)
REM 	WL	���U��(Water Line)
REM 	WStrA	�����\������(Waterside Structure Area)
REM 	WStrL	�����\������(Waterside Structure Line)

REM ����
REM 2023/8/6 �쐬
REM 2023/8/15 ��{���ڂ�DEM�����l�W�����f����DEM*���E���Ă����̂��C��,��ƃt�H���_�̊��ϐ���ǉ�
REM 2023/10/30 ���[�J������iNAS�s�j�B�t�@�C�����̐����ɘa
REM 2024/2/3 osgeo4w shell�ł͂Ȃ��ʏ��cmd����Ăяo���悤�ύX�iosgeo4w shell��powershell�ւ̃p�X�������̂Ŏg���Ȃ��j�B--no-python�ǉ��i�����������H�j
REM 2024/4/11 �}�[�W��ogrmerge.bat�ɕύX�B���C���h�J�[�h�w��ɂ��cmd�̕���������������B
REM 2024/5/10 ���l�W�����f��DEM1A�@�ǉ�
REM 2025/6/12 ���l�W�����f����zip�܂Ƃ߂��폜
REM 2025/8/17 �n���@�̑��n����2024��gdal�����Ή��̂��߁A�b��I��XY�����ւ�
