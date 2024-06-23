module yard.builders.pdf_builder;

import yard.builders.builder;
import yard.utils.yrd_tree;
import yard.utils.yrd_types;
import yard.utils.yrd_ttf;
import yard.utils.yrd_searcher;
import yard.utils.yrd_errors;

import std.file : write, read;
import std.conv : to, hexString;
import std.stdio : writef;
import std.string : indexOf, capitalize, split;
import std.format : format;
import std.utf : decode;
import std.algorithm: canFind;
import std.base64 : Base64;
import std.uni : toUpper, isWhite;

const size_t HEIGHT = 842;
const size_t WIDTH = 596;

// PAGE CONSTANTS
size_t PAGE_HEIGHT, PAGE_WIDTH, PAGE_TOP_MARGIN, PAGE_BOTTOM_MARGIN, PAGE_LEFT_MARGIN, PAGE_RIGHT_MARGIN;
string PAGE_FONT;

// TEMPLATE CONSTANTS
size_t TMP_PAGE_HEIGHT, TMP_PAGE_WIDTH, TMP_PAGE_TOP_MARGIN, TMP_PAGE_BOTTOM_MARGIN, TMP_PAGE_LEFT_MARGIN, TMP_PAGE_RIGHT_MARGIN;
string TMP_PAGE_FONT;

