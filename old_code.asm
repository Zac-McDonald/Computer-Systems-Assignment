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