@ECHO OFF
REM GSIKibanMerge.bat
REM ���y�n���@��Ւn�}���zip���𓀂��A��{���ڂ̓^�O���ƂɃ}�[�W�A���l�W�����f���͎�ޕʂ�zip�ɂ܂Ƃ߂�
REM �g�����@OSGeo4W Shell���J���āAGSIKibanMerge.bat <���y�n���@��Ւn�}��*.zip�t�@�C����ۑ������t�H���_�p�X>
REM ���m�̖��@��{���ڂ̃t�@�C�����������ƁAcmd�Ŏg�p�ł��镶����̍ő咷�� 8191 �����ɒ�G����
REM 2023/8/6 �쐬
REM 2023/8/15 ��{���ڂ�DEM�����l�W�����f����DEM*���E���Ă����̂��C��,��ƃt�H���_�̊��ϐ���ǉ�
REM https://github.com/motohirooya/GSIKibanMerge.bat

REM ---------------------------------------------
REM 
REM �p�����[�^�ݒ�
REM 
REM ---------------------------------------------
REM �v���O�����ւ̃p�X
set QGP="C:\OSGeo4W\bin\qgis_process-qgis.bat"
set PS="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

REM �}�[�W����^�O
set TAG=AdmArea AdmPt BldA Cntr CommBdry CommPt Cstline DEM DGHM ElevPt FGDFeature GCP LeveeEdge RailCL RdArea RdASL RdCompt RdEdg RdMgtBdry RdSgmtA RvrMgtBdry SBArea WA WL WStrA

REM �o�͌`�� gpkg fgb shp
set OUTPUTFILETYPE=fgb

REM ��1������zip�̃t�H���_�A�T�u�t�H���_���Ώ�
set FOLDER=%~1

REM ��ƃt�H���_
set WORK=%FOLDER%\data

REM ---------------------------------------------
REM 
REM �����A�v���O�����L���̊m�F
REM 
REM ---------------------------------------------
IF [%1]==[] (
	echo GSIKibanMerge.bat
	echo ���y�n���@��Ւn�}���zip���񓚂��A��{���ڂ̓^�O���ƂɃ}�[�W�A���l�W�����f���͎�ޕʂ�zip�ɂ܂Ƃ߂�
	echo �g�����@OSGeo4W Shell���J���āAGSIKibanMerge.bat ^<���y�n���@��Ւn�}��*.zip�t�@�C����ۑ������t�H���_�p�X^>
	exit /b
) 

for %%f in ( %1 %QGP% %PS% ) do (
IF NOT EXIST %%f (
	echo %%f ������܂���B
	exit /b
) 
) 

REM ---------------------------------------------
REM 
REM zip�̉�
REM 
REM ---------------------------------------------


IF EXIST "%WORK%" (
	echo %WORK%�t�H���_�����ɂ���܂��B�I�����܂��B
	exit /b
) ELSE (
	mkdir "%WORK%"
) 

for /F "delims=" %%f in ('dir /b /s "%FOLDER%\*.zip"') do %PS% -Command Expand-Archive "%%f" "%WORK%"

REM ---------------------------------------------
REM 
REM ��{���ڂ̃}�[�W
REM 
REM ---------------------------------------------

setlocal enabledelayedexpansion
for %%t in ( %TAG% ) do (

REM xml�t�@�C���p�X�̎擾
set XMLFILES=
for /F "delims=" %%f in ('dir /b /s "%WORK%\*%%t-*.xml"') do set XMLFILES=!XMLFILES! --LAYERS="%%f"

REM �t�@�C�����擾�ł��Ȃ��ꍇ�͎��s���Ȃ�
IF [!XMLFILES!] neq [] (
REM �}�[�W
call %QGP% run native:mergevectorlayers !XMLFILES! --OUTPUT="%WORK%\GSIBadsicMergeTemp1.fgb"
REM �������̕ύX�@fid��fidgsi
call %QGP% run native:renametablefield --INPUT="%WORK%\GSIBadsicMergeTemp1.fgb" --FIELD=fid --NEW_NAME=fidgsi --OUTPUT="%WORK%\GSIBadsicMergeTemp2.fgb"
REM �����폜�@layer;path
call %QGP% run native:deletecolumn --INPUT="%WORK%\GSIBadsicMergeTemp2.fgb" --COLUMN=layer --COLUMN=path --OUTPUT="%FOLDER%\%%t.%OUTPUTFILETYPE%"
) 
) 

REM ---------------------------------------------
REM 
REM ���l�W�����f������ޕʂ�zip�ɂ܂Ƃ߂�
REM 
REM ---------------------------------------------
for %%t in ( DEM5A DEM5B DEM5C DEM10A DEM10B ) do (
IF EXIST "%WORK%\*%%t*.xml" %PS% -Command Compress-Archive -Path "%WORK%\*%%t*.xml" -DestinationPath "%FOLDER%\PACK-%%t.zip"
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
