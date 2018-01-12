.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;ROSCA ALEXANDRU

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc



includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "TETRIS",0
area_width EQU 192
area_height EQU 352
marime equ area_width*area_height;
marimeCounter equ area_width*area_height;
matrice_pixeli dd marime dup(0ffffffh);
area DD 0
aux dd 1
aux_pozitiey dd 0

randomx dd 0
randomy dd 0
can_rotate dd 0
final_game dd 0
dex dd 0
dey dd 0
countLine dd 0
runda dd 0
symbol_width equ 48
symbol_height equ 48
score_width EQU 10
score_height EQU 20
symbol_w equ symbol_width/3
symbol_h equ symbol_height/3
deplasarey dd 0
deplasarex dd 96
xx dd 0
yy dd 0
rotate dd 1
tip_fig dd 0
event dd 0
posx dd 0
posy dd 0
tipFigura dd 0
tip dd 0
scor_total dd 0
aux_score dd 0

pozitiex dd 0
pozitiey dd 0
counter1 dd 0
counter2 dd 0
counter3 dd 0
counter4 dd 1
random_nr dd 1
auxDreapta dd 0
auxStanga dd 0
ivar dd 1
jvar dd 0
counter5 dd 0
counter6 dd 0
positionx dd 0
positiony dd 0
possx dd 0
possy dd 0
fig dd 0
format db "color: %x ",0 
format2 db "x = %d, y = %d ; ",0
format3 db "var1 = %d , var2 = %d, var3 = %d",0
format4 db "positionx : %d   positiony = %d  ",0
format5 db "scor: %d",0
mesaj db "S-a apelat reset", 0
color0 dd 0ff0000h
color1 dd 00ff00h
color2 dd 0000ffh
color3 dd 0ff00ffh
color4 dd 0ffff00h
color5 dd 0a32a2ah
color6 dd 1d8c96h
color dd 0 
col dd 0
aux2 dd 0
aux3 dd 0
aux4 dd 0


var11 dd 1
var12 dd 1
var13 dd 1
var1 dd 1
var2 dd 1
var3 dd 1
squareNo3 dd 0


arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
counter dd 0

include digits.inc
include digits2.inc

.code

;;;afisare scor

make_text2 proc
	push ebp
	mov ebp, esp
	pusha
	
	lea esi, digits2
	mov eax, [ebp+arg1]
	
draw_text3:
	mov ebx, score_width
	mul ebx
	mov ebx, score_height
	mul ebx
	add esi, eax
	mov ecx, score_height
bucla_simbol_linii3:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, score_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, score_width
bucla_simbol_coloane3:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb3
	mov dword ptr [edi], 0
	jmp simbol_pixel_next3
simbol_pixel_alb3:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next3:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane3
	pop ecx
	loop bucla_simbol_linii3
	popa
	mov esp, ebp
	pop ebp
	ret
make_text2 endp


make_text_macro2 macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text2
	add esp, 16
endm

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y


make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	 
	;alege culoare
	mov eax, tipFigura
	mov ebx, 0
	cmp eax, ebx
	je cul0
	
	mov ebx, 1
	cmp eax, ebx
	je cul1
	
	mov ebx, 2
	cmp eax, ebx
	je cul2
	
	mov ebx, 3
	cmp eax, ebx
	je cul3
	
	mov ebx, 5
	cmp eax, ebx
	je cul5
	
	mov ebx, 6
	cmp eax, ebx
	je cul6
	
	cul4:
	mov eax, color4
	mov color, eax
	jmp start_f
	
	cul3:
	mov eax, color3
	mov color, eax
	jmp start_f
	
	cul2:
	mov eax, color2
	mov color, eax
	jmp start_f
	
	cul5:
	mov eax, color5
	mov color, eax
	jmp start_f
	
	cul6:
	mov eax, color6
	mov color, eax
	jmp start_f
	
	cul1:
	mov eax, color1
	mov color, eax
	jmp start_f
	
	cul0:
	mov eax, color0
	mov color, eax
	
	; daca e figura patrat, sa fie tot timpul rotita
start_f:	
	mov ebx, rotate
	cmp rotate, 0			;verific daca figura trebuie rotita
	je rotate_fig

rotit:	
	
	lea esi, digits
	mov eax, [ebp+arg1]
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov fig, eax
	
	
	;xor edx, edx
	;mov ivar,ebx
	
	mov ecx, symbol_height	
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov edx, color
	mov dword ptr [edi], edx
	jmp simbol_pixel_next
