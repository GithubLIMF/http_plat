*----------------------------------------------------------------------*
***INCLUDE LZTGD0002I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  LISTE_UPDATE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE liste_update_data INPUT.
  IF ztgd0002-erdat IS INITIAL
   OR  ztgd0002-erdim IS INITIAL
   OR  ztgd0002-ernam IS INITIAL .
    ztgd0002-erdat = sy-datum .
    ztgd0002-erdim = sy-uzeit .
    ztgd0002-ernam = sy-uname .
  ENDIF.
  ztgd0002-aedat = sy-datum .
  ztgd0002-aetim = sy-uzeit .
  ztgd0002-aenam = sy-uname .
ENDMODULE.
