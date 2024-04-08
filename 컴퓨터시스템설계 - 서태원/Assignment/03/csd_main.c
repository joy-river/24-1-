#define csd_LED_ADDR 0x41200000
#define csd_SWITCH_ADDR 0x41210000

#include <stdint.h>
#include <unistd.h>

int csd_main()
{
	int32_t *s = (int32_t *)csd_SWITCH_ADDR;
	int8_t test = 128;

	for(int i = 0; i < 8; i++){
		if (*s & (test >> i))
			return usleep((100 + 100 * i) * 1000);
	}

	return sleep(1);

}

