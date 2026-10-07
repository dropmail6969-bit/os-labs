#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>

/*
 * Печатает: имя процесса, его pid, ppid родителя и текущее время
 * в формате часы:минуты:секунды:миллисекунды.
 */
static void print_info(const char *who) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);

    struct tm tm_buf;
    localtime_r(&ts.tv_sec, &tm_buf);

    printf("[%-28s] pid=%5d ppid=%5d time=%02d:%02d:%02d:%03ld\n",
           who,
           (int)getpid(),
           (int)getppid(),
           tm_buf.tm_hour, tm_buf.tm_min, tm_buf.tm_sec,
           ts.tv_nsec / 1000000L);
    fflush(stdout);
}

int main(void) {
    print_info("Родитель (до fork)");

    /* --- Первый дочерний процесс --- */
    pid_t pid1 = fork();
    if (pid1 < 0) {
        perror("fork 1");
        return 1;
    } else if (pid1 == 0) {
        print_info("Дочерний 1 (старт)");
        sleep(1);
        print_info("Дочерний 1 (конец)");
        _exit(0);
    }

    /* --- Второй дочерний процесс --- */
    pid_t pid2 = fork();
    if (pid2 < 0) {
        perror("fork 2");
        return 1;
    } else if (pid2 == 0) {
        print_info("Дочерний 2 (старт)");
        sleep(1);
        print_info("Дочерний 2 (конец)");
        _exit(0);
    }

    /* --- Родитель --- */
    print_info("Родитель (после fork)");

    /* Список процессов — здесь увидим свои pid/ppid */
    printf("\n=== ps -x ===\n");
    system("ps -x");
    printf("=== конец ps -x ===\n\n");

    /* Дождаться обоих потомков */
    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);

    print_info("Родитель (все дети завершены)");
    return 0;
}
