#!/data/data/com.termux/files/usr/bin/bash

CC="${CC:-clang}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

pause() {
    echo
    echo -e "${CYAN}Нажмите Enter, чтобы вернуться в меню...${NC}"
    read -r _
}

header() {
    clear
    echo -e "${BOLD}=================================================${NC}"
    echo -e "${BOLD}   Лабораторная работа №2 — меню заданий${NC}"
    echo -e "${BOLD}=================================================${NC}"
    echo
}

# ---------------------------------------------------------
#  Компиляция всех исходников
# ---------------------------------------------------------
compile_all() {
    header
    echo -e "${YELLOW}>>> Компиляция всех программ${NC}"
    echo

    $CC task2.c -o task2
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка компиляции task2.c${NC}"
        pause; return
    fi
    echo -e "${GREEN}[OK]${NC} task2 собран"

    $CC variant4.c -o variant4
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка компиляции variant4.c${NC}"
        pause; return
    fi
    echo -e "${GREEN}[OK]${NC} variant4 собран"

    pause
}

# ---------------------------------------------------------
#  Задание 2
# ---------------------------------------------------------
task2_run() {
    header
    echo -e "${YELLOW}>>> Задание 2. Два fork() + ps -x${NC}"
    echo

    if [ ! -x ./task2 ]; then
        echo "Собираю task2..."
        $CC task2.c -o task2 || { echo -e "${RED}Ошибка компиляции${NC}"; pause; return; }
    fi

    ./task2
    pause
}

# ---------------------------------------------------------
#  Вариант 4 — с вводом параметров
# ---------------------------------------------------------
variant4_run() {
    header
    echo -e "${YELLOW}>>> Вариант 4. Поиск комбинации байт в каталоге${NC}"
    echo

    if [ ! -x ./variant4 ]; then
        echo "Собираю variant4..."
        $CC variant4.c -o variant4 || { echo -e "${RED}Ошибка компиляции${NC}"; pause; return; }
    fi

    read -r -p "Каталог (Enter = demo): " dir
    [ -z "$dir" ] && dir="demo"

    read -r -p "Комбинация байт (Enter = HELLO): " pat
    [ -z "$pat" ] && pat="HELLO"

    read -r -p "Максимум процессов N (Enter = 2): " N
    [ -z "$N" ] && N=2

    if [ ! -d "$dir" ]; then
        echo -e "${RED}Каталог не найден: $dir${NC}"
        echo "Сначала создайте демо-данные (пункт d в меню)"
        pause; return
    fi

    echo
    ./variant4 "$dir" "$pat" "$N"
    pause
}

# ---------------------------------------------------------
#  Демо-данные для варианта 4
# ---------------------------------------------------------
setup_demo() {
    header
    echo -e "${YELLOW}>>> Подготовка демонстрационных данных${NC}"
    echo
    rm -rf demo
    mkdir -p demo

    printf 'HELLO Ubuntu HELLO\n' > demo/a.txt
    printf 'hello world\n'        > demo/b.txt
    printf 'HELLO\n'              > demo/c.txt
    printf 'no match here\n'      > demo/d.txt

    echo "Создан каталог demo:"
    echo "  a.txt  = 'HELLO Ubuntu HELLO' (19 байт, 2 совпадения)"
    echo "  b.txt  = 'hello world'        (12 байт, 0 совпадений)"
    echo "  c.txt  = 'HELLO'              ( 6 байт, 1 совпадение)"
    echo "  d.txt  = 'no match here'      (14 байт, 0 совпадений)"
    echo
    echo -e "${GREEN}Готово${NC}"
    pause
}

# ---------------------------------------------------------
#  Автотест всех заданий
# ---------------------------------------------------------
run_all_tests() {
    header
    echo -e "${YELLOW}>>> Запуск автотестов лабы №2${NC}"
    echo
    if [ -x ./run_lab2.sh ]; then
        ./run_lab2.sh
    else
        echo -e "${RED}run_lab2.sh не найден${NC}"
    fi
    pause
}

# ---------------------------------------------------------
#  Главное меню
# ---------------------------------------------------------
main_menu() {
    while true; do
        header
        echo "Выберите действие:"
        echo
        echo "  1) Компилировать все программы"
        echo "  2) Задание 2 — два fork + ps -x"
        echo "  3) Вариант 4 — поиск комбинации байт"
        echo
        echo "  d) Подготовить демо-данные для варианта 4"
        echo "  a) Запустить автотесты (run_lab2.sh)"
        echo "  q) Выход"
        echo
        read -r -p "Ваш выбор: " choice

        case "$choice" in
            1) compile_all ;;
            2) task2_run ;;
            3) variant4_run ;;
            d|D) setup_demo ;;
            a|A) run_all_tests ;;
            q|Q)
                echo "Выход."
                exit 0
                ;;
            *)
                echo -e "${RED}Неверный выбор: $choice${NC}"
                sleep 1
                ;;
        esac
    done
}

main_menu
