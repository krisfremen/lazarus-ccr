-------------------------------------------------------------------------------
                                  fixlp                                        
-------------------------------------------------------------------------------

In Lazarus v2.1 a new structure of the xml files (*.lpi, *.lps, *.lpk) was
introduced. It replaces the numbered xml nodes used in older versions by
unnumbered nodes.

While Lazarus v2.1 can read both types of file formats and can also convert 
between them, older versions cannot read the new structure correctly leading
to a lot of difficult-to-understand errors when trying to compile.

fixlp is a small utility program for Lazarus versions before v2.1 and
converts the new Lazarus xml file format to the format used by older 
versions.


Syntax:
  fixlp <filename1> [, <filename2> [, ...]]
  
<filename1,2,...> are the names of the Lazarus .lpi, .lps or .lpk files 
(with absolute or relative path) to be converted. 

Wildcards are allowed.