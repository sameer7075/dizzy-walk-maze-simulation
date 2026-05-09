; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: render.asm

.386
.model flat,STDCALL

INCLUDE Irvine32.inc
INCLUDE render.inc
INCLUDE constants.inc

darkGray EQU 8
LEGEND_COL EQU VIEW_COLS + 3

.data
hudWalletLabel BYTE "Wallet: ",0
hudStepsLabel BYTE "Steps: ",0
hudKeyLabel BYTE "Key: ",0
hudPosLabel BYTE "Position: (",0
hudCommaLabel BYTE ",",0
hudCloseParen BYTE ")",0
hudModeLabel BYTE "Mode: ",0
hudHasKey BYTE "Yes",0
hudNoKey BYTE "No",0
hudSep BYTE " | ",0
sepLine BYTE 80 DUP('='),0

legendTitle BYTE "Legend",0
legendProfessor BYTE "Professor",0
legendWall BYTE "Wall",0
legendBuilding BYTE "Building",0
legendLake BYTE "Lake",0
legendPit BYTE "Pit",0
legendCoin BYTE "Coin",0
legendKey BYTE "Key",0
legendDestination BYTE "Destination",0
legendStumble BYTE "Stumble",0
legendEmpty BYTE "Empty",0

lastColor DWORD lightGray    ; Cache for SetTextColor to avoid redundant calls

.code

;=================================================
; PRINT COLORED CELL
; Input: AL = maze character to print
; Output: None
; Purpose: Print character with color based on maze cell type
;=================================================
PrintColoredCell PROC
    push ebx
    mov bl, al

    ; Default foreground color
    mov eax, lightGray

    cmp bl, 'P'
    je PCC_Professor
    cmp bl, '~'
    je PCC_Lake
    cmp bl, '#'
    je PCC_Wall
    cmp bl, 'B'
    je PCC_Building
    cmp bl, 'X'
    je PCC_Pit
    cmp bl, 'C'
    je PCC_Coin
    cmp bl, 'K'
    je PCC_Key
    cmp bl, 'D'
    je PCC_Destination
    cmp bl, 'S'
    je PCC_Stumble
    cmp bl, '.'
    je PCC_Empty
    jmp PCC_Set

PCC_Professor:
    mov eax, yellow
    jmp PCC_Set

PCC_Lake:
    mov eax, lightBlue
    jmp PCC_Set

PCC_Wall:
    mov eax, white
    jmp PCC_Set

PCC_Building:
    mov eax, brown
    jmp PCC_Set

PCC_Pit:
    mov eax, lightRed
    jmp PCC_Set

PCC_Coin:
    mov eax, yellow
    jmp PCC_Set

PCC_Key:
    mov eax, lightCyan
    jmp PCC_Set

PCC_Destination:
    mov eax, lightGreen
    jmp PCC_Set

PCC_Stumble:
    mov eax, lightMagenta
    jmp PCC_Set

PCC_Empty:
    mov eax, darkGray

PCC_Set:
    call CachedSetTextColor
    mov al, bl
    call WriteChar

    pop ebx
    ret
PrintColoredCell ENDP

;=================================================
; CACHED SET TEXT COLOR
; Input: EAX = color value
; Output: None
; Purpose: Set console text color only if different from last call (performance optimization)
;=================================================
CachedSetTextColor PROC
    push ebx
    mov ebx, eax
    cmp eax, lastColor
    je CSC_Skip
    call SetTextColor
    mov lastColor, ebx
CSC_Skip:
    pop ebx
    ret
CachedSetTextColor ENDP

