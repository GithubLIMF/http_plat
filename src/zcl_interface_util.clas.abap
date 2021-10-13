class ZCL_INTERFACE_UTIL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF tys_log_message,
          guid TYPE guid_32,
          head TYPE string,
          body TYPE string,
        END OF tys_log_message .
  types:
    BEGIN OF tys_inter_message,
          request  TYPE tys_log_message,
          response TYPE tys_log_message,
        END OF tys_inter_message .

  class-methods SAVE_INTERFACE_IN_MESSAGE
    importing
      value(IR_SERVER) type ref to IF_HTTP_SERVER
      !IS_INTER_INFO type ZSGD_INTER_INFO .
  class-methods SAVE_INTERFACE_OUT_MESSAGE
    importing
      value(IR_CLIENT) type ref to IF_HTTP_CLIENT
      value(IS_INTER_INFO) type ZSGD_INTER_INFO .
  class-methods READ_INTERFACE_MESSAGE_BS
    importing
      !IV_GUID type GUID_32
    returning
      value(RS_INTER_MESSAGE) type TYS_INTER_MESSAGE .
  class-methods READ_INTERFACE_MESSAGE
    importing
      !IV_GUID type GUID_32
    returning
      value(RS_INTER_MESSAGE) type TYS_INTER_MESSAGE .
  class-methods CREATE_GUID
    returning
      value(R_GUID_32) type GUID_32 .
  class-methods GET_HTML_WITH_XML
    importing
      !IV_XML type STRING
    returning
      value(RV_HTML) type STRING .
  class-methods GET_HTML_WITH_JSON
    importing
      !IV_JSON type STRING
    returning
      value(RV_HTML) type STRING .
  class-methods GEN_CRE_INFO
    changing
      !CS type ANY .
  class-methods GEN_UPD_INFO
    changing
      !CS type ANY .
protected section.
private section.

  types TY_HTTP_TYPE type ZE_INTER_BOUND .
  types:
*http 请求消息
    BEGIN OF tys_http_message,
      uri  TYPE char255,
      host TYPE char20,
      head TYPE string,
      body TYPE string,
    END OF tys_http_message .
  types:
    BEGIN OF tys_http_communication,
      http_type TYPE ty_http_type.
      INCLUDE TYPE zsgd_inter_info.
  TYPES: END OF tys_http_communication .

  constants GC_SERVER type TY_HTTP_TYPE value 'INBOUND' ##NO_TEXT.
  constants GC_CLIENT type TY_HTTP_TYPE value 'OUTBOUND' ##NO_TEXT.

  class-methods SAVE_MESSAGE
    importing
      value(IR_REQUEST) type ref to IF_HTTP_REQUEST
      value(IR_RESPONSE) type ref to IF_HTTP_RESPONSE
      value(IS_HTTP_COMMUNICATION) type TYS_HTTP_COMMUNICATION .
  class-methods GET_REQUEST_MESSAGE
    importing
      !IR_REQUEST type ref to IF_HTTP_REQUEST
    returning
      value(RS_HTTP_MESSAGE) type TYS_HTTP_MESSAGE .
  class-methods GET_RESPONSE_MESSAGE
    importing
      !IR_RESPONSE type ref to IF_HTTP_RESPONSE
    returning
      value(RS_HTTP_MESSAGE) type TYS_HTTP_MESSAGE .
  class-methods GET_NAME
    returning
      value(NAME) type STRING .
ENDCLASS.



CLASS ZCL_INTERFACE_UTIL IMPLEMENTATION.


  method CREATE_GUID.
      DATA:l_guid_16 TYPE SYSUUID_X16."16位二进制，显示32位字符串
*    CALL FUNCTION '/IBS/RB_GENERATE_GUID'
*      IMPORTING
*        ex_guid_16 = l_guid_16
*      EXCEPTIONS
*        failed     = 1
*        OTHERS     = 2.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*
*    ELSE.
  l_guid_16 = cl_system_uuid=>create_uuid_x16_static( ).
      r_guid_32 = l_guid_16.
