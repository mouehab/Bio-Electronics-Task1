#include "C8051F020.INC"


;Initializations
ORG 00H
CLR A
S_SWITCH	EQU	P3.6
H_SWITCH 	EQU	P3.7
MOV B,#7
MOV DPTR,#40H
CALL Serial_Init


;First Char
CALL Serial_Read
MOV R1,A
MOV R3,A
;Fetching the 7-seg value
MOVC A,@A+DPTR
MOV P1,A
CLR A


;Second Char
CALL Serial_Read
MOV R2,A
MOV R4,A
;Fetching the 7-seg value
MOVC A,@A+DPTR
MOV P2,A


;=====================================================================================================================
 
MAIN:
;Green LED 
			SETB P3.5
			CLR P3.4 
;The Decrementing Process
  		CALL Dec_Right
			CALL Dec_Left

;Getting Original Values
			CALL Get_Original_Values

;Red LED
			SETB P3.4
			CLR P3.5

;The Decrementing Process
  		CALL Dec_Right
			CALL Dec_Left

;Getting Original Values
			CALL Get_Original_Values


	   	JMP MAIN	


;=======================================================================================================================


DELAY: 
			MOV R6,B
	   	MOV R5,#0
      MOV R7,#0
LOOP:
		  DJNZ R7,LOOP
	   	DJNZ R5,LOOP
	   	DJNZ R6,LOOP
      RET


;Common Cathode Look-up Table
ORG 40H
DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH


Serial_Init:
	;Set timer 1 mode to 8-bit Auto-Reload
	MOV TMOD,#20H
	;Enable reception
	;Set Serial port mode to 8-bit UART
	MOV SCON0,#50H
	;Set baudrate to 9600 at 11.0592MHz
	MOV TH1,#0FDH
	MOV TL1,#0FDH
	;Start Timer
	SETB TR1					
	RET

	
Serial_Read:
	;Wait for Receive interrupt flag
	JNB RI,Serial_Read
	;Then read data from SBUF
	MOV A,SBUF0
	;Convert ASCII into Real number
	SUBB A,#30H
	;If flag is set then clear it and clear acc
	CLR RI
	
	RET


Dec_Left:
;Making sure the number is not 0 because i dont want to decrement 0 
	CJNE R1, #0, Left_Dec
	RET

Left_Dec:
	CALL DELAY
;Decrement the Left Seven-seg by 1
	DEC R1
	MOV A, R1
	MOVC A, @A+DPTR
	MOV P1,A 
; Decrement the Right seven-seg by 10
	MOV R2, #9
	MOV A, R2
	MOVC A, @A+DPTR
	MOV P2,A 
	CALL Dec_Right
;Repeating the previous process until i reacch 00
	CJNE R1, #0, Left_Dec
	RET

Dec_Right:
;Making sure the number is not 0 because i dont want to decrement 0 
	CJNE R2, #0, Right_Dec
	RET

Right_Dec:
; Decrementing the Right seven-seg until i reach 0
	CALL DELAY
	DEC R2
	MOV A, R2
	MOVC A, @A+DPTR
	MOV P2,A 

;Checking the buttons
	CALL SLOW
	CALL HURRY
REPEAT:
	CJNE R2, #0, Right_Dec
	RET

Get_Original_Values:
;Getting the Original Value of the Right Digit Back
	MOV A,R3
	MOV R1,A
;Fetching the 7-seg value Again
	MOVC A,@A+DPTR
	MOV P1,A

;Getting the Original Value of the Left Digit Back
	MOV A,R4
	MOV R2,A
;Fetching the 7-seg value Again
	MOVC A,@A+DPTR
	MOV P2,A

	RET

SLOW:						
;SUBROUTINE TO MONITOR SWITCH STATUS
	JB	 S_SWITCH, HURRY		;CHECK IF SWITCH IS PRESSED OR NOT
	INC  B					    ;IF SWITCH IS PRESSED, CHANGE THE FREQUENCY			    
	RET
		
HURRY:						
	
	JB	 H_SWITCH, REPEAT
	DEC  B
	MOV	 A,B
	CJNE A,#0, REPEAT
	INC B				    
	RET																											 


END