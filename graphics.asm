; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; graphics.asm
; Contains all the graphics structures used in the game

; Sprites are of a fixed size, drawn from the top left corner. Each sprite can use 3 colours from a set palette (based on the PICO-8 palette). This means that each pixel is represented by 2 bits: 0 being no colour, and 1-3 being the chosed colours. The colours are chosen at the start of the sprite definition. There are 16 possible colours, so 3 nibbles are needed to represent the 3 chosen colours

SPRITE_WIDTH = 16		; Changing these won't do anything (because that would be much harder to implement), they're more for referencec
SPRITE_HEIGHT = 24

DrawSprite:
; Draws a sprite given its address and x/y coordinates (top left)
; params r0 = sprite address (i.e. adr r0, Sprite_Char_Idle_0)
; params r1 = x coordinate
; params r2 = y coordinate
PUSH { lr, r4-r9 }
	; Load the sprites colours into our CURRENT_SPRITE_COLOURS array
	ldrh r3, [r0, #0]
	adr r4, CURRENT_SPRITE_COLOURS 		; Get the current colours palette
	adr r5, PALETTE 					; Get the palette array address

	mov r6, $0F00 						; Get the first colour index only
	and r6, r6, r3
	lsr r6, #7							; Shift the index so it represents the number properly, move 1 less so it is double (2 bytes per colour)
	ldrh r6, [r5, r6]					; Load the colour from the palette
	strh r6, [r4, #0]					; Store the colour in the CURRENT_SPRITE_COLOURS array

	mov r6, $00F0 						; Get the second colour index only
	and r6, r6, r3
	lsr r6, #3							; Shift the index so it represents the number properly, move 1 less so it is double (2 bytes per colour)
	ldrh r6, [r5, r6]					; Load the colour from the palette
	strh r6, [r4, #2]					; Store the colour in the CURRENT_SPRITE_COLOURS array

	mov r6, $000F 						; Get the third colour index only
	and r6, r6, r3
	lsl r6, #1							; Double the index (2 bytes per colour)
	ldrh r6, [r5, r6]					; Load the colour from the palette
	strh r6, [r4, #4]					; Store the colour in the CURRENT_SPRITE_COLOURS array

	; Draw each pixel with the correct colour
	; r0 = sprite address
	; r1 = x coordinate
	; r2 = y coordinate
	; r3 = current sprite row
	; r4 = CURRENT_SPRITE_COLOURS array
	; r5 = counter (0-24 for rows, 0-16 for each pixel)

	mov r5, #0				; Initialise the row index
	DrawSprite_DrawRow:
	mov r6, r5				; Get the current row index
	lsl r6, #2				; Multiply by 4 (each row is 4 bytes long)
	add r6, #4				; Skip the 2 bytes defining colours
	ldr r3, [r0, r6]		; Read in the associated row
	PUSH { r5 }
		mov r5, #0						; Initialise the pixel index
		DrawSprite_DrawPixel:
			mov r6, $C0000000				; Setup the mask to extract single pixel information (2 bits)
			mov r7, r5						; Get the current index
			lsl r7, #1						; Multiply the index by 2 (bits per pixel) so it equals the number of bits we need to shift the mask
			lsr r6, r7						; Shift the mask

			and r6, r6, r3					; Read the pixel information, r6 now contains the offset pixel info
			mov r8, #30						; We need to shift by 30 - (index * 2) to get the number properly
			sub r8, r7						; 30 - (index * 2)
			lsr r6, r8						; Shift it, r6 now contains the pixel info (not offset)

			cmp r6, #0						; If the colour is zero - nothing to draw
			beq DrawSprite_DrawPixel_End
			sub r6, #1						; Otherwise subtract 1 to get the proper colour index
			lsl r6, #1						; x2 because 2 bytes per colour

			POP { r7 }						; Recall the y coordinate into r7
			PUSH { r7 }

			PUSH { r0-r3 }
			ldrh r0, [r4, r6]				; Load the correct colour into r0
			add r1, r5						; Get the x coordinate
			add r2, r7						; Get the y coordinate
			bl DrawPixel
			POP { r0-r3 }
		DrawSprite_DrawPixel_End:
		add r5, #1
		cmp r5, #16
		bne DrawSprite_DrawPixel
	POP { r5 }
	add r5, #1
	cmp r5, #24
	bne DrawSprite_DrawRow
POP { pc, r4-r9 }

; Stores the possible colours we can use indexed 0-15. They are based on the PICO-8 palette
align 4
PALETTE:
dh $0000, $290A, $792A, $042A, $AA86, $5AA9, $C618, $FF9D, $F809, $FD00, $FF64, $0726, $2D7F, $83B3, $FBB5, $FE75

; Stores the current sprites colours
align 4
CURRENT_SPRITE_COLOURS:
dh $0000, $0000, $0000

align 4
Sprite_Char_Idle_0:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000		; Each row defined where every 2 bit pair defines a single pixels colour
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA000
dw $000AA0A0
dw $000AAAA0
dw $000AAA00
dw $000AA000
dw $000AA000
dw $000FF000
dw $000FF000
dw $000FF000
dw $000FF000
dw $000FF000
dw $000FF000
dw $000FF000
dw $000FFF00
dw $000F0000
dw $000FF000
dw $00000000

align 4
Sprite_Char_Run_0:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $00000000
dw $00000000
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA0A0
dw $00AAAAA0
dw $0AAAAA00
dw $0A0AA000
dw $0A0AA000
dw $000AA000
dw $000FFF00
dw $000FFFF0
dw $FF0FF0F0
dw $0FFF00F0
dw $00FF00FF
dw $00000000
dw $00000000
dw $00000000

align 4
Sprite_Char_Run_1:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA000
dw $00AAA000
dw $00AAA0A0
dw $00AAAAA0
dw $00AAAA00
dw $000AA000
dw $000FF000
dw $000FF000
dw $000FF000
dw $000FFF00
dw $000F0F00
dw $0FFF0F00
dw $0F000F00
dw $0F0000FF
dw $000000F0
dw $00000000

align 4
Sprite_Char_Run_2:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AAA00
dw $000AAA00
dw $000FF000
dw $000FF000
dw $000FF000
dw $0000FFF0
dw $0000F0F0
dw $00FFFFF0
dw $00F0F000
dw $00F0F000
dw $0000F000
dw $0000FF00
dw $00000000

align 4
Sprite_Char_Run_3:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AAA00
dw $000AAA00
dw $000AA000
dw $000FF000
dw $000FFF00
dw $000FFF00
dw $000F0FF0
dw $00FF00F0
dw $00FF0F00
dw $00F00F00
dw $00F000F0
dw $00F00000
dw $000F0000
dw $00000000

align 4
Sprite_Char_Run_4:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA000
dw $00AAA000
dw $00AAA0A0
dw $00AAAAA0
dw $00AAAA00
dw $000AA000
dw $000FF000
dw $000FFF00
dw $000FFF00
dw $00FF0FF0
dw $0FF000F0
dw $0FF000F0
dw $FF0000FF
dw $F0000000
dw $F0000000
dw $00000000

align 4
Sprite_Char_Climb_0:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $00FF0000
dw $00550000
dw $00550000
dw $00140500
dw $00AA0A00
dw $00AAAA00
dw $0AAAA000
dw $0AAA0000
dw $0AAA0000
dw $00AA0000
dw $00FFF000
dw $00FFFF00
dw $00F0FF00
dw $00F00F00
dw $00F0FF00
dw $00F0F000
dw $00F0F000
dw $00F0FF00
dw $00F00000
dw $00F00000
dw $00F00000
dw $0FF00000

align 4
Sprite_Char_Jump_0:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AA000
dw $000AAA00
dw $000AAA00
dw $000FF000
dw $000FF000
dw $000FF000
dw $0000FFF0
dw $0000F0F0
dw $00FFFFF0
dw $00F0F000
dw $00F0F000
dw $0000F000
dw $0000FF00
dw $00000000

align 4
Sprite_Char_Jump_1:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $00000000
dw $00000000
dw $00000000
dw $000FF000
dw $00055000
dw $00055000
dw $00050000
dw $000AA000
dw $000AA0A0
dw $00AAAAA0
dw $0AAAAA00
dw $0A0AA000
dw $0A0AA000
dw $000AA000
dw $000FFF00
dw $000FFFF0
dw $FF0FF0F0
dw $0FFF00F0
dw $00FF00FF
dw $00000000
dw $00000000
dw $00000000

align 4
Sprite_Char_Swing_0:
dw $0EB3			; Colour choices 14, 11 and 3
dw $00000000
dw $00000000
dw $00000000
dw $00000000
dw $00000000
dw $FF000000
dw $55050000
dw $55050000
dw $50050000
dw $AA0A0000
dw $AAAA0000
dw $AA000000
dw $AA000000
dw $AA000000
dw $AA000000
dw $AA000000
dw $FF0FFF00
dw $FFFF0FF0
dw $FFFF00F0
dw $0FF000FF
dw $00000000
dw $00000000
dw $00000000
dw $00000000