public interface KN_Order {
    String getReceiverIdentification();
    String getEnvelopeIdentification();
    String getPackingInstructions();
    String getDeliveryInstructions();
    String getClientNumber();
    String getClientOrderReference();
    String getDepot();
    String getConsigneeCustomerNumber();
    String getConsigneeOrderNumber();
    String getOrderType();
    String getServiceLevel();
    String getClientContactDetails();
    String getShipCode();
    String getTieInReference();
    String getDeliveryCompany();
    String getDeliveryATTN();
    String getStreetLine1();
    String getStreetLine2();
    String getDeliveryState();
    String getDeliveryCity();
    String getDeliveryZIPCode();
    String getDeliveryCountryCode();
    String getDeliveryPhone();
    String getDeliveryPhoneAlternate();
    String getDeliveryEmailAddress();
    List<KN_OrderLine> getLines();
}