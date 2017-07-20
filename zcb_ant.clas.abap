class ZCB_ANT definition
  public
  inheriting from CL_OS_CA_COMMON
  abstract
  create public .

public section.

  methods CREATE_PERSISTENT
    returning
      value(RESULT) type ref to ZCL_ANT
    raising
      CX_OS_OBJECT_EXISTING .
  methods CREATE_TRANSIENT
    returning
      value(RESULT) type ref to ZCL_ANT
    raising
      CX_OS_OBJECT_EXISTING .

  methods IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_OID
    redefinition .
  methods IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_OID_TAB
    redefinition .
  methods IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_QUERY
    redefinition .
  methods IF_OS_CA_SERVICE~GET_OID_BY_REF
    redefinition .
  methods IF_OS_CA_SERVICE~GET_REF_BY_OID
    redefinition .
  methods IF_OS_CA_SERVICE~SAVE
    redefinition .
  methods IF_OS_CA_SERVICE~SAVE_IN_UPDATE_TASK
    redefinition .
  methods IF_OS_FACTORY~CREATE_PERSISTENT
    redefinition .
  methods IF_OS_FACTORY~CREATE_TRANSIENT
    redefinition .
protected section.

  types TYP_OID type OS_GUID .
  types TYP_TYPE type OS_GUID .
  types TYP_OBJECT_REF type ref to ZCL_ANT .
  types:
    begin of TYP_DB_DATA ,
      DAYS_ALIVE type INT4 ,
      OS_OID type TYP_OID ,
    end of TYP_DB_DATA .
  types:
    TYP_DB_DATA_TAB type standard table of
      TYP_DB_DATA with non-unique default key .
  types:
    TYP_OID_TAB type standard table of
      TYP_OID with non-unique default key .
  types:
    TYP_OBJECT_REF_TAB type standard table of
      TYP_OBJECT_REF with non-unique default key .
  types:
    begin of TYP_SPECIAL_OBJECT_INFO ,
      OBJECT_ID type TYP_INTERNAL_OID ,
      ID_STATUS type TYP_ID_STATUS ,
      OID type TYP_OID ,
    end of TYP_SPECIAL_OBJECT_INFO .
  types:
    TYP_SPECIAL_OBJECT_INFO_TAB type sorted table of
      TYP_SPECIAL_OBJECT_INFO with unique key
      OBJECT_ID .
  types:
    TYP_SPECIAL_OID_TAB type sorted table of
      TYP_SPECIAL_OBJECT_INFO with unique key
      OID .
  types:
    TYP_DB_DELETE_TAB type standard table of
      TYP_SPECIAL_OBJECT_INFO with non-unique default key .

  data CURRENT_SPECIAL_OBJECT_INFO type TYP_SPECIAL_OBJECT_INFO .
  data MAP_ATT_INFO_TAB type OSTYP_RT_MAP_ATT_INFO_SRT_TAB .
  data SPECIAL_OBJECT_INFO type TYP_SPECIAL_OBJECT_INFO_TAB .
  data SPECIAL_OID_TAB type TYP_SPECIAL_OID_TAB .

  methods MAP_EXTRACT_IDENTIFIER
    importing
      !I_DB_DATA type TYP_DB_DATA
    exporting
      value(E_OID) type TYP_OID .
  methods MAP_GET_ATTRIBUTES
    importing
      !I_OBJECT_REF_TAB type TYP_OBJECT_REF_TAB
    exporting
      value(E_OBJECT_DATA_TAB) type TYP_DB_DATA_TAB .
  methods MAP_INITIALIZE_METADATA .
  methods MAP_LOAD_FROM_DATABASE_GUID
    importing
      !I_OID_TAB type TYP_OID_TAB
    returning
      value(RESULT) type TYP_DB_DATA_TAB .
  methods MAP_MERGE_IDENTIFIER
    importing
      !I_OID_TAB type TYP_OID_TAB
    changing
      !C_DB_DATA_TAB type TYP_DB_DATA_TAB .
  methods MAP_SAVE_TO_DATABASE
    importing
      !I_DELETES type TYP_DB_DELETE_TAB
      !I_INSERTS type TYP_DB_DATA_TAB
      !I_UPDATES type TYP_DB_DATA_TAB .
  methods MAP_SET_ATTRIBUTES
    importing
      !I_OBJECT_DATA type TYP_DB_DATA
      !I_OBJECT_REF type TYP_OBJECT_REF
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods PM_CHECK_AND_SET_ATTRIBUTES
    importing
      !I_ID_PROVIDED type TYP_ID_STATUS default 0
      !I_OBJECT_DATA type TYP_DB_DATA
      !I_OID type TYP_OID optional
    raising
      CX_OS_OBJECT_NOT_FOUND .
  methods PM_CREATE_REPRESENTANT
    importing
      !I_OID type TYP_OID optional
    returning
      value(RESULT) type TYP_OBJECT_REF .
  methods PM_DELETE_PERSISTENT .
  methods PM_LOAD_AND_SET_ATTRIBUTES
    importing
      !I_OID type TYP_OID optional
    raising
      CX_OS_OBJECT_NOT_FOUND .

  methods DELETE_SPECIAL_OBJECT_INFO
    redefinition .
  methods LOAD_SPECIAL_OBJECT_INFO
    redefinition .
  methods MAP_INVALIDATE
    redefinition .
  methods OS_PM_DELETE_PERSISTENT
    redefinition .
  methods PM_LOAD
    redefinition .
  methods SAVE_SPECIAL_OBJECT_INFO
    redefinition .
private section.

  methods MAP_LOAD_FROM_DATABASE
    importing
      !I_ORDER_BY_CLAUSE type STRING optional
      !I_SUBCLASSES type OS_BOOLEAN default OSCON_FALSE
      !I_UPTO type I default 0
      !I_WHERE_CLAUSE type STRING optional
      !PAR1 type ANY optional
      !PAR2 type ANY optional
      !PAR3 type ANY optional
    returning
      value(RESULT) type TYP_DB_DATA_TAB .
ENDCLASS.



CLASS ZCB_ANT IMPLEMENTATION.


  method CREATE_PERSISTENT.
***BUILD 093901
*      RETURNING RESULT TYPE REF TO ZCL_ANT
************************************************************************
* Purpose        : Create a new persistent object
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : The object exists in memory and will result in a
*                  new entry on database when the top transaction is
*                  closed.
*
* OO Exceptions  : propagates OS_PM_CREATED_PERSISTENT
*
* Implementation : 1. create a new object
*                  2. Set Attributes
*                  3. Register the object as NEW and initialize it
*                  4. Clean up
*
************************************************************************
* Changelog:
* - 2000-03-06   : (BGR) Initial Version 2.0
* - 2000-08-02   : (SB)  OO Exceptions
* - 2001-01-10   : (SB)  persistent atrributes as optional parameters
* - 2002-01-17   : (SB)  private attributes in super classes
* - 2006-08-01   : (SB)  replace SYSTEM_UUID_CREATE
************************************************************************

*< Generated from mapping:
  data: THE_OBJECT type ref to ZCL_ANT,
*>
        TEMP_OID type OS_GUID.

  clear CURRENT_OBJECT_IREF.

* * 1. Create a new object with a new OID
  try.
      call method CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC
        receiving UUID = TEMP_OID.
    catch CX_UUID_ERROR.
      raise exception type CX_OS_INTERNAL_ERROR.
  endtry.

  THE_OBJECT = PM_CREATE_REPRESENTANT( I_OID = TEMP_OID ).

* * 2. Set attributes
*< Generated from mapping:
*>

* * 3. register object as 'NEW' and initialize it.
  call method OS_PM_CREATED_PERSISTENT.

* * 4. clean-up
  clear CURRENT_SPECIAL_OBJECT_INFO.
  result = THE_OBJECT.

           "CREATE_PERSISTENT
  endmethod.


  method CREATE_TRANSIENT.
***BUILD 093901
*      RETURNING RESULT TYPE REF TO ZCL_ANT
************************************************************************
* Purpose        : Create a new transient object
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : The object exists in memory until it is RELEASEd
*
* OO Exception   : propagates OS_PM_CREATED_TRANSIENT
*
* Implementation : 1. Create a new object
*                  2. Set Attributes
*                  3. Register the object as TRANSIENT and initialize it
*                  4. Clean up
*
************************************************************************
* Changelog:
* - 2000-03-06   : (BGR) Initial Version 2.0
* - 2000-08-02   : (SB)  OO Exceptions
* - 2001-01-10   : (SB)  persistent atrributes as optional parameters
* - 2002-01-17   : (SB)  private attributes in super classes
************************************************************************

  data: THE_OBJECT   type        TYP_OBJECT_REF.

  clear CURRENT_OBJECT_IREF.

* * 1. Create a new object without OID
  THE_OBJECT = PM_CREATE_REPRESENTANT( ).

* * 2. Set attributes
*< Generated from mapping:
*>

* * 3. Register the object as TRANSIENT and initialize it
  call method OS_PM_CREATED_TRANSIENT.

* * 4. Clean up
  clear CURRENT_SPECIAL_OBJECT_INFO.
  result = THE_OBJECT.

           "CREATE_TRANSIENT
  endmethod.


  method DELETE_SPECIAL_OBJECT_INFO.
***BUILD 090501
************************************************************************
* Purpose        : Delete current entry SPECIAL_OBJECT_INFO
*
* Version        : 2.0
*
* Precondition   : Index is set in CURRENT_OBJECT_INDEX
*
* Postcondition  : entry is deleted
*
* OO Exceptions  : --
*
* Implementation :
*
************************************************************************
* Changelog:
* - 2000-03-02   : (BGR) Initial Version
* - 2001-11-14   : (SB)  Type Mapping
************************************************************************

  read table SPECIAL_OBJECT_INFO into CURRENT_SPECIAL_OBJECT_INFO
       index CURRENT_OBJECT_INDEX.

  delete table SPECIAL_OID_TAB
    with table key
      OID = CURRENT_SPECIAL_OBJECT_INFO-OID.

  delete SPECIAL_OBJECT_INFO index CURRENT_OBJECT_INDEX.
  clear CURRENT_SPECIAL_OBJECT_INFO.

           "DELETE_SPECIAL_OBJECT_INFO
  endmethod.


  method IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_OID.
***BUILD 093901
*      importing I_OID type OS_GUID
*      returning result type ref to object
************************************************************************
* Purpose        : Get a persistent object identified by the
*                  given OID
*
* Version        : 2.0
*
* Precondition   : The object exists with the given OID,
*                  either in memory or on database.
*
* Postcondition  : The object exists in memory, RESULT is the reference
*
* OO Exceptions  : CX_OS_OBJECT_NOT_FOUND
*                  (DELETED_BY_OID,TRANSIENT_BY_OID,INVALID_OID)
*                  propagates PM_LOAD_AND_SET_ATTRIBUTES
*                  propagates OS_PM_LOADED_PERISISTENT
*
* Implementation : 1. Look for object in SPECIAL_OBJECT_INFO. If found,
*                     check if it is still valid
*                  2. Object found: Check PM_STATUS
*                     2a. If Status is TRANSIENT or DELETED, error!
*                     2b. If Status is NOT_LOADED, continue with 3.
*                     2c. If Status is NEW, LOADED or CHANGED, success!
*                  3. Load object data from database and set object
*                  3.a. Completion in super class
*                  4. clean up
*
************************************************************************
* Changelog:
* - 2000-03-07   : (BGR) Version 2.0 - Common Superclass
* - 2000-08-02   : (SB)  OO Exceptions
* - 2001-11-14   : (SB)  type mapping
* - 2002-01-07   : (SB)  invalid OID error added
* - 2004-01-21   : (SB)  Type Mapping Refactoring
************************************************************************

  data: FLAG_NOT_LOADED type OS_BOOLEAN.

  data: TEMP_CURRENT_OBJECT_IREF type ref to object.

