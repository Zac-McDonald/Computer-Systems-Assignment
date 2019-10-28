; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; animation.asm
; Contains all the logic for managing animation timings

UpdateAnimations:
; Update the animator counters for different entities.
; params r0 = BASE ADDRESS
PUSH { lr }
	bl GetTime									; Get the total elapsed time in r0

	mov r1, Player_Info							; Load the player info struct
	ldrb r2, [r1, #6]							; Load the current frame counter

	lsr r0, #8									; Shift the time to the right 8 times (approx a small amount of time, probs perfect for 1 frame)
	tst r0, #1									; Check if the right-most bit (8-th bit originally) is zero. Changes fast enough to check every frame.
	addne r2, #1								; Increment the frame counter if the bit is true

	strb r2, [r1, #6]							; Store the new frame counter
POP { pc }