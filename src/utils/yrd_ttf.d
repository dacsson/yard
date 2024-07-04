/*
  Парсер TTF-шрифтов (скорее всего подойдёт ко всем OpenType шрифтам)
  Но только для парсинга CMAP таблицы и другого необходимого для ПДФ 
*/
module yard.utils.yrd_ttf;

import std.file : read; 
import std.utf : byChar;
import std.stdio : writef, writeln;
import std.conv : to;
import std.stdint;
import std.algorithm.sorting : sort;
import std.datetime.date : Date, DateTime;
import std.datetime.timezone : UTC;
import std.datetime.systime : SysTime;
import core.exception : ArrayIndexError;

string dec_to_hexa(int n)
{
  // ans string to store hexadecimal number
  char[] ans;
  
  while (n != 0) {
    // remainder variable to store remainder
    int rem = 0;
      
    // ch variable to store each character
    char ch;
    // storing remainder in rem variable.
    rem = n % 16;

    // check if temp < 10
    if (rem < 10) {
      ch = cast(char)(rem + 48);
    }
    else {
      ch = cast(char)(rem + 55);
    }
      
    // updating the ans string with the character variable
    ans ~= ch;
    n = n / 16;
  }
    
  // reversing the ans string to get the final result
  int i = 0, j = cast(int)ans.length - 1;
  while(i <= j)
  {
    char temp = ans[i];
    ans[i] = ans[j];
    ans[j] = temp;
    i++;
    j--;
  }

  size_t ans_size = ans.length;
  size_t front_zeros = 4 - ans_size;
  string res = "";
  for(int ch = 0; ch < front_zeros; ch++) {
    res ~= "0";
  }
  res ~= to!string(ans);

  return res;
}

class Binary_Reader {
  public size_t pos;
  public uint8_t[] data;

  this(const ubyte[] buffer) {
    this.data = buffer.dup;
  }

  size_t seek(size_t index) {
    size_t prev_pos = this.pos;
    this.pos = index;
    return prev_pos;
  }

  uint8_t get_u8() {
    return this.data[this.pos++];
  }

  uint16_t get_u16() {
    return ((get_u8() << 8 ) | (get_u8() >>> 0));
  }

  uint32_t get_u32() {
    return get_i32() >>> 0;
  }

  int8_t get_i8() {
    uint8_t num = get_u8();
    if(num & 0x80) {
      num -= (1 << 8);
    }
    return num;
  }

  int16_t get_i16() {
    uint16_t num = get_u16();
    if(num & 0x8000) {
      num -= (1 << 16);
    }
    return num;
  }

  int32_t get_i32() {
    return (
      (get_u8() << 24) |
      (get_u8() << 16) |
      (get_u8() << 8) |
      (get_u8())
    );
  }

  SysTime get_date() {
    long macTime = get_u32() * 0x100000000 + get_u32();
    Date def = Date(1904, 1, 1);
    SysTime utcTime = SysTime(def, UTC());
    return utcTime;
  }

  string get_string(size_t size) {
    string str = "";
    for(int i = 0; i < size; i++) {
      int char_code = get_u8();
      char ch = cast(char)char_code;
      str ~= ch;
    }
    return str;
  }

  int16_t get_fixed() {
    return get_i32() / (1 << 16);
  }
}

struct Offset_Table {
  string name;
  uint32_t checksum;
  uint32_t offset;
  uint32_t length;

  this(string name, uint32_t checksum, uint32_t offset, uint32_t length) {
    this.name = name;
    this.checksum = checksum;
    this.offset = offset;
    this.length = length;
  }
}

/*
The 'hhea' table contains information needed to 
layout fonts whose characters are written horizontally, 
that is, either left to right or right to left. 
This table contains information that is 
general to the font as a whole. 
Information which pertains to specific glyphs is 
given in the 'hmtx' table
*/
struct HHEA_Table 
{
  uint16_t ver;
  int16_t ascent;
  int16_t descent;
  int16_t line_gap;
  int16_t metric_data_format;
  uint16_t num_of_long_metrics;
}

struct Cmap_Encoding_Subtable
{
  uint16_t platform_id;
  uint16_t platform_spec_id;
  uint32_t offset;
}

