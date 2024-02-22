#! /bin/bash

echo "Compiling..."

cd "build"

dmd "../src/main.d" "../src/lexer.d"

# cd ..
# cd "test"

# firefox file.pdf
