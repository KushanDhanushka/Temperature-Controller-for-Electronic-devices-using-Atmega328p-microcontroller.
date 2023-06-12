;
; Temperature Controller by Assembly.asm
;
; Created : 11/29/2022 11:14:49 PM
; By : H.K. Kushan Dhanushka

.include "M328PDEF.INC" 

.org 0x000					; starts from 0x000

main:

	LDI R21, 0xF8
    OUT DDRB, R21       ; (column lines C1,C2,C3 as i/p AND RS,E,PWM (Timer2) O/P)
    LDI R20, 0xFF       
    OUT DDRD, R20       ; O/P (row lines R1,R2,R3,R4, LCD data )  
	CBI DDRC, 0         ; set pin PC0 as i/p for ADC0

	;Timer 2 - PWM config. 
	ldi r16, 0b10000011    ; Set WGM bits to 0b011
	sts TCCR2A, r16        ; Write to TCCR2A register
	ldi r16, 0b00000101    ; Set prescaler value to 0b100
	sts TCCR2B, r16        ; Write to TCCR2B register
	ldi r16, 0b00000010 ; Enable Output Compare Match interrupt
	sts TIMSK2, r16        ; Write to TIMSK2 register
	
	; Counter for arithmatics    
	LDI R24, 0x00       ; COUNTER

	; Data storaging registers
	CLR R25
	CLR R26
	CLR R27
	CLR R28  
    ;-----------------------------------------------------------

; KEYPAD CODE HERE!!!

init_keypad:
	CBI PORTD,0
	CBI PORTD,1
	CBI PORTD,2
	CBI PORTD,3
	SBI PORTB,0
	SBI PORTB,1
	SBI PORTB,2

    ;-----------------------------------------------------------
wait_release:
	NOP                    ; delay
	NOP
	NOP
	NOP
	IN  R21, PINB          ;read key pins 
	ANDI R21, 0x07         ;mask unsed bits
	CPI R21, 0x07          ;equal if no keypress
	BRNE wait_release      ;do again until keys released
	;-----------------------------------------------------------
wait_keypress:
    NOP                    ; delay
	NOP
	NOP
	NOP
	NOP
	NOP
    IN R21, PINB           ;read key pins
    ANDI R21, 0x07         ;mask unsed bits
    CPI R21, 0x07          ;equal if no keypress
    BREQ wait_keypress     ;keypress? no, go back & check
	INC R24
    ;-----------------------------------------------------------;ground row 1
	CBI PORTD,0
	SBI PORTD,1
	SBI PORTD,2
	SBI PORTD,3

    NOP						; delay 
	NOP
	NOP
	NOP
	NOP
	NOP
    IN R21, PINB           ;read all columns
    ANDI R21, 0x07         ;mask unsed bits
    CPI R21, 0x07          ;equal if no key
    BRNE row1_col          ;row 1, find column // new function

    ;-----------------------------------------------------------;ground row 2
	SBI PORTD,0
	CBI PORTD,1
	SBI PORTD,2
	SBI PORTD,3

    NOP
	NOP
	NOP
	NOP
	NOP
	NOP
    IN R21, PINB            ;read all columns
    ANDI R21, 0x07			;mask unsed bits
    CPI R21, 0x07			;equal if no key
    BRNE row2_col           ;row 2, find column // nf 2

    ;-----------------------------------------------------------;ground row 3
	SBI PORTD,0
	SBI PORTD,1
	CBI PORTD,2
	SBI PORTD,3

    NOP
	NOP
	NOP
	NOP
	NOP
	NOP
    IN R21, PINB			;read all columns
    ANDI R21, 0x07			;mask unsed bits
    CPI R21, 0x07			;equal if no key
    BRNE row3_col			;row 3, find column // nf 3

    ;-----------------------------------------------------------;ground row 4
    SBI PORTD,0
	SBI PORTD,1
	SBI PORTD,2
	CBI PORTD,3

    NOP
	NOP
	NOP
	NOP
	NOP
	NOP
    IN R21, PINB			;read all columns
    ANDI R21, 0x07			;mask unsed bits
    CPI R21, 0x07			;equal if no key
    BRNE row4_col			;row 4, find column // nf 4 

;---------------------------------------------------------------
;Finding the column

