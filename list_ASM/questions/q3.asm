_dataQ3:
  stringQ3 times 11 db 0x00
	position times 11 db 0x00

_startQ3:
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
