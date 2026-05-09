; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: game_logic.asm

.386
.model flat,STDCALL

INCLUDE Irvine32.inc
INCLUDE game_logic.inc
INCLUDE maze_data.inc
INCLUDE movement.inc
INCLUDE input.inc
INCLUDE constants.inc

.data

logTitle BYTE "============================ Adventure Log ============================",0
logProfessorLabel BYTE "Professor: ",0
logStepsLabel BYTE "Total steps: ",0
logWalletLabel BYTE "Wallet: ",0
logKeyStatusLabel BYTE "Key status: ",0
logEndReasonLabel BYTE "End reason: ",0
logKeyLostLabel BYTE "Key lost at step ",0
logKeyLostPosLabel BYTE " at (",0
logPathLabel BYTE "Path summary:",0
logPickupLabel BYTE "Pickup summary:",0
logNoPaths BYTE "None",0
logStepPrefix BYTE "Step ",0
logPickupPrefix BYTE "Pickup ",0
logTypePrefix BYTE " type=",0
logStepAtPrefix BYTE " at step ",0
logLocationPrefix BYTE " (",0
logComma BYTE ",",0
logCloseParen BYTE ")",0
logNoPickups BYTE "None",0
logKeyHas BYTE "has key",0
logKeyMissing BYTE "no key",0
logEndlessMode BYTE "Termination mode: endless",0
logFiniteMode BYTE "Termination mode: finite",0
oldLogSize DWORD 0
oldLogBuffer BYTE 65536 DUP(?)

.code 

;=================================================
; INIT MAZE
; Input: None
; Output: maze populated, currentProfessor initialized, game state reset
; Purpose: Generate maze and initialize professor position and game variables
;=================================================
InitMaze PROC
    call GenerateMaze

    mov currentProfessor.posX, WORLD_ROWS/2
    mov currentProfessor.posY, WORLD_COLS/2
    mov currentProfessor.wallet, 0
    mov currentProfessor.hasKey, 1
    mov currentProfessor.treasures, 0
    mov currentProfessor.steps, 0
    mov currentProfessor.keyLostAt_X, 255
    mov currentProfessor.keyLostAt_Y, 255
    mov currentProfessor.keyLostStep, 0FFFFFFFFh
    mov pathCount, 0
    mov pickupCount, 0
    mov gameOver, 0
    mov byte ptr endReason, 0
    mov cameraRow, 0
    mov cameraCol, 0

    cmp byte ptr currentProfessor.profName, 0
    jne IM_NameReady
    lea esi, defaultProfessorName
    lea edi, currentProfessor.profName
    call CopyString

IM_NameReady:
    mov modeChanged, 0
    call RecordPathPoint
    ret
InitMaze ENDP

;=================================================
; COPY STRING
; Input: ESI = source pointer, EDI = destination pointer
; Output: None
; Purpose: Copy null-terminated string from source to destination
;=================================================
CopyString PROC
    push eax
CS_Loop:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je CS_Done
    inc esi
    inc edi
    jmp CS_Loop
CS_Done:
    pop eax
    ret
CopyString ENDP

;=================================================
; GET MAZE CELL
; Input: EAX = row, EDX = col
; Output: AL = cell character at position (row, col)
; Purpose: Retrieve maze cell value at specified coordinates
;=================================================
GetMazeCell PROC
    push ebx
    imul eax, WORLD_COLS
    add eax, edx
    lea ebx, maze
    mov al, byte ptr [ebx + eax]
    pop ebx
    ret
GetMazeCell ENDP

;=================================================
; RECORD PATH POINT
; Input: currentProfessor.posX, currentProfessor.posY
; Output: pathX, pathY arrays updated, pathCount incremented
; Purpose: Store current professor position in path history for logging
;=================================================
RecordPathPoint PROC
    mov eax, pathCount
    cmp eax, MAX_PATH_POINTS
    jae RPP_Done

    mov esi, eax
    mov al, currentProfessor.posX
    mov pathX[esi], al
    mov al, currentProfessor.posY
    mov pathY[esi], al
    inc pathCount

RPP_Done:
    ret
RecordPathPoint ENDP