* * 1. Look for object in SPECIAL_OBJECT_INFO. If found, check if it
* * is still valid

  clear:  CURRENT_OBJECT_IREF.

  read table SPECIAL_OID_TAB into CURRENT_SPECIAL_OBJECT_INFO
       with table key OID = I_OID.

  if ( sy-subrc = 0 ).

    read table SPECIAL_OBJECT_INFO into CURRENT_SPECIAL_OBJECT_INFO
         with table key
         OBJECT_ID = CURRENT_SPECIAL_OBJECT_INFO-OBJECT_ID.

    call method OS_LOAD_AND_VALIDATE_CURRENT
         exporting I_INDEX = sy-tabix.

  endif.

  if ( not CURRENT_OBJECT_IREF is initial ).

* * 2. Object found: Check PM_STATUS

    case CURRENT_OBJECT_INFO-PM_STATUS.

*   * 2a. If Status is TRANSIENT or DELETED, error!
    when OSCON_OSTATUS_DELETED.

*!!!!! Error: Object activation failed - Object marked for deletion
      TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
      call method OS_CLEAR_CURRENT.
      clear CURRENT_SPECIAL_OBJECT_INFO.
      class CX_OS_OBJECT_NOT_FOUND definition load.
      raise exception type CX_OS_OBJECT_NOT_FOUND
        exporting
          OBJECT = TEMP_CURRENT_OBJECT_IREF
          OID    = I_OID
          TEXTID = CX_OS_OBJECT_NOT_FOUND=>DELETED_BY_OID.

    when OSCON_OSTATUS_TRANSIENT.

*!!!!! Error: Object activation failed - Object is transient
      TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
      call method OS_CLEAR_CURRENT.
      clear CURRENT_SPECIAL_OBJECT_INFO.
      class CX_OS_OBJECT_NOT_FOUND definition load.
      raise exception type CX_OS_OBJECT_NOT_FOUND
        exporting
          OBJECT = TEMP_CURRENT_OBJECT_IREF
          OID    = I_OID
          TEXTID = CX_OS_OBJECT_NOT_FOUND=>IS_TRANSIENT_BY_OID.

*   * 2b. If Status is NOT_LOADED, continue with 3.
    when OSCON_OSTATUS_NOT_LOADED.

      FLAG_NOT_LOADED      = OSCON_TRUE.

*   * 2c. If Status is NEW, LOADED or CHANGED, success!
    when others.

      FLAG_NOT_LOADED      = OSCON_FALSE.

    endcase. "PM_STATUS

  else." ( CURRENT_OBJECT_IREF is initial ).

    FLAG_NOT_LOADED      = OSCON_TRUE.

  endif." ( Entry in administrative data? )

* * 3. Load object data from database and set object

  if (  FLAG_NOT_LOADED = OSCON_TRUE ).

*   * Invalid OID
    if ( I_OID is initial ).
      call method OS_CLEAR_CURRENT.
      clear CURRENT_SPECIAL_OBJECT_INFO.
      class CX_OS_OBJECT_NOT_FOUND definition load.
      raise exception type CX_OS_OBJECT_NOT_FOUND
        exporting
          OID    = I_OID
          TEXTID = CX_OS_OBJECT_NOT_FOUND=>INVALID_OID.
    endif.

*   * internal Undo
    append INTERNAL_NEXT_UNDO_INFO to INTERNAL_TRANSACTION_STACK.
    INTERNAL_CURRENT_TRANSACTION = sy-tabix.

    try.
        call method PM_LOAD_AND_SET_ATTRIBUTES
             exporting I_OID  = I_OID.

        result ?= CURRENT_OBJECT_IREF.

*       * 3.a. Completion in super class
        call method OS_PM_LOADED_PERSISTENT.

      cleanup.
        call method OS_INTERNAL_UNDO.
        call method OS_CLEAR_CURRENT.
        clear CURRENT_SPECIAL_OBJECT_INFO.
    endtry.

*   * Clean-up internal Undo
    delete INTERNAL_TRANSACTION_STACK
           index INTERNAL_CURRENT_TRANSACTION.
    add -1 to INTERNAL_CURRENT_TRANSACTION.
    if ( INTERNAL_TRANSACTION_STACK is initial ).
      clear INTERNAL_UNDO_INFO.
      INTERNAL_NEXT_UNDO_INFO = 1.
    endif. "( INTERNAL_TRANSACTION_STACK is initial? )

  else. "( Object already loaded )

    result ?= CURRENT_OBJECT_IREF.
    call method OS_CLEAR_CURRENT.

  endif. "( Loading necessesary? )

* * 4. clean up

  clear  CURRENT_SPECIAL_OBJECT_INFO.


           "IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_OID
  endmethod.


  method IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_OID_TAB.
***BUILD 093901
      "importing I_OID_TAB type INDEX TABLE
      "returning value(RESULT) type OSREFTAB
      "raising   CX_OS_OBJECT_NOT_FOUND
************************************************************************
* Purpose        : Get persistent objects by OID table
*
* Version        : 2.0
*
* Precondition   : -
*
* Postcondition  : For each entry in the OID table, there is a corres-
*                  ponding entry in the RESULT table. If the object was
*                  found in the cache or the database, then a reference
*                  to this object can be found in the RESULT table,
*                  if not, the reference is initial. The persistent
*                  objects are active.
*
* OO Exceptions  : CX_OS_OBJECT_NOT_FOUND
*                    (DELETED_BY_OID,TRANSIENT_BY_OID,INVALID_OID)
*                  propagates PM_LOAD_AND_SET_ATTRIBUTES
*                  propagates OS_PM_LOADED_PERISISTENT
*
* Implementation : 1. Look for object in SPECIAL_OBJECT_INFO. If found,
*                     check if it is still valid
*                  2. Object found: Check PM_STATUS
*                     2a. If Status is TRANSIENT or DELETED, error!
*                     2b. If Status is NOT_LOADED, continue with 3.
*                     2c. If Status is NEW, LOADED or CHANGED, success!
*                  3. Load object data from database and set object
*                     3.a Completion in super class
*                  4. clean up
*
************************************************************************
* Changelog:
* - 2004-01-07   : (SB)  Multi Access
************************************************************************

  types: begin of TYP_OID_INDEX,
           OID   type TYP_OID,
           INDEX type SY-TABIX,
         end of TYP_OID_INDEX,
         TYP_OID_INDEX_TAB type sorted table
           of TYP_OID_INDEX with non-unique key OID.

  data: FLAG_NOT_LOADED  type OS_BOOLEAN,
        TEMP_OBJECT_REF  type TYP_OBJECT_REF,
        OID              type TYP_OID,
        OID_TAB          type TYP_OID_TAB,
        OBJECT_DATA_TAB  type TYP_DB_DATA_TAB,
        OID_INDEX        type TYP_OID_INDEX,
        OID_INDEX_TAB    type TYP_OID_INDEX_TAB,
        NEXT_INDEX       type SY-TABIX.

  data: TEMP_CURRENT_OBJECT_IREF type ref to OBJECT.

  field-symbols: <FS_OBJECT_DATA>  type TYP_DB_DATA,
                 <FS_OID>          type TYP_OID,
                 <FS_OID_INDEX>    type TYP_OID_INDEX.

* * 1. Look for objects in SPECIAL_OBJECT_INFO. If found, check if they
* * are still valid

  loop at I_OID_TAB assigning <FS_OID>. "#EC GEN_OK

    clear CURRENT_OBJECT_IREF.

    read table SPECIAL_OID_TAB into CURRENT_SPECIAL_OBJECT_INFO
       with table key OID = <FS_OID>.

    if ( SY-SUBRC = 0 ).

      read table SPECIAL_OBJECT_INFO into CURRENT_SPECIAL_OBJECT_INFO
           with table key
           OBJECT_ID = CURRENT_SPECIAL_OBJECT_INFO-OBJECT_ID.
      call method OS_LOAD_AND_VALIDATE_CURRENT
           exporting I_INDEX = SY-TABIX.

    endif.

    if ( not CURRENT_OBJECT_IREF is initial ).

*   * 2. Object found: Check PM_STATUS

      case CURRENT_OBJECT_INFO-PM_STATUS.

*     * 2a. If Status is TRANSIENT or DELETED, error!
      when OSCON_OSTATUS_DELETED.

*!!!!! Error: Object activation failed - Object marked for deletion
      TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
      call method OS_CLEAR_CURRENT.
      clear CURRENT_SPECIAL_OBJECT_INFO.
      class CX_OS_OBJECT_NOT_FOUND definition load.
      raise exception type CX_OS_OBJECT_NOT_FOUND
        exporting
          OBJECT = TEMP_CURRENT_OBJECT_IREF
          OID    = <FS_OID>
          TEXTID = CX_OS_OBJECT_NOT_FOUND=>DELETED_BY_OID.

      when OSCON_OSTATUS_TRANSIENT.

*!!!!! Error: Object activation failed - Object is transient
      TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
      call method OS_CLEAR_CURRENT.
      clear CURRENT_SPECIAL_OBJECT_INFO.
      class CX_OS_OBJECT_NOT_FOUND definition load.
      raise exception type CX_OS_OBJECT_NOT_FOUND
        exporting
          OBJECT = TEMP_CURRENT_OBJECT_IREF
          OID    = <FS_OID>
          TEXTID = CX_OS_OBJECT_NOT_FOUND=>IS_TRANSIENT_BY_OID.

*     * 2b. If Status is NOT_LOADED, continue with 3.
      when OSCON_OSTATUS_NOT_LOADED.

        FLAG_NOT_LOADED = OSCON_TRUE.

*     * 2c. If Status is NEW, LOADED or CHANGED, success!
      when others.

        FLAG_NOT_LOADED = OSCON_FALSE.

      endcase.

    else." ( CURRENT_OBJECT_IREF is initial )

      FLAG_NOT_LOADED = OSCON_TRUE.

    endif.

    if ( FLAG_NOT_LOADED = OSCON_TRUE ).

*!!!! Error: OID is initial
      if ( <FS_OID> is initial ).
        call method OS_CLEAR_CURRENT.
        clear CURRENT_SPECIAL_OBJECT_INFO.
        class CX_OS_OBJECT_NOT_FOUND definition load.
        raise exception type CX_OS_OBJECT_NOT_FOUND
          exporting
            OID    = <FS_OID>
            TEXTID = CX_OS_OBJECT_NOT_FOUND=>INVALID_OID.
      endif.

      append <FS_OID> to OID_TAB.

    endif.

    TEMP_OBJECT_REF ?= CURRENT_OBJECT_IREF.
    append TEMP_OBJECT_REF to RESULT.

    call method OS_CLEAR_CURRENT.

  endloop.

* * 3. Load object data from database and set objects

  if ( OID_TAB is not initial ).