// TEXT CONSTANTS
size_t H1_FONT_SIZE, H1_MARGIN, H1_REDLINE, H1_BEFORE, H1_AFTER, H1_ROWSPACE;
string H1_ALIGMENT, H1_REGISTRE, H1_FORMAT, H1_NUMBERING;
size_t H2_FONT_SIZE, H2_MARGIN, H2_REDLINE, H2_BEFORE, H2_AFTER, H2_ROWSPACE;
string H2_ALIGMENT, H2_REGISTRE, H2_FORMAT, H2_NUMBERING;
size_t H3_FONT_SIZE, H3_MARGIN, H3_REDLINE, H3_BEFORE, H3_AFTER, H3_ROWSPACE;
string H3_ALIGMENT, H3_REGISTRE, H3_FORMAT, H3_NUMBERING;
size_t H4_FONT_SIZE, H4_MARGIN, H4_REDLINE, H4_BEFORE, H4_AFTER, H4_ROWSPACE;
string H4_ALIGMENT, H4_REGISTRE, H4_FORMAT, H4_NUMBERING;
size_t H5_FONT_SIZE, H5_MARGIN, H5_REDLINE, H5_BEFORE, H5_AFTER, H5_ROWSPACE;
string H5_ALIGMENT, H5_REGISTRE, H5_FORMAT, H5_NUMBERING;
size_t H6_FONT_SIZE, H6_MARGIN, H6_REDLINE, H6_BEFORE, H6_AFTER, H6_ROWSPACE;
string H6_ALIGMENT, H6_REGISTRE, H6_FORMAT, H6_NUMBERING;
size_t TMP_H1_FONT_SIZE, TMP_H1_MARGIN, TMP_H1_REDLINE, TMP_H1_BEFORE, TMP_H1_AFTER, TMP_H1_ROWSPACE;
string TMP_H1_ALIGMENT, TMP_H1_REGISTRE, TMP_H1_FORMAT, TMP_H1_NUMBERING;
size_t TMP_H2_FONT_SIZE, TMP_H2_MARGIN, TMP_H2_REDLINE, TMP_H2_BEFORE, TMP_H2_AFTER, TMP_H2_ROWSPACE;
string TMP_H2_ALIGMENT, TMP_H2_REGISTRE, TMP_H2_FORMAT, TMP_H2_NUMBERING;
size_t TMP_H3_FONT_SIZE, TMP_H3_MARGIN, TMP_H3_REDLINE, TMP_H3_BEFORE, TMP_H3_AFTER, TMP_H3_ROWSPACE;
string TMP_H3_ALIGMENT, TMP_H3_REGISTRE, TMP_H3_FORMAT, TMP_H3_NUMBERING;
size_t TMP_H4_FONT_SIZE, TMP_H4_MARGIN, TMP_H4_REDLINE, TMP_H4_BEFORE, TMP_H4_AFTER, TMP_H4_ROWSPACE;
string TMP_H4_ALIGMENT, TMP_H4_REGISTRE, TMP_H4_FORMAT, TMP_H4_NUMBERING;
size_t TMP_H5_FONT_SIZE, TMP_H5_MARGIN, TMP_H5_REDLINE, TMP_H5_BEFORE, TMP_H5_AFTER, TMP_H5_ROWSPACE;
string TMP_H5_ALIGMENT, TMP_H5_REGISTRE, TMP_H5_FORMAT, TMP_H5_NUMBERING;
size_t TMP_H6_FONT_SIZE, TMP_H6_MARGIN, TMP_H6_REDLINE, TMP_H6_BEFORE, TMP_H6_AFTER, TMP_H6_ROWSPACE;
string TMP_H6_ALIGMENT, TMP_H6_REGISTRE, TMP_H6_FORMAT, TMP_H6_NUMBERING;
size_t PA_FONT_SIZE, PA_MARGIN, PA_REDLINE, PA_BEFORE, PA_AFTER, PA_ROWSPACE;
string PA_ALIGMENT, PA_REGISTRE, PA_FORMAT, PA_NUMBERING;
size_t P1_FONT_SIZE, P1_MARGIN, P1_REDLINE, P1_BEFORE, P1_AFTER, P1_ROWSPACE;
string P1_ALIGMENT, P1_REGISTRE, P1_FORMAT, P1_NUMBERING;
size_t P2_FONT_SIZE, P2_MARGIN, P2_REDLINE, P2_BEFORE, P2_AFTER, P2_ROWSPACE;
string P2_ALIGMENT, P2_REGISTRE, P2_FORMAT, P2_NUMBERING;
size_t CE_FONT_SIZE, CE_MARGIN, CE_REDLINE, CE_BEFORE, CE_AFTER, CE_ROWSPACE;
string CE_ALIGMENT, CE_REGISTRE, CE_FORMAT, CE_NUMBERING;
size_t TMP_PA_FONT_SIZE, TMP_PA_MARGIN, TMP_PA_REDLINE, TMP_PA_BEFORE, TMP_PA_AFTER, TMP_PA_ROWSPACE;
string TMP_PA_ALIGMENT, TMP_PA_REGISTRE, TMP_PA_FORMAT, TMP_PA_NUMBERING;
size_t TMP_P1_FONT_SIZE, TMP_P1_MARGIN, TMP_P1_REDLINE, TMP_P1_BEFORE, TMP_P1_AFTER, TMP_P1_ROWSPACE;
string TMP_P1_ALIGMENT, TMP_P1_REGISTRE, TMP_P1_FORMAT, TMP_P1_NUMBERING;
size_t TMP_P2_FONT_SIZE, TMP_P2_MARGIN, TMP_P2_REDLINE, TMP_P2_BEFORE, TMP_P2_AFTER, TMP_P2_ROWSPACE;
string TMP_P2_ALIGMENT, TMP_P2_REGISTRE, TMP_P2_FORMAT, TMP_P2_NUMBERING;
size_t TMP_CE_FONT_SIZE, TMP_CE_MARGIN, TMP_CE_REDLINE, TMP_CE_BEFORE, TMP_CE_AFTER, TMP_CE_ROWSPACE;
string TMP_CE_ALIGMENT, TMP_CE_REGISTRE, TMP_CE_FORMAT, TMP_CE_NUMBERING;
size_t IMG_HEIGHT, IMG_WIDTH, IMG_MARGIN, IMG_BEFORE, IMG_AFTER;
string IMG_ALIGMENT;
size_t CNT_MARGIN1, CNT_MARGIN2, CNT_MARGIN3;

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

    for(int i = cast(int)children.length - 1; i >= 0; i--)
    {
      PDF_Object child = children[i];
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
    size_t parent_name, size_t[] font_names, size_t image_obj_name , size_t contents_name, size_t cs_obj_name, size_t gstate_name,
    size_t x_box_pos, size_t y_box_pos,
    size_t left_margin, size_t bottom_margin
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
      // "/ArtBox [ 50 50 " ~ 
      // to!string(x_box_pos - left_margin)  ~ " " ~
      // to!string(y_box_pos - bottom_margin)  ~ " ]\n" ~
      "/Resources \n<< \n/Font <</F1 " ~
      to!string(font_names[0]) ~
      " 0 R " ~
      "/F2 " ~ to!string(font_names[1]) ~ " 0 R " ~
      " >> " ~
      "\n/ExtGState << /G3 " ~
      to!string(gstate_name) ~
      " 0 R >> " ~
      "\n/XObject << /Im1 " ~ 
      to!string(image_obj_name) ~
      " 0 R >> " ~
      "\n/ColorSpace /DeviceRGB " ~
      // to!string(cs_obj_name) ~
      // " 0 R] >>" ~
      "\n/ProcSet [ /PDF /Text /ImageB /ImageC /ImageI ] >>\n" ~
      "/Contents " ~
      to!string(contents_name) ~
      " 0 R\n>>";
  }

  void create_gstate(size_t name, size_t rev_num) {
    this.name = name;
    this.rev_num = rev_num;
    
    value = "<< \n/ca 1 /BM /Normal\n>>";
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

  string build_cid_tbl_row(wchar letter, TTF font) {
    int char_code = cast(int)letter;
    string hex_char_code = dec_to_hexa(char_code);
    string glyph_index = font.find_glyph_index(letter);

    string line = "<" ~ hex_char_code ~ "><" ~ glyph_index ~ ">" ~ "\n"; 

    return line;   
  }

  void create_cid_tbl(size_t name, size_t rev_num, wchar[] unique_letters, string font_path)
  {
    this.name = name;
    this.rev_num = rev_num;
    
    TTF font = new TTF(font_path);

    string cctgi_table = "";

    // для каждый буквы найти corresponding glyph index
    foreach (wchar letter; unique_letters)
    {
      string line = build_cid_tbl_row(letter, font);
      cctgi_table ~= line;
      // string line = build_cid_tbl_row(to!wchar(letter.toUpper), font);
      // writef("\nUNIQUE %s\n", letter);
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
    string font_path,
    // double ascent, double descent, double stemv, double cap_height,
    size_t font_file_name
  )
  {
    this.name = name;
    this.rev_num = rev_num;

    TTF font = new TTF(font_path);

    double xMin = cast(double)font.head.xMin / 2.048;
    double yMin = cast(double)font.head.yMin / 2.048;
    double xMax = cast(double)font.head.xMax / 2.048;
    double yMax = cast(double)font.head.yMax / 2.048;

    value = 
      "<<\n/Type /FontDescriptor\n/FontName /" ~ 
      font_name ~ 
      "\n/Ascent " ~ 
      to!string(font.hhea.ascent) ~ 
      "\n/Descent " ~ 
      to!string(font.hhea.descent) ~
      "\n/StemV 0" ~
      "\n/CapHeight " ~ 
      to!string(font.oss2.sCapHeight) ~
      "\n/Flags 6" ~
      "\n/FontBBox [" ~ to!string(xMin) ~ " " ~
      to!string(yMin) ~ " " ~
      to!string(xMax) ~ " " ~
      to!string(yMax) ~ " " ~
      "]" ~
      "\n/AvgWidth " ~ to!string(font.oss2.xAvgCharWidth) ~
      // "\n/MaxWidth " ~ to!string(ttf.oss2.) ~
      // "\n/XHeight 447" ~
      "\n/ItalicAngle 0" ~
      "\n/FontFile2 " ~
      to!string(font_file_name) ~
      " 0 R\n>>"; 
  }

  void create_base_font_object(size_t name, size_t rev_num, size_t[] font_child_name, size_t cid_tbl_name, string base_font_name)
  {
    this.name = name;
    this.rev_num = rev_num;

    string desc_fonts = "";
    foreach(size_t desc_font; font_child_name) {
      desc_fonts ~= (to!string(desc_font) ~ " ");
    }

    value = 
      "<<\n/Encoding /Identity-H\n/ToUnicode " ~ 
      to!string(cid_tbl_name) ~ 
      " 0 R\n/Subtype /Type0\n/Type /Font\n/DescendantFonts [" ~ 
      desc_fonts ~ 
      "0 R]\n/BaseFont /" ~ base_font_name ~ "\n>>";    
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
      // writef("glyphs width: | glyh %s | index %s | dec index %d | width full %d | width %f |\n", letter, glyph_index, dec_glyph_index, width, rel_width);
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
    m - Begin a new subpath by moving the current point to coordinates (x, y),
    l - Append a straight line segment from the current point to the point (x, y). The new current point is (x, y). 
   */
  static string part_draw_line(size_t x_start, size_t y_start, size_t x_finish, size_t y_finish) 
  {
    string res = 
      to!string(x_start) ~ " " ~ to!string(y_start)  ~ " m\n" ~
      to!string(x_finish) ~ " " ~ to!string(y_finish)  ~ " l\n" ~
      "S\n";

    return res;
  }

  static string part_create_table_stream(size_t left_margin, size_t bottom_margin, size_t cell_height, size_t cell_width, size_t rows, size_t columns)
  {
    string res = 
      "\nq" ~
      "\n1 0 0 1 " ~ to!string(left_margin) ~ " " ~ to!string(bottom_margin) ~ " cm" ~
      "\n0 0 0 RG 0 0 0 rg\n";

    for(int i = 0; i <= rows; i++)
    {
      res ~= part_draw_line( 0, cell_height * i, cell_width * columns, cell_height * i);
    }

    for(int i = 0; i <= columns; i++)
    {
      res ~= part_draw_line( cell_width * i, 0, cell_width * i, cell_height * rows);
    }
    
    res ~= "Q";

    return res;
  }

  /*
    Создать строку с потоком текста которая будет составляюшей потокового объекта
  */
  static string part_create_text_stream(
    size_t left_margin, size_t right_margin, size_t bottom_margin,
    string font_name, size_t font_size, wchar[] input_text, string font_path
  ) {
    TTF font = new TTF(font_path);

    // bottom_margin = HEIGHT - bottom_margin;

    string res = 
      // "\nQ 1 0 0 1 0 0 cm q" ~ 
      // "\n" ~
      // "\nq" ~ 
      // // "\n.75 0 0 .75 0 0 cm" ~ 
      // "\n0 1 0 RG 0 1 1 rg" ~ 
      // "\n/G3 gs" ~
      // // "\n0 0 600 50 re" ~ 
      // // "\nf" ~ 
      // "\nQ" ~ 
      // "\nq" ~ 
      // "\n1 0 0 1 0 0 cm" ~ 
      "\n0 0 0 RG 0 0 0 rg" ~ 
      "\n/G3 gs" ~
      "\nBT \n/" ~ to!string(font_name) ~
      " " ~ to!string(font_size) ~
      " Tf\n" ~
      "\n1 0 0 1 " ~ to!string(left_margin) ~ " " ~ to!string(bottom_margin) ~ " Tm" ~ 
      // to!string(x_pos) ~ " " ~ to!string(y_pos) ~
      // " Td\n" ~
      "[";
 
    foreach (wchar letter; input_text)
    {
      string glyph_index = font.find_glyph_index(letter);
      // int char_code = cast(int)letter;
      // string dec_code = dec_to_hexa(char_code);

      string sym = "<" ~ glyph_index ~ ">";
      res ~= sym;
    }

    res ~= "] TJ\nET";

    return res;
  }

  static string part_create_image_stream(size_t h1_x, size_t h1_y, size_t h2_x, size_t h2_y, size_t w1_x, size_t w1_y, string image_name) {
    string res = 
      "\n/Perceptual ri q\n" ~ 
      to!string(h1_x) ~ " " ~ 
      to!string(h1_y) ~ " " ~ 
      to!string(h2_x) ~ " " ~ 
      to!string(h2_y) ~ " " ~ 
      to!string(w1_x) ~ " " ~ 
      to!string(w1_y) ~ " cm\n" ~ 
      "/" ~ image_name ~ " Do\nQ\n";

    return res;
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
  void create_stream_object(size_t name, size_t rev_num, string[] children, size_t children_heights)
  {
    this.name = name;
    this.rev_num = rev_num; 
    
    writef(" CALC PAGE MARGIN %d\n", children_heights);
    size_t margin = 842 - children_heights;

    string stream_value = 
      "\n1 0 0 1 0 " ~ to!string(margin) ~ " cm" ~
      "\nq" ~
      "\n0 1 0 RG 0 1 1 rg" ~
      "\n/G3 gs" ~
      "\nQ";
    foreach (string child; children)
    {
      stream_value ~= child;
    }
    // stream_value ~= "\nQ";

//     string stream_value = 
//       // "\n/Cs1 cs 0 0 0 sc " ~
//       "\nBT \n/F1 12 Tf \n100 100 Td \n[ <0249><026A><0262><025C><025F><026C><000F><0003><0266><0262><026A><0004>] TJ \nET\n" ~ 
//       "\n/Perceptual ri q\n132 0 0 132 45 140 cm\n/" ~
//       image_name ~
//       " Do\nQ\n" ~
//       "Q
// q
// 72.75 87.296265 224.25 23.148926 re
// W* n
// q
// .75 0 0 .75 77.25 92.546265 cm
// 0 0 0 RG 0 0 0 rg
// BT
// /F4 14.666667 Tf
// 1 0 0 -1 0 .62304592 Tm
// 0 -13.0696621 Td <0014> Tj
// ET
// Q
// Q
// q
// 297.75 87.296265 224.25 23.148926 re
// W* n
// q
// .75 0 0 .75 302.25 92.546265 cm
// 0 0 0 RG 0 0 0 rg
// BT
// /F4 14.666667 Tf
// 1 0 0 -1 0 .62304592 Tm
// 0 -13.0696621 Td <0015> Tj
// ET
// Q
// Q
// q
// .75 0 0 .75 72 86.546265 cm
// 0 0 0 RG 0 0 0 rg
// .66666669 -.72835284 m
// .66666669 32.60498 l
// S
// 300.66666 -.72835284 m
// 300.66666 32.60498 l
// S
// 600.66669 -.72835284 m
// 600.66669 32.60498 l
// S
// 0 -.061686199 m
// 600 -.061686199 l
// S
// 0 31.938314 m
// 600 31.938314 l
// S
// Q";
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

  void create_image_resource_object(size_t name, size_t rev_num, size_t width, size_t height, string image_path, size_t cs_obj_name) {
    this.name = name;
    this.rev_num = rev_num; 

    // to!string(Base64.encode(cast(ubyte[])read(image_path)))
    const ubyte[] stream_value = cast(const(ubyte)[])read(image_path);

    // длина потока в байтах
    ubyte[] byte_stream = cast(ubyte[])stream_value;
    size_t stream_size = byte_stream.length;

    // тип компрессии
    string compression_type;

    value = "<</Type /XObject \n/Subtype /Image \n/Width " ~ to!string(width) ~ 
    "\n/ColorTransform 0" ~
    "\n/Height " ~ to!string(height) ~ 
    "\n/BitsPerComponent 8" ~ 
    "\n/Filter /DCTDecode" ~
    "\n/ColorSpace [/ICCBased " ~ to!string(cs_obj_name) ~ " 0 R]" ~
    "\n/Length " ~ to!string(stream_size) ~ 
    ">>\nstream\n" ~ cast(string)stream_value ~ "\nendstream";    
  }

  void create_colorspace_embedd_object(size_t name, size_t rev_num, string icc_config_path) {
    this.name = name;
    this.rev_num = rev_num; 

    const ubyte[] stream_value = cast(ubyte[])read(icc_config_path);

    // длина потока в байтах
    ubyte[] byte_stream = cast(ubyte[])stream_value;
    size_t stream_size = byte_stream.length;

    // тип компрессии
    string compression_type;

    value = "<<\n/N 3" ~
    "\n/Alternate /DeviceRGB" ~ 
    "\n/Length " ~ to!string(stream_size) ~ 
    ">>\nstream\n" ~ cast(string)stream_value ~ "\nendstream";        
  }

  void create_colorspace_object(size_t name, size_t rev_num, size_t cs_embedd_name) {
    this.name = name;
    this.rev_num = rev_num;

    value = "/ColorSpace\n<<\n /Cs1 [/ICCBased " ~ to!string(cs_embedd_name) ~ " 0 R]\n>>";
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

class Page_Container 
{
  PDF_Object[] temp_objs;
  PDF_Object stream_obj;
  PDF_Object gstate_obj;
  PDF_Object cs_embed_obj;
  PDF_Object font_embed_obj;
  PDF_Object bfont_embed_obj;
  PDF_Object font_desc_obj;
  PDF_Object bfont_desc_obj;
  PDF_Object cid_tbl_obj;
  PDF_Object bcid_tbl_obj;
  PDF_Object image_obj;
  PDF_Object resources_obj;
  PDF_Object bold_font_obj;
  PDF_Object parent_font_obj;
  PDF_Object bparent_font_obj;
  PDF_Object page_obj;
}

class PDF_Body
{
  PDF_Object[] objects; 
  string normal_font_path;
  string bold_font_path;
  TTF normal_font;
  TTF bold_font;

  void create_header_obj(
    Yrd_tree parse_tree, size_t i,
    ref wchar[] unique_letters, ref string[] children, ref int children_widths, ref size_t prev_bottom_margin,
    ref size_t counter, string tag_value,
    string REGISTRE, string NUMBERING, size_t FONT_SIZE, string FORMAT, size_t AFTER, size_t MARGIN, string ALIGMENT,
    ref bool with_image
  ) 
  {
    if(i != 0) {
      string next_tag = parse_tree.get_tag_leaf(i - 1, 0).value;
      if((next_tag == "\\изо" || next_tag == "\\тизо") && IMG_ALIGMENT == "втексте") with_image = true;
    }

    size_t line_width = 0;
    wstring wtag_value = (REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
    // wtag_value = (NUMBERING == "да") ? (to!wstring(counter--) ~ " " ~ wtag_value) : wtag_value;
    // h1_count++;

    foreach (wchar letter; wtag_value)
    {
      int width = (FORMAT == "жирный") ? bold_font.find_glyph_width(letter) : normal_font.find_glyph_width(letter);
      line_width += width;
    }

    size_t devider = normal_font.head.unitsPerEm / FONT_SIZE;
    string ch_text = PDF_Object.part_create_text_stream(
      (ALIGMENT == "центр") ? ((PAGE_WIDTH + MARGIN) - (line_width / devider ))/ 2 : PAGE_LEFT_MARGIN + MARGIN, 
      0, 
      (with_image) ? prev_bottom_margin + IMG_HEIGHT : prev_bottom_margin + AFTER + add_margin_before(parse_tree, i), 
      (FORMAT == "жирный") ? "F2" : "F1", 
      FONT_SIZE, 
      cast(wchar[])wtag_value,
      (FORMAT == "жирный") ? bold_font_path : normal_font_path
    );
    children ~= ch_text;
    children_widths += (with_image) ? IMG_HEIGHT : (AFTER + add_margin_before(parse_tree, i));
    prev_bottom_margin += (with_image) ? IMG_HEIGHT : (AFTER + add_margin_before(parse_tree, i));
    // writef(" NEXT | %s | MARGIN %d %d %s\n", next_tag, IMG_HEIGHT, (AFTER + add_margin_before(parse_tree, i) + 40), with_image);

    // уникальные буквы
    foreach (wchar letter; wtag_value)
    {
      if(!unique_letters.canFind(letter)) unique_letters ~= letter;
    }

    if(with_image) with_image = false;
  }

  size_t add_margin_before(Yrd_tree parse_tree, size_t i)
  {
    // writef(" marggirn before for %d \n", i);
    if(i >= (parse_tree.content_size() - 1)) {
      return 0;
    }
    string tag_name = parse_tree.get_tag_leaf(i + 1, 0).value;
    if(tag_name == "\\з1") {
      return H1_BEFORE;
    }
    else if(tag_name == "\\з2") {
      return H2_BEFORE;
    }
    else if(tag_name == "\\а") {
      return PA_BEFORE;
    }
    else if(tag_name == "\\а") {
      return PA_BEFORE + 10;
    }
    else if(tag_name == "\\а1") {
      return P1_BEFORE;
    }  
    else if(tag_name == "\\а2") {
      return P1_BEFORE;
    }  
    else if(tag_name == "\\з3") {
      return H3_BEFORE;
    }
    else if(tag_name == "\\з4") {
      return H4_BEFORE;
    }
    else if(tag_name == "\\з5") {
      return H5_BEFORE;
    }
    else if(tag_name == "\\з6") {
      return H6_BEFORE;
    }
    else if(tag_name == "\\тз1") {
      return TMP_H1_BEFORE;
    }
    else if(tag_name == "\\тз2") {
      return TMP_H2_BEFORE;
    }
    else if(tag_name == "\\та") {
      return TMP_PA_BEFORE;
    }
    else if(tag_name == "\\та1") {
      return TMP_P1_BEFORE;
    }  
    else if(tag_name == "\\та2") {
      return TMP_P1_BEFORE;
    }  
    else if(tag_name == "\\тз3") {
      return TMP_H3_BEFORE;
    }
    else if(tag_name == "\\тз4") {
      return TMP_H4_BEFORE;
    }
    else if(tag_name == "\\тз5") {
      return TMP_H5_BEFORE;
    }
    else if(tag_name == "\\тз6") {
      return TMP_H6_BEFORE;
    }    
    return 0;
  }

  size_t add_margin_after(Yrd_tree parse_tree, size_t i)
  {
    // writef(" marggirn before for %d \n", i);
    if(i >= (parse_tree.content_size() + 1)) {
      return 0;
    }
    string tag_name = parse_tree.get_tag_leaf(i + 1, 0).value;
    if(tag_name == "\\з1") {
      return H1_AFTER;
    }
    else if(tag_name == "\\з2") {
      return H2_AFTER;
    }
    else if(tag_name == "\\а") {
      return PA_AFTER;
    }
    else if(tag_name == "\\а") {
      return PA_AFTER + 10;
    }
    else if(tag_name == "\\а1") {
      return P1_AFTER;
    }  
    else if(tag_name == "\\а2") {
      return P1_AFTER;
    }  
    else if(tag_name == "\\з3") {
      return H3_AFTER;
    }
    else if(tag_name == "\\з4") {
      return H4_AFTER;
    }
    else if(tag_name == "\\з5") {
      return H5_AFTER;
    }
    else if(tag_name == "\\з6") {
      return H6_AFTER;
    }
    else if(tag_name == "\\тз1") {
      return TMP_H1_AFTER;
    }
    else if(tag_name == "\\тз2") {
      return TMP_H2_AFTER;
    }
    else if(tag_name == "\\та") {
      return TMP_PA_AFTER;
    }
    else if(tag_name == "\\та1") {
      return TMP_P1_AFTER;
    }  
    else if(tag_name == "\\та2") {
      return TMP_P1_AFTER;
    }  
    else if(tag_name == "\\тз3") {
      return TMP_H3_AFTER;
    }
    else if(tag_name == "\\тз4") {
      return TMP_H4_AFTER;
    }
    else if(tag_name == "\\тз5") {
      return TMP_H5_AFTER;
    }
    else if(tag_name == "\\тз6") {
      return TMP_H6_AFTER;
    }    
    return 0;
  }

  void create_objects(Yrd_tree parse_tree)
  {
    normal_font_path = Searcher.find_font_path(PAGE_FONT);
    bold_font_path = Searcher.find_font_path(PAGE_FONT ~ " Bold");
    // writef("| %s | %s | FIND FONTS %s %s\n", PAGE_FONT, PAGE_FONT ~ " Bold", normal_font_path, bold_font_path);
    normal_font = new TTF(normal_font_path);
    bold_font = new TTF(bold_font_path);

    size_t id = 1;
    size_t pages_count = 1;
    
    // массив уникальных символов для CMAP таблицы
    wchar[] unique_letters;

    // добавляем каталон
    PDF_Object catalog_obj = new PDF_Object();
    catalog_obj.create_catalog();
    objects ~= catalog_obj;
    ++id;

    // @TODO FIND HOW MANY PAGES
    id = 4; // пропускаем 2 и 3 это будут: объявление страницы и дерева страниц

    // изначальное значение переменной - отступ от начала страницы
    int children_widths = 50;

    size_t prev_top_margin = 0, prev_bottom_margin = 0, prev_left_margin = 0;

    int[] cell_widths;

    size_t h1_count = parse_tree.h1_count, h2_count = parse_tree.h2_count, h3_count = parse_tree.h3_count, list_count = 1;
    size_t tbl_curr_row = 0, tbl_curr_col = 0, tbl_curr_cell = 0, tbl_rows = 0, tbl_cols = 0;
    size_t tbl_height = 0;

    bool with_image = false;
    bool from_new_page = false;
    Page_Container[] pages;

    size_t curr_page_index = cast(int)parse_tree.content_size() - 1;
    size_t page_id = 3;
    // writef("\n\n\tPAGES %d\n\n", parse_tree.pg_count);
    // добавляем объекты
    for(size_t f = 0; f < parse_tree.pg_count; f++) {
      PDF_Object[] temp_objs;
      string[] children;

      if(f > 0) {
        // writef(" new page reading %d => %s\n", curr_page_index, parse_tree.get_tag_leaf(curr_page_index - 1, 1).value);
      }
      for(int i = cast(int)curr_page_index; i >= 0; i--)
      {
        // writef("tag: %s %s\n", parse_tree.get_tag_leaf(i, 0), parse_tree.get_tag_leaf(i, 1));
        string tag_name = parse_tree.get_tag_leaf(i, 0).value;
        string tag_value =  parse_tree.get_tag_leaf(i, 1).value;
        wstring wtag_value;
        size_t line_width = 0;

        if(from_new_page) {
          children_widths = 50;
          prev_bottom_margin = 0;
          from_new_page = false;
        }

        if(tag_name == "\\сод") {
          size_t devider = normal_font.head.unitsPerEm / PA_FONT_SIZE;
          for(int h = cast(int)parse_tree.headers.length - 1; h >= 0; h--)
          {
            Header header = parse_tree.headers[h];
            line_width = 0;
            switch(header.level) {
              case 1: {
                wtag_value = to!wstring(header.value);
                // wtag_value = (H3_NUMBERING == "да") ? (to!wstring(h3_count--) ~ " " ~ wtag_value) : wtag_value;
                // H3_count++;

                TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
                foreach (wchar letter; wtag_value)
                {
                  int width = font.find_glyph_width(letter);
                  line_width += width;
                }
                
                wstring page_num = to!wstring(header.page);
                foreach (wchar num; page_num)
                {
                  int width = font.find_glyph_width(num);
                  line_width += width;
                }

                while(((line_width / devider) + PAGE_LEFT_MARGIN + CNT_MARGIN1) < (PAGE_WIDTH - PAGE_RIGHT_MARGIN - 10)) {
                  wtag_value ~= ".";
                  int width = font.find_glyph_width('.');
                  line_width += width;
                }
                wtag_value ~= page_num;

                // size_t devider = font.head.unitsPerEm / H3_FONT_SIZE;
                // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
                string ch_text = PDF_Object.part_create_text_stream(
                  // WHY 320 ??
                  PAGE_LEFT_MARGIN + CNT_MARGIN1, 
                  0, 
                  prev_bottom_margin + 20, 
                  "F1", 
                  12, 
                  cast(wchar[])wtag_value,
                  Searcher.find_font_path(PAGE_FONT)
                  // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
                );
                children ~= ch_text;
                children_widths += (20);
                prev_bottom_margin += (20);

                // уникальн ые буквы
                foreach (wchar letter; wtag_value)
                {
                  if(!unique_letters.canFind(letter)) unique_letters ~= letter;
                  // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
                }    
              } break;
              case 2: {
                wtag_value = to!wstring(header.value);
                // wtag_value = (H3_NUMBERING == "да") ? (to!wstring(h3_count--) ~ " " ~ wtag_value) : wtag_value;
                // H3_count++;

                TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
                foreach (wchar letter; wtag_value)
                {
                  int width = font.find_glyph_width(letter);
                  line_width += width;
                }
                
                wstring page_num = to!wstring(header.page);
                foreach (wchar num; page_num)
                {
                  int width = font.find_glyph_width(num);
                  line_width += width;
                }

                while(((line_width / devider) + PAGE_LEFT_MARGIN + CNT_MARGIN2) < (PAGE_WIDTH - PAGE_RIGHT_MARGIN - 10)) {
                  wtag_value ~= ".";
                  int width = font.find_glyph_width('.');
                  line_width += width;
                }
                wtag_value ~= page_num;

                // size_t devider = font.head.unitsPerEm / H3_FONT_SIZE;
                // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
                string ch_text = PDF_Object.part_create_text_stream(
                  // WHY 320 ??
                  PAGE_LEFT_MARGIN + CNT_MARGIN2, 
                  0, 
                  prev_bottom_margin + 20, 
                  "F1", 
                  12, 
                  cast(wchar[])wtag_value,
                  Searcher.find_font_path(PAGE_FONT)
                  // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
                );
                children ~= ch_text;
                children_widths += (20);
                prev_bottom_margin += (20);

                // уникальн ые буквы
                foreach (wchar letter; wtag_value)
                {
                  if(!unique_letters.canFind(letter)) unique_letters ~= letter;
                  // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
                }
              } break;
              case 3: {

              } break;
              default: break;
            }
          }
        }
        else if(tag_name == "\\стр") {
          curr_page_index = cast(size_t)(i-=1);
          from_new_page = true;
          break;
        }
        else if(tag_name == "\\з1")
        {
          writef(" BEFORE | %d | %d | with %d + %d \n", children_widths, prev_bottom_margin, H1_AFTER, add_margin_before(parse_tree, i));

          create_header_obj(
            parse_tree, i,
            unique_letters, children, children_widths, prev_bottom_margin, 
            h1_count, tag_value, 
            H1_REGISTRE, H1_NUMBERING, H1_FONT_SIZE, H1_FORMAT, H1_AFTER, H1_MARGIN, H1_ALIGMENT,
            with_image
          );
          // wtag_value = (H1_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (H1_NUMBERING == "да") ? (to!wstring(h1_count--) ~ " " ~ wtag_value) : wtag_value;
          // // h1_count++;

          // TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          // foreach (wchar letter; wtag_value)
          // {
          //   string glyph_index = font.find_glyph_index(letter);
          //   int dec_glyph_index = to!int(glyph_index, 16);
          //   int width = font.find_glyph_width(letter);
          //   line_width += width;
          // }

          // size_t devider = font.head.unitsPerEm / H1_FONT_SIZE;
          // // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          // string ch_text = PDF_Object.part_create_text_stream(
          //   // WHY 320 ??
          //   (PAGE_WIDTH - (line_width / devider ))/ 2, 
          //   0, 
          //   // prev_bottom_margin + IMG_HEIGHT,
          //   prev_bottom_margin + H1_AFTER + add_margin_before(parse_tree, i) + 40, 
          //   (H1_FORMAT == "жирный") ? "F2" : "F1", 
          //   H1_FONT_SIZE, 
          //   cast(wchar[])wtag_value,
          //   Searcher.find_font_path(PAGE_FONT ~ " Bold")
          //   // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          // );
          // children ~= ch_text;
          // writef(" HEADER 1 %d | %d|\n", prev_bottom_margin + H1_AFTER + add_margin_before(parse_tree, i) + 40, prev_bottom_margin);
          // // PLUS IMAGE
          // children_widths += (H1_AFTER + add_margin_before(parse_tree, i) + 40);
          // prev_bottom_margin += (H1_AFTER + add_margin_before(parse_tree, i) + 40);

          // // уникальн ые буквы
          // foreach (wchar letter; wtag_value)
          // {
          //   if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          //   // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          // }
        }
        else if(tag_name == "\\тз1")
        {
          wtag_value = (TMP_H1_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (TMP_H1_NUMBERING == "да") ? (to!wstring(TMP_H1_count--) ~ " " ~ wtag_value) : wtag_value;
          // TMP_H1_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / TMP_H1_FONT_SIZE;
          // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            (PAGE_WIDTH - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + TMP_H1_AFTER + add_margin_before(parse_tree, i), 
            (TMP_H1_FORMAT == "жирный") ? "F2" : "F1", 
            TMP_H1_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (TMP_H1_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (TMP_H1_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }
        }
        else if(tag_name == "\\табл")
        {
          if(tag_value == "начало") {
            string ch_tbl = PDF_Object.part_create_table_stream(
              PAGE_LEFT_MARGIN + PA_MARGIN, 
              prev_bottom_margin - ((CE_AFTER * tbl_rows * 2) - 8) + add_margin_before(parse_tree, i), 
              CE_AFTER + 12, 
              ((PAGE_WIDTH - PAGE_RIGHT_MARGIN - PAGE_LEFT_MARGIN) / tbl_cols), 
              tbl_rows, 
              tbl_cols
            );
            children ~= ch_tbl;

            tbl_cols = 0;
            tbl_rows = 0;
            tbl_curr_col = 0;
            tbl_curr_row = 0;
            tbl_curr_cell = 0;
          }
          else {
            string[] rxc = tag_value.split!isWhite;
            // writef(" split %s", rxc);
            tbl_rows = to!size_t(rxc[0]);
            tbl_cols = to!size_t(rxc[1]);

            // writef(" TABLE SPECS -> %d by %d", tbl_rows, tbl_cols);
          }
          // bottom_margin + (cell_height * rows)           TAGLE HEIGHT + 20 
          //                                                       |
          // string ch_tbl = PDF_Object.part_create_table_stream(
          //   50, 
          //   50 + add_margin_before(parse_tree, i), 
          //   10, 
          //   150, 
          //   3, 
          //   3
          // );
          // children ~= ch_tbl;
          // children_widths += 50; 
          // prev_bottom_margin += 50;
        }
        else if(tag_name == "\\яч" && tag_value == "начало")
        {
        
        }
        else if(tag_name == "\\эл") 
        {
          wtag_value = to!wstring(tag_value);

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);
          string ch_text = PDF_Object.part_create_text_stream(
            5 + PAGE_LEFT_MARGIN + PA_MARGIN + (((PAGE_WIDTH - PAGE_RIGHT_MARGIN - PAGE_LEFT_MARGIN) / tbl_cols) * (tbl_cols - tbl_curr_col - 1)), 
            0, 
            (tbl_curr_row == 0) ? prev_bottom_margin + ( CE_AFTER * (tbl_curr_row + 1)) - 10 + 20 : prev_bottom_margin + ( CE_AFTER * (tbl_curr_row + 1)) - 10, 
            "F1", 
            CE_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT)
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;

          // prev_bottom_margin += (20 * tbl_curr_row);
          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          } 

          if(((tbl_curr_cell + 1) % tbl_cols) == 0) {
            if(tbl_curr_row == 0) {
              children_widths += ((CE_AFTER * (tbl_curr_row + 1)) + 20);
              prev_bottom_margin += ((CE_AFTER * (tbl_curr_row + 1)) + 20);
            }
            else {
              children_widths += ((CE_AFTER * (tbl_curr_row + 1)));
              prev_bottom_margin += ((CE_AFTER * (tbl_curr_row + 1)));
            }
            // tbl_height += (20 * tbl_curr_row);
            tbl_curr_row++;
          } 
          if(((tbl_curr_cell + 1) % tbl_cols) != 0) {
            tbl_curr_col++;
          }
          else if(((tbl_curr_cell + 1) % tbl_cols) == 0) {
            tbl_curr_col = 0;
          }
          if(tbl_curr_row > tbl_rows) {
            // ссылка на табл конец
          }
          tbl_curr_cell++; 

          // writef(" curr cell | %d | curr row | %d | curr col | %d |  PREV | %d |\n", tbl_curr_cell, tbl_curr_row, tbl_curr_col, prev_bottom_margin);     
        }
        else if(tag_name == "\\изо" || tag_name == "\\тизо")
        {
          // if()
          string ch_img = PDF_Object.part_create_image_stream(
            IMG_HEIGHT, 
            0, 
            0, 
            IMG_HEIGHT, 
            PAGE_LEFT_MARGIN, 
            prev_bottom_margin - IMG_HEIGHT + add_margin_after(parse_tree, i), 
            "Im1"
          );
          children ~= ch_img;
          writef(" | %s | IMAGE %d | %d |\n", IMG_ALIGMENT,add_margin_after(parse_tree, i) + 40, prev_bottom_margin);
          // children_widths += (90 + add_margin_before(parse_tree, i));
          // prev_bottom_margin += (90 + add_margin_before(parse_tree, i));
        }
        else if(tag_name == "\\з2")
        {
          create_header_obj(
            parse_tree, i,
            unique_letters, children, children_widths, prev_bottom_margin, 
            h2_count, tag_value, 
            H2_REGISTRE, H2_NUMBERING, H2_FONT_SIZE, H2_FORMAT, H2_AFTER, H2_MARGIN, H2_ALIGMENT,
            with_image
          );
          // writef("was %d and we do + %d\n", prev_bottom_margin, H2_AFTER);
          // wtag_value = to!wstring(tag_value);
          // wtag_value = (to!wstring(h1_count) ~ "." ~ to!wstring(h2_count--) ~ " " ~ wtag_value);
          // // h2_count++;

          // TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          // foreach (wchar letter; wtag_value)
          // {
          //   string glyph_index = font.find_glyph_index(letter);
          //   int dec_glyph_index = to!int(glyph_index, 16);
          //   int width = font.find_glyph_width(letter);
          //   line_width += width;
          // }

          // // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);
          // string ch_text = PDF_Object.part_create_text_stream(
          //   PAGE_LEFT_MARGIN + H2_MARGIN, 
          //   0, 
          //   prev_bottom_margin + H2_AFTER + add_margin_before(parse_tree, i), 
          //   "F1", 
          //   12, 
          //   cast(wchar[])wtag_value,
          //   Searcher.find_font_path(PAGE_FONT)
          //   // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          // );
          // children ~= ch_text;
          // children_widths += (H2_AFTER + add_margin_before(parse_tree, i));
          // prev_bottom_margin += (H2_AFTER + add_margin_before(parse_tree, i));
          // // writef("now %d\n", prev_bottom_margin);
          // // уникальн ые буквы
          // foreach (wchar letter; wtag_value)
          // {
          //   if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          //   // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          // }
        }
        else if(tag_name == "\\тз2")
        {
          // writef("was %d and we do + %d\n", prev_bottom_margin, TMP_H2_AFTER);
          wtag_value = to!wstring(tag_value);
          // wtag_value = (to!wstring(h1_count) ~ "." ~ to!wstring(TMP_H2_count--) ~ " " ~ wtag_value);
          // TMP_H2_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);
          string ch_text = PDF_Object.part_create_text_stream(
            PAGE_LEFT_MARGIN + TMP_H2_MARGIN, 
            0, 
            prev_bottom_margin + TMP_H2_AFTER + add_margin_before(parse_tree, i), 
            "F1", 
            12, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT)
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (TMP_H2_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (TMP_H2_AFTER + add_margin_before(parse_tree, i));
          // writef("now %d\n", prev_bottom_margin);
          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }
        }
        else if(tag_name == "\\а")
        {
          // writef(" paragraph %s\n", tag_value);
          wtag_value = to!wstring(tag_value);
          wstring curr_line = "";
          size_t curr_width = 0;

          wstring[] sublines;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          size_t devider = font.head.unitsPerEm / PA_FONT_SIZE;

          for(size_t l = 0; l < wtag_value.length; l++)
          {
            wchar letter = wtag_value[l];

            int width = font.find_glyph_width(letter);
            // writef("    width for %s is %d\n", letter, width);
            // writef(" width for %s is %d\n", letter, width);
            line_width += width;
            // writef(" | %d | %d |\n", ((line_width / devider) + PAGE_LEFT_MARGIN + PA_MARGIN + PA_REDLINE), (PAGE_WIDTH - PAGE_RIGHT_MARGIN));
            if(sublines.length == 0) {
              if(((line_width / devider) + PAGE_LEFT_MARGIN + PA_MARGIN + PA_REDLINE) <= (PAGE_WIDTH - PAGE_RIGHT_MARGIN)) {
                curr_line ~= letter;
                curr_width = (line_width + PAGE_LEFT_MARGIN + PA_MARGIN + PA_REDLINE);              
              }
              else {
                // writef(" new line with letter (%s)\n", letter);
                if(!isWhite(letter)) l--;
                sublines ~= curr_line;
                curr_line = "";
                curr_width = 0;
                line_width = 0;
              }
            }
            else {
              if(((line_width / devider) + PAGE_LEFT_MARGIN + PA_MARGIN) <= (PAGE_WIDTH - PAGE_RIGHT_MARGIN)) {
                curr_line ~= letter;
                curr_width = (line_width + PAGE_LEFT_MARGIN + PA_MARGIN );
              }
              else {
                // writef(" new line with letter (%s)\n", letter);
                if(!isWhite(letter)) l--;
                sublines ~= curr_line;
                curr_line = "";
                curr_width = 0;
                line_width = 0;
              }
            }
          }  
          
          // добавить остальные саблинии
          // writef(" sublines count %d for %s\n", sublines.length, tag_value);
          if(sublines.length > 1) {
            for(size_t j = sublines.length - 1; j >= 1; j--)
            {
              string ch_line = PDF_Object.part_create_text_stream(
                PAGE_LEFT_MARGIN + PA_MARGIN, 
                0, 
                (sublines.length - 1 != j) ? prev_bottom_margin + PA_ROWSPACE : (prev_bottom_margin + PA_AFTER + add_margin_before(parse_tree, i)), 
                "F1", 
                PA_FONT_SIZE, 
                cast(wchar[])sublines[j],
                Searcher.find_font_path(PAGE_FONT)
              );
              children ~= ch_line;
              (sublines.length - 1 != j) ? (children_widths += PA_ROWSPACE) : (children_widths += (PA_AFTER + add_margin_before(parse_tree, i)));
              (sublines.length - 1 != j) ? (prev_bottom_margin += PA_ROWSPACE) : (prev_bottom_margin += (PA_AFTER + add_margin_before(parse_tree, i)));
            }
          } else {
            sublines ~= curr_line;
          }

          // добавить первую линию
          string ch_text = PDF_Object.part_create_text_stream(
            PAGE_LEFT_MARGIN + PA_MARGIN + PA_REDLINE, 
            0, 
            (sublines.length > 1) ? prev_bottom_margin + PA_ROWSPACE : prev_bottom_margin + PA_AFTER + add_margin_before(parse_tree, i), 
            "F1", 
            PA_FONT_SIZE, 
            cast(wchar[])sublines[0],
            Searcher.find_font_path(PAGE_FONT)
          );
          children ~= ch_text;
          (sublines.length > 1) ? (children_widths += PA_ROWSPACE) : (children_widths += (PA_AFTER + add_margin_before(parse_tree, i)));
          (sublines.length > 1) ? (prev_bottom_margin += PA_ROWSPACE) : (prev_bottom_margin += (PA_AFTER + add_margin_before(parse_tree, i)));
          // writef(" AFTER %s -> %d\n", sublines[0], add_margin_before(parse_tree, i));
          // writef(" SUbstring count %d\n", sublines.length);

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          }
        }
        else if(tag_name == "\\та")
        {
          // writef(" paragraph %s\n", tag_value);
          wtag_value = to!wstring(tag_value);
          wstring curr_line = "";
          size_t curr_width = 0;

          wstring[] sublines;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          size_t devider = font.head.unitsPerEm / TMP_PA_FONT_SIZE;

          foreach (wchar letter; wtag_value)
          {
            int width = font.find_glyph_width(letter);
            // writef("    width for %s is %d\n", letter, width);
            // writef(" width for %s is %d\n", letter, width);
            line_width += width;
            if(((line_width / devider) + PAGE_LEFT_MARGIN + TMP_PA_MARGIN) <= (PAGE_WIDTH - PAGE_RIGHT_MARGIN)) {
              curr_line ~= letter;
              curr_width = (line_width + PAGE_LEFT_MARGIN + TMP_PA_MARGIN );
            }
            else {
              sublines ~= curr_line;
              curr_line = "";
              curr_width = 0;
              line_width = 0;
            }
          }  
          
          // добавить остальные саблинии
          // writef(" sublines count %d for %s\n", sublines.length, tag_value);
          if(sublines.length > 1) {
            for(size_t j = sublines.length - 1; j >= 1; j--)
            {
              string ch_line = PDF_Object.part_create_text_stream(
                PAGE_LEFT_MARGIN + TMP_PA_MARGIN, 
                0, 
                (sublines.length - 1 != j) ? prev_bottom_margin + TMP_PA_ROWSPACE : (prev_bottom_margin + TMP_PA_AFTER + add_margin_before(parse_tree, i)), 
                "F1", 
                TMP_PA_FONT_SIZE, 
                cast(wchar[])sublines[j],
                Searcher.find_font_path(PAGE_FONT)
              );
              children ~= ch_line;
              (sublines.length - 1 != j) ? (children_widths += TMP_PA_ROWSPACE) : (children_widths += (TMP_PA_AFTER + add_margin_before(parse_tree, i)));
              (sublines.length - 1 != j) ? (prev_bottom_margin += TMP_PA_ROWSPACE) : (prev_bottom_margin += (TMP_PA_AFTER + add_margin_before(parse_tree, i)));
            }
          } else {
            sublines ~= curr_line;
          }
          // writef("\n\n\tMARGIN BEFORE => %d\n\n", add_margin_before(parse_tree, i));

          // добавить первую линию
          string ch_text = PDF_Object.part_create_text_stream(
            PAGE_LEFT_MARGIN + TMP_PA_MARGIN + TMP_PA_REDLINE, 
            0, 
            (sublines.length > 1) ? prev_bottom_margin + TMP_PA_ROWSPACE : prev_bottom_margin + TMP_PA_AFTER + add_margin_before(parse_tree, i), 
            "F1", 
            TMP_PA_FONT_SIZE, 
            cast(wchar[])sublines[0],
            Searcher.find_font_path(PAGE_FONT)
          );
          children ~= ch_text;
          (sublines.length > 1) ? (children_widths += TMP_PA_ROWSPACE) : (children_widths += (TMP_PA_AFTER + add_margin_before(parse_tree, i)));
          (sublines.length > 1) ? (prev_bottom_margin += TMP_PA_ROWSPACE) : (prev_bottom_margin += (TMP_PA_AFTER + add_margin_before(parse_tree, i)));
          // writef(" AFTER %s -> %d\n", sublines[0], add_margin_before(parse_tree, i));
          // writef(" SUbstring count %d\n", sublines.length);

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          }
        }
        else if(tag_name == "\\а1")
        {
          // writef(" paragraph %s\n", tag_value);
          wtag_value = to!wstring(tag_value);
          wstring curr_line = "";
          size_t curr_width = 0;

          wstring[] sublines;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          size_t devider = font.head.unitsPerEm / P1_FONT_SIZE;

          foreach (wchar letter; wtag_value)
          {
            int width = font.find_glyph_width(letter);
            // writef("    width for %s is %d\n", letter, width);
            // writef(" width for %s is %d\n", letter, width);
            line_width += width;
            if(((line_width / devider) + PAGE_LEFT_MARGIN + P1_MARGIN) <= (PAGE_WIDTH - PAGE_RIGHT_MARGIN)) {
              curr_line ~= letter;
              curr_width = (line_width + PAGE_LEFT_MARGIN + P1_MARGIN );
            }
            else {
              sublines ~= curr_line;
              curr_line = "";
              curr_width = 0;
              line_width = 0;
            }
          }  
          
          // добавить остальные саблинии
          // writef(" sublines count %d for %s\n", sublines.length, tag_value);
          if(sublines.length > 1) {
            for(size_t j = sublines.length - 1; j >= 1; j--)
            {
              string ch_line = PDF_Object.part_create_text_stream(
                PAGE_LEFT_MARGIN + P1_MARGIN, 
                0, 
                (sublines.length - 1 != j) ? prev_bottom_margin + P1_ROWSPACE : (prev_bottom_margin + P1_AFTER + add_margin_before(parse_tree, i)), 
                "F1", 
                P1_FONT_SIZE, 
                cast(wchar[])sublines[j],
                Searcher.find_font_path(PAGE_FONT)
              );
              children ~= ch_line;
              (sublines.length - 1 != j) ? (children_widths += P1_ROWSPACE) : (children_widths += (P1_AFTER + add_margin_before(parse_tree, i)));
              (sublines.length - 1 != j) ? (prev_bottom_margin += P1_ROWSPACE) : (prev_bottom_margin += (P1_AFTER + add_margin_before(parse_tree, i)));
            }
          } else {
            sublines ~= curr_line;
          }

          // добавить первую линию
          string ch_text = PDF_Object.part_create_text_stream(
            PAGE_LEFT_MARGIN + P1_MARGIN + P1_REDLINE, 
            0, 
            (sublines.length > 1) ? prev_bottom_margin + P1_ROWSPACE : prev_bottom_margin + P1_AFTER + add_margin_before(parse_tree, i), 
            "F1", 
            P1_FONT_SIZE, 
            cast(wchar[])sublines[0],
            Searcher.find_font_path(PAGE_FONT)
          );
          children ~= ch_text;
          (sublines.length > 1) ? (children_widths += P1_ROWSPACE) : (children_widths += (P1_AFTER + add_margin_before(parse_tree, i)));
          (sublines.length > 1) ? (prev_bottom_margin += P1_ROWSPACE) : (prev_bottom_margin += (P1_AFTER + add_margin_before(parse_tree, i)));
          // writef(" AFTER %s -> %d\n", sublines[0], add_margin_before(parse_tree, i));
          // writef(" SUbstring count %d\n", sublines.length);

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          }
        }
        else if(tag_name == "\\та1")
        {
          // writef(" paragraph %s\n", tag_value);
          wtag_value = to!wstring(tag_value);
          wstring curr_line = "";
          size_t curr_width = 0;

          wstring[] sublines;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          size_t devider = font.head.unitsPerEm / TMP_P1_FONT_SIZE;

          foreach (wchar letter; wtag_value)
          {
            int width = font.find_glyph_width(letter);
            // writef("    width for %s is %d\n", letter, width);
            // writef(" width for %s is %d\n", letter, width);
            line_width += width;
            if(((line_width / devider) + PAGE_LEFT_MARGIN + TMP_P1_MARGIN) <= (PAGE_WIDTH - PAGE_RIGHT_MARGIN)) {
              curr_line ~= letter;
              curr_width = (line_width + PAGE_LEFT_MARGIN + TMP_P1_MARGIN );
            }
            else {
              sublines ~= curr_line;
              curr_line = "";
              curr_width = 0;
              line_width = 0;
            }
          }  
          
          // добавить остальные саблинии
          // writef(" sublines count %d for %s\n", sublines.length, tag_value);
          if(sublines.length > 1) {
            for(size_t j = sublines.length - 1; j >= 1; j--)
            {
              string ch_line = PDF_Object.part_create_text_stream(
                PAGE_LEFT_MARGIN + TMP_P1_MARGIN, 
                0, 
                (sublines.length - 1 != j) ? prev_bottom_margin + TMP_P1_ROWSPACE : (prev_bottom_margin + TMP_P1_AFTER + add_margin_before(parse_tree, i)), 
                "F1", 
                TMP_P1_FONT_SIZE, 
                cast(wchar[])sublines[j],
                Searcher.find_font_path(PAGE_FONT)
              );
              children ~= ch_line;
              (sublines.length - 1 != j) ? (children_widths += TMP_P1_ROWSPACE) : (children_widths += (TMP_P1_AFTER + add_margin_before(parse_tree, i)));
              (sublines.length - 1 != j) ? (prev_bottom_margin += TMP_P1_ROWSPACE) : (prev_bottom_margin += (TMP_P1_AFTER + add_margin_before(parse_tree, i)));
            }
          } else {
            sublines ~= curr_line;
          }

          // добавить первую линию
          string ch_text = PDF_Object.part_create_text_stream(
            PAGE_LEFT_MARGIN + TMP_P1_MARGIN + TMP_P1_REDLINE, 
            0, 
            (sublines.length > 1) ? prev_bottom_margin + TMP_P1_ROWSPACE : prev_bottom_margin + TMP_P1_AFTER + add_margin_before(parse_tree, i), 
            "F1", 
            TMP_P1_FONT_SIZE, 
            cast(wchar[])sublines[0],
            Searcher.find_font_path(PAGE_FONT)
          );
          children ~= ch_text;
          (sublines.length > 1) ? (children_widths += TMP_P1_ROWSPACE) : (children_widths += (TMP_P1_AFTER + add_margin_before(parse_tree, i)));
          (sublines.length > 1) ? (prev_bottom_margin += TMP_P1_ROWSPACE) : (prev_bottom_margin += (TMP_P1_AFTER + add_margin_before(parse_tree, i)));
          // writef(" AFTER %s -> %d\n", sublines[0], add_margin_before(parse_tree, i));
          // writef(" SUbstring count %d\n", sublines.length);

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          }
        }
        else if(tag_name == "\\а2")
        {
          // writef(" paragraph %s\n", tag_value);
          wtag_value = to!wstring(tag_value);
          wstring curr_line = "";
          size_t curr_width = 0;

          wstring[] sublines;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          size_t devider = font.head.unitsPerEm / P2_FONT_SIZE;

          foreach (wchar letter; wtag_value)
          {
            int width = font.find_glyph_width(letter);
            // writef("    width for %s is %d\n", letter, width);
            // writef(" width for %s is %d\n", letter, width);
            line_width += width;
            if(((line_width / devider) + PAGE_LEFT_MARGIN + P2_MARGIN) <= (PAGE_WIDTH - PAGE_RIGHT_MARGIN)) {
              curr_line ~= letter;
              curr_width = (line_width + PAGE_LEFT_MARGIN + P2_MARGIN );
            }
            else {
              sublines ~= curr_line;
              curr_line = "";
              curr_width = 0;
              line_width = 0;
            }
          }  
          
          // добавить остальные саблинии
          // writef(" sublines count %d for %s\n", sublines.length, tag_value);
          if(sublines.length > 1) {
            for(size_t j = sublines.length - 1; j >= 1; j--)
            {
              string ch_line = PDF_Object.part_create_text_stream(
                PAGE_LEFT_MARGIN + P2_MARGIN, 
                0, 
                (sublines.length - 1 != j) ? prev_bottom_margin + P2_ROWSPACE : (prev_bottom_margin + P2_AFTER + add_margin_before(parse_tree, i)), 
                "F1", 
                P2_FONT_SIZE, 
                cast(wchar[])sublines[j],
                Searcher.find_font_path(PAGE_FONT)
              );
              children ~= ch_line;
              (sublines.length - 1 != j) ? (children_widths += P2_ROWSPACE) : (children_widths += (P2_AFTER + add_margin_before(parse_tree, i)));
              (sublines.length - 1 != j) ? (prev_bottom_margin += P2_ROWSPACE) : (prev_bottom_margin += (P2_AFTER + add_margin_before(parse_tree, i)));
            }
          } else {
            sublines ~= curr_line;
          }

          // добавить первую линию
          string ch_text = PDF_Object.part_create_text_stream(
            PAGE_LEFT_MARGIN + P2_MARGIN + P2_REDLINE, 
            0, 
            (sublines.length > 1) ? prev_bottom_margin + P2_ROWSPACE : prev_bottom_margin + P2_AFTER + add_margin_before(parse_tree, i), 
            "F1", 
            P2_FONT_SIZE, 
            cast(wchar[])sublines[0],
            Searcher.find_font_path(PAGE_FONT)
          );
          children ~= ch_text;
          (sublines.length > 1) ? (children_widths += P2_ROWSPACE) : (children_widths += (P2_AFTER + add_margin_before(parse_tree, i)));
          (sublines.length > 1) ? (prev_bottom_margin += P2_ROWSPACE) : (prev_bottom_margin += (P2_AFTER + add_margin_before(parse_tree, i)));
          // writef(" AFTER %s -> %d\n", sublines[0], add_margin_before(parse_tree, i));
          // writef(" SUbstring count %d\n", sublines.length);

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);
          // writef(" AFTER THIS -> %d\n", add_margin_before(parse_tree, i));
          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          }
        }
        else if(tag_name == "\\та2")
        {
          // writef(" paragraph %s\n", tag_value);
          wtag_value = to!wstring(tag_value);
          wstring curr_line = "";
          size_t curr_width = 0;

          wstring[] sublines;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          size_t devider = font.head.unitsPerEm / TMP_P2_FONT_SIZE;

          foreach (wchar letter; wtag_value)
          {
            int width = font.find_glyph_width(letter);
            // writef("    width for %s is %d\n", letter, width);
            // writef(" width for %s is %d\n", letter, width);
            line_width += width;
            if(((line_width / devider) + PAGE_LEFT_MARGIN + TMP_P2_MARGIN) <= (PAGE_WIDTH - PAGE_RIGHT_MARGIN)) {
              curr_line ~= letter;
              curr_width = (line_width + PAGE_LEFT_MARGIN + TMP_P2_MARGIN );
            }
            else {
              sublines ~= curr_line;
              curr_line = "";
              curr_width = 0;
              line_width = 0;
            }
          }  
          
          // добавить остальные саблинии
          // writef(" sublines count %d for %s\n", sublines.length, tag_value);
          if(sublines.length > 1) {
            for(size_t j = sublines.length - 1; j >= 1; j--)
            {
              string ch_line = PDF_Object.part_create_text_stream(
                PAGE_LEFT_MARGIN + TMP_P2_MARGIN, 
                0, 
                (sublines.length - 1 != j) ? prev_bottom_margin + TMP_P2_ROWSPACE : (prev_bottom_margin + TMP_P2_AFTER + add_margin_before(parse_tree, i)), 
                "F1", 
                TMP_P2_FONT_SIZE, 
                cast(wchar[])sublines[j],
                Searcher.find_font_path(PAGE_FONT)
              );
              children ~= ch_line;
              (sublines.length - 1 != j) ? (children_widths += TMP_P2_ROWSPACE) : (children_widths += (TMP_P2_AFTER + add_margin_before(parse_tree, i)));
              (sublines.length - 1 != j) ? (prev_bottom_margin += TMP_P2_ROWSPACE) : (prev_bottom_margin += (TMP_P2_AFTER + add_margin_before(parse_tree, i)));
            }
          } else {
            sublines ~= curr_line;
          }

          // добавить первую линию
          string ch_text = PDF_Object.part_create_text_stream(
            PAGE_LEFT_MARGIN + TMP_P2_MARGIN + TMP_P2_REDLINE, 
            0, 
            (sublines.length > 1) ? prev_bottom_margin + TMP_P2_ROWSPACE : prev_bottom_margin + TMP_P2_AFTER + add_margin_before(parse_tree, i), 
            "F1", 
            TMP_P2_FONT_SIZE, 
            cast(wchar[])sublines[0],
            Searcher.find_font_path(PAGE_FONT)
          );
          children ~= ch_text;
          (sublines.length > 1) ? (children_widths += TMP_P2_ROWSPACE) : (children_widths += (TMP_P2_AFTER + add_margin_before(parse_tree, i)));
          (sublines.length > 1) ? (prev_bottom_margin += TMP_P2_ROWSPACE) : (prev_bottom_margin += (TMP_P2_AFTER + add_margin_before(parse_tree, i)));
          // writef(" AFTER %s -> %d\n", sublines[0], add_margin_before(parse_tree, i));
          // writef(" SUbstring count %d\n", sublines.length);

          // writef("\n HEADER 1 %s - %s - %s - %d\n", wtag_value, H1_REGISTRE, capitalize(tag_value), line_width);
          // writef(" AFTER THIS -> %d\n", add_margin_before(parse_tree, i));
          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
          }
        }
        else if(tag_name == "\\з3")
        {
          wtag_value = (H3_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (H3_NUMBERING == "да") ? (to!wstring(h3_count--) ~ " " ~ wtag_value) : wtag_value;
          // H3_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / H3_FONT_SIZE;
          // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            ((PAGE_WIDTH + H3_MARGIN) - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + H3_AFTER + add_margin_before(parse_tree, i), 
            (H3_FORMAT == "жирный") ? "F2" : "F1", 
            H3_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (H3_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (H3_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }        
        }
        else if(tag_name == "\\тз3")
        {
          wtag_value = (TMP_H3_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (TMP_H3_NUMBERING == "да") ? (to!wstring(TMP_H3_count--) ~ " " ~ wtag_value) : wtag_value;
          // TMP_H3_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / TMP_H3_FONT_SIZE;
          // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            ((PAGE_WIDTH + TMP_H3_MARGIN) - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + TMP_H3_AFTER + add_margin_before(parse_tree, i), 
            (TMP_H3_FORMAT == "жирный") ? "F2" : "F1", 
            TMP_H3_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (TMP_H3_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (TMP_H3_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }        
        }
        else if(tag_name == "\\з4")
        {
          wtag_value = (H4_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (H4_NUMBERING == "да") ? (to!wstring(h4_count--) ~ " " ~ wtag_value) : wtag_value;
          // H4_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / H4_FONT_SIZE;
          // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            ((PAGE_WIDTH + H4_MARGIN) - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + H4_AFTER + add_margin_before(parse_tree, i), 
            (H4_FORMAT == "жирный") ? "F2" : "F1", 
            H4_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (H4_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (H4_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }        
        }
        else if(tag_name == "\\тз4")
        {
          wtag_value = (TMP_H4_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (TMP_H4_NUMBERING == "да") ? (to!wstring(TMP_H4_count--) ~ " " ~ wtag_value) : wtag_value;
          // TMP_H4_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / TMP_H4_FONT_SIZE;
          // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            ((PAGE_WIDTH + TMP_H4_MARGIN) - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + TMP_H4_AFTER + add_margin_before(parse_tree, i), 
            (TMP_H4_FORMAT == "жирный") ? "F2" : "F1", 
            TMP_H4_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (TMP_H4_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (TMP_H4_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }        
        }
        else if(tag_name == "\\з5")
        {
          wtag_value = (H5_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (H5_NUMBERING == "да") ? (to!wstring(H5_count--) ~ " " ~ wtag_value) : wtag_value;
          // H5_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / H5_FONT_SIZE;
          // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            ((PAGE_WIDTH + H5_MARGIN) - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + H5_AFTER + add_margin_before(parse_tree, i), 
            (H5_FORMAT == "жирный") ? "F2" : "F1", 
            H5_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (H5_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (H5_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          } 
        }
        else if(tag_name == "\\тз5")
        {
          wtag_value = (TMP_H5_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (TMP_H5_NUMBERING == "да") ? (to!wstring(TMP_H5_count--) ~ " " ~ wtag_value) : wtag_value;
          // TMP_H5_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / TMP_H5_FONT_SIZE;
          // writef("\n WIDTH - | %d <-> %d | RES - | %d |FOR %s\n", line_width, line_width / 161, (PAGE_WIDTH - (line_width / 12))/ 2, wtag_value);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            ((PAGE_WIDTH + TMP_H5_MARGIN) - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + TMP_H5_AFTER + add_margin_before(parse_tree, i), 
            (TMP_H5_FORMAT == "жирный") ? "F2" : "F1", 
            TMP_H5_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (TMP_H5_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (TMP_H5_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          } 
        }
        else if(tag_name == "\\з6")
        {
          wtag_value = (H6_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (H6_NUMBERING == "да") ? (to!wstring(H6_count--) ~ " " ~ wtag_value) : wtag_value;
          // H6_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / H6_FONT_SIZE;
          // writef("\n MARGIN - | %d | %d |\n", H6_AFTER, H6_BEFORE);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            (PAGE_WIDTH - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + H6_AFTER + add_margin_before(parse_tree, i), 
            (H6_FORMAT == "жирный") ? "F2" : "F1", 
            H6_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          children_widths += (H6_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (H6_AFTER + add_margin_before(parse_tree, i));

          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }
        }
        else if(tag_name == "\\тз6")
        {
          wtag_value = (TMP_H6_REGISTRE == "капс") ? to!wstring(tag_value.toUpper) : to!wstring(tag_value);
          // wtag_value = (TMP_H6_NUMBERING == "да") ? (to!wstring(TMP_H6_count--) ~ " " ~ wtag_value) : wtag_value;
          // TMP_H6_count++;

          TTF font = new TTF(Searcher.find_font_path(PAGE_FONT));
          foreach (wchar letter; wtag_value)
          {
            string glyph_index = font.find_glyph_index(letter);
            int dec_glyph_index = to!int(glyph_index, 16);
            int width = font.find_glyph_width(letter);
            line_width += width;
          }

          size_t devider = font.head.unitsPerEm / TMP_H6_FONT_SIZE;
          // writef("\n MARGIN - | %d | %d |\n", TMP_H6_AFTER, TMP_H6_BEFORE);
          string ch_text = PDF_Object.part_create_text_stream(
            // WHY 320 ??
            (PAGE_WIDTH - (line_width / devider ))/ 2, 
            0, 
            prev_bottom_margin + TMP_H6_AFTER + add_margin_before(parse_tree, i), 
            (TMP_H6_FORMAT == "жирный") ? "F2" : "F1", 
            TMP_H6_FONT_SIZE, 
            cast(wchar[])wtag_value,
            Searcher.find_font_path(PAGE_FONT ~ " Bold")
            // "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
          );
          children ~= ch_text;
          
          writef(" BEFORE | %d | %d | with %d + %d \n", children_widths, prev_bottom_margin, TMP_H6_AFTER, add_margin_before(parse_tree, i));
          
          children_widths += (TMP_H6_AFTER + add_margin_before(parse_tree, i));
          prev_bottom_margin += (TMP_H6_AFTER + add_margin_before(parse_tree, i));

          writef(" AFTER | %d | %d |\n", children_widths, prev_bottom_margin);
          // уникальн ые буквы
          foreach (wchar letter; wtag_value)
          {
            if(!unique_letters.canFind(letter)) unique_letters ~= letter;
            // writef("%s => | dec - %d | hex -> %s |\n", letter, cast(int)letter, dec_to_hexa(cast(int)letter));
          }
        }
        line_width = 0;
      }

      Page_Container page = new Page_Container();

      PDF_Object new_obj = new PDF_Object();
      new_obj.create_stream_object(id, 0, children, children_widths);
      page.temp_objs ~= new_obj;

      page.gstate_obj = new PDF_Object();
      page.gstate_obj.create_gstate(++id, 0);

      page.cs_embed_obj = new PDF_Object();
      page.cs_embed_obj.create_colorspace_embedd_object(++id, 0, "/Users/mac/Downloads/sRGB2014.icc");

      // PDF_Object cs_obj = new PDF_Object();
      // cs_obj.create_colorspace_object(id + 2, 0, cs_embed_obj.name);

      // EMBED FONT FILES
      page.font_embed_obj = new PDF_Object();
      page.font_embed_obj.create_embed_font(++id, 0, Searcher.find_font_path(PAGE_FONT));
      
      // -------- BOLD
      page.bfont_embed_obj = new PDF_Object();
      page.bfont_embed_obj.create_embed_font(++id, 0, Searcher.find_font_path(PAGE_FONT ~ " Bold"));

      page.font_desc_obj = new PDF_Object();
      page.font_desc_obj.create_font_descriptor(++id, 0, "YAZWPA+Times-Roman", Searcher.find_font_path(PAGE_FONT), page.font_embed_obj.name);

      // -------- BOLD
      page.bfont_desc_obj = new PDF_Object();
      page.bfont_desc_obj.create_font_descriptor(++id, 0, "BYAZWPA+Times-Roman", Searcher.find_font_path(PAGE_FONT ~ " Bold"), page.bfont_embed_obj.name);

      page.cid_tbl_obj = new PDF_Object();
      page.cid_tbl_obj.create_cid_tbl(++id, 0, unique_letters, Searcher.find_font_path(PAGE_FONT));

      // -------- BOLD
      page.bcid_tbl_obj = new PDF_Object();
      page.bcid_tbl_obj.create_cid_tbl(++id, 0, unique_letters, Searcher.find_font_path(PAGE_FONT ~ " Bold"));

      page.image_obj = new PDF_Object();
      page.image_obj.create_image_resource_object(++id, 0, 256, 256, "/Users/mac/Desktop/Projects/yard/test/ASTU.jpg", page.cs_embed_obj.name);
    
      page.resources_obj = new PDF_Object();
      page.resources_obj.create_font_object(++id, 0, "CIDFontType2", "F1", "YAZWPA+Times-Roman", page.font_desc_obj.name, unique_letters, Searcher.find_font_path(PAGE_FONT));

      // -------- BOLD
      page.bold_font_obj = new PDF_Object();
      page.bold_font_obj.create_font_object(++id, 0, "CIDFontType2", "F2", "BYAZWPA+Times-Roman", page.bfont_desc_obj.name, unique_letters, Searcher.find_font_path(PAGE_FONT ~ " Bold"));

      page.parent_font_obj = new PDF_Object();
      page.parent_font_obj.create_base_font_object(++id, 0, [page.resources_obj.name], page.cid_tbl_obj.name, "YAZWPA+Times-Roman");

      // -------- BOLD
      page.bparent_font_obj = new PDF_Object();
      page.bparent_font_obj.create_base_font_object(++id, 0, [page.bold_font_obj.name], page.bcid_tbl_obj.name, "BYAZWPA+Times-Roman");

      page.page_obj = new PDF_Object();
      page.page_obj.create_page(page_id, 0, 2, [page.parent_font_obj.name, page.bparent_font_obj.name], page.image_obj.name, page.temp_objs[0].name, page.cs_embed_obj.name, page.gstate_obj.name, PAGE_WIDTH, PAGE_HEIGHT, PAGE_LEFT_MARGIN, PAGE_BOTTOM_MARGIN);
      
      page_id += 15;

      id += 2;
      pages ~= page;
    }

    PDF_Object pages_tree_obj = new PDF_Object();

    PDF_Object[] page_objs;
    foreach(Page_Container page; pages) {
      page_objs ~= page.page_obj;
    }
    pages_tree_obj.create_pages_tree(2, 0, parse_tree.pg_count, page_objs);
    
    objects ~= pages_tree_obj;

    foreach(Page_Container page; pages)
    {
      objects ~= page.page_obj;

      foreach (PDF_Object obj; page.temp_objs)
      {
        objects ~= obj;
      }

      objects ~= page.gstate_obj;
      objects ~= page.cs_embed_obj;
      objects ~= page.font_embed_obj;
      objects ~= page.bfont_embed_obj;
      objects ~= page.font_desc_obj;
      objects ~= page.bfont_desc_obj;
      objects ~= page.cid_tbl_obj;
      objects ~= page.bcid_tbl_obj;
      objects ~= page.image_obj;
      objects ~= page.resources_obj;
      objects ~= page.bold_font_obj;
      objects ~= page.parent_font_obj;
      objects ~= page.bparent_font_obj;
    }
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

  string[string][] options;

  this()
  {
    pdf_header  = "%PDF-1.6\n";
    pdf_body    = new PDF_Body();
    pdf_crtable = new PDF_CRTable();
    pdf_trailer = new PDF_Trailer();
  }

  private void set_variables(Yrd_tree template_tree) {
    // get page options
    try {
      PAGE_HEIGHT          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.HEIGHT));
      // writef("height %s %s %s | %s\n", "!" ~ TAGS.PG, PAGE_STYLE.HEIGHT, template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.HEIGHT), template_tree.get_templ_opt_value("!стр", "высота"));

      PAGE_WIDTH           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.WIDTH));
      // writef("%d\n", PAGE_WIDTH);
      // writef("%s\n", template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.TMARGIN) );
      PAGE_TOP_MARGIN      = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.TMARGIN));
      PAGE_BOTTOM_MARGIN   = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.BMARGIN));
      PAGE_LEFT_MARGIN     = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.LMARGIN));
      PAGE_RIGHT_MARGIN    = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.RMARGIN));
      PAGE_FONT            = template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.FONT);

      // get tags options
      H1_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.FSIZE));
      H1_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.ALIGMENT);
      H1_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.REGISTRE);
      H1_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.FORMAT);
      H1_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.REDLINE));
      H1_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.MARGIN));
      H1_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.BEFORE)); 
      H1_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.AFTER));
      H1_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.ROWSPACE));
      H1_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.H1, TXT_STYLE.NUMBERING);

      H2_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.FSIZE));
      H2_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.ALIGMENT);
      H2_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.REGISTRE);
      H2_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.FORMAT);
      H2_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.REDLINE));
      H2_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.MARGIN));
      H2_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.BEFORE)); 
      H2_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.AFTER));
      H2_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.ROWSPACE));
      H2_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.H2, TXT_STYLE.NUMBERING);
    
      H3_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.FSIZE));
      H3_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.ALIGMENT);
      H3_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.REGISTRE);
      H3_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.FORMAT);
      H3_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.REDLINE));
      H3_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.MARGIN));
      H3_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.BEFORE)); 
      H3_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.AFTER));
      H3_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.ROWSPACE));
      H3_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.H3, TXT_STYLE.NUMBERING);
    
      H4_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.FSIZE));
      H4_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.ALIGMENT);
      H4_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.REGISTRE);
      H4_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.FORMAT);
      H4_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.REDLINE));
      H4_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.MARGIN));
      H4_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.BEFORE)); 
      H4_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.AFTER));
      H4_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.ROWSPACE));
      H4_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.H4, TXT_STYLE.NUMBERING);

      H5_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.FSIZE));
      H5_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.ALIGMENT);
      H5_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.REGISTRE);
      H5_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.FORMAT);
      H5_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.REDLINE));
      H5_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.MARGIN));
      H5_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.BEFORE)); 
      H5_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.AFTER));
      H5_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.ROWSPACE));
      H5_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.H5, TXT_STYLE.NUMBERING);

      H6_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.FSIZE));
      H6_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.ALIGMENT);
      H6_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.REGISTRE);
      H6_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.FORMAT);
      H6_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.REDLINE));
      H6_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.MARGIN));
      H6_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.BEFORE)); 
      H6_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.AFTER));
      H6_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.ROWSPACE));
      H6_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.H6, TXT_STYLE.NUMBERING);

      PA_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.FSIZE));
      PA_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.ALIGMENT);
      PA_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.REGISTRE);
      PA_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.FORMAT);
      PA_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.REDLINE));
      PA_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.MARGIN));
      PA_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.BEFORE)); 
      PA_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.AFTER));
      PA_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.ROWSPACE));
      PA_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.PA, TXT_STYLE.NUMBERING);    
    
      P1_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.FSIZE));
      P1_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.ALIGMENT);
      P1_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.REGISTRE);
      P1_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.FORMAT);
      P1_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.REDLINE));
      P1_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.MARGIN));
      P1_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.BEFORE)); 
      P1_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.AFTER));
      P1_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.ROWSPACE));
      P1_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.P1, TXT_STYLE.NUMBERING);    

      P2_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.FSIZE));
      P2_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.ALIGMENT);
      P2_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.REGISTRE);
      P2_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.FORMAT);
      P2_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.REDLINE));
      P2_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.MARGIN));
      P2_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.BEFORE)); 
      P2_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.AFTER));
      P2_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.ROWSPACE));
      P2_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.P2, TXT_STYLE.NUMBERING);    

      CE_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.FSIZE));
      CE_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.ALIGMENT);
      CE_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.REGISTRE);
      CE_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.FORMAT);
      CE_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.REDLINE));
      CE_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.MARGIN));
      CE_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.BEFORE)); 
      CE_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.AFTER));
      CE_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.ROWSPACE));
      CE_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.CE, TXT_STYLE.NUMBERING); 

      TMP_PAGE_HEIGHT          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPG, PAGE_STYLE.HEIGHT));
      // writef("height %s %s %s | %s\n", "!" ~ TAGS.PG, PAGE_STYLE.HEIGHT, template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.HEIGHT), template_tree.get_templ_opt_value("!стр", "высота"));

      TMP_PAGE_WIDTH           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPG, PAGE_STYLE.WIDTH));
      // writef("%d\n", PAGE_WIDTH);
      // writef("%s\n", template_tree.get_templ_opt_value("!" ~ TAGS.PG, PAGE_STYLE.TMARGIN) );
      TMP_PAGE_TOP_MARGIN      = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPG, PAGE_STYLE.TMARGIN));
      TMP_PAGE_BOTTOM_MARGIN   = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPG, PAGE_STYLE.BMARGIN));
      TMP_PAGE_LEFT_MARGIN     = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPG, PAGE_STYLE.LMARGIN));
      TMP_PAGE_RIGHT_MARGIN    = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPG, PAGE_STYLE.RMARGIN));
      TMP_PAGE_FONT            = template_tree.get_templ_opt_value("!" ~ TAGS.TPG, PAGE_STYLE.FONT);

      // get tags options
      TMP_H1_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.FSIZE));
      TMP_H1_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.ALIGMENT);
      TMP_H1_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.REGISTRE);
      TMP_H1_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.FORMAT);
      TMP_H1_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.REDLINE));
      TMP_H1_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.MARGIN));
      TMP_H1_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.BEFORE)); 
      TMP_H1_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.AFTER));
      TMP_H1_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.ROWSPACE));
      TMP_H1_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TH1, TXT_STYLE.NUMBERING);

      TMP_H2_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.FSIZE));
      TMP_H2_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.ALIGMENT);
      TMP_H2_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.REGISTRE);
      TMP_H2_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.FORMAT);
      TMP_H2_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.REDLINE));
      TMP_H2_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.MARGIN));
      TMP_H2_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.BEFORE)); 
      TMP_H2_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.AFTER));
      TMP_H2_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.ROWSPACE));
      TMP_H2_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TH2, TXT_STYLE.NUMBERING);
    
      TMP_H3_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.FSIZE));
      TMP_H3_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.ALIGMENT);
      TMP_H3_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.REGISTRE);
      TMP_H3_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.FORMAT);
      TMP_H3_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.REDLINE));
      TMP_H3_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.MARGIN));
      TMP_H3_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.BEFORE)); 
      TMP_H3_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.AFTER));
      TMP_H3_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.ROWSPACE));
      TMP_H3_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TH3, TXT_STYLE.NUMBERING);
    
      TMP_H4_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.FSIZE));
      TMP_H4_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.ALIGMENT);
      TMP_H4_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.REGISTRE);
      TMP_H4_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.FORMAT);
      TMP_H4_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.REDLINE));
      TMP_H4_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.MARGIN));
      TMP_H4_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.BEFORE)); 
      TMP_H4_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.AFTER));
      TMP_H4_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.ROWSPACE));
      TMP_H4_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TH4, TXT_STYLE.NUMBERING);

      TMP_H5_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.FSIZE));
      TMP_H5_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.ALIGMENT);
      TMP_H5_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.REGISTRE);
      TMP_H5_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.FORMAT);
      TMP_H5_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.REDLINE));
      TMP_H5_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.MARGIN));
      TMP_H5_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.BEFORE)); 
      TMP_H5_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.AFTER));
      TMP_H5_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.ROWSPACE));
      TMP_H5_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TH5, TXT_STYLE.NUMBERING);

      TMP_H6_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.FSIZE));
      TMP_H6_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.ALIGMENT);
      TMP_H6_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.REGISTRE);
      TMP_H6_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.FORMAT);
      TMP_H6_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.REDLINE));
      TMP_H6_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.MARGIN));
      TMP_H6_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.BEFORE)); 
      TMP_H6_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.AFTER));
      TMP_H6_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.ROWSPACE));
      TMP_H6_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TH6, TXT_STYLE.NUMBERING);

      TMP_PA_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.FSIZE));
      TMP_PA_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.ALIGMENT);
      TMP_PA_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.REGISTRE);
      TMP_PA_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.FORMAT);
      TMP_PA_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.REDLINE));
      TMP_PA_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.MARGIN));
      TMP_PA_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.BEFORE)); 
      TMP_PA_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.AFTER));
      TMP_PA_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.ROWSPACE));
      TMP_PA_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TPA, TXT_STYLE.NUMBERING);    
    
      TMP_P1_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.FSIZE));
      TMP_P1_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.ALIGMENT);
      TMP_P1_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.REGISTRE);
      TMP_P1_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.FORMAT);
      TMP_P1_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.REDLINE));
      TMP_P1_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.MARGIN));
      TMP_P1_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.BEFORE)); 
      TMP_P1_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.AFTER));
      TMP_P1_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.ROWSPACE));
      TMP_P1_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TP1, TXT_STYLE.NUMBERING);    

      TMP_P2_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.FSIZE));
      TMP_P2_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.ALIGMENT);
      TMP_P2_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.REGISTRE);
      TMP_P2_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.FORMAT);
      TMP_P2_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.REDLINE));
      TMP_P2_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.MARGIN));
      TMP_P2_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.BEFORE)); 
      TMP_P2_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.AFTER));
      TMP_P2_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.ROWSPACE));
      TMP_P2_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TP2, TXT_STYLE.NUMBERING);    

      TMP_CE_FONT_SIZE         = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.FSIZE));
      TMP_CE_ALIGMENT          = template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.ALIGMENT);
      TMP_CE_REGISTRE          = template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.REGISTRE);
      TMP_CE_FORMAT            = template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.FORMAT);
      TMP_CE_REDLINE           = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.REDLINE));
      TMP_CE_MARGIN            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.MARGIN));
      TMP_CE_BEFORE            = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.BEFORE)); 
      TMP_CE_AFTER             = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.AFTER));
      TMP_CE_ROWSPACE          = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.ROWSPACE));
      TMP_CE_NUMBERING         = template_tree.get_templ_opt_value("!" ~ TAGS.TCE, TXT_STYLE.NUMBERING);

      IMG_HEIGHT               = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.IM, IMG_STYLE.HEIGHT));
      IMG_WIDTH                = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.IM, IMG_STYLE.WIDTH));
      IMG_ALIGMENT             = template_tree.get_templ_opt_value("!" ~ TAGS.IM, IMG_STYLE.ALIGMENT);
      IMG_MARGIN               = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.IM, IMG_STYLE.MARGIN));
      IMG_BEFORE               = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.IM, IMG_STYLE.BEFORE)); 
      IMG_AFTER                = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.IM, IMG_STYLE.AFTER));
    
      CNT_MARGIN1              = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CN, CNT_STYLE.MARGIN1));
      CNT_MARGIN2              = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CN, CNT_STYLE.MARGIN2));
      CNT_MARGIN3              = to!size_t(template_tree.get_templ_opt_value("!" ~ TAGS.CN, CNT_STYLE.MARGIN3));
      // CNT_DELIMET              =
    } catch(ERROR_Option_Not_Found e) {
      writef(" ERROR %s\n", e.msg);
    }
  }

  string build(Yrd_tree parse_tree, Yrd_tree template_tree)
  {
    set_variables(template_tree);
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