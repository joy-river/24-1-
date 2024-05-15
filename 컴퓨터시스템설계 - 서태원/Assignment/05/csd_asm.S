// ------------------------------------------
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          College of Informatics, Korea Univ.
//  Date:   May 06, 2020
// ------------------------------------------

#include "csd_zynq_peripherals.h"
#include "uart_init.s"
#include "uart_regs.h"

.extern csd_watch

#define	TIMER_INITIAL	 0x98967F

.align 5

csd_vector_table:
	b .
	b .
	b .
	b .
	b .
	b .
	b csd_IRQ_ISR
	b .

.global main
main:

	UART_init
	// Disable interrupt: CPSR'I = 1
	cpsID i

	cps #0x12	   	       // IRQ mode 
	ldr	r13,=irq_stack_top // Stack pointer setup for IRQ mode

	cps #0x13		          // supervisor mode
	ldr	r13,=svc_stack_top // Stack pointer setup for SVC mode

	cps #0x11		          // FIQ mode
	ldr	r13,=fiq_stack_top // Stack pointer setup for FIQ mode

	cps #0x1F	             // SYS mode 

	// Set VBAR (Vector Base Address Register) to my vector table
	ldr     r0, =csd_vector_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb
	isb

	// Enable interrupt: CPSR'I = 0
	cpsIE i

// ---------------------------
// Generic Interrupt Controller (GIC) setup - Begin
// ---------------------------

	// CPU Interface ID Register
	ldr r0, =GICC_IIDR
	ldr r3, [r0]

	// CPU Controller Type Register
	ldr r0, =GICD_TYPER
	ldr r3, [r0]

	// CPU Binary Pointer Register
	ldr r0, =GICC_BPR
	ldr r3, [r0]

	// Distributor Control Register
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	mov r2, #1       // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	 // Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29   // Enable #29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// According to specifications, 
	// Cortex-A9 supports 5-bit version of priority format [7:3] in secure world
	// ( 0 -> 8 -> 16 -> 24...)

	// Interrupt Priority Register #7
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]
	mov r2, #0x10 << 8    // Priority 16 for ID# 29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// CPU Interface Control Register
	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1        // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

 	// CPU Interface Interrupt Priority Mask Register
	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF     // Lowest
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

// ---------------------------
// Generic Interrupt Controller (GIC) setup - End
// ---------------------------


// ---------------------------
// Private Timer setup - Begin
// ---------------------------

 	// Private Timer Load Register
	ldr r0, =PRIVATE_LOAD
 	ldr r1, =TIMER_INITIAL
 	str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #32 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]

// ----------------------------
// Private Timer setup - End
// ----------------------------

forever:
	b forever

// ----------------------------
// Interrupt Service Routines (ISRs) - Begin
// ----------------------------

csd_IRQ_ISR:

	stmfd sp!, {r0-r12, lr}

 	// Interrupt Ack
  	ldr r0, =GICC_IAR
	ldr r3, [r0]


print_string:

	stmfd sp!, {r1-r3}
	bl csd_watch
	ldmfd sp!, {r1-r3}
 	// Clear Interrupt Status bit
  	ldr r0, =PRIVATE_STATUS
  	mov r1, #1
	str r1, [r0]

 	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r3, [r0]

	ldmfd sp!, {r0-r12, lr}
	subs pc, lr, #4

// ----------------------------
// Interrupt Service Routines (ISRs) - End
// ----------------------------

.data
.align 4

irq_stack:     .space 1024
irq_stack_top:
fiq_stack:     .space 1024
fiq_stack_top:
svc_stack:     .space 1024
svc_stack_top:

string:
	.ascii "00:00:00"
	.byte 0x00

led_value: .word 	0xC3
