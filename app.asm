; ALLOWS ONE TO START THE APPLICATION WITH RUN
; SYS 2064
*=$0801 
         BYTE $0C, $08, $0A, $00, $9E, $20, $32, $30, $36, $34, $00, $00, $00, $00, $00

CIA1IRQ         = $DC0D
RASTERREG       = $D011
IRQRASTER       = $D012
IRQADDRMSB      = $0314
IRQADDRLSB      = $0315
IRQCTRL         = $D01A
IRQFLAG         = $D019
IRQFINISH       = $EA31
PORTB           = $DC01

F_LSB1          = $D400
F_MSB1          = $D401
CTRL1           = $D404
ATT_DEC1        = $D405
SUS_REL1        = $D406
VFMODE          = $D418


INIT    LDA #%01111111 ; SWITCH OFF CIA-1 INTERRUPTS
        STA CIA1IRQ

        AND RASTERREG ; CLEAR VIC RASTER REGISTER
        STA RASTERREG

        LDA #250 ; SETUP PLAY INTERRUPT AT RASTER LINE 250 FOR TIMING
        STA IRQRASTER
        LDA #<PLAYIRQ
        STA IRQADDRMSB
        LDA #>PLAYIRQ
        STA IRQADDRLSB

        LDA #%00000001 ; RE-ENABLE RASTER INTERRUPTS ONLY AFTER SETUP
        STA IRQCTRL

        ; SETTING UP VOICE 1
        ; AFTER THESE STEPS, A SOUND CAN BE HEARD

        ; INITIALIZE FREQUENCIES. NOTE "A-3" ACCORDING TO http://sta.c64.org/cbm64sndfreq.html
        LDA #$8F
        STA F_LSB1
        LDA #$0E
        STA F_MSB1

        ; SET SAW TOOTH VOICE (BIT 5) AND OPEN GATE (BIT 0)
        LDA #%00100001
        STA CTRL1

        ; SET A SLOW ATTACK (7-4) AND A DECAY (3-0)
        LDA #%11110000
        STA ATT_DEC1

        ; SET SUSTAIN (7-4) AND RELEASE (3-0), SOME VALUES
        LDA #%11001000
        STA SUS_REL1

        ; SET FILTERS (7-4) AND VOLUME TO 11 (3-0)
        LDA #%00001111
        STA VFMODE

WAIT    LDA PORTB ; WAIT UNTIL SPACEBAR IS PRESSED
        CMP #$EF 
        BNE WAIT

CLEAN   LDA #0 ; CLEAR SID VOLUME AND FILTERS,
        STA VFMODE
        RTS ; AND THEN QUIT

PLAYIRQ ; DO SOME WEIRD STUFF WITH THE FREQUENCIES EVERY CYCLE
        INC F_LSB1
        LDA #127 ; THIS SOUNDS NICE
        ADC F_MSB1
        STA F_MSB1

        ASL IRQFLAG ; RESET IRQ FLAG
        JMP IRQFINISH ; LET MACHINE HANDLE OTHER IRQS