*    ENDIF.

  endmethod.


  METHOD gen_cre_info.
    DEFINE lmc_assign.
      IF <lfs_fld> IS ASSIGNED.UNASSIGN <lfs_fld>.ENDIF.
      ASSIGN COMPONENT &1 OF STRUCTURE cs TO <lfs_fld> .
      IF <lfs_fld> IS ASSIGNED. <lfs_fld> = &2.UNASSIGN <lfs_fld>.ENDIF.
    end-of-definition.
    FIELD-SYMBOLS:<lfs_fld>    TYPE any.
    lmc_assign:'ERDAT' sy-datum,'ERTIM' sy-uzeit,'ERNAM' sy-uname.

  ENDMETHOD.


  METHOD gen_upd_info.
    DEFINE lmc_assign.
      IF <lfs_fld> IS ASSIGNED.UNASSIGN <lfs_fld>.ENDIF.
      ASSIGN COMPONENT &1 OF STRUCTURE cs TO <lfs_fld> .
      IF <lfs_fld> IS ASSIGNED. <lfs_fld> = &2.UNASSIGN <lfs_fld>.ENDIF.
    end-of-definition.
  ENDMETHOD.


  METHOD get_html_with_json.

    cl_demo_output=>write_json( json = iv_json  ).

    cl_demo_output=>get(
*      EXPORTING
*        data   = iv_json            " Text or Data
*        name   = 'JSON'
       RECEIVING
         output = rv_html            " Output
     ).

  ENDMETHOD.


  METHOD get_html_with_xml.
    cl_demo_output=>write_text( text = iv_xml  ).

    cl_demo_output=>get(
*      EXPORTING
*        data   = iv_json            " Text or Data
*        name   = 'JSON'
       RECEIVING
         output = rv_html            " Output
     ).


  ENDMETHOD.


  METHOD get_name.
    DATA: lt_stack TYPE abap_callstack,
          ls_stack TYPE LINE OF abap_callstack,
          lt_lines TYPE TABLE OF abap_callstack_line-line.
    CALL FUNCTION 'SYSTEM_CALLSTACK'
      IMPORTING
        callstack = lt_stack.
    DATA: idx TYPE sy-tabix.
    LOOP AT lt_stack INTO ls_stack WHERE mainprogram CS 'CL_DEMO_OUTPUT' ."##no_text ##INTO_OK.

      idx = sy-tabix.
    ENDLOOP.
    LOOP AT lt_stack INTO ls_stack FROM idx + 1 ."##INTO_OK.
      APPEND ls_stack-line TO lt_lines.
    ENDLOOP.
    READ TABLE lt_stack INTO ls_stack INDEX idx + 1.
*      TRY.
*          name = code_scan=>get_par_name( stack_frame = ls_stack
*                                          lines       = lt_lines ).
*        CATCH cx_name.
**        IF cl_abap_docu_system=>techdev = abap_true.
**          MESSAGE 'Notify owner of CL_DEMO_OUPUT' TYPE 'X' ##no_text.
**        ENDIF.
*          TRY.
*              name = introspection=>get_par_name( ls_stack ).
*            CATCH cx_name.
*              CLEAR name.
*          ENDTRY.
*      ENDTRY.
    TRY.
        name = code_analysis=>get_par_name( stack_frame = ls_stack
                                            lines       = lt_lines ).
      CATCH cx_name.
*        IF cl_abap_docu_system=>techdev = abap_true.
*          MESSAGE 'Notify owner of CL_DEMO_OUPUT' TYPE 'X' ##no_text.
*        ELSE.
        CLEAR name.
*        ENDIF.
    ENDTRY.

  ENDMETHOD.


  METHOD get_request_message.
    DATA:lt_header_fields TYPE tihttpnvp,
         ls_header_field  TYPE ihttpnvp.

    DATA:lv_lines TYPE i.

