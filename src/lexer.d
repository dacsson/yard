module yard.lexer;

import std.stdio;
import std.regex : matchFirst;
import std.conv : to;
import std.utf : decodeFront;

enum StateType {
  S_NONE        ,
  S_SEEN_VARDEF ,  // ожидаем зачение переменной
}

enum LexType {
  LEX_NONE    ,   // нет лексемы или ошибка декларации
  LEX_START   ,
  LEX_NUM     ,
  LEX_STR     ,
  LEX_VARVAL  ,   // значение переменной
  LEX_IDENT   ,
  // LEX_OP      , => deprecated, разбиваем это на ДОСТУПНЫЕ операции :
  LEX_DEFVAR  ,   // "!" - декларация переменной
  LEX_DEFCMD  ,   // "\" - декларация начала команды
  LEX_DEFCMEND,   // "/" - декларация конца команды
  LEX_DEFGRP  ,   // "\n после тэга" - декларация начала группы 
  LEX_DEFGREND,   // "\n после заполнения тэга" - декларация конца группы
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
  // на какой строк в исходном файле находится
  uint at_line;

  this(uint id, LexType type, string value, uint at_line)
  {
    this.id = id;
    this.type = type;
    this.value = value;
    this.at_line = at_line;
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
  /*
    LEX_DEFVAR  ,   // "!" - декларация переменной
    LEX_DEFCMD  ,   // "\" - декларация начала команды
    LEX_DEFCMEND,   // "/" - декларация конца команды
    LEX_DEFGRP  ,   // "\n после тэга" - декларация начала группы 
    LEX_DEFGREND,   // "\n после заполнения тэга" - декларация конца группы
  */
  private LexType get_symbol_class(string sym)
  {
    if (sym == "EOL") return LexType.LEX_EOL;
    else if (!matchFirst(sym, `^\d+$`).empty()) return LexType.LEX_NUM;
    else if (!matchFirst(sym, `[\p{Cyrillic}+|\p{L}+]`).empty()) return LexType.LEX_STR;
    // else if (!matchFirst(sym, `[!\\()]`).empty()) return LexType.LEX_OP; 
    else if (sym == "!") return LexType.LEX_DEFVAR;
    else if (sym == "\\") return LexType.LEX_DEFCMD;
    else if (sym == "/") return LexType.LEX_DEFCMEND;
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
  StateValue[][] lex_table = [
    LexType.LEX_START :
    [
      LexType.LEX_STR     :   StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      // LexType.LEX_OP      :  StateValue(LexType.LEX_NONE, LexType.LEX_OP),
      LexType.LEX_DEFVAR  :   StateValue(LexType.LEX_NONE, LexType.LEX_DEFVAR),
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_NONE, LexType.LEX_DEFGRP),
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFGREND),
      LexType.LEX_DEFCMD  :   StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_DEFCMEND :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMEND),
      LexType.LEX_SPECIAL :   StateValue(LexType.LEX_NONE, LexType.LEX_SPECIAL),
      LexType.LEX_INDENT  :   StateValue(LexType.LEX_NONE, LexType.LEX_INDENT),
      LexType.LEX_NLINE   :   StateValue(LexType.LEX_NONE, LexType.LEX_NLINE),
      LexType.LEX_NULL    :   StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :   StateValue(LexType.LEX_EOL, LexType.LEX_NONE)
    ],
    LexType.LEX_STR :
    [
      LexType.LEX_NUM     :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_STR     :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      // LexType.LEX_OP      :  StateValue(LexType.LEX_STR, LexType.LEX_NONE),
      LexType.LEX_DEFVAR  :   StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_STR, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_STR, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_NLINE   :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_STR, LexType.LEX_NONE)
    ],
    LexType.LEX_DEFVAR : [
      LexType.LEX_NUM     :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFVAR),
      LexType.LEX_STR     :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFVAR),
      LexType.LEX_DEFVAR  :   StateValue(LexType.LEX_NONE, LexType.LEX_DEFVAR),   // какаято хуета
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_DEFVAR, LexType.LEX_NONE), // какаято хуета
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_DEFVAR, LexType.LEX_NONE), // какаято хуета
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFVAR),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_NONE, LexType.LEX_DEFVAR),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFVAR),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_DEFVAR, LexType.LEX_NONE), // если пробел то ждём текста
      LexType.LEX_NLINE   :  StateValue(LexType.LEX_DEFVAR, LexType.LEX_NONE), // и тут тоже ждём текста
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_DEFVAR, LexType.LEX_NONE)      
    ],
    LexType.LEX_VARVAL : [
      LexType.LEX_NUM     :  StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL),
      LexType.LEX_STR     :  StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL),
      LexType.LEX_DEFVAR  :   StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL),   
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL), 
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL), 
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NONE, LexType.LEX_VARVAL), 
      LexType.LEX_NLINE   :  StateValue(LexType.LEX_DEFVAR, LexType.LEX_NONE), 
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_VARVAL, LexType.LEX_NONE)   
    ],
    LexType.LEX_DEFGRP : [

    ],
    LexType.LEX_DEFGREND : [

    ],
    LexType.LEX_DEFCMD : [
      LexType.LEX_NUM     :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_STR     :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_DEFVAR  :   StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),   // какаято хуета
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // какаято хуета
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // какаято хуета
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // если пробел то ждём текста
      LexType.LEX_NLINE   :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // и тут тоже ждём текста
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE)         
    ],
    LexType.LEX_DEFCMEND : [
      LexType.LEX_NUM     :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_STR     :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_DEFVAR  :   StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),   // какаято хуета
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // какаято хуета
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // какаято хуета
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFCMD),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // если пробел то ждём текста
      LexType.LEX_NLINE   :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE), // и тут тоже ждём текста
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_DEFCMD, LexType.LEX_NONE)         
    ],
    // LexType.LEX_OP :
    // [
    //   LexType.LEX_NUM  :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
    //   LexType.LEX_STR    :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
    //   // LexType.LEX_OP      :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
    //   LexType.LEX_DEFVAR  :   StateValue(LexType.LEX_NONE, LexType.LEX_STR),
    //   LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_NONE, LexType.LEX_DEFGRP),
    //   LexType.LEX_DEFGREND :  StateValue(LexType.LEX_NONE, LexType.LEX_DEFGREND),
    //   LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NONE, LexType.LEX_STR),
    //   LexType.LEX_DEFCMEND : StateValue(LexType.LEX_STR, LexType.LEX_NONE),      
    //   LexType.LEX_SPECIAL :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
    //   LexType.LEX_INDENT  :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
    //   LexType.LEX_NLINE :  StateValue(LexType.LEX_OP, LexType.LEX_NONE),
    //   LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
    //   LexType.LEX_EOL     :  StateValue(LexType.LEX_OP, LexType.LEX_NONE)
    // ],
    // LexType.LEX_SPECIAL :
    // [
    //   LexType.LEX_NUM     :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
    //   LexType.LEX_STR     :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
    //   // LexType.LEX_OP      :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
    //   LexType.LEX_DEFVAR  :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
    //   LexType.LEX_SPECIAL :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
    //   LexType.LEX_INDENT  :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
    //   LexType.LEX_NLINE   :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE),
    //   LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
    //   LexType.LEX_EOL     :  StateValue(LexType.LEX_SPECIAL, LexType.LEX_NONE)
    // ],
    LexType.LEX_INDENT :
    [
      LexType.LEX_NUM     :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_STR     :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      // LexType.LEX_OP      :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_DEFVAR  :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NONE, LexType.LEX_INDENT),
      LexType.LEX_NLINE   :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_INDENT, LexType.LEX_NONE)
    ],
    LexType.LEX_NLINE :
    [
      LexType.LEX_NUM  :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_STR    :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      // LexType.LEX_OP      :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_DEFVAR  :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_NLINE :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_NLINE, LexType.LEX_NONE)
    ],
    LexType.LEX_NULL :
    [
      LexType.LEX_NUM     :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_STR     :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      // LexType.LEX_OP      :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_DEFVAR  :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_DEFGRP  :   StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_DEFGREND :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_DEFCMD  :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_DEFCMEND : StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_SPECIAL :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_INDENT  :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE),
      LexType.LEX_NLINE   :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_NULL    :  StateValue(LexType.LEX_NONE, LexType.LEX_NULL),
      LexType.LEX_EOL     :  StateValue(LexType.LEX_NULL, LexType.LEX_NONE)
    ]
  ]; 

  this(string input_text)
  {
    this.input_text = input_text;
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
        plex =  Token(0, state.res, slice, 0);
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
      count_removes+=(prev_str_size - to!int(input_text.length));

      prev_str_size = to!int(input_text.length);
      
      if(symbol.sym_class == LexType.LEX_EOL) break;
    }

    return this.result;
  }
}