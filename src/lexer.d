module yard.lexer;

import std.regex : matchFirst;
import std.conv : to;
import std.utf : decodeFront;

enum LexType {
  LEX_NONE    ,
  LEX_START   ,
  LEX_NUM     ,
  LEX_STR     ,
  LEX_IDENT   ,
  LEX_OP      ,
  LEX_SPECIAL ,
  LEX_INLINE  ,
  LEX_INDENT  ,
  LEX_NLINE   ,
  LEX_NULL    ,
  LEX_EOL
}

/**
 * pair consisting of a token name and an optional attribute value. 
 * The token name is an abstract symbol representing a kind of lexical unit, 
 * e.g., a particular keyword, or sequence of input characters denoting an identifier. 
 * The token names are the input symbols that the parser processes.
 */
struct Token 
{
  uint id;
  LexType type;
  string value;

  this(uint id, LexType type, string value)
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
  LexType res;
  // функция перехода
  LexType next_state;
  // нынешнее состояние
  LexType curr_state;

  this(LexType res, LexType next_state, LexType curr_state = LexType.LEX_NONE)
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
  LexType sym_class;

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
  private LexType get_symbol_class(string sym)
  {
    if (sym == "EOL") return LexType.LEX_EOL;
    else if (!matchFirst(sym, `^\d+$`).empty()) return LexType.LEX_NUM;
    else if (!matchFirst(sym, `[\p{Cyrillic}+|\p{L}+]`).empty()) return LexType.LEX_STR;
    else if (!matchFirst(sym, `[!\\()]`).empty()) return LexType.LEX_OP; 
    else if (sym == " ") return LexType.LEX_INDENT;
    else if (!matchFirst(sym, `\n`).empty()) return LexType.LEX_NLINE;
    else if (!matchFirst(sym, `\r`).empty()) return LexType.LEX_SPECIAL;
    else return LexType.LEX_NULL;
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
  Token[] result;
  StateValue[LexType][LexType] lex_table; 

  // Заполнить таблицу переходов состояний автомата
  private StateValue[LexType][LexType] setup_table()
  {
    StateValue[LexType][LexType] _lex_table;

    _lex_table[LexType.LEX_START] = 
    [
      LexType.LEX_STR    :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_OP      :  StateValue(LexType.LEX_NONE, LexType.LEX_OP),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NONE, LexType.LEX_SPECIAL),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NONE, LexType.LEX_INDENT),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_NONE, LexType.LEX_NLINE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_EOL, LexType.LEX_NONE)
    ];
    _lex_table[LexType.LEX_STR] = 
    [
      LexType.LEX_NUM  :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_STR    :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_OP      :  StateValue(LexType.LEX_STR, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_STR, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_STR, LexType.LEX_NONE),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_STR, LexType.LEX_NONE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_STR, LexType.LEX_NONE)
    ];
    _lex_table[LexType.LEX_OP] = 
    [
      LexType.LEX_NUM  :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
      LexType.LEX_STR    :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
      LexType.LEX_OP      :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_OP, LexType.LEX_NONE)
    ];
    _lex_table[LexType.LEX_SPECIAL] = 
    [
      LexType.LEX_NUM  :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
      LexType.LEX_STR    :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
      LexType.LEX_OP      :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE)
    ];
    _lex_table[LexType.LEX_INDENT] = 
    [
      LexType.LEX_NUM  :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_STR    :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_OP      :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NONE, LexType.LEX_INDENT),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE)
    ];
    _lex_table[LexType.LEX_NLINE] = 
    [
      LexType.LEX_NUM  :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_STR    :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_OP      :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE)
    ];
    _lex_table[LexType.LEX_NULL] = 
    [
      LexType.LEX_NUM  :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_STR    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_OP      :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE)
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
    StateValue state =  StateValue(LexType.LEX_NONE, LexType.LEX_NONE, LexType.LEX_START);
    DecodedSymbol symbol;
    Token plex;

    string cpy_str = input_text.dup;

    int curr_symbol_size = 0;
    int prev_str_size = to!int(input_text.length);
    int count_removes = 0;

    // копим считанные символы
    string slice = "";

    bool stay_at_curr_sym = true;

    while(count_removes<=cpy_str.length)
    {
      // decodeFront() берёт по одному символу из строки слева направо, декодирует с УТФ-8 и удаляет его из строки
      symbol = new DecodedSymbol(
        (count_removes == cpy_str.length) ? "EOL" : to!string(input_text.decodeFront())
      );

      // переход в новое состояние
      state =  this.lex_table[state.curr_state][symbol.sym_class];

      // если состояние привело к результату, т.е. составлена полная лексема
      if(state.res != LexType.LEX_NONE) 
      {
        plex =  Token(0, state.res, slice);
        this.result ~= plex;
        state = StateValue(LexType.LEX_NONE, LexType.LEX_NONE, LexType.LEX_START);

        // продолжаем обход строки с той же позиции
        if(stay_at_curr_sym) {
          symbol.value ~= input_text;
          input_text = symbol.value;
        }

        slice = "";
        stay_at_curr_sym = false;
      }
      else 
      {
        state = StateValue(LexType.LEX_NONE, LexType.LEX_NONE, state.next_state);
        stay_at_curr_sym = true;
        slice ~= symbol.value;
      }

      // удаление декодированого символа иногда может означать удаление как бы нескольких символов (размер некоторых символов > 1)
      // поэтому следим за размером символов
      curr_symbol_size = prev_str_size - to!int(input_text.length); 
      count_removes+=curr_symbol_size;

      prev_str_size = to!int(input_text.length);
      
      if(symbol.sym_class == LexType.LEX_EOL) break;
    }

    return this.result;
  }
}