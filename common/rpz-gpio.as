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

#deffunc init_lux int _ch
	devcontrol "i2copen",0x39,_ch	; TSL2572を初期化
	if stat : return 1
	wait 40
	return
	
#defcfunc max var _p1, var _p2
	if _p1 > _p2 : return _p1 : else : return _p2
	return 0

#deffunc set int _p1, int _p2, int _ch
	if(_p1 == 0){
		devcontrol "i2cwrite",0x048D, 2, _ch
		devcontrol "i2cwrite",0x008F, 2, _ch
	}else : if (_p1 == 1){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x008F, 2, _ch
	}else : if (_p1 == 2){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x018F, 2, _ch
	}else : if (_p1 == 3){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x028F, 2, _ch
	}else : if (_p1 == 4){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x038F, 2, _ch
	}
	
	devcontrol "i2cwrite",(_p2<<8)|0x0081, 2, _ch // set time
	return
	

#deffunc integration int _again, int _atime, int _ch, array data
	devcontrol "i2cwrite",0x0180,2, _ch
	if stat : return 1
	set _again, _atime, _ch
	devcontrol "i2cwrite",0x0380,2, _ch
	if stat : return 1
	wait 40
	repeat
		devcontrol "i2cwrite",0x93, 1, _ch
		devcontrol "i2cread", _ch
		status=0+stat
		if( (status&0x1 == 1) && ((status&0x10)>>4)==1){
			devcontrol "i2cwrite",0x0180,2,_ch
			break
			}
		else : wait 100
	loop
	devcontrol "i2cwrite",0x14|0xA0,1, _ch
	devcontrol "i2creadw", _ch	
	data(0) = stat
	devcontrol "i2cwrite",0x16|0x80,1, _ch
	devcontrol "i2creadw", _ch
	data(1) = stat

	return 

#defcfunc calc_lux int _again, int _atime, int _ch0, int _ch1
	if(_again == 0){ g = 0.16 }
	else : if (_again == 1){ g = 1.0 }
	else : if (_again == 2){ g = 8.0 }
	else : if (_again == 3){ g = 16.0 }
	else : if (_again == 4){ g = 120.0 }
	
	if(_atime == 0xED){ t = 50.0 }
	else : if(_atime == 0xB6){ t = 200.0 }
	else : if(_atime == 0x24){ t = 600.0 }
	
	cpl = (t*g)/60.0

	lux1 = (double(_ch0) - 1.87*double(_ch1)) / cpl
	lux2 = (0.63*double(_ch0) - double(_ch1)) / cpl
	return max(lux1, lux2)
	
#defcfunc cget_lux int ch
	again = 1
	atime = 0xB6
	
	integration again,atime,ch, data

	ch0 = data(0)
	ch1 = data(1)

	if(max(ch0,ch1) == 65535){
		again = 0
		atime = 0xED
		integration again,atime,ch, data
	} else : if(max(ch0,ch1) < 100){
		again = 4
		atime = 0x24
		integration again,atime,ch, data
	} else : if(max(ch0,ch1) < 300){
		again = 4
		atime = 0xB6
		integration again,atime,ch, data
	} else : if(max(ch0,ch1) < 3000){
		again = 2
		atime = 0xB6
		integration again,atime,ch, data
	}

	devcontrol "i2cwrite",0x0180,2,ch
	
	ch0 = data(0)
	ch1 = data(1)

	lux = calc_lux(again, atime, ch0, ch1)

	return lux

#defcfunc get_lux int ch
	again = 2
	atime = 0xB6

	integration again,atime,ch, data

	ch0 = data(0)
	ch1 = data(1)

	return ch0

#global

	i2c_stat=0
	_umsg=""

#endif
