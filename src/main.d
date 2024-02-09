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

  Lexer lexer = new Lexer(content);
  PlainLex[] plexs = lexer.analyze();

  foreach (PlainLex key; plexs)
  {
    writeln(" Лексема:\t", key.type, "\tсо значением:\t", key.value);
  }

  return 0;
}
