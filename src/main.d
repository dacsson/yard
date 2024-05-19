module yard.main;

import std.stdio : writef, writeln;
import std.file : readText;

import yard.lexer;
import yard.parser;

import yard.utils.yrd_types;
import yard.utils.yrd_tree;
import yard.utils.yrd_ttf;

import yard.builders.html_builder;
import yard.builders.latex_builder;
import yard.builders.pdf_builder;

// import libharu_topdf;

int main(string[] args)
{
  // "/home/thephoneoff/MyProjects/yard/test/simple.yard"
  string content = readText(args[1]);

  Lexer lexer = new Lexer(content);
  Token[] plexs = lexer.get_tokens();

  // foreach (Token key; plexs)
  // {
  //   writef("%s\t%s\n", key.type, key.value);
  // }

  Parser parser = new Parser(plexs);
  Yrd_tree parse_tree = parser.parse();

  switch(args[2])
  {
    case "html": {
      // Html_ html = new Html_Constr();
      // string html_output = html.build(parse_tree);
      // // writef("%s\n", html_output);
      // html.create_file("/home/thephoneoff/MyProjects/yard/test/temp.html");
    } break;
    case "latex": {
      // Latex_Constr latex = new Latex_Constr();
      // string latex_output = latex.build(parse_tree);
      // // writef("%s\n", latex_output);
      // latex.create_file("../test/temp.tex");
    } break;
    case "pdf": {
      PDF_Builder pdf = new PDF_Builder();
      string pdf_output = pdf.build(parse_tree);
      // writef("pdf:\n%s\n", pdf_output);
      pdf.create_file("../test/new.pdf");
    } break;
    default: {
      // import std.file : write, read;
      // import std.string : indexOf;
      string font_path = "/System/Library/Fonts/Supplemental/Times New Roman.ttf";
      TTF ttf = new TTF(font_path);
      int h = ttf.htmx.h_metrics[618].advance_width;
      writef("\nw for %d => %d\n", 618, h);
      ttf.find_glyph_width('П');
      // cmap.read_hhea_table()
      // string[string][] char_glyph_table = cmap.char_glyph_table;
      // for(int i = 0; i < char_glyph_table.length; i++) {
      //   foreach (key, value; char_glyph_table[i])
      //   {
      //     writef("key: %s, value: %s\n", key, value);
      //     // int val = value;
      //     // ubyte[] data = cast(ubyte[])val;
      //     // string hex = data.toH;
      //     // writef("%s\n", hex);
      //   }
      //   // writef("%d: %d", char_glyph_table[i].ke)
      // }
    } break;
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
