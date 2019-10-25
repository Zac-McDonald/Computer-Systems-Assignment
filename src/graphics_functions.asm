; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; graphics_functions.asm
; Functions for using the Raspberry Pi graphics capabilities

MAILBOX_OFFSET = $B880

; Mailbox property interface tags
; See: https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
Allocate_Buffer       = $00040001
Set_Physical_Display  = $00048003
Set_Virtual_Buffer    = $00048004
Set_Depth             = $00048005
Set_Virtual_Offset    = $00048009
Set_Palette           = $0004800B

Graphics_Setup:
; Sets up the needed graphics functionality
; returns r0 = address of frame buffer info (or zero on failure)
; params r0 = BASE ADDRESS
PUSH { lr }
	Graphics_Setup_Retry:
	; Send frame buffer info to mailbox
	PUSH { r0 }					; Save the BASE ADDRESS for later
	mov r1, #8					; Set mailbox channel to 8
	mov r2, Frame_Buffer_Info and $FF
	orr r2, Frame_Buffer_Info and $FF00
	orr r2, Frame_Buffer_Info and $FF0000
	orr r2, Frame_Buffer_Info and $FF000000
	;add r2, $40000000			; Setup message
	bl Mailbox_Send

	; Receive the frame buffer pointer
	POP { r0 }					; Recall the BASE ADDRESS
	mov r1, #8					; Set the mailbox channel to 8
	bl Mailbox_Receive

	;; Check that the GPU accepted our settings
	;teq r0, #0					; if 0, we succeeded
	;movne r0, #0				; Set the pointer to zero
	;POPne { pc }				; Return from the function early

	ldr r0, [Frame_Buffer_Pointer]
	teq r0, #0
	beq Graphics_Setup_Retry

	; Return the frame buffer address so we know we succeeded
	and r0, $3FFFFFFF
	str r0, [Frame_Buffer_Pointer]
POP { pc }

Mailbox_Send:
; Sends a message to the RPi mailbox
; params r0 = BASE ADDRESS
; params r1 = Mailbox channel
; params r2 = Message (bottom 4 bits must be zero)
PUSH { lr }
	orr r0, MAILBOX_OFFSET and $FF
	orr r0, MAILBOX_OFFSET and $FF00

	; Wait for the mailbox status to be ready
	Mailbox_Send_Wait_For_Status:
	ldr r3, [r0, $18]			; Load current status
	tst r3, $80000000			; Check the top bit (if 0 it is ready)
	bne Mailbox_Send_Wait_For_Status

	mov r3, $20
	orr r3, r1
	orr r1, r2					; Combine the mailbox channel and message
	str r1, [r0, r3]			; Store the complete message in the mailbox write field
POP { pc }

Mailbox_Receive:
; Attempts to receive a message in a given mailbox
; returns r0 = Mailbox message contents
; params r0 = BASE ADDRESS
; params r1 = Mailbox channel
PUSH { lr }
	orr r0, MAILBOX_OFFSET and $FF
	orr r0, MAILBOX_OFFSET and $FF00

	; Wait until we get mail in the correct mailbox
	Mailbox_Receive_Wait_For_Status:
	ldr r2, [r0, $18]			; Load current status
	tst r2, $40000000			; Check the 2nd-top bit (if 0 continue)
	bne Mailbox_Receive_Wait_For_Status

	ldr r2, [r0, #0]			; Read the next mailbox item
	and r3, r2, $F				; Read the mailbox channel from the item
	teq r3, r1					; Check if the items mailbox matches the desired
	bne Mailbox_Receive_Wait_For_Status

	and r0, r0, $FFFFFFF0		; Read the message contents
POP { pc }

DrawPixel:
; Draws a pixel of a given colour at a given position
; params r0 = colour
; params r1 = x coordinate
; params r2 = y coordinate
PUSH { lr }
	mov r3, SCREEN_WIDTH		; Get the screen width
	mla r1, r2, r3, r1			; Make r1 the index = x + width * y
	lsl r1, #1					; Multiply r1 by the screen depth (bytes)

	ldr r2, [Frame_Buffer_Pointer]
	strh r0, [r2, r1]			; Write the colour to the correct location
POP { pc }

ClearScreen:
; Clears all the colours (sets to black) of the frame buffer
PUSH { lr }
	mov r0, $0000				; Colour to set (black)
	mov r1, #0					; X-coord - we will only increment this (acts as i if y = 0)

	mov r3, SCREEN_WIDTH
	mov r2, SCREEN_HEIGHT
	mul r3, r2					; Get the total number of pixels

	mov r2, #0					; Y-coord - will remain as zero

	ClearScreen_Loop:
		PUSH { r0-r3 }
		bl DrawPixel			; Draw the desired pixel
		POP { r0-r3 }

		add r1, #1				; Increment the current pixel
		cmp r1, r3 				; Check if we need to keep looping
	bne ClearScreen_Loop
POP { pc }

; Stores all the needed information about the frame buffer
align 16
Frame_Buffer_Info:
dw Frame_Buffer_Info_End - Frame_Buffer_Info 				; Size of message
dw $00000000

dw Set_Physical_Display
dw $00000008
dw $00000008
dw SCREEN_WIDTH
dw SCREEN_HEIGHT

dw Set_Virtual_Buffer
dw $00000008
dw $00000008
dw SCREEN_WIDTH
dw SCREEN_HEIGHT

dw Set_Depth
dw $00000004
dw $00000004
dw SCREEN_DEPTH

dw Set_Virtual_Offset
dw $00000008
dw $00000008

Frame_Buffer_Offset_X:
dw 0
Frame_Buffer_Offset_Y:
dw 0

dw Set_Palette
dw $00000010
dw $00000010
dw 0
dw 2
dw $00000000, $FFFFFFFF

dw Allocate_Buffer
dw $00000008
dw $00000008

Frame_Buffer_Pointer:
dw 0
dw 0

dw $00000000
Frame_Buffer_Info_End: