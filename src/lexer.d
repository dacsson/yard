module yard.lexer;

import std.stdio;
import std.regex;
import std.typecons;
import std.conv;
import std.utf;

/**
 * Смысловая единица языка 
 */
class Lex 
{
  uint id;
  string type;
  string value;

  this(uint id, string type, string value)
  {
    this.id = id;
    this.type = type;
    this.value = value;
  }
}

class PlainLex 
{
  string type;
  string value;

  this(string type, string value)
  {
    this.type = type;
    this.value = value; 
  }
}

/** 
 * Объект результата перехода состояния автомата, 
 * имеет либо конечный результат, либо переход в другое состояние
 */
class StateValue
{
  string res;
  string state;

  this(string res, string state)
  {
    this.res = res;
    this.state = state;
  }
}

/**
 * Лексически анализатор
 *
 * Params: 
 * input_text = входящий текст в формате ЯРД
 * lex_table = таблица переходов состояний автомата
 * result = исходный текст разбитый на лексемы
 */
class Lexer
{
  string input_text;
  StateValue[string][string] lex_table; 
  PlainLex[] result;

  // Заполнить таблицу переходов состояний автомата
  private StateValue[string][string] setup_table()
  {
    StateValue[string][string] _lex_table;

    _lex_table["start"] = 
    [
      "number"  : new StateValue("0", "number"),
      "name"    : new StateValue("0", "name"),
      "op"      : new StateValue("0", "op"),
      "special" : new StateValue("0", "special"),
      "indent"  : new StateValue("0", "indent"),
      "newline" : new StateValue("0", "newline"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("EOL", "0")
    ];
    _lex_table["number"] = 
    [
      "number"  : new StateValue("0", "number"),
      "name"    : new StateValue("0", "null"),
      "op"      : new StateValue("number", "0"),
      "special" : new StateValue("number", "0"),
      "indent"  : new StateValue("number", "0"),
      "newline" : new StateValue("number", "0"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("number", "0")
    ];
    _lex_table["name"] = 
    [
      "number"  : new StateValue("0", "name"),
      "name"    : new StateValue("0", "name"),
      "op"      : new StateValue("name", "0"),
      "special" : new StateValue("name", "0"),
      "indent"  : new StateValue("name", "0"),
      "newline" : new StateValue("name", "0"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("name", "0")
    ];
    _lex_table["op"] = 
    [
      "number"  : new StateValue("op", "0"),
      "name"    : new StateValue("op", "0"),
      "op"      : new StateValue("op", "0"),
      "special" : new StateValue("op", "0"),
      "indent"  : new StateValue("op", "0"),
      "newline" : new StateValue("op", "0"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("op", "0")
    ];
    _lex_table["special"] = 
    [
      "number"  : new StateValue("special", "0"),
      "name"    : new StateValue("special", "0"),
      "op"      : new StateValue("special", "0"),
      "special" : new StateValue("special", "0"),
      "indent"  : new StateValue("special", "0"),
      "newline" : new StateValue("special", "0"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("special", "0")
    ];
    _lex_table["indent"] = 
    [
      "number"  : new StateValue("indent", "0"),
      "name"    : new StateValue("indent", "0"),
      "op"      : new StateValue("indent", "0"),
      "special" : new StateValue("indent", "0"),
      "indent"  : new StateValue("0", "indent"),
      "newline" : new StateValue("indent", "0"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("indent", "0")
    ];
    _lex_table["newline"] = 
    [
      "number"  : new StateValue("newline", "0"),
      "name"    : new StateValue("newline", "0"),
      "op"      : new StateValue("newline", "0"),
      "special" : new StateValue("newline", "0"),
      "indent"  : new StateValue("newline", "0"),
      "newline" : new StateValue("newline", "0"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("newline", "0")
    ];
    _lex_table["null"] = 
    [
      "number"  : new StateValue("0", "null"),
      "name"    : new StateValue("0", "null"),
      "op"      : new StateValue("null", "0"),
      "special" : new StateValue("null", "0"),
      "indent"  : new StateValue("null", "0"),
      "newline" : new StateValue("0", "null"),
      "null"    : new StateValue("0", "null"),
      "EOL"     : new StateValue("null", "0")
    ];

    return _lex_table;
  }

  this(string input_text)
  {
    this.input_text = input_text;
    this.lex_table = setup_table();
  }

  /**
   * Определить класс лексемы 
   * 
   * Params: 
   * sym = входяший символ
   * 
   * Returns: 3-мерный словарь переходов состояний для автомата для разных классов лексем
   */
  private string get_symbol_class(string sym)
  {
    if (sym == "EOL") return "EOL";
    else if (!matchFirst(sym, `^\d+$`).empty()) return "number";
    else if (!matchFirst(sym, `[\p{Cyrillic}+|\p{L}+]`).empty()) return "name";
    else if (!matchFirst(sym, `[!\\()]`).empty()) return "op"; 
    else if (sym == " ") return "indent";
    else if (!matchFirst(sym, `\n`).empty()) return "newline";
    else if (!matchFirst(sym, `\r`).empty()) return "special";
    else return "null";
  }

  /** 
   * Проанализировать входящий текст в ЯРД и выделить лексемы
   *
   * Returns: входящий текст разделённый на лексемы 
   */
  public PlainLex[] analyze()
  {
    int i = 0;
    StateValue state = new StateValue("0", "0");
    string init_state = "start";
    bool shift = true;
    string symbol = "";
    Lex lex;
    PlainLex plex;
    string sym_class;
    string cpy_str = input_text.dup;

    int offset = 0;
    int prev_size = to!int(input_text.length);
    
    int count_removes = 0;

    string slice = "";

    // for(int i = 0; i <= (cpy_str.length - 2); i++)
    while(i<=cpy_str.length)
    {
      // decodeFront() берёт по одному символу из строки слева направо, декодирует с УТФ-8 и удаляет его из строки
      string cpy_curr_str = input_text.dup;
      symbol = (count_removes == cpy_str.length) ? "EOL" : to!string(input_text.decodeFront());
      sym_class  = this.get_symbol_class(symbol);
      state =  this.lex_table[init_state][sym_class];
      
      //writeln(" current offset ", offset, " / ", count_removes, " / ", i, " / ", cpy_str.length, " / ", input_text.length);
      //writeln(" symb: ", symbol, " class: ", sym_class, "| init state: ", init_state, " | res : ", state.res, " | state ", state.state, " | ");

      if(state.res != "0") 
      {
        lex = new Lex(0, state.res, slice);
        writeln(" Лексема:\t", lex.type, "\tсо значением:\t", lex.value);
        //writeln(" slice from ", pos, " to ", i, " from[] ", cpy_str[pos], " to ", cpy_str[i]);
        plex = new PlainLex(lex.type, lex.value);
        this.result ~= plex;

        init_state = "start";

        i = shift ? i-offset: i;
        // writeln(" prev sym ", prev_symbol);
        if(shift) {
          symbol ~= input_text;
          input_text = symbol;
        }
        slice = "";

        shift = false;
      }
      else 
      {
        init_state = state.state;
        shift = true;
        slice ~= symbol;
      }

      i+=offset;

      // удаление декодированого символа иногда может означать удаление как бы нескольких символов (из-за типа символа dchar)
      offset =  prev_size - to!int(input_text.length); 
      count_removes+=offset;

      // запоминаем размер до удаления
      prev_size = to!int(input_text.length);
      //writeln(" slice ", slice);
      if(symbol == "EOL") break;
    }

    return this.result;
  }
}


