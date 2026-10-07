#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
#  Запуск всех заданий лабораторной работы №1
# =========================================================

CC="${CC:-clang}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
info() { echo -e "${YELLOW}==>${NC}    $1"; }

total=0
passed=0

check() {
    total=$((total + 1))
    if [ "$1" -eq 0 ]; then
        ok "$2"
        passed=$((passed + 1))
    else
        fail "$2"
    fi
}

# Логи пишем в текущий каталог, а не в /tmp (в Termux он недоступен)
LOG_OK=".s6_ok.log"
LOG_ERR=".s6_err.log"

# =========================================================
#  Задание 3. Программа 1.c
# =========================================================
echo
info "Задание 3. Компиляция и запуск 1.c"

$CC 1.c -o 1.exe
check $? "Компиляция 1.c прошла без ошибок"

out=$(./1.exe)
[ "$out" = "HELLO Ubuntu" ]
check $? "Вывод программы 1.exe: '$out'"

# =========================================================
#  Задание 4. Аргументы командной строки
# =========================================================
echo
info "Задание 4. Вывод аргументов командной строки"

rm -f args.txt
./script4.sh один два "три слова" > /dev/null
check $? "script4.sh выполнился"

[ -f args.txt ] && grep -q "один" args.txt && grep -q "три слова" args.txt
check $? "args.txt содержит переданные аргументы"

# =========================================================
#  Задание 5. Файлы с заданным расширением
# =========================================================
echo
info "Задание 5. Поиск файлов по расширению"

rm -rf dir5 && mkdir dir5
touch dir5/a.txt dir5/b.txt dir5/c.c
rm -f result.txt
./script5.sh result.txt dir5 txt > /dev/null
check $? "script5.sh выполнился"

grep -q "a.txt" result.txt && grep -q "b.txt" result.txt && ! grep -q "c.c" result.txt
check $? "result.txt содержит только .txt файлы"

# =========================================================
#  Задание 6. Компиляция с контролем ошибок
# =========================================================
echo
info "Задание 6. Компиляция с обработкой ошибок"

# Успешный случай
./script6.sh 1.c 1.exe > "$LOG_OK" 2>&1
check $? "script6.sh компилирует и запускает корректный файл"

# Случай с ошибкой
cat > bad.c <<'BADEOF'
int main(void) {
    printf("no stdio\n")
    return 0;
}
BADEOF

rm -f bad.exe
./script6.sh bad.c bad.exe > "$LOG_ERR" 2>&1
grep -q "Ошибка компиляции" "$LOG_ERR"
check $? "script6.sh сообщает об ошибке компиляции"

[ ! -f bad.exe ]
check $? "bad.exe не создан при ошибке компиляции"

# =========================================================
#  Задание 7 (вариант 4). Сравнение двух каталогов
# =========================================================
echo
info "Задание 7 (вар. 4). Сравнение содержимого каталогов"

rm -rf Dir1 Dir2
mkdir -p Dir1 Dir2
echo "hello"     > Dir1/a.txt
echo "world"     > Dir1/b.txt
echo "same"      > Dir1/c.txt
echo "same"      > Dir2/x.txt
echo "world"     > Dir2/y.txt
echo "different" > Dir2/z.txt

out=$(./script7.sh Dir1 Dir2)
check $? "script7.sh выполнился"

echo "$out" | grep -q "Совпадение: Dir1/b.txt  <->  Dir2/y.txt"
check $? "Найдено совпадение b.txt <-> y.txt"

echo "$out" | grep -q "Совпадение: Dir1/c.txt  <->  Dir2/x.txt"
check $? "Найдено совпадение c.txt <-> x.txt"

echo "$out" | grep -q "Найдено совпадений: 2"
check $? "Счётчик совпадений = 2"

# =========================================================
#  Итог
# =========================================================
echo
echo "========================================"
echo "Пройдено $passed из $total проверок"
echo "========================================"

if [ "$passed" -eq "$total" ]; then
    ok "Все задания лабы №1 выполнены"
    exit 0
else
    fail "Есть непройденные проверки"
    exit 1
fi
