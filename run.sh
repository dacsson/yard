#! /bin/bash

echo "Compiling..."

cd "build"

dmd "../src/main.d"

cd ..
cd "test"

firefox file.pdf
