module yard.builders.pdf_builder;

import yard.builders.builder;
import yard.utils.yrd_tree;
import yard.utils.yrd_types;
import yard.utils.yrd_ttf;

import std.file : write, read;
import std.conv : to, hexString;
import std.stdio : writef;
import std.string : indexOf;
import std.format : format;
import std.utf : decode;
import std.algorithm: canFind;

// Объект пдф
// ex. 
// 41 0 obj <</Type/Pages/Kids[34 0 R 43 0 R 52 0 R]/Count 3>> endobj
class PDF_Object
{
  // имя чтобы ссылаться на объект
  size_t name;

  // почти всегда ноль
  size_t rev_num;

  // зависит от типа объекта
  string value;

  // имя каталога всегда 1 
  void create_catalog()
  {
    name = 1;
    rev_num = 0;

    value = "<<\n/Type /Catalog\n/Pages 2 0 R\n>>";
  }

  /** 
   * 
   * Params:
   *   name = obj name num
   *   rev_num = revision num
   *   pg_count = сколько страниц в документе
   *   children_names = объекты для ссылки
   */
  void create_pages_tree(size_t name, size_t rev_num, size_t pg_count, PDF_Object[] children)
  {
    this.name = name;
    this.rev_num = rev_num;

    value = "<<\n/Type /Pages\n/Count " ~ to!string(pg_count) ~ "\n/Kids [ ";

    foreach (PDF_Object child; children)
    {
      value ~= (to!string(child.name) ~ " " ~ to!string(child.rev_num) ~ " R ");
    }

    value ~= "]\n>>";
  }
  
  /** 
   * Объявление страницы
   * Params:
   *   name = 
   *   rev_num = 
   *   parent_name = ссылка на голову дерева страниц
   *   resources_name = ссылка на ресурсы (шрифт)
   *   contents_name = ссылка на объект с данными для отображения
   *   x_box_pos = длина страницы
   *   y_box_pos = высота страницы
   * Examples: 
   *  4 0 obj
   *   <<
   *   /Type /Page
   *   /Parent 3 0 R
   *   /Resources << /Font << /F1 7 0 R >> /ProcSet 6 0 R >>
   *   /MediaBox [ 0 0 612 792 ]
   *   /Contents 5 0 R
   *   >>
   *  endobj
   */
  void create_page(
    size_t name, size_t rev_num, 
    size_t parent_name, size_t resources_name, size_t contents_name,
    size_t x_box_pos, size_t y_box_pos
  )
  {
    this.name = name;
    this.rev_num = rev_num;

    value = 
      "<<\n/Type /Page\n" ~
      "/Parent " ~
      to!string(parent_name) ~
      " 0 R\n" ~
      "/MediaBox [ 0 0 " ~
      to!string(x_box_pos) ~
      " " ~
      to!string(y_box_pos) ~
      " ]\n" ~
      "/Resources << /Font <</F1 " ~
      to!string(resources_name) ~
      " 0 R >> /ProcSet [ /PDF /Text ] >>\n" ~
      "/Contents " ~
      to!string(contents_name) ~
      " 0 R\n>>";
  }

  void create_embed_font(size_t name, size_t rev_num, string path_to_font)
  {
    this.name = name;
    this.rev_num = rev_num; 

    const ubyte[] stream_value = cast(const(ubyte)[])read(path_to_font);

    // длина потока в байтах
    ubyte[] byte_stream = cast(ubyte[])stream_value;
    size_t stream_size = byte_stream.length;

    // тип компрессии
    string compression_type;

    value = "<</Length " ~ to!string(stream_size) ~ " /Length1 " ~ to!string(stream_size) ~ " >>\nstream\n" ~ cast(string)stream_value ~ "\nendstream";
  }

