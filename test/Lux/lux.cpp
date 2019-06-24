extern void I2C_Init( void );
extern void I2C_Close( int ch );
extern void I2C_Term( void );
extern int I2C_Open( int ch, int adr );
extern int I2C_ReadByte( int ch );
extern int I2C_ReadWord( int ch );
extern int I2C_WriteByte( int ch, int value, int length );
int get_lux(void);

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

	for(int i=0; i<1; i++){
		lux = get_lux();
		std::cout << lux << std::endl;
		usleep(50000);
	}

	I2C_Close(0);
	return 0;
}