/* 
The 'cmap' table maps character codes to glyph indices.

THIS TYPE IS SPECIFICLY FOR CMAP FORMAT 4
*/
struct CMAP_table
{
  uint16_t ver;
  uint16_t num_of_subtables;
  Cmap_Encoding_Subtable[] enc_subtables;
  uint16_t format;
  uint16_t length;
  uint16_t language;
  uint16_t seg_count;
  uint16_t search_range;
  uint16_t entry_selector;
  uint16_t range_shift;
  uint16_t[] end_codes;
  uint16_t reserve_pad;
  uint16_t[] start_codes;
  uint16_t[] id_deltas;
  uint16_t[] id_range_offsets;
  uint16_t[] glyph_index_array;

  string[string][] char_glyph_table;
}

struct OSS2_table {
  uint16_t ver;
  int16_t xAvgCharWidth;
  uint16_t usWeightClass;
  uint16_t usWidthClass;
  int16_t fsType;
  int16_t	ySubscriptXSize;
  int16_t	ySubscriptYSize;
  int16_t	ySubscriptXOffset;	
  int16_t	ySubscriptYOffset;	
  int16_t	ySuperscriptXSize;	
  int16_t	ySuperscriptYSize;	
  int16_t	ySuperscriptXOffset;	
  int16_t	ySuperscriptYOffset;	
  int16_t	yStrikeoutSize;	
  int16_t	yStrikeoutPosition;	
  int16_t	sFamilyClass;	
  // PANOSE	panose;	
  uint32_t[4]	ulUnicodeRange;	
  int8_t[4]	achVendID;	
  uint16_t	fsSelection;
  uint16_t	fsFirstCharIndex;	
  uint16_t	fsLastCharIndex;
  // ADDED FIELDS
  int16_t	sTypoAscender;
  int16_t	sTypoDescender;
  int16_t	sTypoLineGap;	
  uint16_t	usWinAscent;	
  uint16_t usWinDescent;
  uint32_t	ulCodePageRange1;	
  uint32_t	ulCodePageRange2;	
  int16_t	sxHeight;	
  int16_t	sCapHeight;	
  uint16_t	usDefaultChar;	
  uint16_t	usBreakChar;	
  uint16_t	usMaxContext; 
  uint16_t	usLowerPointSize;	
  uint16_t	usUpperPointSize;	
}

struct Long_Hor_Metric {
  uint16_t advance_width;
  int16_t left_side_bearing;
}

struct HMTX_table
{
  Long_Hor_Metric[] h_metrics;
  int16_t left_side_bearings;
}

struct HEAD_table
{
  uint16_t ver;
  uint16_t fontRevision;
  uint32_t checkSumAdjusment;
  // WOW! MAGIC!
  uint32_t magicNumber;
  uint16_t flags;
  uint16_t unitsPerEm;
  // ABSOLUTLY DISGUSTING
  SysTime created;
  SysTime modified;
  int16_t xMin;
  int16_t yMin;
  int16_t xMax;
  int16_t yMax;
}

class TTF {
  size_t subtables_count;
  Offset_Table[] tables;

  CMAP_table cmap;
  HHEA_Table hhea;
  HMTX_table htmx;
  OSS2_table oss2;
  HEAD_table head;

  this(string font_path) {
    const ubyte[] font_content = cast(const(ubyte)[])read(font_path);
    tables = read_offset_tables(font_content);
    cmap = read_cmap_table(font_content);
    hhea = read_hhea_table(font_content);
    htmx = read_hmtx_table(font_content);
    oss2 = read_oss2_table(font_content);
    head = read_head_table(font_content);
  }

  Offset_Table[] read_offset_tables(const ubyte[] buffer) {
    auto file = new Binary_Reader(buffer);
    
    Offset_Table[] tables;

    uint32_t scalar_type = file.get_u32();
    uint16_t tables_count = file.get_u16();
    uint16_t search_range = file.get_u16();
    uint16_t entry_selector = file.get_u16();
    uint16_t range_shift = file.get_u16();
    // // writef("| %08x - %d | %08x - %d | %08x - %d | %d | %d", scalar_type, scalar_type, tables_count, tables_count, search_range, search_range, entry_selector, range_shift);

    string tag;
    Offset_Table curr_table;
    for(int i = 0; i < tables_count; i++) {
      tag = file.get_string(4);
      curr_table = Offset_Table(tag, file.get_u32(), file.get_u32(), file.get_u32());
      tables ~= curr_table;
      // // writef("%s %d %d %d\n", tag, curr_table.checksum, curr_table.offset, curr_table.length);
    }

    return tables;
  }

