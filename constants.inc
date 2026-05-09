; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: constants.inc

;==================== CONSTANTS & EXTERN DECLARATIONS =======================

WORLD_ROWS EQU 100
WORLD_COLS EQU 150
VIEW_ROWS EQU 25
VIEW_COLS EQU 60
SCROLL_MARGIN EQU 5
randomDelaySec EQU 2    ; delay between each successive Random move in seconds
MAX_PATH_POINTS EQU 4096
MAX_PICKUPS EQU 128

; Extern declarations - these are defined in main.asm
PROFESSOR STRUCT
    profName BYTE 32 DUP(?)
    posX BYTE ?
    posY BYTE ?
    wallet DWORD ?
    hasKey BYTE ?
    keyLostAt_X BYTE ?
    keyLostAt_Y BYTE ?
    keyLostStep DWORD ?
    treasures DWORD ?
    steps DWORD ?
PROFESSOR ENDS

EXTERN currentProfessor:PROFESSOR
EXTERN maze:BYTE
EXTERN cameraRow:DWORD
EXTERN cameraCol:DWORD
EXTERN pathX:BYTE
EXTERN pathY:BYTE
EXTERN pathCount:DWORD
EXTERN pickupType:BYTE
EXTERN pickupX:BYTE
EXTERN pickupY:BYTE
EXTERN pickupStep:DWORD
EXTERN pickupCount:DWORD
EXTERN logFileName:BYTE
EXTERN numberBuffer:BYTE
EXTERN defaultProfessorName:BYTE
EXTERN gameOver:BYTE
EXTERN endReason:BYTE
EXTERN terminationMode:BYTE
EXTERN gameMode:BYTE
EXTERN modeChanged:BYTE
EXTERN modeMsg:BYTE
EXTERN modeRandom:BYTE
EXTERN modeKeyboard:BYTE
EXTERN newline:BYTE


EXTERN prevPosX:BYTE
EXTERN prevPosY:BYTE
EXTERN pitMsg:BYTE
EXTERN noKeyMsg:BYTE
EXTERN winMsg:BYTE
EXTERN termPrompt:BYTE
EXTERN stepLimitPrompt:BYTE
EXTERN termEndlessMsg:BYTE
EXTERN termFiniteMsg:BYTE
EXTERN stepLimitReachedMsg:BYTE

