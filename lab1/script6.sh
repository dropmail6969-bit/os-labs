#!/data/data/com.termux/files/usr/bin/bash

src="$1"
exe="$2"

if [ $# -ne 2 ]; then
    echo "Использование: $0 <исходный_файл.c> <результирующий_файл>"
    exit 1
fi

CC="${CC:-gcc}"

$CC "$src" -o "$exe"
status=$?

if [ $status -ne 0 ]; then
    echo "Ошибка компиляции. Запуск программы отменён."
    exit $status
fi

if [ -x "$exe" ]; then
    if [[ "$exe" == */* ]]; then
        "$exe"
    else
        "./$exe"
    fi
else
    echo "Исполняемый файл не найден: $exe"
    exit 1
fi