  Offset_Table find_table(string tag) {
    for(int i = 0; i < tables.length; i++) {
      if(tables[i].name == tag) return tables[i];
    }

    assert(0);
  }

  CMAP_table read_cmap_table(const ubyte[] buffer) {
    CMAP_table cmap_table;
    auto file = new Binary_Reader(buffer);

    file.seek(find_table("cmap").offset);

    cmap_table.ver = file.get_i16();
    uint16_t subtables_count = file.get_i16();

    // // writef("at %d => | %08x - %d | | %08x - %d |\n", file.pos, ver, ver, subtables_count, subtables_count);

    // read encoding subtables 
    for(int i = 0; i < subtables_count; i++) {
      Cmap_Encoding_Subtable enc_table;
      enc_table.platform_id = file.get_u16();
      enc_table.platform_spec_id = file.get_u16();
      enc_table.offset = file.get_u32();  

      cmap_table.enc_subtables ~= enc_table;
      // // writef("%d subtable => | %d | %d | %d |\n", i, platform_id, platform_spec_id, offset);
    }

    // read subtables
    cmap_table.format = file.get_u16();
    // // writef("format -> %d at %d\n", format, file.pos);

    // cmap form 4
    switch(cmap_table.format) {
      case 4: {
        cmap_table.length = file.get_u16();
        uint16_t _length = cast(uint16_t)(cmap_table.length - 2);
        // // writef("new length: %d / %d", cmalength, _length);
       cmap_table.language = file.get_u16();
        _length -= 2;
        uint16_t segCountX2 = file.get_u16();
        _length -= 2;
        cmap_table.seg_count = segCountX2 / 2;
        cmap_table.search_range = file.get_u16();
        _length -= 2;
        cmap_table.entry_selector = file.get_u16();
        _length -= 2;
        cmap_table.range_shift = file.get_u16();
        _length -= 2;

        // Ending character code for each segment
        for(int i = 0; i < cmap_table.seg_count; i++) {
          uint16_t endCode = file.get_u16();
          _length -= 2;
          cmap_table.end_codes ~= endCode;
        }
        cmap_table.reserve_pad = file.get_u16();
        _length -= 2;

        // Starting character code for each segment
        for(int i = 0; i < cmap_table.seg_count; i++) {
          uint16_t startCode = file.get_u16();
          _length -= 2;
          cmap_table.start_codes ~= startCode;
        }

        // Delta for all character codes in segment
        for(int i = 0; i < cmap_table.seg_count; i++) {
          uint16_t idDelta = file.get_u16();
          _length -= 2;
          cmap_table.id_deltas ~= idDelta;
        }

        // Offset in bytes to glyph indexArray, or 0
        for(int i = 0; i < cmap_table.seg_count; i++) {
          uint16_t idRangeOffset = file.get_u16();
          _length -= 2;
          cmap_table.id_range_offsets ~= idRangeOffset;
        }
        // // writef("at pos %d\n", file.pos);
        // Glyph index array
        size_t glyphIndexSize = _length ;
        for(int i = 0; i < glyphIndexSize; i++) {
          uint16_t glyphIndex = file.get_u16();
          cmap_table.glyph_index_array ~= glyphIndex;
        }

        // // writef(" at %d:\n - length | %08x - %d |\n - language | %s - %d |\n - seg count2 | %08x - %d |\n - glyphs size | %d |\n", file.pos ,length, length, language, language, segCountX2, segCountX2, glyphIndexSize);
        // wchar ch = 'П';
        // uint16_t ch_code = cast(uint16_t)ch;

        // // writef(" trying to get glyph index: char - %s | code - %d |\n", ch, ch_code);
        // for(int i = 0; i < segCount; i++) {
        //   // int glyphId = *( &idRangeOffsets[i] + idRangeOffsets[i] / 2 + (ch_code - startCodes[i]) );
        //   // writef("SEGMENT n. %d : st cd - %d end cd - %d offset - %d\n", i, startCodes[i], endCodes[i], idRangeOffsets[i]);
        //   // // writef("id for %d - %d\n", ch_code, glyphId);
        // }

        // BUILD A CMAP CHAR CODE TO GLYPH INDEX MAP
        uint16_t glyph_index;
        int glyph_id;
        for(uint16_t char_code = 32; char_code < 65532; char_code++) {
          for(int i = 0; i < cmap_table.seg_count; i++) {
            // FIND IN WHICH SEGMENT DOES CHAR CODES APPEAR
            if(char_code >= cmap_table.start_codes[i] && char_code <= cmap_table.end_codes[i]) {
              uint16_t offset = cmap_table.id_range_offsets[i];
              switch(offset) {
                case 0: {
                  glyph_id = (cmap_table.id_deltas[i] + char_code) % 65536;
                } break;
                default: {
                  glyph_id = *( &cmap_table.id_range_offsets[i] + cmap_table.id_range_offsets[i] / 2 + (char_code - cmap_table.start_codes[i]) ); 
                } break;
              }

              string[string] char_gyph_pair = [dec_to_hexa(char_code): dec_to_hexa(glyph_id)];
              cmap_table.char_glyph_table ~= char_gyph_pair;
            } 
          }
        }

        // for(int i = 0; i < 200; i+=2) {
        //   // uint16_t gl_index = glyphIndexArray[i - segCount + idRangeOffsets[i]/2 + (ch_code - startCodes[i])];
        //   // writef("|%d - %d | %08x - %08x|\n", glyphIndexArray[i], glyphIndexArray[i + 1], glyphIndexArray[i], glyphIndexArray[i + 2]);
        // }
        // // writef(" trying to get glyph index: char - %s | code - %d |\n", ch, ch_code);
        // // writef("%d\n", glyphIndexArray[i - segCount + idRangeOffset[i]/2 + (c - startCode[i])]);

        // uint16_t next = file.get_u16();
        // // writef("next is | %s - %08x - %d |\n", cast(char*)next, next, next);
      } break;
      default : {
        
      } break;
    }

    return cmap_table;
  }

