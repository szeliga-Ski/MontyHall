; *******************************************************************
; *																	*
;{ * Data															*
; *																	*
; *******************************************************************

;ORG_VAL					EQU		32768

BLACK					EQU		64		; ATTR-P bright black ink on black paper
BLUE					EQU		65		; ATTR-P bright blue ink on black paper
RED						EQU		66		; ATTR-P bright red ink on black paper
MAGENTA					EQU		67		; ATTR-P bright magenta ink on black paper
GREEN					EQU		68		; ATTR-P bright green ink on black paper
CYAN					EQU		69		; ATTR-P bright cyan ink on black paper
YELLOW					EQU		70		; ATTR-P bright yellow ink on black paper
WHITE					EQU		71		; ATTR-P bright white ink on black paper

NUMBER_OF_HALTS			EQU		3		; used by "delay" routine

NEWLINE					EQU		13		; new line character code
SPACE					EQU		32		; space character code
PERCENT					EQU		37		; % sign code
CAR						EQU		67		; character code for 'C' (for Car)
GOAT					EQU		71		; character code for 'G' (for Goat)
UDG_A					EQU		144		; UDG 'A'
UDG_B					EQU		145		; UDG 'B'

SUM_OF_DOORS			EQU		3		; 0+1+2 = 3

NUM_ITERATIONS			EQU		255

STACK_BC    			EQU		#2d2b	; calculator ROM routine
FP_TO_BC    			EQU		#2da2	; calculator ROM routine

; variables

swap					DEFB	0		; count of the number of swaps
stick					DEFB	0		; count of the number of sticks
;num_iterations			DEFB	80		; number of iterations to run for
loopCounter				DEFB	0		; loop counter
randDoorNum				DEFB	0		; random door number
goatDoorNum				DEFB	0		; reveal a goat door number
carDoorNum				DEFB	0		; car position
;tempVar					DEFB	0		; used in J_cont2

; UDG graphics.

blocks DEFB 255,129,129,129,129,129,129,255	; UDG 'A' = empty box
       DEFB 255,255,255,255,255,255,255,255	; UDG 'B' = filled-in square

; game messages

strDoors			DEFB 'Doors: '							; 7 chars
DOORS_LEN			EQU		7
strRandDoor			DEFB 'D:'								; 2 chars
RAND_DOORS_LEN		EQU		2
strLoop				DEFB 'I:'								; 2 chars
LOOP_LEN			EQU 	2
strCarPosn			DEFB 'C:'								; 2 chars
CAR_POSN_LEN		EQU		2
strChosenDoor		DEFB 'R:'								; 2 chars
CHOSEN_DOOR_LEN		EQU		2
strGoatDoor			DEFB 'M:'								; 2 chars
GOAT_DOOR_LEN		EQU		2
strStick			DEFB 'Stick: '							; 7 chars
STICK_LEN			EQU		7
strSwap				DEFB 'Swap: '							; 6 chars
SWAP_LEN			EQU		6
strOutOf			DEFB ' out of '							; 8 chars
OUT_OF_LEN			EQU		8

strXCoord			DEFB 'x='
XCOORD_LEN			EQU 	2
strYCoord			DEFB 'y='
str3Spaces			DEFB '   '
STR3SPACES_LEN		EQU 	3
strEndMessage		DEFB '   Press any key to run again' 	; 29 chars
END_MESSAGE_LEN		EQU 	29
strEquals			DEFB ' = '
EQUALS_LEN			EQU		3

YCOORD_LEN			EQU 	2
xPosStr				DEFB 	0								; used to print string
yPosStr				DEFB 	0								; used to print string
count				DEFB 	0								; used to count adjacent cells
arrayOffset			DEFB	0								; used to index into an array

printColour			DEFB 	GREEN							; used in F_printStr

doors 				DEFS 	3,0		; The door array used in the main loop

FALSE				EQU		0		; Boolean value
TRUE				EQU		1		; Boolean value

;} End of data