;=================================================
; DRAW HUD
; Input: None
; Output: None
; Purpose: Display heads-up display showing wallet, steps, key status, position, and mode
;=================================================
DrawHUD PROC
    ; Top separator line
    mov dl, 0
    mov dh, VIEW_ROWS + 1
    call Gotoxy
    mov eax, lightGray
    call CachedSetTextColor
    lea edx, sepLine
    call WriteString

    ; Combined HUD line
    mov dl, 0
    mov dh, VIEW_ROWS + 2
    call Gotoxy
    mov eax, lightGray
    call CachedSetTextColor

    lea edx, hudWalletLabel
    call WriteString
    mov eax, currentProfessor.wallet
    call WriteDec

    lea edx, hudSep
    call WriteString

    lea edx, hudStepsLabel
    call WriteString
    mov eax, currentProfessor.steps
    call WriteDec

    lea edx, hudSep
    call WriteString

    lea edx, hudKeyLabel
    call WriteString
    cmp currentProfessor.hasKey, 1
    je DH_HasKey2
    lea edx, hudNoKey
    call WriteString
    jmp DH_Pos2

DH_HasKey2:
    lea edx, hudHasKey
    call WriteString

DH_Pos2:
    lea edx, hudSep
    call WriteString

    lea edx, hudPosLabel
    call WriteString
    movzx eax, currentProfessor.posX
    call WriteDec
    lea edx, hudCommaLabel
    call WriteString
    movzx eax, currentProfessor.posY
    call WriteDec
    lea edx, hudCloseParen
    call WriteString

    lea edx, hudSep
    call WriteString

    lea edx, hudModeLabel
    call WriteString
    cmp gameMode, 0
    je DH_ModeRandom2
    lea edx, modeKeyboard
    call WriteString
    jmp DH_Done2

DH_ModeRandom2:
    lea edx, modeRandom
    call WriteString

DH_Done2:
    ; Bottom separator line
    mov dl, 0
    mov dh, VIEW_ROWS + 3
    call Gotoxy
    lea edx, sepLine
    call WriteString

    ret
DrawHUD ENDP

;=================================================
; DRAW LEGEND PANEL
; Input: None
; Output: None
; Purpose: Display legend panel on right side with tile type explanations
;=================================================
DrawLegend PROC
    ; Title
    mov dl, LEGEND_COL
    mov dh, 1
    call Gotoxy
    mov eax, white
    call CachedSetTextColor
    lea edx, legendTitle
    call WriteString

    ; P - Professor
    mov dl, LEGEND_COL
    mov dh, 3
    call Gotoxy
    mov al, 'P'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendProfessor
    call WriteString

    ; # - Wall
    mov dl, LEGEND_COL
    mov dh, 4
    call Gotoxy
    mov al, '#'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor 
    mov al, ' '
    call WriteChar
    lea edx, legendWall
    call WriteString

    ; B - Building
    mov dl, LEGEND_COL
    mov dh, 5
    call Gotoxy
    mov al, 'B'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendBuilding
    call WriteString

    ; ~ - Lake
    mov dl, LEGEND_COL
    mov dh, 6
    call Gotoxy
    mov al, '~'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendLake
    call WriteString

    ; X - Pit
    mov dl, LEGEND_COL
    mov dh, 7
    call Gotoxy
    mov al, 'X'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendPit
    call WriteString

    ; C - Coin
    mov dl, LEGEND_COL
    mov dh, 8
    call Gotoxy
    mov al, 'C'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendCoin
    call WriteString

    ; K - Key
    mov dl, LEGEND_COL
    mov dh, 9
    call Gotoxy
    mov al, 'K'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendKey
    call WriteString

    ; D - Destination
    mov dl, LEGEND_COL
    mov dh, 10
    call Gotoxy
    mov al, 'D'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendDestination
    call WriteString

    ; S - Stumble
    mov dl, LEGEND_COL
    mov dh, 11
    call Gotoxy
    mov al, 'S'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendStumble
    call WriteString

    ; . - Empty
    mov dl, LEGEND_COL
    mov dh, 12
    call Gotoxy
    mov al, '.'
    call PrintColoredCell
    mov eax, lightGray
    call CachedSetTextColor
    mov al, ' '
    call WriteChar
    lea edx, legendEmpty
    call WriteString

    ret
DrawLegend ENDP

;=================================================
; DISPLAY MODE HINT
; Input: None
; Output: None
; Purpose: Print current movement mode indicator
;=================================================
DisplayModeHint PROC
    lea edx, modeMsg
    call WriteString

    cmp gameMode, 0
    je ShowRandom

    lea edx, modeKeyboard
    call WriteString
    jmp DM_Done