simbol_pixel_alb:
	;mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	add esi, symbol_width			; citesc coloana cu coloana din fisier pt a roti figura
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	lea esi, digits
	add esi, fig
	add esi, ivar
	inc fig
	loop bucla_simbol_linii
	
jmp final_make
	
rotate_fig:
	lea esi, digits	
	mov eax, [ebp+arg1]
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax


mov ecx, symbol_height	
bucla_simbol_linii1:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane1:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb1
	mov edx, color
	mov dword ptr [edi],edx
	jmp simbol_pixel_next1
simbol_pixel_alb1:
	;mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next1:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane1
	pop ecx
	loop bucla_simbol_linii1
	
final_make:
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
figura proc

push ebp
mov ebp,esp
pusha
	inc random_nr
	
	mov eax, 1
	mov var1, eax	; se poate deplasa
	
	mov esi, area
	lea edi, matrice_pixeli
	xor ebx, ebx
	mov counter3, ebx
	loop2:
		mov dword ptr eax, [edi]
		mov dword ptr [esi], eax
		inc counter3					;mut din matricea auxiliara in matricea de pixeli (area)
		add edi, 4
		add esi, 4
		cmp counter3, marimeCounter
		je start_functie
	jmp loop2
	
	;mov eax, final_game
	;cmp eax, 1
	;je game_over

start_functie:
mov ebx, [ebp + arg4]
mov tipFigura, ebx				;ce fel de figura


mov eax, [ebp + arg1]			;salvez in eax evenimentul
cmp eax, 1						; s-a dat click
jz evt_click
cmp eax, 2						
jz inc_counter
	
evt_click:
mov ebx, deplasarey
cmp ebx, (area_height-symbol_h)		;verific daca s-a ajuns la ultima linie ca sa nu se mai poata misca stanga/ dreapta
je ultima_linie

;;;;;;;;;;;;;;;;;;verific in ce parte a ecranului s-a dat click pt deplasare stanga / dreapta / rotire

;;numere random
mov edx, [ebp + arg3]
mov randomx, edx
mov edx, [ebp + arg2]
mov randomy, edx

mov edx, [ebp + arg3]
cmp edx, area_height/2
jge rotate_piese

mov ebx, [ebp + arg2]
cmp ebx, area_width/2
jge dreapta	
		
stanga:
	push 1					; verific daca atunci cand incerc sa deplasez spre stanga nu am vreo figura in cale
	push area
	push deplasarey
	push deplasarex
	call canMoveLeft
	add esp, 16
	
	mov eax, var11			; var11 = 0 rezulva ca figura nu se poate deplasa spre stanga
	cmp eax, 0
	je inc_counter

	mov eax, deplasarex
	mov ebx, -32				;daca prima figura rotita a fost deplasata la maxim rezulta nu se mai poate deplasa
	cmp eax, ebx
	je inc_counter
	
	mov eax, deplasarex
	mov ebx, -16				; daca figura rotita a fost deplasata odata verific daca se mai poate deplasa odata 
	cmp eax, ebx
	je checkIfFirstFig
	jmp deplasare
	
	checkIfFirstFig:
	xor edx, edx
	mov eax, tip_fig
	cmp eax, edx
	je depla_stanga
	jmp inc_counter
	
    deplasare:
	
	xor eax, eax
	mov ebx, deplasarex     ;verific daca s-a ajuns in stanga ecranului si daca da, verific daca figura e rotita (pot deplasa inca 16 biti); iar daca 
	cmp  eax, ebx			;figura rotita e prima figura rezulta ca se poate deplasa cu inca 16 biti spre stanga
	je stanga_ecranului
	jmp depla_stanga
	
	
	stanga_ecranului:
	mov ebx, 1				;figura e rotita
	mov eax, rotate			 
	cmp ebx, eax
	je depla_stanga			; daca figura e rotita pot deplasa o data spre stanga(sau de doua ori daca e prima figura)
	jmp inc_counter			; daca figura nu e rotita nu se mai poate deplasa
	
	depla_stanga:
	
	mov ebx, deplasarex		;deplasez o patratica mai in stanga(symbol_width/3)
	sub ebx, symbol_w
	mov deplasarex, ebx
	jmp inc_counter
	
