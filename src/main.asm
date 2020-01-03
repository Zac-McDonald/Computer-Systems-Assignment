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
mov sp, $8000				; Initialise the stack pointer

; Begin copied CPU CORE CODE
; Return CPU ID (0..3) Of The CPU Executed On
mrc p15,0,r0,c0,c0,5 ; R0 = Multiprocessor Affinity Register (MPIDR)
ands r0,3 ; R0 = CPU ID (Bits 0..1)
bne end_of_program ; IF (CPU ID != 0) Branch To Infinite Loop (Core ID 1..3)
; End

mov r0, BASE_ADDRESS
bl GPIO_Setup				; Setup GPIO pins for relavent inputs and outputs

mov r0, BASE_ADDRESS
bl Graphics_Setup			; Attempt to setup the graphics functionality
teq r0, #0					; Check if we succeeded (not zero)
beq setup_error 			; Go to error state

bl Tick						; Wait a moment to make sure everything is setup

mov r0, $7E0
mov r1, #0
mov r2, #0
bl DrawPixel				; Draw a green pixel to the top left corner

mov r0, $7E0
mov r1, SCREEN_WIDTH - 1
mov r2, SCREEN_HEIGHT - 1
bl DrawPixel				; Draw a green pixel to the bottom right corner

main_loop:
	mov r0, #0
	bl GetButton
	mov r2, r0
	mov r0, BASE_ADDRESS
	mov r1, #0
	bl SetLED				; Make the first LED show the state of button 0

	mov r0, #1
	bl GetButton
	mov r2, r0
	mov r0, BASE_ADDRESS
	mov r1, #1
	bl SetLED				; Make the second LED show the state of button 1

	mov r0, #1
	bl GetButtonDown
	mov r2, r0
	mov r0, BASE_ADDRESS
	mov r1, #2
	bl SetLED				; Make the second LED show the state of button 1

	bl PlayerUpdate

	bl Tick					; Wait for a time before the next frame calculations
	mov r0, BASE_ADDRESS
	bl UpdateButtons		; Update button states before the next frame
	mov r0, BASE_ADDRESS
	bl UpdateAnimations		; Update animation counters
	bl ClearScreen			; Clear the screen before the next frame

	bl PlayerDraw
b main_loop

end_of_program:
b end_of_program			; Catch the end of the program

setup_error:				; Error display
	mov r0, BASE_ADDRESS
	mov r1, #0
	bl TurnOnLED
b setup_error

Tick:
; Function to wait for a constant tick-rate
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
align 4
include "graphics.asm"
align 4
include "player.asm"
align 4
include "animation.asm"