  HHEA_Table read_hhea_table(const ubyte[] buffer) {
    HHEA_Table hhea_table;

    auto file = new Binary_Reader(buffer);
    file.seek(find_table("hhea").offset);

    hhea_table.ver = file.get_fixed();
    hhea_table.ascent = file.get_i16();
    hhea_table.descent = file.get_i16();
    hhea_table.line_gap = file.get_i16();

    // thowaway vars
    uint16_t advance_w_max = file.get_u16();
    int16_t min_left_sbearing = file.get_i16();
    int16_t min_right_sbearing = file.get_i16();
    int16_t x_max_extent = file.get_i16();
    int16_t care_slop_rise = file.get_i16();
    int16_t care_slop_run = file.get_i16();
    int16_t care_offset = file.get_i16();

    int16_t res1 = file.get_i16();
    int16_t res2 = file.get_i16();
    int16_t res3 = file.get_i16();
    int16_t res4 = file.get_i16();

    hhea_table.metric_data_format = file.get_i16();
    hhea_table.num_of_long_metrics = file.get_u16();

    // // writef("\nhhead => | ver %d | ascent %d | descent %d | met data format %d | num metrics %d |\n", hhea_table.ver, hhea_table.ascent, hhea_table.descent, hhea_table.metric_data_format, hhea_table.num_of_long_metrics);

    return hhea_table;
  }

  HMTX_table read_hmtx_table(const ubyte[] buffer) {
    HMTX_table htmx_table;

    auto file = new Binary_Reader(buffer);
    file.seek(find_table("hmtx").offset);

    for(int i = 0; i < hhea.num_of_long_metrics; i++) {
      uint16_t advance_width = file.get_u16();
      int16_t left_side_bearing = file.get_i16();
      Long_Hor_Metric metric = Long_Hor_Metric(advance_width, left_side_bearing);
      htmx_table.h_metrics ~= metric;
    }

    // left side bearing ???

    return htmx_table;
  }