dreapta:
	push 0					; verific daca atunci cand incerc sa deplasesz spre dreapta nu am vreo figura
	push area
	push deplasarey
	push deplasarex
	call canMoveLeft
	add esp, 16

	mov eax, var11			; var11 = 0 rezulva ca figura nu se poate deplasa sprea dreapta
	cmp eax, 0
	je inc_counter

	mov ebx, deplasarex						; verific daca s-a ajuns in dreapta ecranului si daca da, nu mai pot deplasa la dreapta
	cmp ebx, (area_width-symbol_width)
		jz inc_counter
	add ebx, symbol_w
	mov deplasarex, ebx
	jmp inc_counter
	
rotate_piese:

; resetare joc
mov eax, 1
cmp eax, final_game
je restart_game
jmp rotate_piese2

restart_game:
	mov esi, area						
	lea edi, matrice_pixeli
	xor eax, eax
	mov final_game, eax
	mov deplasarey, eax
	mov scor_total, eax
	mov eax, 80
	mov deplasarex, eax

	mov ecx, marimeCounter		
	loop_reset:
		mov dword ptr  [esi], 0ffffffh
		mov dword ptr [edi], 0ffffffh							;incarc cu pixeli albi ambele matrici
		add edi, 4
		add esi, 4
	loop loop_reset
	jmp ultima_linie


rotate_piese2:
push area
push deplasarey
push deplasarex								;verific daca atunci cand vreau sa rotesc figura nu ma suprapun peste altele
call canRotate
add esp, 12

xor eax, eax
cmp eax, can_rotate
je inc_counter



;verific daca vreau sa rotesc figura in partea stanga a ecranului (daca figura e in partea stanga atunci cand o rotesc se poate suprapune si aparea in partea dreapta)
mov eax, 3
mov ebx, tip_fig				; figura 3 nu trebuie sa fie rotita
cmp eax, ebx
je inc_counter


mov eax, 1
mov ebx, rotate
cmp eax, ebx
je checkIfCanRotate						; daca figura e rotita ma asigur ca atunci cand ajunge in pozitia initiala figura nu apare in partea dreapta
jmp rotateFig

checkIfCanRotate:
mov eax, -16							
mov ebx, deplasarex
cmp eax, ebx
je addPixels  

mov eax, -32			
mov ebx, deplasarex
cmp eax, ebx
je addPixels2

jmp rotateFig

addPixels:
mov eax, deplasarex
add eax, symbol_w
mov deplasarex, eax
jmp rotateFig

addPixels2:
mov eax, deplasarex
add eax, symbol_w*2
mov deplasarex, eax

rotateFig:
mov edx, 1
cmp rotate, edx								; daca rotate = 0 rezulta rotate = 1 si invers
je rot
mov ebx, 1
mov rotate, ebx
jmp inc_counter
rot:
mov ebx, 0
mov rotate, ebx


inc_counter:
	inc counter	

afiseaza:


xor edx, edx
mov eax, counter
mov ebx, 3
div ebx						;setez intervalul de timp
cmp edx, 0
jz sec_passed				;se deplaseaza figura mai jos
ultima_linie:
make_text_macro tipFigura, area, deplasarex, deplasarey
;make_text_macro2 1, area, 20, 10



push area
push deplasarey
push deplasarex
call canMoveMore1						; se verifica daca se mai poate deplasa pe verticala
add esp, 12

mov eax, var1
cmp eax, 0
je matrice_auxiliara

jmp final_draw

sec_passed:

mov ebx, deplasarey
;cmp ebx, (area_height-symbol_height)		;verific daca a depasit area - inaltimea figurii ca sa poate fi desenata inca odata
push area
push deplasarey
push deplasarex
call canMoveMore1
add esp, 12

mov eax, var1
cmp eax, 0
je ultima_linie

add ebx, symbol_h						;desenez pe ecran cum s-a mutat pe y
mov deplasarey, ebx
make_text_macro tipFigura, area, deplasarex, deplasarey

jmp final_draw

