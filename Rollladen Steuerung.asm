; Mapping
; inputs
EIN 	EQU 20h
B_UP 	EQU EIN.0
B_DOWN 	EQU EIN.1
C_IS_UP EQU EIN.3
C_IS_DOWN EQU EIN.4

; outputs
AUS 	EQU P3
M_UP 	EQU AUS.0
M_DOWN	EQU AUS.1


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
mov tl0, #0ffh
mov th0, #0h

; clear inputs (buttons, contacts and motor)
;mov P0, #0h
;mov P3, #0h

; start timer
starttimer:
setb tr0; start timer0
ajmp anfang

call zeigen

;---------------------------
; Hauptprogramm
anfang:
mov EIN, P0

mov C, B_UP
ANL C, /M_DOWN
ANL C, /C_IS_UP
JNC S1
SETB M_UP

S1:
mov C, B_DOWN
ORL C, C_IS_UP
JNC S2
CLR M_UP

S2:
mov C, B_DOWN
ANL C, /M_UP
ANL C, /C_IS_DOWN
JNC S3
SETB M_DOWN

S3:
mov C, B_UP
ORL C, C_IS_DOWN 
JNC S4
CLR M_DOWN

S4:
mov C, M_DOWN

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
cjne r1, #09h, nuranzeige
mov r1, #00h
call countdown
ret

nuranzeige:
call zeigen
ret

countdown:
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

