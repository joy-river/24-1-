#include <stdint.h>
#include <unistd.h>

int csd_main(int32_t s)
{

	if (s <= 8) 
		return usleep((100 * s) * 1000);
	return sleep(1);

}
