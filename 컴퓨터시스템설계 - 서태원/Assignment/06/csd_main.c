/*
 * csd_main.c
 *
 *  Created on: 2018. 4. 30.
 *      Author: Taeweon Suh
 */


unsigned volatile char * gpio_led = (unsigned char *) 0x41200000;

unsigned volatile char * switch_address = (unsigned char *) 0x41210000;

void csd_main()
{

 int count;
 int switch_value = *switch_address;

 while(switch_value == *switch_address){

	for (count=0; count < 0x400000; count++) ;
	*gpio_led = 0x3c;

	for (count=0; count < 0x400000; count++) ;
	*gpio_led = 0xc3;

 }

	return;
}
