*&---------------------------------------------------------------------*
*& Report ZDEMO_ALV_GRID
*&---------------------------------------------------------------------*
*&
*& Developer       : IBM_YUANY
*& Consultant      :
*& Date            : 20190613
*& FS Number       :
*& Batch Job Name  :
*&---------------------------------------------------------------------*
* Logical Explication
*&---------------------------------------------------------------------*
* Description:
*&---------------------------------------------------------------------*
*              MODIFICATION HISTORY :
*Developer        Consultant     Date            IL#        Transport
* 开发XXX        业务XXX     日期             任务编号    请求号
*
* Description:
*&---------------------------------------------------------------------*
REPORT zgdrp0001.
TABLES:zsgd_inter_info.

TYPES:ty_msg_type TYPE char10.

TYPES:tys_outtab TYPE zsgd_zgdrp0001,
      tyt_outtab TYPE TABLE OF tys_outtab.

TYPES:BEGIN OF tys_message,
        type TYPE ty_msg_type,
        guid TYPE guid_32,
        head TYPE string,
        body TYPE string,
      END OF tys_message,
      tyt_message TYPE TABLE OF tys_message.


CONSTANTS:c_req TYPE ty_msg_type VALUE 'REQUEST',
          c_res TYPE ty_msg_type VALUE 'RESPONSE'.

DATA:gt_outtab   TYPE tyt_outtab,
     gt_edit     TYPE tyt_outtab,
     gt_message  TYPE tyt_message,
     gt_message2 TYPE tyt_message.

DATA:gv_title LIKE sy-title,
     gv_sname TYPE dd02l-tabname.

*alv define
DATA:gr_9000_con TYPE REF TO cl_gui_custom_container,
     go_9000_alv TYPE REF TO cl_gui_alv_grid.

DATA:gr_9001_con      TYPE REF TO cl_gui_custom_container,
     gr_9001_con_left TYPE REF TO cl_gui_container,
     gr_9001_con_head TYPE REF TO cl_gui_container,
     gr_9001_con_body TYPE REF TO cl_gui_container,
     gr_split         TYPE REF TO cl_gui_splitter_container.

"!>>Add by ibm_huy  2018-12-20 -->Begin
DATA: gr_9001_viewer_head TYPE REF TO cl_gui_html_viewer
    , gr_9001_viewer_body TYPE REF TO cl_gui_html_viewer
    .
"!<<Add by ibm_huy  2018-12-20 -->End

DATA:gr_9001_tree      TYPE REF TO cl_gui_simple_tree,
     gr_9001_html_head TYPE REF TO cl_gui_html_viewer,
     gr_9001_html_body TYPE REF TO cl_gui_html_viewer.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS:p_ifname TYPE ztgd0004-ifname NO-DISPLAY,
             p_bund   TYPE ztgd0004-inter_bound
                           AS LISTBOX VISIBLE LENGTH 20 OBLIGATORY USER-COMMAND a.
  SELECT-OPTIONS:
             s_code   FOR zsgd_inter_info-inter_code,
             s_msgid  FOR zsgd_inter_info-msgid,
             s_key    FOR zsgd_inter_info-inter_msg_key,
*             s_stat   FOR zsgd_inter_info-zproc_stat,
             s_uname  FOR sy-uname MATCHCODE OBJECT zsh_uname,
             s_dats   FOR sy-datum DEFAULT sy-datum,
             s_times  FOR sy-uzeit.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  PARAMETERS:p_r1 RADIOBUTTON GROUP g1 DEFAULT 'X',
             p_r2 RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVE DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_receive DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      handle_selection_changed FOR EVENT selection_changed OF cl_gui_simple_tree
        IMPORTING node_key sender,
      handle_node_double_click FOR EVENT node_double_click OF cl_gui_simple_tree
        IMPORTING node_key sender,
      handle_context_select FOR EVENT node_context_menu_select OF cl_gui_simple_tree
        IMPORTING fcode node_key sender.

    CLASS-METHODS:
*数据更改结束
      handle_data_changed_finished FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified et_good_cells sender,
*用户命令
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm sender,
*工具栏
      handle_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object sender,
