BASE = $3F000000
mov sp, $1000

mov r0, BASE
bl GPIO_Setup	; Setup LEDs for writing

bl Delay

mov r0, BASE
mov r1, #0
bl TurnOnLED

bl Delay

mov r0, BASE
mov r1, #1
bl TurnOnLED

bl Delay

mov r0, BASE
mov r1, #2
bl TurnOnLED

bl Delay

mov r0, BASE
mov r1, #3
bl TurnOnLED

bl Delay

end_program:
b end_program

Delay:
PUSH { lr }
	mov r0, BASE
	mov r1, $070000
	orr r1, $00A100
	orr r1, $000020
	bl Pause
POP { pc }

include "gpio_functions.asm"