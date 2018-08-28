@isTest class OrderWrapperTest {
	@testSetup static void testSetup () {
		TestDataFactory td = TestDataFactory.instance;
		td.accounts.createSObject('Test_account', 'CHF', true);
		PBSI__PBSI_Sales_Order__c order = td.salesOrders.createSObject(td.accounts.getSObjectId('Test_account'), 'Re-Order', null, false);
		order.PBSI__Customer_Purchase_Order__c = '1234';
		order.PBSI__Stage__c = 'closed';
		order.PBSI__Status__c = 'in progress';
		order.PBSI__Due_Date__c = Date.today().addDays(2);
		order.Tracking_Number_1__c = '11';
		order.Tracking_Number_2__c = '22';
		order.Tracking_Number_3__c = '33';

		insert order;
	}
	@isTest static void test1 () {
		PBSI__PBSI_Sales_Order__c order = [SELECT Name,
								  PBSI__Due_Date__c,
								  CurrencyIsoCode,
								  Total_Shoes_Shipped__c,
								  Total_Quantity_To_Ship__c,
								  PBSI__Final_Order_Total__c,
								  PBSI__Stage__c,
								  PBSI__Customer_Purchase_Order__c,
								  Delivery_Date__c,
								  PBSI__Type__c,
								  PBSI__Order_Date__c,
								  Sales_Order_Type__c,
								  Pre_Order_Final_Order_Total__c,
								  PBSI__Sales_Tax__c,
								  PBSI__Shipping_Cost__c,
								  PBSI__Order_Total__c,
								  Total_Quantity_Of_Shoes_On_Order__c,
								  Tracking_Number_1__c,
								  Tracking_Number_2__c,
								  Tracking_Number_3__c,
								  PBSI__Status__c,
								  Id,
								  PBSI__Customer__r.B2B_On_Payment_Terms__c,
								  Master_order__r.Id,
								  Master_order__r.Name,
								  (SELECT Id FROM Attachments ORDER BY CreatedDate DESC LIMIT 1)
									  FROM PBSI__PBSI_Sales_Order__c
									  LIMIT 1][0];
		SalesOrderWrapper ow = new SalesOrderWrapper(order);
		System.assertEquals(false, ow.hasLines);
		System.assertEquals(order.Id, ow.sourceId);
		System.assertEquals(order.Name, ow.name);
		System.assertEquals(order.CurrencyIsoCode, ow.currencyisocode);
		System.assertEquals(order.PBSI__Status__c, ow.status);
		System.assertEquals(order.Sales_order_type__c, ow.type);
		System.assertEquals(order.PBSI__Stage__c, ow.stage);
		System.assertEquals(order.PBSI__Customer_Purchase_Order__c, ow.customerPurchaseOrder);
		System.assertEquals(order.Tracking_Number_1__c, ow.trackingNumber1);
		System.assertEquals(order.Tracking_Number_2__c, ow.trackingNumber2);
		System.assertEquals(order.Tracking_Number_3__c, ow.trackingNumber3);
		System.assertEquals(order.PBSI__Due_Date__c, ow.dueDate);
		System.assertEquals(order.PBSI__Order_Date__c, ow.orderDate);
		System.assertEquals(order.PBSI__Due_Date__c.format(), ow.dueDateString);
		System.assertEquals(order.PBSI__Order_Date__c.format(), ow.orderDateString);
		System.assertEquals(order.Total_Quantity_Of_Shoes_On_Order__c, ow.totalQuantity);
		System.assertEquals(order.PBSI__Order_Total__c, ow.orderTotal);
		System.assertEquals(order.PBSI__Shipping_Cost__c, ow.shippingCost);
		System.assertEquals(order.PBSI__Sales_Tax__c, ow.salesTax);
		System.assertEquals(order.Pre_Order_Final_Order_Total__c, ow.prdeOrderFinalTotal);
		System.assertEquals(order.Total_Quantity_To_Ship__c, ow.totalQuantityToShip);
		System.assertEquals(order.Total_Shoes_Shipped__c, ow.totalShoesShipped);
		System.assertEquals(order.PBSI__Final_Order_Total__c, ow.finalOrderTotal);
		System.assertEquals(order.PBSI__Customer__r.B2B_On_Payment_Terms__c, ow.customerPaymentTerm);
		System.assertEquals(order.Delivery_Date__c, ow.deliveryDate);
		System.assertEquals(false, ow.orderConfirmationDisplay);
		System.assertEquals(null, ow.orderConfirmation);
		//TODO Add lines to the order 
		System.assertEquals(0, ow.getLines().size());
	}

}