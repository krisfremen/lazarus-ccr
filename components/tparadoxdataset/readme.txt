================================================================================
                      TParadoxDataset for Lazarus
================================================================================

Current package can be found at: 
https://sourceforge.net/p/lazarus-ccr/svn/HEAD/tree/components/tparadoxdataset/

--------------------------------------------------------------------------------
                                 License
--------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at 
http://www.mozilla.org/MPL/

Alternatively, you may redistribute this library, use and/or modify it under the
terms of the GNU Lesser General Public License as published by the 
Free Software Foundation; either version 2.1 of the License, or (at your option) 
any later version.
You may obtain a copy of the LGPL at http://www.gnu.org/copyleft/.

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
specific language governing rights and limitations under the License.

--------------------------------------------------------------------------------
                                  Summary
--------------------------------------------------------------------------------
TParadoxDataSet is a TDataSet that can read (but not write!) Paradox files up 
to Version 7.

The motivation for having the component read-only is to provide a way to read 
old Pardox files for converting to newer database formats. 

The main characteristics are:

* Data-aware implementation, i.e. the component is a descendant of TDataset, 
  and you can use the standard data-aware Lazarus components to display the 
  table contents.
  
* All table levels up to version 7

* No external DLL needed (unlike the TParadox component that comes with 
  Lazarus). Works in 32- and 64-bit operating systems.
  
* Now supports BLOB fields, character encoding, filtering and bookmarks.

--------------------------------------------------------------------------------
                               Installation
--------------------------------------------------------------------------------
* If needed, unzip the files from the zip file to any directory.

* In Lazarus, open the package .lpk file with 
    "Package" > "Open package file (.lpk)". 
  In v0.2 there are two packages; both have the same content, but 
  lazparadox.lpk has a naming conflict with the Paradox package contained 
  in the Lazarus distribution; therefore it is recommended to install 
  lazparadoxpkg.lpk instead.
  
* If you don't want to install the component into the IDE, click on "Compile".

* If you want to install the component into the IDE, click on "Use" > "Install". 
  Confirm the prompt to rebuild the IDE. When Lazarus restarts you'll find the 
  component TParadoxDataset on palette "Data Access".
  
--------------------------------------------------------------------------------
                                   Usage
--------------------------------------------------------------------------------
* Drop the TParadoxDataset component on the form.
    
* Specify the name of the table file (extension ".db") in property TableName
    
* Set Active to true in order to open the table. When, for example, a DBGrid 
  is linked to the dataset the table is immediately displayed.
    
* The encoding of text fields used in the file is displayed in the read-only 
  property InputEncoding. It is automatically converted to the encoding given 
  in property TargetEncoding which defaults to "UTF8". In the case that text 
  fields must be encoded differently specify the codepage name here, e.g. 
  "CP1252" for Western Europe code page (use the (case-insensitive) names 
  given in the LazUtils unit lconvencoding).
    
* Filtering: Set Filtered to false. Then define the filter conditon in property 
  Filter or use the OnFilterRecord event. Finally start the filtering action
  by setting Filtered to true.
    
* Bookmarks: Store the currently active record as a bookmark by setting the 
  variable bookmark (which is of type TBookmark to ParadoxDataset1.GetBookmark. 
  For returning to this record, call ParadoxDataset1.GotoBookmark(boomark). 
  Since the component uses the RecNo as bookmarks it is not required to call 
  FreeBookmark.

