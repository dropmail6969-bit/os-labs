#!/data/data/com.termux/files/usr/bin/bash

dir1="$1"
dir2="$2"

if [ $# -ne 2 ]; then
    echo "Использование: $0 <Dir1> <Dir2>"
    exit 1
fi

if [ ! -d "$dir1" ]; then
    echo "Каталог не найден: $dir1"
    exit 1
fi

if [ ! -d "$dir2" ]; then
    echo "Каталог не найден: $dir2"
    exit 1
fi

# Собираем только файлы (без подкаталогов)
real1=()
for f in "$dir1"/*; do
    [ -f "$f" ] && real1+=("$f")
done

real2=()
for f in "$dir2"/*; do
    [ -f "$f" ] && real2+=("$f")
done

n1=${#real1[@]}
n2=${#real2[@]}

echo "Каталог 1: $dir1  ($n1 файлов)"
echo "Каталог 2: $dir2  ($n2 файлов)"
echo "----------------------------------------"

checked=0
found=0

for f1 in "${real1[@]}"; do
    for f2 in "${real2[@]}"; do
        checked=$((checked + 1))
        if cmp -s "$f1" "$f2"; then
            echo "Совпадение: $f1  <->  $f2"
            found=$((found + 1))
        fi
    done
done

echo "----------------------------------------"
echo "Просмотрено файлов в $dir1: $n1"
echo "Просмотрено файлов в $dir2: $n2"
echo "Сравнений выполнено: $checked"
echo "Найдено совпадений: $found"
