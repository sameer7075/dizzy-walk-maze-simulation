; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: main.asm

.386
.model flat,STDCALL
.stack 4096

INCLUDE GraphWin.inc
INCLUDE Irvine32.inc

;=================================================
; LOCAL MAIN CONSTANTS / STRUCT
;=================================================

WORLD_ROWS EQU 100
WORLD_COLS EQU 150
VIEW_ROWS EQU 25
VIEW_COLS EQU 60
SCROLL_MARGIN EQU 5
MAX_PATH_POINTS EQU 4096
MAX_PICKUPS EQU 128

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



;=================================================
; DATA SECTION 
;=================================================

.data
INCLUDE maze_data.inc

maze BYTE WORLD_ROWS*WORLD_COLS DUP(?)
cameraRow DWORD 0
cameraCol DWORD 0

currentProfessor PROFESSOR <>

; Record keeping
MAX_PATH_POINTS EQU 4096
MAX_PICKUPS EQU 128

pathX BYTE MAX_PATH_POINTS DUP(?)
pathY BYTE MAX_PATH_POINTS DUP(?)
pathCount DWORD 0

pickupType BYTE MAX_PICKUPS DUP(?)
pickupX BYTE MAX_PICKUPS DUP(?)
pickupY BYTE MAX_PICKUPS DUP(?)
pickupStep DWORD MAX_PICKUPS DUP(?)
pickupCount DWORD 0

logFileName BYTE "adventure_log.txt",0
numberBuffer BYTE 16 DUP(0)
defaultProfessorName BYTE "Dizzy Professor",0

; Game state
gameOver BYTE 0              ; 0=running, 1=game over
endReason BYTE 64 DUP(?)    ; reason why game ended
prevPosX BYTE 0              ; track previous position for undo
prevPosY BYTE 0

; Termination mode: 0 = endless, 1 = finite steps
terminationMode BYTE 0
stepLimit DWORD 0

; Movement mode: 0 = Random, 1 = Keyboard
gameMode BYTE 1
modeChanged BYTE 0
modeMsg BYTE "Mode: ",0
modeRandom BYTE "Random",0
modeKeyboard BYTE "Keyboard",0

newline BYTE 0Dh,0Ah,0
uiSeparatorLine BYTE 93 DUP('='),0
uiDashLine BYTE 74 DUP('-'),0
screenInputBuffer BYTE 4 DUP(0)

; Replace these lines to change the initial DIZZY WALK ASCII art.
; Keep the art stored in-file so it is easy to swap later.

dizzyWalkArt BYTE " /$$$$$$$  /$$$$$$ /$$$$$$$$ /$$$$$$$$/$$     /$$  /$$      /$$  /$$$$$$  /$$       /$$   /$$      ",0
             BYTE "| $$__  $$|_  $$_/|_____ $$ |_____ $$|  $$   /$$/ | $$  /$ | $$ /$$__  $$| $$      | $$  /$$/      ",0
             BYTE "| $$  \ $$  | $$       /$$/      /$$/ \  $$ /$$/  | $$ /$$$| $$| $$  \ $$| $$      | $$ /$$/       ",0
             BYTE "| $$  | $$  | $$      /$$/      /$$/   \  $$$$/   | $$/$$ $$ $$| $$$$$$$$| $$      | $$$$$/        ",0
             BYTE "| $$  | $$  | $$     /$$/      /$$/     \  $$/    | $$$$_  $$$$| $$__  $$| $$      | $$  $$        ",0
             BYTE "| $$  | $$  | $$    /$$/      /$$/       | $$     | $$$/ \  $$$| $$  | $$| $$      | $$\  $$       ",0
             BYTE "| $$$$$$$/ /$$$$$$ /$$$$$$$$ /$$$$$$$$   | $$     | $$/   \  $$| $$  | $$| $$$$$$$$| $$ \  $$      ",0
             BYTE "|_______/ |______/|________/|________/   |__/     |__/     \__/|__/  |__/|________/|__/  \__/      ",0

dizzyWalkArtLines EQU 8


introTagline BYTE "A dizzy professor is trying to find the way home...",0
introContinuePrompt BYTE "Press any key to continue",0

menuTitle BYTE "                                       MAIN MENU",0
menuStartOption BYTE "1. Start Adventure",0
menuHelpOption BYTE "2. Help",0
menuExitOption BYTE "3. Exit",0
menuChoicePrompt BYTE "Choose Option:",0
menuChoiceArrow BYTE "> ",0

