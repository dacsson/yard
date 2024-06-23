module yard.builders.html_builder;

import yard.builders.builder;
import yard.utils.yrd_tree;
import yard.utils.yrd_types;

import std.file;
import std.stdio : writef;
import std.string : strip, chompPrefix, capitalize;
import std.array : replace;
import std.algorithm.iteration : map;
import std.uni : toUpper;
import std.algorithm.mutation : copy;
import std.array : appender;
import std.base64 : Base64;
import std.conv;

class Html_Builder : IBuilder
{
  string content;
  bool isTitlePresent = false;

  private string set_variables(string _title, string var_name, string var_value)
  {
    var_name = strip(var_name);
    var_value = strip(var_value);
    auto abuf = appender!(char[])();
    chompPrefix(var_name, "!").map!toUpper.copy(abuf);
    // writef("chopped: %s\n", abuf.data);
    return _title.replace(`%`~ abuf.data ~ `%`, var_value);
    // switch(var_name)
    // {
    //   case "!автор": {
    //     // writef("\nREPLACE %s: \n", _title.replace(`%АВТОР%`, var_value));
    //     return _title.replace(`%АВТОР%`, var_value);
    //   } break;
    //   case "!номер": {
    //     return _title.replace("%НОМЕР%", var_value);
    //     // writef("\nREPLACE %s %s:\n", var_name, var_value);
    //   } break;
    //   case "!номер": {
    //     return _title.replace("%НОМЕР%", var_value);
    //     // writef("\nREPLACE %s %s:\n", var_name, var_value);
    //   } break;
    //   default: return _title;
    // }
  }

  private string build_element(string tag_name, string tag_value)
  {
    tag_name = strip(tag_name);
    tag_value = strip(tag_value);
    switch(tag_name)
    {
      case "\\з1": {
        return "<p class=1 align=left style='margin-left:.5in;text-align:left;text-indent:-.25in'><b>" ~ strip(tag_value) ~ "</b></p>\n";
      } break;
      case "\\з2": {
        return "<p class=1 align=left style='margin-left:.75in;text-align:left;text-indent:-.25in'>" ~ strip(tag_value) ~ "</p>\n";
      } break;
      case "\\а": {
        return "<p class=1 align=left style='margin-left:.75in;text-align:left;text-indent:-.25in'>" ~ tag_value ~ "</p>\n";
      } break;
      case "\\л": {
        if(tag_value == "начало") return "<ol>";
        else if(tag_value == "конец") return "</ol>";
        return "";
      } break;
      case "\\эл": {
        if(tag_value == "начало") return "<li>";
        else if(tag_value == "конец") return "</li>";
        return "";
      } break;
      case "\\изо": {
        return `<img src=data:image/jpg;base64,` ~ to!string(Base64.encode(cast(ubyte[])read(tag_value))) ~ ` alt="" width="500" height="600">`;
      } break;
      case "\\титул": {
        this.isTitlePresent = true;
        return ( 
          `
          

          `);
      } break;
      default: return "";
    }
  }

