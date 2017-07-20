*&---------------------------------------------------------------------*
*& Report  Z_ANT_RIDDLE
*&---------------------------------------------------------------------*
*& Ant riddle
*&
*& Two ants go on a journey. They have to find companions. Each ant
*& can recruit another ant on each day except the first. Each recruited
*& ant trys to persuade other ants, also starting on the second day.
*&
*& SAP demo programs for object services (persistence):
*& - DEMO_CREATE_PERSISTENT
*& - DEMO_QUERY_SERVICE
*&---------------------------------------------------------------------*
REPORT z_ant_riddle.

INCLUDE z_ant_riddle_classes.

PARAMETER: p_new    RADIOBUTTON GROUP gr1,
           p_contin RADIOBUTTON GROUP gr1 DEFAULT 'X',
           p_count  TYPE i DEFAULT 2 NO-DISPLAY,
           p_simul  TYPE simul DEFAULT abap_false.

START-OF-SELECTION.

  program=>main(
    EXPORTING
      new_game = p_new
      num_ants = p_count
      simul    = p_simul
  ).
