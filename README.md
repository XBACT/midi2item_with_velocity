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
