module yard.main;

import std.stdio : writef, writeln;
import std.file;
import std.utf;
import std.conv;
import std.regex;

import yard.lexer;

int main()
{
  string content = readText("../test/hello.yard");
  // string content =
  // "%PDF-1.0
  // 1 0 obj
  // <<
  // /Type /Catalog
  // /Pages 3 0 R
  // /Outlines 2 0 R
  // >>
  // endobj
  // 2 0 obj
  // <<
  // /Type /Outlines
  // /Count 0
  // >>
  // endobj
  // 3 0 obj
  // <<
  // /Type /Pages
  // /Count 1
  // /Kids [ 4 0 R ]
  // >>
  // endobj
  // 4 0 obj
  // <<
  // /Type /Page
  // /Parent 3 0 R
  // /Resources << /Font << /F1 7 0 R >> /ProcSet 6 0 R >>
  // /MediaBox [ 0 0 612 792 ]
  // /Contents 5 0 R
  // >>
  // endobj
  // 5 0 obj
  // << /Length 44 >>
  // stream
  // BT
  // /F1 24 Tf
  // 100 100 Td (Hello World) Tj
  // ET
  // endstream
  // endobj
  // 6 0 obj
  // [ /PDF /Text ]
  // endobj
  // 7 0 obj
  // <<
  // /Type /Font
  // /Subtype /Type1
  // /Name /F1
  // /BaseFont /Helvetica
  // /Encoding /MacRomanEncoding
  // >>
  // endobj
  // xref
  // 0 8
  // 0000000000 65535 f
  // 0000000009 00000 n
  // 0000000074 00000 n
  // 0000000120 00000 n
  // 0000000179 00000 n
  // 0000000322 00000 n
  // 0000000415 00000 n
  // 0000000445 00000 n
  // trailer
  // <<
  // /Size 8
  // /Root 1 0 R
  // >>
  // startxref
  // 553
  // %%EOF";

  // write("../test/file.pdf", content);
  // writef("created file with size %ul", getSize("../test/file.txt"));
  
  string input = 
  "def findOdd(array):
    newArray = []
    for i in range(len(array)):
        if i % 2 != 0:
            newArray.push(i)
    return newArray
  array = [1, 2, 3, 4, 5]
  print(findOdd(array))
  ";
  Lexer lexer = new Lexer(content);
  PlainLex[] plexs = lexer.analyze();

  // foreach (PlainLex key; plexs)
  // {
  //   writeln("value: ", key.value, " \ttype :", key.type);
  // }

  return 0;
}
