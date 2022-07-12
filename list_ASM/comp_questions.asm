q1 db "1", 0
q2 db "2", 0
q3 db "3", 0
q4 db "4", 0
q5 db "5", 0

_compQ1:
	mov si, command
	mov di, q1
	call _strComp
	jne .end
	call _startQ1
	.end
	ret

_compQ2:
	mov si, command
	mov di, q2
	call _strComp
	jne .end
	call _startQ2
	.end
	ret

_compQ3:
	mov si, command
	mov di, q3
	call _strComp
	jne .end
	call _startQ3
	.end
	ret

_compQ4:
	mov si, command
	mov di, q4
	call _strComp
	jne .end
	call _startQ4
	.end
	ret

_compQ5:
	mov si, command
	mov di, q5
	call _strComp
	jne .end
	call _startQ5
	.end
	ret