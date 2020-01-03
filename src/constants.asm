; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; constants.asm
; Defines important constants for use across the entire project

BASE_ADDRESS = $3F000000

SCREEN_WIDTH = 192
SCREEN_HEIGHT = 160
SCREEN_DEPTH = 16

UPDATE_RATE = $61A8	;$07A120 = 500ms = 2Hz, $C350 = 50ms = 20Hz