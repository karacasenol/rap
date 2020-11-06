CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open      TYPE c LENGTH 1 VALUE 'O', "Open
        accepted  TYPE c LENGTH 1 VALUE 'A', "Accepted
        cancelled TYPE c LENGTH 1 VALUE 'C', "Cancelled,
      END OF travel_status.



    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS calculateTravelID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~calculateTravelID.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setInitialStatus.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS recalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalcTotalPrice.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.


   METHODS is_update_granted IMPORTING has_before_image TYPE abap_bool
                                       overall_status   type /dmo/overall_status
                             RETURNING VALUE(update_granted) TYPE abap_bool.

   METHODS is_delete_granted IMPORTING has_before_image TYPE abap_bool
                                       overall_status   type /dmo/overall_status
                             RETURNING VALUE(delete_granted) TYPE abap_bool.

    METHODS is_create_granted  RETURNING VALUE(create_granted) TYPE abap_bool.


ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD calculateTotalPrice.


     MODIFY ENTITIES of zi_rap_travel_5214 in LOCAL MODE
     ENTITY travel
     EXECUTE recalcTotalPrice
     from CORRESPONDING #( keys )
     REPORTED DATA(execute_reported).

     reported = CORRESPONDING #( deep execute_reported ).



  ENDMETHOD.

  METHOD calculateTravelID.

    READ ENTITIES OF   zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelID ) WITH CORRESPONDING #( keys )
    RESULT  DATA(travels).

    DELETE travels WHERE TravelID IS NOT INITIAL.

    CHECK travels  IS NOT INITIAL.

    SELECT SINGLE FROM zrap_atrav_5214
    FIELDS MAX( travel_id ) AS travelID
    INTO @DATA(max_travelid).

    MODIFY ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FROM VALUE #( FOR travel IN travels INDEX INTO i (
    %tky    = travel-%tky
    TravelID = max_travelid + 1
    %control-TravelID = if_abap_behv=>mk-on  ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD setInitialStatus.

    " read relevant travel instance data
    READ ENTITIES OF   zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelStatus ) WITH CORRESPONDING #( keys )
    RESULT  DATA(travels).

    DELETE travels WHERE TravelStatus IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.


    MODIFY ENTITIES OF  zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( travelstatus )
    WITH VALUE #( FOR travel IN travels
    ( %tky = travel-%tky
       TravelStatus = travel_status-open ) )
       REPORTED DATA(update_reported).


    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD validateAgency.

    " read relevant travel instance data
    READ ENTITIES OF   zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( AgencyID ) WITH CORRESPONDING #( keys )
    RESULT  DATA(travels).

    DATA agencies TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    "Optimization of DB select: extract distinct non-initial agency IDS
    agencies = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING  agency_id = AgencyID EXCEPT * ).
    DELETE agencies WHERE agency_id IS INITIAL.

    IF agencies IS NOT INITIAL.

      SELECT FROM /dmo/agency FIELDS agency_id
      FOR ALL ENTRIES IN @agencies
      WHERE agency_id = @agencies-agency_id
      INTO TABLE @DATA(agencies_db).


    ENDIF.

    "Raise msg for non existing agencyID
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_AGENCY' )
      TO reported-travel.


      IF travel-AgencyID IS INITIAL OR NOT line_exists( agencies_db[ agency_id = travel-AgencyID ] ).


        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.



        APPEND VALUE #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_AGENCY'
                        %msg        = NEW zcm_rap_5214(
                                          severity = if_abap_behv_message=>severity-error
                                          textid = zcm_rap_5214=>messages-agency_unknown
                                          agencyid = travel-AgencyID )
                        %element-AgencyID = if_abap_behv=>mk-on  )
         TO reported-travel.



      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateCustomer.

    " read relevant travel instance data
    READ ENTITIES OF   zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerID ) WITH CORRESPONDING #( keys )
    RESULT  DATA(travels).

    DATA customers  TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    "Optimization of DB select: extract distinct non-initial agency IDS
    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING  customer_id  = CustomerID EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.

      SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @customers
      WHERE customer_id = @customers-customer_id
      INTO TABLE @DATA(customer_db).


    ENDIF.

    "Raise msg for non existing agencyID
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_CUSTOMER' )
      TO reported-travel.


      IF travel-CustomerID IS INITIAL OR NOT line_exists( customer_db[ customer_id = travel-CustomerID ] ).


        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.



        APPEND VALUE #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg        = NEW zcm_rap_5214(
                                          severity = if_abap_behv_message=>severity-error
                                          textid = zcm_rap_5214=>messages-customer_unknown
                                          customerid = travel-CustomerID )
                        %element-CustomerID = if_abap_behv=>mk-on  )
         TO reported-travel.



      ENDIF.

    ENDLOOP.





  ENDMETHOD.

  METHOD validateDates.


    " read relevant travel instance data
    READ ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelID BeginDate EndDate ) WITH CORRESPONDING #( keys )
    RESULT  DATA(travels).


    "Raise msg for ***
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_DATES' )
      TO reported-travel.


      IF travel-EndDate < travel-BeginDate.

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcm_rap_5214(
                                          severity = if_abap_behv_message=>severity-error
                                          textid = zcm_rap_5214=>messages-date_interval
                                          begindate = travel-BeginDate
                                          enddate = travel-EndDate
                                          travelid = travel-TravelID )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate = if_abap_behv=>mk-on )
         TO reported-travel.

      ELSEIF travel-BeginDate < cl_abap_context_info=>get_system_date(  ) .



        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcm_rap_5214(
                                          severity = if_abap_behv_message=>severity-error
                                          textid = zcm_rap_5214=>messages-begin_date_before_system_date
                                          begindate = travel-BeginDate )
                        %element-BeginDate = if_abap_behv=>mk-on  )
         TO reported-travel.





      ENDIF.




    ENDLOOP.







  ENDMETHOD.

  METHOD acceptTravel.

    "Set the new overall status
    MODIFY ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
       ENTITY Travel
       UPDATE FIELDS ( TravelStatus )
       WITH VALUE #( FOR key IN keys
                     ( %tky = key-%tky
                       TravelStatus = travel_status-accepted ) )
     FAILED failed
     REPORTED  reported.

    "Fill the response table
    READ ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
                      ( %tky = travel-%tky
                       %param = travel ) ).


  ENDMETHOD.

  METHOD rejectTravel.


    "Set the new overall status
    MODIFY ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
       ENTITY Travel
       UPDATE FIELDS ( TravelStatus )
       WITH VALUE #( FOR key IN keys
                     ( %tky = key-%tky
                       TravelStatus = travel_status-cancelled ) )
     FAILED failed
     REPORTED  reported.

    "Fill the response table
    READ ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
                      ( %tky = travel-%tky
                       %param = travel ) ).







  ENDMETHOD.

  METHOD recalcTotalPrice.

   types:BEGIN OF ty_amount_per_curruncycode,
         amount type /dmo/total_price,
         currency_code TYPE /dmo/currency_code,
         END OF ty_amount_per_curruncycode.


  DATA : amount_per_currency_code TYPE STANDARD TABLE OF ty_amount_per_curruncycode.

  READ ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
  ENTITY Travel
  FIELDS ( BookingFee CurrencyCode )
  WITH CORRESPONDING #( keys )
  RESULT data(travels) .

  delete travels WHERE CurrencyCode is INITIAL.

  LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

   amount_per_currency_code = VALUE #( ( amount = <travel>-BookingFee
                                         currency_code = <travel>-CurrencyCode  ) ).



   READ ENTITIES OF zi_rap_travel_5214 in LOCAL MODE
   ENTITY Travel by \_Booking
   FIELDS ( FlightPrice CurrencyCode )
   WITH VALUE #( ( %tky = <travel>-%tky ) )
   RESULT DATA(bookings).


   LOOP AT bookings into data(booking) WHERE CurrencyCode is not INITIAL.
     COLLECT VALUE ty_amount_per_curruncycode( amount = booking-FlightPrice
                                                currency_code = booking-CurrencyCode )
     into amount_per_currency_code.
   ENDLOOP.

   clear <travel>-TotalPrice.
   LOOP AT amount_per_currency_code into data(single_amount_per_currencycode).

   if single_amount_per_currencycode-currency_code = <travel>-CurrencyCode.

      <travel>-TotalPrice += single_amount_per_currencycode-amount.

   else.

         /dmo/cl_flight_amdp=>convert_currency(
           EXPORTING
             iv_amount               =  single_amount_per_currencycode-amount
             iv_currency_code_source =  single_amount_per_currencycode-currency_code
             iv_currency_code_target =  <travel>-CurrencyCode
             iv_exchange_rate_date   =  cl_abap_context_info=>get_system_date( )
           IMPORTING
             ev_amount               = DATA(total_booking_price_per_curr)
         ).

       <travel>-TotalPrice += total_booking_price_per_curr.


   endif.
   ENDLOOP.
  ENDLOOP.


     MODIFY ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
     ENTITY Travel
     UPDATE FIELDS ( TotalPrice )
     WITH CORRESPONDING #( travels ).




  ENDMETHOD.

  METHOD get_features.

     READ ENTITIES of zi_rap_travel_5214 in LOCAL MODE
     ENTITY Travel
     FIELDS ( TravelStatus ) WITH CORRESPONDING #( keys )
     RESULT data(travels)
     FAILED failed.



     result = value #(
        for travel in travels
          let is_accepted = COND #( when travel-TravelStatus = travel_status-accepted
                                    then if_abap_behv=>fc-o-disabled
                                    else if_abap_behv=>fc-o-enabled )
              is_rejected = COND #( when travel-TravelStatus = travel_status-cancelled
                                    then if_abap_behv=>fc-o-disabled
                                    else if_abap_behv=>fc-o-enabled )
         in (  %tky         = travel-%tky
               %action-acceptTravel = is_accepted
               %action-rejectTravel = is_rejected   )
      ).




  ENDMETHOD.

  METHOD get_authorizations.

    data : has_before_image TYPE abap_bool,
           is_update_requested type abap_bool,
           is_delete_requested type abap_bool,
           update_granted      type abap_bool,
           delete_granted      TYPE abap_bool.

    data failed_travel like LINE OF failed-travel.

    read ENTITIES of zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelStatus ) WITH CORRESPONDING #( keys )
    RESULT data(travels)
    FAILED failed.

    check travels is not INITIAL.

    select from zrap_atrav_5214
    FIELDS travel_uuid,overall_status
    FOR ALL ENTRIES IN @travels
    WHERE travel_uuid eq @travels-TravelUUID
    order by PRIMARY KEY
    into table @data(travels_before_image).

    is_update_requested =
    COND #( when requested_authorizations-%update = if_abap_behv=>mk-on or
                 requested_authorizations-%action-acceptTravel = if_abap_behv=>mk-on or
                 requested_authorizations-%action-rejectTravel = if_abap_behv=>mk-on or
                 requested_authorizations-%assoc-_Booking = if_abap_behv=>mk-on

             then abap_true else abap_false ).



    is_delete_requested =
    COND #( when requested_authorizations-%delete = if_abap_behv=>mk-on
            then abap_true else abap_false ).


   LOOP AT travels into data(travel).

   update_granted = delete_granted = abap_true.


   APPEND value #(  %tky = travel-%tky
                    %update  = if_abap_behv=>auth-allowed
                    %action-acceptTravel = if_abap_behv=>auth-allowed
                    %action-rejectTravel = if_abap_behv=>auth-allowed
                    %assoc-_Booking = if_abap_behv=>auth-allowed
                    %delete  = if_abap_behv=>auth-allowed
                      ) to result.


   ENDLOOP.





  ENDMETHOD.

  METHOD is_create_granted.

     AUTHORITY-CHECK OBJECT 'ZOSTAT5214'
     ID 'ZOSTAT5214' DUMMY
     ID 'ACTVT' FIELD '01'.

    create_granted = cond #( when sy-subrc = 0 then abap_true else abap_false ).

    create_granted = abap_true.


  ENDMETHOD.


  METHOD is_delete_granted.


   if has_before_image = abap_true.
  AUTHORITY-CHECK OBJECT 'ZOSTAT5214'
     ID 'ZOSTAT5214' FIELD travel_status
     ID 'ACTVT' FIELD '06'.
  else.
    AUTHORITY-CHECK OBJECT 'ZOSTAT5214'
     ID 'ZOSTAT5214' DUMMY
     ID 'ACTVT' FIELD '06'.
  endif.



    delete_granted = cond #( when sy-subrc = 0 then abap_true else abap_false ).

    delete_granted = abap_true.



  ENDMETHOD.

  METHOD is_update_granted.


  if has_before_image = abap_true.
  AUTHORITY-CHECK OBJECT 'ZOSTAT5214'
     ID 'ZOSTAT5214' FIELD travel_status
     ID 'ACTVT' FIELD '02'.
  else.
    AUTHORITY-CHECK OBJECT 'ZOSTAT5214'
     ID 'ZOSTAT5214' DUMMY
     ID 'ACTVT' FIELD '02'.
  endif.



    update_granted = cond #( when sy-subrc = 0 then abap_true else abap_false ).

    update_granted = abap_true.



  ENDMETHOD.

ENDCLASS.
