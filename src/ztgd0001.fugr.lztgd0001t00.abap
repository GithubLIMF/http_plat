*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 2020/06/03 at 15:09:51
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTGD0001........................................*
DATA:  BEGIN OF STATUS_ZTGD0001                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTGD0001                      .
CONTROLS: TCTRL_ZTGD0001
            TYPE TABLEVIEW USING SCREEN '2001'.
*.........table declarations:.................................*
TABLES: *ZTGD0001                      .
TABLES: ZTGD0001                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
