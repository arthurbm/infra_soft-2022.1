// Steps do execute program:

// 1 - You need to be in the /q1 folder
// 2 - gcc -g -pthread 1.c -o 1.out
// 3 - ./1.out

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

// Notes
// 1 - If you add or remove a file, you need to change the value of the constant N and the files array
// 2 - If you add numbers to files larger than the amount defined in C, it will not be possible to count. I added some cases, to demonstrate the behavior.

#define N 10 // Number of files
#define C 10 // Number of candidates
#define T 2 // Number of threads

char *files[N] = {"1.in", "2.in", "3.in", "4.in", "5.in", "6.in", "7.in", "8.in", "9.in", "10.in"};
int fileIndexToBeRead = N;
int arrCandidatesVotes[C] = { 0 };

pthread_t threads[T];
pthread_mutex_t mutexCandidates [C], mutexFileIndexControl = PTHREAD_MUTEX_INITIALIZER;

void* fileRead() {
    if (fileIndexToBeRead > 0) {
      int fileIndex = fileIndexToBeRead;

      // While changing index value of file to be read, mutex lock
      pthread_mutex_lock(&mutexFileIndexControl);
      fileIndexToBeRead--;
      pthread_mutex_unlock(&mutexFileIndexControl);

      FILE *file;
      int res, candidateIndex;
    
      file = fopen(files[fileIndex - 1], "rt");
      
      if (file == NULL)
      {
          fprintf(stderr, "There was an error trying to open the file!\n");
          exit(-1);
      }
      
      while (!feof(file))
      {
          res = fscanf(file, "%d", &candidateIndex);
    
          if (res != EOF)
          {
            if (candidateIndex >= 0 && candidateIndex <= C) {
              // While updating candidates total value, mutex lock
              pthread_mutex_lock(&mutexCandidates[candidateIndex]);
              
              arrCandidatesVotes[candidateIndex] += 1;
                  
              pthread_mutex_unlock(&mutexCandidates[candidateIndex]);
            } else {
              printf("\nO valor (%d) está fora do range de candidatos(0 - %d)", candidateIndex, C);
            }
          }
      }
      
      fclose(file);
      fileRead();
    }
  pthread_exit(NULL);
}

void printCandidatesArray() {

    printf("\n\nAPURAÇÃO DOS VOTOS\n");

    int i;
    for (i = 0; i < C; i++) {
      if (i == 0) {
        printf("\nVotos Brancos: %i", arrCandidatesVotes[i]);
      } else {
        printf("\nVotos Candidato %i: %d ", i, arrCandidatesVotes[i]);
      }
    }
    
    putchar('\n');
}

void printWinnerCandidate() {
  int i, winnerCandidateIndex = 0, winnerCandidateValue = 0;

  for (i = 0; i < C; i++) {
    if (arrCandidatesVotes[i] > winnerCandidateValue) {
      winnerCandidateIndex = i;
      winnerCandidateValue = arrCandidatesVotes[i];
    }
  }
  printf("\nRESULTADO FINAL\n\nCandidato %d venceu com %d votos\n", winnerCandidateIndex, winnerCandidateValue);

}

void printVotePercentagePerCandidate() {
  int i, totalVotes = 0;

  for (i = 0; i < C; i++) {
    totalVotes += arrCandidatesVotes[i];
  }

  printf("\n\nPERCENTUAL DE VOTOS POR CANDIDATO\n\n");

  for (i = 0; i < C; i++) {
    if (i == 0) {
      printf("Votos Brancos: %.2f%%\n", (float) arrCandidatesVotes[i] / totalVotes * 100);
    } else {
      printf("Votos Candidato %i: %.2f%%\n", i, (float) arrCandidatesVotes[i] / totalVotes * 100);
    }
  }
}

int main()
{
    int i;
    for (i = 0; i < C; i++)
    {
        pthread_mutex_init(&mutexCandidates[i], NULL);
    }
  
    for (i = 0; i < T; i++)
    {
      if ((pthread_create(&threads[i], NULL, fileRead, NULL) != 0)) {
        perror("Failed to created thread");
      }
    }
  
    for (i = 0; i < T; i++)
    {
      if ((pthread_join(threads[i], NULL)) != 0) {
        perror("Failed to join thread");
      }
    }
  
    for (i = 0; i < C; i++)
    {
        pthread_mutex_destroy(&mutexCandidates[i]);
    }

    printCandidatesArray();
    printVotePercentagePerCandidate();
    printWinnerCandidate();

    pthread_exit(NULL);
    return 0;
}