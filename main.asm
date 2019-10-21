; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; main.asm
; Main entry point of the program (compile this file for RPi)

; Note: Program follows the Application Binary Interface standard
;		i.e. r0-r3 are volatile (modified by functions) while r4-r12 will not be altered by functions

align 4
include "constants.asm"

mov sp, $1000				; Initialise the stack pointer

mov r0, BASE_ADDRESS
bl GPIO_Setup				; Setup GPIO pins for relavent inputs and outputs

mov r0, BASE_ADDRESS
bl Graphics_Setup			; Attempt to setup the graphics functionality
teq r0, #0					; Check if we succeeded (not zero)
beq setup_error 			; Go to error state

; Draw a single green pixel on the screen
mov r0, $7E0
mov r1, #32
mov r2, #32
bl DrawPixel

main_loop:
bl main_loop

end_of_program:
b end_of_program			; Catch the end of the program

setup_error:				; Error display

mov r0, BASE_ADDRESS
mov r1, #0
bl TurnOnLED

bl setup_error

align 4
include "gpio_functions.asm"
align 4
include "graphics_functions.asm"