@isTest
private class PaymentTermsDaysCalcTest {
	
	@isTest static void createPaymentTermsPositive1Month() {
		On_Payment_Terms__c pt = new On_Payment_Terms__c(
			Name = 'end next month',
			Terms_Days__c = 0,
			Discount_Available__c = 10,
			End_Next_Month__c = true
		);
		Test.startTest();
			insert pt;
		Test.stopTest();
		On_Payment_Terms__c ptAfterInsert = [SELECT Id,Terms_Days__c FROM On_Payment_Terms__c WHERE Id = :pt.Id];
		System.assertEquals(PaymentTermsDaysCalc.daysToEndNextMonth(), ptAfterInsert.Terms_Days__c);
	}

	@isTest static void createPaymentTermsPositive3Month3() {
		On_Payment_Terms__c pt = new On_Payment_Terms__c(
			Name = '90 days end of month',
			Terms_Days__c = 0,
			Discount_Available__c = 10,
			X90_Days_Month_End__c = true
		);
		Test.startTest();
			insert pt;
		Test.stopTest();
		On_Payment_Terms__c ptAfterInsert = [SELECT Id,Terms_Days__c FROM On_Payment_Terms__c WHERE Id = :pt.Id];
		System.assertEquals(PaymentTermsDaysCalc.daysToEnd3Months(), ptAfterInsert.Terms_Days__c);
	}

	@isTest static void createPaymentTermsNegative() {
		On_Payment_Terms__c pt = new On_Payment_Terms__c(
			Name = 'NOT end next month',
			Terms_Days__c = 120,
			Discount_Available__c = 10,
			End_Next_Month__c = false
		);
		Test.startTest();
			insert pt;
		Test.stopTest();
		On_Payment_Terms__c ptAfterInsert = [SELECT Id,Terms_Days__c FROM On_Payment_Terms__c WHERE Id = :pt.Id];
		System.assertEquals(120, ptAfterInsert.Terms_Days__c);
	}

	@isTest static void updatePaymentTerms() {
		On_Payment_Terms__c pt = new On_Payment_Terms__c(
			Name = 'changing',
			Terms_Days__c = 120,
			Discount_Available__c = 10,
			End_Next_Month__c = false
		);
		insert pt;

		pt.End_Next_Month__c = true;
		Test.startTest();
			update pt;
		Test.stopTest();
		On_Payment_Terms__c ptAfterInsert = [SELECT Id,Terms_Days__c FROM On_Payment_Terms__c WHERE Id = :pt.Id];
		System.assertEquals(PaymentTermsDaysCalc.daysToEndNextMonth(), ptAfterInsert.Terms_Days__c);
	}

	@isTest static void batchUpdatePaymentTerms() {
		On_Payment_Terms__c pt = new On_Payment_Terms__c(
			Name = 'end next month',
			Terms_Days__c = 0,
			Discount_Available__c = 10,
			End_Next_Month__c = true
		);
		insert pt;

		Test.startTest();
			Database.executeBatch(new PaymentTermsDaysCalc());
		Test.stopTest();
		On_Payment_Terms__c ptAfterInsert = [SELECT Id,Terms_Days__c FROM On_Payment_Terms__c WHERE Id = :pt.Id];
		System.assertEquals(PaymentTermsDaysCalc.daysToEndNextMonth(), ptAfterInsert.Terms_Days__c);
	}
	
}