;=================================================
; RECORD PICKUP
; Input: AL = pickup type character (C, X, K, S, etc), currentProfessor position
; Output: pickupType, pickupX, pickupY, pickupStep arrays updated
; Purpose: Log pickup event with coordinates and step number
;=================================================
RecordPickup PROC
    push eax
    push ebx
    push edx

    mov dl, al
    mov eax, pickupCount
    cmp eax, MAX_PICKUPS
    jae RP_Done

    mov ebx, eax
    mov pickupType[ebx], dl
    mov al, currentProfessor.posX
    mov pickupX[ebx], al
    mov al, currentProfessor.posY
    mov pickupY[ebx], al
    mov eax, currentProfessor.steps
    inc eax
    mov pickupStep[ebx*4], eax
    inc pickupCount

RP_Done:
    pop edx
    pop ebx
    pop eax
    ret
RecordPickup ENDP

;=================================================
; UINT TO ASCII
; Input: EAX = unsigned 32-bit integer value
; Output: numberBuffer contains null-terminated decimal string
; Purpose: Convert unsigned integer to ASCII decimal string
;=================================================
UIntToAscii PROC
    push ebx
    push ecx
    push edx
    push edi

    mov edi, OFFSET numberBuffer
    mov ebx, 10
    cmp eax, 0
    jne UTA_Convert

    mov byte ptr [edi], '0'
    mov byte ptr [edi+1], 0
    jmp UTA_Done

UTA_Convert:
    xor ecx, ecx

UTA_PushLoop:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    cmp eax, 0
    jne UTA_PushLoop

    mov edi, OFFSET numberBuffer

UTA_PopLoop:
    pop edx
    mov [edi], dl
    inc edi
    loop UTA_PopLoop
    mov byte ptr [edi], 0

UTA_Done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
UIntToAscii ENDP

;=================================================
; WRITE NULL-TERMINATED STRING TO FILE
; Input: EAX = file handle, EDX = string pointer
; Output: None
; Purpose: Write null-terminated string to open file
;=================================================
WriteNullTerminatedToFile PROC
    push ecx
    xor ecx, ecx

WNTF_Loop:
    cmp byte ptr [edx+ecx], 0
    je WNTF_Write
    inc ecx
    jmp WNTF_Loop

WNTF_Write:
    call WriteToFile
    pop ecx
    ret
WriteNullTerminatedToFile ENDP

;=================================================
; WRITE NEWLINE TO FILE
; Input: EAX = file handle
; Output: None
; Purpose: Write carriage return and line feed to file
;=================================================
WriteNewlineToFile PROC
    push edx
    push ecx
    lea edx, newline
    mov ecx, 2
    call WriteToFile
    pop ecx
    pop edx
    ret
WriteNewlineToFile ENDP

;=================================================
; WRITE ADVENTURE LOG
; Input: currentProfessor, pathX/Y arrays, pickupType/X/Y/Step arrays, endReason, terminationMode
; Output: adventure_log.txt file written with game summary
; Purpose: Write complete game session log to file with stats, path, and pickups
;=================================================

WriteAdventureLog PROC uses eax ebx ecx edx esi edi
    lea edx, logFileName
    call OpenInputFile
    cmp eax, 0FFFFFFFFh
    je WAL_NoOldLog

    mov ebx, eax
    mov eax, ebx
    lea edx, oldLogBuffer
    mov ecx, SIZEOF oldLogBuffer
    call ReadFromFile
    mov oldLogSize, eax
    mov eax, ebx
    call CloseFile
    jmp WAL_CreateOut

WAL_NoOldLog:
    mov oldLogSize, 0

WAL_CreateOut:
    lea edx, logFileName
    call CreateOutputFile
    mov ebx, eax
    cmp ebx, 0FFFFFFFFh
    je WAL_Done

    ; Restore old content first so this run appends at bottom.
    mov ecx, oldLogSize
    cmp ecx, 0
    je WAL_WriteCurrent

    mov eax, ebx
    lea edx, oldLogBuffer
    call WriteToFile

