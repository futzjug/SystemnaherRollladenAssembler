; Mapping
; inputs
EIN 	EQU 20h
B_UP 	EQU EIN.0
B_DOWN 	EQU EIN.1
C_IS_UP EQU EIN.3
C_IS_DOWN EQU EIN.4

; Flags
FLAGS 	EQU 28h
F_B_PRESSED EQU FLAGS.0
F_CLOCK_UP EQU FLAGS.1
F_CLOCK_DOWN EQU FLAGS.2

; outputs
AUS 	EQU P3
M_UP 	EQU AUS.0
M_DOWN	EQU AUS.1

; LED Matrix
VERT_ALWAYS_ON EQU AUS.5
UPPER_LEDS EQU AUS.6
LOWER_LEDS EQU AUS.7


; INIT
cseg at 0h
ajmp init
cseg at 100h

; Interrupt
ORG 0bh
call timer
reti

; INIT
ORG 20h
init:
mov IE, #10010010b
mov tmod, #00000010b
mov r7, #17h
mov r6, #25h

; timer speed
mov tl0, #14h
mov th0, #50h

; clear inputs (buttons, contacts and motor)
;mov P0, #0h
mov P3, #0h

; setze dauerhaft 1
SETB VERT_ALWAYS_ON

; start timer
starttimer:
setb tr0; start timer0
ajmp anfang

call zeigen

;---------------------------
; Hauptprogramm
anfang:
mov EIN, P0

CLR C
ORL C, /B_UP
ORL C, F_CLOCK_UP

ANL C, /F_B_PRESSED
ANL C, /M_DOWN
ANL C, C_IS_UP

JNC S1
SETB M_UP
CLR F_CLOCK_UP

S1:
SETB C
ANL C, /B_DOWN
ANL C, /F_B_PRESSED

ORL C, /C_IS_UP

ANL C, M_UP

JNC S2
CLR M_UP
SETB F_B_PRESSED

S2:
CLR C
ORL C, /B_DOWN
ORL C, F_CLOCK_DOWN

ANL C, /F_B_PRESSED
ANL C, /M_UP
ANL C, C_IS_DOWN

JNC S3
SETB M_DOWN
CLR F_CLOCK_DOWN

S3:
SETB C
ANL C, /B_UP
ANL C, /F_B_PRESSED

ORL C, /C_IS_DOWN 

ANL C, M_DOWN

JNC S4
CLR M_DOWN
SETB F_B_PRESSED

S4:
CLR C
ORL C, /B_UP
ORL C, /B_DOWN
MOV F_B_PRESSED, C

jnb tr0, da
ajmp anfang
da:
call display
ajmp anfang
;------------------------------
; unterprogramme
;



;----------------------
; timer
;
timer:
inc r1
; timer repeats
cjne r1, #05h, nuranzeige
mov r1, #00h
call countdown
ret

nuranzeige:
call zeigen
ret

countdown:
; Uhrzeit Check -> Hochfahren um 23:45
cjne r6, #26h, clockDown ; check minuten = 38
cjne r7, #17h, clockDown ; check stunden = 23
SETB F_CLOCK_UP

clockDown:
; Uhrzeit Check -> Runterfahren um 23:48
cjne r6, #28h, clock ; check minuten = 40
cjne r7, #17h, clock ; check stunden = 23
SETB F_CLOCK_DOWN

clock:
cjne r6, #3bh, minuten
cjne r7, #17h, stunden
mov r6, #00h
mov r7, #00h
jmp zeigen

stunden:
mov r6, #00h
inc r7
call zeigen
ret
minuten:
inc r6
call zeigen
ret

zeigen:
; update LED Matrix
CLR UPPER_LEDS
CLR LOWER_LEDS

jnb M_UP, zeigenLower
SETB UPPER_LEDS

zeigenLower:
jnb M_DOWN, zeigenClock
SETB LOWER_LEDS

zeigenClock:
; update clock
mov DPTR, #table
mov a, R6
mov b, #0ah
div ab
mov R0, a
movc a,@a+dptr
mov r3, a
mov a, r0
xch a,b
movc a, @a+dptr
mov r2, a
;----------------
mov a, R7
mov b, #0ah
div ab
mov R0, a
movc a,@a+dptr
mov r5, a
mov a, r0
xch a,b
movc a, @a+dptr
mov r4, a
call display
ret

display:
mov P2, R2
clr P1.0
setb P1.0

mov P2, R3
clr P1.1
setb P1.1

mov P2, R4
clr P1.2
setb P1.2

mov P2, R5
clr P1.3
setb P1.3

ret

org 300h
table:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b

end

