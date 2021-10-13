*----------------------------------------------------------------------*
***INCLUDE LZTGD0003I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  LISTE_UPDATE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE liste_update_data INPUT.
IF ztgd0003-erdat IS INITIAL
   OR  ztgd0003-erdim IS INITIAL
   OR  ztgd0003-ernam IS INITIAL .
    ztgd0003-erdat = sy-datum .
    ztgd0003-erdim = sy-uzeit .
    ztgd0003-ernam = sy-uname .
  ENDIF.
  ztgd0003-aedat = sy-datum .
  ztgd0003-aetim = sy-uzeit .
  ztgd0003-aenam = sy-uname .
ENDMODULE.