WAL_WriteCurrent:



    mov eax, ebx
    lea edx, logTitle
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    mov eax, ebx
    lea edx, logProfessorLabel
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, currentProfessor.profName
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    mov eax, ebx
    lea edx, logStepsLabel
    call WriteNullTerminatedToFile
    mov eax, currentProfessor.steps
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    mov eax, ebx
    lea edx, logWalletLabel
    call WriteNullTerminatedToFile
    mov eax, currentProfessor.wallet
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    mov eax, ebx
    lea edx, logKeyStatusLabel
    call WriteNullTerminatedToFile
    cmp currentProfessor.hasKey, 1
    jne WAL_NoKey
    lea edx, logKeyHas
    jmp WAL_WriteKeyStatus

WAL_NoKey:
    lea edx, logKeyMissing

WAL_WriteKeyStatus:
    mov eax, ebx
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    mov eax, ebx
    lea edx, logEndReasonLabel
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, endReason
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    cmp currentProfessor.keyLostStep, 0FFFFFFFFh
    je WAL_NoKeyLoss

    mov eax, ebx
    lea edx, logKeyLostLabel
    call WriteNullTerminatedToFile
    mov eax, currentProfessor.keyLostStep
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logKeyLostPosLabel
    call WriteNullTerminatedToFile
    movzx eax, currentProfessor.keyLostAt_X
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logComma
    call WriteNullTerminatedToFile
    movzx eax, currentProfessor.keyLostAt_Y
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logCloseParen
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

WAL_NoKeyLoss:
    mov eax, ebx
    lea edx, logPathLabel
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    mov ecx, pathCount
    xor esi, esi
    cmp ecx, 0
    je WAL_NoPaths

WAL_PathLoop:
    cmp esi, ecx
    jae WAL_PathsDone

    mov eax, ebx
    lea edx, logStepPrefix
    call WriteNullTerminatedToFile
    mov eax, esi
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logLocationPrefix
    call WriteNullTerminatedToFile
    movzx eax, pathX[esi]
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logComma
    call WriteNullTerminatedToFile
    movzx eax, pathY[esi]
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logCloseParen
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    inc esi
    jmp WAL_PathLoop

WAL_NoPaths:
    mov eax, ebx
    lea edx, logNoPaths
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

WAL_PathsDone:
    mov eax, ebx
    lea edx, logPickupLabel
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    mov ecx, pickupCount
    xor esi, esi
    cmp ecx, 0
    je WAL_NoPickups

WAL_PickupLoop:
    cmp esi, ecx
    jae WAL_PickupsDone

    mov eax, ebx
    lea edx, logPickupPrefix
    call WriteNullTerminatedToFile
    mov eax, esi
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logTypePrefix
    call WriteNullTerminatedToFile

    mov al, pickupType[esi]
    mov byte ptr numberBuffer, al
    mov byte ptr numberBuffer+1, 0
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile

    mov eax, ebx
    lea edx, logLocationPrefix
    call WriteNullTerminatedToFile
    movzx eax, pickupX[esi]
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logComma
    call WriteNullTerminatedToFile
    movzx eax, pickupY[esi]
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logCloseParen
    call WriteNullTerminatedToFile
    mov eax, ebx
    lea edx, logStepAtPrefix
    call WriteNullTerminatedToFile
    mov eax, pickupStep[esi*4]
    call UIntToAscii
    mov eax, ebx
    lea edx, numberBuffer
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

    inc esi
    jmp WAL_PickupLoop

WAL_NoPickups:
    mov eax, ebx
    lea edx, logNoPickups
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

WAL_PickupsDone:
    cmp terminationMode, 1
    jne WAL_Endless
    mov eax, ebx
    lea edx, logFiniteMode
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile
    jmp WAL_Close

WAL_Endless:
    mov eax, ebx
    lea edx, logEndlessMode
    call WriteNullTerminatedToFile
    mov eax, ebx
    call WriteNewlineToFile

WAL_Close:
    mov eax, ebx
    call WriteNewlineToFile
    mov eax, ebx
    call CloseFile

WAL_Done:
    ret
WriteAdventureLog ENDP

;=================================================
; SET MAZE CELL
; Input: EAX = row, EDX = col, BL = value to set
; Output: None
; Purpose: Set maze cell value at specified coordinates
;=================================================
SetMazeCell PROC
    push eax
    imul eax, WORLD_COLS
    add eax, edx
    lea edx, maze
    mov byte ptr [edx + eax], bl
    pop eax
    ret
SetMazeCell ENDP

