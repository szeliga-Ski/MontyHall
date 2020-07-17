ORG 32768

INCLUDE "data.asm"			; include data definitions
INCLUDE "subroutines.asm"	; include subroutines

J_start:
	CALL F_blackScreen			; clear screen, set ink & paper
	;LD A, (num_iterations)		; initialise the loop by
	;LD B, A						; putting loop counter in B
	LD B, NUM_ITERATIONS
	
	XOR A
	LD (swap), A
	LD (stick), A

J_mainLoop:
	PUSH BC						; store the loop counter
	LD A, B
	LD (loopCounter), A			; and store in RAM for use by print routines
	
	LD HL, 23692				; prevent the "Scroll?" message
	LD (HL), 100				;

	; initialise the three doors
	LD A, GOAT					; store the character code for G
	LD HL, doors				; behind each of the three doors
	LD (HL), A					; Door 1
	INC HL
	LD (HL), A					; Door 2
	INC HL
	LD (HL), A					; Door 3

J_getRandom0:					; put the car behind a random door
	CALL F_random				; load A with a pseudo-random number
	AND 3						; we need a door offset which is 0-2
	CP 2						; so blank top 5 bits and check
	JR Z, J_cont0				; random number is 2 so continue
	JR C, J_cont0				; random number was either 0 or 1 so continue
	JR NC, J_getRandom0			; get another number 'cos offset=3
J_cont0:						; we now have a door offset 0-2 in A
	LD HL, doors				; point HL at the 'doors' array
	LD B, 0						; set up the offset in
	LD C, A						; registers BC
	ADD HL, BC					; offset to point to the random door
	LD (HL), CAR				; store the Car behind this door
	LD (carDoorNum), A			; store car position in temporary RAM variable

	CALL F_displayDoorContents	; display contents of the three doors

	; pick a random door
J_getRandom1:					; put the car behind a random door
	CALL F_random				; load A with a pseudo-random number
	AND 3						; we need a door offset which is 0-2
	CP 2						; so blank top 5 bits and check
	JR Z, J_cont1				; random number is 2 so continue
	JR C, J_cont1				; random number was either 0 or 1 so continue
	JR NC, J_getRandom1			; get another number 'cos offset=3
J_cont1:						; we now have a door offset 0-2 in A
	; TO DO: display loop counter, random door #, car position, random door contents
	LD (randDoorNum), A			; store random door number in RAM
	CALL F_displayState

	; if that car is behind the random door then increment 'stick'	
	LD A, (randDoorNum)			; load the offset
	LD HL, doors				; point HL at the doors array
	LD B, 0						; copy offset to BC
	LD C, A						;
	ADD HL, BC					; add offset to HL
	LD A, (HL)					; see what is behind the door	
	CP CAR
	JR NZ, J_revealGoat			; it wasn't a car so skip the increment
	LD A, (stick)				; increment the 'stick' variable
	INC A						;
	LD (stick), A				; store the incremented value	

J_revealGoat:					; reveal a random goat	
	; choose a random door number 0-2
	; repeat if we have chosen the car or the random door
	CALL F_random				; load A with a pseudo-random number
	AND 3						; we need a door offset which is 0-2
	CP 2						; so blank top 5 bits and check
	JR Z, J_cont2				; random number is 2 so continue
	JR C, J_cont2				; random number was either 0 or 1 so continue
	JR NC, J_revealGoat			; get another number 'cos offset=3	
J_cont2:
	; Also need to pick another door if the door has the car
	; ... or is the one already chosen by the contestant
	LD (goatDoorNum), A			; store the chosen door in RAM
	LD B, A
	LD A, (carDoorNum)
	CP B
	JR Z, J_revealGoat			; get another door - we chose the car!
	
	LD A, (randDoorNum)			; see if it is the contestant's door
	LD B, A
	LD A, (goatDoorNum)
	CP B
	JR Z, J_revealGoat			; get another door - we chose the contestant's door!
	
	; phew - we can now get the player to change doors!
	LD (goatDoorNum), A			; store the door we are going to switch to
	
	; get player to change door choice - "LET d=6-m-d"
	LD A, SUM_OF_DOORS
	LD HL, randDoorNum
	SUB (HL)
	LD HL, goatDoorNum
	SUB (HL)
	LD (randDoorNum), A			; store the 'other' door number

	; display loop counter, random door #, car position, random door contents, random goat position
	
	CALL F_displayState2
	
	; if random door position holds the car then increment 'swap'
	
	LD A, (randDoorNum)			; get door offset
	LD B, 0						;
	LD C, A						; ... store in BC
	LD HL, doors				; point HL at doors array
	ADD HL, BC					; add offset
	LD A, (HL)
	CP CAR
	JR Z, J_incSwap				; it was the car
	JR J_nextLoop				; it wasn't the car
J_incSwap:
	LD A, (swap)				; increment the 'swaps' count
	INC A						;
	LD (swap), A				; and store in RAM

J_nextLoop:	
	POP BC						; continue the main loop
	DEC B						;
	JP  NZ, J_mainLoop			;

	; end of iterations so display the results
	
	CALL F_displayResults
	CALL F_pressAnyKey
	JP J_start
	
RET
	
END 32768				; makes TAP file auto-run