org 0x7c00
jmp 0x0000:main

%macro getc 0
	mov ah, 0x00
	int 16h
	xor ah, ah
%endmacro

%macro pushr 1
	push %1
%endmacro

main:
	mov ah, 00h
  mov al, 03h
  int 10h
 	xor dx, dx

  jmp _waitToGetString

_putChar:
	mov ah, 0x0e
	int 10h
	ret

_waitToGetString:
	getc

	cmp ax, 0x0d
	je _endl

	pushr ax
	inc dx

	call _putChar

	jmp _waitToGetString

_invertString:
	pop ax
	call _putChar
	sub dx, 1

	cmp dx, 0
	je _end

	jmp _invertString

_endl:
	mov al, 0x0a
	call _putChar
	mov al, 0x0d
	call _putChar
	jmp _invertString

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
