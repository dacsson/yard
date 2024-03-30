module yard.parser;

import std.stdio: writef;

import yard.utils.yrd_tree;
import yard.utils.yrd_types;

class Parser
{
  Token[] token_list;
  Yrd_tree parse_tree;

  this(Token[] token_list)
  {
    this.token_list = token_list;
    this.parse_tree = new Yrd_tree();
  }

  Yrd_tree parse()
  {
    Token curr_var_name, 
            curr_tag_name, 
            curr_var_value, 
            cur_tag_value;

    foreach (Token token; token_list)
    {
      // writef("%s %s\n", token.type, token.value);
      switch(token.type)
      {
        case LEXEMS.LEX_DEFVAR: {
          curr_var_name = token;
          // writef("varname %s\n", curr_var_name.value);
        } break;
        case LEXEMS.LEX_VARVAL: {
          curr_var_value = token;
          // writef("variable: %s %s\n", curr_var_name.type, curr_var_value.value);
          parse_tree.make_var_leaf(curr_var_name, curr_var_value);
        } break;
        case LEXEMS.LEX_DEFCMD : {
          curr_tag_name = token;
        } break;
        case LEXEMS.LEX_CMDVAL : {
          cur_tag_value = token;
          parse_tree.make_tag_leaf(curr_tag_name, cur_tag_value);
        } break;
        case LEXEMS.LEX_STR : {
          parse_tree.make_tag_leaf(Token(0, LEXEMS.LEX_DEFCMD, "\\а", 0), token);
        } break;
        default: break;
      }
    }

    return this.parse_tree;
  }
}