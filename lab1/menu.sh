#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
#  Интерактивное меню запуска заданий лабораторной работы №1
# =========================================================

CC="${CC:-clang}"

# Цвета
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
    echo -e "${BOLD}   Лабораторная работа №1 — меню заданий${NC}"
    echo -e "${BOLD}=================================================${NC}"
    echo
}

# ---------------------------------------------------------
#  Задание 3. Компиляция и запуск 1.c
# ---------------------------------------------------------
task3() {
    header
    echo -e "${YELLOW}>>> Задание 3. Компиляция и запуск 1.c${NC}"
    echo

    if [ ! -f 1.c ]; then
        echo -e "${RED}Файл 1.c не найден${NC}"
        pause; return
    fi

    echo "Компиляция: $CC 1.c -o 1.exe"
    $CC 1.c -o 1.exe
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка компиляции${NC}"
        pause; return
    fi
    echo -e "${GREEN}Компиляция успешна${NC}"
    echo
    echo "Запуск: ./1.exe"
    echo "Результат:"
    ./1.exe
    pause
}

# ---------------------------------------------------------
#  Задание 4. Аргументы командной строки
# ---------------------------------------------------------
task4() {
    header
    echo -e "${YELLOW}>>> Задание 4. Вывод аргументов командной строки${NC}"
    echo
    echo "Введите аргументы через пробел (например: один два \"три слова\"):"
    read -r -p "> " args
    echo

    # Разбираем строку в массив через eval — так сохраняются кавычки
    eval "set -- $args"

    rm -f args.txt
    ./script4.sh "$@"
    echo
    echo -e "${GREEN}--- Содержимое args.txt ---${NC}"
    cat args.txt
    pause
}

# ---------------------------------------------------------
#  Задание 5. Файлы с заданным расширением
# ---------------------------------------------------------
task5() {
    header
    echo -e "${YELLOW}>>> Задание 5. Поиск файлов по расширению${NC}"
    echo

    read -r -p "Каталог (Enter = текущий): " dir
    [ -z "$dir" ] && dir="."

    read -r -p "Расширение (без точки, например txt): " ext
    [ -z "$ext" ] && ext="txt"

    read -r -p "Файл результата (Enter = result.txt): " out
    [ -z "$out" ] && out="result.txt"

    echo
    ./script5.sh "$out" "$dir" "$ext"
    echo
    echo -e "${GREEN}--- Содержимое $out ---${NC}"
    cat "$out"
    pause
}

# ---------------------------------------------------------
#  Задание 6. Компиляция с контролем ошибок
# ---------------------------------------------------------
task6() {
    header
    echo -e "${YELLOW}>>> Задание 6. Компиляция с обработкой ошибок${NC}"
    echo

    read -r -p "Исходный файл (Enter = 1.c): " src
    [ -z "$src" ] && src="1.c"

    read -r -p "Имя результата (Enter = 1.exe): " exe
    [ -z "$exe" ] && exe="1.exe"

    echo
    ./script6.sh "$src" "$exe"

    echo
    echo -e "${CYAN}Проверка ветки с ошибкой компиляции...${NC}"

    cat > .bad_tmp.c <<'BADEOF'
int main(void) {
    printf("no stdio\n")
    return 0;
}
BADEOF

    echo
    echo "Запуск на заведомо битом файле .bad_tmp.c:"
    rm -f .bad_tmp.exe
    ./script6.sh .bad_tmp.c .bad_tmp.exe

    if [ ! -f .bad_tmp.exe ]; then
        echo -e "${GREEN}Файл .bad_tmp.exe не создан — ветка ошибки работает${NC}"
    else
        echo -e "${RED}Ошибка: exe создан, а не должен${NC}"
    fi

    rm -f .bad_tmp.c .bad_tmp.exe
    pause
}

# ---------------------------------------------------------
#  Задание 7 (вариант 4). Сравнение двух каталогов
# ---------------------------------------------------------
task7() {
    header
    echo -e "${YELLOW}>>> Задание 7 (вар. 4). Сравнение содержимого каталогов${NC}"
    echo

    read -r -p "Первый каталог (Enter = Dir1): " d1
    [ -z "$d1" ] && d1="Dir1"

    read -r -p "Второй каталог (Enter = Dir2): " d2
    [ -z "$d2" ] && d2="Dir2"

    echo
    ./script7.sh "$d1" "$d2"
    pause
}

# ---------------------------------------------------------
#  Демо-данные для задания 7
# ---------------------------------------------------------
setup_demo7() {
    header
    echo -e "${YELLOW}>>> Подготовка демонстрационных данных для задания 7${NC}"
    echo
    rm -rf Dir1 Dir2
    mkdir -p Dir1 Dir2
    echo "hello"     > Dir1/a.txt
    echo "world"     > Dir1/b.txt
    echo "same"      > Dir1/c.txt
    echo "same"      > Dir2/x.txt
    echo "world"     > Dir2/y.txt
    echo "different" > Dir2/z.txt

    echo "Созданы каталоги:"
    echo "  Dir1: a.txt(hello) b.txt(world) c.txt(same)"
    echo "  Dir2: x.txt(same) y.txt(world) z.txt(different)"
    echo
    echo -e "${GREEN}Готово${NC}"
    pause
}

# ---------------------------------------------------------
#  Запуск всех заданий (аналог run_lab1.sh)
# ---------------------------------------------------------
run_all() {
    header
    echo -e "${YELLOW}>>> Запуск всех заданий${NC}"
    echo
    if [ -x ./run_lab1.sh ]; then
        ./run_lab1.sh
    else
        echo -e "${RED}run_lab1.sh не найден в текущем каталоге${NC}"
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
        echo "  1) Задание 3 — компиляция и запуск 1.c"
        echo "  2) Задание 4 — вывод аргументов командной строки"
        echo "  3) Задание 5 — файлы с заданным расширением"
        echo "  4) Задание 6 — компиляция с обработкой ошибок"
        echo "  5) Задание 7 (вар. 4) — сравнение двух каталогов"
        echo
        echo "  d) Подготовить демо-данные для задания 7"
        echo "  a) Запустить все задания (run_lab1.sh)"
        echo "  q) Выход"
        echo
        read -r -p "Ваш выбор: " choice

        case "$choice" in
            1) task3 ;;
            2) task4 ;;
            3) task5 ;;
            4) task6 ;;
            5) task7 ;;
            d|D) setup_demo7 ;;
            a|A) run_all ;;
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

# Запуск
main_menu