*   * internal Undo
    append INTERNAL_NEXT_UNDO_INFO to INTERNAL_TRANSACTION_STACK.
    INTERNAL_CURRENT_TRANSACTION = SY-TABIX.

    try.
       call method MAP_LOAD_FROM_DATABASE_GUID
             exporting I_OID_TAB = OID_TAB
             receiving result = OBJECT_DATA_TAB.
      catch CX_OS_DB_SELECT.
        clear OBJECT_DATA_TAB.
    endtry.

    loop at I_OID_TAB assigning <FS_OID>. "EC GEN_OK
      OID_INDEX-OID = <FS_OID>.
      OID_INDEX-INDEX = SY-TABIX.
      insert OID_INDEX into table OID_INDEX_TAB.
    endloop.

    try.

        loop at OBJECT_DATA_TAB assigning <FS_OBJECT_DATA>.

          call method MAP_EXTRACT_IDENTIFIER
               exporting I_DB_DATA  = <FS_OBJECT_DATA>
               importing E_OID = OID.

          clear CURRENT_OBJECT_IREF.

          call method PM_CHECK_AND_SET_ATTRIBUTES
               exporting I_OBJECT_DATA  = <FS_OBJECT_DATA>
                         I_ID_PROVIDED  = ID_STATUS_NONE.

          TEMP_OBJECT_REF ?= CURRENT_OBJECT_IREF.

          read table OID_INDEX_TAB
               with key OID = OID
               assigning <FS_OID_INDEX>.

          while ( ( SY-SUBRC = 0 ) and ( <FS_OID_INDEX>-OID = OID ) ).

            NEXT_INDEX = SY-TABIX + 1.

            modify RESULT from TEMP_OBJECT_REF
                          index <FS_OID_INDEX>-INDEX.

            read table OID_INDEX_TAB
                 index NEXT_INDEX
                 assigning <FS_OID_INDEX>.

          endwhile.

*         * 3.a. Completion in super class
          call method OS_PM_LOADED_PERSISTENT.

          clear CURRENT_SPECIAL_OBJECT_INFO.

        endloop.

      cleanup.
        call method OS_INTERNAL_UNDO.
        call method OS_CLEAR_CURRENT.
        clear CURRENT_SPECIAL_OBJECT_INFO.
    endtry.

*   * Clean-up internal Undo
    delete INTERNAL_TRANSACTION_STACK
           index INTERNAL_CURRENT_TRANSACTION.
    add -1 to INTERNAL_CURRENT_TRANSACTION.
    if ( INTERNAL_TRANSACTION_STACK is initial ).
      clear INTERNAL_UNDO_INFO.
      INTERNAL_NEXT_UNDO_INFO = 1.
    endif. "( INTERNAL_TRANSACTION_STACK is initial? )

  endif.

* * 4. clean up

  clear CURRENT_SPECIAL_OBJECT_INFO.


           "IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_OID_TAB
  endmethod.


  method IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_QUERY.
***BUILD 093901
     " importing I_QUERY type ref to IF_OS_QUERY
     "           I_PARAMETER_TAB type OSTYP_DREF_TAB optional
     "           I_PAR1 type ANY optional
     "           I_PAR2 type ANY optional
     "           I_PAR3 type ANY optional
     "           I_SUBCLASSES type OS_BOOLEAN default OSCON_FALSE
     "           I_UPTO type I default 0
     "           I_OPTIONS type IF_OS_QUERY_OPTIONS default
     "             IF_OS_QUERY_OPTIONS=>DEFAULT_OPTIONS
     " returning value(RESULT) type OSREFTAB
     " raising   CX_OS_OBJECT_NOT_FOUND
     "           CX_OS_QUERY_ERROR
************************************************************************
* Purpose        : Get persistent objects by Query
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : For each instance that satifies the filter
*                  expression, there is a corresponding entry in the
*                  RESULT table. The persistent objects are active.
*
* OO Exceptions  : CX_OS_OBJECT_NOT_FOUND
*                    (DELETED_BY_OID,TRANSIENT_BY_OID)
*                  propagates PM_CHECK_AND_SET_ATTRIBUTES
*                  propagates OS_PM_LOADED_PERISISTENT
*
* Implementation : 1. Load data by query
*                  2. Set objects from data
*                  2a. Object found: Check PM_STATUS
*                  2b. Object not found, replace
*                  2c. Set attributes
*                  2d. Completion in super class
*                  3. clean up
*
************************************************************************
* Changelog:
* - 2004-03-25   : (SB)  Initial version
************************************************************************

  data: FLAG_NOT_LOADED  type OS_BOOLEAN,
        TEMP_OBJECT_REF  type TYP_OBJECT_REF,
        OID              type TYP_OID,
        OBJECT_DATA_TAB  type TYP_DB_DATA_TAB,
        QUERY            type ref to IF_OS_QRY_SERVICE,
        WHERE_CLAUSE     type STRING,
        ORDER_BY_CLAUSE  type STRING.

  data: TEMP_CURRENT_OBJECT_IREF type ref to OBJECT.

  field-symbols: <FS_OBJECT_DATA>  type TYP_DB_DATA.

* * 1. Load data by query

  try.
      call method MAP_INITIALIZE_METADATA.

      QUERY ?= I_QUERY.

      call method QUERY->MAP
           exporting I_CLASS_AGENT = ME
                     I_MAP_ATT_TAB = MAP_ATT_INFO_TAB.

      call method QUERY->GET_ORDER_BY_CLAUSE
           receiving RESULT = ORDER_BY_CLAUSE.

      if ( I_PARAMETER_TAB is supplied ).

        if ( ( I_PAR1 is supplied ) or
             ( I_PAR2 is supplied ) or
             ( I_PAR3 is supplied ) ).

          raise exception type CX_OS_QUERY_PARAMETER_ERROR
            exporting TEXTID = CX_OS_QUERY_PARAMETER_ERROR=>CALL_ERROR.

        endif.

        call method QUERY->GET_WHERE_CLAUSE
             exporting I_PARAMETER_TAB = I_PARAMETER_TAB
             receiving RESULT = WHERE_CLAUSE.

        call method MAP_LOAD_FROM_DATABASE
             exporting I_WHERE_CLAUSE    = WHERE_CLAUSE
                       I_ORDER_BY_CLAUSE = ORDER_BY_CLAUSE
                       I_SUBCLASSES      = I_SUBCLASSES
                       I_UPTO            = I_UPTO
             receiving result = OBJECT_DATA_TAB.

      else.

        call method QUERY->GET_WHERE_CLAUSE
             receiving RESULT = WHERE_CLAUSE.

        call method MAP_LOAD_FROM_DATABASE
             exporting I_WHERE_CLAUSE    = WHERE_CLAUSE
                       I_ORDER_BY_CLAUSE = ORDER_BY_CLAUSE
                       I_SUBCLASSES      = I_SUBCLASSES
                       I_UPTO            = I_UPTO
                       PAR1              = I_PAR1
                       PAR2              = I_PAR2
                       PAR3              = I_PAR3
             receiving result = OBJECT_DATA_TAB.

      endif.
    catch CX_OS_DB_SELECT.
      clear OBJECT_DATA_TAB.
  endtry.

* * 2. Set objects from data

  try.

*     * internal Undo
      append INTERNAL_NEXT_UNDO_INFO to INTERNAL_TRANSACTION_STACK.
      INTERNAL_CURRENT_TRANSACTION = SY-TABIX.

      loop at OBJECT_DATA_TAB assigning <FS_OBJECT_DATA>.

        call method MAP_EXTRACT_IDENTIFIER
             exporting I_DB_DATA  = <FS_OBJECT_DATA>
             importing E_OID = OID.

        clear CURRENT_OBJECT_IREF.

        read table SPECIAL_OID_TAB into CURRENT_SPECIAL_OBJECT_INFO
           with table key OID = OID.

        if ( SY-SUBRC = 0 ).

          read table SPECIAL_OBJECT_INFO
               into CURRENT_SPECIAL_OBJECT_INFO
               with table key
               OBJECT_ID = CURRENT_SPECIAL_OBJECT_INFO-OBJECT_ID.
          call method OS_LOAD_AND_VALIDATE_CURRENT
               exporting I_INDEX = SY-TABIX.

        endif.

        if ( not CURRENT_OBJECT_IREF is initial ).

*       * 2a. Object found: Check PM_STATUS

          case CURRENT_OBJECT_INFO-PM_STATUS.

*         * 2a1. If Status is DELETED, ignore or raise exception!
          when OSCON_OSTATUS_DELETED.

            if ( I_OPTIONS-DATABASE_QUERY_OPTIONS O
                 IF_OS_QUERY_OPTIONS=>IGNORE_DELETED ).

              call method OS_CLEAR_CURRENT.
              continue.

            endif.

* !!!!!!!! Error: Object activation failed - Object marked for deletion
            TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
            call method OS_CLEAR_CURRENT.
            clear CURRENT_SPECIAL_OBJECT_INFO.
            class CX_OS_OBJECT_NOT_FOUND definition load.
            raise exception type CX_OS_OBJECT_NOT_FOUND
              exporting
                OBJECT = TEMP_CURRENT_OBJECT_IREF
                OID    = OID
                TEXTID = CX_OS_OBJECT_NOT_FOUND=>DELETED_BY_OID.

*         * 2a2. If Status is TRANSIENT, error!
          when OSCON_OSTATUS_TRANSIENT.

* !!!!!!!!!! Error: Object activation failed - Object is transient
            TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
            call method OS_CLEAR_CURRENT.
            clear CURRENT_SPECIAL_OBJECT_INFO.
            class CX_OS_OBJECT_NOT_FOUND definition load.
            raise exception type CX_OS_OBJECT_NOT_FOUND
              exporting
                OBJECT = TEMP_CURRENT_OBJECT_IREF
                OID    = OID
                TEXTID = CX_OS_OBJECT_NOT_FOUND=>IS_TRANSIENT_BY_OID.

*         * 2a3. If Status is CHANGED, don't replace or raise exception!
          when OSCON_OSTATUS_CHANGED.

            if ( I_OPTIONS-DATABASE_QUERY_OPTIONS O
                 IF_OS_QUERY_OPTIONS=>REJECT_CHANGED ).

* !!!!!!!! Error: Object activation failed - Object marked as changed
            TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
            call method OS_CLEAR_CURRENT.
            clear CURRENT_SPECIAL_OBJECT_INFO.
            class CX_OS_OBJECT_NOT_FOUND definition load.
            raise exception type CX_OS_OBJECT_NOT_FOUND
              exporting
                OBJECT = TEMP_CURRENT_OBJECT_IREF
                OID    = OID
                TEXTID = CX_OS_OBJECT_NOT_FOUND=>CHANGED_BY_OID.

            endif.

            FLAG_NOT_LOADED = OSCON_FALSE.

*         * 2a4. If Status is NOT_LOADED, replace
          when OSCON_OSTATUS_NOT_LOADED.

            FLAG_NOT_LOADED = OSCON_TRUE.

*         * 2a5. If Status is NEW or LOADED, don't replace
          when others.

            FLAG_NOT_LOADED = OSCON_FALSE.

          endcase.

        else." ( CURRENT_OBJECT_IREF is initial )

*       * 2b. Object not found, replace

          FLAG_NOT_LOADED = OSCON_TRUE.

        endif.

        TEMP_OBJECT_REF ?= CURRENT_OBJECT_IREF.

        if ( FLAG_NOT_LOADED = OSCON_TRUE ).

