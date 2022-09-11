;**************** 7-segment Display ************* 
; 4 bit Final count - P0.7 down to P0.4 in R1
; R0 is used as counter.   
; 2-bit Control input S1, S0 (P0.1, P0.0) in R2
; P2.7 downto P2.0 interfaced to 7-segment Display 
;S1S0 -> 00 - UP Count
;S1S0 -> 01 - Down Count
;S1S0 -> 1x - Stop counting
;R4 and R5 for Delay
;********************************************
        ORG		00h
		SJMP	main
        
        ORG     40h
Seg7:   db  0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

;************** Main routine begins ***********
		ORG		64h
MAIN:
        ACALL   INIT
CONTINUE:
        ACALL   HEX_7seg
        ACALL   DISP_RES
        ACALL   READ_DATA
        ACALL   COUNT
        ACALL   DELAY
        SJMP    CONTINUE
;************** Main routine ends ***********

INIT:
        ; Configure Port 0 as input
        MOV     P0, #0xFF
        MOV     R0, #0       
        RET
READ_DATA:
        ; Read 4-bit Final Count value (N) (Port 0.7 to 0.4) in to R1 and 
        ; Control input (Port 0.0, 0.1) to R2. 
        MOV     A, P0
        MOV     R3, A
        ANL     A, #0x03
        MOV     R2, A
        MOV     A, R3
        ANL     A, #0xF0
        SWAP    A
        MOV     R1, A
        RET
        
COUNT:
        ;As per the control inputs in R2 and F value in R1
        ; Count R0 value UP or down. 
        MOV     A, R1
        DEC     A
        CJNE    R2, #0x0, CNT_DN
        SUBB    A, R0
        JNC     UP1
        MOV     R0, #0xFF
UP1:    INC     R0
        RET

CNT_DN:
        CJNE    R2, #1, CNT_STOP
        INC     A
        SUBB    A, R0
        JC      DN1
        MOV     R0, #0x10
DN1:    DEC     R0
        RET
        
CNT_STOP:
        RET
        
HEX_7seg:
        ;Convert hex value in R0 to 7-seg equivalent - Hex to 7segment decoder. 
        ;store the 7-segment equivalent in to accumulator. 
        
        MOV     DPTR, #Seg7
        MOV     A, R0
        MOVC    A, @A+DPTR
        RET
        
DISP_RES:
        ;Display the result on LEDs connected to Port 2. 
        MOV     P2, A
        RET
        
DELAY:
        DJNZ    R4, DELAY
        DJNZ    R5, DELAY
        RET
        
        END
        
        
