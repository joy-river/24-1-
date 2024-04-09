#define csd_LED_ADDR 0x41200000
#define csd_SWITCH_ADDR 0x41210000

.extern csd_main
.global main

main:
 	ldr r0, =csd_LED_ADDR
	ldr r1, =csd_SWITCH_ADDR

Delay_loop:
	
	ldr r3, [r1]
	clz r3, r3
	sub r3, r3, #23
 	mov r2, #1
	
LED_loop:
 	str r2, [r0]
 	stmdb sp!, {r0-r2}
	
	mov r0, r3
 	bl csd_main

 	ldmia sp!, {r0-r2}
 	mov r2, r2, LSL #1

 	cmp r2, #128
	bgt Delay_loop

 	b LED_loop