helpTitle BYTE "                                       HELP",0
helpLine1 BYTE "Use W/A/S/D to move through the maze.",0
helpLine2 BYTE "Collect coins, find the key, and reach home.",0
helpLine3 BYTE "Press M to toggle movement mode when allowed.",0
helpReturnPrompt BYTE "Press any key to return to the main menu.",0

setupTitle BYTE "                                 PROFESSOR SETUP",0
setupNamePrompt BYTE "Enter Professor Name:",0
setupContinuePrompt BYTE "Press ENTER to continue.",0

adventureTypeTitle BYTE "                                 ADVENTURE TYPE",0
adventureEndlessOption BYTE "1. Endless Adventure",0
adventureFixedOption BYTE "2. Fixed Number of Steps",0
adventureChoicePrompt BYTE "Choose Option (1-2):",0

stepConfigTitle BYTE "                                  STEP CONFIGURATION",0
stepConfigPrompt BYTE "Enter Maximum Steps:",0

gameOverTitle BYTE "                                     GAME OVER",0
gameOverReasonLabel BYTE "Reason:",0
gameOverWalletLabel BYTE "Final Wallet: ",0
gameOverStepsLabel BYTE "Total Steps: ",0
gameOverSavedMsg BYTE "Adventure log saved successfully.",0
gameOverRestartOption BYTE "1. Restart Adventure",0
gameOverExitOption BYTE "2. Exit Game",0
gameOverChoicePrompt BYTE "Choose Option (1-2):",0
gameOverReasonText BYTE "Professor reached home but lost the key.",0
gameOverPitText BYTE "Professor fell into a pit.",0
gameOverWinText BYTE "Professor reached home with the key.",0
gameOverStepLimitText BYTE "Step limit reached.",0
keyYesText BYTE "Yes",0
keyNoText BYTE "No",0

termPrompt BYTE "Choose termination mode: (E) endless or (F) finite steps: ",0
stepLimitPrompt BYTE "Enter maximum number of steps: ",0
termEndlessMsg BYTE "Termination mode set to endless.",0
termFiniteMsg BYTE "Termination mode set to finite steps.",0
stepLimitReachedMsg BYTE "Step limit reached.",0
namePrompt BYTE "Enter professor name (press Enter for default): ",0
restartPrompt BYTE "Press R to restart or Q to quit: ",0

; End game messages
pitMsg BYTE "Professor fell into a pit.",0
noKeyMsg BYTE "Professor reached home but lost the key.",0
winMsg BYTE "Professor reached home with the key.",0

PUBLIC currentProfessor
PUBLIC maze
PUBLIC cameraRow
PUBLIC cameraCol
PUBLIC pathX
PUBLIC pathY
PUBLIC pathCount
PUBLIC pickupType
PUBLIC pickupX
PUBLIC pickupY
PUBLIC pickupStep
PUBLIC pickupCount
PUBLIC logFileName
PUBLIC numberBuffer
PUBLIC defaultProfessorName
PUBLIC gameOver
PUBLIC endReason
PUBLIC terminationMode
PUBLIC stepLimit
PUBLIC gameMode
PUBLIC modeChanged
PUBLIC modeMsg
PUBLIC modeRandom
PUBLIC modeKeyboard
PUBLIC newline

PUBLIC prevPosX 
PUBLIC prevPosY 
PUBLIC pitMsg
PUBLIC noKeyMsg 
PUBLIC winMsg
PUBLIC termPrompt
PUBLIC stepLimitPrompt
PUBLIC termEndlessMsg
PUBLIC termFiniteMsg
PUBLIC stepLimitReachedMsg
PUBLIC namePrompt



.code

;=================================================
; MAIN
; Input: None
; Output: None
; Purpose: Main game loop entry point; manages menu navigation and game initialization
;=================================================
main PROC

    call Randomize
    call ShowIntroScreen

StartMenu:
    call ShowMainMenu
    cmp al, '1'
    je StartAdventure
    cmp al, '2'
    je ShowHelp
    cmp al, '3'
    je QuitGame
    jmp StartMenu

ShowHelp:
    call ShowHelpScreen
    jmp StartMenu

StartAdventure:
    call ShowProfessorSetup
    call ShowAdventureTypeSetup
    call InitMaze

GameLoop:

    call DrawMaze

    ; Choose behavior based on gameMode
    cmp gameMode, 0
    je RandomMode
    jne KeyboardMode

RandomMode:
    ; Save current position before move
    mov al, currentProfessor.posX
    mov prevPosX, al
    mov al, currentProfessor.posY
    mov prevPosY, al
    
    call HandleRandom
    jmp AfterMove

