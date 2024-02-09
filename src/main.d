module yard.main;

import std.stdio : writef, writeln;
import std.file : readText;

import yard.lexer;

int main()
{
  string content = readText("../test/hello.yard");

  Lexer lexer = new Lexer(content);
  Token[] plexs = lexer.get_tokens();

  foreach (Token key; plexs)
  {
    writeln(" Лексема:\t", key.type, "\tсо значением:\t", key.value);
  }

  return 0;
}