  void create_cid_tbl(size_t name, size_t rev_num, wchar[] unique_letters, string font_path)
  {
    this.name = name;
    this.rev_num = rev_num;
    
    TTF font = new TTF(font_path);
    string[string][] char_glyph_table = font.cmap.char_glyph_table;

    string cctgi_table = "";

    // для каждый буквы найти corresponding glyph index
    foreach (wchar letter; unique_letters)
    {
      int char_code = cast(int)letter;
      string hex_char_code = dec_to_hexa(char_code);
      string glyph_index = font.find_glyph_index(letter);

      string line = "<" ~ hex_char_code ~ "><" ~ glyph_index ~ ">" ~ "\n";
      cctgi_table ~= line;
    }
    // for(int i = 0; i < unique_letters.length; i++) {
    //   int char_code = cast(int)unique_letters[i];
    //   string hex_char_code = dec_to_hexa(char_code);
    //   string glyph_index = cmap.find_glyph_index(unique_letters[i]);

    //   string line = "<" ~ hex_char_code ~ "><" ~ glyph_index ~ ">" ~ "\n";
    //   cctgi_table ~= line;
    // }

    string stream_value = 
      "\n/CIDInit /ProcSet findresource begin" ~ 
      "\n12 dict begin" ~
      "\nbegincmap" ~
      "\n/CIDSystemInfo" ~
      "\n<<  /Registry (Adobe)" ~
      "\n/Ordering (UCS)" ~
      "\n/Supplement 0" ~
      "\n>> def" ~
      "\n/CMapName /Adobe-Identity-UCS def" ~
      "\n/CMapType 2 def" ~
      "\n1 begincodespacerange" ~
      "\n<0000> <FFFF>" ~
      "\nendcodespacerange" ~
      "\n9 beginbfchar\n" ~
      cctgi_table ~
      "endbfchar" ~
      "\nendcmap" ~
      "\nCMapName currentdict /TTF defineresource pop" ~
      "\nend\nend";

    // длина потока в байтах
    ubyte[] byte_stream = cast(ubyte[])stream_value;
    size_t stream_size = byte_stream.length;

    // тип компрессии
    string compression_type;

    value = "<</Length " ~ to!string(stream_size) ~ " >>\nstream" ~ stream_value ~ "endstream";

    //     value = "<<\n/Length 450\n>>\nstream
    // /CIDInit /ProcSet findresource begin
    // 12 dict begin
    // begincmap
    // /CIDSystemInfo
    // <<  /Registry (Adobe)
    // /Ordering (UCS)
    // /Supplement 9
    // >> def
    // /CMapName /Adobe-Identity-UCS def
    // /CMapType 2 def
    // 1 begincodespacerange
    // <0000> <FFFF>
    // endcodespacerange
    // 9 beginbfchar
    // <0004> <0021>
    // <000F> <002C>
    // <0249> <041F>
    // <025C> <0432>
    // <025F> <0435>
    // <0262> <0438>
    // <0266> <043C>
    // <026A> <0440>
    // <026C> <0442>
    // endbfchar
    // endcmap
    // CMapName currentdict /TTF defineresource pop
    // end
    // end
    // endstream";
  }

  /** 
   * 
   * Params:
   *   name = 
   *   rev_num = 
   *   font_name = 
   *   ascent = 
   *   descent = 
   *   stemv = 
   *   cap_height = 
   *   font_file_name =
   * Examples:
      9 0 obj
      <</Type /FontDescriptor
      /FontName /YAZWPA+Times-Roman
      /Flags 6
      /Ascent 891.11328
      /Descent -216.30859
      /StemV 61.035156
      /CapHeight 662.10938
      /ItalicAngle 0
      /FontBBox [-568.35938 -306.64063 2000 1006.83594]
      /FontFile2 8 0 R>>
      endobj  
   */
  void create_font_descriptor(
    size_t name, size_t rev_num, 
    string font_name,
    double ascent, double descent, double stemv, double cap_height,
    size_t font_file_name
  )
  {
    this.name = name;
    this.rev_num = rev_num;

    value = 
      "<<\n/Type /FontDescriptor\n/FontName /" ~ 
      font_name ~ 
      "\n/Ascent " ~ 
      to!string(ascent) ~ 
      "\n/Descent " ~ 
      to!string(descent) ~
      "\n/StemV " ~
      to!string(stemv) ~
      "\n/CapHeight " ~ 
      to!string(cap_height) ~
      "\n/Flags 6" ~
      "\n/FontBBox [-568 -307 2046 1039]" ~
      "\n/AvgWidth 401" ~
      "\n/MaxWidth 2000" ~
      "\n/XHeight 447" ~
      "\n/ItalicAngle 0" ~
      "\n/FontFile2 " ~
      to!string(font_file_name) ~
      " 0 R\n>>"; 
  }

