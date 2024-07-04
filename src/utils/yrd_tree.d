module yard.utils.yrd_tree;

import std.stdio : writef;
import std.array;
import std.algorithm;
import std.conv : to;

import yard.lexer;
import yard.utils.yrd_types;
import yard.utils.yrd_errors;

struct Leaf
{
  Token name;
  Token value;

  this(Token name, Token value)
  {
    this.name = name;
    this.value = value;
  }
}

struct Super_Leaf
{
  Token parent;
  Leaf child; 
  
  this(Token parent, Leaf child)
  {
    this.parent = parent;
    this.child = child;
  }
}

struct Header
{
  size_t page;
  size_t level;
  size_t count;
  string value;
}

/** 
 * Абстрактное синтаксическое дерево, чтобы не хранить данные в парсере
 * вынесено как отдельная структура 
 */
class Yrd_tree
{
  // дерево контента документа (то что отображается на выходе)
  Leaf[] content;
  // дерево переменных документа (важных параметров т.е. класс документа и тому подобное)
  Leaf[] vars;
  // 
  Super_Leaf[] templ_content;

  Header[] headers;

  size_t h1_count, h2_count, h3_count, pg_count;

  this() {
    h1_count = 0;
    h2_count = 0;
    h3_count = 0;
    pg_count = 1;
  }

  size_t vars_size()
  {
    return this.vars.length;
  }

  size_t content_size()
  {
    return this.content.length;
  }

  size_t templ_size()
  {
    return this.templ_content.length;
  }

  void make_var_leaf(Token name, Token value)
  {
    vars ~= Leaf(name, value);
  }

  void make_tag_leaf(Token name, Token value)
  {
    // writef("making leaf %s==%s %s %s\n", name.value, TAGS.H1, value.value, name.value == TAGS.H1);

    if(name.value == "\\з1") {
      // writef(" h1: %s | %d |\n", value.value, h1_count);
      value.value = (to!string(h1_count + 1) ~ " " ~ value.value);
      Header header = Header(pg_count, 1, h1_count, value.value);
      headers ~= header;
      h2_count = 0;
      h1_count++;
    }
    else if(name.value == "\\з2") {
      // writef(" h1: %s | %d | %d |\n", value.value, h1_count, h2_count);
      value.value = ( to!string(h1_count) ~ "." ~ to!string(h2_count + 1) ~ " " ~ value.value);
      Header header = Header(pg_count, 2, h2_count, value.value);
      headers ~= header;
      h3_count = 0;
      h2_count++;
    }
    else if(name.value == "\\з3") {
      value.value = ( to!string(h1_count) ~ "." ~ to!string(h2_count) ~ "." ~ to!string(h3_count + 1) ~ " " ~ value.value);
      Header header = Header(pg_count, 3, h3_count, value.value);
      headers ~= header;
      h3_count++;
    }
    else if(name.value == "\\стр") pg_count++;
    content ~= Leaf(name, value);
  }

  void make_templ_leaf(Token pname, Token cname, Token cvalue) 
  {
    templ_content  ~= Super_Leaf(pname, Leaf(cname, cvalue));
  }

  Token get_var_leaf(size_t index, bool retValue)
  {
    if(retValue) { return vars[index].value; }
    return vars[index].name;
  }

  Token get_tag_leaf(size_t index, bool retValue)
  {
    if(retValue) { return content[index].value; }
    return content[index].name;
  }

  string get_templ_opt_value(string parent_name, string opt_name)
  {
    // writef(" SEARCHIN LEAF %s for %s", parent_name, opt_name);
    foreach (Super_Leaf el; templ_content)
    {
      if(el.parent.value == parent_name && el.child.name.value == opt_name) {
        return el.child.value.value;
      }
    }

    throw new ERROR_Option_Not_Found(opt_name, parent_name);
  }

  Token[] find_var_leaf(string var_name)
  {
    Token[] var_tokens;
    for(int i = 0; i < vars.length; i++)
    {
      if(vars[i].name.value == var_name) { var_tokens ~= vars[i].value; }
    }

    return var_tokens;
  }

  Token[] find_tag_leaf(string tag_name)
  {
    Token[] tag_tokens;
    for(int i = 0; i < content.length; i++)
    {
      if(content[i].name.value == tag_name) { tag_tokens ~= content[i].value; }
    }

    return tag_tokens;
  }

  // Token[] opBinary(string op: "~")(Token rhs) const
  // {
  //   Yrd_node new_node = Yrd_node(rhs);
  //   return nodes ~ new_node;
  // }

  // private void opOpAssign(string op: "~", Token)(Token value)
  // {
  //   Yrd_node new_node = Yrd_node(value);
  //   length++;
  //   nodes ~= Yrd_node(value);
  // }

  // void make_content_leaf(Token* Token value)
  // {
  //   Yrd_node new_node = Yrd_node(value);
  //   length++;
  //   nodes ~= new_node;
  // }

  // void make_var_leaf(Token* Token value)
  // {
  //   Yrd_node new_node = Yrd_node(value);
  //   length++;
  //   nodes ~= new_node;
  // }

  // void remove_leaf_at(size_t index)
  // {
  //   nodes = remove(nodes, index);
  //   length--;
  // }
}