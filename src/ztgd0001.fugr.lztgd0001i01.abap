*----------------------------------------------------------------------*
***INCLUDE LZTGD0001I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  LISTE_UPDATE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE liste_update_data INPUT.
  IF ztgd0001-erdat IS INITIAL
   OR  ztgd0001-erdim IS INITIAL
   OR  ztgd0001-ernam IS INITIAL .
    ztgd0001-erdat = sy-datum .
    ztgd0001-erdim = sy-uzeit .
    ztgd0001-ernam = sy-uname .
  ENDIF.
  ztgd0001-aedat = sy-datum .
  ztgd0001-aetim = sy-uzeit .
  ztgd0001-aenam = sy-uname .
ENDMODULE.