;=================================================
; RESOLVE MOVEMENT
; Input: currentProfessor position, maze state
; Output: gameOver flag, maze state, professor state modified as needed
; Purpose: Check cell at professor position and apply game rules (coins, hazards, etc)
;=================================================
ResolveMovement PROC
    push eax
    push ebx
    push edx
    push esi
    push edi
    
    movzx eax, currentProfessor.posX
    movzx edx, currentProfessor.posY
    call GetMazeCell
    
    ; AL now contains the cell character at professor's current position
    mov bl, al  ; save cell type in BL
    
    ; Check for walls/buildings/lakes - undo move
    cmp bl, '#'
    je RM_BlockedExit
    cmp bl, 'B'
    je RM_BlockedExit
    cmp bl, '~'
    je RM_BlockedExit
    
    ; Check for coin
    cmp bl, 'C'
    je RM_Coin
    
    ; Check for stumble
    cmp bl, 'S'
    je RM_Stumble
    
    ; Check for pit
    cmp bl, 'X'
    je RM_Pit
    
    ; Check for key
    cmp bl, 'K'
    je RM_Key
    
    ; Check for destination
    cmp bl, 'D'
    je RM_Destination
    
    jmp RM_Done

RM_BlockedExit:
    ; Wall/Building/Lake - restore position
    mov al, prevPosX
    mov currentProfessor.posX, al
    mov al, prevPosY
    mov currentProfessor.posY, al
    jmp RM_Done

RM_Coin:
    ; Coin pickup: wallet++, treasures++, set cell to empty
    inc currentProfessor.wallet
    inc currentProfessor.treasures
    mov al, 'C'
    call RecordPickup
    movzx eax, currentProfessor.posX
    movzx edx, currentProfessor.posY
    mov bl, '.'
    call SetMazeCell
    jmp RM_Done

RM_Stumble:
    ; 50% chance to lose key
    mov eax, 2
    call RandomRange
    cmp eax, 0
    jne RM_StumbleNoLoss
    
    ; Lost key - record location
    mov al, currentProfessor.posX
    mov currentProfessor.keyLostAt_X, al
    mov al, currentProfessor.posY
    mov currentProfessor.keyLostAt_Y, al
    mov eax, currentProfessor.steps
    inc eax
    mov currentProfessor.keyLostStep, eax
    mov currentProfessor.hasKey, 0
    
RM_StumbleNoLoss:
    ; Clear stumble cell
    movzx eax, currentProfessor.posX
    movzx edx, currentProfessor.posY
    mov bl, '.'
    call SetMazeCell
    jmp RM_Done

RM_Pit:
    ; Game over - fell into pit
    mov gameOver, 1
    lea edi, endReason
    lea esi, pitMsg
    call CopyString
    jmp RM_Done

RM_Key:
    ; Key pickup
    mov currentProfessor.hasKey, 1
    mov al, 'K'
    call RecordPickup
    movzx eax, currentProfessor.posX
    movzx edx, currentProfessor.posY
    mov bl, '.'
    call SetMazeCell
    jmp RM_Done

RM_Destination:
    ; Check if has key
    cmp currentProfessor.hasKey, 1
    je RM_DestinationWin
    
    ; No key - lost
    mov gameOver, 1
    lea edi, endReason
    lea esi, noKeyMsg
    call CopyString
    jmp RM_Done
    
RM_DestinationWin:
    ; Has key - won
    mov gameOver, 1
    lea edi, endReason
    lea esi, winMsg
    call CopyString
    jmp RM_Done

RM_Done:
    pop edi
    pop esi
    pop edx
    pop ebx
    pop eax
    ret
ResolveMovement ENDP

;=================================================
; HANDLE RANDOM MODE
; Encapsulates random move with delay polling
;=================================================

HandleRandom PROC

    mov ecx, randomDelaySec * 100       ; randomDelaySec * 100 * 10ms = ~2000ms total
HR_DelayLoop:
    call CheckModeToggle
    cmp modeChanged, 1
    je HR_ClearModeChange    ; key pressed so exit early

    mov eax, 10
    call Delay       ; wait 10ms

    loop HR_DelayLoop

    call DoRandomMove

    ret
HR_ClearModeChange:
    mov modeChanged, 0
    ret
HandleRandom ENDP

END