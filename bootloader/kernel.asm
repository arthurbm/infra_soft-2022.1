org 0x7e00
jmp 0x0000:start

data:
    ; dados da interface console

        objeto_x: dw 100
        objeto_y: dw 35
        cor_do_objeto: db 4
        direcao: db 4
        win_points: dw 5

    ; dados do Pong =================================================================
        TIMER            equ 046Ch      ; Nº de ticks desde a meia-noite
        ; dados de game status
        game_status db 1                                        ; game_status = 1 - jogando | game_status = 0 - nao ta jogando
        winner_status db 0                                      ; status do vencedor | 1 -> jogador 1, 2 -> jogador 2
        tela_atual db 0                                         ; Status da tela atual | 0-> menu, 1 -> jogo
        
        ; dados da tela
        tela_largura dw 140h                                    ; janela feita com al = 13h (320x200)
        tela_altura dw 0c8h     
        margem_erro dw 6                                        ; margem de erro para a bola não atravessar a tela

        ; dados do tempo
        tempo_aux dw 0                                          ; variável usado para checar se o tempo passou
        

        ; dados da interface 
        texto_jogador_um db '0'                                 ; texto da pontuação do jogador 1
        texto_jogador_dois db '0'                               ; texto da pontuação do jogador 2

        texto_game_over db 'GAME OVER', 0                       ; texto game over
        texto_perdedor db 'VOCE PERDEU', 0                ; texto vencedor 1
        texto_restart db 'RESTART - pressione R', 0             ; texto restart
        texto_return_main_menu db 'MENU - pressione M', 0       ; texto retornar para o main menu
        
        texto_main_menu db 'MENU PRINCIPAL', 0                  ; texto main menu
        texto_jogar db 'JOGAR - pressione ESPACO', 0                 ; texto jogar
        texto_jogador db 'USE AS SETAS CIMA/BAIXO', 0                       ; texto jogador 2
        texto_inst_jogador db 'PARA MOVER A BARRA', 0        ; texto inst jogador 2
        
        ; dados da bola
        bola_size dw 5                                          ; tamanho da bola
        bola_cor db 15                                          ; cor da bola
    
        bola_origem_X dw 0A0h                                   ; posicao X original da bola (meio da tela)
        bola_origem_Y dw 064h                                   ; posição Y original da bola (meio da tela)
        bola_X dw 0A0h                                          ; posição X da bola
        bola_Y dw 064h                                          ; posição Y da bola
        bola_vel_X dw 06h                                       ; velocidade X da bola
        bola_vel_Y dw 03h                                       ; velocidade Y da bola

        ; dados das barras
        error_margin dw 5                                      ; margem de erro de colisão da bola e do objeto


        barra_esquerda_pontos db 0                              ; pontuação do primeiro jogador (esquerda)
        barra_esquerda_X dw 0Ah                                 ; posição X da barra esquerda
        barra_esquerda_Y dw 0Ah                                 ; posição Y da barra esquerda
        barra_esquerda_cor db 15

        barra_direita_pontos db 0                               ; pontuação do segundo jogador (direita)
        barra_direita_X dw 132h                                 ; posição X da barra direita
        barra_direita_Y dw 0A0h                                 ; posição Y da barra direita
        barra_direita_cor db 15

        barra_largura dw 5                                      ; largura da barra
        barra_altura dw 30                                     ; altura da barra
        barra_vel dw 06h                                        ; velocidade vertical da barra
    



; printa um objeto passando os parrametros
; (coordX, coordY, largura, altura, cor)
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

; printa uma string passando os parametros
; (linha, coluna, * string)
%macro print_string 3 
    mov ah, 02h                     ; escolher a posição do cursor
    mov bh, 00h                     ; escolher a pagina
    mov dh, %1                      ; escolher a linha
    mov dl, %2                      ; escolher a coluna
    int 10h

    mov si, %3                      ; pega o texto 

    call prints                     ; print o texto
%endmacro

jogar_pong:
    call limpar_tela

    mov al, 1
    mov [game_status], al
    xor al, al
    mov [tela_atual], al

    jmp pong_loop