*获取 抬头数据
    ir_request->get_header_fields( CHANGING fields = lt_header_fields ).

    READ TABLE lt_header_fields INTO ls_header_field WITH KEY name = '~path'.
    IF sy-subrc EQ 0.
      rs_http_message-uri = ls_header_field-value.
    ENDIF.

    DESCRIBE TABLE lt_header_fields LINES lv_lines.


    rs_http_message-head = zcl_util_json=>serialize( data = lt_header_fields  ).

*获取BODY 数据
    rs_http_message-body = ir_request->get_cdata( ).

  ENDMETHOD.


  METHOD get_response_message.
    DATA:lt_header_fields TYPE tihttpnvp,
         ls_header_field  TYPE ihttpnvp.

    DATA:lv_lines TYPE i.

*获取 抬头数据
    ir_response->get_header_fields( CHANGING fields = lt_header_fields ).

    READ TABLE lt_header_fields INTO ls_header_field WITH KEY name = '~path'.
    IF sy-subrc EQ 0.
      rs_http_message-uri = ls_header_field-value.
    ENDIF.

    rs_http_message-head = zcl_util_json=>serialize( data = lt_header_fields  ).
*获取BODY 数据
    rs_http_message-body = ir_response->get_cdata( ).

  ENDMETHOD.


  METHOD read_interface_message.
    DATA:lt_ztgd0004 TYPE TABLE OF ztgd0004,
         ls_ztgd0004 TYPE ztgd0004.

    DATA:lv_value TYPE string.

    DATA:BEGIN OF ls_tab,
           line TYPE string,
         END OF ls_tab,
         lt_tab LIKE TABLE OF ls_tab.


    DEFINE get_html_with_json.
      CLEAR lv_value.
      LOOP AT lt_tab INTO ls_tab.
        lv_value = |{ lv_value } { ls_tab-line }|.
      ENDLOOP.

      &1 = get_html_with_json( iv_json =  lv_value ).

    END-OF-DEFINITION.
*取 请求
    SELECT * INTO TABLE lt_ztgd0004
      FROM ztgd0004
        WHERE relid EQ 'MH'
          AND ( guid  EQ iv_guid
                OR guid_request EQ iv_guid ).

    CHECK sy-subrc EQ 0.

*请求报文
    READ TABLE lt_ztgd0004 INTO ls_ztgd0004 WITH KEY guid_request = ''.
    IF sy-subrc EQ 0.
      DELETE lt_ztgd0004 INDEX sy-tabix.

      rs_inter_message-request-guid = ls_ztgd0004-guid.

      IMPORT mes_tab = lt_tab[]
        FROM DATABASE ztgd0004(mh)
          TO ls_ztgd0004
            ID ls_ztgd0004-guid.

      get_html_with_json  rs_inter_message-request-head.

      IMPORT mes_tab = lt_tab[]
        FROM DATABASE ztgd0004(mb)
          TO ls_ztgd0004
            ID ls_ztgd0004-guid.

      get_html_with_json rs_inter_message-request-body.
    ENDIF.

*响应报文
    READ TABLE lt_ztgd0004 INTO ls_ztgd0004 INDEX 1.
    IF sy-subrc EQ 0.

      rs_inter_message-response-guid = ls_ztgd0004-guid.

      IMPORT mes_tab = lt_tab[]
            FROM DATABASE ztgd0004(mh)
              TO ls_ztgd0004
                ID ls_ztgd0004-guid.

      get_html_with_json rs_inter_message-response-head.

      IMPORT mes_tab = lt_tab[]
        FROM DATABASE ztgd0004(mb)
          TO ls_ztgd0004
            ID ls_ztgd0004-guid.

      get_html_with_json rs_inter_message-response-body.
    ENDIF.

  ENDMETHOD.


  METHOD read_interface_message_bs.
    DATA:lt_ztgd0004 TYPE TABLE OF ztgd0004,
         ls_ztgd0004 TYPE ztgd0004.

    DATA:lv_value TYPE string.

    DATA:BEGIN OF ls_tab,
           line TYPE string,
         END OF ls_tab,
         lt_tab LIKE TABLE OF ls_tab.

    DEFINE get_html_with_json.
      CLEAR lv_value.
      LOOP AT lt_tab INTO ls_tab.
        lv_value = |{ lv_value } { ls_tab-line }|.
      ENDLOOP.

      &1 = get_html_with_json( iv_json =  lv_value ).

    END-OF-DEFINITION.
    DEFINE get_html_with_xml.
      CLEAR lv_value.
      LOOP AT lt_tab INTO ls_tab.
        lv_value = |{ lv_value } { ls_tab-line }|.
      ENDLOOP.

      &1 = get_html_with_xml( iv_xml =  lv_value ).

    END-OF-DEFINITION.