  void create_base_font_object(size_t name, size_t rev_num, size_t font_child_name, size_t cid_tbl_name)
  {
    this.name = name;
    this.rev_num = rev_num;

    value = 
      "<<\n/Encoding /Identity-H\n/ToUnicode " ~ 
      to!string(cid_tbl_name) ~ 
      " 0 R\n/Subtype /Type0\n/Type /Font\n/DescendantFonts [" ~ 
      to!string(font_child_name) ~ 
      " 0 R]\n/BaseFont /YAZWPA+Times-Roman\n>>";    
  }

  /** 
   * 
   * Params:
   *   name = 
   *   rev_num = 
   *   subtype = 
   *   name = 
   *   base_font = 
   * Examples: 
   *  7 0 obj
   *   <<
   *   /Type /Font
   *   /Subtype /Type1
   *   /Name /F1
   *   /BaseFont /Helvetica
   *   /FontDescriptor 9 0 R
   *   /Encoding /MacRomanEncoding
   *   >>
   *  endobj
   */
  void create_font_object(size_t name, size_t rev_num, string subtype, string font_name, string base_font, size_t font_desc_name, wchar[] unique_letters, string font_path)
  {
    this.name = name;
    this.rev_num = rev_num;

    TTF font = new TTF(font_path);

    // для каждый буквы найти width
    string widths = "\n/W [";
    foreach (wchar letter; unique_letters)
    {
      string glyph_index = font.find_glyph_index(letter);
      int dec_glyph_index = to!int(glyph_index, 16);
      int width = font.find_glyph_width(letter);
      double rel_width = width / 2.048; // WHY 2.048 ??????? 2 to the power of 11?
      writef("glyphs width: | glyh %s | index %s | dec index %d | width full %d | width %f |\n", letter, glyph_index, dec_glyph_index, width, rel_width);
      string pair = " " ~ to!string(dec_glyph_index) ~ " [" ~ to!string(rel_width) ~ "]";
      widths ~= pair;
    }
    widths ~= "]";

    value = 
      "<<\n/Type /Font\n/Subtype /" ~ 
      subtype ~ 
      "\n/BaseFont /" ~ 
      base_font ~ 
      "\n/CIDToGIDMap /Identity\n/CIDSystemInfo\n<<\n/Ordering (Identity)\n/Registry (Adobe)\n/Supplement 0\n>>" ~ 
      "\n/FontDescriptor " ~ 
      to!string(font_desc_name) ~
      " 0 R" ~
      "\n/DW 250" ~
      widths ~
      // "\n/FirstChar 33\n/LastChar 42" ~
      // "\n/W [0 [777.83203 0 0 0 333.00781] 585 [722.16797] 604 [472.16797 0 0 443.84766 0 0 535.15625 0 0 0 632.8125 0 0 0 500 0 437.01172]]" ~
      "\n>>";
      // "\n/Widths [722 500 535 472 444 437 250 250 633 333]" ~
      // "\n/ToUnicode " ~ 
      // to!string(cid_tbl_name) ~ " 0 R\n>>";
  }

