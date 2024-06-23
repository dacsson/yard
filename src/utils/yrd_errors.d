module yard.utils.yrd_errors;

import std.exception;

class ERROR_Option_Not_Found : Exception
{
  this(string opt_name, string tag_name, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @safe
  {
    super("Опция '" ~ opt_name ~ "' для тэга '" ~ tag_name ~ "' не найдена в шаблоне ", file, line, nextInChain);
  }
}
