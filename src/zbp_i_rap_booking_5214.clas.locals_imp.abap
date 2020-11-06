CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateBookingID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateBookingID.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateBookingID.

    DATA max_bookingid TYPE /dmo/booking_id.
    DATA update TYPE TABLE FOR UPDATE  zi_rap_travel_5214\\Booking.

    READ ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Booking BY \_Travel
    FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).


    LOOP AT travels INTO DATA(travel).

      READ ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
      ENTITY Travel BY \_Booking
      FIELDS ( BookingID )
      WITH VALUE #( ( %tky = travel-%tky ) )
      RESULT DATA(bookings).

      max_bookingid = '0000'.
      LOOP AT bookings INTO DATA(booking).
        IF booking-BookingID > max_bookingid.
          max_bookingid =  booking-BookingID.
        ENDIF.
      ENDLOOP.


      LOOP AT bookings INTO booking WHERE BookingID IS INITIAL.

        max_bookingid += 10.
        APPEND VALUE #(  %tky = booking-%tky
                         BookingID  = max_bookingid     ) TO update .


      ENDLOOP.
    ENDLOOP.


    MODIFY ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Booking
    UPDATE FIELDS ( BookingID ) WITH update
    REPORTED DATA(update_reported).


    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD calculateTotalPrice.

    READ ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Booking BY \_Travel
    FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)
    FAILED DATA(read_failed).

    MODIFY ENTITIES OF zi_rap_travel_5214 IN LOCAL MODE
    ENTITY Travel
    EXECUTE recalcTotalPrice
    FROM CORRESPONDING #( travels )
    REPORTED DATA(execute_reported).

    reported = CORRESPONDING #( DEEP execute_reported ).


  ENDMETHOD.

ENDCLASS.
