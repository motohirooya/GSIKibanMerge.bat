# GSIKibanMerge.bat
+ 国土地理院基盤地図情報zipを解凍し、基本項目はタグごとにマージ、数値標高モデルは種類別にzipにまとめる
+ 使い方　WindowsにQGISをインストールし、OSGeo4W Shellを開いて、GSIKibanMerge.bat <国土地理院基盤地図の*.zipファイルを保存したフォルダパス>
+ 必要に応じて、GSIKibanMerge.bat を編集し、qgis_processとpowershellのパスを修正する。
+ 既知の問題　基本項目のファイル数が多いと、cmdで使用できる文字列の最大長は 8191 文字に抵触する