row1_col:
      
    CPI R21, 0b00000110    
	BREQ Load_1
	CPI R21, 0b00000101   
	BREQ Load_2
	CPI R21, 0b00000011    
	BREQ Load_3

row2_col:
      
    CPI R21, 0b00000110    
	BREQ Load_4
	CPI R21, 0b00000101   
	BREQ Load_5
	CPI R21, 0b00000011    
	BREQ Load_6
	
row3_col:
     
    CPI R21, 0b00000110    
	BREQ Load_7
	CPI R21, 0b00000101   
	BREQ Load_8
	CPI R21, 0b00000011    
	BREQ Load_9

row4_col:
     
    CPI R21, 0b00000110    
	BREQ Load_10
	CPI R21, 0b00000101   
	BREQ Load_0
	CPI R21, 0b00000011   
	BREQ Load_11

; Load coressponding values

Load_1:
	LDI R16,0b00000001
	RCALL SAVE

	 
Load_2:
	LDI R16,0b00000010
	RCALL SAVE 
	
	
Load_3:
	LDI R16,0b00000011
	RCALL SAVE 
	
	 
Load_4:
	LDI R16,0b00000100
	RCALL SAVE
 
Load_5:
	LDI R16,0b00000101
	RCALL SAVE  
	 
Load_6:
	LDI R16,0b00000110
	RCALL SAVE

Load_7:
	LDI R16,0b00000111
	RCALL SAVE 

Load_8:
	LDI R16,0b00001000
	RCALL SAVE  
	 
Load_9:
	LDI R16,0b00001001
	RCALL SAVE   
	  
Load_10:
	LDI R16,0b00001010
	RCALL SAVE 
	
Load_0:
	LDI R16,0b00000000
	RCALL SAVE    

Load_11:
	LDI R16,0b00001011
	RCALL SAVE

; store values into registers.

SAVE:	
	CPI R24, 0x01
	BREQ Firstdigit
	CPI R24, 0x02
	BREQ Seconddigit
	CPI R24, 0x03
	BREQ Thirddigit
	CPI R24, 0x04
	BREQ Finish

Firstdigit:
	MOV R25, R16
	RJMP init_keypad
Seconddigit:
	MOV R26, R16
	RJMP init_keypad
Thirddigit:
	MOV R28, R16
	RJMP init_keypad
Finish:
	CPI R16, 0b00001011
	BRNE RESETALL
	RCALL delay_sec     ;delay 0.5s
	RJMP TEMP ; go to next part
	
RESETALL: ; if put wrong value
	RJMP main

;===============================================================

TEMP:                   ; ADC config.
    LDI R20, 0x00		;AREF, right-justified data, ADC0
    STS ADMUX, R20
    LDI R20, 0x87		;enable ADC, ADC prescaler CLK/128
    STS ADCSRA, R20
;------------------------------------------------------------------

LCD_write:
	CBI PORTB, 4			;EN = 0
    RCALL delay_ms			;wait for LCD power on
    ;--------------------------------------------------
    RCALL LCD_init			;subroutine to initialize LCD
    ;--------------------------------------------------
	LDI R19, 0b00110000     ;constant to get ASCII chars 0 to 9
	;--------------------------------------------------
	; to display reference temperature

    ADD R25, R19			;MSD in ASCII dec
    MOV R16, R25
    RCALL data_wrt			;display MSD on LCD
    ;-----------------------------------------------------------------
    ADD R26, R19			;mid digit in ASCII dec
    MOV R16, R26
    RCALL data_wrt			;display mid digit on LCD
    ;-----------------------------------------------------------------
	ADD R28, R19			;LSD in ASCII dec
    MOV R16, R28
    RCALL data_wrt			;display LSD on LCD
    ;-----------------------------------------------------------------
  
    LDI R16, 0xC0			;cursor beginning of 2nd line
    RCALL command_wrt
    RCALL delay_ms
    ;--------------------------------------------------
	; for further arithmetics
	SUB R25,R19
	SUB R26,R19
	SUB R28,R19

	CLR R29					; for the comparison

    LDI R17, 0b11001000
; save the ref. temp in to register in binary
m1:
	CPI R25,1
	BRLO m2
	ADD R29, R17
	DEC R25
	RJMP m1
m2:
	LDI R17, 0b00010100
	CPI R26,1
	BRLO m3
	ADD R29, R17
	DEC R26
	RJMP m2