reset_cor:
    mov al, 1
    mov [bola_cor], al
    ret

mudar_cor:
    mov al, [bola_cor]
    inc al
    mov [bola_cor], al

    mov ah, 16
    cmp [bola_cor], ah
    jge reset_cor

    ret

print_UI:
    ; desenhar os pontos do jogador esquerdo

    mov ah, 02h                     ; escolher a posição do cursor
    mov bh, 00h                     ; escolher a pagina
    mov dh, 04h                     ; escolher a linha
    mov dl, 06h                     ; escolher a coluna
    int 10h

    mov ah, 0Eh                     ; escrever caracter
    mov al, [texto_jogador_um]      ; escolher caracter
    mov bl, [barra_esquerda_cor]    ; escolher cor (branco)
    int 10h

    ; desenhar os pontos do jogador direito

    mov ah, 02h                     ; escolher a posição do cursor
    mov dh, 04h                     ; escolher a linha
    mov dl, 21h                     ; escolher a coluna
    int 10h

    ret

atualiza_texto_jogador_um:
    xor ax, ax
    mov al, [barra_esquerda_pontos]

    add al, 48
    mov [texto_jogador_um], al


    ret

atualiza_texto_jogador_dois:
    xor ax, ax
    mov al, [barra_direita_pontos]

    add al, 48
    mov [texto_jogador_dois], al

    ret

print_barra_direita:

    ; define as coordenadas iniciais da barra direita
    mov cx, [barra_direita_X]
    mov dx, [barra_direita_Y]

    ; desenha a barra direita
    print_obj [barra_direita_X], [barra_direita_Y], [barra_largura], [barra_altura], [barra_direita_cor]

    ret

print_barra_esquerda:

    ; define as coordenadas iniciais da barra esquerda
    mov cx, [barra_esquerda_X]
    mov dx, [barra_esquerda_Y]

    ; desenha a barra esquerda
    print_obj [barra_esquerda_X], [barra_esquerda_Y], [barra_largura], 80, [barra_esquerda_cor]

    ret

print_bola:
    ; define as coordenadas iniciais da bola
    mov cx, [bola_X]
    mov dx, [bola_Y]

    ; desenha a bola
    print_obj [bola_X], [bola_Y], [bola_size], [bola_size], [bola_cor]

    ret

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

print_game_over_menu:
    call limpar_tela

    print_string 04h, 06h, texto_game_over          ; print texto game over


    ; mostra o vencedor     
    mov ah, 02h                                     ; escolher a posição do cursor
    mov bh, 00h                                     ; escolher a pagina
    mov dh, 06h                                     ; escolher a linha
    mov dl, 06h                                     ; escolher a coluna
    int 10h

    mov al, 01h                                     ; compara o status de vencedor
    cmp [winner_status], al
    je perdedor                                  

    perdedor:
        mov si, texto_perdedor                    ; pega o texto de vencedor 1
        jmp print_vencedor

    print_vencedor:                                 ; print o texto de vencedor
        call prints
    
    print_string 08h, 06h, texto_restart            ; print texto restart

    print_string 0Ah, 06h, texto_return_main_menu   ; print texto return main menu  


    ; espera por um caracter
    mov ah, 00h
    int 16h             ; salva o caracter em al

    cmp al, 'r'
    je restart_game
    cmp al, 'R'
    je restart_game

    cmp al, 'm'
    je sair_para_menu
    cmp al, 'M'
    je sair_para_menu

    ret

    restart_game:
        mov al, 01h                                 
        mov [game_status], al                       ; game_status = 1 | retorna o jogo
        ret     

    sair_para_menu:
        mov al, 00h
        mov [game_status], al                       ; game_status = 0 | o jogo para
        mov [tela_atual], al 

    
