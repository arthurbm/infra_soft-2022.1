#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
#include<unistd.h>

#define MAX_MEALS 10
#define MAX_WAIT_TIME 3000000
#define PHILOSOPHER_NUMBER 7

#define THINKING 0
#define EATING 1
#define HUNGRY 2

pthread_mutex_t mutex_forks[PHILOSOPHER_NUMBER];

typedef enum { false, true } bool;

struct TheDiningPhilosophers
{
    int state[PHILOSOPHER_NUMBER];
    pthread_cond_t condition[PHILOSOPHER_NUMBER];
    long total_wait_time[PHILOSOPHER_NUMBER];
    long count[PHILOSOPHER_NUMBER];
};

struct TheDiningPhilosophers philosophersObj;

long time_wait_start[PHILOSOPHER_NUMBER];

// Gets the clock time at this moment
long get_posix_clock_time()
{
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0)
    {
        return (long) (ts.tv_sec * 1000000000 + ts.tv_nsec);
    }
    return 0;
}

bool testRightNeighbour(int i) {
    return philosophersObj.state[(i + 1) % PHILOSOPHER_NUMBER] != EATING;
}

bool testLeftNeighbour(int i) {
    return philosophersObj.state[(i + PHILOSOPHER_NUMBER - 1) % PHILOSOPHER_NUMBER] != EATING;
}

// Check if neighbours aren't eating and philosopher isn't starving. Change state to eating and signal the condition
void check_forks(int i)
{
    printf("Philosopher %d looking for forks\n", i);
    if (philosophersObj.state[i] == HUNGRY && testLeftNeighbour(i) && testRightNeighbour(i))
    {
        philosophersObj.state[i] = EATING;

        //wait time is equal to start time - time at this moment
        time_wait_start[i] += get_posix_clock_time();
        philosophersObj.total_wait_time[i] += time_wait_start[i];

        // signal that doesn't necessarilly unlock mutex
        pthread_cond_signal(&philosophersObj.condition[i]);
    }
}

void put_forks(int phil_number)
{
    static int meals_count = 0;

    pthread_mutex_lock(&mutex_forks[phil_number]);

    philosophersObj.count[phil_number] += 1;
    philosophersObj.state[phil_number] = THINKING;

    printf("Philosopher %d finish eating\n", phil_number);

    meals_count++;
    printf("#Eating count = %d\n\n", meals_count);
    if (meals_count == MAX_MEALS)
    {
        exit(0);
    }
    check_forks((phil_number + PHILOSOPHER_NUMBER - 1) % PHILOSOPHER_NUMBER);
    check_forks((phil_number + 1) % PHILOSOPHER_NUMBER);
    pthread_mutex_unlock(&mutex_forks[phil_number]);
}

void get_forks(int phil_number)
{
    pthread_mutex_lock(&mutex_forks[phil_number]);

    philosophersObj.state[phil_number] = HUNGRY;
    printf("Philosopher %d is hungry\n", phil_number);

    // saving start time
    time_wait_start[phil_number] = (-1) * get_posix_clock_time();

    check_forks(phil_number);
    if (philosophersObj.state[phil_number] != EATING)
    {
        pthread_cond_wait(&philosophersObj.condition[phil_number], &mutex_forks[phil_number]);
    }
    pthread_mutex_unlock(&mutex_forks[phil_number]);
}

void think(int phil_number)
{
    srand(time(NULL) + phil_number);
    int think_time = (rand() % 3) + 1;
    philosophersObj.state[phil_number] = THINKING;
    printf("Philosopher %d is thinking\n", phil_number);
    sleep(think_time);
}

void eat(int phil_number)
{
    srand(time(NULL) + phil_number);
    int eat_time = (rand() % 3) + 1;
    philosophersObj.state[phil_number] = EATING;
    printf("Philosopher %d is eating\n", phil_number);
    sleep(eat_time);
}

void *philosopher(void *param)
{
    int phil_number = *(int *) param;
    while (1)
    {
        think(phil_number);
        get_forks(phil_number);
        eat(phil_number);
        put_forks(phil_number);
    }
}

int main()
{
    pthread_t thread[PHILOSOPHER_NUMBER];
    int id[PHILOSOPHER_NUMBER];

    for (int i = 0; i < PHILOSOPHER_NUMBER; i++)
    {
        id[i] = i;
        philosophersObj.state[i] = THINKING;
        philosophersObj.count[i] = 0;
        philosophersObj.total_wait_time[i] = 0;
        time_wait_start[i] = 0;
        pthread_create(&thread[i], NULL, &philosopher, &id[i]);
    }

    for (int i = 0; i < PHILOSOPHER_NUMBER; i++)
    {
        pthread_join(thread[i], NULL);
    }
}