matrice_auxiliara:
	
	; verific daca pot sterge o linie 
	
	push area
	push deplasarey
	call deleteLine
	add esp, 12
	
	;;setez scorul
	xor edx, edx
	mov ebx, 10
	mov eax, scor_total
	cmp eax, ebx
	jl zecimal
	div ebx
	make_text_macro2 eax, area, 20, 10
	make_text_macro2 edx, area, 40, 10
	jmp is_game_over
	
	zecimal:
	mov edx, scor_total
	make_text_macro2 edx, area, 40, 10
	
	is_game_over:
	mov eax, 16
	mov ebx, deplasarey
	cmp ebx, eax
	jle game_over
	
	;;generare random figura
	xor edx, edx
	xor eax, eax
	;mov eax, randomx
	;mov ebx, randomy
	;mul ebx
	;add eax, ebx
	;add eax, deplasarex
	;add eax, deplasarey
	;mov ebx, random_nr
	;mul ebx
	;shl eax, 7
	rdtsc
	
	mov bx, 7
	xor edx,edx
	div bx
	mov tip_fig, edx
	
	push edx
	push offset format5
	call printf
	add esp, 8
	;xor eax, eax
	;mov tip_fig, eax
	
	
	jmp not_game_over
	
game_over:
mov eax, 1
mov final_game, eax

not_game_over:
	mov eax, 1
	mov aux, eax
	xor ebx, ebx
	mov deplasarey, ebx			;reinitializez pozitia y
	mov eax, 80
	mov deplasarex, eax			;reinitializez pozitia x
	mov rotate, 0				;setez sa nu fie rotita figura
	;inc tip_fig					;schimb figura
	
	mov eax, tip_fig
	mov ebx, 3
	cmp eax, ebx		; figura 3 tb sa fie rotita tot timpul
	je figr3
	jmp inc_runda
	
	figr3:
	mov eax, 1
	mov rotate, eax
	jmp inc_runda
	
inc_runda:
	inc runda
	;jmp game_over
	
	;game_is_over:
	;mov edx, 1
	;mov final_game, edx
	
	mov esi, area
	lea edi, matrice_pixeli
	
	
jmp_after_restart:
	
	xor ebx, ebx
	mov counter3, ebx			;counter = 0
	loop3:
		xor eax, eax
		mov dword ptr  eax, [esi]
		mov dword ptr [edi], eax
		inc counter3							;mut din matricea de pixeli(area) in matricea intermediara
		add edi, 4
		add esi, 4
		
		cmp counter3, marimeCounter
		je final_draw
	jmp loop3
	
	jmp start_functie
	
final_draw:

popa
	mov esp, ebp
	pop ebp
	ret	

figura endp

canRotate proc
push ebp
mov ebp, esp
pusha

mov eax, 1
mov can_rotate, eax				; implicit se poate roti

mov eax, [ebp + arg1]
mov dex, eax

mov eax, [ebp + arg2]
mov dey, eax

mov eax, rotate
cmp eax, 0
je fig_nerotite
;;figura rotita				;daca figura e rotita, atunci cand vreau sa o rotesc din nou vreau sa verific daca nu se suprapune peste figurile existente

mov eax, (symbol_width*5/6)
add dey, eax

mov eax, (symbol_w/2)
add dex, eax

mov esi, [ebp + arg3]
;;calc coordonatele

	mov eax, dey
	mov ebx, area_width
	mul ebx
	add eax, dex				
	shl eax, 2						
	add esi, eax
	
	cmp dword ptr [esi], 0ffffffh
	jne set_cannot_rotate
	jmp final_canRotate

fig_nerotite:			;daca figura nu e rotita, atunci cand vreau sa o rotesc din nou vreau sa verific daca nu se suprapune peste figurile existente, verific pixelii in punctele extreme


mov eax, (symbol_w/2)
add dey, eax

mov eax, (symbol_width*5/6)
add dex, eax

mov esi, [ebp + arg3]
;;calc coordonatele

	mov eax, dey
	mov ebx, area_width
	mul ebx
	add eax, dex				
	shl eax, 2						
	add esi, eax
	
	cmp dword ptr [esi], 0ffffffh
	jne set_cannot_rotate
	jmp final_canRotate


set_cannot_rotate:
xor eax, eax
mov can_rotate, eax

final_canRotate:
popa
mov esp, ebp
pop ebp
ret

canRotate endp

canMoveLeft proc
push ebp
mov ebp, esp

