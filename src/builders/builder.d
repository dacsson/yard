module yard.builders.builder;

import yard.utils.yrd_tree;

interface IBuilder
{
  private string set_variables(string var_name, string var_value);

  private string build_element(string tag_name, string tag_value);

  // построить файл в выходном формате
  string build(Yrd_tree content_tree);

  // создать файл
  void create_file(string file_name);
}