*         * 2c. Set attributes
          call method PM_CHECK_AND_SET_ATTRIBUTES
               exporting I_OBJECT_DATA  = <FS_OBJECT_DATA>
                         I_ID_PROVIDED  = ID_STATUS_NONE.

          TEMP_OBJECT_REF ?= CURRENT_OBJECT_IREF.

*         * 2d. Completion in super class
          call method OS_PM_LOADED_PERSISTENT.

        endif.

        append TEMP_OBJECT_REF to RESULT.

        call method OS_CLEAR_CURRENT.

      endloop.

*     * Clean-up internal Undo
      delete INTERNAL_TRANSACTION_STACK
             index INTERNAL_CURRENT_TRANSACTION.
      add -1 to INTERNAL_CURRENT_TRANSACTION.
      if ( INTERNAL_TRANSACTION_STACK is initial ).
        clear INTERNAL_UNDO_INFO.
        INTERNAL_NEXT_UNDO_INFO = 1.
      endif. "( INTERNAL_TRANSACTION_STACK is initial? )

    cleanup.
      call method OS_INTERNAL_UNDO.
      call method OS_CLEAR_CURRENT.
      clear CURRENT_SPECIAL_OBJECT_INFO.
  endtry.

* * 3. clean up

  clear CURRENT_SPECIAL_OBJECT_INFO.


           "IF_OS_CA_PERSISTENCY~GET_PERSISTENT_BY_QUERY
  endmethod.


  method IF_OS_CA_SERVICE~GET_OID_BY_REF.
***BUILD 090501
     " importing I_OBJECT type ref to object
     " returning result type OS_GUID
************************************************************************
* Purpose        : Get the OID for a given object reference.
*
* Version        : 2.0
*
* Precondition   : The object I_OBJECT has an entry in OBJECT_INFO and
*                  is not transient
*
* Postcondition  : The OID of the object is known
*
* OO Exceptions  : CX_OS_OBJECT_STATE(TRANSIENT,UNMANAGED)
*
* Implementation : 1. Look for entry in SPECIAL_OBJECT_INFO
*                  2. No entry found:
*                     Error: not in adm. data
*                  3. Entry found:
*                   3a. if persistent: return OID
*                   3b. if transient: Error: Transient object.
*
************************************************************************
* Changelog:
* - 2000-03-07   : (BGR) Initial Version 2.0
* - 2000-08-02   : (SB) OO Exceptions
************************************************************************

  data: INTERNAL_OID  type TYP_INTERNAL_OID,
        TEMP_OBJECT   type TYP_OBJECT_IREF.

* * 1. Look for entry in SPECIAL_OBJECT_INFO
  TEMP_OBJECT ?= I_OBJECT.
  INTERNAL_OID = OS_GET_INTERNAL_OID_BY_REF(
                    I_OBJECT = TEMP_OBJECT ).

  read table SPECIAL_OBJECT_INFO into CURRENT_SPECIAL_OBJECT_INFO
       with table key OBJECT_ID = INTERNAL_OID.

  if ( sy-subrc <> 0 ).

*   * 2. No entry found: Error: not in adm. data

*!!!! error: No entry in administrative data
    class CX_OS_OBJECT_STATE definition load.
    raise exception type CX_OS_OBJECT_STATE
         exporting OBJECT = I_OBJECT
                   TEXTID = CX_OS_OBJECT_STATE=>UNMANAGED.

  else." ( entry found )

*   * 3. Entry found

    if ( not CURRENT_SPECIAL_OBJECT_INFO-OID is initial ).

*     * 3a. if persistent: return OID
      RESULT = CURRENT_SPECIAL_OBJECT_INFO-OID.

    else. "( no OID - it must be a transient object )

*     * 3b. if transient: Error: Transient object.

*!!!! error: transient object
      class CX_OS_OBJECT_STATE definition load.
      raise exception type CX_OS_OBJECT_STATE
           exporting OBJECT = I_OBJECT
                     TEXTID = CX_OS_OBJECT_STATE=>TRANSIENT.

    endif. "( OID? )
  endif." ( entry found? )

           "IF_OS_CA_SERVICE~GET_OID_BY_REF
  endmethod.


  method IF_OS_CA_SERVICE~GET_REF_BY_OID.
***BUILD 090501
     " importing I_OID        type OS_GUID
     " returning result       type ref to object
************************************************************************
* Purpose        : Get an object reference for a given OID. If no
*                  object exists, create a new representative object
*                  identified by the given OID. If it is loaded from
*                  DB, the missing Business key is added to the entry.
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : An object identified by I_OID exists.
*
* OO Exceptions  : propagates OS_PM_CREATED_REPRESENTANT
*
* Implementation : 1. Look for entry in SPECIAL_OBJECT_INFO and check
*                     if it is still valid
*                  2. No entry found:
*                     Create a new representative object identified by
*                     I_OID
*                  3. Entry found: Return object reference
*                  4. Clean up
*
************************************************************************
* Changelog:
* - 2000-03-07   : (BGR) Initial Version 2.0
* - 2000-08-02   : (SB) OO Exceptions
************************************************************************

  clear: CURRENT_OBJECT_IREF.

* * 1. Look for entry in SPECIAL_OBJECT_INFO and check if it is
* *    still valid
  read table SPECIAL_OID_TAB into CURRENT_SPECIAL_OBJECT_INFO
       with table key OID = I_OID.

  if ( sy-subrc = 0 ).

    read table SPECIAL_OBJECT_INFO into CURRENT_SPECIAL_OBJECT_INFO
         with table key
         OBJECT_ID = CURRENT_SPECIAL_OBJECT_INFO-OBJECT_ID.
    call method OS_LOAD_AND_VALIDATE_CURRENT
           exporting I_INDEX = sy-tabix.

  endif.

  if ( CURRENT_OBJECT_IREF is initial ).

*   * 2. No entry found:
*   * Create a new representative object identified by I_OID only

    RESULT = PM_CREATE_REPRESENTANT( I_OID = I_OID ).

    try.
        call method OS_PM_CREATED_REPRESENTANT.
      cleanup.
        clear CURRENT_SPECIAL_OBJECT_INFO.
        call method OS_CLEAR_CURRENT.
    endtry.

  else." ( Entry found )

*   * 3. Entry found: Return object reference
    RESULT ?= CURRENT_OBJECT_IREF.
    call method OS_CLEAR_CURRENT.

  endif." ( entry found? )

* * 4. Clean up
  clear CURRENT_SPECIAL_OBJECT_INFO.

           "IF_OS_CA_SERVICE~GET_REF_BY_OID
  endmethod.


  method IF_OS_CA_SERVICE~SAVE.
***BUILD 090501
************************************************************************
* Purpose        : Prepare data for database (buffer) transfer
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : data is prepared for saving
*                  if UPDATE_MODE is direct, it is saved to DB
*                  if UPDATE_MODE is LOCAL or UPDATE_TASK,
*                    the corresponding function call is registered
*
* Exceptions     : --
*
* OO Exceptions  : propagates MAP_SAVE_TO_DATABASE
*                  propagates MAP_GET_ATTRIBUTES.
*
* Implementation :
*
************************************************************************
* Changelog:
* - 2000-03-02   : (BGR) Initial Version
* - 2000-08-02   : (SB) OO Exceptions
* - 2001-01-06   : (SB) Update with EXPORT TO DATA BUFFER
* - 2003-03-20   : (SB) post only if there dirty instances
************************************************************************

  data: NEW_OBJECT_REF_TAB       type TYP_OBJECT_REF_TAB,
        CHANGED_OBJECT_REF_TAB   type TYP_OBJECT_REF_TAB,
        INSERT_DATA_TAB          type TYP_DB_DATA_TAB ,
        INSERT_OID_TAB           type TYP_OID_TAB ,
        UPDATE_DATA_TAB          type TYP_DB_DATA_TAB ,
        UPDATE_OID_TAB           type TYP_OID_TAB ,
        DELETE_TAB               type TYP_DB_DELETE_TAB ,
        UPDATE_MODE              type OS_DMODE,
        OBJECT_REF               type TYP_OBJECT_REF,
        OBJECT_INDEX             type TYP_INDEX,
        XCONTAINER               type XSTRING.

  field-symbols:
          <FS_OBJECT_INFO_ITEM>         type TYP_OBJECT_INFO,
          <FS_SPECIAL_OBJECT_INFO_ITEM> type TYP_SPECIAL_OBJECT_INFO.

* * 1. get strong reference, OID for all objects with status
* *    NEW, CHANGED or DELETED

  loop at OBJECT_INFO assigning <FS_OBJECT_INFO_ITEM> "#EC CI_SORTSEQ
       where ( PM_STATUS = OSCON_OSTATUS_NEW or       "#EC CI_SORTSEQ
               PM_STATUS = OSCON_OSTATUS_CHANGED or   "#EC CI_SORTSEQ
               PM_STATUS = OSCON_OSTATUS_DELETED ) and "#EC CI_SORTSEQ
               OM_IGNORE = OSCON_FALSE.               "#EC CI_SORTSEQ

    OBJECT_INDEX = sy-tabix.

    case <FS_OBJECT_INFO_ITEM>-PM_STATUS.

      when OSCON_OSTATUS_NEW.

        read table SPECIAL_OBJECT_INFO
             assigning <FS_SPECIAL_OBJECT_INFO_ITEM>
             index OBJECT_INDEX.

        OBJECT_REF ?= <FS_OBJECT_INFO_ITEM>-OBJECT_IREF.
        append OBJECT_REF
            to NEW_OBJECT_REF_TAB.
        append <FS_SPECIAL_OBJECT_INFO_ITEM>-OID
            to INSERT_OID_TAB.

      when OSCON_OSTATUS_CHANGED.

        read table SPECIAL_OBJECT_INFO
             assigning <FS_SPECIAL_OBJECT_INFO_ITEM>
             index OBJECT_INDEX.

        OBJECT_REF ?= <FS_OBJECT_INFO_ITEM>-OBJECT_IREF.
        append OBJECT_REF
            to CHANGED_OBJECT_REF_TAB.
        append <FS_SPECIAL_OBJECT_INFO_ITEM>-OID
            to UPDATE_OID_TAB.

      when OSCON_OSTATUS_DELETED.

        read table SPECIAL_OBJECT_INFO
             assigning <FS_SPECIAL_OBJECT_INFO_ITEM>
             index OBJECT_INDEX.

        append <FS_SPECIAL_OBJECT_INFO_ITEM> to DELETE_TAB.

    endcase." Status

  endloop. "at OBJECT_INFO


* * 2. get attributes for new and changed objects

* * New Objects
  if ( not NEW_OBJECT_REF_TAB is initial ).

    call method MAP_GET_ATTRIBUTES
         exporting I_OBJECT_REF_TAB  = NEW_OBJECT_REF_TAB
         importing E_OBJECT_DATA_TAB = INSERT_DATA_TAB.

    call method MAP_MERGE_IDENTIFIER
         exporting I_OID_TAB          = INSERT_OID_TAB
         changing  C_DB_DATA_TAB      = INSERT_DATA_TAB.

  endif. "( not NEW_OBJECT_REF_TAB is initial ).

