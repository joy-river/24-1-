#define csd_LED_ADDR 0x41200000
.extern csd_main
.global main

main:
 	ldr r0, =csd_LED_ADDR
 	mov r1, #1

LED_loop:
 	str r1, [r0]
 	stmdb sp!, {r0, r1}
 	bl csd_main

 	ldmia sp!, {r0, r1}
 	mov r1, r1, LSL #1

 	cmp r1, #128
 	movgt r1, r1, LSR #8

 	b LED_loop
