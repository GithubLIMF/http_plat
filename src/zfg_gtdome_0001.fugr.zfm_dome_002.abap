FUNCTION zfm_dome_002.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IS_DATA) TYPE  ZSGD_DOME_001
*"  EXPORTING
*"     REFERENCE(EV_MSGTYP) TYPE  STRING
*"     REFERENCE(EV_MSG) TYPE  STRING
*"----------------------------------------------------------------------
  DATA : lv_output TYPE string .
  DATA:lv_output_json TYPE string,
       lv_input_json  TYPE string,
       lv_type        TYPE char1,
       lv_dfxt        TYPE zd_dfxt,
       lv_code        TYPE char10,
       lv_message     TYPE char100.
  DATA : gs_return LIKE zgs_return .
  DATA : lt_header TYPE zstgd_header .
  DATA : ls_header TYPE zsgd_header .
  DATA:  ls_info TYPE zsgd_inter_info.
  lv_code = 'DEMO002' .
  zcl_util_json=>serialize(
       EXPORTING
           data             = is_data
           pretty_name      = zcl_ui2_json=>pretty_mode-camel_case
       RECEIVING
           r_json           = lv_output

     ).
  ls_info-inter_msg_key = is_data-matnr .
  ls_header-name = 'Content-Type'.
  ls_header-value = 'application/json'.
  APPEND ls_header TO lt_header.
  ls_header-name = 'code'.
  ls_header-value = 'DEMO001'.
  APPEND ls_header TO lt_header.
  CLEAR lv_dfxt.
  CALL METHOD zcl_interface_pan02=>post
    EXPORTING
      iv_code    = lv_code "
      it_header  = lt_header "非必输
      iv_input   = lv_output "代码
      iv_dfxt    = lv_dfxt  "系统账号密码代码
      is_info    = ls_info
    IMPORTING
      ev_type    = lv_type
      ev_message = lv_message
      ev_output  = lv_output_json.

  IF   lv_type = '0'.

*&  根据传入JSON解析成内表
    zcl_util_json=>deserialize(
      EXPORTING
          json             = lv_output_json
        CHANGING
          data             = gs_return

    ).
    ev_msgtyp = gs_return-CODE .
    ev_msg = gs_return-msg .
  ELSE .
    ev_msgtyp = lv_type .
    ev_msg = lv_message .
  ENDIF .

ENDFUNCTION.
