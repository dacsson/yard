#! /bin/bash

echo "Compiling..."

cd "build"

dmd "../src/main.d" "../src/lexer.d" "../src/parser.d" "../src/utils/yrd_tree.d" "../src/utils/yrd_types" "../src/constructors/constructor.d" "../src/constructors/html_constr.d" "../src/constructors/latex_constr.d"

# cd ..
# cd "test"

# firefox file.pdf
