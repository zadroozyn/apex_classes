/**
 * Class contains methods that are using to test AccountMethods methods.<br>
 * The class's methods cover also AccountDataUpdation APEX class, AccountTriggerHandler APEX class and AccountTriggers APEX trigger.<br>
 * Class's methods use methods from TestUtility to create test data.
 * 
 * @version 2.0  2014.09.27 Ewa Byra (ewa.byra@nefoscdc.com).
 * 							Extended class to cover AccountDataUpdation APEX class, AccountTriggerHandler APEX class and AccountTriggers APEX trigger.
 * 
 * @version 1.0  2014.08.11 Ewa Byra (ewa.byra@nefoscdc.com).
 *                          Initial version of class.
 * 
 * @see AccountMethods        APEX class.
 * @see AccountDataUpdation   APEX class.
 * @see AccountTriggerHandler APEX class.
 * @see AccountTriggers       APEX trigger.
 * @see TestUtility           APEX class.
 */

@isTest
public class AccountMethodsTest {
	
	/**
	 * Method used to test assignDefaultValues(List<Account>) method from AccountMethods class.
	 */
	public static testMethod void assignDefaultValuesTest() {
		
		System.runAs(TestUtility.createUser('tester', null, true)) {
            TestUtility.enableAllFeatures();

			// settings
			TestUtility.insertAccountSettingsDefaultValuesRecords();

			// contries
			List<pw_ccpro__CountryObject__c> lCountries = new List<pw_ccpro__CountryObject__c>();

			lCountries.add(TestUtility.createCountry('Luxembourg', 'LU', 'LUX', false));
			lCountries.add(TestUtility.createCountry('Germany', 'DE', 'DEU', false));
			lCountries.add(TestUtility.createCountry('Switzerland', 'CH', 'CHE', false));
			lCountries.add(TestUtility.createCountry('Austria', 'AT', 'AUT', false));
			lCountries.add(TestUtility.createCountry('Poland', 'PL', 'PLN', false));
			lCountries.add(TestUtility.createCountry('United States', 'US', 'USA', false));
			lCountries.add(TestUtility.createCountry('Canada', 'CA', 'CAN', false));
			lCountries.add(TestUtility.createCountry('United Kingdom', 'GB', 'GBR', false));
			lCountries.add(TestUtility.createCountry('China', 'CN', 'CHN', false));

			insert lCountries;

			// create test data
			List<Account> lAccounts = new List<Account>();
			
			for (Integer i = 0; i < 10; i++) {
				lAccounts.add(TestUtility.createAccount('test ' + i, 'EUR', false));
			}
			
			lAccounts.get(0).BillingCountry = 'Luxembourg';
			lAccounts.get(1).BillingCountry = 'Germany';
			lAccounts.get(2).BillingCountry = 'Switzerland';
			lAccounts.get(3).BillingCountry = 'Austria';
			lAccounts.get(4).BillingCountry = 'Poland';
			lAccounts.get(5).BillingCountry = 'United States';
			lAccounts.get(6).BillingCountry = 'Canada';
			lAccounts.get(7).BillingCountry = 'United Kingdom';
			lAccounts.get(8).BillingCountry = 'China';
			lAccounts.get(9).BillingCountry = '';
			
			Test.startTest();

			// Test insertion
			insert lAccounts;
			
			Set<ID> sAccountIDs = new Set<ID>();
			
			for (Account record : lAccounts) {
				sAccountIDs.add(record.ID);
			}

			for (Account record : 	[SELECT ID, BillingCountry, 
											On_Payment_Term__c, On_Payment_Term__r.Name, 
											c2g__CODAAccountsReceivableControl__c, c2g__CODAAccountsReceivableControl__r.Name, 
											c2g__CODATaxCalculationMethod__c, 
											c2g__CODAOutputVATCode__c, c2g__CODAOutputVATCode__r.Name, 
											c2g__CODAVATStatus__c, 
											c2g__CODASalesTaxStatus__c 
									 FROM   Account 
									 WHERE  ID IN :sAccountIDs]) {

				System.assertEquals('Advance Payment', record.On_Payment_Term__r.Name);
				System.assertEquals('1100', record.c2g__CODAAccountsReceivableControl__r.Name);
				System.assertEquals('Gross', record.c2g__CODATaxCalculationMethod__c);

				if (record.BillingCountry != null && record.BillingCountry.equals('Luxembourg')) {
					
					System.assertEquals('VOLU', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && record.BillingCountry.equals('Switzerland')) {

					System.assertEquals('VOSTD', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Home', record.c2g__CODAVATStatus__c);
					System.assertEquals('Taxable', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('Germany') || record.BillingCountry.equals('Austria'))) {

					System.assertEquals('VO3Z', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('EC Non-registered', record.c2g__CODAVATStatus__c);
					System.assertEquals('Taxable', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('United States') || record.BillingCountry.equals('Canada'))) {
					
					System.assertEquals('VOUSZ', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				} else {

					System.assertEquals(null, record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				}
			}

			// Test updation
			lAccounts.get(5).BillingCountry = 'Austria';

			update lAccounts;

			for (Account record : 	[SELECT ID, BillingCountry, 
											On_Payment_Term__c, On_Payment_Term__r.Name, 
											c2g__CODAAccountsReceivableControl__c, c2g__CODAAccountsReceivableControl__r.Name, 
											c2g__CODATaxCalculationMethod__c, 
											c2g__CODAOutputVATCode__c, c2g__CODAOutputVATCode__r.Name, 
											c2g__CODAVATStatus__c, 
											c2g__CODASalesTaxStatus__c 
									 FROM   Account 
									 WHERE  ID IN :sAccountIDs]) {

				System.assertNotEquals('United States', record.BillingCountry);

				System.assertEquals('Advance Payment', record.On_Payment_Term__r.Name);
				System.assertEquals('1100', record.c2g__CODAAccountsReceivableControl__r.Name);
				System.assertEquals('Gross', record.c2g__CODATaxCalculationMethod__c);

				if (record.BillingCountry != null && record.BillingCountry.equals('Luxembourg')) {
					
					System.assertEquals('VOLU', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && record.BillingCountry.equals('Switzerland')) {

					System.assertEquals('VOSTD', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Home', record.c2g__CODAVATStatus__c);
					System.assertEquals('Taxable', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('Germany') || record.BillingCountry.equals('Austria'))) {

					System.assertEquals('VO3Z', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('EC Non-registered', record.c2g__CODAVATStatus__c);
					System.assertEquals('Taxable', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('United States') || record.BillingCountry.equals('Canada'))) {
					
					System.assertEquals('VOUSZ', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				} else {

					System.assertEquals(null, record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				}
			}

			// Test deletion
			delete lAccounts;

			// Test undeletion
			undelete lAccounts;

			Test.stopTest();
		}	
	}

	/**
	 * Method used to test AccountDataUpdation batch job.
	 */
	public static testMethod void accountDataUpdationBatchJobTest() {

		System.runAs(TestUtility.createUser('tester', null, true)) {

			// contries
			List<pw_ccpro__CountryObject__c> lCountries = new List<pw_ccpro__CountryObject__c>();

			lCountries.add(TestUtility.createCountry('Luxembourg', 'LU', 'LUX', false));
			lCountries.add(TestUtility.createCountry('Germany', 'DE', 'DEU', false));
			lCountries.add(TestUtility.createCountry('Switzerland', 'CH', 'CHE', false));
			lCountries.add(TestUtility.createCountry('Austria', 'AT', 'AUT', false));
			lCountries.add(TestUtility.createCountry('Poland', 'PL', 'PLN', false));
			lCountries.add(TestUtility.createCountry('United States', 'US', 'USA', false));
			lCountries.add(TestUtility.createCountry('Canada', 'CA', 'CAN', false));
			lCountries.add(TestUtility.createCountry('United Kingdom', 'GB', 'GBR', false));
			lCountries.add(TestUtility.createCountry('China', 'CN', 'CHN', false));

			insert lCountries;

			// create test data
			List<Account> lAccounts = new List<Account>();
			
			for (Integer i = 0; i < 10; i++) {
				lAccounts.add(TestUtility.createAccount('test ' + i, 'EUR', false));
			}
			
			lAccounts.get(0).BillingCountry = 'Luxembourg';
			lAccounts.get(1).BillingCountry = 'Germany';
			lAccounts.get(2).BillingCountry = 'Switzerland';
			lAccounts.get(3).BillingCountry = 'Austria';
			lAccounts.get(4).BillingCountry = 'Poland';
			lAccounts.get(5).BillingCountry = 'United States';
			lAccounts.get(6).BillingCountry = 'Canada';
			lAccounts.get(7).BillingCountry = 'United Kingdom';
			lAccounts.get(8).BillingCountry = 'China';
			lAccounts.get(9).BillingCountry = '';

			insert lAccounts;
			
			Set<ID> sAccountIDs = new Set<ID>();
			
			for (Account record : lAccounts) {
				sAccountIDs.add(record.ID);
			}

			for (Account record : 	[SELECT ID, BillingCountry, 
											On_Payment_Term__c, On_Payment_Term__r.Name, 
											c2g__CODAAccountsReceivableControl__c, c2g__CODAAccountsReceivableControl__r.Name, 
											c2g__CODATaxCalculationMethod__c, 
											c2g__CODAOutputVATCode__c, c2g__CODAOutputVATCode__r.Name, 
											c2g__CODAVATStatus__c, 
											c2g__CODASalesTaxStatus__c 
									 FROM   Account 
									 WHERE  ID IN :sAccountIDs]) {

				System.assertNotEquals('Advance Payment', record.On_Payment_Term__r.Name);
				System.assertNotEquals('1100', record.c2g__CODAAccountsReceivableControl__r.Name);

				if (record.BillingCountry != null && record.BillingCountry.equals('Luxembourg')) {
					
					System.assertNotEquals('VOLU', record.c2g__CODAOutputVATCode__r.Name);

				} else if (record.BillingCountry != null && record.BillingCountry.equals('Switzerland')) {

					System.assertNotEquals('VOSTD', record.c2g__CODAOutputVATCode__r.Name);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('Germany') || record.BillingCountry.equals('Austria'))) {

					System.assertNotEquals('VO3Z', record.c2g__CODAOutputVATCode__r.Name);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('United States') || record.BillingCountry.equals('Canada'))) {
					
					System.assertNotEquals('VOUSZ', record.c2g__CODAOutputVATCode__r.Name);

				}
			}

			// settings
			TestUtility.insertAccountSettingsDefaultValuesRecords();

			// run batch job
			Test.startTest();
			ID batchProcessID = Database.executeBatch(new AccountDataUpdation());
			Test.stopTest();

			// verify test results
			for (Account record : 	[SELECT ID, BillingCountry, 
											On_Payment_Term__c, On_Payment_Term__r.Name, 
											c2g__CODAAccountsReceivableControl__c, c2g__CODAAccountsReceivableControl__r.Name, 
											c2g__CODATaxCalculationMethod__c, 
											c2g__CODAOutputVATCode__c, c2g__CODAOutputVATCode__r.Name, 
											c2g__CODAVATStatus__c, 
											c2g__CODASalesTaxStatus__c 
									 FROM   Account 
									 WHERE  ID IN :sAccountIDs]) {

				System.assertEquals('Advance Payment', record.On_Payment_Term__r.Name);
				System.assertEquals('1100', record.c2g__CODAAccountsReceivableControl__r.Name);
				System.assertEquals('Gross', record.c2g__CODATaxCalculationMethod__c);

				if (record.BillingCountry != null && record.BillingCountry.equals('Luxembourg')) {
					
					System.assertEquals('VOLU', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && record.BillingCountry.equals('Switzerland')) {

					System.assertEquals('VOSTD', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Home', record.c2g__CODAVATStatus__c);
					System.assertEquals('Taxable', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('Germany') || record.BillingCountry.equals('Austria'))) {

					System.assertEquals('VO3Z', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('EC Non-registered', record.c2g__CODAVATStatus__c);
					System.assertEquals('Taxable', record.c2g__CODASalesTaxStatus__c);

				} else if (record.BillingCountry != null && (record.BillingCountry.equals('United States') || record.BillingCountry.equals('Canada'))) {
					
					System.assertEquals('VOUSZ', record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				} else {

					System.assertEquals(null, record.c2g__CODAOutputVATCode__r.Name);
					System.assertEquals('Export', record.c2g__CODAVATStatus__c);
					System.assertEquals('Exempt', record.c2g__CODASalesTaxStatus__c);

				}
			}
		}
	}
	
}