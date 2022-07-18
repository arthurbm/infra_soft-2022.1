org 0x7c00
jmp 0x0000:main

_dataQ3:
  stringQ3 times 11 db 0x00
  position times 11 db 0x00

main:
  mov ah, 00h
  mov al, 03h
  int 10h
  xor dx, dx

  mov di, stringQ3
  call gets

  mov di, position
  call gets

	mov si, position
	xor ax, ax
	
	call findcQ3
  call _end
  
_putChar:
	mov ah, 0x0e
	int 10h
	ret
	
_getChar:
 	mov ah, 00h
	int 16h
  	xor ah, ah
	ret

_endl_global:
  mov al, 0x0A
	call _putChar

	mov al, 0x0D
	call _putChar
	ret
	
delc:
	mov al, 0x08
	call _putChar
		 
	mov al, ' '
	call _putChar
		 
	mov al, 0x08
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
	
findcQ3:
	mov al, byte[si]
	sub al, '1'
	mov di, stringQ3

	.loop1:
		cmp al, 0
		je .break

		dec al
		inc di
		jmp .loop1

	.break:
		mov al, byte[di]
		call _putChar
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
		jmp main
  
times 510 - ($ - $$) db 0
dw 0xaa55
