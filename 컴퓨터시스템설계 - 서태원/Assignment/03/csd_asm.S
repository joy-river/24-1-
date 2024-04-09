#define csd_LED_ADDR 0x41200000
#define csd_SWITCH_ADDR 0x41210000
.extern csd_main
.global main

main:
 	ldr r0, =csd_LED_ADDR


Delay_loop:
 	mov r1, #1
	ldr r2, =csd_SWITCH_ADDR
	
LED_loop:
 	str r1, [r0]
 	stmdb sp!, {r0, r1}
	ldr r0, [r2]
 	bl csd_main

 	ldmia sp!, {r0, r1}
 	mov r1, r1, LSL #1

 	cmp r1, #128
	bgt Delay_loop

 	b LED_loop