pusha 
	mov eax, 1
	mov var11, eax
	;;;;;;;;;;;;;;;;;;;;
	
	mov eax, [ebp + arg1]	 ; deplasarex
	mov xx, eax
	
	mov eax, [ebp + arg2]	 ;deplasarey
	mov yy, eax
	
	mov eax, rotate
	mov ebx, 0
	cmp eax, ebx
	je moveLeftRotate
	;;;;;;;;;;;;;;figuri rotite						;verific daca se pot deplasa stanga/dreapta figurile rotite, este necesar sa verific daca sunt pixeli colorati in pozitia (1,3) din
													; figura atunci cand vreau sa ma deplasez spre stanga si trbuie sa verific daca sunt pixeli colorati putin mai la dreapta de pozitia
	mov eax, (symbol_height*5/6)					; (3,3) din figura
	add yy, eax
	
	mov edx, [ebp + arg4]				;verific la stanga sau dreapta
	cmp edx, 0 						
	je movRight1
	
	mov eax, tip_fig
	cmp eax, 1					; daca e figura 1 se poate deplasa spre stanga
	je final_canMoveLeft
	
	mov eax, (symbol_width/6)
	add xx, eax						
	jmp checkcanmov1
	
	movRight1:
	mov eax, tip_fig
	cmp eax, 4
	je final_canMoveLeft			; daca e figura 4 se poate deplasa sprea dreapta
	
	mov eax, symbol_width
	add eax, symbol_width/6
	add xx, eax

checkcanmov1:
	
	;;calc coordonatele
	mov esi, [ebp + arg3]	;area
	
	mov eax, yy
	mov ebx, area_width
	mul ebx
	add eax, xx				;calculez coordonatele pt area  
	shl eax, 2						
	add esi, eax
	
	
	cmp dword ptr[esi], 0ffffffh
	jne setVar11toZero
	jmp final_canMoveLeft
	;;;;;;;;;;;;;;;;;;;;
	;figuri nerotite					; pt figurile care nu sunt rotite daca vreau sa le deplasez la stanga/dreapta e necesar sa verific daca gasesc pixeli colorati inafara figurii 
	moveLeftRotate:						; pe ultimul rand (inafara de figura "Z")
	
	mov eax, (symbol_height*5/6)
	add yy, eax
	
	mov edx, [ebp + arg4]
	cmp edx, 0 						
	je movRight
	
	mov eax, (symbol_width/6)
	sub xx, eax						
	jmp checkcanmov
	
	movRight:
	mov eax, tip_fig
	cmp eax, 4
	je final_canMoveLeft		; daca e figura "Z" nu trebuie sa verific
	
	
	mov eax, symbol_width
	add eax, symbol_width/6
	add xx, eax

checkcanmov:	
	;;calc coordonatele
	mov esi, [ebp + arg3]	;area
	
	mov eax, yy
	mov ebx, area_width
	mul ebx
	add eax, xx				;calculez coordonatele pt area  
	shl eax, 2						
	add esi, eax
	
	
	cmp dword ptr[esi], 0ffffffh
	jne setVar11toZero
	jmp final_canMoveLeft
	setVar11toZero:
	xor ebx, ebx
	mov var11, ebx
	

final_canMoveLeft:	
	
popa
	mov esp, ebp
	pop ebp
	ret	



canMoveLeft endp

