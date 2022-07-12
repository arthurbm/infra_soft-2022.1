org 0x7e00
jmp 0x0000:_start

%include "aux_funcs.asm"
%include "comp_questions.asm"
%include "questions/q1.asm"
%include "questions/q2.asm"
%include "questions/q3.asm"
%include "questions/q4.asm"
%include "questions/q5.asm"

menuText db "=======================================================" ,10,13,"*  MENU - ASM list  *",10,13,10,13,"Group 7, which is integrated by:",10,13,10,13,"    abm5 - Arthur Brito Medeiros",10,13,"    ... - Julia Dias",10,13,"    ... - Welline Nascimento",10,13,10,13,"For execute the program type a number from 1 to 5 " ,10,13, "and press ENTER to select the question you want to run" ,10,13,10,13, "* To return to the menu, press the ENTER button again *",10,13,"=======================================================",10,13,10,13,10,13,0

tempMsg db "Question not yet implemented",0

data:
	command times 100 db 0
  call _dataQ3
  call _dataQ4
  call _dataQ5

_start:             
	xor ax, ax	
	xor bx, bx
	xor cx, cx
	xor dx, dx	
	mov bx, 15
	mov ds, ax    
	mov es, ax

	call _clear

	mov ah, 00h
	mov al, 10h
	int 10h

	mov si, menuText
	call _printLine

_initMenu:
	xor ax, ax	
	xor bx, bx
	xor cx, cx
	xor dx, dx	
	mov bx, 15
	mov ds, ax    
	mov es, ax   

	mov al, '>'
	call _putChar
	mov al, ' '
	call _putChar
	mov di, command

_wait:                  
	call _getChar
	call _putChar
	cmp al, 13
	je _chooseQuestion       
	stosb	
	jmp _wait
   
_chooseQuestion:                 
	mov al,0
	stosb
	call _compQ1 	
	call _compQ2	
	call _compQ3
	call _compQ4	
	call _compQ5

	jmp _initMenu

jmp $