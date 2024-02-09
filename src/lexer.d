module yard.lexer;

import std.regex : matchFirst;
import std.conv : to;
import std.utf : decodeFront;

/**
 * pair consisting of a token name and an optional attribute value. 
 * The token name is an abstract symbol representing a kind of lexical unit, 
 * e.g., a particular keyword, or sequence of input characters denoting an identifier. 
 * The token names are the input symbols that the parser processes.
 */
struct Token 
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

/** 
 * Объект результата перехода состояния автомата, 
 * имеет либо конечный результат, либо переход в другое состояние
 */
struct StateValue
{
  // функция выхода
  string res;
  // функция перехода
  string next_state;
  // нынешнее состояние
  string curr_state;

  this(string res, string next_state, string curr_state = "0")
  {
    this.res = res;
    this.next_state = next_state;
    this.curr_state = curr_state;
  }
}

/** 
 *  Декордированный символ кириллицы
 * 
 */
class DecodedSymbol
{
  string value;
  string sym_class;

  this(string value = "")
  {
    this.value = value;
    this.sym_class = get_symbol_class(value);
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
  Token[] result;

  // Заполнить таблицу переходов состояний автомата
  private StateValue[string][string] setup_table()
  {
    StateValue[string][string] _lex_table;

    _lex_table["start"] = 
    [
      "number"  :  StateValue("0", "number"),
      "name"    :  StateValue("0", "name"),
      "op"      :  StateValue("0", "op"),
      "special" :  StateValue("0", "special"),
      "indent"  :  StateValue("0", "indent"),
      "newline" :  StateValue("0", "newline"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("EOL", "0")
    ];
    _lex_table["number"] = 
    [
      "number"  :  StateValue("0", "number"),
      "name"    :  StateValue("0", "null"),
      "op"      :  StateValue("number", "0"),
      "special" :  StateValue("number", "0"),
      "indent"  :  StateValue("number", "0"),
      "newline" :  StateValue("number", "0"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("number", "0")
    ];
    _lex_table["name"] = 
    [
      "number"  :  StateValue("0", "name"),
      "name"    :  StateValue("0", "name"),
      "op"      :  StateValue("name", "0"),
      "special" :  StateValue("name", "0"),
      "indent"  :  StateValue("name", "0"),
      "newline" :  StateValue("name", "0"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("name", "0")
    ];
    _lex_table["op"] = 
    [
      "number"  :  StateValue("op", "0"),
      "name"    :  StateValue("op", "0"),
      "op"      :  StateValue("op", "0"),
      "special" :  StateValue("op", "0"),
      "indent"  :  StateValue("op", "0"),
      "newline" :  StateValue("op", "0"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("op", "0")
    ];
    _lex_table["special"] = 
    [
      "number"  :  StateValue("special", "0"),
      "name"    :  StateValue("special", "0"),
      "op"      :  StateValue("special", "0"),
      "special" :  StateValue("special", "0"),
      "indent"  :  StateValue("special", "0"),
      "newline" :  StateValue("special", "0"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("special", "0")
    ];
    _lex_table["indent"] = 
    [
      "number"  :  StateValue("indent", "0"),
      "name"    :  StateValue("indent", "0"),
      "op"      :  StateValue("indent", "0"),
      "special" :  StateValue("indent", "0"),
      "indent"  :  StateValue("0", "indent"),
      "newline" :  StateValue("indent", "0"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("indent", "0")
    ];
    _lex_table["newline"] = 
    [
      "number"  :  StateValue("newline", "0"),
      "name"    :  StateValue("newline", "0"),
      "op"      :  StateValue("newline", "0"),
      "special" :  StateValue("newline", "0"),
      "indent"  :  StateValue("newline", "0"),
      "newline" :  StateValue("newline", "0"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("newline", "0")
    ];
    _lex_table["null"] = 
    [
      "number"  :  StateValue("0", "null"),
      "name"    :  StateValue("0", "null"),
      "op"      :  StateValue("null", "0"),
      "special" :  StateValue("null", "0"),
      "indent"  :  StateValue("null", "0"),
      "newline" :  StateValue("0", "null"),
      "null"    :  StateValue("0", "null"),
      "EOL"     :  StateValue("null", "0")
    ];

    return _lex_table;
  }

  this(string input_text)
  {
    this.input_text = input_text;
    this.lex_table = setup_table();
  }

  /** 
   * Проанализировать входящий текст в ЯРД и выделить лексемы
   *
   * Returns: входящий текст разделённый на лексемы 
   */
  public Token[] get_tokens()
  {
    // Состояние автомата
    StateValue state =  StateValue("0", "0", "start");
    DecodedSymbol symbol;
    Token plex;

    // копия изначального текста (для цикла, т.к. во время цикла меняется изначальная строка)
    string cpy_str = input_text.dup;

    // удаление декодированого символа иногда может означать удаление как бы нескольких символов (размер некоторых символов > 1)
    // поэтому следим за размером символов
    int offset = 0;
    int prev_size = to!int(input_text.length);

    // Считаем
    int count_removes = 0;

    // копим считанные символы
    string slice = "";

    // Сдвиг назад при переходе состояний автомата, чтобы остаться на символе
    bool shift = true;

    // for(int i = 0; i <= (cpy_str.length - 2); i++)
    while(count_removes<=cpy_str.length)
    {
      // decodeFront() берёт по одному символу из строки слева направо, декодирует с УТФ-8 и удаляет его из строки
      symbol = new DecodedSymbol(
        (count_removes == cpy_str.length) ? "EOL" : to!string(input_text.decodeFront())
      );

      // переход в новое состояние
      state =  this.lex_table[state.curr_state][symbol.sym_class];

      // если состояние привело к результату, т.е. составлена полная лексема
      if(state.res != "0") 
      {
        plex =  Token(0, state.res, slice);
        this.result ~= plex;
        state = StateValue("0", "0", "start");

        // продолжаем обход строки с той же позиции
        if(shift) {
          symbol.value ~= input_text;
          input_text = symbol.value;
        }

        slice = "";
        shift = false;
      }
      else 
      {
        state = StateValue("0", "0", state.next_state);
        shift = true;
        slice ~= symbol.value;
      }

      offset =  prev_size - to!int(input_text.length); 
      count_removes+=offset;

      // запоминаем размер до удаления
      prev_size = to!int(input_text.length);
      
      // если End Of Life конец файла
      if(symbol.value == "EOL") break;
    }

    return this.result;
  }
}