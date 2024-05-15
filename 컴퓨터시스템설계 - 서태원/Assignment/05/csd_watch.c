#include "uart_regs.h"
#include <stdint.h>
#include <stdio.h>


static int hour = 0;
static int min = 0;
static int sec = -1;

void csd_watch(){

	int32_t *uart_fifo = uart_TX_RX_FIFO0;

	if(++sec == 60){
		sec = 0;
		if(++min == 60){
			min = 0;
			if(++hour == 24)
				hour = 0;
		}
	}

	char str[10];
	sprintf(str, "%02d:%02d:%02d\n\r", hour, min, sec);

	const char *time = &str[0];



	while (*time)
			*uart_fifo = *time++;

	return;

}


