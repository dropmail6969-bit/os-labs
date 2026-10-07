#!/data/data/com.termux/files/usr/bin/bash

out="args.txt"

echo "Аргументы командной строки:"
for arg in "$@"; do
    echo "$arg"
done | tee "$out"
