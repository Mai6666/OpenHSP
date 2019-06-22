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
	
	std::cout << I2C_WriteByte(0, 0x01A0, 4) << std::endl;
	std::cout << I2C_WriteByte(0, 0x00AD, 4) << std::endl;
	std::cout << I2C_WriteByte(0, 0x01AF, 4) << std::endl;
	std::cout << I2C_WriteByte(0, 0xB6A1, 4) << std::endl;
	std::cout << I2C_WriteByte(0, 0x03A0, 4) << std::endl;

	for(int i=0; i<1; i++){
		I2C_WriteByte(0, 0x14+0xA0, 4);
		lux = I2C_ReadWord(0);
		//std::cout << std::bitset<32>(lux);//
		std::cout << std::hex << lux << std::endl;
		usleep(50000);
	}

	I2C_Close(0);
	return 0;
}