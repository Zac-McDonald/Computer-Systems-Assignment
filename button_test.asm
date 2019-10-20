BASE = $3F000000
mov sp, $1000

mov r0, BASE
bl GPIO_Setup	; Setup LEDs for writing

mov r4, #0
main_loop:
bl Delay

mov r0, BASE
bl UpdateButtons

mov r0, #0
bl GetButton
mov r2, r0
mov r0, BASE
mov r1, #1
bl SetLED

mov r0, #0
bl GetButtonDown
mov r2, r0
mov r0, BASE
mov r1, #2
bl SetLED

mov r0, #0
bl GetButtonUp
mov r2, r0
mov r0, BASE
mov r1, #3
bl SetLED

b main_loop

end_program:
b end_program

Delay:
PUSH { lr }
	mov r0, BASE
	mov r1, $070000
	orr r1, $00A100
	orr r1, $000020
	bl Pause

	add r4, #1
	cmp r4, #2
	moveq r4, #0

	mov r0, BASE
	mov r1, #0
	mov r2, r4
	bl SetLED
POP { pc }

include "gpio_functions.asm"