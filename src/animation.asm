; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; animation.asm
; Contains all the logic for managing animation timings

UpdateAnimations:
; Update the animator counters for different entities.
; params r0 = BASE ADDRESS
PUSH { lr }
	bl GetTime

	mov r1, Player_Info
	ldrb r2, [r1, #6]

	lsr r0, #8
	tst r0, #1
	addne r2, #1

	strb r2, [r1, #6]
POP { pc }