deleteLine proc
push ebp
mov ebp, esp
pusha 

	mov eax, [ebp + arg1]	 ; deplasarey
	mov pozitiey, eax
	mov aux_pozitiey, eax
	
	xor ebx, ebx
	mov countLine, ebx
	mov aux_score, ebx
	
	loop_4:
		inc countLine
	
		mov eax, countLine
		cmp eax, 4
		je setez_scor
	
		xor eax, eax
		mov pozitiex, eax
	
	
	
	
		mov ebx, countLine
		sub ebx, 1						; daca e runda 1 nu aduna nimic la pozitia de pe oy ; daca e runda 2 adun 16 pixeli ...
		mov eax, symbol_h
		mul ebx
		mov edx, aux_pozitiey
		add edx, eax
		mov pozitiey,  edx
		;after: 
	
		mov ebx, 8					;ma pozitionez pe centrul patratului
		mov eax, pozitiex
		add eax, ebx
		mov pozitiex, eax
	
		;;; verific daca trebuie sa sterg linia
	
		mov eax, pozitiey
		add eax, 8
		mov pozitiey, eax			;8 pixeli mai jos
		
		;; verific daca toata linia contine pixeli colorati

		mov ecx, 12				; 12 patratele pe orizontala
	
		loop_1:
			mov esi, [ebp + arg2]		; area
			mov eax, pozitiey
			mov ebx, area_width
			mul ebx
			add eax, pozitiex				;calculez coordonatele pt area  
			shl eax, 2						
			add esi, eax
		
			cmp dword ptr [esi], 0ffffffh
			je loop_4	; daca avem pixel alb ies din functie
		
			mov edx, pozitiex
			add edx, symbol_w
			mov pozitiex, edx
		
		loop loop_1
	
	;daca gasim o linie completa
		inc aux_score
		
		
		mov eax, pozitiey
		sub eax, 8						;adunasem initial 8 pixeli sa ma pozitionez pe centrul figurii
		mov pozitiey, eax
	
		loop_3:
	
			mov esi, [ebp + arg2]		; area
	
			mov eax, pozitiey
			mov ebx, area_width
			mul ebx
			add eax, 0			 
			shl eax, 2						
			add esi, eax
										;copiez pixelii de mai sus cu o pozitie de unde s-a gasit linia completa
			mov eax, pozitiey
			sub eax, symbol_w
			mov pozitiey, eax	
		
			mov edi, [ebp + arg2]		
	
			mov eax, pozitiey
			mov ebx, area_width
			mul ebx
			add eax, 0			 
			shl eax, 2						
			add edi, eax
	
	
	
			mov ecx, (area_width*symbol_h)			; pixelii de pe o linie intreaga
	
			loop_2:
				mov dword ptr eax, [edi]
				mov dword ptr [esi], eax
				add esi, 4
				add edi, 4
			loop loop_2
		
			mov eax, pozitiey
			cmp  eax, symbol_height    		; daca s-a ajuns in partea de sus a ecranului trebuie sa ma opresc
			jle loop_4
	
		jmp loop_3

	jmp loop_4
	
setez_scor:
	push aux_score
	push offset format5 
	call printf
	add esp, 8
	
	xor eax, eax
	cmp aux_score, eax
	je final_deleteLine
	
	mov eax, 1
	cmp aux_score, eax
	je set1_points
	
	
	mov eax, 2
	cmp aux_score, eax
	je set3_points
	
	mov eax, 7
	add scor_total, eax
	jmp final_deleteLine
	
	set1_points:
	mov eax, 1
	add scor_total, eax
	jmp final_deleteLine
	
	set3_points:
	mov eax, 3
	add scor_total, eax
	
final_deleteLine:




popa
mov esp, ebp
pop ebp
ret	

deleteLine endp



canMoveMore1 proc
push ebp
mov ebp, esp

pusha 

	mov eax, [ebp + arg1]	 ; deplasarex
	mov positionx, eax
	
	mov eax, [ebp + arg2]	 ;deplasarey
	mov positiony, eax

	
	
	mov ebx, positiony									;verific daca e pe ultima linie
    cmp ebx, (area_height-symbol_height)
	je setVar3toZero
	
	mov eax, runda
	cmp eax, 0					;daca e prima runda nu are rost sa fac verificarile
	je final_canMove1
	
	mov edx, 1
	mov var1, edx			;implicit se poate deplasa figura 
	mov var2, edx
	mov var3, edx
	
	xor eax, eax
	cmp tip_fig, eax			;verific daca e prima forma, rotita
	je forma1
	
	jmp calcVar1
	
	forma1:
	mov eax, 1
	cmp rotate, eax				; daca prima forma rotita ma intereseaza doar pixelii de pe ultima coloana
	je calcVar3
	
	
	
calcVar1:	
;;;;;;;;;;;;;;;;;var1					; figura este o matrice de 3x3 si verific daca atunci cand deplasez o pozitie mai in jos prima coloana se poate deplasa
	mov eax, (symbol_height*5/6)  			; ma pozitionez pe mijlocului ultimei laturi din figura
	add positiony, eax
	
	mov ebx, (symbol_width/6)				;ma pozitionez pe mijlocul primului  patrat
	add positionx, ebx
	
	
	mov esi, [ebp + arg3]
	xor edx, edx
	mov eax, positiony
	mov ebx, area_width
	mul ebx
	add eax, positionx				;calculez coordonatele pt area  
	shl eax, 2						
	add esi, eax
	mov aux2, eax
	
	
	lea edi, matrice_pixeli
	xor edx, edx
	xor eax, eax
	mov eax, positiony
	add eax, symbol_h				; ma deplasez cu inca 16 pixeli mai jos pt a vedea daca in "matrice_pixeli" am pixeli colorati
	mov ebx, area_width
	mul ebx
	add eax, positionx				;calculez coordonatele pt "matrice_pixeli"
	shl eax, 2						
	add edi, eax
	mov aux3, eax
	
	
	xor eax, eax
	cmp  eax, aux					;daca pe prima coloana sunt doar pixeli albi nu var1 e setata implicit la 1
	je calcVar2
	
