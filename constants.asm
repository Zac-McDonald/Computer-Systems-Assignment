; COS10004 - Computer Systems - Assigment 2
; Zac McDonald - 102580465
; Project: Atari 2600 style game

; constants.asm
; Defines important constants for use across the entire project

BASE_ADDRESS = $3F000000

SCREEN_WIDTH = 64
SCREEN_HEIGHT = 48
SCREEN_DEPTH = 16;24

UPDATE_RATE = $C350;$07A120