; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; main.asm
; Main entry point of the program (compile this file for RPi)

; Note: Program follows the Application Binary Interface standard
;		i.e. r0-r3 are volatile (modified by functions) while r4-r12 will not be altered by functions

include "constants.asm"

mov sp, $1000				; Initialise the stack pointer

mov r0, BASE_ADDRESS
bl GPIO_Setup

main_loop:



bl main_loop

end_of_program:
b end_of_program			; Catch the end of the program

include "gpio_functions.asm"