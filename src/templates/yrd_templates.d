module yard.templates.yrd_templates;

import std.file : readText;
import std.stdio : writef, writeln;
import std.string : splitLines, strip, split;
import std.array : replace;

import yard.utils.yrd_types;

enum TXTALIGMENT : string {
  LEFT    = "левому",
  RIGHT   = "правому",
  CENTER  = "центру",
  BYWIDTH = "ширине"
}

enum TXTFORMAT : string {
  ITALIC      = "курсив",
  BOLD        = "жирный",
  NORMAL      = "нормальный",
  SUBSCRIPT   = "подстрочный",
  SUPERSCRIPT = "надстрочный"
}

enum TXTREGISTRE : string {
  CAPS    = "капс",
  NORMAL  = "нормальный"
}

struct Page_Object_Style {
  size_t width;
  size_t height;
  size_t top_margin;
  size_t bottom_margin;
  size_t left_margin;
  size_t right_margin;
}

struct Text_Object_Style {
  size_t font_size;
  TXTALIGMENT aligment;
  TXTFORMAT format;
  TXTREGISTRE registre;
}

class Template {
  // Page_Object_Style[] pages_styles;
  // string[Text_Object_Style] tags_styles;
  // // титул
  // // обязательные переменные 
  // // стиль картинок

  // void read(string template_path) {
  //   string content = readText(template_path);
  //   content = replace(content, " ", "");
  //   string[] splitted = split(content);

  //   bool reading_page = false;
  //   bool reading_txt_tag = false;
  //   foreach (string key; splitted)
  //   {
  //     Page_Object_Style page_style;
  //     Text_Object_Style txt_style;

  //     if(key == TEMPLATES.PAGE) {
  //       reading_page = true;
  //     }
  //     else if(key == TAGS.H1) {
  //       reading_txt_tag = true;
  //     }

  //     if(reading_page) {
  //       switch(key) {
  //         case TEMPL_PAGEST.HEIGHT: {
            
  //         } break;
  //       } 
  //     }
  //   }

  //   writef("%s\n", splitted);
  // }
}