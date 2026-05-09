; MEMBERS:
; Sameer Ahmed  (24I-2047)
; Abdul Hannan (24I-2014)
;
; FILE: game_logic.inc

CopyString PROTO        ; Input: ESI=source, EDI=dest | Copies string until null
GetMazeCell PROTO        ; Input: EAX=row, EDX=col | Output: AL=cell
SetMazeCell PROTO        ; Input: EAX=row, EDX=col, BL=value
ResolveMovement PROTO    ; Check destination cell and apply game rules
RecordPathPoint PROTO    ; Store current professor position in path history
RecordPickup PROTO       ; Input: AL=pickup type, records coords and step
WriteAdventureLog PROTO  ; Write final adventure log file
HandleRandom PROTO
InitMaze PROTO
