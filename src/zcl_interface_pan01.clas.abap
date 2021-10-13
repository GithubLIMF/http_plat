class ZCL_INTERFACE_PAN01 definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INTERFACE_PAN01 IMPLEMENTATION.


  METHOD if_http_extension~handle_request.
    " Log Start
*    DATA(gv_start) = zcl_util_common=>gen_se16n_id( ).
    DATA: gv_start TYPE i.
    GET RUN TIME FIELD gv_start.

*    zcl_util_log=>gs_flg-is_rest_call = abap_true.
*    zcl_util_log=>log_init( ).
*    zcl_util_log=>log_intf_hub( i_code = 'ENTER' i_msg = 'Enter' ).

*    DATA(lo_tool) = zcl_util=>getcommon( ).
    DATA: lo_req TYPE REF TO if_http_request,
          lo_res TYPE REF TO if_http_response.
    DATA: lv_method TYPE string.
    lo_req = server->request.
    lo_res = server->response.
    lv_method = lo_req->get_method( ).

    DATA: lv_input TYPE string.
    DATA:lv_data TYPE string.
    DATA:lv_output TYPE string.

    DATA lv_code TYPE string.
    DATA: lo_header_fields TYPE tihttpnvp.
*    lo_header_fields = VALUE tihttpnvp( ).
*    lo_header_fields = tihttpnvp.

    "待确定
    DATA:BEGIN OF ls_ret,
           msg_id TYPE char01,
           code   TYPE string,
           msg    TYPE char100,
*           data   TYPE string,
         END OF ls_ret.


    DATA:ls_inter_info TYPE zsgd_inter_info.

    lo_res->set_status( code = 200 reason = 'Ok' ).
    lo_res->set_content_type( 'application/json' ).


*    DATA(tttt) = VALUE tihttpnvp( ).
    DATA: tttt TYPE tihttpnvp.

*    IF 1 = 1."测试(逻辑替换)
*      lo_req->get_header_fields( CHANGING fields =   tttt ).
*      lo_res->append_cdata( data = zcl_util=>getjson( )->serialize( data = tttt  ) ).
**    EXIT.
*    ELSE.
    IF lv_method EQ 'POST'.
      "获取body部分
      lv_input = lo_req->get_cdata( ).

      "获取路径中的code,用以区分具体调用哪个处理方法
      lo_req->get_header_fields( CHANGING fields =   lo_header_fields ).
      DATA: ls_header_field TYPE ihttpnvp.
      READ TABLE lo_header_fields INTO ls_header_field WITH KEY name = 'code'.
      IF sy-subrc EQ 0.
*        REPLACE FIRST OCCURRENCE OF '/' IN ls_header_field-value WITH space.
        lv_code = ls_header_field-value.
        TRANSLATE lv_code TO UPPER CASE.
      ENDIF.

      "没有获取到code，无法判断业务场景，报错
      IF lv_code IS INITIAL.
        ls_ret-code     = '1'.
        ls_ret-msg  = '缺少参数：CODE'.
*        lo_res->append_cdata( data = zcl_util=>getjson( )->serialize( data = ls_ret ) ).
*        RETURN.
        " Log Error
*        zcl_util_log=>log_intf_hub( i_code = 'ERROR' i_stat = zcl_global=>cs-log-stat-error i_msg =  ls_ret-msg ).
      ENDIF.

      "没有维护code对应的方法名，无法具体处理，报错
      IF ls_ret IS INITIAL.
        IF lv_code IS NOT INITIAL.
          DATA: ls_map TYPE ztgd0003.
          SELECT SINGLE * FROM ztgd0003 INTO ls_map WHERE code = lv_code .
          IF sy-subrc <> 0.
            ls_ret-code     = '1'.
            ls_ret-msg  = |未找到CODE({ lv_code })对应处理函数|.
            " Log Error
*            zcl_util_log=>log_intf_hub( i_code = CONV #( lv_code ) i_stat = zcl_global=>cs-log-stat-error i_msg = CONV #( ls_ret-msg ) ).
          ENDIF.
        ELSE.
          ls_ret-code     = '1'.
          ls_ret-msg  = |服务异常|.

          " 消息处理重复，不log
        ENDIF.

      ENDIF.


*      DATA(lt_paras) = VALUE abap_parmbind_tab(
*        ( name = 'INP'      kind = cl_abap_objectdescr=>exporting   value = REF #( lv_input ) )
*        ( name = 'R_RET'    kind = cl_abap_objectdescr=>receiving   value = REF #( lv_output ) )
*      ).
      IF ls_ret IS INITIAL.

        CALL FUNCTION ls_map-clas
          EXPORTING
            iv_input  = lv_input
          IMPORTING
            es_info   = ls_inter_info
            ev_output = lv_data.

      ENDIF.

      IF lv_data IS NOT INITIAL.
        lv_output = lv_data.

      ENDIF.

*      lo_res->append_cdata( data = lv_output ).
    ELSE.
      ls_ret-code       = '1'.
      ls_ret-msg    = '请用POST方式进行提交'.

    ENDIF.
*    ENDIF.


    IF lv_output IS NOT INITIAL.
      lo_res->append_cdata( data = lv_output ).
    ELSE.
      lv_output = zcl_util_json=>serialize( data = ls_ret ).
      lo_res->append_cdata( data = lv_output ).
    ENDIF.
    IF NOT ls_ret-code IS INITIAL.
      ls_inter_info-ret_code   = ls_ret-code."响应报文的code
      ls_inter_info-ret_msg    = ls_ret-msg."响应报文的code
*    ELSE.
*      ls_inter_info-ret_code   = ls_inter_info-ret_code."响应报文的code
*      ls_inter_info-ret_msg    = '接口响应成功！'."响应报文的code
    ENDIF.
    ls_inter_info-inter_code = lv_code.


*记录日志
    zcl_interface_util=>save_interface_in_message( ir_server = server
                                                   is_inter_info = ls_inter_info
     ).

    " Log End
*    GET RUN TIME FIELD data(gv_end).
**    DATA(gv_end) = zcl_util_common=>gen_se16n_id( ).
*    DATA(gv_offset) = CONV se16n_id( ( gv_end - gv_start ) / 1000 / '1000.0' ).
*    zcl_util_log=>log_intf_hub( i_code = CONV #( lv_code ) i_msg = 'End' i_se16n_id = gv_offset ).


  ENDMETHOD.
ENDCLASS.
