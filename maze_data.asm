; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: maze_data.asm

.386
.model flat, STDCALL

INCLUDE Irvine32.inc
INCLUDE constants.inc
INCLUDE maze_data.inc

.code

;=================================================
; FILL MAZE
; Input: None
; Output: maze buffer filled with '.' characters
; Purpose: Initialize entire maze with empty floor tiles
;=================================================
FillMaze PROC

    mov edi, OFFSET maze
    mov ecx, WORLD_ROWS * WORLD_COLS
    mov al, '.'
    rep stosb

    ret
FillMaze ENDP

;=================================================
; GENERATE BORDERS
; Input: maze buffer should be pre-filled
; Output: maze borders set to '#' characters
; Purpose: Create wall borders on all four edges of the maze
;=================================================
GenerateBorders PROC

    ; TOP BORDER
    mov edi, OFFSET maze
    mov ecx, WORLD_COLS
    mov al, '#'
    rep stosb

    ; BOTTOM BORDER
    mov edi, OFFSET maze
    add edi, (WORLD_ROWS - 1) * WORLD_COLS

    mov ecx, WORLD_COLS
    mov al, '#'
    rep stosb

    ; LEFT + RIGHT
    mov esi, 0
    mov ecx, WORLD_ROWS

BorderLoop:

    ; LEFT
    mov eax, esi
    imul eax, WORLD_COLS
    mov maze[eax], '#'

    ; RIGHT
    mov eax, esi
    imul eax, WORLD_COLS
    add eax, WORLD_COLS - 1
    mov maze[eax], '#'

    inc esi
    loop BorderLoop

    ret
GenerateBorders ENDP

;=================================================
; DRAW BUILDING
; Input: startRow, startCol, height, bWidth = building rectangle
; Output: maze filled with 'B' characters in rectangle
; Purpose: Draw rectangular building structure in maze
;=================================================
DrawBuilding PROC USES eax ebx esi edi,
    startRow:DWORD,
    startCol:DWORD,
    height:DWORD,
    bWidth:DWORD

    mov esi, 0

RowLoop:

    mov edi, 0

ColLoop:

    mov eax, startRow
    add eax, esi
    imul eax, WORLD_COLS

    mov ebx, startCol
    add ebx, edi

    add eax, ebx

    mov maze[eax], 'B'

    inc edi
    cmp edi, bWidth
    jl ColLoop

    inc esi
    cmp esi, height
    jl RowLoop

    ret
DrawBuilding ENDP

;=================================================
; DRAW HORIZONTAL WALL
; Input: row = wall row, startCol = start column, wallLen = length
; Output: maze filled with '#' characters horizontally
; Purpose: Draw horizontal wall segment
;=================================================
DrawHorizontalWall PROC USES eax ebx ecx,
    row:DWORD,
    startCol:DWORD,
    wallLen:DWORD

    mov ebx, startCol
    mov ecx, wallLen

HWallLoop:

    mov eax, row
    imul eax, WORLD_COLS
    add eax, ebx

    mov maze[eax], '#'

    inc ebx
    loop HWallLoop

    ret
DrawHorizontalWall ENDP

;=================================================
; DRAW VERTICAL WALL
; Input: col = wall column, startRow = start row, wallLen = length
; Output: maze filled with '#' characters vertically
; Purpose: Draw vertical wall segment
;=================================================
DrawVerticalWall PROC USES eax ebx ecx,
    col:DWORD,
    startRow:DWORD,
    wallLen:DWORD

    mov ebx, startRow
    mov ecx, wallLen

VWallLoop:

    mov eax, ebx
    imul eax, WORLD_COLS
    add eax, col

    mov maze[eax], '#'

    inc ebx
    loop VWallLoop

    ret
DrawVerticalWall ENDP

;=================================================
; DRAW LAKE
; Input: startRow, startCol, height, lWidth = lake rectangle
; Output: maze filled with '~' characters in rectangle
; Purpose: Draw rectangular lake (blocked terrain) in maze
;=================================================
DrawLake PROC USES eax ebx esi edi,
    startRow:DWORD,
    startCol:DWORD,
    height:DWORD,
    lWidth:DWORD

    mov esi, 0

LakeRowLoop:

    mov edi, 0