*双击事件
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no,
*热点事件
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id.
ENDCLASS.                    "lc_receive DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVE IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receive IMPLEMENTATION.

  METHOD handle_selection_changed.
    PERFORM frm_node_double_click USING node_key sender.
  ENDMETHOD.

  METHOD handle_context_select.
    PERFORM frm_node_double_click USING node_key sender.
  ENDMETHOD.

  METHOD handle_node_double_click.
    PERFORM frm_node_double_click USING node_key sender.
  ENDMETHOD.

  METHOD handle_double_click.
    PERFORM frm_double_click USING e_row e_column.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD handle_hotspot_click.
    PERFORM frm_hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD handle_data_changed_finished.
    PERFORM frm_data_changed_finished
                    USING e_modified et_good_cells sender.
  ENDMETHOD.

  METHOD handle_user_command.
    PERFORM frm_user_command USING e_ucomm sender.
  ENDMETHOD.

  METHOD handle_toolbar.
    PERFORM frm_toolbar  USING e_object sender.
  ENDMETHOD.

ENDCLASS.                    "LCL_EVENT_RECEIVE IMPLEMENTATION

INITIALIZATION.
  gv_title = sy-title.
  gv_sname = 'ZSGD_ZGDRP0001_ALV'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_code-low.
  PERFORM frm_f4_code CHANGING s_code-low."接口编码搜索帮助

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_code-high.
  PERFORM frm_f4_code CHANGING s_code-high."接口编码搜索帮助

START-OF-SELECTION.

  PERFORM frm_get_data.

  IF gt_outtab[] IS NOT INITIAL.
    CALL SCREEN 9000.
  ELSE.
    MESSAGE s001(00) WITH '没有满足条件的数据'.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_get_data .
  DATA:lv_ifname TYPE ze_ifname.
  DATA:lt_retcode TYPE RANGE OF ze_ret_code.

  lv_ifname = |%{ p_ifname }%|.

  IF p_r1 IS NOT INITIAL."仅响应报文中错误code
    APPEND 'EEQ0' TO lt_retcode.
  ENDIF.

  IF p_bund EQ 'OUTBOUND'.
    SELECT relid
           guid
           srtf2
           guid_request
           ifname
           inter_bound
           uri
           inter_code
           inter_msg_key
           msgid
           ret_code
           ret_msg
           uname
           dats
           times
           timestamp
           zproc_stat
           zproc_comm
           zproc_uname
           zproc_date
           zproc_tims
           clustr
           clustd
           descr AS zinter_desc
      INTO CORRESPONDING FIELDS OF TABLE gt_outtab
      FROM ztgd0004 AS a INNER JOIN ztgd0001 AS b
        ON a~inter_code = b~code
        WHERE a~ifname LIKE lv_ifname
          AND a~msgid  IN s_msgid
          AND a~uname  IN s_uname
          AND a~dats   IN s_dats
          AND a~times  IN s_times
          AND a~guid_request EQ ''
          AND a~inter_code IN s_code
          AND a~inter_bound EQ p_bund
          AND a~inter_msg_key IN s_key
          AND a~relid  EQ 'MB'
*          AND a~zproc_stat IN s_stat
          AND a~ret_code IN lt_retcode.
  ELSE.
    SELECT relid
         guid
         srtf2
         guid_request
         ifname
         inter_bound
         uri
         inter_code
         inter_msg_key
         msgid
         ret_code
         ret_msg
         uname
         dats
         times
         timestamp
         zproc_stat
         zproc_comm
         zproc_uname
         zproc_date
         zproc_tims
         clustr
         clustd
         descr AS zinter_desc
      INTO CORRESPONDING FIELDS OF TABLE gt_outtab
     FROM ztgd0004 AS a INNER JOIN ztgd0003 AS b
       ON a~inter_code = b~code
       WHERE a~ifname LIKE lv_ifname
          AND a~msgid  IN s_msgid
          AND a~uname  IN s_uname
          AND a~dats   IN s_dats
          AND a~times  IN s_times
          AND a~guid_request EQ ''
          AND a~inter_code IN s_code
          AND a~inter_bound EQ p_bund
          AND a~inter_msg_key IN s_key
          AND a~relid  EQ 'MB'
*           AND a~zproc_stat IN s_stat
          AND a~ret_code IN lt_retcode
    .
  ENDIF.

  SORT gt_outtab BY dats DESCENDING times DESCENDING.

ENDFORM.                    " FRM_GET_DATA
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.

*设置状态栏
  SET PF-STATUS '9000'.
  SET TITLEBAR '9000' WITH gv_title.

ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*& Module DISPLAY_AV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_av OUTPUT.

