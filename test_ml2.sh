#!/bin/bash
# tests for ml2.sh script

# тест 1 (директория существует).
path="$1"
if ! [[ -d "$path" ]]; then
    echo "Error: directory '$path' doesn't exist"
    exit 1
fi

# тест 2 (проверка валидности процента).
threshold="$2"
if ! [[ "$threshold" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: threshold must be a positive number"
    exit 1
fi

# тест 3 (проверка, что процент от 0 до 100).
if (( $(echo "$threshold <= 0" | bc -l 2>/dev/null) )); then
    echo "Error: threshold must be greater than 0"
    exit 1
fi

# тест 4 (проверка, что процент от 0 до 100 - вторая часть).
if (( $(echo "$threshold > 100" | bc -l 2>/dev/null) )); then
    echo "Error: threshold cannot be over 100%"
    exit 1
fi

# тест 5 (проверка, что bc есть и функционирует - запускаю числа с пл. запятой).
if ! command -v bc &> /dev/null; then
    echo "Error: 'bc' calculator is required but not installed"
    exit 1
fi

# тест 6 (проверка, путь к папке есть и он читаемый).
if ! [[ -r "$path" ]]; then
    echo "Error: directory '$path' is not readable"
    exit 1
fi

# тест 7 (проверка, что папка доступна и с ней можно работать).
if ! [[ -x "$path" ]]; then
    echo "Error: directory '$path' is not accessible"
    exit 1
fi

echo "All tests passed for ml2.sh"