*取 请求
    SELECT * INTO TABLE lt_ztgd0004
      FROM ztgd0004
        WHERE relid EQ 'MH'
          AND ( guid  EQ iv_guid
                OR guid_request EQ iv_guid ).

    CHECK sy-subrc EQ 0.

*请求报文
    READ TABLE lt_ztgd0004 INTO ls_ztgd0004 WITH KEY guid_request = ''.
    IF sy-subrc EQ 0.
      DELETE lt_ztgd0004 INDEX sy-tabix.

      rs_inter_message-request-guid = ls_ztgd0004-guid.

      IMPORT mes_tab = lt_tab[]
        FROM DATABASE ztgd0004(mh)
          TO ls_ztgd0004
            ID ls_ztgd0004-guid.

      get_html_with_json  rs_inter_message-request-head.

      IMPORT mes_tab = lt_tab[]
        FROM DATABASE ztgd0004(mb)
          TO ls_ztgd0004
            ID ls_ztgd0004-guid.

      get_html_with_xml rs_inter_message-request-body.
    ENDIF.

*响应报文
    READ TABLE lt_ztgd0004 INTO ls_ztgd0004 INDEX 1.
    IF sy-subrc EQ 0.

      rs_inter_message-response-guid = ls_ztgd0004-guid.

      IMPORT mes_tab = lt_tab[]
            FROM DATABASE ztgd0004(mh)
              TO ls_ztgd0004
                ID ls_ztgd0004-guid.

      get_html_with_json rs_inter_message-response-head.

      IMPORT mes_tab = lt_tab[]
        FROM DATABASE ztgd0004(mb)
          TO ls_ztgd0004
            ID ls_ztgd0004-guid.

      get_html_with_xml rs_inter_message-response-body.
    ENDIF.


  ENDMETHOD.


  METHOD save_interface_in_message.

    DATA:ls_http_communication TYPE tys_http_communication.

    ls_http_communication-http_type = gc_server.
    MOVE-CORRESPONDING is_inter_info TO ls_http_communication.

    save_message(
      EXPORTING
        ir_request            = ir_server->request                 " HTTP Framework (iHTTP) HTTP Request
        ir_response           = ir_server->response                " HTTP Framework (iHTTP) HTTP Response
        is_http_communication = ls_http_communication              " 单字符标记
    )..

  ENDMETHOD.


  METHOD save_interface_out_message.

    DATA:ls_http_communication TYPE tys_http_communication.

    ls_http_communication-http_type = gc_client.
    MOVE-CORRESPONDING is_inter_info TO ls_http_communication.

    save_message(
      EXPORTING
        ir_request            = ir_client->request               " HTTP Framework (iHTTP) HTTP Request
        ir_response           = ir_client->response              " HTTP Framework (iHTTP) HTTP Response
        is_http_communication = ls_http_communication            " 单字符标记
    ).


  ENDMETHOD.


  METHOD SAVE_MESSAGE.

    DATA:ls_req_message  TYPE tys_http_message,
         ls_resp_message TYPE tys_http_message.

    DATA:ls_ztgd0004 TYPE ztgd0004.

    DATA:lv_guid1 TYPE guid_32,
         lv_guid2 TYPE guid_32.

    DATA:BEGIN OF ls_tab,
           line TYPE string,
         END OF ls_tab,
         lt_tab LIKE TABLE OF ls_tab.

    IF ir_request IS NOT INITIAL.
      CLEAR:ls_ztgd0004.
      ls_req_message = get_request_message( ir_request = ir_request ).
      lv_guid1 = create_guid( ).
      ls_ztgd0004-relid = 'MH'."message head
      ls_ztgd0004-guid = lv_guid1.
      ls_ztgd0004-ifname = ls_req_message-uri.
      ls_ztgd0004-inter_bound = is_http_communication-http_type.
      ls_ztgd0004-inter_code  = is_http_communication-inter_code.
      ls_ztgd0004-inter_msg_key  = is_http_communication-inter_msg_key.
      ls_ztgd0004-msgid  = is_http_communication-msgid.
      ls_ztgd0004-ret_code  = is_http_communication-ret_code.
      ls_ztgd0004-ret_msg   = is_http_communication-ret_msg.
      ls_ztgd0004-uname  = sy-uname.
      ls_ztgd0004-dats   = sy-datum.
      ls_ztgd0004-times  = sy-uzeit.
      GET TIME STAMP FIELD ls_ztgd0004-timestamp.