print_main_menu:
    call limpar_tela

    print_string 04h, 06h, texto_main_menu          ; print texto main menu

    print_string 06h, 06h, texto_jogar              ; print texto jogar
   
    print_string 12h, 06h, texto_jogador         ; print texto jogador 2

    print_string 14h, 08h, texto_inst_jogador    ; print texto int jogador 2


    .espera_tecla:
        ; espera por um caracter
        mov ah, 00h
        int 16h          ; salva o caracter em al

        cmp al, ' '
        je jogar

        cmp al, 'n'
        je end
        cmp al, 'N'
        je end

        jmp .espera_tecla


    jogar:
        mov al, 1
        mov [game_status], al
        mov [tela_atual], al
        ret

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

inv_vel_X:
    ; inverte a velocidade em X
    mov ax, [bola_vel_X]
    neg ax
    mov [bola_vel_X], ax

    call mudar_cor

    ret


inv_vel_Y:
    ; inverte a velocidade em Y caso bata na parede
    mov ax, [bola_vel_Y]
    neg ax
    mov [bola_vel_Y], ax
    
    call mudar_cor

    ret

inv_vel_Y_gol:
    ; inverte a velocidade em Y caso haja gol
    mov ax, [bola_vel_Y]
    neg ax
    mov [bola_vel_Y], ax
    
    jmp pass

reset_bola:
    ; a bola volta para a posição X de origem
    mov ax, [bola_origem_X]
    mov [bola_X], ax

    ; a bola volta para a posicao Y de origem
    mov ax, [bola_origem_Y]
    mov [bola_Y], ax

    ; a barra esquerda volta para a posicao inicial
    mov ax, 0Ah
    mov [barra_esquerda_X], ax
    mov [barra_esquerda_Y], ax

    ; a barra direita volta para a posicao inicial
    mov ax, 132h
    mov [barra_direita_X], ax
    mov ax, 0A0h
    mov [barra_direita_Y], ax

    xor ax, ax
    cmp [bola_vel_X], ax    
    jl teste_inv_1  
    jg teste_inv_2          

; serve para o jogo reiniciar de modo que os jogadores sempre consigam pegar a primeira bola

; se V_X < 0 && V_Y < 0, inverte

    teste_inv_1:
        xor ax, ax 
        cmp [bola_vel_Y], ax
        jl inv_vel_Y_gol 

        jmp pass

; se V_X > 0 && V_Y > 0, inverte 
    teste_inv_2:
        xor ax, ax
        cmp [bola_vel_Y], ax
        jg inv_vel_Y_gol

        jmp pass

    pass:

    call inv_vel_X

    

    ret

pontuar_jogador_um:
    mov al, [barra_esquerda_pontos]                 ; pontua o jogador um 
    inc al
    mov [barra_esquerda_pontos], al

    call reset_bola                                 ; bola volta para o início

    call atualiza_texto_jogador_um                  ; Atualiza a pontuação na tela do jogador 1

    ; checa se o jogador dois fez 5 pontos
    mov al, [barra_esquerda_pontos]
    cmp al, 05h
    je game_over

    ret

pontuar_jogador_dois:
    mov al, [barra_direita_pontos]                  ; pontua jogador dois
    inc al
    mov [barra_direita_pontos], al
   
    ; call reset_bola                                 ; bola volta para o início

    call atualiza_texto_jogador_dois                ; Atualiza a pontuação na tela do jogador 2

    ; checa se o jogador dois fez 5 pontos
    mov al, [barra_direita_pontos]
    cmp al, 05h
    je game_over

    ret

game_over:                                          ; quando um jogador fizer 5 pontos
    mov al, 05h
    cmp [barra_esquerda_pontos], al                 ; se o jogador 1 fez 5 pontos
    je jogador_um_venceu                            ; o jogador 1 ganhou
    jne jogador_dois_venceu                         ; se não, o jogador 2 ganhou

    jogador_um_venceu:
        mov byte[winner_status], 01h                ; winner_status = 1
        jmp continua_game_over                      ; pula para o resto do game over
    jogador_dois_venceu:
        mov byte[winner_status], 02h                ; winner status = 2
        jmp continua_game_over                      ; pula para o resto do game over

    continua_game_over:    
        mov byte [barra_esquerda_pontos], 00h       ; zera os pontos do primeiro jogador
        mov byte [barra_direita_pontos], 00h        ; zera os pontos do segundo jogador

        call atualiza_texto_jogador_um              ; atualiza o texto do jogador 1
        call atualiza_texto_jogador_dois            ; atualiza o texto do jogador 2

        xor al, al
        mov [game_status], al                       ; game status = 0 -> o jogo acabou

    ret

