class ZCL_INTERFACE_PAN02 definition
  public
  final
  create public .

public section.

  class-methods POST
    importing
      !IV_CODE type CHAR10
      !IT_HEADER type ZSTGD_HEADER optional
      !IV_INPUT type STRING
      !IV_DFXT type ZD_DFXT optional
      !IS_INFO type ZSGD_INTER_INFO
    exporting
      !EV_TYPE type CHAR1
      !EV_MESSAGE type CHAR100
      !EV_OUTPUT type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INTERFACE_PAN02 IMPLEMENTATION.


  METHOD post.
    DATA:lw_ztgd0001 TYPE ztgd0001,
         lw_ztgd0002 TYPE ztgd0002,
         lw_header   TYPE zsgd_header,
         lv_url      TYPE string,
         lv_username TYPE string,
         lv_password TYPE string.

    DATA:ls_inter_info TYPE zsgd_inter_info.

*接口通用返回结构
    DATA:BEGIN OF ls_ret,
           code(1)      TYPE c,
           msg(255)     TYPE c,
           message(255) TYPE c,
         END OF ls_ret.

    MOVE-CORRESPONDING is_info TO ls_inter_info.
    IF ls_inter_info-inter_code IS INITIAL.
      ls_inter_info-inter_code = iv_code.
    ENDIF.
**********************************************************************
**  获取对方系统URL
    IF iv_code IS NOT INITIAL.
      SELECT SINGLE * INTO lw_ztgd0001 FROM ztgd0001 WHERE code = iv_code.
      IF lw_ztgd0001-url IS INITIAL.
        ev_type = '1'.
        ev_message = '未维护服务提供方服务地址---ZTGD0001'.
*        ls_inter_info-ret_code = '1'.
*        ls_inter_info-ret_msg  = ev_message.
*        zcl_interface_util=>save_interface_out_message( ir_client = lo_client
*                                                        is_inter_info = ls_inter_info
*         ).
        EXIT.
      ENDIF.
    ENDIF.
    lv_url = lw_ztgd0001-url.
    cl_http_client=>create_by_url(
        EXPORTING url = lv_url    "服务提供方服务地址
        IMPORTING client  =  DATA(lo_client)
      ).

**********************************************************************
**  获取对方系统网关appid
    IF iv_dfxt IS NOT INITIAL.
      SELECT SINGLE * INTO lw_ztgd0002 FROM ztgd0002 WHERE dfxt = iv_dfxt.
      IF lw_ztgd0002-username IS INITIAL OR lw_ztgd0002-password IS INITIAL.
        ev_type = '1'.
        ev_message = '未维护服务提供方appid/keysecre---ZTGD0002'.
        ls_inter_info-ret_code = '1'.
        ls_inter_info-ret_msg  = ev_message.
        zcl_interface_util=>save_interface_out_message( ir_client = lo_client
                                                        is_inter_info = ls_inter_info
                                                       ).
        EXIT.
      ENDIF.
    ENDIF.

    IF ev_type NE 'E'.

    ENDIF.
    lv_username = lw_ztgd0002-username.
    lv_password = lw_ztgd0002-password.

**********************************************************************
**  确定调用方法
    IF lw_ztgd0001-method EQ 'GET'.
      lo_client->request->set_method( if_http_request=>co_request_method_get ).
    ELSEIF lw_ztgd0001-method EQ 'POST'.
      lo_client->request->set_method( if_http_request=>co_request_method_post ).
**********************************************************************
**  设置post接口body参数
      lo_client->request->set_cdata( data = iv_input ).
    ENDIF.

**********************************************************************
**  设置权限
    IF NOT lv_username IS INITIAL  AND NOT lv_password IS INITIAL .

      lo_client->request->set_authorization(
        EXPORTING
*    auth_type = 1                " Authorization Type (see ihttp_auth_type_*)
          username  = lv_username        " User Name
          password  = lv_password     " Password
      ).

    ENDIF.
**********************************************************************
**  设置网关需要的appid
    CALL METHOD lo_client->request->set_header_field
      EXPORTING
        name  = 'appID'
        value = lv_username. "发送字符串时只能用utf-8编码

**********************************************************************
**  设置接口header
    LOOP AT it_header INTO lw_header.
      CALL METHOD lo_client->request->set_header_field
        EXPORTING
          name  = lw_header-name
          value = lw_header-value. "发送字符串时只能用utf-8编码

      CLEAR:lw_header.
    ENDLOOP.

**********************************************************************
**  发送数据
    lo_client->send(
*      EXPORTING
*        timeout                    = co_timeout_default " Timeout of Answer Waiting Time
      EXCEPTIONS
        http_communication_failure = 1                  " Communication Error
        http_invalid_state         = 2                  " Invalid state
        http_processing_failed     = 3                  " Error When Processing Method
        http_invalid_timeout       = 4                  " Invalid Time Entry
        OTHERS                     = 5
    ).
    IF sy-subrc <> 0.
      ev_message = '接口访问失败'.
      ev_type = '1'.
      ls_inter_info-ret_code = '1'.
      ls_inter_info-ret_msg  = ev_message.
      zcl_interface_util=>save_interface_out_message( ir_client = lo_client
                                                      is_inter_info = ls_inter_info
                                                     ).
      EXIT.
    ENDIF.

**********************************************************************
**  接收返回参数
    lo_client->receive(
      EXCEPTIONS
        http_communication_failure = 1                " Communication Error
        http_invalid_state         = 2                " Invalid state
        http_processing_failed     = 3                " Error When Processing Method
        OTHERS                     = 4
    ).
    IF sy-subrc <> 0.
      ev_message = '接口接受响应失败'.
      ev_type = '1'.
      ls_inter_info-ret_code = '1'.
      ls_inter_info-ret_msg  = ev_message.
      zcl_interface_util=>save_interface_out_message( ir_client = lo_client
                                                      is_inter_info = ls_inter_info
                                                     ).
      EXIT.
    ENDIF.

    ev_output = lo_client->response->get_cdata( ).
    zcl_util_json=>deserialize(
      EXPORTING
        json             = ev_output
      CHANGING
        data             = ls_ret
    ).

*响应报文信息
    ls_inter_info-ret_code = ls_ret-code.
    ls_inter_info-zproc_stat = ls_ret-code.
*    ls_inter_info = lw_ztgd0001-url .
    IF ls_ret-msg IS NOT INITIAL.
      ls_inter_info-ret_msg  = ls_ret-msg.
    ELSEIF ls_ret-message IS NOT INITIAL.
      ls_inter_info-ret_msg  = ls_ret-message.
    ENDIF.
    zcl_interface_util=>save_interface_out_message( ir_client = lo_client
                                                    is_inter_info = ls_inter_info
                                                  ).

**********************************************************************
**  关闭通道
    IF sy-subrc = 0 .
      lo_client->close(
        EXCEPTIONS
          http_invalid_state = 1                " Invalid state
          OTHERS             = 2
      ).
      IF sy-subrc <> 0.
        ev_message = '接口链接关闭失败'.
        ev_type = '1'.
        ls_inter_info-ret_code = '1'.
        ls_inter_info-ret_msg  = ev_message.
        zcl_interface_util=>save_interface_out_message( ir_client = lo_client
                                                        is_inter_info = ls_inter_info
                                                       ).
        EXIT.
      ENDIF..
      ev_type = '0'.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
