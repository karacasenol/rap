CLASS zcm_rap_5214 DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS BEGIN OF messages.
    CONSTANTS        BEGIN OF date_interval.
    CONSTANTS         msgid TYPE symsgid VALUE 'ZRAP_MSG_5214'.
    CONSTANTS         msgno TYPE symsgno VALUE '001'.
    CONSTANTS         attr1 TYPE scx_attrname VALUE 'BEGINDATE'.
    CONSTANTS         attr2 TYPE scx_attrname VALUE 'ENDDATE'.
    CONSTANTS         attr3 TYPE scx_attrname VALUE 'TRAVELID'.
    CONSTANTS         attr4 TYPE scx_attrname VALUE ''.
    CONSTANTS       END OF date_interval .
    CONSTANTS       BEGIN OF begin_date_before_system_date.
    CONSTANTS         msgid TYPE symsgid VALUE 'ZRAP_MSG_5214'.
    CONSTANTS         msgno TYPE symsgno VALUE '002'.
    CONSTANTS         attr1 TYPE scx_attrname VALUE 'BEGINDATE'.
    CONSTANTS         attr2 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr3 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr4 TYPE scx_attrname VALUE ''.
    CONSTANTS       END OF begin_date_before_system_date .
    CONSTANTS       BEGIN OF customer_unknown.
    CONSTANTS         msgid TYPE symsgid VALUE 'ZRAP_MSG_5214'.
    CONSTANTS         msgno TYPE symsgno VALUE '003'.
    CONSTANTS         attr1 TYPE scx_attrname VALUE 'CUSTOMERID'.
    CONSTANTS         attr2 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr3 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr4 TYPE scx_attrname VALUE ''.
    CONSTANTS       END OF customer_unknown .
    CONSTANTS       BEGIN OF agency_unknown.
    CONSTANTS         msgid TYPE symsgid VALUE 'ZRAP_MSG_5214'.
    CONSTANTS         msgno TYPE symsgno VALUE '004'.
    CONSTANTS         attr1 TYPE scx_attrname VALUE 'AGENCYID'.
    CONSTANTS         attr2 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr3 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr4 TYPE scx_attrname VALUE ''.
    CONSTANTS       END OF agency_unknown .
    CONSTANTS       BEGIN OF unauthorized.
    CONSTANTS         msgid TYPE symsgid VALUE 'ZRAP_MSG_5214'.
    CONSTANTS         msgno TYPE symsgno VALUE '005'.
    CONSTANTS         attr1 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr2 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr3 TYPE scx_attrname VALUE ''.
    CONSTANTS         attr4 TYPE scx_attrname VALUE ''.
    CONSTANTS       END OF unauthorized .
    CONSTANTS END   OF messages.

    DATA begindate TYPE /dmo/begin_date READ-ONLY.
    DATA enddate TYPE /dmo/end_date READ-ONLY.
    DATA travelid TYPE string READ-ONLY.
    DATA customerid TYPE string READ-ONLY.
    DATA agencyid TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING
        severity   TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid     LIKE if_t100_message=>t100key OPTIONAL
        previous   TYPE REF TO cx_root OPTIONAL
        begindate  TYPE /dmo/begin_date OPTIONAL
        enddate    TYPE /dmo/end_date OPTIONAL
        travelid   TYPE /dmo/travel_id OPTIONAL
        customerid TYPE /dmo/customer_id OPTIONAL
        agencyid   TYPE /dmo/agency_id  OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_rap_5214 IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.
    me->begindate = begindate.
    me->enddate = enddate.
    me->travelid = |{ travelid ALPHA = OUT }|.
    me->customerid = |{ customerid ALPHA = OUT }|.
    me->agencyid = |{ agencyid ALPHA = OUT }|.

  ENDMETHOD.
ENDCLASS.
