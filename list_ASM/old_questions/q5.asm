_dataQ5:
	num times 16 db 0
	string db 'Malu  eh uma otima monitora', 13, 10, 0

_startQ5:
  mov ah, 00h
  mov al, 03h
  int 10h
 	xor dx, dx

  mov di, num
	call gets

	mov si, num
	call stoi
	mov bl, al

	mov si, string
	je printQ5

	call _printLine
  ret

stoi:
	xor cx, cx
	xor ax, ax

	.loop1:
		push ax
		lodsb
		mov cl, al
		pop ax
		cmp cl, 0
		je .endloop
		sub cl, 48
		mov bx, 10
		mul bx
		add ax, cx
		jmp .loop1

	.endloop:
		ret

printQ5:
	mov ah, 0
	mov al, 12h
	int 10h

	.loopQ5:
		lodsb
		cmp al, 0
		je .endloop
		call _putChar
		jmp .loopQ5

	.endloop:
		call _end
		ret
