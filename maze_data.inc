; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: maze_data.inc

GenerateMaze PROTO
FillMaze PROTO
GenerateBorders PROTO

DrawBuilding PROTO,
    startRow:DWORD,
    startCol:DWORD,
    height:DWORD,
    bWidth:DWORD

DrawHorizontalWall PROTO,
    row:DWORD,
    startCol:DWORD,
    wallLen:DWORD

DrawVerticalWall PROTO,
    col:DWORD,
    startRow:DWORD,
    wallLen:DWORD

DrawLake PROTO,
    startRow:DWORD,
    startCol:DWORD,
    height:DWORD,
    lWidth:DWORD

PlaceCoin PROTO,
    row:DWORD,
    col:DWORD

PlacePit PROTO,
    row:DWORD,
    col:DWORD

PlaceLake PROTO,
    row:DWORD,
    col:DWORD

PlaceStumble PROTO,
    row:DWORD,
    col:DWORD

PlaceKey PROTO,
    row:DWORD,
    col:DWORD

PlaceDestination PROTO,
    row:DWORD,
    col:DWORD