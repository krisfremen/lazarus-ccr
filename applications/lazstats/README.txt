--------------------------------------------------------------------------------
LazStats
--------------------------------------------------------------------------------
Clone of the LazStats statistics application by William Miller 
(https://openstat.info/LazStatsMain.htm)

What is different?
------------------
- Updated form layout. More consistent user interface. Use anchoring and 
  autosizing to avoid widgetset-dependent layout issues.
- Input validation for more robust user interface.
- Move units into subfolders for each major menu command in order to avoid the 
  extremely long file list in the project manager.
- Include data and documentation folders of the original site. 
  Add missing data files from the OpenStat application mentioned in the 
  pdf help files.
- Create chm help from the original pdf help files of the original site,
  tool used: HelpNDoc.
- Refactoring of code to write text output into a TStringList instead of to 
  the memo of TOutputFrm directly.

License
-------
William Miller writes in file "html/introduction.pdf":

  "While I reserve the copyright protection of these packages, I make no 
  restriction on their distribution or use. It is common courtesy, of course, 
  to give me credit if you use these resources. Because I do not warrant them 
  in any manner, you should insure yourself that the routines you use are 
  adequate for your purposes."

License displayed by program:
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.        *
 *                                                                         *
 ***************************************************************************
