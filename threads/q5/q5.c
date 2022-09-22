// Dining philosophers problem with pthreads
// Compile: gcc -o q6 q6.c -lpthread
// Run: ./q6

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>


#define N 5 // number of philosophers
#define THINKING 0
#define HUNGRY 1
#define EATING 2

int state[N];
pthread_mutex_t mutex[N];

int left_neighbor(int philosopher_number) {
    return ((philosopher_number + (N - 1)) % N);
}

int right_neighbor(int philosopher_number) {
    return ((philosopher_number + 1) % N);
}

void test(int i) {
  if (state[i] == HUNGRY && state[left_neighbor(i)] != EATING && state[right_neighbor(i)] != EATING) {
    state[i] = EATING;
    pthread_mutex_unlock(&mutex[i]);
  }
}

void think(int i) {
  printf("Philosopher %d is thinking\n", i);
}

void get_forks(int i) {
  pthread_mutex_lock(&mutex[i]);
  pthread_mutex_lock(&mutex[i + 1]);
  state[i] = HUNGRY;
  test(i);
  pthread_mutex_unlock(&mutex[i]);
  pthread_mutex_unlock(&mutex[i + 1]);

  printf("Philosopher %d has forks\n", i);
}

void eat(int i) {
  printf("Philosopher %d is eating\n", i);
}

void put_forks(int i) {
  pthread_mutex_lock(&mutex[i]);
  pthread_mutex_lock(&mutex[i + 1]);

  state[i] = THINKING;
  test(left_neighbor(i));
  test(right_neighbor(i));

  pthread_mutex_unlock(&mutex[i + 1]);
  pthread_mutex_unlock(&mutex[i]);

  printf("Philosopher %d has put forks\n", i);
}

void *have_dinner(void *thread_id) {
  int tid = *(int *)thread_id;
  while (1) {
    think(tid);
    get_forks(tid);
    eat(tid);
    put_forks(tid);
  }

  return NULL;
}

int main(int argc, char *argv[])
{
  // pthread_t philosophs[N];
  pthread_t *philosophs = (pthread_t *)  malloc(N*sizeof(pthread_t)); 
  int *philosophs_id= (int* ) malloc(N*sizeof(int));  // The thread id is used to handle the algorithm for each thread

  for (int i = 0; i < N; i++){
    philosophs_id[i] = i;
    if (pthread_create(&philosophs[i],NULL, have_dinner, (void *) &philosophs_id[i]) != 0) {
        perror("Failed to create thread\n");
    }
  }

  for (int i = 0; i < N; i++) {
    pthread_join(philosophs[i], NULL);
  }

  free(philosophs);
  free(philosophs_id);

  pthread_exit(NULL);

  return 0;
}