  string build(Yrd_tree parse_tree)
  {
    string _title = `
      <p class=MsoNormal style='text-align:justify;background:white'><img width=117
      height=113 src="Отчет%20по%20ЛР_files/image001.png" align=left hspace=12
      alt="лого для документов 2022"></p>

      <p class=MsoNormal align=center style='margin-left:63.0pt;text-align:center'><b><i><span
      lang=RU>Федеральное агентство по рыболовству</span></i></b></p>

      <p class=MsoNormal align=center style='margin-left:63.0pt;text-align:center'><b><i><span
      lang=RU>Федеральное государственное бюджетное образовательное</span></i></b></p>

      <p class=MsoNormal align=center style='margin-left:63.0pt;text-align:center'><b><i><span
      lang=RU>учреждение высшего образования</span></i></b></p>

      <p class=MsoNormal align=center style='margin-left:63.0pt;text-align:center'><b><i><span
      lang=RU>«Астраханский государственный технический университет»</span></i></b></p>

      <p class=MsoNormal align=center style='text-align:center;background:white'><b><span
      lang=RU style='font-size:6.0pt;color:black'>Система менеджмента качества в
      области образования, воспитания, науки и инноваций сертифицирована </span></b></p>

      <p class=MsoNormal align=center style='text-align:center;background:white'><b><span
      lang=RU style='font-size:6.0pt;color:black'>ООО «ДКС РУС» по международному
      стандарту ISO 9001:2015</span></b></p>

      <p class=MsoNormal style='text-align:justify;background:white'><span lang=RU>&nbsp;</span></p>

      <p class=MsoNormal style='text-align:justify;background:white'><span lang=RU>&nbsp;</span></p>

      <p class=MsoNormal><span lang=RU>&nbsp;</span></p>

      <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="98%"
      style='width:98.9%;margin-left:5.4pt;border-collapse:collapse'>
      <tr>
        <td width="18%" valign=top style='width:18.8%;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU>Институт</span></p>
        </td>
        <td width="81%" valign=top style='width:81.2%;border:none;border-bottom:solid windowtext 1.0pt;
        padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU>%ИНСТИТУТ%</span></p>
        </td>
      </tr>
      <tr>
        <td width="18%" valign=top style='width:18.8%;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU>Направление</span></p>
        </td>
        <td width="81%" valign=top style='width:81.2%;border:none;border-bottom:solid windowtext 1.0pt;
        padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU>%НАПРАВЛЕНИЕ%</span></p>
        </td>
      </tr>
      <tr>
        <td width="18%" valign=top style='width:18.8%;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU
        style='color:red'>Профиль</span></p>
        </td>
        <td width="81%" valign=top style='width:81.2%;border:none;border-bottom:solid windowtext 1.0pt;
        padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU>%ПРОФИЛЬ%</span></p>
        </td>
      </tr>
      <tr>
        <td width="18%" valign=top style='width:18.8%;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU>Кафедра</span></p>
        </td>
        <td width="81%" valign=top style='width:81.2%;border:none;border-bottom:solid windowtext 1.0pt;
        padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-top:3.0pt;text-align:justify'><span lang=RU>«</span><span
        lang=RU>%КАФЕДРА%</span><span
        lang=RU>»</span></p>
        </td>
      </tr>
      </table>

      <p class=MsoNormal style='text-align:justify;text-indent:.5in'><span lang=RU>&nbsp;</span></p>

      <p class=MsoNormal style='text-align:justify;text-indent:.5in'><span lang=RU>&nbsp;</span></p>

      <p class=MsoNormal align=center style='margin-top:.5in;text-align:center'><span
      lang=RU>&nbsp;</span></p>

      <p class=MsoNormal align=center style='margin-top:.5in;text-align:center'><b><span
      lang=RU style='font-size:20.0pt'>Лабораторная работа № %НОМЕР%</span></b></p>

      <p class=MsoNormal align=center style='text-align:center'><b><span lang=RU>&nbsp;</span></b></p>

      <p class=MsoNormal align=center style='text-align:center'><b><span lang=RU
      style='font-size:16.0pt'>«<u>%ТЕМА%»</u></span></b></p>

      <p class=MsoNormal align=center style='text-align:center'><span lang=RU>&nbsp;</span></p>

      <p class=MsoNormal align=center style='text-align:center;line-height:150%'><span
      lang=RU style='font-size:14.0pt;line-height:150%'>по дисциплине %ДИСЦИПЛИНА%</span></p>

      <p class=MsoNormal style='margin-left:3.5in'><b><span lang=RU style='font-size:
      14.0pt'>&nbsp;</span></b></p>

      <p class=MsoNormal align=center style='text-align:center;text-indent:.5in;
      line-height:150%'><span lang=RU>&nbsp;</span></p>

      <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%"
      style='width:100.0%;border-collapse:collapse;border:none'>
      <tr>
        <td width="42%" valign=top style='width:42.82%;border:solid windowtext 1.0pt;
        padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
        8.0pt'>&nbsp;</span></p>
        </td>
        <td width="2%" valign=top style='width:2.88%;border:solid windowtext 1.0pt;
        border-left:none;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='text-align:justify'><span lang=RU>&nbsp;</span></p>
        </td>
        <td width="54%" valign=top style='width:54.3%;border:solid windowtext 1.0pt;
        border-left:none;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal><span lang=RU>Работа выполнена студентом группы <span
        style='color:red'>%ГРУППА%</span></span></p>
        <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><u><span
        lang=RU>%АВТОР%</span></u><u><span lang=RU>                _____________________                          
        </span></u></p>
        <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><span lang=RU
        style='font-size:8.0pt'>       (Фамилия И.О.)       </span><span lang=RU>                       </span><span
        lang=RU style='font-size:8.0pt'>подпись</span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU>&nbsp;</span></p>
        </td>
      </tr>
      <tr>
        <td width="42%" valign=top style='width:42.82%;border:solid windowtext 1.0pt;
        border-top:none;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='text-align:center'><span lang=RU
        style='font-size:8.0pt'>&nbsp;</span></p>
        </td>
        <td width="2%" valign=top style='width:2.88%;border-top:none;border-left:
        none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
        padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='text-align:justify'><span lang=RU>&nbsp;</span></p>
        </td>
        <td width="54%" valign=top style='width:54.3%;border-top:none;border-left:
        none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
        padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal><span lang=RU>Проверил работу:</span></p>
        <p class=MsoNormal style='text-align:justify'><u><span lang=RU
        >%ПРОВЕРЯЮЩИЙ%</span></u></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
        8.0pt'> (ученая степень, ученое звание, Фамилия И.О.)</span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU>&nbsp;</span></p>
        </td>
      </tr>
      </table>

      <p class=MsoNormal><span lang=RU>                                                                                    Работа
      защищена   </span></p>

      <p class=MsoNormal style='margin-left:177.0pt'><span lang=RU>                        «___»
      _____________ 2024 г.</span></p>

      <p class=MsoNormal align=center style='text-align:center'><b><span lang=RU>&nbsp;</span></b></p>

      <p class=MsoNormal style='margin-left:205.55pt;text-align:justify;text-indent:
      .5in;line-height:150%'><span lang=RU>&nbsp;</span></p>

      <p class=MsoNormal align=center style='margin-bottom:3.0pt;text-align:center;
      text-indent:.5in;line-height:150%'><span lang=RU style='font-family:"Arial",sans-serif'>&nbsp;</span></p>

      <p class=MsoNormal align=center style='margin-bottom:3.0pt;text-align:center;
      text-indent:.5in;line-height:150%'><span lang=RU style='font-family:"Arial",sans-serif'>&nbsp;</span></p>

      <p class=MsoNormal align=center style='text-align:center'><b><span lang=RU>&nbsp;</span></b></p>

      <p class=MsoNormal align=center style='text-align:center'><b><span lang=RU>&nbsp;</span></b></p>

      <p class=MsoNormal align=center style='text-align:center'><b><span lang=RU>АСТРАХАНЬ
      – 2024</span></b></p>

      <b><span lang=RU style='font-size:12.0pt;line-height:107%;font-family:"Times New Roman",serif'><br
      clear=all style='page-break-before:always'>
      </span></b>

      <p class=MsoNormal style='margin-bottom:8.0pt;line-height:107%'><b><span
      lang=RU>&nbsp;</span></b></p>
    `;

    for(int i = 0; i < parse_tree.vars_size(); i++)
    {
      // writef("var: %s %s\n", parse_tree.get_var_leaf(i, 0), parse_tree.get_var_leaf(i, 1));
      _title = set_variables(
        _title,
        parse_tree.get_var_leaf(i, 0).value, 
        parse_tree.get_var_leaf(i, 1).value
      );
    }

    for(int i = 0; i < parse_tree.content_size(); i++)
    {
      // writef("tag: %s %s\n", parse_tree.get_tag_leaf(i, 0), parse_tree.get_tag_leaf(i, 1));
      this.content ~= build_element(
        parse_tree.get_tag_leaf(i, 0).value, 
        parse_tree.get_tag_leaf(i, 1).value
      );
    }

    // writef("REPLACED: %s\n", _title);

    string output = `<!DOCTYPE html>
      <html lang="ru">
        <head>
          <meta http-equiv=Content-Type content="text/html; charset=utf-8">
          <title></title>
          <style>
          <!--
          /* Font Definitions */
          @font-face
            {font-family:Wingdings;
            panose-1:5 0 0 0 0 0 0 0 0 0;}
          @font-face
            {font-family:"Cambria Math";
            panose-1:2 4 5 3 5 4 6 3 2 4;}
          /* Style Definitions */
          p.MsoNormal, li.MsoNormal, div.MsoNormal
            {margin:0in;
            font-size:12.0pt;
            font-family:"Times New Roman",serif;}
          p.1, li.1, div.1
            {mso-style-name:текст1;
            margin:0in;
            text-align:justify;
            text-indent:35.45pt;
            line-height:150%;
            font-size:12.0pt;
            font-family:"Times New Roman",serif;}
          .MsoChpDefault
            {font-family:"Calibri",sans-serif;}
          .MsoPapDefault
            {margin-bottom:8.0pt;
            line-height:107%;}
          /* Page Definitions */
          @page WordSection1
            {size:595.25pt 841.85pt;
            margin:56.7pt 42.55pt 56.7pt 70.9pt;}
            
            @page WordSection2
            {size:595.25pt 841.85pt;
            margin:56.7pt 42.55pt 56.7pt 70.9pt;}

          div.WordSection1
            {page:WordSection1;
            page-break-before: always;}

            div.WordSection2
            {page:WordSection2;}
          /* List Definitions */
          ol
            {margin-bottom:0in;}
          ul
            {margin-bottom:0in;}
          -->
          </style>
        </head>
        <body>`
      ~ _title ~
      content ~
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