KeyboardMode:
    ; Save current position before move
    mov al, currentProfessor.posX
    mov prevPosX, al
    mov al, currentProfessor.posY
    mov prevPosY, al
    
    call HandleKeyboardInput

AfterMove:

    call ResolveMovement
    call RecordPathPoint

    inc currentProfessor.steps

    cmp gameOver, 1
    je GameEnd

    cmp terminationMode, 1
    jne GameLoop

    mov eax, currentProfessor.steps
    cmp eax, stepLimit
    jb GameLoop

    mov gameOver, 1
    lea esi, stepLimitReachedMsg
    lea edi, endReason
    call CopyString
    
    cmp gameOver, 1
    je GameEnd

    jmp GameLoop

GameEnd:
    call WriteAdventureLog

GameEndChoice:
    call ShowGameOverScreen
    cmp al, '1'
    je StartAdventure
    cmp al, '2'
    je QuitGame
    jmp GameEndChoice

QuitGame:
    call ExitProcess


main ENDP

;=================================================
; PROMPT TERMINATION MODE
; 0 = endless, 1 = finite steps
;=================================================

;=================================================
; SHOW INTRO SCREEN
; Input: None
; Output: None
; Purpose: Display intro screen with Dizzy Walk ASCII art and tagline; wait for key press
;=================================================
ShowIntroScreen PROC
    call Clrscr
    mov eax, lightCyan
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf

    lea esi, dizzyWalkArt
    mov ecx, dizzyWalkArtLines
    call PrintTextBlock

    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    call Crlf

    mov eax, lightGray
    call SetTextColor
    lea edx, introTagline
    call WriteString
    call Crlf
    call Crlf
    lea edx, introContinuePrompt
    call WriteString
    call ReadChar
    call Crlf
    ret
ShowIntroScreen ENDP

;=================================================
; SHOW MAIN MENU
; Input: None
; Output: AL = selected menu option (1, 2, or 3)
; Purpose: Display main menu and get user selection
;=================================================
ShowMainMenu PROC
MainMenuLoop:
    call Clrscr
    mov eax, lightGray
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    lea edx, menuTitle
    call WriteString
    call Crlf
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    call Crlf

    lea edx, menuStartOption
    call WriteString
    call Crlf
    lea edx, menuHelpOption
    call WriteString
    call Crlf
    lea edx, menuExitOption
    call WriteString
    call Crlf
    call Crlf

    lea edx, menuChoicePrompt
    call WriteString
    call Crlf
    lea edx, menuChoiceArrow
    call WriteString
    call ReadChar
    call Crlf

    cmp al, '1'
    je SMM_Done
    cmp al, '2'
    je SMM_Done
    cmp al, '3'
    je SMM_Done
    jmp MainMenuLoop

SMM_Done:
    ret
ShowMainMenu ENDP

;=================================================
; SHOW HELP SCREEN
; Input: None
; Output: None
; Purpose: Display help information and movement controls
;=================================================
ShowHelpScreen PROC
    call Clrscr
    mov eax, lightGray
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    lea edx, helpTitle
    call WriteString
    call Crlf
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    call Crlf
    lea edx, helpLine1
    call WriteString
    call Crlf
    lea edx, helpLine2
    call WriteString
    call Crlf
    lea edx, helpLine3
    call WriteString
    call Crlf
    call Crlf
    lea edx, helpReturnPrompt
    call WriteString
    call ReadChar
    call Crlf
    ret
ShowHelpScreen ENDP

;=================================================
; SHOW PROFESSOR SETUP
; Input: None
; Output: currentProfessor.profName populated
; Purpose: Prompt user to enter professor name or use default
;=================================================
ShowProfessorSetup PROC
    call Clrscr
    mov eax, lightGray
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    lea edx, setupTitle
    call WriteString
    call Crlf
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    call Crlf

    lea edx, setupNamePrompt
    call WriteString
    call Crlf
    lea edx, menuChoiceArrow
    call WriteString
    lea edx, currentProfessor.profName
    mov ecx, 31
    call ReadString
    call Crlf
    call Crlf

    lea edx, setupContinuePrompt
    call WriteString
    lea edx, screenInputBuffer
    mov ecx, SIZEOF screenInputBuffer - 1
    call ReadString
    call Crlf
    ret
ShowProfessorSetup ENDP

;=================================================
; SHOW ADVENTURE TYPE / STEP CONFIG
;=================================================

