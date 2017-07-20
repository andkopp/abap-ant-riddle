*&---------------------------------------------------------------------*
*&  Include           Z_ANT_RIDDLE_CLASSES
*&---------------------------------------------------------------------*

CLASS program DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      class_constructor,
      main
        IMPORTING
          new_game TYPE flag
          num_ants TYPE i
          simul    TYPE simul,
      replicate.
  PRIVATE SECTION.
    CLASS-DATA:
      agent TYPE REF TO zca_ant,
      ants  TYPE STANDARD TABLE OF REF TO zcl_ant.
    CLASS-METHODS:
      start_new_game
        IMPORTING
          num_ants TYPE i,
      continue,
      age,
      print.

ENDCLASS.

CLASS program IMPLEMENTATION.

  METHOD class_constructor.

    agent = zca_ant=>agent.

  ENDMETHOD.

  METHOD main.

* Start new game or continue previous game?
    IF new_game = abap_true.
      start_new_game( num_ants ).
    ELSE.
      continue( ).
    ENDIF.

* All ants get older
    age( ).

* Create ants after rule
    replicate( ).

* Print to screen
    print( ).

    IF simul = abap_false.
* Persist data to database
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDMETHOD.

  METHOD start_new_game.

    DATA: lo_ant TYPE REF TO zcl_ant.

* Delete all ants.
    DELETE FROM zps_ant.

* Create ants (day 0)
    DO num_ants TIMES.
      lo_ant ?= agent->create_persistent( ).
      INSERT lo_ant INTO TABLE ants.
    ENDDO.

  ENDMETHOD.

  METHOD continue.

    DATA: lo_ant TYPE REF TO zcl_ant.

* Read all ants (query: age >= 0 days --> all)
    DATA(lo_query_manager) = cl_os_system=>get_query_manager( ).
    DATA(lo_query) = lo_query_manager->create_query( i_filter = `DAYS_ALIVE >= PAR1` ).
    DATA(lt_db) = agent->if_os_ca_persistency~get_persistent_by_query(
      i_query = lo_query
      i_par1  = 0 ).

* Cast
    LOOP AT lt_db ASSIGNING FIELD-SYMBOL(<obj>).
      lo_ant ?= <obj>.
      INSERT lo_ant INTO TABLE ants.
    ENDLOOP.

  ENDMETHOD.

  METHOD age.

* All ants get one day older
    LOOP AT ants INTO DATA(lo_ant).
      lo_ant->set_days_alive( lo_ant->get_days_alive( ) + 1 ).
    ENDLOOP.

  ENDMETHOD.

  METHOD replicate.

    DATA: lt_new_ants LIKE ants,
          lo_new_ant  LIKE LINE OF lt_new_ants.

* All ants that are at least 2 days old recruit another ant.
    LOOP AT ants INTO DATA(lo_ant).
      IF lo_ant->get_days_alive( ) >= 2.
        DATA(lo_new) = agent->create_persistent( ).
        lo_new_ant ?= lo_new.
        INSERT lo_new_ant INTO TABLE lt_new_ants.
      ENDIF.
    ENDLOOP.

* Write ants first in a temporary table so that they don't go through the loop.
    INSERT LINES OF lt_new_ants INTO TABLE ants.

  ENDMETHOD.

  METHOD print.

    TYPES: BEGIN OF output,
             id         TYPE sy-tabix,
             days_alive TYPE i,
           END OF output.

    DATA: lt_output TYPE STANDARD TABLE OF output,
          ls_output LIKE LINE OF lt_output.

    LOOP AT ants INTO DATA(lo_ant).
      CLEAR ls_output.
      ls_output-id = sy-tabix.
      ls_output-days_alive = lo_ant->get_days_alive( ).
      INSERT ls_output INTO TABLE lt_output.
    ENDLOOP.

    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = DATA(lo_salv)
          CHANGING
            t_table      = lt_output.
      CATCH cx_salv_msg .
    ENDTRY.

    lo_salv->get_functions( )->set_all( abap_true ).
    lo_salv->get_columns( )->set_optimize( abap_true ).

    lo_salv->get_display_settings( )->set_list_header( |Ergebnis am Ende des Tages| ).

    lo_salv->get_columns( )->get_column( 'DAYS_ALIVE' )->set_medium_text( 'Alter in Tage' ).

    lo_salv->display( ).

  ENDMETHOD.

ENDCLASS.
