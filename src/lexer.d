module yard.lexer;

import std.stdio;
import std.regex : matchFirst;
import std.conv : to;
import std.utf : decodeFront;

import yard.utils.yrd_types;

alias NAS = STATES.S_NONE;    // NOT A STATE
alias NAL = LEXEMS.LEX_NONE;  // NOT A LEXEM

// продолжить в том же состоянии автомата без "регистрации" токена в файле
StateValue _ret_self_state_RV(STATES _state_type) { return StateValue(NAL, _state_type); }
// вернуть "построенный" токен с переходом в старотовое состояние для чтения нового токена
StateValue _ret_resolved_lex_LV(LEXEMS _lex_type) { return StateValue(_lex_type, STATES.S_START); }
// вернуть "построенный" токен с переходом в другое состояние
StateValue _ret_lex_and_goto_state(LEXEMS _lex_type, STATES _state_type) { return StateValue(_lex_type, _state_type); }

/** 
 * Объект результата перехода состояния автомата, 
 * имеет либо конечный результат, либо переход в другое состояние
 */
struct StateValue
{
  // функция выхода
  LEXEMS res;
  // функция перехода
  STATES next_state;
  // нынешнее состояние
  STATES curr_state;

  this(LEXEMS res, STATES next_state, STATES curr_state = STATES.S_NONE)
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
  LEXEMS sym_class;

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
  private LEXEMS get_symbol_class(string sym)
  {
    if (sym == "EOL") return LEXEMS.LEX_EOL;
    else if (!matchFirst(sym, `^\d+$`).empty()) return LEXEMS.LEX_STR;
    else if (!matchFirst(sym, `[\p{Cyrillic}+|\p{L}+]`).empty()) return LEXEMS.LEX_STR;
    else if (!matchFirst(sym, `^\p{L}+$`).empty()) return LEXEMS.LEX_STR;
    // else if (!matchFirst(sym, `[!\\()]`).empty()) return LEXEMS.LEX_OP; 
    else if (sym == "!") return LEXEMS.LEX_DEFVAR;
    else if (sym == "\\") return LEXEMS.LEX_DEFCMD;
    else if (sym == " ") return LEXEMS.LEX_INDENT;
    else if (!matchFirst(sym, `\n`).empty()) return LEXEMS.LEX_NLINE;
    else if (!matchFirst(sym, `\r`).empty()) return LEXEMS.LEX_SPECIAL;
    else return LEXEMS.LEX_NULL;
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
    STATES.S_START : [
      LEXEMS.LEX_STR     :   _ret_self_state_RV(STATES.S_DEF_VAR),
      LEXEMS.LEX_DEFVAR  :   _ret_self_state_RV(STATES.S_DEF_VAR),
      LEXEMS.LEX_INDENT : _ret_self_state_RV(STATES.S_SEEN_INDENT),
      LEXEMS.LEX_DEFCMD : _ret_self_state_RV(STATES.S_SEEN_CMDDEF),
      LEXEMS.LEX_EOL : _ret_resolved_lex_LV(LEXEMS.LEX_EOL),
    ],
    STATES.S_DEF_VAR : [
      LEXEMS.LEX_STR     :   _ret_self_state_RV(STATES.S_DEF_VAR),
      LEXEMS.LEX_DEFVAR  :   _ret_self_state_RV(STATES.S_DEF_VAR),
      LEXEMS.LEX_INDENT  :   _ret_lex_and_goto_state(LEXEMS.LEX_DEFVAR, STATES.S_INDENT_AFTER_VAR),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_DEFVAR)
    ],
    STATES.S_SEEN_INDENT : [
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_INDENT)
    ],
    STATES.S_INDENT_AFTER_VAR : [
      LEXEMS.LEX_STR     :   _ret_self_state_RV(STATES.S_READ_VARVAL),
      LEXEMS.LEX_INDENT  :   _ret_lex_and_goto_state(LEXEMS.LEX_INDENT, STATES.S_READ_VARVAL),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_DEFVAR)
    ],
    STATES.S_READ_VARVAL : [
      LEXEMS.LEX_STR      :   _ret_self_state_RV(STATES.S_READ_VARVAL),
      LEXEMS.LEX_INDENT   :    _ret_self_state_RV(STATES.S_READ_VARVAL),
      LEXEMS.LEX_NLINE     :   _ret_lex_and_goto_state(LEXEMS.LEX_VARVAL, STATES.S_NLINE_AFTER_VAL),
      LEXEMS.LEX_NULL     : _ret_self_state_RV(STATES.S_READ_VARVAL),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_VARVAL)
    ],
    STATES.S_NLINE_AFTER_VAL : [
      LEXEMS.LEX_DEFVAR : _ret_lex_and_goto_state(LEXEMS.LEX_NLINE, STATES.S_DEF_VAR),
      LEXEMS.LEX_NLINE : _ret_self_state_RV(STATES.S_NLINE_AFTER_VAL),
      LEXEMS.LEX_DEFCMD  :   _ret_lex_and_goto_state(LEXEMS.LEX_NLINE, STATES.S_SEEN_CMDDEF),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_NLINE)
    ],
    STATES.S_SEEN_CMDDEF : [
      LEXEMS.LEX_STR     :   _ret_self_state_RV(STATES.S_SEEN_CMDDEF),
      LEXEMS.LEX_DEFVAR  :   _ret_self_state_RV(STATES.S_SEEN_CMDDEF),
      LEXEMS.LEX_INDENT  :   _ret_lex_and_goto_state(LEXEMS.LEX_INDENT, STATES.S_DEF_CMD),
      LEXEMS.LEX_NLINE   :   _ret_lex_and_goto_state(LEXEMS.LEX_INDENT, STATES.S_DEF_CMD),
      LEXEMS.LEX_DEFCMD  :   _ret_self_state_RV(STATES.S_DEF_CMD),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_NONE)
    ],
    STATES.S_DEF_CMD : [
      LEXEMS.LEX_STR     :   _ret_self_state_RV(STATES.S_DEF_CMD),
      LEXEMS.LEX_DEFVAR  :   _ret_self_state_RV(STATES.S_DEF_CMD),
      LEXEMS.LEX_INDENT  :   _ret_lex_and_goto_state(LEXEMS.LEX_DEFCMD, STATES.S_INDENT_AFTER_CMD),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_DEFVAR)      
    ],
    STATES.S_INDENT_AFTER_CMD : [
      LEXEMS.LEX_STR     :   _ret_self_state_RV(STATES.S_READ_CMDVAL),
      LEXEMS.LEX_INDENT  :   _ret_lex_and_goto_state(LEXEMS.LEX_INDENT, STATES.S_READ_CMDVAL),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_EOL)
    ],
    STATES.S_READ_CMDVAL : [
      LEXEMS.LEX_STR      :   _ret_self_state_RV(STATES.S_READ_CMDVAL),
      LEXEMS.LEX_INDENT   :    _ret_self_state_RV(STATES.S_READ_CMDVAL),
      LEXEMS.LEX_NLINE     :   _ret_lex_and_goto_state(LEXEMS.LEX_CMDVAL, STATES.S_NLINE_AFTER_CMD),
      LEXEMS.LEX_DEFVAR  :   _ret_self_state_RV(STATES.S_READ_CMDVAL),
      LEXEMS.LEX_NULL     :  _ret_self_state_RV(STATES.S_READ_CMDVAL),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_CMDVAL)      
    ],
    STATES.S_NLINE_AFTER_CMD : [
      LEXEMS.LEX_STR      : _ret_lex_and_goto_state(LEXEMS.LEX_NLINE, STATES.S_SEEN_FREE_STR),
      LEXEMS.LEX_DEFCMD : _ret_lex_and_goto_state(LEXEMS.LEX_NLINE, STATES.S_SEEN_CMDDEF),
      LEXEMS.LEX_INDENT : _ret_self_state_RV(STATES.S_NLINE_AFTER_CMD),
      LEXEMS.LEX_NLINE : _ret_self_state_RV(STATES.S_NLINE_AFTER_CMD),
      LEXEMS.LEX_EOL     :   _ret_resolved_lex_LV(LEXEMS.LEX_NLINE)      
    ],
    STATES.S_SEEN_FREE_STR : [
      LEXEMS.LEX_STR : _ret_self_state_RV(STATES.S_SEEN_FREE_STR),
      LEXEMS.LEX_INDENT : _ret_self_state_RV(STATES.S_SEEN_FREE_STR),
      LEXEMS.LEX_NLINE : _ret_self_state_RV(STATES.S_SEEN_FREE_STR),
      LEXEMS.LEX_DEFCMD : _ret_lex_and_goto_state(LEXEMS.LEX_STR, STATES.S_SEEN_CMDDEF),
      LEXEMS.LEX_EOL : _ret_resolved_lex_LV(LEXEMS.LEX_STR)
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
    StateValue state =  StateValue(LEXEMS.LEX_NONE, STATES.S_NONE, STATES.S_START);
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

      // writef("%s - %s - %s : %s\n", state.curr_state, state.next_state, symbol.sym_class,symbol.value);
      // переход в новое состояние
      state =  this.lex_table[state.curr_state][symbol.sym_class];

      // если состояние привело к результату, т.е. составлена полная лексема
      if(state.res != LEXEMS.LEX_NONE) 
      {
        plex =  Token(0, state.res, slice, 0);
        this.result ~= plex;
        state = StateValue(LEXEMS.LEX_NONE, STATES.S_NONE, state.next_state);

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
        state = StateValue(LEXEMS.LEX_NONE, STATES.S_NONE, state.next_state);
        stay_at_curr_sym = true;
        slice ~= symbol.value;
      }

      // удаление декодированого символа иногда может означать удаление как бы нескольких символов (размер некоторых символов > 1)
      // поэтому следим за размером символов
      count_removes+=(prev_str_size - to!int(input_text.length));

      prev_str_size = to!int(input_text.length);
      
      if(symbol.sym_class == LEXEMS.LEX_EOL) break;
    }

    return this.result;
  }
}