LakeColLoop:

    mov eax, startRow
    add eax, esi
    imul eax, WORLD_COLS

    mov ebx, startCol
    add ebx, edi

    add eax, ebx
    mov maze[eax], '~'

    inc edi
    cmp edi, lWidth
    jl LakeColLoop

    inc esi
    cmp esi, height
    jl LakeRowLoop

    ret
DrawLake ENDP

;=================================================
; PLACE COIN
; Input: row, col = position
; Output: maze[row][col] = 'C'
; Purpose: Place collectible coin at specified position
;=================================================
PlaceCoin PROC USES eax,
    row:DWORD,
    col:DWORD

    mov eax, row
    imul eax, WORLD_COLS
    add eax, col

    mov maze[eax], 'C'

    ret
PlaceCoin ENDP

;=================================================
; PLACE PIT
; Input: row, col = position
; Output: maze[row][col] = 'X'
; Purpose: Place pit hazard at specified position
;=================================================
PlacePit PROC USES eax,
    row:DWORD,
    col:DWORD

    mov eax, row
    imul eax, WORLD_COLS
    add eax, col

    mov maze[eax], 'X'

    ret
PlacePit ENDP

;=================================================
; PLACE LAKE
; Input: row, col = position
; Output: maze[row][col] = '~'
; Purpose: Place lake (blocked tile) at specified position
;=================================================
PlaceLake PROC USES eax,
    row:DWORD,
    col:DWORD

    mov eax, row
    imul eax, WORLD_COLS
    add eax, col

    mov maze[eax], '~'

    ret
PlaceLake ENDP

;=================================================
; PLACE STUMBLE
; Input: row, col = position
; Output: maze[row][col] = 'S'
; Purpose: Place stumble hazard at specified position
;=================================================
PlaceStumble PROC USES eax,
    row:DWORD,
    col:DWORD

    mov eax, row
    imul eax, WORLD_COLS
    add eax, col

    mov maze[eax], 'S'

    ret
PlaceStumble ENDP

;=================================================
; PLACE KEY
; Input: row, col = position
; Output: maze[row][col] = 'K'
; Purpose: Place key collectible at specified position
;=================================================
PlaceKey PROC USES eax,
    row:DWORD,
    col:DWORD

    mov eax, row
    imul eax, WORLD_COLS
    add eax, col

    mov maze[eax], 'K'

    ret
PlaceKey ENDP

;=================================================
; PLACE DESTINATION
; Input: row, col = position
; Output: maze[row][col] = 'D'
; Purpose: Place destination goal at specified position
;=================================================
PlaceDestination PROC USES eax,
    row:DWORD,
    col:DWORD

    mov eax, row
    imul eax, WORLD_COLS
    add eax, col

    mov maze[eax], 'D'

    ret
PlaceDestination ENDP

