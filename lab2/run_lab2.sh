#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
#  Автотест лабораторной работы №2
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

LOG_T2=".t2.log"
LOG_V4=".v4.log"

# =========================================================
#  Компиляция
# =========================================================
echo
info "Компиляция"

$CC task2.c -o task2 2> .cc_t2.log
check $? "task2.c скомпилирован"

$CC variant4.c -o variant4 2> .cc_v4.log
check $? "variant4.c скомпилирован"

if [ $passed -lt 2 ]; then
    echo
    echo "Компиляция не прошла — тесты невозможны"
    cat .cc_t2.log .cc_v4.log 2>/dev/null
    exit 1
fi

# =========================================================
#  Задание 2. task2
# =========================================================
echo
info "Задание 2. task2 — два fork + ps -x"

./task2 > "$LOG_T2" 2>&1
check $? "task2 завершился с кодом 0"

for line in \
    "Родитель (до fork)" \
    "Родитель (после fork)" \
    "Родитель (все дети завершены)" \
    "Дочерний 1 (старт)" \
    "Дочерний 1 (конец)" \
    "Дочерний 2 (старт)" \
    "Дочерний 2 (конец)"
do
    grep -qF "$line" "$LOG_T2"
    check $? "Есть строка '$line'"
done

# Извлекаем значения — используем префикс '] pid=' и '] pid= X ppid= Y'
extract_pid()  { grep -F "$1" "$LOG_T2" | sed -E 's/.*\] pid=[ ]*([0-9]+).*/\1/'; }
extract_ppid() { grep -F "$1" "$LOG_T2" | sed -E 's/.*\] pid=[ ]*[0-9]+[ ]+ppid=[ ]*([0-9]+).*/\1/'; }

parent_pid=$(extract_pid "Родитель (до fork)")
child1_pid=$(extract_pid "Дочерний 1 (старт)")
child2_pid=$(extract_pid "Дочерний 2 (старт)")
child1_ppid=$(extract_ppid "Дочерний 1 (старт)")
child2_ppid=$(extract_ppid "Дочерний 2 (старт)")

echo "  parent_pid=$parent_pid  child1=(pid=$child1_pid ppid=$child1_ppid)  child2=(pid=$child2_pid ppid=$child2_ppid)"

# У родителя один и тот же pid во всех строках
n_parent_pids=$(grep -F "Родитель (" "$LOG_T2" | sed -E 's/.*\] pid=[ ]*([0-9]+).*/\1/' | sort -u | wc -l)
[ "$n_parent_pids" -eq 1 ]
check $? "У родителя один и тот же pid во всех строках"

[ "$child1_ppid" = "$parent_pid" ]
check $? "ppid дочернего 1 = pid родителя ($child1_ppid = $parent_pid)"

[ "$child2_ppid" = "$parent_pid" ]
check $? "ppid дочернего 2 = pid родителя ($child2_ppid = $parent_pid)"

[ "$child1_pid" != "$child2_pid" ]
check $? "pid дочерних процессов различаются ($child1_pid ≠ $child2_pid)"

# Три pid в ps -x
n_in_ps=0
for pid in "$parent_pid" "$child1_pid" "$child2_pid"; do
    if grep -qE "^[[:space:]]*$pid[[:space:]]" "$LOG_T2"; then
        n_in_ps=$((n_in_ps + 1))
    fi
done
[ "$n_in_ps" -eq 3 ]
check $? "Все три pid найдены в выводе ps -x ($n_in_ps/3)"

grep -qE "time=[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{3}" "$LOG_T2"
check $? "Время в формате чч:мм:сс:мс"

# =========================================================
#  Вариант 4. variant4
# =========================================================
echo
info "Вариант 4. variant4 — поиск комбинации байт"

rm -rf test_v4
mkdir -p test_v4
printf 'HELLO Ubuntu HELLO\n' > test_v4/a.txt
printf 'hello world\n'        > test_v4/b.txt
printf 'HELLO\n'              > test_v4/c.txt
printf 'no match here\n'      > test_v4/d.txt

./variant4 test_v4 "HELLO" 2 > "$LOG_V4" 2>&1
check $? "variant4 завершился с кодом 0"

n_lines=$(grep -cE "pid=[ ]*[0-9]+ файл=test_v4/" "$LOG_V4")
[ "$n_lines" -eq 4 ]
check $? "Обработано 4 файла (по одному потомку на файл)"

n_pids=$(grep -oE "pid=[ ]*[0-9]+" "$LOG_V4" | grep -oE "[0-9]+" | sort -u | wc -l)
[ "$n_pids" -ge 4 ]
check $? "Использовано минимум 4 разных pid ($n_pids)"

grep -qE "a\.txt.*просмотрено=[ ]*19.*найдено=2" "$LOG_V4"
check $? "a.txt: 19 байт, 2 совпадения"

grep -qE "b\.txt.*просмотрено=[ ]*12.*найдено=0" "$LOG_V4"
check $? "b.txt: 12 байт, 0 совпадений"

grep -qE "c\.txt.*просмотрено=[ ]*6.*найдено=1" "$LOG_V4"
check $? "c.txt: 6 байт, 1 совпадение"

grep -qE "d\.txt.*просмотрено=[ ]*14.*найдено=0" "$LOG_V4"
check $? "d.txt: 14 байт, 0 совпадений"

# Проверка N=1: должно быть не более 1 процесса-ребёнка одновременно.
# Косвенно: с N=1 обработка идёт строго последовательно.
./variant4 test_v4 "HELLO" 1 > .v4_n1.log 2>&1
check $? "Запуск с N=1 завершился успешно"

grep -qE "a\.txt.*найдено=2" .v4_n1.log
check $? "N=1: a.txt обработан корректно"

# =========================================================
#  Обработка ошибок variant4
# =========================================================
echo
info "variant4: обработка ошибок"

./variant4 2> .v4_usage.log
[ $? -ne 0 ] && grep -q "Использование" .v4_usage.log
check $? "Нет аргументов → подсказка и код ошибки"

./variant4 нет_такого_каталога "HELLO" 2 > .v4_no_dir.log 2>&1
[ $? -ne 0 ]
check $? "Несуществующий каталог → ненулевой код"

./variant4 test_v4 "HELLO" 0 > .v4_n0.log 2>&1
[ $? -ne 0 ] && grep -q "N должно" .v4_n0.log
check $? "N=0 → ошибка валидации"

# =========================================================
#  Итог
# =========================================================
echo
echo "========================================"
echo "Пройдено $passed из $total проверок"
echo "========================================"

if [ "$passed" -eq "$total" ]; then
    ok "Все тесты лабы №2 пройдены"
    exit 0
else
    fail "Есть непройденные проверки"
    exit 1
fi
