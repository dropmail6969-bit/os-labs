#!/data/data/com.termux/files/usr/bin/bash

out="$1"
dir="$2"
ext="$3"

if [ $# -ne 3 ]; then
    echo "Использование: $0 <файл_результата> <каталог> <расширение>"
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "Каталог не найден: $dir"
    exit 1
fi

> "$out"

for file in "$dir"/*."$ext"; do
    [ -f "$file" ] || continue
    basename "$file" >> "$out"
done

echo "Готово. Результат записан в $out"