* * Changed Objects
  if ( not CHANGED_OBJECT_REF_TAB is initial ).

    call method MAP_GET_ATTRIBUTES
         exporting I_OBJECT_REF_TAB  = CHANGED_OBJECT_REF_TAB
         importing E_OBJECT_DATA_TAB = UPDATE_DATA_TAB.

    call method MAP_MERGE_IDENTIFIER
         exporting I_OID_TAB          = UPDATE_OID_TAB
         changing  C_DB_DATA_TAB      = UPDATE_DATA_TAB.

  endif. "( not CHANGED_OBJECT_REF_TAB is initial ).

* * 3. perform or subscribe DB operations

  if ( ( INSERT_DATA_TAB is not initial ) or
       ( UPDATE_DATA_TAB is not initial ) or
       ( DELETE_TAB is not initial ) ).

    UPDATE_MODE = PERSISTENCY_MANAGER->GET_UPDATE_MODE(  ).
    if ( UPDATE_MODE = DMODE_DIRECT ).

*     * Direct DB operations
      call method MAP_SAVE_TO_DATABASE
           exporting I_INSERTS = INSERT_DATA_TAB
                     I_UPDATES = UPDATE_DATA_TAB
                     I_DELETES = DELETE_TAB.

    else." ( Update task )

*     * export data to be saved to DB to data buffer
      export
        INSERT_DATA_TAB = INSERT_DATA_TAB
        UPDATE_DATA_TAB = UPDATE_DATA_TAB
        DELETE_TAB      = DELETE_TAB
          to data buffer XCONTAINER.

*     * call update function in update task. this function
*     * calls the method if_os_ca_service~save_in_update_task
*     * of this class agent.
      call function 'OS_UPDATE_CLASS' in update task
        exporting
          CLASSNAME = CLASS_INFO-CLASS_AGENT_NAME
          XCONTAINER = XCONTAINER.

    endif." (Update mode?)

  endif." (something to post?)

           "IF_OS_CA_SERVICE~SAVE
  endmethod.


  method IF_OS_CA_SERVICE~SAVE_IN_UPDATE_TASK.
***BUILD 090501
     " importing XCONTAINER type XSTRING optional
************************************************************************
* Purpose        : save object data to DB when running in update task
*                  mode.
*
* Version        : 2.0
*
* Precondition   : no object service environment is set, no objects
*                  exist in update task
*
* Postcondition  : data has been saved to DB
*
* OO Exceptions  : propagates MAP_SAVE_TO_DATABASE
*
* Implementation :
*
************************************************************************
* Changelog:
* - 2000-03-02   : (BGR) Initial Version
* - 2000-08-02   : (SB) OO Exceptions
* - 2001-01-06   : (SB) Update with EXPORT TO DATA BUFFER
************************************************************************

  data: INSERT_DATA_TAB       type TYP_DB_DATA_TAB ,
        UPDATE_DATA_TAB       type TYP_DB_DATA_TAB ,
        DELETE_TAB            type TYP_DB_DELETE_TAB .

* * import data to be saved to DB from data buffer
  import
    INSERT_DATA_TAB = INSERT_DATA_TAB
    UPDATE_DATA_TAB = UPDATE_DATA_TAB
    DELETE_TAB      = DELETE_TAB
      from data buffer XCONTAINER.

* * store them to DB
  call method MAP_SAVE_TO_DATABASE
       exporting I_INSERTS = INSERT_DATA_TAB
                 I_UPDATES = UPDATE_DATA_TAB
                 I_DELETES = DELETE_TAB.

           "IF_OS_CA_SERVICE~SAVE_IN_UPDATE_TASK
  endmethod.


  method IF_OS_FACTORY~CREATE_PERSISTENT.
***BUILD 093901
*      returning RESULT type ref to ZCL_ANT
************************************************************************
* Purpose        : Create a new persistent object
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : The object exists in memory and will result in a
*                  new entry on database when the top transaction is
*                  closed.
*
* OO Exceptions  : propagates CREATE_PERSISTENT
*
* Implementation : calls CREATE_PERSISTENT
*
************************************************************************
* Changelog:
* - 2000-08-03   : (SB) Initial Version 2.0
* - 2000-08-03   : (SB) OO Exceptions
************************************************************************

  call method CREATE_PERSISTENT
       receiving result = result.

           "IF_OS_FACTORY~CREATE_PERSISTENT
  endmethod.


  method IF_OS_FACTORY~CREATE_TRANSIENT.
***BUILD 093901
*      returning RESULT type ref to ZCL_ANT
************************************************************************
* Purpose        : Create a new transient object
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : The object exists in memory until it is RELEASEd
*
* OO Exception   : propagates CREATE_TRANSIENT
*
* Implementation : calls CREATE_TRANSIENT
*
************************************************************************
* Changelog:
* - 2000-08-03   : (SB) Initial Version 2.0
* - 2000-08-03   : (SB)  OO Exceptions
************************************************************************

  call method CREATE_TRANSIENT
       receiving result = result.

           "IF_OS_FACTORY~CREATE_TRANSIENT
  endmethod.


  method LOAD_SPECIAL_OBJECT_INFO.
***BUILD 090501
************************************************************************
* Purpose        : Load CURRENT_SPECIAL_OBJECT_INFO from
*                  SPECIAL_OBJECT_INFO
*
* Version        : 2.0
*
* Precondition   : Index is set in CURRENT_OBJECT_INDEX
*
* Postcondition  : entry is loaded
*
* OO Exceptions  : -
*
* Implementation : -
*
************************************************************************
* Changelog:
* - 2000-03-02   : (BGR) Initial Version
************************************************************************

  read table SPECIAL_OBJECT_INFO into CURRENT_SPECIAL_OBJECT_INFO
       index CURRENT_OBJECT_INDEX.

           "LOAD_SPECIAL_OBJECT_INFO
  endmethod.


  method MAP_EXTRACT_IDENTIFIER.
***BUILD 093901
     " importing I_DB_DATA type TYP_DB_DATA
     " exporting E_OID          type TYP_OID
************************************************************************
* Purpose        : Extract OID from given DB_DATA
*
* Version        : 2.0
*
* Precondition   : DB_DATA is a structure with object data read from
*                  DB including GUID
*
* Postcondition  : E_OID is the OID extracted from I_DB_DATA
*
* OO Exceptions  : --
*
* Implementation :
*
************************************************************************
* Changelog:
* - 2000-03-06   : (BGR) Initial Version
* - 2000-08-02   : (SB) OO Exceptions
************************************************************************
* Generated! Do not modify!
************************************************************************

  E_OID = I_DB_DATA-OS_OID.

           "MAP_EXTRACT_IDENTIFIER
  endmethod.


method MAP_GET_ATTRIBUTES.
***BUILD 090501
     " importing I_OBJECT_REF_TAB  type TYP_OBJECT_REF_TAB
     " exporting value(E_OBJECT_DATA_TAB) type TYP_DB_DATA_TAB
************************************************************************
* Purpose        : Get object data from objects
*
* Version        : 2.0
*
* Precondition   : I_OBJECT_REF_TAB is a list of objects that have a
*                  valid state (new, changed)
*
* Postcondition  : E_OBJECT_DATA_TAB contains all object data of the
*                  given objects. It is a table of the same size like
*                  I_OBJECT_REF_TAB with corresponding entries.
*                  GUID (and Business Key) will be added later.
*
* OO Exceptions  : CX_OS_OBJECT_REFERENCE collects GET_OID_BY_REF
*
* Implementation :
*
************************************************************************
* Changelog:
* - 2000-03-06   : (BGR) Initial Version
* - 2000-08-02   : (SB)  OO Exceptions
* - 2002-01-17   : (SB)  private attributes in super classes
************************************************************************
* Generated! Do not modify!
************************************************************************

  data: THE_OBJECT       type ref to ZCL_ANT,
        OBJECT_DATA_ITEM type        TYP_DB_DATA,
        PM_SERVICE       type ref to IF_OS_PM_SERVICE. "#EC NEEDED

  data: EX     type ref to CX_OS_ERROR, "#EC NEEDED
        EX_SYS type ref to CX_OS_SYSTEM_ERROR, "#EC NEEDED
        EX_TAB type OSTABLEREF.

  PM_SERVICE ?= PERSISTENCY_MANAGER.

  loop at I_OBJECT_REF_TAB into THE_OBJECT.

    clear OBJECT_DATA_ITEM.

*<  Generated from mapping:
    OBJECT_DATA_ITEM-DAYS_ALIVE = THE_OBJECT->DAYS_ALIVE.
*>

    append OBJECT_DATA_ITEM to E_OBJECT_DATA_TAB.

  endloop."at I_OBJECT_REF_TAB

  if ( not EX_TAB is initial ).
    raise exception type CX_OS_OBJECT_REFERENCE
          exporting EXCEPTION_TAB = EX_TAB.
  endif.

           "MAP_GET_ATTRIBUTES
endmethod.
"#EC CI_VALPAR


  method MAP_INITIALIZE_METADATA.
***BUILD 090501
************************************************************************
* Purpose        : Initialize the mapping metadata,
*
* Version        : 2.0
*
* Precondition   : -
*
* Postcondition  : The mapping metadata table MAP_ATT_INFO_TAB
*                  contains an entry for all persistent attributes
*                  accessible from a query expression
*
* OO Exceptions  : -
*
* Implementation : -
*
************************************************************************
* Changelog:
* - 2004-03-25   : (SB)  Initial Version
************************************************************************


  data: MAP_ATT_INFO type OSTYP_RT_MAP_ATT_INFO.

  if MAP_ATT_INFO_TAB is initial.

    clear MAP_ATT_INFO.
    MAP_ATT_INFO-NAME = 'DAYS_ALIVE'.
    MAP_ATT_INFO-EXPOSURE = '2'.
    MAP_ATT_INFO-RECORDNAME = 'ZPS_ANT'.
    MAP_ATT_INFO-FIELD_NAME1  = 'DAYS_ALIVE'.
    insert MAP_ATT_INFO into table MAP_ATT_INFO_TAB.

  endif.

           "MAP_INITIALIZE_METADATA
  endmethod.


  method MAP_INVALIDATE.
***BUILD 090501
     " importing I_OBJECT_IREF_TAB type TYP_OBJECT_TAB
************************************************************************
* Purpose        : Invalidate state of all objects in I_OBJECT_IREF_TAB
*
* Version        : 2.0
*
* Precondition   : Objects in I_OBJECT_IREF_TAB exist
*
* Postcondition  : Their state in cleared
*
* OO Exceptions  : --
*
* Implementation : - call method IF_OS_STATE~INVALIDATE
*                  - clear object's (persistent) attributes
*
************************************************************************
* Changelog:
* - 2000-04-17   : (BGR) Initial Version
* - 2000-08-02   : (SB)  OO Exceptions
* - 2002-01-17   : (SB)  private attributes in super classes
************************************************************************

  data: OBJECT_IREF type TYP_OBJECT_IREF,
        THE_OBJECT  type ref to ZCL_ANT.

  loop at I_OBJECT_IREF_TAB into OBJECT_IREF.

    if ( not OBJECT_IREF is initial ).

      call method OBJECT_IREF->INVALIDATE.

      THE_OBJECT ?= OBJECT_IREF.

*<    Generated from Mapping:
      clear: THE_OBJECT->DAYS_ALIVE.
