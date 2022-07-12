%macro getc 0
	mov ah, 0x00
	int 16h
	xor ah, ah
%endmacro

%macro pushr 1
	push %1
%endmacro

_startQ2:
	mov ah, 00h
  mov al, 03h
  int 10h
 	xor dx, dx

  jmp _waitToGetString

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
