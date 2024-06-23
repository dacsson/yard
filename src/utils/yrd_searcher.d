module yard.utils.yrd_searcher;

import std.file : exists;
import std.stdio : writef, writeln;

string[] MACOS_DEFAULT_FONT_PATHS = ["/System/Library/Fonts/", "/System/Library/Fonts/Supplemental/"];
string[] LINUX_DEFAULT_FONT_PATHS = ["/usr/share/fonts/", "~/.local/share/fonts/"];
string[] WIN_DEFAULT_FONT_PATHS   = [r"C:\Windows\Fonts\"];

class Searcher 
{
  static string find_font_path(string font_name)
  {
    version(OSX) 
    {
      foreach(string path; MACOS_DEFAULT_FONT_PATHS)
      {
        string file_name = path ~ font_name ~ ".ttf";
        // writef("FONT FOUND: %s", file_name);
        if(file_name.exists) 
        {
          return file_name;
        }
      }
    }
    version(linux) 
    {
      foreach(string path; LINUX_DEFAULT_FONT_PATHS)
      {
        string file_name = path ~ font_name ~ ".ttf";
        // writef("FONT FOUND: %s", file_name);
        if(file_name.exists) 
        {
          return file_name;
        }
      }
    }

    return "not found";
  }
}