*>

    endif. "( not initial )

  endloop. "at I_OBJECT_IREF_TAB

           "MAP_INVALIDATE
  endmethod.


method MAP_LOAD_FROM_DATABASE.
***BUILD 090501
     " importing I_WHERE_CLAUSE type STRING optional
     "           I_ORDER_BY_CLAUSE type STRING optional
     "           I_SUBCLASSES type OS_BOOLEAN default OSCON_FALSE
     "           I_UPTO type I value 0
     "           PAR1 type ANY optional
     "           PAR2 type ANY optional
     "           PAR3 type ANY optional
     " returning value(RESULT) type TYP_DB_DATA_TAB
************************************************************************
* Purpose        : Load object data identified by I_WHERE_CLAUSE with
*                  PAR1, PAR2 and PAR3 from DB to DB_DATA Table
*
* Version        : 2.0
*
* Precondition   : I_WHERE_CLAUSE is valid where clause in Open-SQL
*
* Postcondition  : RESULT is the corresponding table of object
*                  attributes read from DB
*
* OO Exceptions  : CX_OS_DB_SELECT
*
* Implementation : -
*
************************************************************************
* Changelog:
* - 2004-03-25   : (SB)  Initial Version
* - 2005-04-06   : (SB)  Single Table
************************************************************************


  data: DB_DATA           type TYP_DB_DATA.

*< Generated from mapping:
  types: TYP_DB_DATA_LOCAL type ZPS_ANT.
*>

  types:
    TYP_DB_DATA_LOCAL_TAB type standard table of
      TYP_DB_DATA_LOCAL with non-unique default key .

  data: DB_DATA_LOCAL_TAB type TYP_DB_DATA_LOCAL_TAB.

  field-symbols: <FS_DB_DATA_LOCAL> type TYP_DB_DATA_LOCAL.

*< Generated from mapping:
  field-symbols: <FS_DB_ZPS_ANT> type ZPS_ANT.
*>

*< Generated from mapping:
  select * from ZPS_ANT
           up to I_UPTO rows
           into table DB_DATA_LOCAL_TAB
           where (I_WHERE_CLAUSE)
           order by (I_ORDER_BY_CLAUSE).
*>

*   * error handling
  if ( SY-SUBRC <> 0 ).
    class CX_OS_DB_SELECT definition load.
    raise exception type CX_OS_DB_SELECT
         exporting TABLE  = 'ZPS_ANT'
                   WHERE_CLAUSE = I_WHERE_CLAUSE
                   TEXTID = CX_OS_DB_SELECT=>BY_QUERY.
  endif. "( Error )

  loop at DB_DATA_LOCAL_TAB assigning <FS_DB_DATA_LOCAL>.

    assign <FS_DB_DATA_LOCAL> to <FS_DB_ZPS_ANT>.

*< Generated from mapping:
    DB_DATA-DAYS_ALIVE = <FS_DB_ZPS_ANT>-DAYS_ALIVE.
    DB_DATA-OS_OID = <FS_DB_ZPS_ANT>-GUID.
*>

    append DB_DATA to RESULT.

  endloop." at DB_DATA_LOCAL_TAB

           "MAP_LOAD_FROM_DATABASE
endmethod.
"#EC CI_VALPAR


method MAP_LOAD_FROM_DATABASE_GUID.
***BUILD 090501
     " importing I_OID_TAB type TYP_OID_TAB
     " returning value(RESULT) type TYP_DB_DATA_TAB
************************************************************************
* Purpose        : Load object data identified by I_OID_TAB
*                  from DB to DB_DATA Table
*
* Version        : 2.0
*
* Precondition   : I_OID_TAB is a table of valid GUIDs in the DB table
*
* Postcondition  : RESULT is the corresponding table of object
*                  attributes read from DB
*
* OO Exceptions  : CX_OS_DB_SELECT
*
* Implementation : -
*
************************************************************************
* Changelog:
* - 1999-09-21   : (OS)  Initial Version
* - 2000-03-06   : (BGR) Version 2.0
* - 2000-06-19   : (BGR) Support for multi-table loading
* - 2000-08-02   : (SB)  OO Exceptions
* - 2001-11-26   : (SB)  Refactoring Generation
* - 2002-01-17   : (SB)  private attributes in super classes
* - 2004-01-07   : (SB)  Multi Access
* - 2005-02-22   : (SB)  Inner Joins
* - 2005-04-06   : (SB)  Single Table
************************************************************************


  data: DB_DATA           type TYP_DB_DATA.

*< Generated from mapping:
  types: TYP_DB_DATA_LOCAL type ZPS_ANT.
*>

  types:
    TYP_DB_DATA_LOCAL_TAB type standard table of
      TYP_DB_DATA_LOCAL with non-unique default key .

  data: DB_DATA_LOCAL_TAB type TYP_DB_DATA_LOCAL_TAB.

  field-symbols: <FS_DB_DATA_LOCAL> type TYP_DB_DATA_LOCAL.

*< Generated from mapping:
  field-symbols: <FS_DB_ZPS_ANT> type ZPS_ANT.
*>

*< Generated from mapping:
  select * from ZPS_ANT
           into table DB_DATA_LOCAL_TAB
           for all entries in I_OID_TAB
           where ZPS_ANT~GUID = I_OID_TAB-TABLE_LINE.
*>

* * error handling
  if ( SY-SUBRC <> 0 ).
    class CX_OS_DB_SELECT definition load.
    raise exception type CX_OS_DB_SELECT
         exporting TABLE  = 'ZPS_ANT'
                   TEXTID = CX_OS_DB_SELECT=>BY_OIDTAB.
  endif. "( Error )

  loop at DB_DATA_LOCAL_TAB assigning <FS_DB_DATA_LOCAL>.

    assign <FS_DB_DATA_LOCAL> to <FS_DB_ZPS_ANT>.

*< Generated from mapping:
    DB_DATA-DAYS_ALIVE = <FS_DB_ZPS_ANT>-DAYS_ALIVE.
    DB_DATA-OS_OID = <FS_DB_ZPS_ANT>-GUID.
*>

    append DB_DATA to RESULT.

  endloop." at DB_DATA_LOCAL_TAB

           "MAP_LOAD_FROM_DATABASE_GUID
endmethod.
"#EC CI_VALPAR


  method MAP_MERGE_IDENTIFIER.
***BUILD 093901
     " importing I_OID_TAB          type TYP_OID_TAB
     " changing C_DB_DATA_TAB type TYP_DB_DATA_TAB
************************************************************************
* Purpose        : Merge Table I_OID_TAB to C_DB_DATA_TAB.
*                  The result is a complete DB_DATA table to be stored
*                  in DB.
*
* Version        : 2.0
*
* Precondition   : C_DB_DATA is a Table filled with object data except
*                  for GUID. I_OID_TAB is a table of the same size with
*                  corresponding entries.
*
* Postcondition  : C_DB_DATA_TAB is complete
*
* OO Exceptions  : --
*
* Implementation :
*
************************************************************************
* Changelog:
* - 2000-03-06   : (BGR) Initial Version
* - 2000-08-02   : (SB) OO Exceptions
************************************************************************
* Generated! Do not modify!
************************************************************************

  data: OID          type TYP_OID.

  field-symbols <FS_OBJECT_DATA> type TYP_DB_DATA.

  loop at C_DB_DATA_TAB assigning <FS_OBJECT_DATA>.

    read table I_OID_TAB into OID index sy-tabix.
    <FS_OBJECT_DATA>-OS_OID = OID.


  endloop." at C_DB_DATA_TAB

           "MAP_MERGE_IDENTIFIER
  endmethod.


  method MAP_SAVE_TO_DATABASE.
***BUILD 090501
     " importing I_DELETES type TYP_DB_DELETE_TAB
     "           I_INSERTS type TYP_DB_DATA_TAB
     "           I_UPDATES type TYP_DB_DATA_TAB
************************************************************************
* Purpose        : Do database operations:
*                  Insert new object data from I_INSERTS,
*                  Update changed object data from I_UPDATES and
*                  Delete entries for deleted objects from I_DELETES
*
* Version        : 2.0
*
* Precondition   : I_DELETES,I_INSERTS and I_UPDATES contain ALL
*                  necessary information (GUIDs, Data)
*                  If this method is called in update task, there
*                  is NO MORE information, no objects exist anymore.
*
* Postcondition  : All database operations have been performed.
*
* OO Exceptions  : CX_OS_DB_INSERT, CX_OS_DB_UPDATE, CX_OS_DB_DELETE
*
* Implementation : -
*
************************************************************************
* Changelog:
* - 1999-09-21   : (OS)  Initial Version
* - 2000-03-06   : (BGR) Version 2.0
* - 2000-06-19   : (BGR) Support for multi-table loading
* - 2000-07-28   : (SB)  OO Exceptions
* - 2001-11-26   : (SB)  Refactoring Generation
* - 2002-01-17   : (SB)  private attributes in super classes
************************************************************************

*< Generated from mapping:

* * ZPS_ANT: internal tables for mass operation
  data DB_ITB_ZPS_ANT type standard table of ZPS_ANT.
  data DB_UTB_ZPS_ANT type standard table of ZPS_ANT.
  data DB_DTB_ZPS_ANT type standard table of ZPS_ANT.

* * ZPS_ANT: headlines for tables
  data DB_ILN_ZPS_ANT type ZPS_ANT.
  data DB_ULN_ZPS_ANT type ZPS_ANT.
  data DB_DLN_ZPS_ANT type ZPS_ANT.

*>

  field-symbols <FS_INSERT> type TYP_DB_DATA.
  field-symbols <FS_UPDATE> type TYP_DB_DATA.
  field-symbols <FS_DELETE> type TYP_SPECIAL_OBJECT_INFO.

* * Collect Inserts
  loop at I_INSERTS assigning <FS_INSERT>.

*< Generated from mapping:

   DB_ILN_ZPS_ANT-DAYS_ALIVE = <FS_INSERT>-DAYS_ALIVE.


   DB_ILN_ZPS_ANT-GUID = <FS_INSERT>-OS_OID.
   append DB_ILN_ZPS_ANT to DB_ITB_ZPS_ANT.
*>

  endloop. "at I_INSERTS

* * Collect Updates
  loop at I_UPDATES assigning <FS_UPDATE>.

*< Generated from mapping:

   DB_ULN_ZPS_ANT-DAYS_ALIVE = <FS_UPDATE>-DAYS_ALIVE.


   DB_ULN_ZPS_ANT-GUID = <FS_UPDATE>-OS_OID.
   append DB_ULN_ZPS_ANT to DB_UTB_ZPS_ANT.
*>

  endloop. "at I_UPDATES

* * Collect Deletes
  loop at I_DELETES assigning <FS_DELETE>.

    DB_DLN_ZPS_ANT-GUID = <FS_DELETE>-OID.

    append DB_DLN_ZPS_ANT to DB_DTB_ZPS_ANT.

  endloop. "at I_DELETES

* * Perform DB Operations:

*< Generated from mapping:

* * DB Deletes
  delete ZPS_ANT from table DB_DTB_ZPS_ANT.
  if sy-subrc <> 0.
    raise exception type CX_OS_DB_DELETE
      exporting
        table = 'ZPS_ANT'.
  endif.

