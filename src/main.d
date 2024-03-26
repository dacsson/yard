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
    writeln(" Лексема: ", key.type, "\t\tсо значением:\t", key.value);
  }

  // auto table = [
  //   1 : [1 : "3"],
  //   2 : [2 : "4"]
  // ];
  // writeln("\n", typeid(table));

  return 0;
}
