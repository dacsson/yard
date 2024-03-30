module yard.main;

import std.stdio : writef, writeln;
import std.file : readText;

import yard.lexer;
import yard.parser;

import yard.utils.yrd_types;
import yard.utils.yrd_tree;

import yard.constructors.html_constr;
import yard.constructors.latex_constr;

int main(string[] args)
{
  string content = readText("../test/hello.yard");

  Lexer lexer = new Lexer(content);
  Token[] plexs = lexer.get_tokens();

  Parser parser = new Parser(plexs);
  Yrd_tree parse_tree = parser.parse();

  switch(args[1])
  {
    case "html": {
      Html_Constr html = new Html_Constr();
      string html_output = html.build(parse_tree);
      writef("%s\n", html_output);
      html.create_file("../test/temp.html");
    } break;
    case "latex": {
      Latex_Constr latex = new Latex_Constr();
      string latex_output = latex.build(parse_tree);
      writef("%s\n", latex_output);
      latex.create_file("../test/temp.tex");
    } break;
    default: break;
  }
  // for(int i = 0; i < parse_tree.vars_size(); i++)
  // {
  //   writef("var: %s %s\n", parse_tree.get_var_leaf(i, 0), parse_tree.get_var_leaf(i, 1));
  // }
  //   for(int i = 0; i < parse_tree.content_size(); i++)
  // {
  //   writef("tag: %s %s\n", parse_tree.get_tag_leaf(i, 0), parse_tree.get_tag_leaf(i, 1));
  // }
  


  return 0;
}