;=================================================
; GENERATE MAZE
; Input: None
; Output: maze buffer fully populated with game layout
; Purpose: Generate complete procedural maze with buildings, walls, coins, hazards, key, and destination
;=================================================
GenerateMaze PROC

    call FillMaze
    call GenerateBorders

    ; =====================================================
    ; CITY BLOCKS (B)
    ; =====================================================

    invoke DrawBuilding, 6, 8, 9, 16
    invoke DrawBuilding, 8, 33, 11, 14
    invoke DrawBuilding, 7, 55, 9, 18
    invoke DrawBuilding, 9, 82, 12, 15
    invoke DrawBuilding, 6, 112, 10, 20

    invoke DrawBuilding, 27, 12, 10, 20
    invoke DrawBuilding, 30, 44, 9, 16
    invoke DrawBuilding, 29, 72, 11, 17
    invoke DrawBuilding, 28, 98, 10, 19

    invoke DrawBuilding, 67, 10, 10, 18
    invoke DrawBuilding, 70, 36, 9, 16
    invoke DrawBuilding, 69, 60, 11, 18
    invoke DrawBuilding, 71, 89, 10, 16
    invoke DrawBuilding, 68, 116, 12, 17

    ; Professor spawn neighborhood (spawn is near row 50, col 75)
    ; Building sits just to the east so it looks like the professor stepped out.
    invoke DrawBuilding, 47, 76, 7, 9

    ; Destination neighborhood building (destination is near row 94, col 6)
    invoke DrawBuilding, 90, 10, 6, 10

    ; =====================================================
    ; MAZE WALLS (#) WITH GAPS
    ; =====================================================

    invoke DrawHorizontalWall, 20, 2, 38
    invoke DrawHorizontalWall, 20, 48, 30
    invoke DrawHorizontalWall, 20, 90, 57

    invoke DrawHorizontalWall, 42, 2, 26
    invoke DrawHorizontalWall, 42, 36, 42
    invoke DrawHorizontalWall, 42, 88, 59

    invoke DrawHorizontalWall, 60, 2, 33
    invoke DrawHorizontalWall, 60, 46, 36
    invoke DrawHorizontalWall, 60, 96, 51

    invoke DrawHorizontalWall, 84, 2, 45
    invoke DrawHorizontalWall, 84, 58, 33
    invoke DrawHorizontalWall, 84, 102, 45

    invoke DrawVerticalWall, 22, 21, 17
    invoke DrawVerticalWall, 47, 21, 15
    invoke DrawVerticalWall, 78, 21, 19
    invoke DrawVerticalWall, 104, 21, 15
    invoke DrawVerticalWall, 131, 21, 18

    invoke DrawVerticalWall, 30, 43, 15
    invoke DrawVerticalWall, 58, 43, 14
    invoke DrawVerticalWall, 87, 43, 16
    invoke DrawVerticalWall, 118, 43, 15

    invoke DrawVerticalWall, 18, 61, 22
    invoke DrawVerticalWall, 43, 61, 21
    invoke DrawVerticalWall, 74, 61, 20
    invoke DrawVerticalWall, 99, 61, 21
    invoke DrawVerticalWall, 126, 61, 22

    ; Ensure the spawn tile and the immediate "just exited" doorway path stay open.
    mov eax, 50
    imul eax, WORLD_COLS
    add eax, 75
    mov maze[eax], '.'

    mov eax, 50
    imul eax, WORLD_COLS
    add eax, 76
    mov maze[eax], '.'

    ; Small doorway in the destination-side building facing west.
    mov eax, 94
    imul eax, WORLD_COLS
    add eax, 10
    mov maze[eax], '.'

    ; =====================================================
    ; LAKES (~)
    ; =====================================================

    invoke DrawLake, 15, 122, 8, 14
    invoke DrawLake, 48, 12, 9, 18
    invoke DrawLake, 73, 101, 10, 20

    invoke PlaceLake, 47, 11
    invoke PlaceLake, 58, 30
    invoke PlaceLake, 14, 136
    invoke PlaceLake, 82, 121

    ; =====================================================
    ; COINS (C)
    ; =====================================================

    invoke PlaceCoin, 4, 4
    invoke PlaceCoin, 12, 49
    invoke PlaceCoin, 18, 87
    invoke PlaceCoin, 24, 140
    invoke PlaceCoin, 39, 15
    invoke PlaceCoin, 49, 96
    invoke PlaceCoin, 57, 66
    invoke PlaceCoin, 66, 132
    invoke PlaceCoin, 78, 7
    invoke PlaceCoin, 88, 54
    invoke PlaceCoin, 92, 119
    invoke PlaceCoin, 95, 145

    ; =====================================================
    ; PITS (X)
    ; =====================================================

    invoke PlacePit, 26, 82
    invoke PlacePit, 27, 83
    invoke PlacePit, 28, 84
    invoke PlacePit, 63, 52
    invoke PlacePit, 64, 53
    invoke PlacePit, 85, 111
    invoke PlacePit, 86, 112
    invoke PlacePit, 87, 113

    ; =====================================================
    ; STUMBLES (S)
    ; =====================================================

    invoke PlaceStumble, 13, 27
    invoke PlaceStumble, 21, 68
    invoke PlaceStumble, 35, 108
    invoke PlaceStumble, 45, 41
    invoke PlaceStumble, 59, 91
    invoke PlaceStumble, 72, 27
    invoke PlaceStumble, 83, 73
    invoke PlaceStumble, 90, 138

    ; =====================================================
    ; GOALS (K, D)
    ; =====================================================

    invoke PlaceKey, 6, 142
    invoke PlaceDestination, 94, 6

    ret
GenerateMaze ENDP

END