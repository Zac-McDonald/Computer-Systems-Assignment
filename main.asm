; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; main.asm
; Main entry point of the program (compile this file for RPi)

; Note: Program follows the Application Binary Interface standard
;		i.e. r0-r3 are volatile (modified by functions) while r4-r12 will not be altered by functions

align 4
include "constants.asm"

org $0000
mov sp, $1000				; Initialise the stack pointer

mov r0, BASE_ADDRESS
bl GPIO_Setup				; Setup GPIO pins for relavent inputs and outputs

mov r0, BASE_ADDRESS
bl Graphics_Setup			; Attempt to setup the graphics functionality
teq r0, #0					; Check if we succeeded (not zero)
beq setup_error 			; Go to error state

bl Tick

; Draw a single green pixel on the screen
mov r0, $7E0
mov r1, #0
mov r2, #0
bl DrawPixel

mov r0, $FE0
mov r1, #63
mov r2, #47
bl DrawPixel

mov r4, #0
mov r5, #0
main_loop:
	mov r0, BASE_ADDRESS
	bl UpdateButtons

	bl Tick
	add r4, #1
	cmp r4, #2
	moveq r4, #0

	mov r0, BASE_ADDRESS
	mov r1, #0
	mov r2, r4
	;bl SetLED

	mov r0, #0
	bl GetButton
	mov r2, r0
	mov r0, BASE_ADDRESS
	mov r1, #1
	bl SetLED

	mov r0, #0
	bl GetButtonDown
	mov r2, r0
	mov r0, BASE_ADDRESS
	mov r1, #2
	bl SetLED

	mov r0, #0
	bl GetButtonUp
	mov r2, r0
	mov r0, BASE_ADDRESS
	mov r1, #3
	bl SetLED

	mov r0, #0
	bl GetButtonDown
	cmp r0, #1
	addeq r5, #1

	mov r0, #1
	bl GetButtonDown
	cmp r0, #1
	subeq r5, #1

	mov r0, $F800
	mov r1, r5
	mov r2, #1
	bl DrawPixel
b main_loop

end_of_program:
b end_of_program			; Catch the end of the program

setup_error:				; Error display

mov r0, BASE_ADDRESS
mov r1, #0
bl TurnOnLED

bl setup_error

Tick:
PUSH { lr }
	mov r0, BASE_ADDRESS
	mov r1, UPDATE_RATE and $FF
	orr r1, UPDATE_RATE and $FF00
	orr r1, UPDATE_RATE and $FF0000
	bl Pause
POP { pc }

align 4
include "gpio_functions.asm"
align 4
include "graphics_functions.asm"