* * DB Inserts
  insert ZPS_ANT from table DB_ITB_ZPS_ANT
    accepting duplicate keys.
  if sy-subrc <> 0.
    raise exception type CX_OS_DB_INSERT
      exporting
        table = 'ZPS_ANT'.
  endif.

* * DB Updates
  update ZPS_ANT from table DB_UTB_ZPS_ANT.
  if sy-subrc <> 0.
    raise exception type CX_OS_DB_UPDATE
      exporting
        table = 'ZPS_ANT'.
  endif.

*>
           "MAP_SAVE_TO_DATABASE
  endmethod.


  method MAP_SET_ATTRIBUTES.
***BUILD 090501
     " importing I_OBJECT_DATA type TYP_DB_DATA
     "           I_OBJECT_REF  type TYP_OBJECT_REF
     " raising   CX_OS_OBJECT_NOT_FOUND
************************************************************************
* Purpose        : Set object from given object data
*
* Version        : 2.0
*
* Precondition   : I_OBJECT_REF is a reference to the object that will
*                  be set with data from I_OBJECT_DATA
*
* Postcondition  : The object's attributes are set.
*
* OO Exceptions  : CX_OS_OBJECT_NOT_FOUND
*
* Implementation :
*
************************************************************************
* Changelog:
* - 2000-03-06   : (BGR) Initial Version
* - 2000-08-02   : (SB)  OO Exceptions
* - 2002-01-17   : (SB)  private attributes in super classes
************************************************************************
* Generated! Do not modify!
************************************************************************

  data: THE_OBJECT type ref to ZCL_ANT,
        AN_OBJECT  type ref to object, "#EC NEEDED
        PM_SERVICE type ref to IF_OS_PM_SERVICE. "#EC NEEDED

  PM_SERVICE ?= PERSISTENCY_MANAGER.
  THE_OBJECT = I_OBJECT_REF.

*< Generated from mapping:
  THE_OBJECT->DAYS_ALIVE = I_OBJECT_DATA-DAYS_ALIVE.
*>

           "MAP_SET_ATTRIBUTES
  endmethod.


  method OS_PM_DELETE_PERSISTENT.
***BUILD 090501
************************************************************************
* Purpose        : Delete persistent object. It is marked DELETED in
*                  memory and removed from DB when the top transaction
*                  is closed.
*
* Version        : 2.0
*
* Precondition   : The object is persistent (not transient), CURRENT
*                  is set
*
* Postcondition  : Instance is marked for deletion.
*
* OO Exceptions  : propagates PM_DELETE_PERSISTENT
*
* Implementation : load special object info and
*                  call PM_DELETE_PERSISTENT
*
************************************************************************
* Changelog:
* - 2001-12-14   : (SB)  Initial Version
************************************************************************

  call method LOAD_SPECIAL_OBJECT_INFO( ).

  call method PM_DELETE_PERSISTENT( ).

           "OS_PM_DELETE_PERSISTENT .
  endmethod.


  method PM_CHECK_AND_SET_ATTRIBUTES.
***BUILD 090501
     " importing I_OBJECT_DATA  type TYP_DB_DATA
     " importing I_OID          type TYP_BUSINESS_KEY optional
     "           I_ID_PROVIDED type TYP_ID_STATUS default ID_STATUS_NONE
************************************************************************
* Purpose        : check loaded object data of a persistent object and
*                  set object's attributes
*                  if CURRENT is clear, create new representant,
*                  if CURRENT is set, use this object to set the loaded
*                  data
*                  If I_ID_PROVIDED is set to ID_STATUS_NONE, Look for
*                  an entry in SPECIAL_OBJECT_INFO with the given OID
*                  The idea behind this is to create a object with
*                  loaded data, not used by the standard, only extension
*
* Version        : 2.0
*
* Precondition   :
*
* Postcondition  : Persistent object data is checked and object
*                  attributes are set. CURRENT is set.
*
* OO Exception   : CX_OS_OBJECT_STATE(INTERNAL_CHANGED,INTERNAL_DELETED,
*                                     INTERNAL_TRANSIENT, INTERNAL_NEW)
*                  propagates MAP_SET_ATTRIBUTES
*
* Implementation : 1. If CURRENT is clear:
*                   1a. I_ID_PROVIDED = ID_STATUS_NONE?:
*                       Check if another object exists with this OID
*                   1b. I_ID_PROVIDED <> ID_STATUS_NONE or no entry
*                       found:
*                       Create a new Representative object
*                   1c. If an object has been found:
*                       Check if it is allowed to set it
*                  2. set PM_DBSTATUS EXISTING
*                  3. Temporarily save CURRENT_*
*                  4. set object attributes (resolving references)
*                  5. restore CURRENT_*
*
*
************************************************************************
* Changelog:
* - 2000-05-17   : (BGR) Initial Version 2.0
* - 2000-08-02   : (SB) OO Exceptions
************************************************************************

  data: LOADED_OID          type TYP_OID.

  data: TEMP_CURRENT_OBJECT_INFO  type TYP_OBJECT_INFO,
        TEMP_CURRENT_OBJECT_INDEX type TYP_INDEX,
        TEMP_CURRENT_SPECIAL_OI   type TYP_SPECIAL_OBJECT_INFO,
        TEMP_CURRENT_OBJECT_IREF  type TYP_OBJECT_IREF,
        INTERNAL_UNDO_INFO_ITEM   type TYP_INTERNAL_UNDO_INFO,
        TEMP_OBJECT_REF           type TYP_OBJECT_REF.

* * Get OID from DB data
  call method MAP_EXTRACT_IDENTIFIER
       exporting I_DB_DATA = I_OBJECT_DATA
       importing E_OID     = LOADED_OID.

  if ( CURRENT_OBJECT_IREF is initial ).

*   * 1. If CURRENT is clear:

    if ( I_ID_PROVIDED = ID_STATUS_NONE ).

*   * 1a. Check if another object exists with this OID

      read table SPECIAL_OID_TAB into TEMP_CURRENT_SPECIAL_OI
           with table key OID = LOADED_OID.
      if ( sy-subrc = 0 ).

        read table SPECIAL_OBJECT_INFO into
             CURRENT_SPECIAL_OBJECT_INFO
             with table key
             OBJECT_ID = TEMP_CURRENT_SPECIAL_OI-OBJECT_ID.
        call method OS_LOAD_AND_VALIDATE_CURRENT
             exporting I_INDEX = sy-tabix.

      endif. " ( Entry found for OID? )

    endif. "( no ID Provided )

    if ( CURRENT_OBJECT_IREF is initial ).

*     * 1b. Create a new Representative object and a new entry
      call method PM_CREATE_REPRESENTANT
           exporting I_OID = LOADED_OID.

    else. "( Found an entry for the OID )

*     * Now we know an entry exists on DB
      CURRENT_OBJECT_INFO-PM_DBSTATUS = OSCON_DBSTATUS_EXISTING.
      modify OBJECT_INFO from CURRENT_OBJECT_INFO
             index CURRENT_OBJECT_INDEX.

*     * 1c. Check if it is allowed to use the found object.
      case CURRENT_OBJECT_INFO-PM_STATUS.

*       * PM_STATUS = NOT_LOADED: re-use entry and object
        when OSCON_OSTATUS_NOT_LOADED.

*       * PM_STATUS = LOADED: re-use entry and object
        when OSCON_OSTATUS_LOADED.

*       *  other PM_STATUS: Error!
        when OSCON_OSTATUS_NEW.

*!!!!!!!!!! Error! Object already exists on DB
*         * This NEW object should be created on DB by the next
*         * COMMIT. Now an entry was found with the same key!
          class CX_OS_OBJECT_STATE definition load.
          raise exception type CX_OS_OBJECT_STATE
               exporting OBJECT = CURRENT_OBJECT_IREF
                         TEXTID = CX_OS_OBJECT_STATE=>INTERNAL_NEW.

        when OSCON_OSTATUS_CHANGED.

*!!!!!!!!!!! Error: Object has a DB relevant status
          class CX_OS_OBJECT_STATE definition load.
          raise exception type CX_OS_OBJECT_STATE
               exporting OBJECT = CURRENT_OBJECT_IREF
                         TEXTID = CX_OS_OBJECT_STATE=>INTERNAL_CHANGED.

        when OSCON_OSTATUS_DELETED.

*!!!!!!!!!!! Error: Object marked for deletion
          class CX_OS_OBJECT_STATE definition load.
          raise exception type CX_OS_OBJECT_STATE
               exporting OBJECT = CURRENT_OBJECT_IREF
                         TEXTID = CX_OS_OBJECT_STATE=>INTERNAL_DELETED.

        when OSCON_OSTATUS_TRANSIENT.

*!!!!!!!!!!! Error: Object is transient
          class CX_OS_OBJECT_STATE definition load.
          raise exception type CX_OS_OBJECT_STATE
               exporting OBJECT = CURRENT_OBJECT_IREF
                        TEXTID = CX_OS_OBJECT_STATE=>INTERNAL_TRANSIENT.

      endcase.

    endif. "( CURRENT initial? )
  endif. "( CURRENT initial? )

* * 2. set PM_DBSTATUS EXISTING
  CURRENT_OBJECT_INFO-PM_DBSTATUS = OSCON_DBSTATUS_EXISTING.

* * internal Undo entry:
  INTERNAL_UNDO_INFO_ITEM-OBJECT_INDEX = CURRENT_OBJECT_INDEX.
  INTERNAL_UNDO_INFO_ITEM-OBJECT_INFO  = CURRENT_OBJECT_INFO.
  append INTERNAL_UNDO_INFO_ITEM to INTERNAL_UNDO_INFO.
  INTERNAL_NEXT_UNDO_INFO = sy-tabix + 1.

* * To avoid recursive loading of the same object (INIT method)
* * temporarily set status 'LOADING'
  CURRENT_OBJECT_INFO-PM_STATUS = OSCON_OSTATUS_LOADING.
  modify OBJECT_INFO from CURRENT_OBJECT_INFO
         index CURRENT_OBJECT_INDEX.

* * 3. Temporarily save CURRENT_*
  TEMP_CURRENT_OBJECT_IREF  = CURRENT_OBJECT_IREF.
  TEMP_CURRENT_OBJECT_INFO  = CURRENT_OBJECT_INFO.
  TEMP_CURRENT_OBJECT_INDEX = CURRENT_OBJECT_INDEX.
  TEMP_CURRENT_SPECIAL_OI   = CURRENT_SPECIAL_OBJECT_INFO.

* * 4. set object attributes (resolving references)
  TEMP_OBJECT_REF ?= CURRENT_OBJECT_IREF .

  call method MAP_SET_ATTRIBUTES
       exporting I_OBJECT_DATA = I_OBJECT_DATA
                 I_OBJECT_REF  = TEMP_OBJECT_REF.

* * 5. restore CURRENT_*
  CURRENT_OBJECT_INFO          = TEMP_CURRENT_OBJECT_INFO.
  CURRENT_OBJECT_INDEX         = TEMP_CURRENT_OBJECT_INDEX.
  CURRENT_SPECIAL_OBJECT_INFO  = TEMP_CURRENT_SPECIAL_OI.
  CURRENT_OBJECT_IREF          = TEMP_CURRENT_OBJECT_IREF.

