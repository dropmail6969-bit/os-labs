#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <dirent.h>
#include <fcntl.h>
#include <sys/stat.h>

#define MAX_PATTERN 255
#define BUF_SIZE    4096

/*
 * Ищет комбинацию pattern длиной plen во файле path.
 * Печатает pid, имя файла, число просмотренных байт, число вхождений.
 */
static void search_in_file(const char *path,
                           const unsigned char *pattern,
                           int plen)
{
    int fd = open(path, O_RDONLY);
    if (fd < 0) {
        printf("pid=%d файл=%s: не удалось открыть\n", (int)getpid(), path);
        fflush(stdout);
        return;
    }

    unsigned char buf[BUF_SIZE + MAX_PATTERN];
    int carry = 0;               /* сколько байт перенесено из прошлого буфера */
    long long total_read = 0;
    long long found = 0;
    ssize_t n;

    while ((n = read(fd, buf + carry, BUF_SIZE)) > 0) {
        ssize_t total = n + carry;

        /* ищем шаблон во всём буфере */
        for (ssize_t i = 0; i + plen <= total; i++) {
            if (memcmp(buf + i, pattern, plen) == 0)
                found++;
        }

        /* последние plen-1 байт переносим в начало следующей итерации,
         * чтобы поймать вхождение, разрезанное границей буфера */
        carry = (plen - 1 < total) ? plen - 1 : (int)total;
        if (carry > 0)
            memmove(buf, buf + total - carry, carry);

        total_read += n;
    }

    close(fd);

    printf("pid=%5d файл=%-30s просмотрено=%8lld найдено=%lld\n",
           (int)getpid(), path, total_read, found);
    fflush(stdout);
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr,
                "Использование: %s <каталог> <комбинация_байт> <N>\n"
                "  N — максимальное число одновременных процессов\n",
                argv[0]);
        return 1;
    }

    const char *dir         = argv[1];
    const char *pattern_str = argv[2];
    int N                   = atoi(argv[3]);

    if (N < 1) {
        fprintf(stderr, "N должно быть >= 1\n");
        return 1;
    }

    int plen = (int)strlen(pattern_str);
    if (plen < 1 || plen >= MAX_PATTERN) {
        fprintf(stderr, "Длина комбинации должна быть от 1 до %d байт\n",
                MAX_PATTERN - 1);
        return 1;
    }

    unsigned char pattern[MAX_PATTERN];
    memcpy(pattern, pattern_str, plen);

    DIR *d = opendir(dir);
    if (!d) {
        perror("opendir");
        return 1;
    }

    printf("Каталог: %s\nШаблон: ", dir);
    for (int i = 0; i < plen; i++) printf("%02X ", pattern[i]);
    printf("('%s'), длина %d\nМаксимум процессов: %d\n\n",
           pattern_str, plen, N);

    struct dirent *entry;
    int running = 0;

    while ((entry = readdir(d)) != NULL) {
        if (entry->d_name[0] == '.') continue;

        char path[4096];
        snprintf(path, sizeof(path), "%s/%s", dir, entry->d_name);

        struct stat st;
        if (stat(path, &st) < 0) continue;
        if (!S_ISREG(st.st_mode)) continue;      /* только обычные файлы */

        /* ждём, пока освободится слот */
        while (running >= N) {
            wait(NULL);
            running--;
        }

        pid_t pid = fork();
        if (pid < 0) {
            perror("fork");
        } else if (pid == 0) {
            search_in_file(path, pattern, plen);
            _exit(0);
        } else {
            running++;
        }
    }

    closedir(d);

    /* дожидаемся всех оставшихся детей */
    while (running > 0) {
        wait(NULL);
        running--;
    }

    return 0;
}
