*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 2020/06/03 at 13:40:11
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTGD0002........................................*
DATA:  BEGIN OF STATUS_ZTGD0002                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTGD0002                      .
CONTROLS: TCTRL_ZTGD0002
            TYPE TABLEVIEW USING SCREEN '2001'.
*.........table declarations:.................................*
TABLES: *ZTGD0002                      .
TABLES: ZTGD0002                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