mover_bola:
    ; movendo a bola em X
    mov ax, [bola_vel_X]    
    add [bola_X], ax

    ; se bola_X < margem_erro(6)
    ; entao, inverte a velocidade X
    mov ax, [margem_erro]   
    cmp [bola_X], ax        
    jl inv_vel_X          


    ; se bola_X > (tela_largura - bola_size - margem de erro)
    ; entao, a bola volta para o inicio
    mov ax, [tela_largura]
    sub ax, [bola_size]
    sub ax, [margem_erro]
    cmp [bola_X], ax        
    jg pontuar_jogador_um      

    ; movendo a bola em Y                      
    mov ax, [bola_vel_Y]    
    add [bola_Y], ax

    ; se bola_Y < margem_erro 
    ; entao, inverte a velocidade Y
    mov ax, [margem_erro]
    cmp [bola_Y], ax        
    jl inv_vel_Y            

    ; se bola_Y > tela_largura - bola_size - margem_erro
    ; entao, inverte vel Y
    mov ax, [tela_altura]
    sub ax, [bola_size]
    sub ax, [margem_erro]
    cmp [bola_Y], ax
    jg inv_vel_Y       


    ; checa se a bola colide com a barra direita
    
    ; bola_x + bola_size > barra_direita_X
    mov ax, [bola_X]
    add ax, [bola_size]
    cmp ax, [barra_direita_X]
    jng exit_check_colisao_barra    ; se não tem colidao com a barra direta, checamos a barra esquerda

    ; bola_x < barra_direita_X + barra_largura 
    mov ax, [barra_direita_X]
    add ax, [barra_largura]
    cmp [bola_X], ax
    jnl exit_check_colisao_barra    ; se não tem colidao com a barra direta, checamos a barra esquerda

    ; bola_Y + bola_size > barra_direita_Y
    mov ax, [bola_Y]
    add ax, [bola_size]
    cmp ax, [barra_direita_Y]
    jng exit_check_colisao_barra    ; se não tem colidao com a barra direta, checamos a barra esquerda

    ; bola_Y < barra_direita_Y + barra_altura
    mov ax, [barra_direita_Y]
    add ax, [barra_altura]
    cmp [bola_Y], ax
    jnl exit_check_colisao_barra    ; se não tem colidao com a barra direta, checamos a barra esquerda

    ; se chegar até aqui, houve colisão com a barra direita
    ; inverte a velocidade da bola na direção X

    mov al, [bola_cor]                  ; muda a cor da barra direita
    mov [barra_direita_cor], al

    mov ax, [bola_vel_X]
    neg ax
    mov [bola_vel_X], ax

    ret  

    exit_check_colisao_barra:
                    
    ret   

mover_barras:               ; move as barras verticalmente
; barra esquerda

    ; checar de alguma tecla foi pressionada(se nao, checa a outra barra)
    mov ah, 01h
    int 16h
    jz check_mov_barra_direita      ; zf = 1 -> jz pula se for 1

    ; checar qual tecla foi pressionada (AL = ASCII character)
    mov ah, 00h
    int 16h

    jmp check_mov_barra_direita

    ret
    
