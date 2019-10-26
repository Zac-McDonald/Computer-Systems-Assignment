; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; player.asm
; Contains all the functions and logic for the player controller and object.

PlayerUpdate:
; Updates the player information based on events this frame.
PUSH { lr, r4-r5 }
	; Read in the current button input states
	mov r0, #0
	bl GetButtonState
	mov r4, r0
	mov r0, #1
	bl GetButtonState
	mov r5, r0

	mov r0, Player_Info

	; If both buttons just pressed and we are grounded (interact)
	ldrb r1, [r0, #2]
	cmp r1, #0
	cmpeq r4, #2
	cmpeq r5, #2
	; Call interact if equal flag is set

	; If one button held, run in that direction and set the facing direction
	; Check movement right
	cmp r4, #1
	cmpeq r5, #0
	moveq r1, #0
	strbeq r1, [r0, #3]
	ldrbeq r1, [r0, #0]
	ldrbeq r2, [r0, #5]
	addeq r1, r2
	strbeq r1, [r0, #0]
	moveq r1, #1
	strbeq r1, [r0, #4]

	; Check movement left
	cmp r5, #1
	cmpeq r4, #0
	moveq r1, #1
	strbeq r1, [r0, #3]
	ldrbeq r1, [r0, #0]
	ldrbeq r2, [r0, #5]
	subeq r1, r2
	strbeq r1, [r0, #0]
	moveq r1, #1
	strbeq r1, [r0, #4]

	; If one button held and the other is pressed, initiate jump

	; If no buttons active, idle
	cmp r4, #0
	cmpeq r5, #0
	moveq r1, #0
	strbeq r1, [r0, #4]

	; Clamp the x coordinate
	ldrb r1, [r0, #0]

	cmp r1, #0
	movls r1, #0

	cmp r1, SCREEN_WIDTH - 16
	movgt r1, SCREEN_WIDTH - 16

	strb r1, [r0, #0]
POP { pc, r4-r5 }

PlayerDraw:
; Draws the player with the correct sprite
PUSH { lr, r4 }
	bl PlayerGetFrame						; Setup the correct sprite and face direction

	mov r0, Player_Info						; Load the player info struct
	ldrb r1, [r0, #0]						; Read the x coordinate
	ldrb r2, [r0, #1]						; Read the y coordinate
	ldrb r3, [r0, #3]						; Read the facing direction

	ldrb r4, [r0, #7]
	mov r0, Player_Sprites
	ldr r4, [r0, r4]
	mov r0, r4

	bl DrawSprite
POP { pc, r4 }

PlayerGetFrame:
; Selects the correct sprite for the character and face direction
; Values are set in the info struct
PUSH { lr, r4-r5 }
	; r0 = Player info struct
	; r1 = current state
	; r2 = animation frame counter
	; r3 = new face direction
	; r4 = new current sprite
	mov r0, Player_Info
	ldrb r1, [r0, #4]						; Load the current state
	ldrb r2, [r0, #6]						; Load the current frame counter
	ldrb r3, [r0, #3]						; Load the current face direction
	ldrb r4, [r0, #7]						; Load the current sprite

	PlayerGetFrame_Idle:
	cmp r1, #0								; Check idle state
	bne PlayerGetFrame_Run					; If not in this state, skip to the next
	mov r4, #0
	b PlayerGetFrame_End					; Can only be in one state at a time, so skip to the end

	PlayerGetFrame_Run:
	cmp r1, #1								; Check run state
	bne PlayerGetFrame_Jump
	cmp r2, #5								; There are 5 sprites in the run animation
	movge r2, #0							; Wrap to zero if the frame counter exceeds this
	mov r5, r2 								; Copy the frame counter into r5 so we can multiply it
	lsl r5, #2								; r5 = frame counter * 4 = offset from first frame
	mov r4, #4								; Set r4 (current sprite) to the first run sprite
	add r4, r5 								; Add the offset for other frames
	b PlayerGetFrame_End

	PlayerGetFrame_Jump:
	cmp r1, #2								; Check jump state
	bne PlayerGetFrame_Swing
	b PlayerGetFrame_End

	PlayerGetFrame_Swing:
	cmp r1, #3								; Check swing state
	bne PlayerGetFrame_Climb
	b PlayerGetFrame_End

	PlayerGetFrame_Climb:
	cmp r1, #4								; Check climb state
	bne PlayerGetFrame_End

	PlayerGetFrame_End:
	strb r2, [r0, #6]						; Store the current frame counter
	strb r3, [r0, #3]						; Store the current face direction
	strb r4, [r0, #7]						; Store the current sprite
POP { pc, r4-r5 }

; Stores the player information
align 4
Player_Info:
db 24					; 0: Player x coordinate
db 60					; 1: Player y coordinate
db 1					; 2: Grounded: 1 = grounded or 0 = not grounded
db 0					; 3: Face direction 0 = right, 1 = left
db 0					; 4: State: 0 = idle, 1 = run, 2 = jump, 3 = swing, 4 = climb
db 3					; 5: Speed (pixels per update)
db 0					; 6: Animator frame counter
db 0					; 7: Current Sprite

align 4
Player_Sprites:
dw Sprite_Char_Idle_0	; 0
dw Sprite_Char_Run_0	; 4
dw Sprite_Char_Run_1	; 8
dw Sprite_Char_Run_2	; 12
dw Sprite_Char_Run_3	; 16
dw Sprite_Char_Run_4	; 20
dw Sprite_Char_Climb_0	; 24
dw Sprite_Char_Jump_0	; 28
dw Sprite_Char_Jump_1	; 32
dw Sprite_Char_Swing_0	; 36