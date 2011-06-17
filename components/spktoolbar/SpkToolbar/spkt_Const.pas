unit spkt_Const;

(*******************************************************************************
*                                                                              *
*  Plik: spkt_Const.pas                                                        *
*  Opis: Sta�e wykorzystywane do obliczania geometrii toolbara                 *
*  Copyright: (c) 2009 by Spook. Jakiekolwiek u�ycie komponentu bez            *
*             uprzedniego uzyskania licencji od autora stanowi z�amanie        *
*             prawa autorskiego!                                               *
*                                                                              *
*******************************************************************************)

interface

const // ****************
      // *** Elementy ***
      // ****************

      LARGEBUTTON_DROPDOWN_FIELD_SIZE = 29;
      LARGEBUTTON_GLYPH_MARGIN = 1;
      LARGEBUTTON_CAPTION_HMARGIN = 3;
      LARGEBUTTON_MIN_WIDTH = 24;
      LARGEBUTTON_RADIUS = 4;
      LARGEBUTTON_BORDER_SIZE = 2;
      LARGEBUTTON_CHEVRON_HMARGIN = 4;
      LARGEBUTTON_CAPTION_TOP_RAIL = 45;
      LARGEBUTTON_CAPTION_BOTTOM_RAIL = 58;

      SMALLBUTTON_GLYPH_WIDTH = 16;
      SMALLBUTTON_BORDER_WIDTH = 2;
      SMALLBUTTON_HALF_BORDER_WIDTH = 1;
      SMALLBUTTON_PADDING = 2;
      SMALLBUTTON_DROPDOWN_WIDTH = 11;
      SMALLBUTTON_RADIUS = 4;
      SMALLBUTTON_MIN_WIDTH = 2 * SMALLBUTTON_PADDING + SMALLBUTTON_GLYPH_WIDTH;

      // ********************
      // *** Obszar tafli ***
      // ********************

      /// <summary>Maksymalna wysoko�� obszaru, kt�ry mo�e zaj�� zawarto��
      /// tafli z elementami</summary>
      MAX_ELEMENT_HEIGHT = 67;

      /// <summary>Wysoko�� pojedynczego wiersza element�w tafli</summary>
      PANE_ROW_HEIGHT = 22;

      PANE_FULL_ROW_HEIGHT = 3 * PANE_ROW_HEIGHT;

      /// <summary>Wewn�trzny pionowy margines pomi�dzy pierwszym elementem a
      /// tafl� w przypadku wersji jednowierszowej</summary>
      PANE_ONE_ROW_TOPPADDING = 22;
      /// <summary>Wewn�trzny pionowy margines pomi�dzy ostatnim elementem
      /// a tafl� w przypadku wersji jednowierszowej</summary>
      PANE_ONE_ROW_BOTTOMPADDING = 23;

      /// <summary>Odleg�o�� pomi�dzy wierszami w przypadku wersji dwuwierszowej
      /// </summary>
      PANE_TWO_ROWS_VSPACER = 7;
      /// <summary>Wewn�trzny pionowy margines pomi�dzy pierwszym elementem a
      /// tafl� w przypadku wersji dwuwierszowej</summary>
      PANE_TWO_ROWS_TOPPADDING = 8;
      /// <summary>Wewn�trzny pionowy margines pomi�dzy ostatnim elementem
      /// a tafl� w przypadku wersji dwuwierszowej</summary>
      PANE_TWO_ROWS_BOTTOMPADDING = 8;

      /// <summary>Odleg�o�� pomi�dzy wierszami w przypadku wersji
      /// trzywierszowej</summary>
      PANE_THREE_ROWS_VSPACER = 0;
      /// <summary>Wewn�trzny pionowy margines pomi�dzy pierwszym elementem a
      /// tafl� w przypadku wersji trzywierszowej</summary>
      PANE_THREE_ROWS_TOPPADDING = 0;
      /// <summary>Wewn�trzny pionowy margines pomi�dzy ostatnim elementem
      /// a tafl� w przypadku wersji trzywierszowej</summary>
      PANE_THREE_ROWS_BOTTOMPADDING = 1;

      PANE_FULL_ROW_TOPPADDING = PANE_THREE_ROWS_TOPPADDING;

      PANE_FULL_ROW_BOTTOMPADDING = PANE_THREE_ROWS_BOTTOMPADDING;

      /// <summary>Odleg�o�� pomi�dzy lew� kraw�dzi� a pierwszym elementem
      /// tafli</summary>
      PANE_LEFT_PADDING = 2;

      /// <summary>Odleg�o�� pomi�dzy ostatnim elementem tafli a praw� kraw�dzi�
      /// </summary>
      PANE_RIGHT_PADDING = 2;

      /// <summary>Odleg�o�� pomi�dzy dwoma kolumnami wewn�trz tafli</summary>
      PANE_COLUMN_SPACER = 4;

      /// <summary>Odleg�o�� pomi�dzy dwoma osobnymi grupami wewn�trz wiersza
      /// w tafli</summary>
      PANE_GROUP_SPACER = 4;

      // *************
      // *** Tafla ***
      // *************

      /// <summary>Wysoko�� obszaru tytu�u tafli</summary>
      PANE_CAPTION_HEIGHT = 15;

      PANE_CORNER_RADIUS = 3;

      /// <summary>Szeroko��/wysoko�� ramki tafli</summary>
      /// <remarks>Nie nale�y zmienia� tej sta�ej!</remarks>
      PANE_BORDER_SIZE = 2;

      /// <summary>Po�owa szeroko�ci ramki tafli</summary>
      /// <remarks>Nie nale�y zmienia� tej sta�ej!</remarks>
      PANE_BORDER_HALF_SIZE = 1;

      /// <summary>Wysoko�� ca�ej tafli (uwzgl�dniaj�c ramk�)</summary>
      PANE_HEIGHT = MAX_ELEMENT_HEIGHT + PANE_CAPTION_HEIGHT + 2 * PANE_BORDER_SIZE;

      /// <summary>Poziomy margines etykiety zak�adki</summary>
      PANE_CAPTION_HMARGIN = 6;

      // ***********************
      // *** Obszar zak�adki ***
      // ***********************

      /// <summary>Promie� zaokr�glenia zak�adki</summary>
      TAB_CORNER_RADIUS = 4;

      /// <summary>Lewy wewn�trzny margines zak�adki</summary>
      TAB_PANE_LEFTPADDING = 2;
      /// <summary>Prawy wewn�trzny margines zak�adki</summary>
      TAB_PANE_RIGHTPADDING = 2;
      /// <summary>G�rny wewn�trzny margines zak�adki</summary>
      TAB_PANE_TOPPADDING = 2;
      /// <summary>Dolny wewn�trzny margines zak�adki</summary>
      TAB_PANE_BOTTOMPADDING = 1;
      /// <summary>Odleg�o�� pomi�dzy taflami</summary>
      TAB_PANE_HSPACING = 3;

      /// <summary>Szeroko��/wysoko�� ramki zak�adki (nie nale�y zmienia�!)
      /// </summary>
      TAB_BORDER_SIZE = 1;
      /// <summary>Wysoko�� zak�adki</summary>
      TAB_HEIGHT = PANE_HEIGHT + TAB_PANE_TOPPADDING + TAB_PANE_BOTTOMPADDING + TAB_BORDER_SIZE;

      // ***************
      // *** Toolbar ***
      // ***************

      TOOLBAR_BORDER_WIDTH = 1;

      TOOLBAR_CORNER_RADIUS = 3;

      /// <summary>Wysoko�� etykiet z nazwami zak�adek</summary>
      TOOLBAR_TAB_CAPTIONS_HEIGHT = 22;
      /// <summary>Poziomy margines wewn�trznego tytu�u zak�adki</summary>
      TOOLBAR_TAB_CAPTIONS_TEXT_HPADDING = 4;

      TOOLBAR_MIN_TAB_CAPTION_WIDTH = 32;

      /// <summary>Sumaryczna wysoko�� toolbara</summary>
      TOOLBAR_HEIGHT = TOOLBAR_TAB_CAPTIONS_HEIGHT +
                       TAB_HEIGHT;

implementation

initialization

{$IFDEF DEBUG}
// Sprawdzanie poprawno�ci

// �uk du�ego przycisku
assert(LARGEBUTTON_RADIUS * 2 <= LARGEBUTTON_DROPDOWN_FIELD_SIZE);

// Tafla, wersja z jednym wierszem
assert(PANE_ROW_HEIGHT +
       PANE_ONE_ROW_TOPPADDING +
       PANE_ONE_ROW_BOTTOMPADDING <= MAX_ELEMENT_HEIGHT);

// Tafla, wersja z dwoma wierszami
assert(2*PANE_ROW_HEIGHT +
       PANE_TWO_ROWS_TOPPADDING +
       PANE_TWO_ROWS_VSPACER +
       PANE_TWO_ROWS_BOTTOMPADDING <= MAX_ELEMENT_HEIGHT);

// Tafla, wersja z trzema wierszami
assert(3*PANE_ROW_HEIGHT +
       PANE_THREE_ROWS_TOPPADDING +
       2*PANE_THREE_ROWS_VSPACER +
       PANE_THREE_ROWS_BOTTOMPADDING <= MAX_ELEMENT_HEIGHT);
{$ENDIF}

end.
