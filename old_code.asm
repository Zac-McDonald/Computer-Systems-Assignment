; Does all the logic for checking a button, but only checks 1 button. Depreciated because it made more sense to use an update method (called every update tick) to allow for the desired pressed, held, released detection. Also allows button checks to only require 1 input (button number)
GetButton:
; Reads the state of a button
; returns r0 = state of button (0 = up, 1 = down)
; params r0 = BASE ADDRESS
; params r1 = Button number [0,1]
PUSH { lr }
	orr r0, GPIO_OFFSET
	adr r2, GPIO_BUTTON_PINS	; Get the address of the array
	ldrb r2, [r2, r1]			; Get the GPIO pin number

	mov r1, #1
	lsl r1, r2					; Set the n-th bit to high, rest low (n = pin)

	ldr r0, [r0, #52]			; Get the GPIO states
	tst r0, r1					; Check the n-th bit in the current state
	mov r0, #0					; If the GPIO is low, we will return 0
	movne r0, #1				; If the GPIO is high, we will return 1
POP { pc }

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

Graphics_Setup:
; Sets up the needed graphics functionality
; returns r0 = address of frame buffer info (or zero on failure)
; params r0 = BASE ADDRESS
PUSH { lr }
	; Send frame buffer info to mailbox
	PUSH { r0 }					; Save the BASE ADDRESS for later
	mov r1, #8					; Set mailbox channel to 8
	adr r2, Frame_Buffer_Info
	;add r2, $40000000			; Setup message
	bl Mailbox_Send

	; Receive the frame buffer pointer
	POP { r0 }					; Recall the BASE ADDRESS
	mov r1, #8					; Set the mailbox channel to 8
	bl Mailbox_Receive

	; Check that the GPU accepted our settings
	teq r0, #0					; if 0, we succeeded
	movne r0, #0				; Set the pointer to zero
	POPne { pc }				; Return from the function early

	; Return the frame buffer address so we know we succeeded
	adr r0, Frame_Buffer_Info
POP { pc }