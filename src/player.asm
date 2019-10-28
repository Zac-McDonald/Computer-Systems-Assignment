; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; player.asm
; Contains all the functions and logic for the player controller and object.

PlayerUpdate:
; Updates the player information based on events this frame.
PUSH { lr, r4-r6 }
	; Read in the current button input states
	mov r0, #0
	bl GetButtonState
	mov r4, r0
	mov r0, #1
	bl GetButtonState
	mov r5, r0

	mov r0, Player_Info
	ldrb r6, [r0, #4]										; Make record of the state last frame - use it to check for change and reset frame counter

	; If both buttons just pressed and we are grounded (interact)
	PlayerUpdate_Check_Interact:
	ldrb r1, [r0, #2]										; Load grounded value
	cmp r1, #1												; Check that player is grounded
	cmpeq r4, #2											; Check right button held
	cmpeq r5, #2											; Check left button held
	bne PlayerUpdate_Check_Move_Right
	; Call interact if equal flag is set

	b PlayerUpdate_End_State_Checks

	; If one button held, run in that direction and set the facing direction
	; Check movement right
	PlayerUpdate_Check_Move_Right:
	cmp r4, #1
	cmpeq r5, #0
	bne PlayerUpdate_Check_Move_Left
	; Do move right
	mov r1, #0												; Set facing direction to 0
	strb r1, [r0, #3]
	ldrb r1, [r0, #0]										; Load the x coordinate
	ldrb r2, [r0, #5]										; Load the speed
	add r1, r2
	strb r1, [r0, #0]										; x = x + speed
	ldrb r1, [r0, #2]
	cmp r1, #1												; Check if grounded
	moveq r1, #1											; Set state to running if not jumping
	strbeq r1, [r0, #4]
	b PlayerUpdate_Check_Jump

	; Check movement left
	PlayerUpdate_Check_Move_Left:
	cmp r5, #1
	cmpeq r4, #0
	bne PlayerUpdate_Check_Jump
	; Do move left
	mov r1, #1												; Set facing direction to 0
	strb r1, [r0, #3]										
	ldrb r1, [r0, #0]										; Load the x coordinate
	ldrb r2, [r0, #5]										; Load the speed
	sub r1, r2
	strb r1, [r0, #0]										; x = x - speed
	ldrb r1, [r0, #2]
	cmp r1, #1												; Check if grounded
	moveq r1, #1											; Set state to running if not jumping
	strbeq r1, [r0, #4]
	b PlayerUpdate_Check_Jump

	; If one button held and the other is pressed, initiate jump
	PlayerUpdate_Check_Jump:
	ldrb r1, [r0, #4]										; Load the current state
	cmp r1, #1												; Check we are in the running state (1 button held)
	cmpeq r4, #2											; Check if button 0 was just pressed
	beq PlayerUpdate_Check_Jump_Success
	cmp r5, #2												; Check if button 1 was just pressed
	bne PlayerUpdate_Check_Jump_End
	PlayerUpdate_Check_Jump_Success:						; Branch here if either button was pressed
	mov r1, #0												; Set grounded to false
	strb r1, [r0, #2]
	mov r1, #2												; Set state to jumping
	strb r1, [r0, #4]

	; Check if the state has changed
	ldrb r1, [r0, #4]
	cmp r1, r6
	movne r1, #0											; If state has changed reset the frame counter
	strbne r1, [r0, #6]

	ldrb r1, [r0, #6]										; Load the frame counter
	ldrb r2, [r0, #1]										; Load the y coordinate
	cmp r1, #6												; If frame counter < 6, move up
	lslls r1, #2
	addls r2, r1, #60
	strbls r2, [r0, #1]

	; If frame counter > 6, move down

	; If frame counter > 12, set grounded
	ldrb r1, [r0, #6]
	cmp r1, #12
	movgt r1, #0												; Set grounded to true
	strbgt r1, [r0, #2]

	cmp r1, #2
	PlayerUpdate_Check_Jump_End:							; If no buttons pressed, we branch to here
	b PlayerUpdate_End_State_Checks

	PlayerUpdate_End_State_Checks:

	; If no buttons active, idle
	cmp r4, #0
	cmpeq r5, #0
	moveq r1, #0
	strbeq r1, [r0, #4]

	; Clamp the x coordinate
	ldrb r1, [r0, #0]

	cmp r1, #0												; Check if x < 0 (left side)
	movlt r1, #0

	cmp r1, SCREEN_WIDTH - 16								; Check if x > SCREEN_WIDTH - 16 (right side)
	movgt r1, SCREEN_WIDTH - 16

	strb r1, [r0, #0]										; Update the x coordinate
POP { pc, r4-r6 }

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
	ldrb r5, [r0, #6]
	mov r4, #32								; Default to the in-air sprite
	cmp r5, #2
	movls r4, #28							; If frame counter less than 2 - set pre-jump sprite
	b PlayerGetFrame_End

	PlayerGetFrame_Swing:
	cmp r1, #3								; Check swing state
	bne PlayerGetFrame_Climb
	;
	b PlayerGetFrame_End

	PlayerGetFrame_Climb:
	cmp r1, #4								; Check climb state
	bne PlayerGetFrame_End
	;

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