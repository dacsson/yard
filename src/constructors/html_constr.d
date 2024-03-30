module yard.constructors.html_constr;

import yard.constructors.constructor;
import yard.utils.yrd_tree;
import yard.utils.yrd_types;

import std.file;

class Html_Constr : IConstructor
{
  string content;

  private string set_variables(string var_name, string var_value)
  {
    return "";
  }

  private string build_element(string tag_name, string tag_value)
  {
    switch(tag_name)
    {
      case "\\з1": {
        return "<h1>" ~ tag_value ~ "</h1>\n";
      } break;
      case "\\а": {
        return "<p>" ~ tag_value ~ "</p>\n";
      } break;
      default: return tag_value;
    }
  }

  string build(Yrd_tree parse_tree)
  {
    for(int i = 0; i < parse_tree.content_size(); i++)
    {
      // writef("tag: %s %s\n", parse_tree.get_tag_leaf(i, 0), parse_tree.get_tag_leaf(i, 1));
      this.content ~= build_element(
        parse_tree.get_tag_leaf(i, 0).value, 
        parse_tree.get_tag_leaf(i, 1).value
      );
    }

    string output = `<!DOCTYPE html>
      <html lang="ru">
        <head>
          <meta http-equiv=Content-Type content="text/html; charset=utf-8">
          <title></title>
        </head>
        <body>`
      ~ content ~
      `
        </body>
      </html>`;

    this.content = output;

    return output;
  }

  void create_file(string file_name)
  {
    write(file_name, content);
  }
}