class ZCL_UTIL_JSON definition
  public
  final
  create public .

public section.

  constants PRETTY_MODE like ZCL_UI2_JSON=>PRETTY_MODE value ZCL_UI2_JSON=>PRETTY_MODE ##NO_TEXT.

  class-methods UNESCAPE
    importing
      !P_STR type STRING
    returning
      value(R_RET) type STRING .
  class-methods DESERIALIZE
    importing
      !JSON type STRING optional
      !JSONX type XSTRING optional
      !PRETTY_NAME type CHAR1 default PRETTY_MODE-NONE
      !ASSOC_ARRAYS type ABAP_BOOL default ABAP_FALSE
      !ASSOC_ARRAYS_OPT type ABAP_BOOL default ABAP_FALSE
      !NAME_MAPPINGS type ZCL_UI2_JSON=>NAME_MAPPINGS optional
    changing
      !DATA type DATA .
  class-methods SERIALIZE
    importing
      !DATA type DATA
      !COMPRESS type ABAP_BOOL default ABAP_FALSE
      !NAME type STRING optional
      !PRETTY_NAME type CHAR1 default PRETTY_MODE-NONE
      !TYPE_DESCR type ref to CL_ABAP_TYPEDESCR optional
      !ASSOC_ARRAYS type ABAP_BOOL default ABAP_FALSE
      !TS_AS_ISO8601 type ABAP_BOOL default ABAP_FALSE
      !EXPAND_INCLUDES type ABAP_BOOL default ABAP_TRUE
      !ASSOC_ARRAYS_OPT type ABAP_BOOL default ABAP_FALSE
      !NUMC_AS_STRING type ABAP_BOOL default ABAP_FALSE
      !NAME_MAPPINGS type ZCL_UI2_JSON=>NAME_MAPPINGS optional
    returning
      value(R_JSON) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_UTIL_JSON IMPLEMENTATION.


  method DESERIALIZE.
    ZCL_UI2_JSON=>deserialize(
        exporting
          json  = json jsonx = jsonx pretty_name = pretty_name
          assoc_arrays = assoc_arrays assoc_arrays_opt = assoc_arrays_opt name_mappings = name_mappings
        changing data = data
    ).
  endmethod.


  method SERIALIZE.
    r_json = ZCL_UI2_JSON=>serialize(
*     EXPORTING
       data = data
       compress = compress
       name = name
       pretty_name = pretty_name
       type_descr = type_descr
       assoc_arrays = assoc_arrays
       ts_as_iso8601 = ts_as_iso8601
       expand_includes = expand_includes
       assoc_arrays_opt = assoc_arrays_opt
       numc_as_string = numc_as_string
       name_mappings = name_mappings
   ).
  endmethod.


  method UNESCAPE.
   r_ret = cl_http_utility=>unescape_url( p_str ).
  endmethod.
ENDCLASS.
