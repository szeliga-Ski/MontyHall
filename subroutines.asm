JP J_start


; *******************************************************************
; *																	*
; * Utility routine: 	Clears the screen - black paper, green ink  *
; *																	*
; *******************************************************************	   

F_blackScreen:
;{ Set up the bold font
	CALL F_boldFont
	LD HL,blocks        ; address of user-defined graphics data.
	LD (23675),HL       ; make UDGs point to it.
;}
;{ We want a black screen.
	LD A,GREEN     		; green ink (4) on black paper (0), bright (64).
	LD (23693),A        ; set our screen colours - ATTR-P
	XOR A               ; quick way to load accumulator with zero.
	CALL $229B 			; 8859 - set permanent border colours.
;}

;{ Clear the screen
	CALL $0DAF          ; ROM routine - clears screen, opens chan 2.
	LD A,2				; upper screen
	CALL $1601			; open channel		
;}

	RET
;} end of F_blackScreen



; *******************************************************************
; *																	*
; * Utility routine:	makes a bold font located at 60000			*
; *																	*
; *******************************************************************

F_boldFont:
	LD HL,15616			;ROM font
	LD DE,60000			;address of our font
	LD BC,768			;96 chars * 8 rows to alter
J_font1:
	LD A,(HL)			;get bitmap
	RLCA				;rotate it left
	OR (HL)				;combine two images
	LD (DE),A			;write to new font
	INC HL				;next byte of old
	INC DE				;next byte of new
	DEC BC				;decrement counter
	LD A,B				;high byte
	OR C				;combine with low byte
	JR NZ, J_font1		;repeat until BC=zero
	LD HL,60000-256		;font minus 32*8
	LD (23606),HL		;point to new font
	RET

; *******************************************************************
; *																	*
; * Utility routine:	Simple pseudo-random number generator.		*
; *																	*
; * Steps a pointer through the ROM (held in seed), returning		*
; * the contents of the byte at that location.						*
; *																	*
; *******************************************************************

F_random:
	LD HL,(seed)        ; Pointer
	LD A,H
	AND 31              ; keep it within first 8k of ROM.
	LD H,A
	LD A,(HL)           ; Get "random" number from location.
	INC HL              ; Increment pointer.
	LD (seed),HL
	RET

seed   DEFW 0


; *******************************************************************
; *																	*
; * Utility routine: 	Waits for a key to be pressed       		*
; *																	*
; *******************************************************************	   

F_pressAnyKey:
	PUSH AF	; preserve A
	PUSH BC
	PUSH DE

       LD HL,23560			; LAST K system variable.
       LD ( HL ),0			; put null value there.
keyloop   LD A,( HL )			; new value of LAST K.
       CP 0					; is it still zero?
       JR z,keyloop			; yes, so no key pressed.
	   
	POP DE
	POP BC
	POP AF
    RET						; key was pressed.

; ******************************************************************
	
F_displayRegistersBC:
	LD A,22						; AT code
	RST 16
	LD A, 0						; vertical coord
	RST 16
	LD A, 0						; horizontal coord	
	RST 16
	CALL 6683					; display generation number in BC
	RET

; ******************************************************************

F_displayDoorContents:
	LD DE, strDoors				; point DE at display string
	LD BC, DOORS_LEN			; BC=string length
	CALL F_printStr				; print template string "Doors: "

	LD A,CYAN					; in yellow ink
	LD (23695),A				; ATTR-T
	LD HL, doors				; print first door
	LD A, (HL)					; load A with door contents	
	RST 16						; print contents
	CALL F_printSpace
	
	INC HL						; point HL at the second door
	LD A,CYAN					; in yellow ink
	LD (23695),A				; ATTR-T
	LD A, (HL)					; load A with door contents	
	RST 16						; print contents
	CALL F_printSpace
	
	INC HL						; point HL at the third door
	LD A,CYAN					; in yellow ink
	LD (23695),A				; ATTR-T
	LD A, (HL)					; load A with door contents	
	RST 16						; print contents
	CALL F_printNewLine			; end the current display line
	RET
	
; ******************************************************************

F_displayState:

	LD DE, strLoop				; Print "Loop="
	LD BC, LOOP_LEN				; ...
	CALL F_printStr				; ... done
	LD A, (loopCounter)			; display the loop counter value
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW					; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	CALL F_printSpace
	CALL F_printSpace

	LD DE, strRandDoor
	LD BC, RAND_DOORS_LEN
	CALL F_printStr
	LD A, (randDoorNum)			; display random door number
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW					; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine	

	CALL F_printSpace
	CALL F_printSpace
	
	LD DE, strCarPosn			; display car position
	LD BC, CAR_POSN_LEN			; ...
	CALL F_printStr				; ...
	LD A, (carDoorNum)			; ...
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	CALL F_printSpace
	CALL F_printSpace
	
	LD DE, strChosenDoor		; display what is behind the chosen door
	LD BC, CHOSEN_DOOR_LEN		; ...
	CALL F_printStr				; ...
	LD A, (randDoorNum)			; load offset into A
	LD B, 0						; store in BC
	LD C, A						; ...
	LD HL, doors				; HL points at the 'doors' array
	ADD HL, BC					; add offset from BC to HL
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	LD A, (HL)					; A now contains the CHAR behind the door
	RST 16
	
	CALL F_printNewLine			; end the current display line	
	;CALL F_printNewLine			; end the current display line	

	RET