*显示ALV
  PERFORM frm_display_alv.
  cl_gui_cfw=>flush( ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  FRM_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       build and display alv
*----------------------------------------------------------------------*
FORM frm_display_alv .
  DATA:lt_fieldcat     TYPE lvc_t_fcat,  "字段目录列表
       ls_layout       TYPE lvc_s_layo,  "布局结构
       ls_print        TYPE lvc_s_prnt,  "打印控制
       lt_sort         TYPE lvc_t_sort,  "排序表
       lt_filter       TYPE lvc_t_filt,  "过滤表
       lt_funs_excl    TYPE ui_functions, "隐藏标准按钮内表
       lt_hyperlink    TYPE lvc_t_hype,  "超级链接内表
       ls_refresh_stbl TYPE lvc_s_stbl. "刷新行列固定结构

  IF go_9000_alv IS INITIAL.
    CREATE OBJECT gr_9000_con
      EXPORTING
        container_name              = '9000_CONT'      " Name of the Screen CustCtrl Name to Link Container To
      EXCEPTIONS
        cntl_error                  = 1                " CNTL_ERROR
        cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
        create_error                = 3                " CREATE_ERROR
        lifetime_error              = 4                " LIFETIME_ERROR
        lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
        OTHERS                      = 6.
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT go_9000_alv
      EXPORTING
*如果container（GR_9000_con）为null，则全屏显示
        i_parent = gr_9000_con.

*-----设置隐藏按钮
    PERFORM frm_func_excl      TABLES lt_funs_excl .
*-----ALV 事件设置
    PERFORM frm_set_alv_event.
*-----准备获取字段目录
    PERFORM frm_prepare_field_catalog CHANGING lt_fieldcat .
*-----设置布局
    PERFORM frm_prepare_layout        CHANGING ls_layout .
*-----显示alv
*    LS_PRINT-RESERVELNS = 2.
    CALL METHOD go_9000_alv->set_table_for_first_display
      EXPORTING
*       I_BUFFER_ACTIVE               =
*       I_CONSISTENCY_CHECK           =
*       I_STRUCTURE_NAME              =
*       IS_VARIANT                    = "显示变式
*       I_SAVE                        = "决定是否保存变式''/A/U/X
*       I_DEFAULT                     = 'X' "是否可以定义默认布局
        is_layout                     = ls_layout
*       IS_PRINT                      = LS_PRINT
*       IT_SPECIAL_GROUPS             = LT_GROUPS    "字段组
        it_toolbar_excluding          = lt_funs_excl
*       IT_HYPERLINK                  = LT_HYPERLINK
      CHANGING
        it_outtab                     = gt_outtab[]
        it_fieldcatalog               = lt_fieldcat
        it_sort                       = lt_sort
        it_filter                     = lt_filter
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
  ELSE.
*获取前端布局
*    CALL METHOD go_9000_alv->GET_FRONTEND_LAYOUT(
*      IMPORTING
*        ES_LAYOUT = LS_LAYOUT
*                    ).
**获取前端字段目录
*    CALL METHOD go_9000_alv->GET_FRONTEND_FIELDCATALOG(
*      IMPORTING
*        ET_FIELDCATALOG = LT_FIELDCAT
*                          ).
*----刷新alv
    ls_refresh_stbl-row = abap_true.       "行滚动条不滑动
    ls_refresh_stbl-col = abap_true.       "列滚动条不滑动
    CALL METHOD go_9000_alv->refresh_table_display
      EXPORTING
        is_stable = ls_refresh_stbl
*       I_SOFT_REFRESH = abap_true         "过滤、合计、排序等设置不变
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*--异常处理
    ENDIF.
*设置前端布局
*    CALL METHOD go_9000_alv->SET_FRONTEND_LAYOUT( LS_LAYOUT ).
*设置前端字段目录
*    CALL METHOD go_9000_alv->SET_FRONTEND_FIELDCATALOG( LT_FIELDCAT ).
  ENDIF.
ENDFORM.                    " FRM_DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  FRM_PREPARE_FIELD_CATALOG
*&---------------------------------------------------------------------*
*   构建显示字段目录
*----------------------------------------------------------------------*
FORM frm_prepare_field_catalog  CHANGING pt_fieldcat TYPE lvc_t_fcat.

  FIELD-SYMBOLS:<fs_fieldcat> TYPE lvc_s_fcat.

  DEFINE change_txt.
    <fs_fieldcat>-reptext   =
    <fs_fieldcat>-scrtext_l =
    <fs_fieldcat>-scrtext_m =
    <fs_fieldcat>-scrtext_s = &1.
  END-OF-DEFINITION.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gv_sname
    CHANGING
      ct_fieldcat            = pt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2.
  IF sy-subrc <> 0.
*--Exception handling
  ENDIF.
  DELETE pt_fieldcat WHERE fieldname = 'MSGID' .
  DELETE pt_fieldcat WHERE fieldname = 'ZPROC_STAT' .
  DELETE pt_fieldcat WHERE fieldname = 'GUID_REQUEST' .
  DELETE pt_fieldcat WHERE fieldname = 'URI' .
  DELETE pt_fieldcat WHERE fieldname = 'ZPROC_COMM' .
  DELETE pt_fieldcat WHERE fieldname = 'ZPROC_UNAME' .
  DELETE pt_fieldcat WHERE fieldname = 'ZPROC_DATE' .
  DELETE pt_fieldcat WHERE fieldname = 'ZPROC_TIMS' .



  LOOP AT pt_fieldcat ASSIGNING <fs_fieldcat> .
    CASE <fs_fieldcat>-fieldname .
      WHEN 'GUID'.
        change_txt '接口日志ID'(001).
      WHEN 'IFNAME'.
        change_txt '接口路径'(002).
      WHEN 'UNAME'.
        change_txt '接口用户'(003).
      WHEN 'DATS'.
        change_txt '接口日期'(004).
      WHEN 'TIMES'.
        change_txt '接口时间'(005).
        <fs_fieldcat>-REF_FIELD = 'TIMES' .
        <fs_fieldcat>-REF_TABLE = 'ZTGD0004' .
*      WHEN 'ZPROC_STAT'.
*        <fs_fieldcat>-edit = abap_true.
*      WHEN 'ZPROC_COMM'.
*        <fs_fieldcat>-edit = abap_true.
      WHEN OTHERS.
    ENDCASE .
  ENDLOOP .
ENDFORM.                    "FRM_PREPARE_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  FRM_PREPARE_LAYOUT
*&---------------------------------------------------------------------*
*   设置布局
*----------------------------------------------------------------------*
FORM frm_prepare_layout  CHANGING ps_layout TYPE lvc_s_layo.

  DATA:lv_lines     TYPE i,
       lv_line_char TYPE char20.

  DESCRIBE TABLE gt_outtab LINES lv_lines.
  lv_line_char = lv_lines.
  CONDENSE lv_line_char NO-GAPS.

  ps_layout-grid_title = '条目数：' && lv_line_char.

  ps_layout-zebra = 'X' .
  ps_layout-smalltitle = abap_true .     "标体大小
  ps_layout-cwidth_opt = abap_true.      "列宽优化
*选择模式A 行列、B
  ps_layout-sel_mode   = 'B'.     "选择模式A/B/C/D 行列单元格/列/行选择

ENDFORM.                    " FRM_PREPARE_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  FRM_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       ALV DOUBLE CLICK EVENT
*----------------------------------------------------------------------*
FORM frm_double_click  USING    ps_row     TYPE lvc_s_row
                                ps_column  TYPE lvc_s_col.

  DATA:ls_outtab TYPE tys_outtab.

  READ TABLE gt_outtab INTO ls_outtab INDEX ps_row-index.

  CASE ps_column-fieldname.
    WHEN 'GUID'.
      PERFORM frm_display_interface_message USING ls_outtab-guid ls_outtab-inter_code.

    WHEN OTHERS.
      PERFORM frm_display_interface_message USING ls_outtab-guid ls_outtab-inter_code.

  ENDCASE.

ENDFORM.                    " FRM_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  FRM_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       hotspot event
*----------------------------------------------------------------------*
FORM frm_hotspot_click  USING    p_row_id    TYPE lvc_s_row
      p_column_id TYPE lvc_s_col.
  DATA:ls_outtab LIKE LINE OF gt_outtab.
  CASE p_column_id-fieldname.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " FRM_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  FRM_SET_ALV_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_set_alv_event .

  DATA:lo_receive   TYPE REF TO lcl_event_receive.
  DATA:lt_f4        TYPE lvc_t_f4.
  DATA:lo_html      TYPE REF TO cl_dd_document.

*注册事件
  SET HANDLER lcl_event_receive=>handle_double_click          FOR go_9000_alv.
  SET HANDLER lcl_event_receive=>handle_hotspot_click         FOR go_9000_alv.
  SET HANDLER lcl_event_receive=>handle_user_command          FOR go_9000_alv.
  SET HANDLER lcl_event_receive=>handle_toolbar               FOR go_9000_alv.
  SET HANDLER lcl_event_receive=>handle_data_changed_finished FOR go_9000_alv.

ENDFORM.                    " FRM_SET_ALV_EVENT
*&---------------------------------------------------------------------*
*& Form FRM_DISPLAY_INTERFACE_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_OUTTAB_GUID
*&---------------------------------------------------------------------*
FORM frm_display_interface_message  USING  pv_guid TYPE guid_32
                                           pv_intcode TYPE ze_inter_code.

  DATA:ls_inter_message TYPE zcl_interface_util=>tys_inter_message,
       ls_message       TYPE tys_message.

  IF pv_intcode+0(2) = 'BS'.
    ls_inter_message =
      zcl_interface_util=>read_interface_message_bs( iv_guid = pv_guid ).
  ELSE.
    ls_inter_message =
        zcl_interface_util=>read_interface_message( iv_guid = pv_guid ).
  ENDIF.

  CLEAR:gt_message,ls_message.
  MOVE-CORRESPONDING ls_inter_message-request TO ls_message.
  ls_message-type = c_req.
  APPEND ls_message TO gt_message.
  CLEAR ls_message.
  MOVE-CORRESPONDING ls_inter_message-response TO ls_message.
  ls_message-type = c_res.
  APPEND ls_message TO gt_message.


*9001 容器初始化
  PERFORM frm_init_9001_container.

*构造节点
  PERFORM frm_build_node  USING ls_inter_message-request-guid
                                ls_inter_message-response-guid.

*显示 报文
*  PERFORM frm_write_message USING c_req.


  CALL SCREEN 9001."显示

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_INIT_9001_CONTAINER
*&---------------------------------------------------------------------*
*& 初始化 9001屏幕 容器
*&---------------------------------------------------------------------*
FORM frm_init_9001_container .
  IF gr_9001_viewer_head IS NOT INITIAL.
    gr_9001_viewer_head->free( ).
    FREE gr_9001_viewer_head.
  ENDIF.
  IF gr_9001_viewer_body IS NOT INITIAL.
    gr_9001_viewer_body->free( ).
    FREE gr_9001_viewer_body.
  ENDIF.

  IF gr_9001_tree IS NOT INITIAL.
    gr_9001_tree->free( ).
    FREE gr_9001_tree.
  ENDIF.

  IF gr_9001_con_body IS NOT INITIAL.
    gr_9001_con_body->free( ).
    FREE gr_9001_con_body.
  ENDIF.

  IF gr_9001_con_head IS NOT INITIAL.
    gr_9001_con_head->free( ).
    FREE gr_9001_con_head.
  ENDIF.

  IF gr_9001_con_left IS NOT INITIAL.
    gr_9001_con_left->free( ).
    FREE gr_9001_con_left.
  ENDIF.

  IF gr_split IS NOT INITIAL.
    gr_split->free( ).
    FREE gr_split.
  ENDIF.

  IF gr_9001_con IS NOT INITIAL.
    gr_9001_con->free( ).
    FREE gr_9001_con.
  ENDIF.

  CHECK gr_9001_con IS INITIAL.

  CREATE OBJECT gr_9001_con
    EXPORTING
      container_name              = '9001_CONT'      " Name of the Screen CustCtrl Name to Link Container To
*     style                       =                  " Windows Style Attributes Applied to this Container
*     lifetime                    = lifetime_default " Lifetime
*     repid                       = 'ZGDRP0001' " Screen to Which this Container is Linked
*     dynnr                       = '9001' " Report To Which this Container is Linked
*     no_autodef_progid_dynnr     =                  " Don't Autodefined Progid and Dynnr?
    EXCEPTIONS
      cntl_error                  = 1                " CNTL_ERROR
      cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
      create_error                = 3                " CREATE_ERROR
      lifetime_error              = 4                " LIFETIME_ERROR
      lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

*拆分容器 3列
    CREATE OBJECT gr_split
      EXPORTING
        parent            = gr_9001_con        " Parent Container
        rows              = 1                  " Number of Rows to be displayed
        columns           = 3                  " Number of Columns to be Displayed
      EXCEPTIONS
        cntl_error        = 1                  " See Superclass
        cntl_system_error = 2                  " See Superclass
        OTHERS            = 3.
    IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.

*设置第一列 宽度
      gr_split->set_column_width(
        EXPORTING
          id                = 1                 " Column ID
          width             = 20                 " NPlWidth
*        IMPORTING
*          result            =                  " Result Code
        EXCEPTIONS
          cntl_error        = 1                " See CL_GUI_CONTROL
          cntl_system_error = 2                " See CL_GUI_CONTROL
          OTHERS            = 3
      ).
      IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.

*设置第二列宽度
        gr_split->set_column_width(
             EXPORTING
               id                = 2                 " Column ID
               width             = 30                " NPlWidth
*        IMPORTING
*          result            =                  " Result Code
             EXCEPTIONS
               cntl_error        = 1                " See CL_GUI_CONTROL
               cntl_system_error = 2                " See CL_GUI_CONTROL
               OTHERS            = 3
           ).
      ENDIF.

*获取第一列容器
      gr_9001_con_left = gr_split->get_container(
           row       = 1                 " Row
           column    = 1                 " Column
       ).

*获取第二列容器
      gr_9001_con_head = gr_split->get_container(
           row       = 1                 " Row
           column    = 2                 " Column
       ).

*获取第三列容器
      gr_9001_con_body = gr_split->get_container(
           row       = 1                 " Row
           column    = 3                 " Column
       ).
    ENDIF.


  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_WRITE_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_GUID
*&---------------------------------------------------------------------*
FORM frm_write_message  USING    pv_type TYPE ty_msg_type.

  DATA:ls_message TYPE tys_message.

  DATA: lt_html   TYPE cl_abap_browser=>html_table
      , lv_offset TYPE i
      , lv_tmp_url   TYPE c LENGTH 500
      .

  READ TABLE gt_message INTO ls_message WITH KEY type = pv_type.
*  check sy-subrc eq 0.
  IF gr_9001_con_head IS NOT INITIAL.
**显示html
    IF gr_9001_viewer_head IS INITIAL .
      CREATE OBJECT gr_9001_viewer_head
        EXPORTING
          parent = gr_9001_con_head.
      gr_9001_viewer_head->set_ui_flag( cl_gui_html_viewer=>uiflag_no3dborder ).
    ENDIF.
    CLEAR:lt_html[],lv_tmp_url.
    DO.
      lv_offset = ( sy-index - 1 ) * 255.
      IF lv_offset >= strlen( ls_message-head ).EXIT.ENDIF.
      APPEND ls_message-head+lv_offset TO lt_html[].
    ENDDO.
    gr_9001_viewer_head->load_data( IMPORTING assigned_url = lv_tmp_url CHANGING data_table = lt_html[] ).
    gr_9001_viewer_head->show_data( lv_tmp_url ).


  ENDIF.

  IF gr_9001_con_body IS NOT INITIAL.
**显示html
*    PERFORM frm_display_html  USING  ls_message-body
*                                     gr_9001_con_body
*                                     gr_9001_html_body.

    IF gr_9001_viewer_body IS INITIAL .
      CREATE OBJECT gr_9001_viewer_body
        EXPORTING
          parent = gr_9001_con_body.
*      gr_9001_viewer_body = NEW cl_gui_html_viewer( gr_9001_con_body ).
      gr_9001_viewer_body->set_ui_flag( cl_gui_html_viewer=>uiflag_no3dborder ).
    ENDIF.
    CLEAR:lt_html[],lv_tmp_url.
    DO.
      lv_offset = ( sy-index - 1 ) * 255.
      IF lv_offset >= strlen( ls_message-body ).EXIT.ENDIF.
      APPEND ls_message-body+lv_offset TO lt_html[].
    ENDDO.
    gr_9001_viewer_body->load_data( IMPORTING assigned_url = lv_tmp_url CHANGING data_table = lt_html[] ).
    gr_9001_viewer_body->show_data( lv_tmp_url ).

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_BUILD_NODE
*&---------------------------------------------------------------------*
*& 构造节点
*&---------------------------------------------------------------------*
FORM frm_build_node   USING pv_request_guid  TYPE guid_32
                            pv_response_guid  TYPE guid_32.

  DATA:ls_node_sty    TYPE lvc_s_layn,
       lv_node_value  TYPE lvc_value,
       lv_request_key TYPE lvc_nkey.

  DATA:lt_table TYPE TABLE OF uml_tree,
       ls_table TYPE uml_tree.

  CHECK gr_9001_con_left IS NOT INITIAL.

  IF gr_9001_tree IS NOT INITIAL.
    gr_9001_tree->free( ).
    FREE gr_9001_tree.
  ENDIF.

  CREATE OBJECT gr_9001_tree
    EXPORTING
      parent                      = gr_9001_con_left                 " Parent Container
      node_selection_mode         = 0                 " "
    EXCEPTIONS
      lifetime_error              = 1                " "
      cntl_system_error           = 2                " "
      create_error                = 3                " Error Creating Control
      failed                      = 4                " General Error
      illegal_node_selection_mode = 5                " Error in Parameter NODE_SELECTION_MODE
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

    CLEAR:lt_table,ls_table.
    ls_table-node_key = c_req.
    ls_table-exp_image = '@9T@'.
    ls_table-n_image   = '@9T@'.
    ls_table-isfolder  = abap_true.
    ls_table-expander  = abap_true.
    ls_table-text      = pv_request_guid.
    APPEND ls_table TO lt_table.

    CLEAR:ls_table.
    ls_table-node_key = c_res.
    ls_table-relatkey = c_req.
    ls_table-exp_image = '@9S@'.
    ls_table-n_image   = '@9S@'.
    ls_table-text      = pv_response_guid.
    APPEND ls_table TO lt_table.

    gr_9001_tree->add_nodes(
      EXPORTING
        table_structure_name = 'UML_TREE'
        node_table            = lt_table                 " Node table
      EXCEPTIONS
        error_in_node_table            = 1                " Node Table Contains Errors
        failed                         = 2                " General error
        dp_error                       = 3                " Error in Data Provider
        table_structure_name_not_found = 4                " Unable to Find Structure in Dictionary
        OTHERS                         = 5
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


*设置事件
    PERFORM frm_set_tree_event  USING gr_9001_tree.

    gr_9001_tree->expand_node(
      EXPORTING
        node_key            = ls_table-relatkey                 " Node key
      EXCEPTIONS
        failed              = 1                " General Error
        illegal_level_count = 2                " LEVEL_COUNT Must Be GE 0
        cntl_system_error   = 3                " "
        node_not_found      = 4                " Node With Key NODE_KEY Does Not Exist
        cannot_expand_leaf  = 5                " Node With key NODE_KEY is a Leaf
        OTHERS              = 6
    ).
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.



    CALL METHOD cl_gui_cfw=>flush
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_NODE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& tree node double click
*&---------------------------------------------------------------------*
FORM frm_node_double_click
                        USING  pv_node_key TYPE tv_nodekey
                               pr_sender   TYPE REF TO cl_gui_simple_tree.
  DATA:lv_type TYPE ty_msg_type.

  lv_type = pv_node_key.
*输出消息
  PERFORM frm_write_message USING lv_type.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SET_TREE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GR_9001_TREE
*&---------------------------------------------------------------------*
FORM frm_set_tree_event  USING    pr_tree TYPE REF TO cl_gui_simple_tree.

  DATA:lt_events TYPE cntl_simple_events,
       ls_event  TYPE cntl_simple_event.
*设置事件
  SET HANDLER lcl_event_receive=>handle_node_double_click FOR pr_tree.
  SET HANDLER lcl_event_receive=>handle_selection_changed FOR pr_tree.
  SET HANDLER lcl_event_receive=>handle_context_select    FOR pr_tree.

  CLEAR ls_event.
  ls_event-eventid =  cl_gui_simple_tree=>eventid_selection_changed.
  APPEND ls_event TO lt_events.

  CLEAR ls_event.
  ls_event-eventid =  cl_gui_simple_tree=>eventid_node_context_menu_req.
  APPEND ls_event TO lt_events.

  pr_tree->set_registered_events(
    EXPORTING
      events                    = lt_events                " Event Table
    EXCEPTIONS
      cntl_error                = 1                " cntl_error
      cntl_system_error         = 2                " cntl_system_error
      illegal_event_combination = 3                " ILLEGAL_EVENT_COMBINATION
      OTHERS                    = 4
  ).
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH '13'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module DISPLAY_MESSAGE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_message OUTPUT.


*显示 报文
  PERFORM frm_write_message USING c_req.

*  cl_gui_cfw=>flush( ).
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form FRM_F4_CODE
*&---------------------------------------------------------------------*
*& 接口编码的搜索帮助
*&---------------------------------------------------------------------*
FORM frm_f4_code   CHANGING pv_value TYPE ze_inter_code.

  DATA:BEGIN OF ls_data,
         code TYPE char20, "接口
         name TYPE char50,
       END OF ls_data,
       lt_data LIKE TABLE OF ls_data.

  IF p_bund EQ 'INBOUND'.
*入栈接口编码
    SELECT
        code
        descr AS name INTO TABLE lt_data
    FROM ztgd0003.                                      "#EC CI_NOWHERE

  ELSEIF p_bund EQ 'OUTBOUND'.
*出栈接口编码
    SELECT
      code
      descr AS name INTO TABLE lt_data
    FROM ztgd0001.                                      "#EC CI_NOWHERE
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'S_CODE'
      value_org       = 'S'
    TABLES
      value_tab       = lt_data
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& 数据更改
*&---------------------------------------------------------------------*
FORM frm_data_changed_finished  USING pv_modified   TYPE char01
                                      pt_good_cells TYPE lvc_t_modi
                                      pr_sender     TYPE REF TO cl_gui_alv_grid.

  DATA:ls_cell TYPE lvc_s_modi,
       ls_edit TYPE tys_outtab.

  FIELD-SYMBOLS:<ls_edit> TYPE tys_outtab.

  IF pv_modified EQ abap_true.
    LOOP AT pt_good_cells INTO ls_cell.
*记录修改记录
      READ TABLE gt_outtab INTO ls_edit INDEX ls_cell-row_id.
      IF sy-subrc EQ 0.
        READ TABLE gt_edit ASSIGNING <ls_edit> WITH KEY guid = ls_edit-guid.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING ls_edit TO <ls_edit>.
        ELSE.
          APPEND ls_edit TO gt_edit.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM frm_user_command  USING    pv_ucomm  TYPE sy-ucomm
                                pr_sender TYPE REF TO cl_gui_alv_grid.


  CASE pv_ucomm.
    WHEN 'SAVE'.
      PERFORM frm_save_changed.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM frm_toolbar  USING pr_object TYPE REF TO cl_alv_event_toolbar_set
                        pr_sender TYPE REF TO cl_gui_alv_grid.

  DATA:ls_button TYPE stb_button.

  FIELD-SYMBOLS:<fs_toolbar> TYPE ttb_button.

  DEFINE add_button.
    CLEAR:ls_button.
    ls_button-function = &1.
    ls_button-text     = &2.
    APPEND ls_button TO <fs_toolbar>.
  END-OF-DEFINITION.

  DEFINE add_sep.
    CLEAR:ls_button.
    ls_button-function = &1.
    ls_button-butn_type = 3.
    APPEND ls_button TO <fs_toolbar>.
  END-OF-DEFINITION.


  ASSIGN pr_object->mt_toolbar TO <fs_toolbar>.
*  IF sy-subrc EQ 0.
*    add_sep 'SEP1'.
*    add_button 'SAVE' '保存处理记录'(m03).
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FUNC_EXCL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM frm_func_excl  TABLES   pt_funs_excl TYPE ui_functions.

*添加隐藏按钮
  APPEND  '&LOCAL&CUT'    TO pt_funs_excl.
  APPEND  '&LOCAL&COPY'   TO pt_funs_excl.
  APPEND  '&LOCAL&PASTE'  TO pt_funs_excl.
  APPEND  '&LOCAL&UNDO'   TO pt_funs_excl.
  APPEND  '&&SEP02'       TO pt_funs_excl.
  APPEND  '&LOCAL&APPEND' TO pt_funs_excl.
  APPEND  '&LOCAL&INSERT_ROW' TO pt_funs_excl.
  APPEND  '&LOCAL&DELETE_ROW' TO pt_funs_excl.
  APPEND  '&LOCAL&COPY_ROW'   TO pt_funs_excl.
  APPEND  '&&SEP03'           TO pt_funs_excl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SAVE_CHANGED
*&---------------------------------------------------------------------*
*& 保存更改
*&---------------------------------------------------------------------*
FORM frm_save_changed .

  DATA:ls_edit TYPE tys_outtab.

  LOOP AT gt_edit INTO ls_edit.
    UPDATE ztgd0004 SET zproc_stat = ls_edit-zproc_stat
                        zproc_comm = ls_edit-zproc_comm
                        zproc_uname = sy-uname
                        zproc_date = sy-datum
                        zproc_tims = sy-uzeit
           WHERE relid = ls_edit-relid
             AND guid  = ls_edit-guid
             AND srtf2 = ls_edit-srtf2.
    IF sy-subrc NE 0." 有错误则停止更新记录
      EXIT.
    ENDIF.
  ENDLOOP.

  IF sy-subrc EQ 0.
    COMMIT WORK.
    MESSAGE s001(00) WITH '数据保存成功'(m02) .
    CLEAR gt_edit.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001(00) WITH '数据保存失败'(m01) DISPLAY LIKE 'E'.
  ENDIF.


ENDFORM.
