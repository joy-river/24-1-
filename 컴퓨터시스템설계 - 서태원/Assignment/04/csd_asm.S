
#include "uart_init.s"

.global main				// 정렬을 진행할 main을 전역으로 설정합니다

.macro debugging_macro

	str r14, [sp, #60]
	bl debug

.endm

main:						// 정렬을 실행하는 main 함수입니다.
	 UART_init     			// UART Initialization
     ldr r0, =Input_data	// r0레지스터에 입력 데이터의 주소를 불러옵니다.
     debugging_macro


     ldr r1, =Output_data	// r1레지스터에 출력 데이터의 주소를 불러옵니다.
     debugging_macro
     mov r2, #31	    // 정렬을 위한 반복횟수를 31회로 설정합니다.
     debugging_macro

Selection_sort_out_loop: 	// 선택한 정렬 알고리즘은 선택정렬(Selection sort)로 정했습니다. 따라서 이중 반복문을 사용했습니다.
	 ldr r3, [r0], #4   	// r0 주소의 Input 값을 하나 가져와 r3에 저장하고, r0를 4더한 값으로 업데이트합니다.
	 debugging_macro

	 mov r4, r0			 	// 배열 전체를 순회하고 비교하기 위해 r4에 r0를 복사합니다.
	 debugging_macro

	 mov r5, r2			 	// inner_loop 배열 순회를 반복할 횟수를 r5에 저장합니다.
	 debugging_macro

Selection_sort_inner_loop:
	 ldr r6, [r4], #4		// r3와 비교할 배열의 r4위치의 원소를 r6에 불러옵니다. 그 후 r4를 + 4를 더한 값으로 업데이트합니다.

	 cmp r3, r6				// r3와 r6를 비교하여 CPSR을 업데이트합니다.

	 strgt r3, [r4, #-4]	// 만약 r3가 더 크다면, r6를 가져왔던 메모리 주소[r4, #-4]에 r3를 저장합니다.

	 movgt r3, r6			// 만약 r3가 더 크다면, r6를 r3에 대신 저장합니다.

	 subs r5, r5, #1		// r5에 1을 뺀 값을 r5에 넣고, CPSR을 업데이트합니다.

     bne Selection_sort_inner_loop	// 만약 r5가 0이 아니라면, inner_loop를 반복합니다.
     debugging_macro
	 str r3, [r1], #4    	// 현재 순회를 반복한 배열에서 가장 작은 값인 r3를 r1 주소에 저장하고, r1을 4더한 값으로 업데이트합니다.

	 debugging_macro
	 subs r2, r2, #1		// r2에 1을 뺀 값을 r2에 넣고, CPSR을 업데이트합니다.

	 bne Selection_sort_out_loop	// 아직 r2가 0이 되지 않았다면, out_loop를 다시 반복합니다.
	 debugging_macro
	 ldr r3, [r0]			// 모든 반복이 끝나고 입력 배열의 마지막 원소, 즉 지금까지 모든 원소 중에서 가장 큰 값을 가지는 원소를 불러옵니다.
	 debugging_macro
	 str r3, [r1]			// 불러온 가장 큰 원소를 Output_data의 마지막 위치에 저장합니다.
	 debugging_macro

forever:					// 정렬이 끝나고 프로그램을 종료시키지 않게 하는 함수입니다.
	nop						// 아무 행동도 하지 않습니다.
	b forever				// forever을 계속 반복하게 만듭니다.


// debug_macro

check_empty_loop:		// Tx FIFO가 비어있는지 확인합니다.
	// ---------  Check to see if the Tx FIFO is empty ------------------------------
	ldr r2, [r0]		// read Channel Status Register
	and	r2, r2, #0x8	// read Transmit Buffer Empty bit(bit[3])
	cmp	r2, #0x8		// check if TxFIFO is empty and ready to receive new data
	bne	check_empty_loop // if TxFIFO is NOT empty, keep checking until it is empty
	//------------------------------------------------------------------------------
	mov pc, lr

debug:					// 스택에 레지스터 값을 저장하고 디버그를 시작합니다.
	stmfa sp!, {r0 - r12}
	mrs r3, cpsr
	sub r2, lr, #4
	sub r0, r13, #52
	ldr r1, [sp, #8]
	stmfa sp!, {r0 - r3}


	ldr	r1, =string
	ldr	r0, =uart_Channel_sts_reg0
	ldr r4, =uart_TX_RX_FIFO0
	mov r10, #17	    // r10 = 레지스터 출력 반복 횟수
	sub sp, sp, #64

print_strings:			// string을 출력합니다.
	bl check_empty_loop
	ldrb r3, [r1], #1
	strb r3, [r4]
	cmp r3, #0x00
	beq print_register
	bne print_strings

print_register:			// 각 레지스터 값을 출력합니다.
	sub r10, r10, #1
	cmp r10, #0
	beq print_cpsr
	blt debug_end
	ldr r3, [sp], #4
	mov r5, #8
	mov r6, #0x0f


print_hex:				// 레지스터의 값을 hex값으로 변환하여 UART로 보냅니다.
	bl check_empty_loop

	sub r5, r5, #1
	and r7, r6, r3, LSR #28
	cmp r7, #9
	addle r7, r7, #48
	addgt r7, r7, #87
	strb r7, [r4]

	mov r3, r3, LSL #4
	cmp r5, #4
	bleq print_underbar
	cmp r5, #0
	bne print_hex
	beq print_strings


print_underbar:			// 레지스터의 4바이트를 출력하고 '_'를 출력하여 보기 편하게 만듭니다.
	bl check_empty_loop
	mov r7, #0x5f
	strb r7, [r4]
	b print_hex


print_cpsr:				// cpsr의 값에 따른 출력을 만듭니다.
	ldr r3, [sp]
	mov r7, #14
	b cpsr_loop

print_sympho:			// cpsr의 구분되는 각 부분을 쉼표와 공백으로 분리시킵니다.
	bl check_empty_loop
	mov r11, #0x2c
	strb r11, [r4]
	bl check_empty_loop
	mov r11, #0x20
	strb r11, [r4]
	sub r7, r7, #1

cpsr_loop:				// cpsr 값에 따라 출력할 값을 정합니다.
	cmp r7, #14
	moveq r6, #0x6e		// n
	beq cpsr_hex
	cmp r7, #13
	moveq r6, #0x7a		// z
	beq cpsr_hex
	cmp r7, #12
	moveq r6, #0x63		// c
	beq cpsr_hex
	cmp r7, #11
	moveq r6, #0x76		// v
	beq cpsr_hex

	cmp r7, #10
	moveq r12, #0b10
	andeq r12, r12, r3, LSR #27	// r12 = j bit
	beq print_sympho

	cmp r7, #9
	lsleq r3, #20
	moveq r6, #0x69		// i
	beq cpsr_hex

	cmp r7, #8
	moveq r6, #0x66		// f
	beq cpsr_hex

	cmp r7, #7
	beq print_sympho

	cmp r7, #6
	beq select_ISA		// isa를 선택해서 출력합니다.

	cmp r7, #5
	beq print_sympho

	cmp r7, #4
	ldreq r11, =current_mode
	beq print_mode

	cmp r7, #3
	beq select_mode		// mode를 선택해서 출력합니다.

	cmp r7, #2
	ldreq r11, =bracket_open	// 괄호 열기(cpsr 값 출력)
	beq print_mode

	cmp r7, #1
	ldreq r3, [sp]
	moveq r5, #8
	moveq r6, #0x0f
	beq print_hex				// cpsr 값을 출력합니다.

cpsr_hex:						// n,z,c,v,i,f에 대해 hex값을 출력합니다.
	bl check_empty_loop
	clz r5, r3
	cmp r5, #0
	subeq r6, r6, #32
	strb r6, [r4]
	lsl r3, #1
	sub r7, r7, #1
	b cpsr_loop

print_mode:						// r11을 통해 입력된 값을 출력합니다.
	bl check_empty_loop
	ldrb r3, [r11], #1
	strb r3, [r4]
	cmp r3, #0x00
	subeq r7, r7, #1
	beq cpsr_loop
	bne print_mode

select_ISA:						// ISA를 찾아냅니다.
	lsr r3, #31		// r3 = t bit
	orr r5, r12, r3	// r5 = j, t bits

	cmp r5, #0b00
	ldreq r11, =ARM

	cmp r5, #0b01
	ldreq r11, =Thumb

	cmp r5, #0b10
	ldreq r11, =Jazelle

	cmp r5, #0b11
	ldreq r11, =ThumbEE

	b print_mode

select_mode:					// 	mode를 찾아냅니다.
	ldr r3, [sp]
	mov r12, #0b11111
	and r12, r12, r3

	cmp r12, #0b10000
	ldreq r11, =USR

	cmp r12, #0b10001
	ldreq r11, =FIQ

	cmp r12, #0b10010
	ldreq r11, =IRQ

	cmp r12, #0b10011
	ldreq r11, =SVC

	cmp r12, #0b10110
	ldreq r11, =MON

	cmp r12, #0b10111
	ldreq r11, =ABT

	cmp r12, #0b11010
	ldreq r11, =HYP

	cmp r12, #0b11011
	ldreq r11, =UND

	cmp r12, #0b11111
	ldreq r11, =SYS

	b print_mode

debug_end:						// 디버그를 끝내고 레지스터 값을 다시 스택에서 불러옵니다.
	cmp r10, #0
	beq print_strings

	ldmfa sp!, {r0 - r3}
	msr cpsr, r3
	add r2, r2, #4
	str r2, [sp, #12]
	ldmfa sp!, {r0 - r12}
	ldr lr, [sp, #60]
	ldr pc, [sp, #64]

.data
	string:
		.ascii "-----------------------------------------------------------------------------------------------------"
		.byte 0x0D
		.byte 0x0A
		.ascii "r0 = 0x"
		.byte 0x00
		.ascii "   r1 = 0x"
		.byte 0x00
		.ascii "   r2 = 0x"
		.byte 0x00
		.ascii "   r3 = 0x"
		.byte 0x00
		.byte 0x0D
		.byte 0x0A
		.ascii "r4 = 0x"
		.byte 0x00
		.ascii "   r5 = 0x"
		.byte 0x00
		.ascii "   r6 = 0x"
		.byte 0x00
		.ascii "   r7 = 0x"
		.byte 0x00
		.byte 0x0D
		.byte 0x0A
		.ascii "r8 = 0x"
		.byte 0x00
		.ascii "   r9 = 0x"
		.byte 0x00
		.ascii "   r10 = 0x"
		.byte 0x00
		.ascii "   r11 = 0x"
		.byte 0x00
		.byte 0x0D
		.byte 0x0A
		.ascii "r12 = 0x"
		.byte 0x00
		.ascii "   r13 = 0x"
		.byte 0x00
		.ascii "   r14 = 0x"
		.byte 0x00
		.ascii "   r15 = 0x"
		.byte 0x00
		.byte 0x0D
		.byte 0x0A
		.ascii "cpsr = "
		.byte 0x00
		.ascii ")"
		.byte 0x0D
		.byte 0x0A
		.ascii "-----------------------------------------------------------------------------------------------------"
		.byte 0x00

	Thumb:
		.ascii "Thumb mode"
		.byte 0x00
	ARM:
		.ascii "ARM mode"
		.byte 0x00
	Jazelle:
		.ascii "Jazaelle mode"
		.byte 0x00
	ThumbEE:
		.ascii "ThumbEE mode"
		.byte 0x00


	current_mode:
		.ascii "current mode = "
		.byte 0x00

	USR:
		.ascii "USR"
		.byte 0x00

	FIQ:
		.ascii "FIQ"
		.byte 0x00

	IRQ:
		.ascii "IRQ"
		.byte 0x00

	SVC:
		.ascii "SVC"
		.byte 0x00

	MON:
		.ascii "MON"
		.byte 0x00

	ABT:
		.ascii "ABT"
		.byte 0x00

	HYP:
		.ascii "HYP"
		.byte 0x00

	UND:
		.ascii "UND"
		.byte 0x00

	SYS:
		.ascii "SYS"
		.byte 0x00

	bracket_open:
		.ascii "(="
		.byte 0x00

	bracket_close:
		.ascii ")"
		.byte 0x00



.align 4

Input_data:
 .word 2, 0, -7, -1, 3, 8, -4, 10
 .word -9, -16, 15, 13, 1, 4, -3, 14
 .word -8, -10, -15, 6, -13, -5, 9, 12
 .word -11, -14, -6, 11, 5, 7, -2, -12

Output_data:
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0



