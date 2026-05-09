; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: input.asm

.386
.model flat,STDCALL

INCLUDE Irvine32.inc
INCLUDE input.inc
INCLUDE movement.inc
INCLUDE constants.inc

.code

;=================================================
; HANDLE KEYBOARD INPUT
; Input: None
; Output: currentProfessor position updated or gameMode toggled
; Purpose: Read keyboard input and execute corresponding movement or mode toggle
;=================================================
HandleKeyboardInput PROC
    call ReadChar       ; wait for key, AL = key

    cmp al, 'w'
    je HK_Up
    cmp al, 'W'
    je HK_Up

    cmp al, 's'
    je HK_Down
    cmp al, 'S'
    je HK_Down

    cmp al, 'a'
    je HK_Left
    cmp al, 'A'
    je HK_Left

    cmp al, 'd'
    je HK_Right
    cmp al, 'D'
    je HK_Right

    cmp al, 'm'
    je HK_Toggle
    cmp al, 'M'
    je HK_Toggle

    cmp al, 27          ; ESC to quit
    je HK_Quit

    jmp HK_Done

HK_Up:
    call MoveUp
    jmp HK_Done

HK_Down:
    call MoveDown
    jmp HK_Done

HK_Left:
    call MoveLeft
    jmp HK_Done

HK_Right:
    call MoveRight
    jmp HK_Done

HK_Toggle:
    mov al, gameMode
    xor al, 1
    mov gameMode, al
    mov modeChanged, 1
    jmp HK_Done

HK_Quit:
    call ExitProcess

HK_Done:
    ret
HandleKeyboardInput ENDP



;=================================================
; CHECK MODE TOGGLE
; Input: None
; Output: gameMode toggled if M pressed, modeChanged flag set
; Purpose: Poll for M key in random mode without blocking and toggle movement mode
;=================================================
CheckModeToggle PROC
    call ReadKey
    jz CMT_Done

    cmp al, 'm'
    je CMT_Toggle
    cmp al, 'M'
    je CMT_Toggle
    jmp CMT_Done

CMT_Toggle:
    mov al, gameMode
    xor al, 1
    mov gameMode, al
    mov modeChanged, 1

CMT_Done:
    ret
CheckModeToggle ENDP


END