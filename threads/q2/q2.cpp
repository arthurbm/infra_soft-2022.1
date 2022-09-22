#include <stdio.h>
#include <iostream>
#include <fstream>
#include <pthread.h>
#include <stdlib.h>
#include<unistd.h>


using namespace std;

#define numeroTrens 10
#define numeroIntersecao 5

pthread_mutex_t mutex=PTHREAD_MUTEX_INITIALIZER;

typedef struct args{
    int trens;
    int *intersections;
} args;

void *ferrovia(void *ar)
{
    args *argumentos = (args *) ar;

    for (int i = 0; i < 5; i++){
        pthread_mutex_lock(&mutex);
        printf("O trem %d está aguardando a liberação...[em espera]\n",argumentos->trens);
            
        if (argumentos->intersections[i] < 2) {

            argumentos->intersections[i]++;//região critica
            pthread_mutex_unlock(&mutex);
            printf("O trem %d está na intersessão == %d\n",argumentos->trens, i);
            //esperar 500 milissegundos usando pthreads para terminar a região critica
            usleep(500000);

            printf("O trem == %d terminou sua passagem na interseção %d\n",argumentos->trens, i);

            pthread_mutex_lock(&mutex);
            argumentos->intersections[i]--; //região critica
            pthread_mutex_unlock(&mutex);
        } else {
            i--;
            pthread_mutex_unlock(&mutex);
        }
    }
    return NULL;
}

int main()
{
    int i=0;

    pthread_t *thread=NULL; //um vetor de threads
    args *argumentos[numeroTrens+1];

    thread = (pthread_t *) malloc(numeroTrens*sizeof(pthread_t));//alocação da quantidade de threads
    void *intersections = calloc(numeroIntersecao + 1, sizeof(int));

    for(i = 0; i < numeroTrens+1; i++){
        //argumentos[i] = (args *) malloc(sizeof(args));
        argumentos[i] = (args *)malloc(sizeof(args));//alocação dos argumentos
        (*argumentos[i]).trens = i;
        (*argumentos[i]).intersections = (int *)intersections;

        pthread_create(&(thread[i]),NULL,ferrovia,(void *)argumentos[i]);// criacao das threads sendo referenciadas com o id acima
    }

    for(i=0;i<numeroTrens;i++){ // quando alguma thread terminar a execucao espera as outras aqui 
        pthread_join(thread[i],NULL);
    }
    
    pthread_exit(NULL);
    
    free(thread);
    free(argumentos);
    thread=NULL; 
    return 0;
}