ShowRandom:
    lea edx, modeRandom
    call WriteString

DM_Done:
    lea edx, newline
    call WriteString
    ret
DisplayModeHint ENDP

;=================================================
; UPDATE CAMERA
; Input: currentProfessor.posX, currentProfessor.posY
; Output: cameraRow, cameraCol updated to keep professor in view
; Purpose: Update camera position to follow professor within scroll margin
;=================================================
UpdateCamera PROC
    push eax
    push ebx

    ; Row camera
    movzx eax, currentProfessor.posX
    mov ebx, cameraRow
    add ebx, SCROLL_MARGIN
    cmp eax, ebx
    jbe UC_SetTopRow

    mov ebx, cameraRow
    add ebx, VIEW_ROWS - SCROLL_MARGIN - 1
    cmp eax, ebx
    jae UC_SetBottomRow
    jmp UC_ClampRow

UC_SetTopRow:
    cmp eax, SCROLL_MARGIN
    jbe UC_RowZero
    mov ebx, eax
    sub ebx, SCROLL_MARGIN
    mov cameraRow, ebx
    jmp UC_ClampCol

UC_RowZero:
    mov cameraRow, 0
    jmp UC_ClampCol

UC_SetBottomRow:
    mov ebx, eax
    sub ebx, VIEW_ROWS - SCROLL_MARGIN - 1
    mov cameraRow, ebx

UC_ClampRow:
    mov ebx, WORLD_ROWS - VIEW_ROWS
    cmp cameraRow, ebx
    jbe UC_ClampCol
    mov cameraRow, ebx

UC_ClampCol:
    movzx eax, currentProfessor.posY
    mov ebx, cameraCol
    add ebx, SCROLL_MARGIN
    cmp eax, ebx
    jbe UC_SetLeftCol

    mov ebx, cameraCol
    add ebx, VIEW_COLS - SCROLL_MARGIN - 1
    cmp eax, ebx
    jae UC_SetRightCol
    jmp UC_ClampDone

UC_SetLeftCol:
    cmp eax, SCROLL_MARGIN
    jbe UC_ColZero
    mov ebx, eax
    sub ebx, SCROLL_MARGIN
    mov cameraCol, ebx
    jmp UC_ClampDone

UC_ColZero:
    mov cameraCol, 0
    jmp UC_ClampDone

UC_SetRightCol:
    mov ebx, eax
    sub ebx, VIEW_COLS - SCROLL_MARGIN - 1
    mov cameraCol, ebx

UC_ClampDone:
    mov ebx, WORLD_COLS - VIEW_COLS
    cmp cameraCol, ebx
    jbe UC_Done
    mov cameraCol, ebx

UC_Done:
    pop ebx
    pop eax
    ret
UpdateCamera ENDP

;=================================================
; DRAW MAZE
; Input: None
; Output: None
; Purpose: Clear screen, redraw visible maze, HUD, and legend each frame
;=================================================
DrawMaze PROC

    call UpdateCamera
    call Clrscr

    mov ecx, VIEW_ROWS
    xor esi, esi        ; visible row

RowLoop:

    push ecx
    mov ecx, VIEW_COLS
    xor edi, edi        ; visible col

ColLoop:

    mov eax, cameraRow
    add eax, esi
    mov edx, cameraCol
    add edx, edi

    ; if (world row/col matches professor, print P)
    movzx ebx, currentProfessor.posX
    cmp eax, ebx
    jne NotProf

    movzx ebx, currentProfessor.posY
    cmp edx, ebx
    jne NotProf

    mov al, 'P'
    call PrintColoredCell
    jmp NextCell

NotProf:
    call GetMazeCell
    call PrintColoredCell

NextCell:
    inc edi
    loop ColLoop

    call Crlf
    inc esi
    pop ecx
    loop RowLoop

    call DrawHUD
    call DrawLegend

    mov eax, lightGray
    call CachedSetTextColor

    ret
DrawMaze ENDP

END
