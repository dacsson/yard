module yard.lexer;

import std.stdio;
import std.regex;

/**
 * Смысловая единица языка 
 */
class Lex 
{
  uint id;
  string type;
  string value;

  this(uint id = 0, string type, string value)
  {
    this.id = id;
    this.type = type;
    this.value = value;
  }
}

/**
 * Лексически анализатор
 */
class Lexer
{
  string input_text;
  string[string][string][string] lex_table; 
  string result;

  void setup_table()
  {
    this.lex_table["start"] = 
    [
      "number"  : ["state" : "number"],
      "name"    : ["state" : "name"],
      "op"      : ["state" : "op"],
      "special" : ["state" : "special"],
      "indent"  : ["state" : "indent"],
      "newline" : ["state" : "null"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "EOL"]
    ];
    this.lex_table["number"] = 
    [
      "number"  : ["state" : "number"],
      "name"    : ["state" : "null"],
      "op"      : ["res" : "number"],
      "special" : ["res" : "number"],
      "indent"  : ["res" : "number"],
      "newline" : ["res" : "number"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "number"]
    ];
    this.lex_table["name"] = 
    [
      "number"  : ["state" : "name"],
      "name"    : ["state" : "name"],
      "op"      : ["res" : "name"],
      "special" : ["res" : "name"],
      "indent"  : ["res" : "name"],
      "newline" : ["res" : "name"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "name"]
    ];
    this.lex_table["op"] = 
    [
      "number"  : ["res" : "op"],
      "name"    : ["res" : "op"],
      "op"      : ["state" : "op"],
      "special" : ["res" : "op"],
      "indent"  : ["res" : "op"],
      "newline" : ["res" : "op"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "op"]
    ];
    this.lex_table["special"] = 
    [
      "number"  : ["res" : "special"],
      "name"    : ["res" : "special"],
      "op"      : ["res" : "special"],
      "special" : ["res" : "special"],
      "indent"  : ["res" : "special"],
      "newline" : ["res" : "special"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "special"]
    ];
    this.lex_table["indent"] = 
    [
      "number"  : ["res" : "indent"],
      "name"    : ["res" : "indent"],
      "op"      : ["res" : "indent"],
      "special" : ["res" : "indent"],
      "indent"  : ["state" : "indent"],
      "newline" : ["res" : "indent"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "indent"]
    ];
    this.lex_table["newline"] = 
    [
      "number"  : ["res" : "newline"],
      "name"    : ["res" : "newline"],
      "op"      : ["res" : "newline"],
      "special" : ["res" : "newline"],
      "indent"  : ["res" : "newline"],
      "newline" : ["res" : "newline"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "newline"]
    ];
    this.lex_table["null"] = 
    [
      "number"  : ["state" : "null"],
      "name"    : ["state" : "null"],
      "op"      : ["res" : "null"],
      "special" : ["res" : "null"],
      "indent"  : ["res" : "null"],
      "newline" : ["state" : "null"],
      "null"    : ["state" : "null"],
      "EOL"     : ["res" : "null"]
    ];
  }

  this(string input_text)
  {
    this.input_text = input_text;
    setup_table();
    writeln("Element: ", lex_table["start"]["number"]["state"]);

  }

  string get_symbol_class(string sym)
  {
    auto reg_number = ctRegex!(`[0-9]`);
    auto reg_name = ctRegex!(`[]`)
    switch(true)
    {
      case sym == "EOL" : return "EOL";
      case 
      default : return "null";
    }
  }
}