*保存 请求抬头数据
      CLEAR:lt_tab,ls_tab.
      MOVE ls_req_message-head TO ls_tab-line.
      APPEND ls_tab TO lt_tab.
      EXPORT mes_tab = lt_tab[]
        TO DATABASE ztgd0004(mh)
          FROM ls_ztgd0004
            ID ls_ztgd0004-guid.
*保存 请求BODY数据
      CLEAR:lt_tab,ls_tab.
      ls_ztgd0004-relid = 'MB'."message body
      MOVE ls_req_message-body TO ls_tab-line.
      APPEND ls_tab TO lt_tab.
      EXPORT mes_tab FROM lt_tab
        TO DATABASE ztgd0004(mb)
         FROM ls_ztgd0004
            ID ls_ztgd0004-guid.

      CALL FUNCTION 'DB_COMMIT'.
*      COMMIT WORK.
    ENDIF.

    IF ir_response IS NOT INITIAL.

      CLEAR:ls_ztgd0004.
      ls_resp_message = get_response_message( ir_response = ir_response ).
      lv_guid2 = create_guid( ).
      ls_ztgd0004-relid = 'MH'."message head
      ls_ztgd0004-guid = lv_guid2.
      ls_ztgd0004-guid_request = lv_guid1.
      ls_ztgd0004-ifname = ls_resp_message-uri.
      ls_ztgd0004-inter_bound = is_http_communication-http_type.
      ls_ztgd0004-inter_code  = is_http_communication-inter_code.
      ls_ztgd0004-inter_msg_key  = is_http_communication-inter_msg_key.
      ls_ztgd0004-msgid  = is_http_communication-msgid.
      ls_ztgd0004-ret_code  = is_http_communication-ret_code.
      ls_ztgd0004-ret_msg   = is_http_communication-ret_msg.
      ls_ztgd0004-uname  = sy-uname.
      ls_ztgd0004-dats   = sy-datum.
      ls_ztgd0004-times  = sy-uzeit.
      GET TIME STAMP FIELD ls_ztgd0004-timestamp.

*保存 响应抬头数据
      CLEAR:ls_tab,lt_tab.
      MOVE ls_resp_message-head TO ls_tab-line.
      APPEND ls_tab TO lt_tab.
      EXPORT mes_tab FROM lt_tab[]
        TO DATABASE ztgd0004(mh)
          FROM ls_ztgd0004
            ID ls_ztgd0004-guid.
*保存 响应BODY数据
      CLEAR:ls_tab,lt_tab.
      ls_ztgd0004-relid = 'MB'."message body
      MOVE ls_resp_message-body TO ls_tab-line.
      APPEND ls_tab TO lt_tab.
      EXPORT mes_tab FROM lt_tab[]
        TO DATABASE ztgd0004(mb)
          FROM ls_ztgd0004
            ID ls_ztgd0004-guid.

      CALL FUNCTION 'DB_COMMIT'.
*      COMMIT WORK.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
