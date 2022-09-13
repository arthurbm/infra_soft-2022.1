// Dining philosophers problem with pthreads
// Compile: gcc -o q6 q6.c -lpthread
// Run: ./q6

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define N 4                  // number of philosophers
#define LEFT (i + N - 1) % N // number of i's left neighbor
#define RIGHT (i + 1) % N    // number of i's right neighbor
#define THINKING 0
#define HUNGRY 1
#define EATING 2

int state[N];
pthread_mutex_t mutex;
pthread_cond_t cond[N];

void *philosopher(void *arg);

void think(int i) {
  printf("Philosopher %d started thinking", i);
  sleep(1);
  printf("Philosopher %d stopped thinking", i);
}

void get_forks(int i) {
  pthread_mutex_lock(&mutex);
  state[i] = HUNGRY;
  test(i);
  while (state[i] != EATING)
    pthread_cond_wait(&cond[i], &mutex);
  pthread_mutex_unlock(&mutex);
}

void eat(int i) {
  printf("Philosopher %d started eating", i);
  sleep(1);
  printf("Philosopher %d stopped eating", i);
}

void put_forks(int i) {
  pthread_mutex_lock(&mutex);
  state[i] = THINKING;
  test(LEFT);
  test(RIGHT);
  pthread_mutex_unlock(&mutex);
}

void test(int i) {
  if (state[i] == HUNGRY && state[LEFT] != EATING && state[RIGHT] != EATING) {
    state[i] = EATING;
    pthread_cond_signal(&cond[i]);
  }
}

int main(int argc, char *argv[])
{
  int i;
  pthread_t tid[N];

  pthread_mutex_init(&mutex, NULL);
  for (i = 0; i < N; i++) {
    pthread_cond_init(&cond[i], NULL);
  }

  for (i = 0; i < N; i++) {
    pthread_create(&tid[i], NULL, philosopher, (void *)i);
    printf("Philosopher %d is thinking", i);
  }

  // Is it necessary?
  for (i = 0; i < N; i++) {
    pthread_join(tid[i], NULL);
  }

  pthread_exit(NULL);

  return 0;
}