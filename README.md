# GSIKibanMerge.bat
- 国土地理院基盤地図情報zipを解凍し、基本項目をタグごとにマージ
- 準備　qgis_process-qgis.bat　のパスを修正する。<br>国土地理院基盤地図情報基本項目のzipをダウンロードし、フォルダにまとめる。
- 使い方　エクスプローラで、「GSIKibanMerge.bat」に「国土地理院基盤地図の.zipファイルを保存したフォルダパス」をドロップする。
- 要QGIS 3.36以上

# GSIElev.bat
- 基盤地図情報数値標高モデルをtifに変換
- 準備　qgis_process-qgis.bat　のパスを修正する。<br>国土地理院基盤地図情報数値標高モデルのzipをダウンロードし、フォルダにまとめる。
- 使用方法 エクスプローラで、「GSIElev.bat」に 「国土地理院基盤地図数値標高モデルの.zipファイル」をドロップする。
- 出力先は入力ファイルと同じ
- 要QGIS 3.36以上、QuickDEM4JP(Defaultプロファイルにインストール)
