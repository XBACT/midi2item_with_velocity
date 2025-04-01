# midi2item_with_velocity

REAPER用のスクリプトで、MIDIファイルを空アイテムに変換します。元の`midi2item`スクリプトを基に、MIDIノートのベロシティ（音量）をアイテムボリュームに反映する機能を追加しました。

## 特徴
- MIDIノートの開始位置、長さ、ピッチをアイテムに変換
- ベロシティをアイテムボリューム（0.0-2.0）に反映
- 和音は自動で別々のトラックに分割

## 使い方
1. REAPERでMIDIアイテムを選択
2. スクリプトを実行（Scriptメニューからロード）
3. 子トラックにベロシティ付きの空アイテムが生成されます

## クレジット
- Original script: midi2item by ePi
- Modified by: XBACT

## ライセンス
The MIT License (MIT)

Copyright (c) 2021 ePi (original midi2item)  
Copyright (c) 2025 XBACT (modifications)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