* * the method call get_ref_by_oid in map_set_attributes
* * eventually creates new entries in the
* * administrative data tables, it is necessary to
* * to recalculate the index
  read table OBJECT_INFO transporting no fields
     with table key OBJECT_ID = CURRENT_OBJECT_INFO-OBJECT_ID.
  CURRENT_OBJECT_INDEX = sy-tabix.

           "PM_CHECK_AND_SET_ATTRIBUTES
  endmethod.


  method PM_CREATE_REPRESENTANT.
***BUILD 093901
     " importing I_OID          type TYP_OID optional
     " returning result         type TYP_OBJECT_REF
************************************************************************
* Purpose        : Create a new representative object including a new
*                  entry in administrative data (OBJECT_INFO and
*                  SPECIAL_OBJECT_INFO)
*
* Version        : 2.0
*
* Precondition   : --
*
* Postcondition  : A new object exists, corresponding entries in
*                  OBJECT_INFO and SPECIAL_OBJECT_INFO have been
*                  inserted, CURRENT is set
*
* OO Exceptions  : --
*
* Implementation : 1. Create object
*                  2. Get internal OID for the new object
*                  3. Create new entry in SPECIAL_OBJECT_INFO
*                  4. Let super class create a new entry in OBJECT_INFO
*
************************************************************************
* Changelog:
* - 2000-03-07   : (BGR) Initial Version 2.0
* - 2000-08-02   : (SB)  OO Exceptions
* - 2001-11-14   : (SB)  Type Mapping
* - 2001-11-27   : (SB)  No entry for transient instances
*                        in SPECIAL_OID_TAB
************************************************************************

  data: NEW_OBJECT type ref to ZCL_ANT.

* * 1. Create object
  create object NEW_OBJECT.

* * 2. Get internal OID for the new object and set CURRENT_SPECIAL_OI
  clear CURRENT_SPECIAL_OBJECT_INFO.

  CURRENT_SPECIAL_OBJECT_INFO-OBJECT_ID =
      OS_GET_INTERNAL_OID_BY_REF( I_OBJECT = NEW_OBJECT ).
  CURRENT_SPECIAL_OBJECT_INFO-OID       = I_OID.
  CURRENT_SPECIAL_OBJECT_INFO-ID_STATUS = ID_STATUS_COMPLETE.

* * 3. Create new entry in SPECIAL_OBJECT_INFO
  insert CURRENT_SPECIAL_OBJECT_INFO into table SPECIAL_OBJECT_INFO.
  if ( I_OID is supplied ).
    insert CURRENT_SPECIAL_OBJECT_INFO into table SPECIAL_OID_TAB.
  endif.

* * 4. Let super class create a new entry in OBJECT_INFO
  call method OS_CREATE_NEW_ENTRY_FOR_REPR
       exporting I_OBJECT = NEW_OBJECT
                 I_INTERNAL_OID = CURRENT_SPECIAL_OBJECT_INFO-OBJECT_ID.

  result = NEW_OBJECT.

           "PM_CREATE_REPRESENTANT
  endmethod.


  method PM_DELETE_PERSISTENT.
***BUILD 090501
************************************************************************
* Purpose        : Delete persistent object. It is marked DELETED in
*                  memory and removed from DB when the top transaction
*                  is closed.
*
* Version        : 2.0
*
* Precondition   : The object is persistent (not transient), CURRENT
*                  is set
*
* Postcondition  : Instance is marked for deletion.
*
* OO Exception   : CX_OS_OBJECT_STATE(CREATED_AND_DELETED,TRANSIENT)
*                  propagates OS_PM_DELETED_PERSISTENT
*
* Implementation : 1. Check the state of the object:
*                    1a. Object is already deleted - done
*                    1b. Object is transient - Error
*                    1c. Object is new, loaded or changed - continue
*                    1d. Object is not_loaded:
*                        Check DBSTATUS:
*                       1d1. DBSTATUS Unknown/Existing - continue
*                       1d2. DBSTATUS Not existing - Error
*                   2. Completion: call OS_PM_DELETED_PERSISTENT
*
************************************************************************
* Changelog:
* - 2000-03-06   : (BGR) Initial Version 2.0
* - 2000-08-02   : (SB) OO Exceptions
************************************************************************

  data: TEMP_CURRENT_OBJECT_IREF type ref to object.

* * 1. Check the state of the object:
  case CURRENT_OBJECT_INFO-PM_STATUS.

  when OSCON_OSTATUS_DELETED.

*   * 1a. Object is already deleted - done
    call method OS_CLEAR_CURRENT.
    clear CURRENT_SPECIAL_OBJECT_INFO.
    exit.

  when OSCON_OSTATUS_TRANSIENT.

*   * 1b. Object is transient - Error
*!! error: object already exists transient
    TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
    call method OS_CLEAR_CURRENT.
    clear CURRENT_SPECIAL_OBJECT_INFO.
    class CX_OS_OBJECT_STATE definition load.
    raise exception type CX_OS_OBJECT_STATE
         exporting OBJECT = TEMP_CURRENT_OBJECT_IREF
                   TEXTID = CX_OS_OBJECT_STATE=>TRANSIENT.

  when OSCON_OSTATUS_NEW     or
       OSCON_OSTATUS_CHANGED or
       OSCON_OSTATUS_LOADED.

*   * 1c. Object is new, loaded or changed - continue

  when OSCON_OSTATUS_NOT_LOADED.

*   * 1d. Object is not_loaded: Check DBSTATUS:
    case CURRENT_OBJECT_INFO-PM_DBSTATUS.


    when OSCON_DBSTATUS_EXISTING
      or OSCON_DBSTATUS_UNKNOWN.

*     * 1d1. DBSTATUS Existing/Unknown - continue

    when OSCON_DBSTATUS_NOT_EXISTING.
*     * 1d2. DBSTATUS Not existing - Error
*!!!! error: No DB entry for the object
      TEMP_CURRENT_OBJECT_IREF = CURRENT_OBJECT_IREF.
      call method OS_CLEAR_CURRENT.
      clear CURRENT_SPECIAL_OBJECT_INFO.
      class CX_OS_OBJECT_STATE definition load.
      raise exception type CX_OS_OBJECT_STATE
           exporting OBJECT = TEMP_CURRENT_OBJECT_IREF
                     TEXTID = CX_OS_OBJECT_STATE=>CREATED_AND_DELETED.

    endcase. "PM_DBSTATUS
  endcase. "PM_STATUS

* * 2. Completion: call OS_PM_DELETED_PERSISTENT
  call method OS_PM_DELETED_PERSISTENT.

  clear CURRENT_SPECIAL_OBJECT_INFO.

           "PM_DELETE_PERSISTENT
  endmethod.


  method PM_LOAD.
***BUILD 090501
************************************************************************
* Purpose        : Load data from DB into Object specified by CURRENT
*
* Version        : 2.0
*
* Precondition   : CURRENT_* is set
*
* Postcondition  : object is loaded or exceptions is raised
*
* OO Exceptions  : propagates PM_LOAD_AND_SET_ATTRIBUTES
*
* Implementation : call PM_LOAD_AND_SET_ATTRIBUTES
*
************************************************************************
* Changelog:
* - 2000-03-02   : (BGR) Initial Version
* - 2000-08-02   : (SB)  OO Exceptions
* - 2000-09-06   : (SB)  export parameter I_OID not provided
* - 2001-11-14   : (SB)  export parameter I_OID provided
* - 2001-11-14   : (SB)  type mapping
************************************************************************

  call method PM_LOAD_AND_SET_ATTRIBUTES
       exporting I_OID = CURRENT_SPECIAL_OBJECT_INFO-OID.

           "PM_LOAD
  endmethod.


  method PM_LOAD_AND_SET_ATTRIBUTES.
***BUILD 090501
     " importing I_OID type TYP_OID optional

************************************************************************
* Purpose        : Load object data of a persistent object and set
*                  object's attributes
*                  if CURRENT is clear, load data using I_OID.
*                  if CURRENT is set, use the OID stored there.
*
* Version        : 2.0
*
* Precondition   : CURRENT can be set (use this object to set attributes
*                  to) or clear.
*
* Postcondition  : Persistent object data is loaded and object
*                  attributes are set. CURRENT is set.
*
* OO Exceptions  : propagates PM_CHECK_AND_SET_ATTRIBUTES
*                  propagates MAP_LOAD_FROM_DATABASE_GUID
*
* Implementation : 1. Check Source of DB Keys: OID from
*                     CURRENT_SPECIAL_OBJECT_INFO or from I_OID
*                  2. Load from Database
*                  2.a. Type Mapping: Set E_TYPE and return if case of
*                       type mismatch
*                  3. Check loaded data and set object's attributes
*
************************************************************************
* Changelog:
* - 2000-03-07   : (BGR) Initial Version 2.0
* - 2000-05-17   : (BGR) use PM_CHECK_AND_SET_ATTRIBUTES
* - 2000-08-02   : (SB) OO Exceptions
* - 2004-01-21   : (SB) Type Mapping Refactoring
* - 2005-02-22   : (SB) Set Exception parameters
************************************************************************

  data: OBJECT_DATA_TAB type TYP_DB_DATA_TAB,
        OBJECT_DATA     type TYP_DB_DATA,
        OID             type TYP_OID,
        OID_TAB         type TYP_OID_TAB.

* * 1. Check Source of DB OID: OID from
* *    CURRENT_SPECIAL_OBJECT_INFO or from I_OID?
  if ( CURRENT_OBJECT_IREF is initial ).

    OID = I_OID.

  else. "( CURRENT is set ).

*   * Get OID from CURRENT_SPECIAL_OBJECT_INFO
    OID = CURRENT_SPECIAL_OBJECT_INFO-OID.

  endif. "( CURRENT set? ).


* * 2. Load from Database
  try.
      append OID to OID_TAB.
      call method MAP_LOAD_FROM_DATABASE_GUID
           exporting I_OID_TAB = OID_TAB
           receiving result = OBJECT_DATA_TAB.
    catch CX_OS_DB_SELECT.
      class CX_OS_OBJECT_NOT_FOUND definition load.
      raise exception type CX_OS_OBJECT_NOT_FOUND
        exporting
          OID    = OID
          TEXTID = CX_OS_OBJECT_NOT_FOUND=>BY_OID.
  endtry.

  read table OBJECT_DATA_TAB into OBJECT_DATA index 1.


* * 3. Now Check the loaded data and set the Object.
  call method PM_CHECK_AND_SET_ATTRIBUTES
       exporting I_OBJECT_DATA  = OBJECT_DATA
                 I_OID          = OID
                 I_ID_PROVIDED  = ID_STATUS_COMPLETE.

           "PM_LOAD_AND_SET_ATTRIBUTES
  endmethod.


  method SAVE_SPECIAL_OBJECT_INFO.
***BUILD 090501
************************************************************************
* Purpose        : Save CURRENT_SPECIAL_OBJECT_INFO into
*                  SPECIAL_OBJECT_INFO
*
* Version        : 2.0
*
* Precondition   : Index is set in CURRENT_OBJECT_INDEX
*
* Postcondition  : entry is saved
*
* OO Exceptions  : -
*
* Implementation : -
*
************************************************************************
* Changelog:
* - 2000-03-02   : (BGR) Initial Version
************************************************************************

  modify SPECIAL_OBJECT_INFO from CURRENT_SPECIAL_OBJECT_INFO
         index CURRENT_OBJECT_INDEX.

           "SAVE_SPECIAL_OBJECT_INFO
  endmethod.
ENDCLASS.
