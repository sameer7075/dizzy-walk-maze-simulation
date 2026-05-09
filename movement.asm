; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: movement.asm

.386
.model flat,STDCALL

INCLUDE Irvine32.inc
INCLUDE movement.inc
INCLUDE constants.inc

.code

;=================================================
; MOVE UP
; Input: currentProfessor.posX
; Output: currentProfessor.posX decremented (if not at boundary)
; Purpose: Move professor up one cell toward row 0
;=================================================
MoveUp PROC
    mov al, currentProfessor.posX
    cmp al, 0
    jbe done
    dec currentProfessor.posX
done:
    ret
MoveUp ENDP

;=================================================
; MOVE DOWN
; Input: currentProfessor.posX
; Output: currentProfessor.posX incremented (if not at boundary)
; Purpose: Move professor down one cell toward row WORLD_ROWS
;=================================================
MoveDown PROC
    mov al, currentProfessor.posX
    cmp al, WORLD_ROWS-1
    jae done
    inc currentProfessor.posX
done:
    ret
MoveDown ENDP

;=================================================
; MOVE LEFT
; Input: currentProfessor.posY
; Output: currentProfessor.posY decremented (if not at boundary)
; Purpose: Move professor left one cell toward column 0
;=================================================
MoveLeft PROC
    mov al, currentProfessor.posY
    cmp al, 0
    jbe done
    dec currentProfessor.posY
done:
    ret
MoveLeft ENDP

;=================================================
; MOVE RIGHT
; Input: currentProfessor.posY
; Output: currentProfessor.posY incremented (if not at boundary)
; Purpose: Move professor right one cell toward column WORLD_COLS
;=================================================
MoveRight PROC
    mov al, currentProfessor.posY
    cmp al, WORLD_COLS-1
    jae done
    inc currentProfessor.posY
done:
    ret
MoveRight ENDP

;=================================================
; DO RANDOM MOVE
; Input: None
; Output: currentProfessor position updated with random direction
; Purpose: Generate random move in one of four cardinal directions
;=================================================
DoRandomMove PROC
    mov eax, 4
    call RandomRange

    cmp eax, 0
    je DR_Up
    cmp eax, 1
    je DR_Down
    cmp eax, 2
    je DR_Left
    cmp eax, 3
    je DR_Right
    ret

DR_Up:
    call MoveUp
    ret

DR_Down:
    call MoveDown
    ret

DR_Left:
    call MoveLeft
    ret

DR_Right:
    call MoveRight
    ret
DoRandomMove ENDP


END