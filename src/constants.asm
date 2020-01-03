; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; constants.asm
; Defines important constants for use across the entire project and sets up ARM

BASE_ADDRESS = $3F000000

SCREEN_WIDTH = 192
SCREEN_HEIGHT = 160
SCREEN_DEPTH = 16

UPDATE_RATE = $8235	;$07A120 = 500ms = 2Hz, $C350 = 50ms = 20Hz, $8235 = 30Hz, $411A = 60Hz

; Setup the ARM CPU
org $8000					; Move this code to $8000
mov sp, $8000				; Initialise the stack pointer above us

; Copied code for capturing CPU cores 1-3 in an infinite loop (removed inconsistancies)
; Return CPU ID (0..3) Of The CPU Executed On
mrc p15, 0, r0, c0, c0, 5 	; R0 = Multiprocessor Affinity Register (MPIDR)
ands r0, 3 					; R0 = CPU ID (Bits 0..1)
bne end_of_program 			; If (CPU ID != 0) Branch To Infinite Loop (Core ID 1..3)

; Copied code for enabling branch predictions? (provided speed increase)
mrc p15, 0, r0, c1, c0
mov r1, #3
orr r0, r0, r1, lsl#11      ;Set bits 11 and 12.
mcr p15, 0, r0, c1, c0      ;Update the CP15 Control registor (C1) from R0.