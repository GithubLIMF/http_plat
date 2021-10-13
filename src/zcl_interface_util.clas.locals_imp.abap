*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS cx_name DEFINITION INHERITING FROM cx_static_check FINAL.
ENDCLASS.

CLASS code_analysis DEFINITION FINAL.

  PUBLIC SECTION.

    CLASS-METHODS get_par_name
      IMPORTING stack_frame TYPE LINE OF abap_callstack
                lines       TYPE STANDARD TABLE
      RETURNING VALUE(ret)  TYPE string
      RAISING   cx_name.

  PRIVATE SECTION.
    CLASS-DATA counter TYPE i.
    CLASS-DATA stack_frame TYPE LINE OF abap_callstack.
    CLASS-DATA lines       TYPE STANDARD TABLE OF abap_callstack_line-line.

ENDCLASS.


CLASS code_analysis  IMPLEMENTATION.

  METHOD get_par_name.

    DATA:
      progtab  TYPE TABLE OF string,
      progline TYPE string,
      idx      TYPE sy-tabix,
      moff     TYPE i.

    FIELD-SYMBOLS <progline> TYPE string.

    "Count identic calls from one line
    IF stack_frame <> code_analysis=>stack_frame OR
       lines       <> code_analysis=>lines.
      code_analysis=>stack_frame = stack_frame.
      code_analysis=>lines       = lines.
      counter = 0.
    ELSE.
      counter = counter + 1.
    ENDIF.

    READ REPORT stack_frame-include INTO progtab.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_name.
    ENDIF.
    DELETE progtab TO stack_frame-line - 1.
    "Remove comments
    LOOP AT progtab ASSIGNING <progline>.
      IF strlen( <progline> ) > 0 AND <progline>(1) = '*'.
        DELETE progtab.
        CONTINUE.
      ENDIF.
      REPLACE REGEX `\A\s*".*` IN <progline> WITH `` ##no_text.
      IF sy-subrc <> 0.
        REPLACE REGEX `(.*)(")([^'|{``]+\z)` IN <progline> WITH `$1`.
      ENDIF.
      IF <progline> IS INITIAL.
        DELETE progtab.
      ENDIF.
    ENDLOOP.
    "Get all statements that are in or begin in the line
    LOOP AT progtab ASSIGNING <progline>.
      CONDENSE <progline>.
      idx = sy-tabix.
      REPLACE ALL OCCURRENCES OF REGEX `'[^']*\.[^']*'` IN <progline> WITH `'dummy'` ##no_text.
      REPLACE ALL OCCURRENCES OF REGEX '`[^`]*\.[^`]*`' IN <progline> WITH '`dummy`' ##no_text.
      REPLACE ALL OCCURRENCES OF REGEX '\|[^|]*\.[^|]*\|' IN <progline> WITH '`dummy`' ##no_text.
      IF idx = 1.
        progline = progline && ` ` && <progline>.
        IF substring( val = progline off = strlen( progline ) - 1 len = 1 ) = `.`.
          EXIT.
        ENDIF.
      ELSE.
        FIND `.` IN <progline> MATCH OFFSET moff.
        IF sy-subrc = 0.
          progline = progline && ` ` && substring( val = <progline> len = moff + 1 ).
          EXIT.
        ELSE.
          progline = progline && ` ` && <progline>.
        ENDIF.
      ENDIF.
    ENDLOOP.
    "Separate the calls of one line
    CONDENSE progline.
    REPLACE ALL OCCURRENCES OF REGEX `\s?CALL METHOD\s([^.]+)\(\s(?:EXPORTING\s)?(?:value|data)\s=\s([^.]+)\s\)\s?\.` ##NO_TEXT
           IN progline WITH `$1( $2 ).` IGNORING CASE.
    CONDENSE progline.
    REPLACE ALL OCCURRENCES OF REGEX `\s?CALL METHOD\s([^.]+)\sEXPORTING\s(?:value|data)\s=\s([^.]+)\s?\.` ##NO_TEXT
            IN progline WITH `$1( $2 ).` IGNORING CASE.
    CONDENSE progline.
    "Exactly the following methods call get_name( )
    REPLACE ALL OCCURRENCES OF `->write(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `=>write(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `->display(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `=>display(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `->write_data(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `=>write_data(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `=>display_data(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `->get(` IN progline WITH `###(` IGNORING CASE.
    REPLACE ALL OCCURRENCES OF `=>get(` IN progline WITH `###(` IGNORING CASE.
    SPLIT progline AT `###(` INTO TABLE progtab.
    IF lines( progtab ) <= 1.
      RAISE EXCEPTION TYPE cx_name.
    ENDIF.
    DELETE progtab INDEX 1.
    LOOP AT progtab ASSIGNING <progline>.
      REPLACE REGEX `([^)]+)(\).*)` IN <progline> WITH `$1`.
      CONDENSE <progline>.
      REPLACE REGEX `(?:EXPORTING )?(?:value|data) = ` IN <progline> WITH `` IGNORING CASE ##NO_TEXT.
      IF <progline> CS ` `  OR
         matches( val = <progline> regex = `-?\d+` ) OR           "no numeric literals
         <progline> CS `'`                           OR           "no text field literals
         <progline> CS '`'                           OR           "no string literals
         <progline> CS `[` OR <progline> CS `]`      OR           "expressions (parenthesis)
         <progline> CS `(` OR <progline> CS `)`.                  "expressions (parenthesis)
        CLEAR <progline>.
      ENDIF.
    ENDLOOP.
    IF counter = 0.
      counter = 1.
    ENDIF.
    "Reset for calls in loops
    IF counter > lines( progtab ).
      counter = 1.
    ENDIF.
    READ TABLE progtab INTO ret INDEX counter.
    ret = to_upper( ret ).

  ENDMETHOD.
ENDCLASS.
