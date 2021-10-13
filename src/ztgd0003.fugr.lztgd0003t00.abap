*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 2020/06/03 at 11:04:35
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTGD0003........................................*
DATA:  BEGIN OF STATUS_ZTGD0003                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTGD0003                      .
CONTROLS: TCTRL_ZTGD0003
            TYPE TABLEVIEW USING SCREEN '2001'.
*.........table declarations:.................................*
TABLES: *ZTGD0003                      .
TABLES: ZTGD0003                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
