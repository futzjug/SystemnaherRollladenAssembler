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
mov r7, #09h
mov r6, #05h
mov tl0, #0c0h
mov th0, #0c0h
setb P0.0

call zeigen
;---------------------------
anfang:
jnb p1.0, starttimer
jnb p1.1, stoptimer
nurRT:
jnb p1.2, RT
jnb tr0, da
ajmp anfang
da:
call display
jnb P0.0, nurRT
ajmp anfang
;------------------------------
; unterprogramme
;
; start timer
starttimer:
setb tr0; start timer0
setb P1.0
ajmp anfang
; stop Timer
stoptimer:
clr tr0; stop timer
setb P1.1
ajmp anfang

RT:
clr tr0; stop timer
setb P1.2
setb P0.0
ljmp init



;----------------------
; timer
;
timer:
inc r1
cjne r1, #02h, nuranzeige
mov r1, #00h
call countdown
ret

nuranzeige:
call zeigen
ret

countdown:
cjne r6, #3bh, sekunden
jmp minuten
;cjne r7, #0h, minuten
hupe:
clr tr0; stop timer
clr P0.0
ret

minuten:
mov r6, #00h
inc r7
call zeigen
ret
sekunden:
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
mov P3, R2
clr P2.0
setb P2.0

mov P3, R3
clr P2.1
setb P2.1

mov P3, R4
clr P2.2
setb P2.2

mov P3, R5
clr P2.3
setb P2.3

ret

org 300h
table:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b

end

