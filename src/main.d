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

  // enum States {
  //   NUMBER,
  //   START,
  //   NAME,
  //   OP,
  //   SPECIAL,
  //   INLINE,
  //   INDENT,
  //   NEWLINE,
  //   NULL,
  //   EOL
  // }

  // StateValue[States][States] table;
  // table[States.START] = 
  //   [
  //     States.NUMBER  :  StateValue("0", "number"),
  //     States.NAME    :  StateValue("0", "name"),
  //     States.OP      :  StateValue("0", "op"),
  //     States.SPECIAL :  StateValue("0", "special"),
  //     States.INDENT  :  StateValue("0", "indent"),
  //     States.NEWLINE :  StateValue("0", "newline"),
  //     States.NULL   :  StateValue("0", "null"),
  //     States.EOL     :  StateValue("EOL", "0")
  //   ];

  // writeln("\n", table[States.START][States.NUMBER].res);

  return 0;
}
