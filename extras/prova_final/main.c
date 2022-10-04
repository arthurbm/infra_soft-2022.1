// Hello world in C
#include <stdio.h>
#include<pthread.h>
#include<stdlib.h>
#include<unistd.h>

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
int state = 0; // 0 = banks are closed, 1 = banks are open
int count = 0; // number of iterations

void *handle_bank_state() {
    while (1) {
        pthread_mutex_lock(&mutex);
        if (state == 0) {
            printf("Banks are closed, opening banks\n");
            count++;
            printf("Number of iterations: %d\n", count);
            state = 1;
            pthread_cond_broadcast(&cond);
        } else {
            printf("Banks are open, closing banks\n");
            count++;
            printf("Number of iterations: %d\n", count);
            state = 0;
            pthread_cond_broadcast(&cond);
        }
        pthread_mutex_unlock(&mutex);
        sleep(2);
    }
}

void *check_banks(void *param) {
    int id = *(int *) param;
    while (1) {
        pthread_mutex_lock(&mutex);

        pthread_cond_wait(&cond, &mutex);

        if (state == 0) printf("Bank %d is closed\n", id);
        else printf("Bank %d is open\n", id);

        pthread_mutex_unlock(&mutex);
    }
}

int main()
{
    pthread_t central_bank, banks[10];
    int id[10];

    printf("cheguei\n");
    pthread_create(&central_bank, NULL, handle_bank_state, NULL);
    for (int i = 0; i < 10; i++) {
        id[i] = i;
        pthread_create(&banks[i], NULL, check_banks, &id[i]);
    }

    pthread_join(central_bank, NULL);
    for (int i = 0; i < 10; i++) {
        pthread_join(banks[i], NULL);
    }

    pthread_exit(NULL);

    return 0;
}