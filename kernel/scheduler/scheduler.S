#include "lib/utils.S"

.global cpu_switch_task
cpu_switch_task:
	mrs x11, spsr_el1
	mov x10, sp
	mrs x9, sp_el0
	mov x8, x0
    stp     x19, x20, [x8], #16
    stp	x21, x22, [x8], #16
	stp	x23, x24, [x8], #16
	stp	x25, x26, [x8], #16
	stp	x27, x28, [x8], #16
	stp	x29, x30, [x8], #16
	stp	x9, x10, [x8], #16
	str     x11, [x8]
	mov x8, x1
	ldp	x19, x20, [x8], #16
	ldp	x21, x22, [x8], #16
	ldp	x23, x24, [x8], #16
	ldp	x25, x26, [x8], #16
	ldp	x27, x28, [x8], #16
	ldp	x29, x30, [x8], #16
	ldp	x9, x10, [x8], #16
	ldr     x11, [x8]
	msr sp_el0, x9
	mov sp, x10
	msr spsr_el1, x11
	msr elr_el1, x30

	dsb sy
	mrs x0, sctlr_el1
	bic x0, x0, #(1 << 0)
	msr sctlr_el1, x0
	isb

	msr ttbr0_el1, x2
    tlbi vmalle1is
	dsb ish
	isb

	orr x0, x0, #(1 << 0)
    msr sctlr_el1, x0
    isb

    eret
