#include <stdint.h>
#include <unistd.h>

int csd_main(int32_t s)					// csd_main은 r0 레지스터에 저장된 가장 높은 스위치 값을 s로 받습니다.
{

	if (s <= 8)							// 가장 높은 스위치 값에 따라 딜레이를 결정합니다.
		return usleep((100 * s) * 1000);// usleep의 단위가 마이크로초이므로 ((100 * s) * 1000)msec만큼 딜레이를 가집니다.
	return sleep(1);					// 만약 어떤 스위치도 켜지지 않았다면, 1초의 딜레이를 가집니다.

}
