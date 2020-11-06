@EndUserText.label: 'Travel Projection View'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_RAP_TRAVEL_5214 
 as projection on ZI_RAP_TRAVEL_5214 as Travel 
{
    //ZI_RAP_TRAVEL_5214
    key TravelUUID,
    @Search.defaultSearchElement: true
    TravelID,
    @Consumption.valueHelpDefinition: [{ entity :{ name: '/DMO/I_Agency' , element : 'AgencyID'  } }]
    @ObjectModel.text.element: ['AgencyName']
    @Search.defaultSearchElement: true
    AgencyID,
    _Agency.Name as AgencyName,
    @Consumption.valueHelpDefinition: [{ entity :{ name: '/DMO/I_Customer' , element : 'CustomerID'  } }]
    @ObjectModel.text.element: ['CustomerName']
    @Search.defaultSearchElement: true
    CustomerID,
    _Customer.LastName as CustomerName,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    @Consumption.valueHelpDefinition: [{entity :{ name : 'I_Currency', element : 'Currency'} }]
    CurrencyCode,
    Description,
    TravelStatus,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    
    /* Associations */
    //ZI_RAP_TRAVEL_5214
    _Agency,
    _Booking : redirected to composition child ZC_RAP_BOOKING_5214,
    _Currency,
    _Customer
    
}