; barra direita
    check_mov_barra_direita:
        
        ; move para cima
        cmp ah, 0x48                ; 'o'
        je mover_barra_direita_cima

        ;  move para baixo    
        cmp ah, 0x50                
        je mover_barra_direita_baixo

        jmp exit_mov_barra

        mover_barra_direita_cima:   
            ; move a barra direita para cima
            mov ax, [barra_vel]
            sub [barra_direita_Y], ax

            ; checa se o movimento é válido
            mov ax, [margem_erro]
            cmp [barra_direita_Y], ax
            jl fix_barra_direita_cima

            ret

        fix_barra_direita_cima:
            mov ax, [margem_erro]
            mov [barra_direita_Y], ax

            ret


        mover_barra_direita_baixo:  
            ; move a barra direita para baixo   
            mov ax, [barra_vel]
            add [barra_direita_Y], ax

            ; checa se o movimento é válido
            mov ax, [tela_altura]
            sub ax, [margem_erro]
            sub ax, [barra_altura]
            cmp [barra_direita_Y], ax
            jg fix_barra_direita_baixo

            ret

        fix_barra_direita_baixo:
            ; conserta o movimento caso não seja válido
            mov ax, [tela_altura]
            sub ax, [margem_erro]
            sub ax, [barra_altura]
            mov [barra_direita_Y], ax
            
            ret

    exit_mov_barra:
        ret

random_ball_loop:
    mov ax, 00h                           ; setar o fundo a cada iteracao

    call print_objeto

    .checar_objeto:
        ; mov byte [direcao], bl            ; Atualizar posicao

        ; SE A BOLA PASSAR PELA FRENTE DO OBJETO ELE DAR O JUMP (CONTINUAR O LOOP)
        ; Check if bola_X colides with objeto_X in a range of +/- error_margin
        mov ax, [bola_X]
        add ax, [bola_size]
        sub ax, [objeto_x]
        cmp ax, [error_margin]
        jg exit_colisao_bola
        ; neg ax
        ; cmp ax, [error_margin]
        ; jl exit_colisao_bola


        ; SE A BOLA PASSAR POR BAIXO DO OBJETO ELE VAI DAR O JUMP
        ; Check if bola_y colides with objeto_y in a range of +/- error_margin
        mov ax, [bola_Y]
        add ax, [bola_size]
        sub ax, [objeto_y]
        cmp ax, [error_margin]
        jg exit_colisao_bola
        ; neg ax
        ; cmp ax, [error_margin]
        ; jl exit_colisao_bola

        ; Se bateu no objeto, pontua o jogador 1
        call pontuar_jogador_um

        ; Se bateu no objeto, checa se o jogador 1 ganhou
        mov ax, [barra_esquerda_pontos]
        cmp ax, [win_points]
        je mostra_game_over

        call proximo_objeto
        exit_colisao_bola:

        ret

    

    proximo_objeto:
        ; Nao ganhou, entao gere outro objeto
        call mudar_cor_objeto

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

    ; delay_loop:                     ; Para não ficar piscando freneticamente
    ;     mov bx, [TIMER]
    ;     add bx, 2
    ;     .delay:
    ;         cmp [TIMER], bx
    ;         jl .delay

pong_loop:                     ; gera a sensação de movimento
        xor al , al

        cmp [tela_atual], al        ; se a tela atual for a de menu
        je mostra_main_menu         ; mostra o menu

        cmp [game_status], al       ; se o jogo acabar
        je mostra_game_over         ; mostra a tela de game over
        
        mov ah, 00h                 ; get system time
        int 1ah                     ; cx:dx = numero de ticks de clock desde a meia noite

        cmp dx, [tempo_aux]         ; verifica se o tempo passou (provavelmente 1/100 s)
        je pong_loop

        ; o tempo passou

        mov [tempo_aux], dx         ; atualiza o tempo

        call limpar_tela            ; da update na tela para nao deixar "rastro"

        call mover_bola             ; muda as coordenadas da bola      

        call print_bola             ; desenha a bola 

        call mover_barras           ; move e checa os movimentos validos das barras


        call print_barra_direita    ; desenha a barra esquerda

        call print_UI

        call random_ball_loop

        jmp pong_loop 
            
        end:                        
            ; Menu do console
            call jogar_pong

mostra_game_over:
            call print_game_over_menu
            jmp pong_loop
            
mostra_main_menu:
    call print_main_menu
    jmp pong_loop
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
    print_obj [objeto_x], [objeto_y], 5, 5, [cor_do_objeto]

    ret


start:
    xor ax, ax
    mov ds, ax

    
    call limpar_tela                ; executa a configuração de video inicial

    jmp jogar_pong


times 63*512-($-$$) db 0


jmp $
dw 0xaa55