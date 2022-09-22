#include <stdio.h>
#include <iostream>
#include <fstream>
#include <pthread.h>

#include <stdlib.h>
//#define LINHAS 2
//#define COLUNAS 2

using namespace std;

int linhas = 0;
int colunas = 0;
int matriz[linhas][coluna]={0};

void *verifyHorizontal(int n){
    for (int i = 0; i < linhas; i++){
        for (int j = i + 1; j < colunas; j++){
            if (matriz[n][j] != matriz[n][i]){
                printf("Não é um quadrado latino\n");
                pthread_exit(NULL);
                break;
            }
            else{
                printf("Achei iguais, %d = %d, em %d e %d da linha %d\n", matriz[n][j], matriz[n][i], j, i, n);
                pthread_exit(NULL);
            }
        }
    }

    return NULL;
}


void *verifyVertical(int n)
{
    for (int i = 0; i < linhas; i++){
        for (int j = i + 1; j < colunas; j++){
            if (matriz[j][n] != matriz[i][n]){
                printf("Não é um quadrado latino\n");
                pthread_exit(NULL);
                break;
            } else {
                printf("Achei iguais, %d = %d, em %d e %d da coluna %d\n", matriz[j][n], matriz[i][n], j, i, n);
                pthread_exit(NULL);
                break;
            }
        }
    }
    printf("É um quadrado\n");
    return NULL;
}

int main()
{
    int qnt_threads;

    printf("Digite a quantidade de threads\n");
    scanf("%d", &qnt_threads);

    pthread_t thread[qnt_threads];

    printf("Digite o numero de linhas\n");
    scanf("%d", &linhas);

    printf("Digite o numero de coluhas\n\n");
    scanf("%d", &colunas);    

    printf("Digite os valores da matriz\n"); 
    for(int i = 0; i < linhas; i++){
        for(int j = 0; j < colunas; j++){
            
            printf ("\nElemento[%d][%d] = ", i, j);   
            scanf("%d", &matriz[i][j]);     
        }
    }

    for (int i = 0; i < qnt_threads; i++){//faltou terminar
        pthread_create(&thread[i], NULL, verifyHorizontal(matriz[j]), (void *)&params[i]);
        pthread_create(&thread[i], NULL, verifyVertical(matriz[i]), (void *)&params[i]);
    }

    for (int i = 0; i < qnt_threads; i++)
    {
        pthread_join(thread[i], NULL);
    }
    return 0;
}