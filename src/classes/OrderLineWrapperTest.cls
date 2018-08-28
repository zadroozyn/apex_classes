@isTest class OrderLineWrapperTest {

	@isTest static void test () {
		PBSI__PBSI_Sales_Order_Line__c testLine = new PBSI__PBSI_Sales_Order_Line__c();
		testLine.PBSI__ItemDescription__c = 'Test_desc';
		testLine.PBSI__Quantity_Needed__c = 20;
		testLine.PBSI__Quantity_Picked__c = 10;
		testLine.PBSI__Price4__c = 100;

		OrderLineWrapper olw = new OrderLineWrapper(testLine);
		System.assertEquals(testLine.Name, olw.name);
		System.assertEquals(testLine.PBSI__Quantity_Needed__c, olw.quantityNeeded);
		System.assertEquals(testLine.PBSI__Quantity_Picked__c, olw.quantityPacked);
		System.assertEquals(testLine.PBSI__Quantity_Left_To_Ship__c, olw.quantityLeftToPack);
		System.assertEquals(testLine.PBSI__Price4__c, olw.price);
		System.assertEquals(testLine.PBSI__Total_Price__c, olw.totalPrice);
	}
}