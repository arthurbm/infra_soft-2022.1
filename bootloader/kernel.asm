org 0x7e00
jmp 0x0000:start

data:
    ; dados da interface console
        texto_menu_console db 'PLAYSTATION 6', 0                  ; texto console
        texto_menu_snake db 'T - JOGAR SNAKE', 0                ; texto jogar Snake console

    ; dados do Snake

        ; Constantes

        ; TIMER       equ 046Ch                                 ; Nº de ticks desde a meia-noite, 18.2 ticks equivalem a 1 segundo
        array_cobra_x equ 1000h
        array_cobra_y equ 2000h
        ; Variáveis
        cobra_x: dw 0A0h
        cobra_y: dw 064h
        comprimento_da_cobra: dw 5
        largura_da_cobra: dw 2
        win_points: dw 15

        points dw 0

        objeto_x: dw 30
        objeto_y: dw 20
        cor_do_objeto: db 4
        direcao: db 4
        TIMER  equ 046Ch      ; Nº de ticks desde a meia-noite
        tela_largura dw 140h                                    ; janela feita com al = 13h (320x200)
        tela_altura dw 0c8h    

;Snake ----------------------------------------------------------------
%macro print_obj 5          
    .loop1:    
        .loop2:
            mov ah, 0Ch             ; escrevendo um pixel
            mov al, %5              ; escolhendo a cor (branca)
            mov bh, 00h             ; escolhendo a pagina
            int 10h

            inc cx
            mov ax, cx     
            sub ax, %1
            cmp ax, %3
            jne .loop2
        
        mov cx, %1
        inc dx
        mov ax, dx
        sub ax, %2
        cmp ax, %4
        jne .loop1

%endmacro

%macro print_string 3 
    mov ah, 02h                     ; escolher a posição do cursor
    mov bh, 00h                     ; escolher a pagina
    mov dh, %1                      ; escolher a linha
    mov dl, %2                      ; escolher a coluna
    int 10h

    mov si, %3                      ; pega o texto 

    call prints                     ; print o texto
%endmacro

prints:                ; print o texto de game over
        .loop:
            lodsb ; bota character em al 
            cmp al, 0
            je .endloop
            call putchar
            jmp .loop
        .endloop:
            ret

putchar:
    mov ah, 0x0e
    mov bh, 00h
    mov bl, 15
    int 10h
    ret

menu_console:
    call limpar_tela

    print_string 04h, 06h, texto_menu_console

    print_string 0Eh, 06h, texto_menu_snake

    .espera_tecla:
        ; espera por um caracter
        mov ah, 00h
        int 16h          ; salva o caracter em al

        cmp al, 't'
        je snake_loop
        cmp al, 'T'
        je snake_loop

        jmp .espera_tecla


    jmp menu_console

limpar_tela:
    ; chama o modo vídeo
    mov ah, 00h             ; set video mode
    mov al, 13h             ; escolhe o video mode
    int 10h                 ; executa

    ; chama o fundo preto
    mov ah, 0Bh             ; setando a configuracao
    mov bh, 00h             ; para a cor de fundo
    mov bl, 00h             ; escholhendo preto
    int 10h

    ret

reset_cor_objeto:
    mov al, 1
    mov [cor_do_objeto], al
    ret

jump_grey:
    mov al, 9
    mov [cor_do_objeto], al
    ret

mudar_cor_objeto:
    mov al, [cor_do_objeto]
    inc al
    mov [cor_do_objeto], al
    ; Selecionar cores de 1-15, menos 7 e 8 que são cinza
    mov ah, 16
    cmp [cor_do_objeto], ah
    jge reset_cor_objeto
    mov ah, 7
    cmp [cor_do_objeto], ah
    je jump_grey

    ret
print_objeto:
    ; Desenhar objeto
    mov cx, [objeto_x]
    mov dx, [objeto_y]
    print_obj [objeto_x], [objeto_y], 3, 3, [cor_do_objeto]

    ret

game_won_snake:
    call limpar_tela
    
    xor ah, ah
    int 16h
        
    cmp al, 'e'
    je menu_console

    jmp game_won_snake

snake_loop:
    call limpar_tela
    mov ax, 00h                             ; setar o fundo a cada iteracao

    call print_objeto

    checar_objeto:
        mov byte [direcao], bl            ; Atualizar posicao

        ; Checar de existe sobreposicao entre do objeto e da cobra com uma margem de erro
        mov ax, [objeto_x]
        add ax, 3
        cmp ax, [cobra_x]
        jng delay_loop        
        
        mov ax, [cobra_x]
        add ax, [largura_da_cobra]
        cmp [objeto_x], ax
        jnl delay_loop        

        mov ax, [objeto_y]
        add ax, 3
        cmp ax, [cobra_y]
        jng delay_loop        

        mov ax, [cobra_y]
        add ax, [comprimento_da_cobra]
        cmp [objeto_y], ax
        jnl delay_loop        

        ; Se bateu no objeto, incrementa o tamanho da cobra
        ; E aumenta a pontuação
        add word [comprimento_da_cobra], 2
        inc word [points]
        mov ax, [points]
        cmp ax, [win_points]
        jge game_won_snake

    ; Nao ganhou, entao gere outro objeto
    call mudar_cor_objeto

    proximo_objeto:
        ; Pegar uma posicao pseudoaleatoria para o objeto aparecer a seguir
        xor ah, ah
        int 1ah                         ; Pegar os ticks de relogio desde a meia-noite
        mov ax, dx
        xor dx, dx
        mov cx, [tela_largura]
        div cx                          ; (dx/ax) / cx; ax = quociente, dx = resto
        mov word [objeto_x], dx
    
        xor ah, ah
        int 1ah                         ; Pegar os ticks de relogio desde a meia-noite
        mov ax, dx
        xor dx, dx
        mov cx, [tela_altura]
        div cx
        mov word [objeto_y], dx

    ; Checar se o objeto foi gerado "dentro" da cobra
    xor bx, bx                          ; index do array
    mov cx, [comprimento_da_cobra]      ; contador do loop
    .check_loop:
        mov ax, [objeto_x]
        cmp ax, [array_cobra_x + bx]
        jne .increment

        mov ax, [objeto_y]
        cmp ax, [array_cobra_y + bx]
        je proximo_objeto

        .increment:
            inc bx
            inc bx
    loop .check_loop

    delay_loop:                     ; Para não ficar piscando freneticamente
        mov bx, [TIMER]
        add bx, 2
        .delay:
            cmp [TIMER], bx
            jl .delay

jmp snake_loop


start:
    xor ax, ax
    mov ds, ax

    
    call limpar_tela                ; executa a configuração de video inicial

    jmp menu_console

end:                        
    ; Menu do console
    call menu_console

times 63*512-($-$$) db 0


jmp $
dw 0xaa55