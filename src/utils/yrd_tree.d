module yard.utils.yrd_tree;

import std.stdio : writef;
import std.array;
import std.algorithm;

import yard.lexer;
import yard.utils.yrd_types;

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

struct Yrd_node
{
  Yrd_node* parent;
  Yrd_node*[] children; // optimize
  Token token;
  
  this(Yrd_node* parent, Yrd_node*[] children, Token token)
  {
    this.parent = parent;
    this.children = children.dup;
    this.token = token;
  }
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

  size_t vars_size()
  {
    return this.vars.length;
  }

  size_t content_size()
  {
    return this.content.length;
  }
  /** 
   * Deprecated: если бы структура имела конструктор то пришлось бы 
   * именно в нём прописывать правила добавления в массив (то что делает парсер!)
   */
  // this(Token[] tokens)
  // {
  //   foreach (Token key; tokens)
  //   {
  //     nodes ~= Yrd_node(key);
  //     length++;
  //   }
  //   this.nodes = nodes;
  // }

  // ref Token opIndex(size_t index)
  // {
  //   return nodes[index].token;
  // }

  // void opIndexAssign(Token)(Token value, size_t index)
  // {
  //   nodes[index].token = value;
  // }

  void make_var_leaf(Token name, Token value)
  {
    vars ~= Leaf(name, value);
  }

  void make_tag_leaf(Token name, Token value)
  {
    content ~= Leaf(name, value);
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