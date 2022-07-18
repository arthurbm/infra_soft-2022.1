org 0x7c00; endereço de memória onde o programa vai ser carregado
jmp 0x0000: start; Função inicial

frase db "Nao existe", 10, 10, 0; reserva espaço na memória para a string
azul db "AZUL", 10, 0; reserva espaço na memória para a string
vermelho db "VERMELHO", 10, 0; reserva espaço na memória para a string
verde db "VERDE", 10, 0; reserva espaço na memória para a string
amarelo db "AMARELO", 10, 0; reserva espaço na memória para a string

_azul:
    mov al, 9
    mov bl, 9
    mov si, azul; faz si apontar para o início da frase
    ret

_vermelho:
    mov bl, 4
    mov si, vermelho; faz si apontar para o início da frase
    ret

_verde:
    mov bl, 10
    mov si, verde; faz si apontar para o início da frase
    ret

_amarelo:
    mov bl, 14
    mov si, amarelo; faz si apontar para o início da frase
    ret

%macro compareAzul 0
    cmp cx, 4
    jne notAzul

    mov di, sp

    mov bl, [di]
    cmp bl, 'l'
    jne notAzul

    mov bl, [di+2]
    cmp bl, 'u'
    jne notAzul

    mov bl, [di+4]
    cmp bl, 'z'
    jne notAzul

    mov bl, [di+6]
    cmp bl, 'a'
    jne notAzul
%endmacro

%macro compareAzul2 0
    cmp cx, 4
    jne notAzul2

    mov di, sp

    mov bl, [di]
    cmp bl, 'L'
    jne notAzul2

    mov bl, [di+2]
    cmp bl, 'U'
    jne notAzul2

    mov bl, [di+4]
    cmp bl, 'Z'
    jne notAzul2

    mov bl, [di+6]
    cmp bl, 'A'
    jne notAzul2
%endmacro


%macro compareVermelho 0
    cmp cx, 8
    jne notVermelho

    mov di, sp

    mov bl, [di]
    cmp bl, 'o'
    jne notVermelho

    mov bl, [di+2]
    cmp bl, 'h'
    jne notVermelho

    mov bl, [di+4]
    cmp bl, 'l'
    jne notVermelho

    mov bl, [di+6]
    cmp bl, 'e'
    jne notVermelho

    mov bl, [di+8]
    cmp bl, 'm'
    jne notVermelho

    mov bl, [di+10]
    cmp bl, 'r'
    jne notVermelho

    mov bl, [di+12]
    cmp bl, 'e'
    jne notVermelho

    mov bl, [di+14]
    cmp bl, 'v'
    jne notVermelho
%endmacro

%macro compareVerde 0
    cmp cx, 5
    jne notVerde

    mov di, sp

    mov bl, [di]
    cmp bl, 'e'
    jne notVerde

    mov bl, [di+2]
    cmp bl, 'd'
    jne notVerde

    mov bl, [di+4]
    cmp bl, 'r'
    jne notVerde

    mov bl, [di+6]
    cmp bl, 'e'
    jne notVerde

    mov bl, [di+8]
    cmp bl, 'v'
    jne notVerde
%endmacro

%macro compareAmarelo 0
    cmp cx, 7
    jne finish

    mov di, sp

    mov bl, [di]
    cmp bl, 'o'
    jne notAmarelo

    mov bl, [di+2]
    cmp bl, 'l'
    jne notAmarelo

    mov bl, [di+4]
    cmp bl, 'e'
    jne notAmarelo

    mov bl, [di+6]
    cmp bl, 'r'
    jne notAmarelo

    mov bl, [di+8]
    cmp bl, 'a'
    jne notAmarelo

    mov bl, [di+10]
    cmp bl, 'm'
    jne notAmarelo

    mov bl, [di+12]
    cmp bl, 'a'
    jne notAmarelo
%endmacro

print:
    lodsb; carrega uma letra de si em al e passa si para o proximo caracter
    cmp al, 0; compara o valor em al com zero (o equivalente a '\0')
    je done_; se a linha anterior for igual, pula para o final da função

    mov ah, 0eh; imprime um caracter que está em al
    int 10h; interrupção de vídeo?
    jmp print; chama a função que printa um char da string novamente

    done_:
        ret; volta para a linha onde a função call foi chamada

start:
    xor ax, ax; limpa ax
    xor cx, cx; limpa cx
    xor bx, bx; limpa bx

    mov ds, ax; zera ds
    mov es, ax; zera es
    mov bl, 5
    mov si, frase; faz si apontar para o início da frase

    mov al, 13h
    mov ah, 0
    int 10h

    getString:
        mov ah, 0; 
        int 16h;

        mov bl, 15
        mov ah, 0eh; é o modo de vídeo do int 10h para imprimir o valor de al na tela
        int 10h;

        mov dl, al
        cmp dl, 0x0d
        je done
        push ax
        inc cx

        jmp getString
    
    done:
        compareAzul
        call _azul

        notAzul:
            compareVermelho
            call _vermelho
        
        notAzul2:
            compareVermelho
            call _vermelho

        notVermelho:
            compareVerde
            call _verde

        notVerde:
            compareAmarelo
            call _amarelo
        
        notAmarelo:

    finish:
        call print; chama a função que printa um char da string

times 510 - ($ - $$) db 0
dw 0xaa55
