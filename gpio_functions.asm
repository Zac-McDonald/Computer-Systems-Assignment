; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; gpio_functions.asm
; Functions for using delay, 4 GPIO LEDs and 2 GPIO inputs
; LEDs are attached to GPIO 18, 17, 27 and 22
; Buttons are attached to GPIO 23 and 24

GPIO_OFFSET = $200000
TIMER_OFFSET = $3000

GPIO_Setup:
; Function to set the GPIO settings to allow writing to LEDs
; param r0 = BASE ADDRESS
PUSH { lr }
	orr r0, GPIO_OFFSET

	; Enable write mode for GPIO 18, 17, 27 and 22
	; Write mode for GPIO 18 and 17
	mov r1, #1
	lsl r1, #21
	mov r2, #1
	lsl r2, #24
	orr r1, r2
	str r1, [r0, #4]
	; Write mode for GPIO 27 and 22
	; NOTE - no need to do any setup for the buttons as GPIO defaults to inputs
	mov r1, #1
	lsl r1, #21
	mov r2, #1
	lsl r2, #6
	orr r1, r2
	str r1, [r0, #8]
POP { pc }

Pause:
; Function to hold for a time
; params r0 = BASE ADDRESS
; params r1 = time delay (in microseconds?)
PUSH { lr }
	orr r0, TIMER_OFFSET

	; Store the time that the timer started in r3
	ldr r3, [r0, #4]
	pauseloop$:
	ldr r2, [r0, #4] 	; Get the total elapsed time in r2
	sub r2, r3 			; elapsed time - start time
	cmp r2, r1 			; if result > delay then pause is finished
	ble pauseloop$
POP { pc }

TurnOffLED:
; Turns off LED on GPIO
; params r0 = BASE ADDRESS
; params r1 = LED number [0,3]
PUSH { lr }
	orr r0, GPIO_OFFSET
	adr r2, GPIO_LED_PINS	; Get the address of the array
	ldrb r2, [r2, r1]		; Get the GPIO pin number

	mov r1, #1
	lsl r1, r2				; Set the n-th bit to high, rest low (n = pin)

	str r1, [r0, #40]		; Set GPIO # to off
POP { pc }

TurnOnLED:
; Turns off LED on GPIO
; params r0 = BASE ADDRESS
; params r1 = LED number [0,3]
PUSH { lr }
	orr r0, GPIO_OFFSET
	adr r2, GPIO_LED_PINS	; Get the address of the array
	ldrb r2, [r2, r1]		; Get the GPIO pin number

	mov r1, #1
	lsl r1, r2				; Set the n-th bit to high, rest low (n = pin)

	str r1, [r0, #28]		; Set GPIO # to on
POP { pc }

SetLED:
; Sets an LED on GPIO to the state in r2
; params r0 = BASE ADDRESS
; params r1 = LED number [0,3]
; params r2 = state (0 = off, 1 = on)
PUSH { lr }
	cmp r2, #0
	beq SetLED_SetOff		; if r2 == 0 jump to the appropriate branch

	bl TurnOnLED			; if r2 != 0 call TurnOnLED and jump to the end
	b SetLED_Finish

	SetLED_SetOff:			; Call TurnOffLED then continue to the end
	bl TurnOffLED

	SetLED_Finish:
POP { pc }

UpdateButtons:
; Updates the state arrays for buttons
; params r0 = BASE ADDRESS
; states become 0 if up and 1 if down
PUSH { lr, r4 }
	orr r0, GPIO_OFFSET
	ldr r0, [r0, #52]			; Get the GPIO states

	adr r1, GPIO_BUTTON_CURR_STATE	; Get the address of the current state array
	adr r2, GPIO_BUTTON_PREV_STATE	; Get the address of the previous state array
	ldrb r3, [r1, #0]				; Set previous state for button 0
	strb r3, [r2, #0]
	ldrb r3, [r1, #1]				; Set previous state for button 1
	strb r3, [r2, #1]

	adr r2, GPIO_BUTTON_PINS 	; Get the address of the button pins array
	; r0 = GPIO states
	; r1 = Current State array
	; r2 = GPIO pins

	; Update current state for button 0
	ldrb r3, [r2, #0]			; Get the GPIO pin number of button 0
	mov r4, #1
	lsl r4, r3					; Set the n-th bit to high, rest low (n = pin)
	tst r0, r4					; Check the n-th bit in the GPIO state
	mov r4, #0					; If the GPIO is low, we will set 0
	movne r4, #1				; If the GPIO is high, we will set 1
	strb r4, [r1, #0]			; Store state (0 or 1) in array

	; Update current state for button 1
	ldrb r3, [r2, #1]			; Get the GPIO pin number of button 1
	mov r4, #1
	lsl r4, r3					; Set the n-th bit to high, rest low (n = pin)
	tst r0, r4					; Check the n-th bit in the GPIO state
	mov r4, #0					; If the GPIO is low, we will set 0
	movne r4, #1				; If the GPIO is high, we will set 1
	strb r4, [r1, #1]			; Store state (0 or 1) in array
POP { pc, r4 }

GetButton:
; Reads the state of a button
; returns r0 = state of button (0 = up, 1 = down)
; params r0 = Button number [0,1]
PUSH { lr }
	adr r1, GPIO_BUTTON_CURR_STATE	; Get the address of the current state array
	ldrb r0, [r1, r0]				; Load the current state
POP { pc }

GetButtonDown:
; Reads if a button has changed to the down state
; returns r0 = if button pressed (0 = not pressed, 1 = pressed)
; params r0 = Button number [0,1]
PUSH { lr }
	adr r1, GPIO_BUTTON_CURR_STATE	; Get the address of the current state array
	ldrb r1, [r1, r0]				; Load the current state
	adr r2, GPIO_BUTTON_PREV_STATE	; Get the address of the previous state array
	ldrb r2, [r2, r0]				; Load the previous state

	; r0 = 1 if r1 AND !r2
	cmp r1, #0						; if r1 == 0, the statement will be false
	beq GetButtonDown_FailState
	cmp r2, #1						; if r2 == 1, the statement will be false
	beq GetButtonDown_FailState
	mov r0, #1						; if we reached here, both conditions are met, return 1
	b GetButtonDown_Finish

	GetButtonDown_FailState:
	mov r0, #0						; both conditions not met, return 0

	GetButtonDown_Finish:
POP { pc }

GetButtonUp:
; Reads if a button has changed to the up state
; returns r0 = if button released (0 = not released, 1 = released)
; params r0 = Button number [0,1]
PUSH { lr }
	adr r1, GPIO_BUTTON_CURR_STATE	; Get the address of the current state array
	ldrb r1, [r1, r0]				; Load the current state
	adr r2, GPIO_BUTTON_PREV_STATE	; Get the address of the previous state array
	ldrb r2, [r2, r0]				; Load the previous state

	; r0 = 1 if !r1 AND r2
	cmp r1, #1						; if r1 == 1, the statement will be false
	beq GetButtonUp_FailState
	cmp r2, #0						; if r2 == 0, the statement will be false
	beq GetButtonUp_FailState
	mov r0, #1						; if we reached here, both conditions are met, return 1
	b GetButtonUp_Finish

	GetButtonUp_FailState:
	mov r0, #0						; both conditions not met, return 0

	GetButtonUp_Finish:
POP { pc }

; Stores the pin numbers of the LEDs, mapped to indices 0-3
align 2
GPIO_LED_PINS:
db 18, 17, 27, 22

; Stores the pin numbers of the buttons, indices 0-1
align 2
GPIO_BUTTON_PINS:
db 23, 24

; Stores the current state of the buttons, indices 0-1
; Use to detect if a button is pressed, held or released
align 2
GPIO_BUTTON_CURR_STATE:
db 0, 0

; Stores the previous state of the buttons, indices 0-1
; Use to detect if a button is pressed, held or released
align 2
GPIO_BUTTON_PREV_STATE:
db 0, 0