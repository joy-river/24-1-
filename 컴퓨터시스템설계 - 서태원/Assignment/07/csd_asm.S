// Vector table base location should be aligned at 2^5
.align 5
// --------------------------
// Our interrupt vector table
// --------------------------
csd_vector_table:
	b .
	b .
	b .
	b csd_prefetch_abort
	b csd_data_abort
	b .
	b .
	b .

.global main
main:

	// -------------------------------------
	// Set VBAR (Vector Base Address Register) to 
	// the base location of our interrupt vector table
	// -------------------------------------
	ldr     r0, =csd_vector_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb
	isb

	/* Disable MMU, if enabled */
	mrc	p15, 0, r0, c1, c0, 0		/* read CP15 register 1 */
	bic	r0, r0, #0x1			/* clear bit 0 */
	mcr	p15, 0, r0, c1, c0, 0		/* write value back */

	/* Invalidate caches and TLBs */
	mov	r0,#0				/* r0 = 0  */
	mcr	p15, 0, r0, c8, c7, 0		/* invalidate TLBs */
	mcr	p15, 0, r0, c7, c5, 0		/* invalidate icache */
	mcr	p15, 0, r0, c7, c5, 6		/* Invalidate branch predictor array */


    /* Begin: store some words to the start of each 1MB section */
	mov r0, #0x400000
	ldr r1, =#-1024
	mov r2, #2049

mem_init:
	cmp r1, #0
	addeq r1, r1, #1

	str r1, [r0], #4
	add r1, r1, #1
	cmp r1, r2
	bne mem_init

    /* End */

	ldr	r0,=csd_MMUTable	   /* Load MMU translation table base */
	orr	r0, r0, #0x5B			/* Outer-cacheable, WB */
	mcr	15, 0, r0, c2, c0, 0		/* TTBR0 */

	// Clear PD0 in TTBCR (Translation Table Base Control Register)
	mrc p15, 0, r2, c2, c0, 2
	bic r2, r2, #(1<<4)   // Set PD0 to 0 = HW-based page table walk
	mcr p15, 0, r2, c2, c0, 2

	/* Enable MMU */
	// Set M-bit in SCTLR (System Control Register)
	mrc	p15, 0, r0, c1, c0, 0
	bic r0, r0, #(1<<12)  // I-bit = I$ disable
	bic r0, r0, #(1<<2)   // C-bit = $ disable
	orr r0, r0, #(1<<0)   // M-bit = MMU enable
	mcr	p15, 0, r0, c1, c0, 0	/* Enable MMU */
	dsb					        /* dsb	allow the MMU to start up */
	isb					        /* isb	flush prefetch buffer */

	mov r0, #0
	mov r1, #0x200000
	mov r2, #3072

va_sum:
	ldr r3, [r1], #4
	add r0, r0, r3
	subs r2, r2, #1

	bne va_sum


forever:
	nop
	b forever


csd_prefetch_abort:
	mrc p15, 0, r10, c6, c0, 2  // read IFAR to r10
	mrc p15, 0, r11, c5, c0, 1  // read IFSR to r11
	b .

csd_data_abort:
	mrc p15, 0, r10, c6, c0, 0  // read DFAR to r10
	mrc p15, 0, r11, c5, c0, 0  // read DFSR to r11
	b .
