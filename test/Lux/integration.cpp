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
	int lux=5;

	I2C_Init();
	int stat = I2C_Open(0,0x39);
	if(stat != 0) std::cout << "Open error" << std::endl;
	
	std::cout << I2C_WriteByte(0, 0x0180, 2) << std::endl;
	std::cout << I2C_WriteByte(0, 0x008D, 2) << std::endl;
	std::cout << I2C_WriteByte(0, 0x028F, 2) << std::endl;
	std::cout << I2C_WriteByte(0, 0xB681, 2) << std::endl;
	std::cout << I2C_WriteByte(0, 0x0380, 2) << std::endl;
	while(1){
		I2C_WriteByte(0, 0x93, 1);
		int status = I2C_ReadByte(0);
		if((status&0x1 == 1) && (((status&0x10)>>4) == 1)){
			I2C_WriteByte(0, 0x0180, 2);
			break;
		}
		else usleep(1000);
	}
	I2C_WriteByte(0, 0x14|0xA0, 1); 
	for(int i=0; i<1; i++){
		lux = I2C_ReadWord(0);
		std::cout << std::hex << lux << std::endl;
		usleep(50000);
	}

	I2C_Close(0);
	return 0;
}