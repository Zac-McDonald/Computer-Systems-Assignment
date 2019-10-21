; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; graphics_functions.asm
; Functions for using the Raspberry Pi graphics capabilities

MAILBOX_OFFSET = $B880

Graphics_Setup:
; Sets up the needed graphics functionality
; returns r0 = address of frame buffer info (or zero on failure)
; params r0 = BASE ADDRESS
PUSH { lr }
	; Send frame buffer info to mailbox
	PUSH { r0 }					; Save the BASE ADDRESS for later
	mov r1, #1					; Set mailbox number to 1
	adr r2, Frame_Buffer_Info
	add r2, $40000000			; Setup message
	bl Mailbox_Send

	; Receive the frame buffer pointer
	POP { r0 }					; Recall the BASE ADDRESS
	mov r1, #1					; Set the mailbox number to 1
	bl Mailbox_Receive

	; Check that the GPU accepted our settings
	teq r0, #0					; if 0, we succeeded
	movne r0, #0				; Set the pointer to zero
	POPne { pc }				; Return from the function early

	; Return the frame buffer address so we know we succeeded
	adr r0, Frame_Buffer_Info
POP { pc }

Mailbox_Send:
; Sends a message to the RPi mailbox
; params r0 = BASE ADDRESS
; params r1 = Mailbox number
; params r2 = Message (bottom 4 bits must be zero)
PUSH { lr }
	orr r0, MAILBOX_OFFSET and $FF
	orr r0, MAILBOX_OFFSET and $FF00

	; Wait for the mailbox status to be ready
	Mailbox_Send_Wait_For_Status:
	ldr r3, [r0, $18]			; Load current status
	tst r3, $80000000			; Check the top bit (if 0 it is ready)
	bne Mailbox_Send_Wait_For_Status

	add r1, r2					; Combine the mailbox number and message
	str r1, [r0, $20]			; Store the complete message in the mailbox write field
POP { pc }

Mailbox_Receive:
; Attempts to receive a message in a given mailbox
; returns r0 = Mailbox message contents
; params r0 = BASE ADDRESS
; params r1 = Mailbox number
PUSH { lr }
	orr r0, MAILBOX_OFFSET and $FF
	orr r0, MAILBOX_OFFSET and $FF00

	; Wait until we get mail in the correct mailbox
	Mailbox_Receive_Wait_For_Status:
	ldr r2, [r0, $18]			; Load current status
	tst r2, $40000000			; Check the 2nd-top bit (if 0 continue)
	bne Mailbox_Receive_Wait_For_Status

	ldr r2, [r0, #0]			; Read the next mailbox item
	and r3, r2, $F				; Read the mailbox number from the item
	teq r3, r1					; Check if the items mailbox matches the desired
	bne Mailbox_Receive_Wait_For_Status

	and r0, r0, $FFFFFFF0		; Read the message contents
POP { pc }

DrawPixel:
; Draws a pixel of a given colour at a given position
; params r0 = colour
; params r1 = x coordinate
; params r2 = y coordinate
PUSH { lr, r4 }
	adr r4, Screen_Width
	ldr r3, [r4, #0]			; Get the screen width
	mla r1, r2, r3, r1			; Make r1 the index = x + width * y
	lsl r1, #2					; Multiply r1 by the screen depth (bytes)

	adr r4, Frame_Buffer_Pointer
	ldr r3, [r4, #0]
	strh r0, [r3, r1]			; Write the colour to the correct location
POP { pc, r4 }

; Stores all the needed information about the frame buffer
align 16
Frame_Buffer_Info:
dd 640		; Physical Width
dd 480		; Physical Height
Screen_Width:
dd 640		; Virtual Width
Screen_Height:
dd 480		; Virtual Height
dd 0		; GPU - Pitch (number of pixels per row)
dd 16		; Bit Depth
dd 0		; X Offset
dd 0		; Y Offset
Frame_Buffer_Pointer:
dd 0		; GPU - Frame Buffer Pointer
dd 0		; GPU - Frame Buffer Size