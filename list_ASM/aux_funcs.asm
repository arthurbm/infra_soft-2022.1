_getChar:
 	mov ah, 00h
	int 16h
	ret

_putChar:
	mov ah, 0x0e
	int 10h
	ret

_printLine:            
	.whilePrintLine:
		lodsb	
		cmp al, 0
		je .end
		call _putChar
		jmp .whilePrintLine
	
	.end:
		ret

_strComp:                           
	.whileStrComp:
		lodsb
		cmp byte[di], 0
		jne .cont
		cmp al, 0
		jne .concluded
		stc
		jmp .concluded
		
		.cont:
			cmp al, byte[di]
    			jne .concluded
			clc
    			inc di
    			jmp .whileStrComp

		.concluded:
			ret

_clear:
  mov ah, 0
  mov al, 10h
  int 10h
  ret

delc:
	mov al, 0x08
	call _putChar
		 
	mov al, ' '
	call _putChar
		 
	mov al, 0x08
	call _putChar
	ret

_endl_global:
  mov al, 0x0A
	call _putChar

	mov al, 0x0D
	call _putChar
	ret

gets:
	xor cx, cx
	
	.loop:		 
		call _getChar

		cmp al, 0x08
		je .backspace

		cmp al, 0x0D
		je .done
		 
		cmp cl, 0x3F 
		je .loop
		 
		call _putChar
		 
		stosb
		inc cl
		jmp .loop
		 
		.backspace:
			cmp cl, 0
			je .loop
		 
			dec di
			mov byte[di], 0
			dec cl

			call delc
			jmp .loop
		 
	.done:
		mov al, 0
		stosb		 
		call _endl_global
		ret

_end:                        
	.wait:
		call .getChar
		cmp al, 13
		je .end
		jmp .wait

	.getChar:
	 	mov ah, 00h
		int 16h
		ret

	.end:	
		pop ax
		jmp _start