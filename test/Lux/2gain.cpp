extern void I2C_Init( void );
extern void I2C_Close( int ch );
extern void I2C_Term( void );
extern int I2C_Open( int ch, int adr );
extern int I2C_ReadByte( int ch );
extern int I2C_ReadWord( int ch );
extern int I2C_WriteByte( int ch, int value, int length );

#include <iostream>
#include <unistd.h>
#include <bitset>

using std::cout;
using std::endl;

int main(){
	int ch=1, slave=0x39;
	int lux = 0;

	I2C_Init();
	int stat = I2C_Open(ch, slave);
	if(stat != 0) std::cout << "Open error" << std::endl;

	std::cout << I2C_WriteByte(ch, 0x92, 1) << std::endl;
	int id = I2C_ReadByte(ch);
	std::cout << "id: " << id << std::endl;
	I2C_WriteByte(ch, 0x0180, 2); //stop
	usleep(30000);
	I2C_WriteByte(ch, 0x0380, 2);
	I2C_WriteByte(ch, 0xB681, 2);
	I2C_WriteByte(ch, 0x008D, 2);
	I2C_WriteByte(ch, 0x008F, 2);
	while(1){
		I2C_WriteByte(ch, 0x93, 1);
		int status = I2C_ReadByte(ch);
		if((status&0x1 == 1) && (((status&0x10)>>4) == 1)){
			I2C_WriteByte(ch, 0x0180, 2);
			break;
		}
		else usleep(1000);
	}
	I2C_WriteByte(ch, 0xA0|0x14, 1);
	for(int i=0; i<1; i++){
	usleep(50000);
	lux = I2C_ReadWord(ch);
	std::cout << std::hex << "lux1: " << lux << std::endl;
	}

	usleep(300000);
	I2C_WriteByte(ch, 0x0180, 2);
	usleep(30000);
	I2C_WriteByte(ch, 0x0380, 2);
	I2C_WriteByte(ch, 0xB681, 2);
	I2C_WriteByte(ch, 0x008D, 2);
	I2C_WriteByte(ch, 0x018F, 2);
	while(1){
		I2C_WriteByte(ch, 0x93, 1);
		int status = I2C_ReadByte(ch);
		if((status&0x1 == 1) && (((status&0x10)>>4) == 1)){
			I2C_WriteByte(ch, 0x0180, 2);
			break;
		}
		else usleep(1000);
	}
	std::cout << I2C_WriteByte(ch, 0xA0|0x14, 1) << std::endl;
	for(int i=0; i<1; i++){
	usleep(50000);
	lux = I2C_ReadWord(ch);
	std::cout << std::hex << "lux2: " << lux << std::endl;
	}
	I2C_Close(ch);
	return 0;
}