;;caz particular pentru figura 5, daca gasesc pixeli colorati in pozitia (1,3) rezulta ca nu se mai poate deplasa
	
	mov ebx, tip_fig 
	mov edx, 5
	cmp edx, ebx 
	je checkIfCanGo1
	jmp continue1
	
	checkIfCanGo1:
	mov eax, 1
	mov ebx, rotate			; daca figura e rotita nu trebuie sa verific
	cmp eax, ebx
	je calcVar2
	lea edi, matrice_pixeli
	add edi, aux2
	cmp dword ptr [edi], 0ffffffh
	jne setVar1toZero
	
	
	
	
continue1:	
	lea edi, matrice_pixeli
	mov esi, [ebp + arg3]
	add esi, aux2
	add edi, aux3
	
	cmp dword ptr [edi], 0ffffffh	
	jne gasit_pixel_negru			; daca la ambele coordonate din area si "matrice_pixeli" sunt pixeli colorati rezulva ca figura nu se poate deplasa(var1 = 0)
	jmp calcVar2
	
gasit_pixel_negru:
	cmp dword ptr [esi], 0ffffffh
	jne setVar1toZero
	mov edx, tip_fig
	cmp edx, 5
	je calcVar2				; daca e figura 5 sa nu se seteze var1 = 1
	xor eax, eax					
	mov aux, eax
	jmp calcVar2
setVar1toZero:
	xor eax, eax
	mov var1, eax
;;;;;;;;;;;;var2 			 ; figura este o matrice de 3x3 si verific daca atunci cand deplasez o pozitie mai in jos a doua coloana se poate deplasa
calcVar2:
	mov eax, [ebp + arg1]	 ; deplasarex
	mov positionx, eax
	
	mov eax, [ebp + arg2]	 ;deplasarey
	mov positiony, eax


	mov eax, (symbol_height*5/6) 
	add positiony, eax
	
	mov ebx, (symbol_width/2)	;ma pozitionez pe mijlocul patratelului al doilea
	add positionx, ebx
	
	mov esi, [ebp + arg3]
	xor edx, edx
	mov eax, positiony
	mov ebx, area_width
	mul ebx
	add eax, positionx				;calculez coordonatele pt area
	shl eax, 2		
	add esi, eax
	mov aux2, eax
	
	lea edi, matrice_pixeli
	xor edx, edx
	xor eax, eax
	mov eax, positiony
	add eax, symbol_h
	mov ebx, area_width
	mul ebx
	add eax, positionx				;calculez coordonatele pt  matrice_pixeli
	shl eax, 2						
	add edi, eax	
	mov aux3, eax
;; caz particular pt figura 1, 5
;; daca atunci cand figura 1, 5 este inversata verific daca pe pozitia (2,3) avem pixeli colorati in matricea auxiliara si daca da rezulta ca nu se poate deplasa 
	mov edx, tip_fig
	mov ecx, 1
	cmp edx, ecx
	je checkIfCanGo2
	mov ecx, 5
	cmp edx, ecx
	je checkIfCanGo2
	mov ecx, 6
	cmp edx, ecx
	je figura6_particular
	jmp continue2
	
	checkIfCanGo2:
	lea edi, matrice_pixeli
	add edi, aux2
	cmp dword ptr [edi], 0ffffffh
	jne setVar2toZero
	jmp continue2
	
	figura6_particular:	; daca gasesc in pozitia (2,2) pixeli colorati sa nu ma pot depalasa
	xor eax, eax
	cmp rotate, 0			; daca figura nu e rotita nu trebuie sa fac verificarile
	je continue2
	
	mov eax, [ebp + arg2]	 ;deplasarey
	mov positiony, eax
	mov eax, symbol_width/2
	add positiony, eax
	
	lea edi, matrice_pixeli
	mov eax, positiony
	mov ebx, area_width
	mul ebx
	add eax, positionx				;calculez coordonatele pt  matrice_pixeli
	shl eax, 2						
	add edi, eax
	
	cmp dword ptr [edi], 0ffffffh
	jne setVar2toZero
	jmp calcVar3
	
	
	