; ******************************************************************

F_displayState2:

	LD DE, strLoop				; Print "Loop="
	LD BC, LOOP_LEN				; ...
	CALL F_printStr				; ... done
	LD A, (loopCounter)			; display the loop counter value
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW					; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	CALL F_printSpace
	CALL F_printSpace

	LD DE, strRandDoor
	LD BC, RAND_DOORS_LEN
	CALL F_printStr
	LD A, (randDoorNum)			; display random door number
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW					; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine	

	CALL F_printSpace
	CALL F_printSpace
	
	LD DE, strCarPosn			; display car position
	LD BC, CAR_POSN_LEN			; ...
	CALL F_printStr				; ...
	LD A, (carDoorNum)			; ...
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	CALL F_printSpace
	CALL F_printSpace
	
	LD DE, strChosenDoor		; display what is behind the chosen door
	LD BC, CHOSEN_DOOR_LEN		; ...
	CALL F_printStr				; ...
	LD A, (randDoorNum)			; load offset into A
	LD B, 0						; store in BC
	LD C, A						; ...
	LD HL, doors				; HL points at the 'doors' array
	ADD HL, BC					; add offset from BC to HL
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	LD A, (HL)					; A now contains the CHAR behind the door
	RST 16
	
	CALL F_printSpace
	CALL F_printSpace
	
	LD DE, strGoatDoor			; display goat position
	LD BC, GOAT_DOOR_LEN			; ...
	CALL F_printStr				; ...
	LD A, (goatDoorNum)			; ...
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	CALL F_printNewLine			; end the current display line	
	CALL F_printNewLine			; end the current display line	

	RET

; ******************************************************************
F_displayResults:

	LD DE, strStick				; Print "Stick="
	LD BC, STICK_LEN			; ...
	CALL F_printStr				; ... done
	LD A, (stick)				; display the loop counter value
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW					; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine	
	LD DE, strOutOf				; display ' out of '
	LD BC, OUT_OF_LEN			; ...
	CALL F_printStr				; ...
	LD A, NUM_ITERATIONS		; display the # of iterations
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	
	LD DE, strEquals
	LD BC, EQUALS_LEN
	CALL F_printStr				; display ' = '
	
	; Enter with BC holding the denominator and DE the numerator
	; Exit with BC holding the Percentage value (0-100)
	LD BC, NUM_ITERATIONS
	LD DE, (stick)
	LD D, 0
	CALL F_calculatePercentage	
	;LD B,0
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; display the percentage for 'stick'
	
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	LD A, PERCENT
	RST 16						; display '%'
	CALL F_printNewLine			; end the current display line
	
	LD DE, strSwap				; Print "Swap="
	LD BC, SWAP_LEN				; ...
	CALL F_printStr				; ... done
	CALL F_printSpace
	LD A, (swap)				; display the loop counter value
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	LD DE, strOutOf				; display ' out of '
	LD BC, OUT_OF_LEN			; ...
	CALL F_printStr				; ...
	
	LD A, NUM_ITERATIONS		; display the # of iterations
	LD C, A						; ...
	LD B, 0						; ...
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; using a ROM routine
	
	LD DE, strEquals
	LD BC, EQUALS_LEN
	CALL F_printStr				; display ' = '
	
	; Enter with BC holding the Total Amount and DE the Given Amount
	; Exit with C holding the Percentage value (0-100)	
	LD BC, NUM_ITERATIONS
	LD DE, (swap)
	LD D, 0
	CALL F_calculatePercentage
	;LD B,0
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	CALL 6683					; display the percentage for 'swap'
	
	LD A, YELLOW				; in yellow ink
	LD (23695),A				; ATTR-T
	LD A, PERCENT
	RST 16						; display '%'
	
	CALL F_printNewLine			; end the current display line
	CALL F_printNewLine			; end the current display line
	
	LD DE, strEndMessage		; display prompt to run again
	LD BC, END_MESSAGE_LEN
	CALL F_printStr
	
	RET
	
; ******************************************************************
;{ Display a message with 	DE=string address,
;							BC=string length
;							
F_printStr:
	LD A,GREEN			; in green ink
	LD (23695),A		; ATTR-T
	CALL $203C			; call ROM routine
	RET
;}
	
; ******************************************************************
;{ Print a blank line
;							
F_printNewLine:
	LD A, NEWLINE		; new line ASCII code
	RST 16				; print it
	RET
	
	
; ******************************************************************
;{ Print a space character
;							
F_printSpace:
	LD A, SPACE					; space character
	RST 16						; print space
	RET
	
	
; ******************************************************************
; Routine to calculate an integer percentage
;
; Enter with BC holding the denominator and DE the numerator
; Exit with BC holding the Percentage value (0-100)
;
F_calculatePercentage:
	PUSH BC				; store denominator
	
	LD B, D				; put numerator on calc's stack
	LD C, E				; ...
	CALL STACK_BC		; ... done
	LD BC, 100			; %'s always out of 100
	CALL STACK_BC
	RST #28				; start ROM calculator
	DEFB #04 			; tell it we are multiplying
	DEFB #38 			; end ROM call
	
	POP BC				; restore denominator
	CALL STACK_BC
	RST #28				; start ROM calculator
	DEFB #05 			; tell it we are dividing
	DEFB #38 			; end ROM call
	CALL FP_TO_BC		; copy FP number to BC
	RET