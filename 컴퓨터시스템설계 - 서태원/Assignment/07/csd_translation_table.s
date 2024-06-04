
.globl  csd_MMUTable_lv2
.section .csd_mmu_tbl_lv2,"a"

csd_MMUTable_L2:
		/*
	.set PA, 0x400000
	.set PAGE, PA
	.word PAGE + 0x15de6
	.set PAGE, PA + 0x1000
	.word PAGE + 0x15de6
	.set PAGE, PA + 0x1000
	.word PAGE + 0x15de6
	*/

	.set PA, 0x400000
	.set VA, PA
	.word VA + 0x2
	.set VA, PA + 0x2000
	.word VA + 0x2
	.set VA, PA
	.word VA + 0x2

.globl  csd_MMUTable
.section .csd_mmu_tbl,"a"

csd_MMUTable:
	/* A 32-bit is required for each PTE (Page Table Entry).
	 * Each PTE covers a 1MB section.
	 * There are 4096 PTEs, so 16KB is required for the page table.
	 *
	 *  First 6 PTEs with the following translations
	 *     1st 1MB: 0x0000_0000 (VA) -> 0x0000_0000 (PA)
	 *     2nd 1MB: 0x0010_0000 (VA) -> 0x0020_0000 (PA)
	 *     3rd 1MB: 0x0020_0000 (VA) -> 0x0040_0000 (PA)
	 *     4th 1MB: 0x0030_0000 (VA) -> 0x0020_0000 (PA)
	 *     5th 1MB: 0x0040_0000 (VA) -> 0x0010_0000 (PA)
	 *     6th 1MB: 0x0050_0000 (VA) -> 0x0050_0000 (PA)
	 */
.set SECT, 0
.word	SECT + 0x15de6		/* S=b1 TEX=b101 AP=b11, Domain=b1111, C=b0, B=b1 */
.set	SECT, SECT + 0x100000
.word	SECT + 0x15de6		/* S=b1 TEX=b101 AP=b11, Domain=b1111, C=b0, B=b1 */
.word	csd_MMUTable_L2 + 0x1e1


.end
