FUNCTION zfm_dome_001.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IV_INPUT) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(ES_INFO) TYPE  ZSGD_INTER_INFO
*"     REFERENCE(EV_OUTPUT) TYPE  STRING
*"----------------------------------------------------------------------
  DATA : gs_return TYPE zgs_return .
  DATA : ls_data TYPE zsgd_dome_001 .

*&  根据传入JSON解析成内表 内表需要自定义，最好以结构为主
  zcl_util_json=>deserialize(
    EXPORTING
        json             = iv_input
      CHANGING
        data             = ls_data

  ).
*解析后的逻辑处理
  IF NOT ls_data IS INITIAL .
    es_info-inter_msg_key = ls_data-matnr .
    es_info-zproc_stat = '0' .
    es_info-ret_code = '0' .
    es_info-ret_msg = '数据接受成功！' .
    gs_return-code = '0' .
    gs_return-msg = '数据接受成功！' .
  ELSE .
    es_info-zproc_stat = '1' .
    es_info-ret_code = '1' .
    es_info-ret_msg = '请传输数据！' .
    gs_return-code = '1' .
    gs_return-msg = '请传输数据！' .
  ENDIF.

*返还逻辑处理后结果并转换报文
  zcl_util_json=>serialize(
       EXPORTING
           data             = gs_return
           pretty_name      = zcl_ui2_json=>pretty_mode-camel_case
       RECEIVING
           r_json           = ev_output

     ).


ENDFUNCTION.