m3:
	LDI R17, 0b00000010
	CPI R28,1
	BRLO read_ADC
	ADD R29, R17
	DEC R28
	RJMP m3
;====================================================================
; ADC conv.
;====================================================================
	;--------------------------------------------------
read_ADC:
    LDI R20, 0xC7		;set ADSC in ADCSRA to start conversion
    STS ADCSRA, R20
	;----------------------------------------------------------------
wait_ADC:
    LDS R21, ADCSRA		;check ADIF flag in ADCSRA
    SBRS R21, 4			;skip jump when conversion is done (flag set)
    RJMP wait_ADC		;loop until ADIF flag is set
    ;----------------------------------------------------------------
    LDI R17, 0xD7		;set ADIF flag again
    STS ADCSRA, R17		;so that controller clears ADIF
    ;----------------------------------------------------------------

	LDS R16, ADCL		;get low-byte result from ADCL
	LDS R28, ADCH		;get high-byte result from ADCH
	MOV R23, R16        ; for the comparison
	LSR R16
    ;----------------------------------------------------------------
	; tho display current temperature.

    CLR R25           ;set counter1, initial value 0
    CLR R26           ;set counter2, initial value 0
	CLR R28
	
	;arithmatic operations

	CPI   R16, 228    ;compare R16 with 228
    BRSH  adjust      ;jump if R16 >= 128
    ;----------------------------------------------------------------
l7: CPI R16, 100      ;compare R16 with 100
	BRLO l8           ;jump when R16 < 100
    INC R25           ;increment counter1 by 1
    SUBI R16, 100     ;R16 = R16 - 100
    RJMP l7
    ;-----------------------------------------------------------------
l8: CPI R16, 10       ;compare R16 with 10
    BRLO l9           ;jump when R16 < 10
    INC R26           ;increment counter2 by 1
    SUBI R16, 10      ;R16 = R16 - 10
    RJMP l8
    ;-----------------------------------------------------------------
l9:	MOV R28, R16      ;1
    ;-----------------------------------------------------------------
dsp:
    ADD R25, R19      ;MSD in ASCII dec
    MOV R16, R25
    RCALL data_wrt    ;display MSD on LCD
    ;-----------------------------------------------------------------
    ADD R26, R19      ;mid digit in ASCII dec
    MOV R16, R26
    RCALL data_wrt    ;display mid digit on LCD
    ;-----------------------------------------------------------------
	ADD R28, R19      ;LSD in ASCII dec
    MOV R16, R28
    RCALL data_wrt    ;display LSD on LCD
    ;-----------------------------------------------------------------
	RCALL delay_ms
    ;-----------------------------------------------------------------
    LDI R16, 0xC0     ;force cursor beginning of 2nd line
    RCALL command_wrt
    RCALL delay_ms
	RJMP pwm
    ;-----------------------------------------------------------------
adjust:
    CPI   R16, 128    ;compare R16 with 128 when R16 >= 228
    BRLO l8           ;jump when R16 < 128
    INC R25           ;increment counter1 by 1
    SUBI R16, 100     ;R16 = R16 - 100
    RJMP adjust
	;-----------------------------------------------------------------

;====================================================================

; pwm value setup

;====================================================================

pwm:	
	CP R23, R29
	BRMI nopwm
	SUB	R23, R29
	CPI R23, 0
	BREQ nopwm

	CPI R23, 1
	BREQ pwmlow
	CPI R23, 2
	BREQ pwmlow
	CPI R23, 3
	BREQ pwmlow
	CPI R23, 4
	BREQ pwm25
	CPI R23, 5
	BREQ pwm25
	CPI R23, 6
	BREQ pwm25

	CPI R23, 7
	BREQ pwm50
	CPI R23, 8
	BREQ pwm50
	CPI R23, 9
	BREQ pwm50
	CPI R23, 10
	BREQ pwm50
	CPI R23, 11
	BREQ pwm50
	CPI R23, 12
	BREQ pwm50

	CPI R23, 13
	BREQ pwm75
	CPI R23, 14
	BREQ pwm75
	CPI R23, 15
	BREQ pwm75
	CPI R23, 16
	BREQ pwm75
	CPI R23, 17
	BREQ pwm75
	CPI R23, 18
	BREQ pwm75
	CPI R23, 19
	BREQ pwm75

	CPI R23, 20
	BRSH pwmfull
	RJMP  wait_ADC      ;go back & get another ADC reading
