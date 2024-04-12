#define csd_LED_ADDR 0x41200000
#define csd_SWITCH_ADDR 0x41210000

.extern csd_main
.global main

main:
 	ldr r0, =csd_LED_ADDR		// r0에 LED의 주소를 저장합니다.
	ldr r1, =csd_SWITCH_ADDR	// r1에 스위치의 주소를 저장합니다.

Delay_loop:						// 스위치 입력을 받고, led 점등을 시작하는 반복문입니다.

	ldr r3, [r1]				// 스위치 주소에서 스위치 값을 받아옵니다.
	clz r3, r3					// 가장 높은 스위치 값을 찾기 위해 clz를 사용했습니다.
	sub r3, r3, #23				// 높은 비트 23개는 항상 0이므로 그 개수를 빼 줍니다.
 	mov r2, #1					// 첫 번째 led를 점등하기 위해 r2에 1값을 넣습니다.

LED_loop:						// led를 점등시키는 반복문입니다.
 	str r2, [r0]				// r2에 저장된 값을 led에 저장하여 led를 점등합니다.
 	stmdb sp!, {r0-r3}			// 함수 호출 전에 스택에 r0-r3 레지스터의 값을 저장합니다.

	mov r0, r3					// csd_main 함수의 매개변수로 넘겨줄 r0에 스위치의 값을 넣습니다.
 	bl csd_main					// csd_main으로 분기합니다.

 	ldmia sp!, {r0-r3}			// 딜레이 종료 후 스택에서 r0-r3 레지스터의 값을 불러옵니
 	mov r2, r2, LSL #1			// 다음 led를 점등하기 위해 LSL #1으로 r2 값을 증가시킵니다.

 	cmp r2, #128				// 만약 r2값이 128(1000_0000)을 넘어가는지 체크합니다.
	bgt Delay_loop				// r2가 128보다 크다면, 다시 Delay_loop로 돌아가 반복문을 처음부터 다시 시작합니다.

 	b LED_loop					// r2가 128보다 작다면, LED_loop로 가서 다음 led를 점등합니다.
