#!/data/data/com.termux/files/usr/bin/bash

CC="${CC:-clang}"

echo "=== Компиляция лабы №2 ==="
$CC task2.c    -o task2    || exit 1
$CC variant4.c -o variant4 || exit 1
echo "OK"
echo

echo "=== Задание 2: два fork + ps -x ==="
./task2
echo

echo "=== Вариант 4: поиск комбинации ==="
mkdir -p demo
echo "HELLO Ubuntu HELLO"    > demo/a.txt
echo "hello world"            > demo/b.txt
echo "HELLO"                  > demo/c.txt
echo "no match here"          > demo/d.txt
./variant4 demo "HELLO" 2