;====================================================================


nopwm:
	ldi r16, 0				; Set PWM value to r16
	sts OCR2A, r16			; Write to OCR2A register
	RJMP  wait_ADC

pwmlow:
	ldi r16, 32				; Set PWM value to r16
	sts OCR2A, r16			; Write to OCR2A register	
	RJMP  wait_ADC

pwm25:
	ldi r16, 64				; Set PWM value to r16
	sts OCR2A, r16			; Write to OCR2A register	
	RJMP  wait_ADC

pwm50:
	ldi r16, 128			; Set PWM value to r16
	sts OCR2A, r16			; Write to OCR2A register
	RJMP  wait_ADC

pwm75:
	ldi r16, 192			; Set PWM value to r16
	sts OCR2A, r16			; Write to OCR2A register
	RJMP  wait_ADC

pwmfull:
	ldi r16, 254			; Set PWM value to r16
	sts OCR2A, r16			; Write to OCR2A register
	RJMP wait_ADC
;====================================================================

; LCD dispaly functions.
;====================================================================

LCD_init:
    LDI R16, 0x33			;init LCD for 4-bit data
    RCALL command_wrt		;send to command register
    RCALL delay_ms
    LDI R16, 0x32			;init LCD for 4-bit data
    RCALL command_wrt
    RCALL delay_ms
    LDI R16, 0x28			;LCD 2 lines, 5x7 matrix
    RCALL command_wrt
    RCALL delay_ms
    LDI R16, 0x0C			;disp ON, cursor OFF
    RCALL command_wrt
    LDI R16, 0x01			;clear LCD
    RCALL command_wrt
    RCALL delay_ms
    LDI R16, 0x06			;shift cursor right
    RCALL command_wrt
    RET  
;====================================================================
command_wrt:
    MOV R27, R16
    ANDI R27, 0xF0		;mask low nibble & keep high nibble
    OUT PORTD, R27		;o/p high nibble to port D
    CBI PORTB, 5		;RS = 0 for command
    SBI PORTB, 4		;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI PORTB, 4		;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us
    ;-------------------------------------------------------
    MOV R27, R16
    SWAP R27			;swap nibbles
    ANDI R27, 0xF0		;mask low nibble & keep high nibble
    OUT PORTD, R27		;o/p high nibble to port D
    SBI PORTB, 4		;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI PORTB, 4		;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us
    RET
;====================================================================
data_wrt:
    MOV R27, R16
    ANDI R27, 0xF0		;mask low nibble & keep high nibble
    OUT PORTD, R27		;o/p high nibble to port D
    SBI PORTB, 5		;RS = 1 for data
    SBI PORTB, 4		;EN = 1
    RCALL delay_short   ;make wide EN pulse
    CBI PORTB, 4		;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay 100us
    ;-------------------------------------------------------
    MOV R27, R16
    SWAP R27			;swap nibbles
    ANDI R27, 0xF0		;mask low nibble & keep high nibble
    OUT PORTD, R27		;o/p high nibble to port D
    SBI PORTB, 4		;EN = 1
    RCALL delay_short   ;widen EN pulse
    CBI PORTB, 4		;EN = 0 for H-to-L pulse
    RCALL delay_us      ;delay in micro seconds
    RET
;====================================================================

; time delay functions!!!

;====================================================================

delay_short:            ;short delay, 3 cycles
	NOP
    NOP
    RET
;--------------------------------------------------
delay_us:               ;delay in us
    LDI R20, 90
l1: RCALL delay_short
    DEC R20
    BRNE l1
    RET
;--------------------------------------------------
delay_ms:               ;delay in ms
    LDI R21, 40
l2: RCALL delay_us
    DEC R21
    BRNE l2
    RET
;----------------------------------------------------------------
delay_sec:              ;nested loop subroutine (max delay 3.11s)
    LDI R20, 255		;outer loop counter 
l3: LDI R21, 255		;mid loop counter
l4: LDI R22, 40			;inner loop counter to give 0.5s delay
l5: DEC R22				;decrement inner loop
    BRNE l5				;loop if not zero
    DEC R21				;decrement mid loop
    BRNE l4				;loop if not zero
    DEC R20				;decrement outer loop
    BRNE l3				;loop if not zero
    RET                 ;return to caller
;====================================================================
; END OF THE CODE !!!!!