  OSS2_table read_oss2_table(const ubyte[] buffer) {
    OSS2_table oss2_table;

    auto file = new Binary_Reader(buffer);
    file.seek(find_table("OS/2").offset);

    oss2_table.ver = file.get_u16();
    // // writef(" ver | %08x - %d |\n", oss2_table.ver, oss2_table.ver);
    oss2_table.xAvgCharWidth = file.get_i16();
    // // writef(" xAvgCharWidth | %08x - %d |\n", oss2_table.xAvgCharWidth, oss2_table.xAvgCharWidth);
    oss2_table.usWeightClass = file.get_u16();
    // // writef(" usWeightClassh | %08x - %d |\n", oss2_table.usWeightClass, oss2_table.usWeightClass);
    oss2_table.usWidthClass = file.get_u16();
    // writef(" usWidthClass | %08x - %d |\n", oss2_table.usWidthClass, oss2_table.usWidthClass);
    oss2_table.fsType = file.get_i16();
    // writef(" sType | %08x - %d |\n", oss2_table.fsType, oss2_table.fsType);
    oss2_table.ySubscriptXSize = file.get_i16();
    // writef(" ySubscriptXSize | %08x - %d |\n", oss2_table.ySubscriptXSize, oss2_table.ySubscriptXSize);
    oss2_table.ySubscriptYSize = file.get_i16();

    oss2_table.ySubscriptXOffset = file.get_i16();
    // writef(" ySubscriptXOffset | %08x - %d |\n", oss2_table.ySubscriptXOffset, oss2_table.ySubscriptXOffset);	
    oss2_table.ySubscriptYOffset = file.get_i16();	
    // writef(" ySubscriptYOffset | %08x - %d |\n", oss2_table.ySubscriptYOffset, oss2_table.ySubscriptYOffset);
    oss2_table.ySuperscriptXSize = file.get_i16();
    // writef(" ySuperscriptXSize | %08x - %d |\n", oss2_table.ySuperscriptXSize, oss2_table.ySuperscriptXSize);
    oss2_table.ySuperscriptYSize = file.get_i16();
    // writef(" ySuperscriptYSize | %08x - %d |\n", oss2_table.ySuperscriptYSize, oss2_table.ySuperscriptYSize);
    oss2_table.ySuperscriptXOffset = file.get_i16();
    // writef(" ySuperscriptXOffset | %08x - %d |\n", oss2_table.ySuperscriptXOffset, oss2_table.ySuperscriptXOffset);
    oss2_table.ySuperscriptYOffset = file.get_i16();
    // writef(" ySuperscriptYOffset | %08x - %d |\n", oss2_table.ySuperscriptYOffset, oss2_table.ySuperscriptYOffset);
    oss2_table.yStrikeoutSize = file.get_i16();
    // writef(" yStrikeoutSize | %08x - %d |\n", oss2_table.yStrikeoutSize, oss2_table.yStrikeoutSize);
    oss2_table.yStrikeoutPosition = file.get_i16();
    // writef(" yStrikeoutPosition | %08x - %d |\n", oss2_table.yStrikeoutPosition, oss2_table.yStrikeoutPosition);	
    oss2_table.sFamilyClass = file.get_i16();
    // writef(" sFamilyClass  | %08x - %d |\n", oss2_table.sFamilyClass , oss2_table.sFamilyClass );

    // PANOSE
    uint8_t	bFamilyType = file.get_u8();
    // writef(" bFamilyType  | %08x - %d |\n", bFamilyType , bFamilyType );
    uint8_t	bSerifStyle = file.get_u8();
    // writef(" bSerifStyle  | %08x - %d |\n", bSerifStyle , bSerifStyle );
    uint8_t	bWeight = file.get_u8();
    // writef(" bWeight  | %08x - %d |\n", bWeight , bWeight );
    uint8_t	bProportion = file.get_u8();
    uint8_t	bContrast = file.get_u8();
    uint8_t	bStrokeVariation = file.get_u8();
    uint8_t	bArmStyle = file.get_u8();
    uint8_t	bLetterform = file.get_u8();
    uint8_t	bMidline = file.get_u8();
    uint8_t	bXHeight = file.get_u8();

    oss2_table.ulUnicodeRange[0] = file.get_u32();
    oss2_table.ulUnicodeRange[1] = file.get_u32();
    oss2_table.ulUnicodeRange[2] = file.get_u32();
    oss2_table.ulUnicodeRange[3] = file.get_u32();

    oss2_table.achVendID[0] = file.get_i8();
    oss2_table.achVendID[1] = file.get_i8();
    oss2_table.achVendID[2] = file.get_i8();
    oss2_table.achVendID[3] = file.get_i8();

    oss2_table.fsSelection = file.get_u16();
    // writef(" fsSelection  | %08x - %d |\n", oss2_table.fsSelection, oss2_table.fsSelection );
    oss2_table.fsFirstCharIndex = file.get_u16();
    // writef(" fsFirstCharIndex  | %08x - %d |\n", oss2_table.fsFirstCharIndex , oss2_table.fsFirstCharIndex );
    oss2_table.fsLastCharIndex = file.get_u16();
    // writef(" fsLastCharIndex   | %08x - %d |\n", oss2_table.fsLastCharIndex , oss2_table.fsLastCharIndex );
    
    oss2_table.sTypoAscender = file.get_i16();
    oss2_table.sTypoDescender = file.get_i16();
    oss2_table.sTypoLineGap = file.get_i16();
    oss2_table.usWinAscent = file.get_u16();
    oss2_table.usWinDescent = file.get_u16();
    oss2_table.ulCodePageRange1 = file.get_u32();
    oss2_table.ulCodePageRange2 = file.get_u32();
    oss2_table.sxHeight = file.get_i16();
    oss2_table.sCapHeight = file.get_i16();
    // writef(" sCapHeight   | %08x - %d |\n", oss2_table.sCapHeight , oss2_table.sCapHeight );
    oss2_table.usDefaultChar = file.get_u16();
    oss2_table.usBreakChar = file.get_u16();
    oss2_table.usMaxContext = file.get_u16(); 
    oss2_table.usLowerPointSize = file.get_u16();
    oss2_table.usUpperPointSize = file.get_u16();	

    return oss2_table;
  }

