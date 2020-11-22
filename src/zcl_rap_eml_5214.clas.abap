CLASS zcl_rap_eml_5214 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_RAP_EML_5214 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

     " step 1 - read
*
*      read ENTITIES of zi_rap_travel_5214
*          ENTITY Travel
*          from VALUE #( ( TravelUUID = 'DC7015E09B6AAE4217000C02EA89A7D9' ) )
*       RESULT data(travels).
*
*
*       out->write( travels ) .



*      read ENTITIES of zi_rap_travel_5214
*          ENTITY Travel
*          FIELDS ( AgencyID CustomerID  )
*          WITH VALUE #( ( TravelUUID = 'DC7015E09B6AAE4217000C02EA89A7D9' ) )
*       RESULT data(travels).
*
*
*       out->write( travels ) .


*         read ENTITIES of zi_rap_travel_5214
*          ENTITY Travel
*         all  FIELDS
*          WITH VALUE #( ( TravelUUID = 'DC7015E09B6AAE4217000C02EA89A7D9' ) )
*       RESULT data(travels).
*
*
*       out->write( travels ) .



*        " Step 4 - read by Association
*         read ENTITIES of zi_rap_travel_5214
*          ENTITY Travel by \_Booking
*          all  FIELDS  WITH VALUE #( ( TravelUUID = 'DC7015E09B6AAE4217000C02EA89A7D9' ) )
*          RESULT data(bookings).
*
*
*           out->write( bookings ) .


             " Step 5 - Unsuccesfull read
*         read ENTITIES of zi_rap_travel_5214
*          ENTITY Travel
*          all  FIELDS  WITH VALUE #( ( TravelUUID = '111015E09B6AAE4217000C02EA89A7D9' ) )
*          RESULT data(travels)
*          failed data(failed)
*          reported data(reported).
*
*
*           out->write( travels ) .
*           out->write( failed ) .
*           out->write( reported ) .


*            " Step 6 - Modify Update
*        MODIFY ENTITIES of zi_rap_travel_5214
*        ENTITY Travel
*        UPDATE
*        SET FIELDS WITH VALUE #( ( TravelUUID = 'DC7015E09B6AAE4217000C02EA89A7D9'
*                                   Description = 'I like RAP@openSAP'  )  )
*        failed DATA(failed)
*        REPORTED DATA(reported).
*
*        out->write( 'Update Done' ) .
*
*        COMMIT ENTITIES
*           RESPONSE OF zi_rap_travel_5214
*           FAILED   DATA(failed_commit)
*           REPORTED DATA(reported_commit).



*     "  step 7- Modify Create
*      MODIFY ENTITIES of zi_rap_travel_5214
*      ENTITY travel
*      CREATE SET FIELDS WITH VALUE
*      #( (
*          %cid = 'MuContentID_1'
*          AgencyID = '70012'
*          CustomerID = '14'
*          BeginDate = cl_abap_context_info=>get_system_date( )
*          EndDate    =  cl_abap_context_info=>get_system_date( ) + 10
*          Description = ' I like ABAP'
*
*      ) )
*
*      MAPPED data(mapped)
*      FAILED DATA(failed)
*      REPORTED data(reported).
*
*      out->write( mapped-travel ).
*
*
*           COMMIT ENTITIES
*           RESPONSE OF zi_rap_travel_5214
*           FAILED   DATA(failed_commit)
*           REPORTED DATA(reported_commit).
*
*
*
*      out->write( 'Create done').



        " step 8  Modify delete
          MODIFY ENTITIES of zi_rap_travel_5214
          ENTITY Travel
          DELETE FROM  VALUE #( ( TravelUUID = '02FB209383E01EDB87A8D8BBB15F181E' ) )
          failed data(failed)
          reported data(reported).

           COMMIT ENTITIES
           RESPONSE OF zi_rap_travel_5214
           FAILED   DATA(failed_commit)
           REPORTED DATA(reported_commit).

           out->write('Delete done' ).




  ENDMETHOD.
ENDCLASS.
