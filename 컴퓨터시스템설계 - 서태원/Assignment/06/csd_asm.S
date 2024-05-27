// ------------------------------------------
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          College of Informatics, Korea Univ.
//  Date:   May 06, 2020
// ------------------------------------------

#include "csd_zynq_peripherals.h"
#define csd_SWITCH_ADDR 0x41210000

.extern csd_main

.global main
main:

	ldr r0, =csd_SWITCH_ADDR
	ldr r1, =L2_reg1_ctrl
forever:

	ldr r2, [r0]
	and r2, r2, #0b1

	# 캐시에 스위치 값 저장
	str r2, [r1]
	mrc		p15, 0, r3, c1, c0, 0	@ read control register (CP15 register1)

	cmp r2, #0
	# 스위치 값이 0 인 경우 L1 캐시 비활성화
	biceq		r3, r3, #4096		    @ disable I bit (Instruction Cache)
	biceq		r3, r3, #4		        @ disable C bit (Data and Unified Caches)
	# 스위치 값이 1인 경우 L1 캐시 활성화
	orrne		r3, r3, #(1<<12)	    @ Enable I bit (Instruction Cache)
	orrne		r3, r3, #(1<<2)         @ Enable C bit (Data and Unified Caches)

	mcr		p15, 0, r3, c1, c0, 0	@ write control register (CP15 register2)


	bl  csd_main

	b forever