ShowAdventureTypeSetup PROC
AdventureTypeLoop:
    call Clrscr
    mov eax, lightGray
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    lea edx, adventureTypeTitle
    call WriteString
    call Crlf
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    call Crlf

    lea edx, adventureEndlessOption
    call WriteString
    call Crlf
    lea edx, adventureFixedOption
    call WriteString
    call Crlf
    call Crlf

    lea edx, adventureChoicePrompt
    call WriteString
    call Crlf
    lea edx, menuChoiceArrow
    call WriteString
    call ReadChar
    call Crlf

    cmp al, '1'
    je SAT_Endless
    cmp al, '2'
    je SAT_Fixed
    jmp AdventureTypeLoop

SAT_Endless:
    mov terminationMode, 0
    mov stepLimit, 0
    ret

SAT_Fixed:
    mov terminationMode, 1
    call ShowStepConfiguration
    ret
ShowAdventureTypeSetup ENDP

;=================================================
; SHOW STEP CONFIGURATION
; Input: None
; Output: stepLimit populated
; Purpose: Prompt user to enter maximum step limit for finite mode
;=================================================
ShowStepConfiguration PROC
    call Clrscr
    mov eax, lightGray
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    lea edx, stepConfigTitle
    call WriteString
    call Crlf
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    call Crlf
    lea edx, stepConfigPrompt
    call WriteString
    call Crlf
    lea edx, menuChoiceArrow
    call WriteString
    call ReadDec
    mov stepLimit, eax
    call Crlf
    ret
ShowStepConfiguration ENDP

;=================================================
; PRINT TEXT BLOCK
; Input: ESI = address of first null-terminated line, ECX = number of lines
; Output: None
; Purpose: Print multiple null-terminated strings with line breaks
;=================================================

PrintTextBlock PROC uses esi ecx
PTB_NextLine:
    cmp ecx, 0
    je PTB_Done

    mov edx, esi
    call WriteString
    call Crlf

PTB_ScanLine:
    mov al, [esi]
    inc esi
    cmp al, 0
    jne PTB_ScanLine

    dec ecx
    jmp PTB_NextLine

PTB_Done:
    ret
PrintTextBlock ENDP

;=================================================
; SHOW GAME OVER SCREEN
; Input: None
; Output: AL = selected choice (1 or 2)
; Purpose: Display game over message, stats, and menu choices
;=================================================
ShowGameOverScreen PROC
    call Clrscr

    mov eax, lightRed
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf

    mov eax, yellow
    call SetTextColor
    lea edx, gameOverTitle
    call WriteString
    call Crlf

    mov eax, lightRed
    call SetTextColor
    lea edx, uiSeparatorLine
    call WriteString
    call Crlf
    call Crlf

    mov eax, lightGray
    call SetTextColor

    lea edx, gameOverReasonLabel
    call WriteString
    call Crlf
    lea edx, endReason
    call WriteString
    call Crlf
    call Crlf

    lea edx, gameOverWalletLabel
    call WriteString
    mov eax, currentProfessor.wallet
    call WriteDec
    call Crlf

    lea edx, gameOverStepsLabel
    call WriteString
    mov eax, currentProfessor.steps
    call WriteDec
    call Crlf
    call Crlf
    call Crlf
    lea edx, gameOverSavedMsg
    call WriteString
    call Crlf
    call Crlf
    
    mov eax, lightGray
    call SetTextColor
    lea edx, uiDashLine
    call WriteString
    call Crlf
    mov eax, lightGray
    call SetTextColor
    lea edx, gameOverRestartOption
    call WriteString
    call Crlf
    lea edx, gameOverExitOption
    call WriteString
    call Crlf
    call Crlf
    lea edx, uiDashLine
    call WriteString
    call Crlf
    lea edx, gameOverChoicePrompt
    call WriteString
    call Crlf
    lea edx, menuChoiceArrow
    call WriteString
    call ReadChar
    call Crlf

    push eax
    mov eax, lightGray
    call SetTextColor
    pop eax
    ret
ShowGameOverScreen ENDP

;=================================================
; PROMPT PROFESSOR NAME
; Input: None
; Output: currentProfessor.profName populated
; Purpose: Prompt user to enter professor name with maximum 31 characters
;=================================================
PromptProfessorName PROC
    lea edx, namePrompt
    call WriteString

    lea edx, currentProfessor.profName
    mov ecx, 31
    call ReadString
    call Crlf
    ret
PromptProfessorName ENDP

;=================================================
; INCLUDE MODULES
;=================================================

INCLUDE maze_data.inc
INCLUDE movement.inc
INCLUDE input.inc
INCLUDE render.inc
INCLUDE game_logic.inc



END main