  /** 
   * Создание объекта внутри котрого есть поток 
   * Examples: 
   *  BT
   *    /F1 24 Tf -> defines font and font size
   *    175 720 Td -> position of the text
   *    (Hello World!)Tj -> text to be displayed itself 
   *  ET
   */
  void create_stream_object(size_t name, size_t rev_num, size_t font_size, size_t x_pos, size_t y_pos, string text)
  {
    this.name = name;
    this.rev_num = rev_num; 

    string stream_value = "\nBT \n/F1 12 Tf \n100 100 Td \n[ <0249><026A><0262><025C><025F><026C><000F><0003><0266><0262><026A><0004>] TJ \nET\n";
      // "\nBT" ~ 
      // "\n/F1 " ~ 
      // to!string(font_size) ~ 
      // " Tf\n" ~
      // "100 100 Td\n(" ~
      // // "\n100 100 Td" ~ 
      // // "(Hello, world!" ~
      // text ~
      // ") Tj"  ~
      // "\nET\n";
      // "BT\n/F4 14.666667 Tf\n1 0 0 -1 51.725418 .62304592 Tm\n0 -13.0696621 Td <0266> Tj\n9.2746582 0 Td <0262> Tj\n7.8433838 0 Td <026A> Tj\n7.328125 0 Td <0004> Tj\nET\n";

    // длина потока в байтах
    ubyte[] byte_stream = cast(ubyte[])stream_value;
    size_t stream_size = byte_stream.length;

    // тип компрессии
    string compression_type;

    value = "<</Length " ~ to!string(stream_size) ~ " >>\nstream" ~ stream_value ~ "endstream";
  }

  string build() 
  {
    string res = 
      to!string(name) ~ 
      " " ~
      to!string(rev_num) ~ 
      " obj\n" ~ 
      value ~
      "\n" ~
      "endobj";
    return res;
  }
}

class PDF_Body
{
  PDF_Object[] objects; 

  void create_objects(Yrd_tree parse_tree)
  {
    size_t id = 1;
    size_t pages_count = 1;
    
    // массив уникальных символов для CMAP таблицы
    wchar[] unique_letters;

    // добавляем каталон
    PDF_Object catalog_obj = new PDF_Object();
    catalog_obj.create_catalog();
    objects ~= catalog_obj;
    id++;

    // @TODO FIND HOW MANY PAGES
    id = 4; // пропускаем 2 и 3 это будут: объявление страницы и дерева страниц
    PDF_Object[] temp_objs;

    // добавляем объекты
    for(int i = 0; i < parse_tree.content_size(); i++)
    {
      // writef("tag: %s %s\n", parse_tree.get_tag_leaf(i, 0), parse_tree.get_tag_leaf(i, 1));
      string tag_name = parse_tree.get_tag_leaf(i, 0).value;
      string tag_value =  parse_tree.get_tag_leaf(i, 1).value;


      if(tag_name == "\\з1")
      {
        PDF_Object new_obj = new PDF_Object();
        new_obj.create_stream_object(id += i, 0, 12, 175, 720 + i, tag_value);
        temp_objs ~= new_obj;
      }

      // уникальные буквы
      foreach (wchar letter; tag_value)
      {
        if(!unique_letters.canFind(letter)) unique_letters ~= letter;
        writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
      }
    }

    PDF_Object font_embed_obj = new PDF_Object();
    font_embed_obj.create_embed_font(id + 1, 0, "/System/Library/Fonts/Supplemental/Times New Roman.ttf");

    PDF_Object font_desc_obj = new PDF_Object();
    font_desc_obj.create_font_descriptor(id + 2, 0, "YAZWPA+Times-Roman", 891, -216, 0, 662, font_embed_obj.name);

    PDF_Object cid_tbl_obj = new PDF_Object();
    cid_tbl_obj.create_cid_tbl(id + 3, 0, unique_letters,"/System/Library/Fonts/Supplemental/Times New Roman.ttf");

    PDF_Object resources_obj = new PDF_Object();
    resources_obj.create_font_object(id + 4, 0, "CIDFontType2", "F1", "YAZWPA+Times-Roman", font_desc_obj.name, unique_letters, "/System/Library/Fonts/Supplemental/Times New Roman.ttf");

    PDF_Object parent_font_obj = new PDF_Object();
    parent_font_obj.create_base_font_object(id + 5, 0, resources_obj.name, cid_tbl_obj.name);

    PDF_Object page_obj = new PDF_Object();
    page_obj.create_page(3, 0, 2, parent_font_obj.name, temp_objs[0].name, 500, 800);
    
    PDF_Object pages_tree_obj = new PDF_Object();
    pages_tree_obj.create_pages_tree(2, 0, pages_count, [page_obj]);
    
    objects ~= pages_tree_obj;
    objects ~= page_obj;

    foreach (PDF_Object obj; temp_objs)
    {
      objects ~= obj;
    }

    objects ~= font_embed_obj;
    objects ~= font_desc_obj;
    objects ~= cid_tbl_obj;
    objects ~= resources_obj;
    objects ~= parent_font_obj;
  }

