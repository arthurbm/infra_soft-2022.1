_dataQ4:
  x times 2 db 0x00
  y times 2 db 0x00
  z times 2 db 0x00
  w times 2 db 0x00

  intd times 11 db 0x00
  restd times 11 db 0x00

  pairs db 'A parte inteira eh par', 13, 10, 0
  odds db 'A parte inteira eh impar', 13, 10, 0

_startQ4:
  mov ah, 00h
  mov al, 03h
  int 10h
 	xor dx, dx

  mov di, x
  call gets

  mov di, y
  call gets

  mov di, z
  call gets

  mov di, w
  call gets

  call solve

  jmp _endl_global

solve:
  ; Resolvendo (z - w)
    mov si, w
    lodsb 
    sub al, 48
    mov bl, al 

    mov si, z
    lodsb
    sub al, 48

    sub al, bl
    xor ah, ah

    push ax
  ;

  ; Resolvendo (x + y)
    mov si, y
    lodsb
    sub al, 48
    mov bl, al 

    mov si, x
    lodsb
    sub al, 48

    add al, bl
    xor ah, ah

    push ax
  ;

  ; Resolvendo (x + y) + (z - w)
    pop ax
    mov bl, al

    pop ax 

    add al, bl
    xor ah, ah

    push ax
  ;

  ; Resolvendo (y - z)
    mov si, z
    lodsb
    sub al, 48
    mov bl, al 

    mov si, y 
    lodsb
    sub al, 48 

    sub al, bl
    xor ah, ah

    push ax 
  ;

  ; Resolvendo (x + w)
    mov si, w
    lodsb
    sub al, 48
    mov bl, al 

    mov si, x
    lodsb
    sub al, 48

    add al, bl
    xor ah, ah

    push ax
  ;

  ; Resolvendo (x + w) + (y - z)
    pop ax 
    mov bl, al

    pop ax 
    add al, bl

    xor ah, ah
    push ax
  ;

  ; Resolvendo ((x + y) + (z - w)) / ((x + w) + (y - z))
    pop ax
    mov bl, al

    pop ax
    div bl
    
    push ax ;Salvando a parte inteira e o resto (al, ah)
    push ax ;Salvando ax para obter a paridade da parte inteira

    mov di, intd
    add al, 48
    call _putChar ;Printando a parte inteira
    call _endl_global

    pop ax
    mov al, ah
    mov di, restd
    add al, 48
    call _putChar ;Printando o resto
    call _endl_global
  ;

  ; Conferindo paridade
    pop ax

    xor ah, ah
    mov bl, 2
    div bl

    mov al, ah
    add al, 48

    cmp al, 0
    je pair

    mov si, odds
    call _printLine
    call _end
  ;

pair:
  mov si, pairs
  call _printLine
  jmp _endl_global
