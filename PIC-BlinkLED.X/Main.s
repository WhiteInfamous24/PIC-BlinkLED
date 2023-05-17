#include "xc.inc"

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

; starting position of the program < -pRESET_VECT=0h >
psect RESET_VECT, class=CODE, delta=2
RESET_VECT:
    GOTO    setup

; memory location to go when a interrupt happens < -pINT_VECT=4h >
psect INT_VECT, class=CODE, delta=2
INT_VECT:
    
    ; save context
    MOVWF   W_TMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TMP
    
    ; IMPLEMENT METHOD INTERRUPTION
    
    ; return previous context
    SWAPF   STATUS_TMP, W
    MOVWF   STATUS
    SWAPF   W_TMP, F
    SWAPF   W_TMP, W
    
    RETFIE

; program variables
W_TMP	    EQU 0x20
STATUS_TMP  EQU	0x21
CTER_0	    EQU 0X22
CTER_1	    EQU 0X23
CTER_2	    EQU 0X24

; program setup
setup:
    
    ; PORTB configuration
    BANKSEL TRISB		; select TRISB memory bank
    MOVLW   0b00000000		; clear TRISB vector, to put all the pin in output mode
    MOVWF   TRISB
    BANKSEL ANSELH		; set PORTB in digital mode
    CLRF    ANSELH
    
    ; select PORTB memory bank
    BANKSEL PORTB

; main program loop
main:
    
    ; put PORTB in HIGH
    MOVLW   0b00000000		; put RB0 pin in HIGH
    MOVWF   PORTB
    
    ; delay program
    CALL    delay
    
    ; put PORTB in LOW
    MOVLW   0b00000001		; put RB0 pin in LOW
    MOVWF   PORTB
    
    ; delay program
    CALL    delay
    
    GOTO    main

; delay subroutine (using instructions)
delay:
    MOVLW   0x05		; initial value of mayor loop
    MOVWF   CTER_0
loop_2:
    MOVLW   0xFF		; initial value of medium loop
    MOVWF   CTER_1
loop_1:
    MOVLW   0xFF		; initial value of minor loop
    MOVWF   CTER_2
loop_0:
    DECFSZ  CTER_2
    GOTO    loop_0
    DECFSZ  CTER_1
    GOTO    loop_1
    DECFSZ  CTER_0
    GOTO    loop_2
    
    RETURN

END RESET_VECT