  string build()
  {
    string res = "";

    foreach (PDF_Object obj; objects)
    {
      res ~= ("" ~ obj.build() ~ "\n");
    }

    return res;
  }
}

// ex. 0000000003 65535 f - head of the linked list
// ex. 0000017496 00000 n
class PDF_CRTable_Object
{
  // сколько байтов с начала файла чтобы придти к объекту (на который ссылается)
  // number of bytes (in decimal) from the beginning of the PDF file to where the object appears in the body.
  // ex. 0000000721
  size_t pointer_to_obj;

  // ex. 00007
  size_t generation_number;

  // f - free obj
  // n - in use obj
  char type;

  this(size_t pointer_to_obj, size_t generation_number, char type)
  {
    this.pointer_to_obj = pointer_to_obj;
    this.generation_number = generation_number;
    this.type = type;
  }

  string build()
  {
    string res = 
      format("%.*d", 10, pointer_to_obj) ~ 
      " " ~ 
      format("%.*d", 5, generation_number) ~ 
      " " ~ 
      to!string(type) ~ "\n";

    return res;
  }
}

// ex.
// 0 1
// 0000000000 65535 f
class PDF_CRTable_Subsection
{
  // ссылка на имя первого объекта подсекции
  size_t list_head_name;

  PDF_CRTable_Object[] refs;

  // @TODO FIX CONSTRUCTOR
  this(size_t list_head_name, string pdf_output, PDF_Object[] pdf_body_objs)
  {
    this.list_head_name = list_head_name;

    // ссылка на начало 
    PDF_CRTable_Object head = new PDF_CRTable_Object(0, 65_535, 'f');
    refs ~= head;

    string find_obj;
    PDF_CRTable_Object curr_crt_obj;

    foreach (PDF_Object obj; pdf_body_objs)
    {
      find_obj = pdf_output[0..indexOf(pdf_output, to!string(obj.name) ~ " 0 obj")];
      ubyte[] byte_stream = cast(ubyte[])find_obj;

      curr_crt_obj = new PDF_CRTable_Object(byte_stream.length, 0, 'n');
      // writef("%s", find_obj);
      refs ~= curr_crt_obj;
    }
  }

  string build()
  {
    string res = (to!string(list_head_name) ~ " " ~ to!string(refs.length) ~ "\n");

    foreach (PDF_CRTable_Object obj; refs)
    {
      res ~= obj.build();
    }

    return res;
  }
}

// Cross-reference table
// ex. 
// xref
// 0 4
// 0000000003 65535 f
// 0000017496 00000 n
// 0000000721 00003 n
// 0000000000 00007 f
class PDF_CRTable 
{
  PDF_CRTable_Subsection[] sub_sections;

