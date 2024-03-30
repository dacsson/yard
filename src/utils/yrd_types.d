module yard.utils.yrd_types;

/** 
 * Bugs: убрать неисползуемые
 */
enum STATES {
  S_START       ,
  S_NONE        ,
  S_DEF_VAR     ,  // декларация переменной
  S_SEEN_VARDEF ,  // ожидаем имя переменной
  S_READ_VARVAL ,  // ожидаем значение переменной
  S_READ_CMDVAL ,
  S_SEEN_EOL    ,
  S_INDENT_AFTER_CMD,
  S_INDENT_AFTER_VAR,  // пробел после переменной,
  S_NLINE_AFTER_VAL,   // ентер после значение переменной
  S_NLINE_AFTER_CMD,
  S_SEEN_INDENT,
  S_DEF_CMD     , // декларация команды
  S_SEEN_CMDDEF , // ожидаем имя команды
  S_SEEN_FREE_STR,  // текст без команд и переменных
}

/** 
 * Bugs: убрать неисползуемые
 */
enum LEXEMS {
  LEX_NONE    ,   // нет лексемы или ошибка декларации
  LEX_START   ,
  LEX_STR     ,
  LEX_VARVAL  ,   // значение переменной
  LEX_IDENT   ,
  // LEX_OP      , => deprecated, разбиваем это на ДОСТУПНЫЕ операции :
  LEX_DEFVAR  ,   // "!" - декларация переменной
  LEX_DEFCMD  ,   // "\" - декларация начала команды
  LEX_CMDVAL  ,
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
  LEXEMS type;
  string value;
  // на какой строк в исходном файле находится
  uint at_line;

  this(uint id, LEXEMS type, string value, uint at_line)
  {
    this.id = id;
    this.type = type;
    this.value = value;
    this.at_line = at_line;
  }

  this(Token other)
  {
    this.id = other.id;
    this.type = other.type;
    this.value = other.value;
    this.at_line = other.at_line;
  }
}