continue2:
	lea edi, matrice_pixeli
	mov esi, [ebp + arg3]
	add esi, aux2
	add edi, aux3
	

	cmp dword ptr [edi], 0ffffffh
	jne gasit_pixel_negru2
	
	jmp calcVar3
	
gasit_pixel_negru2:
	cmp dword ptr [esi], 0ffffffh
	jne setVar2toZero
	jmp calcVar3
setVar2toZero:
	xor eax, eax
	mov var2, eax
;;;;;;;;;;;;var3  		 figura este o matrice de 3x3 si verific daca atunci cand deplasez o pozitie mai in jos a 3-a coloana se poate deplasa
calcVar3:
	mov eax, [ebp + arg1]	 ; deplasarex
	mov positionx, eax
	
	mov eax, [ebp + arg2]	 ;deplasarey
	mov positiony, eax
	
	
	mov eax, (symbol_height*5/6)
	add positiony, eax
	
	mov ebx, (symbol_width*5/6)	;ma pozitionez pe mijlocul patratelului al doilea
	add positionx, ebx

	
	mov esi, [ebp + arg3]
	xor edx, edx
	mov eax, positiony
	mov ebx, area_width
	mul ebx
	add eax, positionx				;calculez coordonatele
	shl eax, 2						
	add esi, eax
	mov aux2, eax
	
	
	lea edi, matrice_pixeli
	xor edx, edx
	xor eax, eax
	mov eax, positiony
	add eax, symbol_h
	mov ebx, area_width
	mul ebx
	add eax, positionx				;calculez coordonatele
	shl eax, 2						
	add edi, eax
	mov aux3, eax
	
	
	;;daca este figura 4 verific 
	;;verific daca atunci cand figura e rotita  in pozitia (3,3) din figura avem pixeli colorati in matricea auxiliara
	mov edx, tip_fig
	mov ecx, 4
	cmp edx, ecx
	je checkIfCanGo3
	jmp continue3
	
	checkIfCanGo3:
	lea edi, matrice_pixeli
	add edi, aux2
	cmp dword ptr [edi], 0ffffffh
	jne setVar3toZero
	
continue3:
	lea edi, matrice_pixeli
	mov esi, [ebp + arg3]
	add esi, aux2
	add edi, aux3
	
	cmp dword ptr [edi], 0ffffffh
	jne gasit_pixel_negru3
	
	jmp final_canMove1
	
gasit_pixel_negru3:
	cmp dword ptr [esi], 0ffffffh
	jne setVar3toZero
	jmp final_canMove1
setVar3toZero:
	xor eax, eax
	mov var3, eax
	
;;daca e fig nr 4 verific daca pe pozitia a 3-a cu doua pozitii mai jos in matricea de pixeli avem pixeli albi sau colorati

	
	
final_canMove1:
;; fac un AND intre var1, var2, var3, daca rezultatul este 1 rezulta ca piesa se poate deplasa in jos
	
	mov eax, var2
	mov ebx, var3
	and eax, ebx
	mov ebx, var1
	and ebx, eax		;salvez rezultatul in variabila1
	mov var1, ebx
	
popa
	mov esp, ebp
	pop ebp
	ret		


canMoveMore1 endp

; procedure drow
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc

push ebp
mov ebp, esp
pusha
	inc counter4 					; counter pentru schimbarea piesei
	mov eax, [ebp + arg1]
	cmp eax, 0
	jne dupa_initializare
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	mov ebx, 0			;tip de figura(intial)
	mov tip, ebx
	
	jmp final_functie
	
	dupa_initializare:
	
	
	
	mov ebx, [ebp + arg3]	;  pozitia pe y
	mov posy, ebx
	
	mov ebx, [ebp + arg2]	;pozitia pe x
	mov posx, ebx
	
	mov ebx, [ebp + arg1]	; evnimentul
	mov event, ebx
	
	
	push tip_fig				;se apeleaza functia propriu-zisa de desenare
	push posy
	push posx
	push event
	call figura
	add esp, 16
	
	final_functie:
	popa
	mov esp, ebp
	pop ebp
	ret

draw endp


start:
	;aici se scrie codul
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	;terminarea programului
	push 0
	call exit
end start
