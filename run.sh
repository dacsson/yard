#! /bin/bash

echo "Compiling..."

cd "build"

dmd "../src/main.d" "../src/lexer.d" "../src/parser.d" "../src/utils/yrd_ttf.d" "../src/utils/yrd_tree.d" "../src/utils/yrd_types.d" "../src/builders/builder.d" "../src/builders/html_builder.d" "../src/builders/latex_builder.d" "../src/builders/pdf_builder.d" "../src/templates/yrd_templates.d" "../src/utils/yrd_searcher.d" "../src/utils/yrd_errors.d"

# cd ..
# cd "test"

# firefox file.pdf