  void create_sections(string pdf_output, PDF_Object[] pdf_body_objs)
  {
    PDF_CRTable_Subsection ssec = new PDF_CRTable_Subsection(0, pdf_output, pdf_body_objs);
    sub_sections ~= ssec;
    // foreach (PDF_Object obj; pdf_body_objs)
    // {
    //   PDF_CRTable_Subsection ssec = new PDF_CRTable_Subsection(0, pdf_output, pdf_body_objs)
    // }
  }

  string build() 
  {
    string res = "xref\n";

    foreach (PDF_CRTable_Subsection ssec; sub_sections)
    {
      res ~= ssec.build();
    }

    return res;
  }
}


// ex.
// trailer
// <<
// /Size 22
// /Root 2 0 R
// /Info 1 0 R
// >>
// startxref
// 18799
// %%EOF
class PDF_Trailer
{
  // количество секций в cross ref table 
  size_t size;

  // имя root объекта (каталог)
  size_t root_name;

  // количество байт от начала документа чтобы дойти до xref 
  size_t pointer_to_obj;

  /** 
   * 
   * Params:
   *   size = количество секций в cross ref table 
   *   root_name = имя root объекта (каталог)
   */
  void create_trailer(size_t size, size_t root_name, string pdf_output)
  {
    this.size = size;
    this.root_name = root_name;

    string to_xref = pdf_output[0..indexOf(pdf_output, "xref")];
    ubyte[] byte_stream = cast(ubyte[])to_xref;
    
    this.pointer_to_obj = byte_stream.length;
  }

  string build()
  {
    string res = "";

    res = "trailer\n<<\n/Size " ~
          to!string(size) ~ 
          "\n/Root " ~ 
          to!string(root_name) ~ 
          " 0 R\n>>\nstartxref\n" ~ 
          to!string(pointer_to_obj) ~ 
          "\n%%EOF";

    return res;  
  }
}

class PDF_Builder 
{
  string pdf_header;
  PDF_Body pdf_body;
  PDF_CRTable pdf_crtable;
  PDF_Trailer pdf_trailer;

  string content;
  bool isTitlePresent = false;

  this()
  {
    pdf_header = "%PDF-1.6\n";
    pdf_body = new PDF_Body();
    pdf_crtable = new PDF_CRTable();
    pdf_trailer = new PDF_Trailer();
  }

  private string set_variables(string var_name, string var_value)
  {
    return "";
  }

  private string build_element(string tag_name, string tag_value)
  {
    switch(tag_name)
    {
      case "\\з1": {
        return `\section{` ~ tag_value ~ "}\n";
      } break;
      case "\\а": {
        return `\paragraph{` ~ tag_value ~ "}\n";
      } break;
      default: return tag_value;
    }
  }

  string build(Yrd_tree parse_tree)
  {
    // for(int i = 0; i < parse_tree.content_size(); i++)
    // {
    //   // writef("tag: %s %s\n", parse_tree.get_tag_leaf(i, 0), parse_tree.get_tag_leaf(i, 1));
    //   this.content ~= build_element(
    //     parse_tree.get_tag_leaf(i, 0).value, 
    //     parse_tree.get_tag_leaf(i, 1).value
    //   );
    // }

    /*
      1. HEADER => добавить версию пдф
      2. BODY => создать и добавить пдф объекты
      3. CRTABLE => создать подсекции => добавить ссылки на объекты
      4. TRAILER => создать ссылку на начало дока и ссылку на CRTABLE
    */

    // 2. 
    pdf_body.create_objects(parse_tree);
    this.content = pdf_header ~ pdf_body.build(); 

    // 3. 
    pdf_crtable.create_sections(this.content, pdf_body.objects);
    this.content ~= pdf_crtable.build();

    // 4.
    pdf_trailer.create_trailer(pdf_crtable.sub_sections[0].refs.length, 1, this.content);
    this.content ~= pdf_trailer.build();

    return this.content;
  }

  void create_file(string file_name)
  {
    write(file_name, content);
  }
}