  HEAD_table read_head_table(const ubyte[] buffer) {
    HEAD_table head_table;

    auto file = new Binary_Reader(buffer);
    file.seek(find_table("head").offset);

    head_table.ver = file.get_fixed();
    // writef(" ver | %08x - %d |\n", head_table.ver, head_table.ver);
    head_table.fontRevision = file.get_fixed();
    // writef(" fontRevision | %08x - %d |\n", head_table.fontRevision, head_table.fontRevision);
    head_table.checkSumAdjusment = file.get_u32();
    // writef(" checkSumAdjusment | %08x - %d |\n", head_table.checkSumAdjusment, head_table.checkSumAdjusment);
    head_table.magicNumber = file.get_u32();
    // writef(" | %d |\n", head_table.magicNumber);
    head_table.flags = file.get_u16();
    // writef(" | %d |\n", head_table.flags);
    head_table.unitsPerEm = file.get_u16();
    // writef(" | %d |\n", head_table.unitsPerEm);
    head_table.created = file.get_date();
    // writef(" | %s |\n", head_table.created);
    head_table.modified = file.get_date();
    // writef(" | %s |\n", head_table.modified);
    head_table.xMin = file.get_i16();
    // writef(" xMin | %08x - %d |\n", head_table.xMin, head_table.xMin);
    head_table.yMin = file.get_i16();
    // writef(" yMin | %08x - %d |\n", head_table.yMin, head_table.yMin);
    head_table.xMax = file.get_i16();
    // writef(" xMax | %08x - %d |\n", head_table.xMax, head_table.xMax);
    head_table.yMax = file.get_i16();
    // writef(" yMax | %08x - %d |\n", head_table.yMax, head_table.yMax);
  
    return head_table;
  }

  string find_glyph_index(wchar char_code) {
    string hex_char_code = dec_to_hexa(cast(int)char_code);
    // WHY????
    // writef(" READING %s \n", char_code);
    if(char_code == '•') {
      return dec_to_hexa(135);
    }
    if(char_code == 'Ё') {
      return dec_to_hexa(203);
    }
    if(char_code == 'ё') {
      return dec_to_hexa(115);
    }
    if(char_code == '«') {
      return dec_to_hexa(169);
    }
    if(char_code == '»') {
      return dec_to_hexa(170);
    }
    for(int i = 0; i < cmap.char_glyph_table.length; i++) {
      foreach (key, value; cmap.char_glyph_table[i])
      {
        if(key == hex_char_code) return value;
      }
    }

    return "";
  }

  int find_glyph_width(wchar char_to_find) {
    // writef(" searching %s\n", char_to_find);
    // string hex_char_code = dec_to_hexa(cast(int)char_code);
    try {
      string glyph_index = find_glyph_index(char_to_find);
      int dec_glyph_index = to!int(glyph_index, 16);
      int h = htmx.h_metrics[dec_glyph_index].advance_width;

      return h;
    } catch( ArrayIndexError e) {
      writef(" ERROR READING %s\n", char_to_find);
    }

    return 0;
  }
}