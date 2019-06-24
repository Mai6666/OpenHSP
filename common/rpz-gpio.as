;	RPZ-Sensor Raspberry Pi module
#ifndef __rpz-gpio__
#define __rpz-gpio__

#include "hsp3dish.as"

	;	RPZ-Sensor用の拡張コマンドを定義するファイルです
	;	#include "rpz-gpio.as"
	;	を先頭に入れて使用してください
	;

#module
#deffunc gpmes str _p1

	;	gpmes "メッセージ"
	;	(簡易画面表示用)メッセージ更新
	;	update命令で画面更新する際のメッセージを設定します
	;
	_umsg=_p1
	return

#deffunc update int _p1

	;	update フレーム数
	;	(簡易画面表示用)フレーム更新
	;	フレーム数の値だけ、画面のフレーム更新を行います
	;	その際にgpmesで設定した文字列を表示します
	;
	fr=_p1
	if fr<=0 : fr=1
	repeat fr
	redraw 0
	pos 20,20
	mes _umsg
	redraw 1
	await 66
	loop
	return

#deffunc getnotestr var _p1, str _p2

	;	getnotestr 取得先変数, "検索文字列"
	;	noteselで指定した文字列バッファの中から
	;	"検索文字列"で指定した文字列で始まる行の内容を取得する
	;	結果は取得先変数に代入される
	;	該当文字列がなかった場合は""が代入される
	;
	s1=_p2				; 検索文字列
	s1len=strlen(s1)		; s1の長さ(byte)を取得
 	s1res=notefind(s1,1)		; s1で始まる行を検索
	if s1res<0 : _p1="" : return	; 該当行なし
	noteget s2,s1res		; 該当行を取得
	_p1=strmid(s2,s1len,255)	; 検索文字列以降を取得
	return

#deffunc geti2c

	;	geti2c
	;	rpz-sensorボードのI2C関連情報を取得する
	;	(rpz-sensorコマンドを使用、取得までラグがあります)
	;	以下の変数に結果が代入されます(すべて実数型になります)
	;	(温度) rpz_temp
	;	(気圧) rpz_pressure
	;	(湿度) rpz_humidity
	;	(照度) rpz_lux
	;
	exec "/home/pi/ome/bin/rpz-sensor >result.txt"
	notesel msg
	noteload "result.txt"		; result.txtを取り込む
	getnotestr res," Temp :"	; Tempの行内容をresに取得
	rpz_temp@=0.0+res
	getnotestr res," Pressure :"	; Pressureの行内容をresに取得
	rpz_pressure@=0.0+res
	getnotestr res," Humidity :"	; Humidityの行内容をresに取得
	rpz_humidity@=0.0+res
	getnotestr res," Lux :"		; Luxの行内容をresに取得
	rpz_lux@=0.0+res
	return 0

#deffunc i2cinit
	devcontrol "i2copen",0x39	; TSL2572を初期化
	if stat : return 1
	wait 40
	return 0

#deffunc getlux
	devcontrol "getlux"
	rpz_lux@=0+stat
	return

#global

	i2c_stat=0
	_umsg=""

#endif

	devcontrol "i2clos