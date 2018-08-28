/**
 * Helper class for test methods.<br>
 * It is using to prepare test data.<br>
 * Follow the content:<br>
 * 1. Methods to create standard Salesforce objects.
 * 2. Methods to create custom Salesforce objects.
 * 3. Methods to create objects from Financial Force package.
 * 4. Methods to create objects from Ascent package.
 * 5. Methods from Address Tool package.
 * 6. Methods to insert custom settings records.
 * 7. Utility methods.
 *
 * @version 1.0 2014.04.28 Ewa Byra (ewa.byra@nefoscdc.com).
 *                         Initial version of class.
 */

@isTest
public class TestUtility {

	/* ------------------------------------------------- 1. Methods to create STANDARD SALESFORCE OBJECTS ------------------------------------------------- */

	/**
	 * Method used to create user.
	 *
	 * @param name      name of User.
	 * @param profileID ID of related profile. If it is null, it will be assiged System Administrator profile.
	 * @param doInsert  if it is true, created record will be insered to database.
	 * @return User record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static User createUser(String name, ID profileID, Boolean doInsert) {
		User user= new User();

		user.ProfileId = profileID == null ? [SELECT ID FROM Profile WHERE Name = 'System Administrator'].ID : profileID;
		user.UserName = name + '@on-running.com.test';
		user.LastName = name;

		user.Alias = name.abbreviate(8);
		user.Email = name + '@on-running.com.test';
		user.EmailEncodingKey = 'UTF-8';
		user.LanguageLocaleKey = 'en_US';
		user.LocaleSidKey = 'en_US';
		user.TimeZoneSidKey = 'Europe/Berlin';

		if (doInsert) {
			insert user;
		}

		return user;
	}

	/**
	 * Method used to create Account record.
	 *
	 * @param name            value for Name field.
	 * @param currencyIsoCode value for CurrencyIsoCode field.
	 * @param doInsert        if it is true, created record will be insered to database.
	 * @return Account record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static Account createAccount(String name, String currencyIsoCode, Boolean doInsert) {
		Account record = new Account();
		record.Name = name;
		record.CurrencyIsoCode = currencyIsoCode;
		record.c2g__CODACreditLimitEnabled__c = true;
		record.c2g__CODACreditLimit__c = 10000;
		record.BillingCountry = 'Switzerland';

		if (doInsert) {
			insert record;
		}

		return record;
	}

	public static Account createPersonAccount(String name, String currencyIsoCode, Boolean doInsert) {
		Account record = new Account();
		record.LastName = name;
		record.CurrencyIsoCode = currencyIsoCode;
		record.c2g__CODACreditLimitEnabled__c = true;
		record.c2g__CODACreditLimit__c = 10000;
		record.BillingCountry = 'Switzerland';
		record.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Account record.
	 *
	 * @param general_ledger_accountID  value for c2g__CODAAccountsPayableControl__c field.
	 * @param currencyIsoCode           value for CurrencyIsoCode field.
	 * @param billingCountry            value for BillingCountry field.
	 * @param doInsert                  if it is true, created record will be insered to database.
	 * @return Account record which was created.
	 * @author Ewa Latoszek (ewa.latoszek@nefoscdc.com).
	 */
	public static Account createSupplierAccount(ID general_ledger_accountID, String currencyIcoCode, String billingCountry, Boolean doInsert) {
		Account account = new Account();
		account.Name = 'Test AG';
		account.CurrencyIsoCode = currencyIcoCode;
		account.BillingCountry = billingCountry;
		account.c2g__CODAAccountsPayableControl__c = general_ledger_accountID;
		account.RecordTypeId = [SELECT ID FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Supplier'].ID;
		account.c2g__CODABillingMethod__c = 'Electronic';
		account.c2g__CODABaseDate1__c = 'Invoice Date';
		account.c2g__CODABaseDate2__c = '';
		account.c2g__CODABaseDate3__c = 'Invoice Date';
		account.c2g__CODABaseDate4__c = 'Invoice Date';
		account.c2g__CODADiscount1__c = 0;
		account.c2g__CODADiscount2__c = 0;
		account.c2g__CODADiscount3__c = 0;
		account.c2g__CODADiscount4__c = 0;
		account.c2g__CODASalesTaxStatus__c = 'Taxable';
		account.c2g__CODAVATStatus__c = 'EC Non-registered';

		if (doInsert) {
			insert account;
		}

		return account;
	}

	/**
	 * Method used to create Contact record.
	 *
	 * @param name            value for Name field.
	 * @param account         related Account.
	 * @param doInsert        if it is true, created record will be insered to database.
	 * @return Contact record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static Contact createContact(String name, Account account, Boolean doInsert) {
		Contact record = new Contact();
		record.LastName = name;
		record.AccountId = account.ID;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	public static Contact[] createContacts(String name, Account account, Boolean doInsert, Integer count) {
		Contact[] contacts = new Contact[] {};

		for (Integer i = 0; i < count; i++) {
			Contact u = createContact(name + i, account, false);
			contacts.add(u);
		}

		if (doInsert) {
			insert contacts;
		}

		return contacts;
	}

	/**
	 * Method used to create Product record.
	 *
	 * @param name     value for Name field.
	 * @param doInsert if it is true, created record will be insered to database.
	 * @return Product record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static Product2 createProduct(String name, Boolean doInsert) {
		Product2 product = new Product2();
		product.Name = name;

		if (doInsert) {
			insert product;
		}

		return product;
	}

	/**
	 * Method used to create Attachment record.
	 *
	 * @param parentID ID of record to which Attachment will be assigned.
	 * @param name     name of attachment.
	 * @param body     body of attachment.
	 * @param doInsert if it is true, created record will be insered to database.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>
	 */
	public static Attachment createAttachment(ID parentID, String name, String body, Boolean doInsert) {
		Attachment record = new Attachment();
		record.Name = name;
		record.Body = Blob.valueOf(body);
		record.ParentId = parentID;


		if (doInsert) {
			insert record;
		}

		return record;
	}

	/* ------------------------------------------------- 2. Methods to create CUSTOM SALESFORCE OBJECTS --------------------------------------------------- */

	/**
	 * Method used to create Style Year record.
	 *
	 * @param name     value for Name field.
	 * @param doInsert if it is true, created record will be insered to database.
	 * @return Style Year record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static Style_Year__c createStyleYear(String name, Boolean doInsert) {
		Style_Year__c styleYear = new Style_Year__c();
		styleYear.Name = name;

		if (doInsert) {
			insert styleYear;
		}

		return styleYear;
	}

	/**
	 * Method used to create Style Year record.
	 *
	 * @param name     value for Name field.
	 * @param doInsert if it is true, created record will be insered to database.
	 * @return Fabric record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static Fabric__c createFabric(String name, Boolean doInsert) {
		Fabric__c fabric = new Fabric__c();
		fabric.Name = name;
		fabric.Fabric_Description__c = name;

		if (doInsert) {
			insert fabric;
		}

		return fabric;
	}

	/**
	 * Method used to create Size record.
	 *
	 * @param name        value for Name field.
	 * @param styleYearID ID of related Style Year.
	 * @param doInsert    if it is true, created record will be insered to database.
	 * @return Size record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static Sizes__c createSize(String name, ID styleYearID, Boolean doInsert) {
		Sizes__c size = new Sizes__c();
		size.Name = name;
		size.European_Size__c = name;
		size.UK_Size__c = name;
		size.UK_Size__c = name;
		size.US_Size__c = name;
		size.US_Men__c = name;
		size.US_Women__c = name;
		size.Style_Year__c = styleYearID;

		if (doInsert) {
			insert size;
		}

		return size;
	}

	/**
	 * Method used to create On Payment Term (API Name: On_Payment_Terms__c) record that are used to test.
	 *
	 * @param name       value for On Payment Term Name (API Name: Name) field.
	 * @param daysOffset value for Days Offset 1 (API Name: Terms_Days__c) field.
	 * @param discount   value for Discount 1 (API Name: Discount_Available__c) field.
	 * @param doInsert   if it is true, created record will be insered to database.
	 * @return On Payment Term (API Name: On_Payment_Terms__c) record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static On_Payment_Terms__c createOnPaymentTerm(String name, Integer daysOffset, Decimal discount, Boolean doInsert) {
		On_Payment_Terms__c onPaymentTerm = new On_Payment_Terms__c(Name = name, Terms_Days__c = daysOffset, Discount_Available__c = discount);

		if (doInsert) {
			insert onPaymentTerm;
		}

		return onPaymentTerm;
	}

	/**
	 * Method used to create Customer Visit (API Name: Customer_Visit__c) record that are used to test.
	 *
	 * @param delaerID    ID of Dealer Account.
	 * @param visitorID   ID of Visitor Account.
	 * @param doInsert    if it is true, created record will be insered to database.
	 * @return Customer Visit (API Name: Customer_Visit__c) record.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static Customer_Visit__c createCustomerVisit(ID delaerID, ID visitorID, Boolean doInsert) {
		Customer_Visit__c record = new Customer_Visit__c(Account__c = delaerID, Visitor_Account__c = visitorID, Visitor_E_Mail__c = 'test@test.com');

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Back Order Request (API Name: Back_Order_Request__c) record that are used to test.
	 *
	 * @param itemID     ID of PBSI__PBSI_Item__c record.
	 * @param locationID ID of PBSI__PBSI_Location__c record.
	 * @param doInsert   if it is true, created record will be insered to database.
	 * @return Back Order Request (API Name: Back_Order_Request__c) record.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static Back_Order_Request__c createBackOrderRequest(ID itemID, ID locationID, Boolean doInsert) {
		Back_Order_Request__c record = new Back_Order_Request__c(Shoe__c = itemID, Location__c = locationID);

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/* ------------------------------------------------- 3. Methods to create objects from FINANCIAL FORCE package ---------------------------------------- */

	/**
	 * Method used to create company.
	 *
	 * @param name      name of company.
	 * @param doInsert  if it is true, created record will be insered to database.
	 * @return Company record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com)
	 */
	public static c2g__codaCompany__c createCompany(String name, Boolean doInsert) {
		c2g__codaCompany__c company = new c2g__codaCompany__c(
				Name = name,
				ffbf__CompanyIdentificationNumber__c = 12345,
				c2g__CashMatchingCurrencyMode__c = 'USD',
				c2g__YearEndMode__c = 'Test Code',
				c2g__ExternalId__c = 'ABCDE1234567876',
				c2g__LogoURL__c = 'ww.XYZ.com',
				c2g__ECCountryCode__c = 'AE' ,
				c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ,
				c2g__Website__c = 'ww.xyz.com',
				c2g__Country__c = 'CH'
				);

		if (doInsert) {
			insert company;
		}

		return company;
	}

	/**
	 * Method used to create Company record.
	 *
	 * @param name          company Name.
	 * @param recordTypeID  ID of record type.
	 * @param country       value for Company
	 * @param state         value for State/Province
	 * @param zipCode       value for ZipCode
	 * @param city          value for City
	 * @param street        value for Street
	 * @param doInsert      if it is true, created record will be insered to database.
	 * @return Company record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static c2g__codaCompany__c createCompany(String name, ID recordTypeID, String country, String state, String zipCode, String city, String street, Boolean doInsert) {
		c2g__codaCompany__c record = new c2g__codaCompany__c();
		record.Name = name;
		record.RecordTypeId = recordTypeID;
		record.c2g__Country__c = country;
		record.c2g__StateProvince__c = state;
		record.c2g__ZipPostCode__c = zipCode;
		record.c2g__City__c = city;
		record.c2g__Street__c = street;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create UserCompany record.
	 *
	 * @param company    related Company.
	 * @param user       related User.
	 * @param doInsert   if it is true, created record will be insered to database.
	 * @return UserCompany record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static c2g__codaUserCompany__c createUserCompany(c2g__codaCompany__c company, User user, Boolean doInsert) {
		c2g__codaUserCompany__c record = new c2g__codaUserCompany__c();
		record.c2g__Company__c = company.Id;
		record.c2g__User__c = user.Id;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Year record.
	 *
	 * @param name       year Name, for example '2014'.
	 * @param company    related Company.
	 * @param doInsert   if it is true, created record will be insered to database.
	 * @return Year record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static c2g__codaYear__c createYear(String name, c2g__codaCompany__c company, Boolean doInsert) {
		c2g__codaYear__c record = new c2g__codaYear__c(
				Name = name,
				c2g__OwnerCompany__c = company.Id,
				c2g__AutomaticPeriodList__c =  true,
				c2g__ExternalId__c = 'yzsd1234',
				c2g__NumberOfPeriods__c = 11,
				c2g__StartDate__c =  system.today() - 10,
				c2g__Status__c = 'Open',
				c2g__PeriodCalculationBasis__c = '445',
				c2g__YearEndMode__c = 'Full Accounting Code',
				c2g__UnitOfWork__c = 12
				);


		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Period record.
	 *
	 * @param company    related Company.
	 * @param year       related Year.
	 * @param doInsert   if it is true, created record will be insered to database.
	 * @return Year record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static c2g__codaPeriod__c createPeriod(c2g__codaCompany__c company, c2g__codaYear__c year, Boolean doInsert) {
		c2g__codaPeriod__c record = new c2g__codaPeriod__c(
				Name = 'Test period',
				c2g__ExternalId__c = 'period_external_ID',
				c2g__StartDate__c = System.today() - 10,
				c2g__EndDate__c = System.today() + 10,
				c2g__OwnerCompany__c = company.ID,
				c2g__PeriodNumber__c = '123',
				c2g__Description__c = 'test Desc',
				c2g__PeriodGroup__c = 'Q1',
				c2g__YearName__c = year.ID
				);


		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create General Ledger Account (API Name: c2g__codaGeneralLedgerAccount__c).
	 *
	 * @param name              Value for Name field.
	 * @param allowRevalutation Value for Allow Revaluation field.
	 * @param type              Type of General Ledger Account record.
	 * @param unitOfWork        Value for Unit of Work.
	 * @param doInsert          if it is true, created record will be insered to database.
	 * @return General Ledger Account record that was created.
	 */
	public static c2g__codaGeneralLedgerAccount__c createGeneralLedgerAccount(String name, Boolean allowRevalutation, String type, Integer unitOfWork, Boolean doInsert) {
		c2g__codaGeneralLedgerAccount__c generalLedgerAccount = new c2g__codaGeneralLedgerAccount__c(
				Name = name,
				c2g__AllowRevaluation__c = allowRevalutation,
				c2g__Type__c = type,
				c2g__UnitOfWork__c = unitOfWork,
				c2g__ReportingCode__c = name,
				c2g__BalanceSheet1__c = 'Balance Sheet',
				c2g__ExternalId__c = 'testID',
				c2g__TrialBalance1__c = 'Balance Sheet'
				);

		if (doInsert) {
			insert generalLedgerAccount;
		}

		return generalLedgerAccount;
	}

	/**
	 * Method used to create Output VAT Code (API Name: c2g__codaOutputVATCode__c).
	 *
	 * @param name                   Value for Name field.
	 * @param generalLedgerAccountID ID of General Ledger Account record.
	 * @param doInsert               if it is true, created record will be insered to database.
	 * @return Tax Code record that was created.
	 */
	public static c2g__codaTaxCode__c createTaxCode(String name, ID generalLedgerAccountID, Boolean doInsert) {
		c2g__codaTaxCode__c record = new c2g__codaTaxCode__c(Name = name, c2g__Description__c = name, c2g__GeneralLedgerAccount__c = generalLedgerAccountID);

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * @brief  Method used to create Exchange Rate (API Name: c2g__codaExchangeRate__c)
	 * @param  accountingCurrency - related Accounting Currency
	 * @param  company - related Company.
	 * @param  doInsert - Insert record or do not.
	 * @return Exchange Rate record.
	 * @author Piotr Kożuchowski
	 */
	public static c2g__codaExchangeRate__c createExchangeRate (c2g__codaAccountingCurrency__c accountingCurrency,
			c2g__codaCompany__c company, Boolean doInsert) {

		c2g__codaExchangeRate__c record = new c2g__codaExchangeRate__c(
				c2g__ExchangeRateCurrency__c = accountingCurrency.ID,
				c2g__OwnerCompany__c = company.ID,
				c2g__ExternalId__c = '12323232',
				c2g__Rate__c = 44.55,
				c2g__StartDate__c = System.today() - 10,
				c2g__UnitOfWork__c = 10
				);

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Accounting Currency (API: c2g__codaAccountingCurrency__c) record.
	 *
	 * @param name      Name of record.
	 * @param companyID ID of related Country (API: c2g__codaCompany__c).
	 * @param doInsert  if it is true, created record will be insered to database.
	 * @return Accounting Currency record that was created.
	 */
	public static c2g__codaAccountingCurrency__c createAccountingCurrency(String name, ID companyID, Boolean doInsert) {
		c2g__codaAccountingCurrency__c record = new c2g__codaAccountingCurrency__c(Name = name, c2g__OwnerCompany__c = companyID, CurrencyIsoCode = name, c2g__DecimalPlaces__c = 2, c2g__ExternalId__c = name, c2g__UnitOfWork__c = 10);

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Payable Invoice (API: c2g__codaPurchaseInvoice__c) record.
	 *
	 * @param invoiceNumber        value for c2g__AccountInvoiceNumber__c field.
	 * @param ownerID              value for OwnerID field.
	 * @param accountID            ID of related Account (API: Account).
	 * @param accountingCurrencyID value for c2g__InvoiceCurrency__c field.
	 * @param periodID             value for c2g__Period__c field.
	 * @param doInsert             if it is true, created record will be insered to database.
	 * @return Payable Invoice record that was created.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static c2g__codaPurchaseInvoice__c createPayableInvoice(String invoiceNumber, ID ownerID, ID accountID, ID accountingCurrencyID, ID periodID, Boolean doInsert) {
		c2g__codaPurchaseInvoice__c record = new c2g__codaPurchaseInvoice__c();

		record.c2g__Account__c = accountID;
		record.OwnerID = ownerID;
		record.c2g__AccountInvoiceNumber__c = invoiceNumber;
		record.c2g__InvoiceDate__c = System.Date.today();
		record.c2g__RegisteredDate__c = System.Date.today();
		record.c2g__DueDate__c = System.Date.today().addDays(30);
		record.ffap__DeriveDueDate__c = false;
		record.ffap__DeriveCurrency__c = false;
		record.ffap__DerivePeriod__c = false;
		record.ffap__CopyAccountValues__c = false;
		record.c2g__InvoiceDescription__c = 'Sample invoice description';
		record.c2g__InvoiceStatus__c = 'In Progress';
		record.c2g__InvoiceCurrency__c = accountingCurrencyID;
		record.c2g__Period__c = periodID;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	//ASCENT - this method was missing although apparently required, and causing test failures on production deployment / validation
	/**
	 * Method used to create Credit Note (API: c2g__codaPurchaseCreditNote__c) record.
	 *
	 * @param creditNoteNumber     value for c2g__AccountCreditNoteNumber__c field.
	 * @param ownerID              value for OwnerID field.
	 * @param accountID            ID of related Account (API: Account).
	 * @param accountingCurrencyID value for c2g__InvoiceCurrency__c field.
	 * @param periodID             value for c2g__Period__c field.
	 * @param doInsert             if it is true, created record will be insered to database.
	 * @return Payable Invoice record that was created.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static c2g__codaPurchaseCreditNote__c createPayableCreditNote(String creditNoteNumber, ID ownerID, ID accountID, ID accountingCurrencyID, ID periodID, Boolean doInsert) {
		c2g__codaPurchaseCreditNote__c record = new c2g__codaPurchaseCreditNote__c();

		record.c2g__Account__c = accountID;
		record.OwnerID = ownerID;
		record.c2g__AccountCreditNoteNumber__c = creditNoteNumber;
		record.c2g__CreditNoteDate__c = System.Date.today();
		record.c2g__RegisteredDate__c = System.Date.today();
		record.c2g__DueDate__c = System.Date.today().addDays(30);
		record.ffap__DeriveDueDate__c = false;
		record.ffap__DeriveCurrency__c = false;
		record.ffap__DerivePeriod__c = false;
		record.ffap__CopyAccountValues__c = false;
		record.c2g__CreditNoteDescription__c = 'Sample credit note description';
		record.c2g__CreditNoteStatus__c = 'In Progress';
		record.c2g__CreditNoteCurrency__c = accountingCurrencyID;
		record.c2g__Period__c = periodID;

		if (doInsert) {
			insert record;
		}

		return record;
	}
	//ASCENT - this method was missing although apparently required, and causing test failures on production deployment / validation

	/**
	 * Method used to create and configure Company.
	 *
	 * @param tester          User that will be used to configure.
	 * @param currencyIsoCode Currency ISO Code (3-digit).
	 * @param countryIsoCode  Country ISO Code (2-digit).
	 * @return Company record that was created.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static c2g__codaCompany__c createCompany(User tester, String currencyIsoCode, String countryIsoCode) {
		Group group_record = new Group(Name = 'test group', Type = 'Queue');
		insert group_record;

		final List<QueuesObject> queues = new List<QueuesObject>();
        queues.add(new QueuesObject(QueueID = group_record.Id, sObjectType = 'c2g__codaPurchaseInvoice__c'));
        queues.add(new QueuesObject(QueueID = group_record.Id, sObjectType = 'c2g__codaPurchaseCreditNote__c'));
        queues.add(new QueuesObject(QueueID = group_record.Id, sObjectType = 'c2g__codaInvoice__c'));
        insert queues;

		GroupMember member = new GroupMember();
		member.GroupId = group_record.ID;
		member.UserOrGroupId = tester.ID;
		insert member;

		c2g__codaCompany__c company = new c2g__codaCompany__c();
		company.Name = 'Test Record';
		company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
		company.c2g__YearEndMode__c = 'Test Code';
		company.c2g__ExternalId__c = 'ABCDE1234567876';
		company.c2g__LogoURL__c ='ww.XYZ.com';
		company.c2g__ECCountryCode__c = 'AE' ;
		company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
		company.c2g__Website__c = 'ww.xyz.com';
		company.c2g__Country__c = countryIsoCode;
		company.ownerid = group_record.Id;
		insert company;

		TestUtility.createUserCompany(company, tester, true); // method creates c2g__codaUserCompany__c record

		c2g__codaYear__c year = new c2g__codaYear__c();
		year.Name = String.valueOf(System.today().year());
		year.c2g__AutomaticPeriodList__c =  true;
		year.c2g__OwnerCompany__c = company.ID;
		year.c2g__ExternalId__c = 'yzsd1234';
		year.c2g__NumberOfPeriods__c = 11;
		year.c2g__StartDate__c = System.today() - 10;
		year.c2g__Status__c = 'Open';
		year.c2g__PeriodCalculationBasis__c = '445';
		year.c2g__YearEndMode__c = 'Full Accounting Code';
		year.c2g__UnitOfWork__c = 12;
		year.OwnerID = group_record.ID;
		insert year;

		c2g__codaPeriod__c period = new c2g__codaPeriod__c();
		period.Name ='Test period';
		period.c2g__ExternalId__c = 'period_external_ID';
		period.c2g__StartDate__c = System.today() - 10;
		period.c2g__EndDate__c= System.today() + 10;
		period.c2g__OwnerCompany__c = company.ID;
		period.c2g__PeriodNumber__c = '123';
		period.c2g__Description__c = 'test Desc';
		period.c2g__PeriodGroup__c = 'Q1';
		period.c2g__PeriodNumber__c = '1';
		period.c2g__YearName__c = year.ID;
		insert period;

		c2g__codaAccountingCurrency__c accountring_currency = new c2g__codaAccountingCurrency__c();
		accountring_currency.c2g__OwnerCompany__c = company.ID;
		accountring_currency.c2g__DecimalPlaces__c = 2;
		accountring_currency.Name = currencyIsoCode;
		accountring_currency.c2g__Dual__c = true ;
		accountring_currency.OwnerId = group_record.Id;
		insert accountring_currency;

		c2g__codaExchangeRate__c rate = new c2g__codaExchangeRate__c();
		rate.c2g__ExchangeRateCurrency__c = accountring_currency.ID;
		rate.c2g__OwnerCompany__c = company.ID;
		rate.c2g__ExternalId__c = '12323232';
		rate.c2g__Rate__c = 44.55;
		rate.c2g__StartDate__c = System.today() - 10;
		rate.c2g__UnitOfWork__c = 10;
		insert rate;

		return company;
	}

	/**
	 * Method used to create and configure Company.
	 *
	 * @param tester          User that will be used to configure.
	 * @param currencyIsoCode Currency ISO Code (3-digit).
	 * @param countryIsoCode  Country ISO Code (2-digit).
	 * @return Company record that was created.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static c2g__codaCompany__c createCompanyWithHomeCurrency(User tester, String currencyIsoCode, String countryIsoCode) {
		Group group_record = new Group(Name = 'test group', Type = 'Queue');
		insert group_record;

		QueuesObject queue = new QueuesObject(QueueID = group_record.Id, sObjectType = 'c2g__codaPurchaseInvoice__c');
		insert  queue;

		GroupMember member = new GroupMember();
		member.GroupId = group_record.ID;
		member.UserOrGroupId = tester.ID;
		insert member;

		c2g__codaCompany__c company = new c2g__codaCompany__c();
		company.Name = 'Test Record';
		company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
		company.c2g__YearEndMode__c = 'Test Code';
		company.c2g__ExternalId__c = 'ABCDE1234567876';
		company.c2g__LogoURL__c ='ww.XYZ.com';
		company.c2g__ECCountryCode__c = 'AE' ;
		company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
		company.c2g__Website__c = 'ww.xyz.com';
		company.c2g__Country__c = countryIsoCode;
		company.ownerid = group_record.Id;
		insert company;

		TestUtility.createUserCompany(company, tester, true); // method creates c2g__codaUserCompany__c record

		c2g__codaYear__c year = new c2g__codaYear__c();
		year.Name = String.valueOf(System.today().year());
		year.c2g__AutomaticPeriodList__c =  true;
		year.c2g__OwnerCompany__c = company.ID;
		year.c2g__ExternalId__c = 'yzsd1234';
		year.c2g__NumberOfPeriods__c = 11;
		year.c2g__StartDate__c = System.today() - 10;
		year.c2g__Status__c = 'Open';
		year.c2g__PeriodCalculationBasis__c = '445';
		year.c2g__YearEndMode__c = 'Full Accounting Code';
		year.c2g__UnitOfWork__c = 12;
		year.OwnerID = group_record.ID;
		insert year;

		c2g__codaPeriod__c period = new c2g__codaPeriod__c();
		period.Name ='Test period';
		period.c2g__ExternalId__c = 'period_external_ID';
		period.c2g__StartDate__c = System.today() - 10;
		period.c2g__EndDate__c= System.today() + 10;
		period.c2g__OwnerCompany__c = company.ID;
		period.c2g__PeriodNumber__c = '123';
		period.c2g__Description__c = 'test Desc';
		period.c2g__PeriodGroup__c = 'Q1';
		period.c2g__PeriodNumber__c = '1';
		period.c2g__YearName__c = year.ID;
		insert period;

		c2g__codaAccountingCurrency__c accountring_currency = new c2g__codaAccountingCurrency__c();
		accountring_currency.c2g__OwnerCompany__c = company.ID;
		accountring_currency.c2g__DecimalPlaces__c = 2;
		accountring_currency.Name = currencyIsoCode;
		accountring_currency.c2g__Dual__c = true ;
		accountring_currency.OwnerId = group_record.Id;
		accountring_currency.c2g__Home__c = true;
		insert accountring_currency;

		return company;
	}

	/* ------------------------------------------------- 4. Methods to create objects from ASCENT package ------------------------------------------------- */

	/**
	 * Method used to create Warehouse record.
	 *
	 * @param name        value for Name field.
	 * @param doInsert    if it is true, created record will be insered to database.
	 * @return Warehouse record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__Warehouse__c createWarehouse(String name, Boolean doInsert) {
		PBSI__Warehouse__c warehouse = new PBSI__Warehouse__c();
		warehouse.Name = name;

		if (doInsert) {
			insert warehouse;
		}

		return warehouse;
	}

	/**
	 * Method used to create Location record.
	 *
	 * @param name        value for Name field.
	 * @param warehouseID ID of related Warehouse.
	 * @param doInsert    if it is true, created record will be insered to database.
	 * @return Location record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__PBSI_Location__c createLocation(String name, ID warehouseID, Boolean doInsert) {
		PBSI__PBSI_Location__c location = new PBSI__PBSI_Location__c();
		location.Name = name;
		location.PBSI__Warehouselookup__c = warehouseID;

		if (doInsert) {
			insert location;
		}

		return location;
	}

	/**
	 * Method used to create Location record.
	 *
	 * @param name        value for Name field.
	 * @param accountID   ID of related Account.
	 * @param warehouseID ID of related Warehouse.
	 * @param doInsert    if it is true, created record will be insered to database.
	 * @return Location record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__PBSI_Location__c createLocation(String name, ID accountID, ID warehouseID, Boolean doInsert) {
		PBSI__PBSI_Location__c location = new PBSI__PBSI_Location__c();
		location.Name = name;
		location.PBSI__Account__c = accountID;
		location.PBSI__Warehouselookup__c = warehouseID;

		if (doInsert) {
			insert location;
		}

		return location;
	}

	/**
	 * Method used to create Lot record.
	 *
	 * @param name        value for Name field.
	 * @param locationID  ID of related Location.
	 * @param doInsert    if it is true, created record will be insered to database.
	 * @return Lot record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__Lot__c createLot(String name, ID locationID, Boolean doInsert) {
		PBSI__Lot__c lot = new PBSI__Lot__c();
		lot.Name = name;
		lot.PBSI__Location__c = locationID;

		if (doInsert) {
			insert lot;
		}

		return lot;
	}

	/**
	 * Method used to create Item Group record.
	 *
	 * @param name     value for Name field.
	 * @param yearID   ID of year record. This is value for Style Year.
	 * @param doInsert if it is true, created record will be insered to database.
	 * @return Item Group record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__PBSI_Item_Group__c createItemGroup(String name, ID yearID, Boolean doInsert) {
		PBSI__PBSI_Item_Group__c itemGroup = new PBSI__PBSI_Item_Group__c();
		itemGroup.Name = name;
		itemGroup.Style_Year__c = yearID;
		itemGroup.Group_Description__c = name;

		if (doInsert) {
			insert itemGroup;
		}

		return itemGroup;
	}

	/**
	 * Method used to create Item record.
	 *
	 * @param name     value for Name field.
	 * @param doInsert if it is true, created record will be insered to database.
	 * @return Item record.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__PBSI_Item__c createItem(String name, ID itemGroupID, ID locationID, ID warehouseID, ID fabricCodeID, ID sizeID, ID styleYearID, String eanNumber, Boolean doInsert) {
		PBSI__PBSI_Item__c item = new PBSI__PBSI_Item__c();
		item.Name = name;
		item.PBSI__Item_Group__c = itemGroupID;
		item.PBSI__Default_Location__c = locationID;
		item.PBSI__Warehouse__c = warehouseID;
		item.Fabric_Code__c = fabricCodeID;
		item.Size__c = sizeID;
		item.Style_Year__c = styleYearID;
		item.PBSI__description__c = name;
		item.PBSI__defaultunitofmeasure__c = 'EA';
		item.EAN_Number__c = eanNumber;
		item.PBSI__purchaseprice__c = 56;
		item.PBSI__salesprice__c = 88;

		if (doInsert) {
			insert item;
		}

		return item;
	}

	/**
	 * Method used to create Inventory record.
	 *
	 * @param itemID     value for PBSI__item_lookup__c field.
	 * @param locationID value for PBSI__location_lookup__c field.
	 * @param doInsert   if it is true, created record will be insered to database.
	 * @return Inventory record.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static PBSI__PBSI_Inventory__c createInventory(ID itemID, ID locationID, Boolean doInsert) {
		PBSI__PBSI_Inventory__c record = new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c = itemID, PBSI__location_lookup__c = locationID);

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Sales Order record.
	 *
	 * @param account         related Account.
	 * @param contact         related Contact.
	 * @param recordTypeID    ID of record type.
	 * @param currencyIsoCode value for CurrencyIsoCode field.
	 * @param doInsert        if it is true, created record will be insered to database.
	 * @return Sales Order record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__PBSI_Sales_Order__c createSalesOrder(Account account, Contact contact, ID recordTypeID, String currencyIsoCode, Boolean doInsert) {
		PBSI__PBSI_Sales_Order__c record = new PBSI__PBSI_Sales_Order__c();
		record.PBSI__Customer__c = account.ID;
		if(contact != null) {
			record.PBSI__Contact__c = contact.ID;
		}
		record.RecordTypeId = recordTypeID;
		record.CurrencyIsoCode = currencyIsoCode;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Sales Order record.
	 *
	 * @param companyID       ID of related Company.
	 * @param accountID       ID of related Account.
	 * @param recordTypeID    ID of record type.
	 * @param currencyIsoCode value for CurrencyIsoCode field.
	 * @param doInsert        if it is true, created record will be insered to database.
	 * @return Sales Order record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__PBSI_Sales_Order__c createSalesOrder(ID companyID, ID accountID, ID recordTypeID, String currencyIsoCode, Boolean doInsert) {
		PBSI__PBSI_Sales_Order__c record = new PBSI__PBSI_Sales_Order__c();
		record.PBSI__Customer__c = accountID;
		record.Ascent2FF__Company__c = companyID;
		record.RecordTypeId = recordTypeID;
		record.CurrencyIsoCode = currencyIsoCode;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Sales Order record.
	 *
	 * @param accountID       ID of related Account.
	 * @param recordTypeID    ID of record type.
	 * @param currencyIsoCode value for CurrencyIsoCode field.
	 * @param doInsert        if it is true, created record will be insered to database.
	 * @return Sales Order record which was created.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static PBSI__PBSI_Sales_Order__c createSalesOrder(ID accountID, ID recordTypeID, String currencyIsoCode, Boolean doInsert) {
		PBSI__PBSI_Sales_Order__c record = new PBSI__PBSI_Sales_Order__c();
		record.PBSI__Customer__c = accountID;
		record.RecordTypeId = recordTypeID;
		record.CurrencyIsoCode = currencyIsoCode;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create Sales Order record.
	 *
	 * @param salesOrderID ID of related Sales Oreder.
	 * @param itemID       ID of related Item.
	 * @param lotID        ID of related Lot.
	 * @param locationID   ID of related Location.
	 * @param quantity     quantity of Sales Order Line.
	 * @param price        price of Sales Order Line.
	 * @param doInsert     if it is true, created record will be insered to database.
	 * @return Sales Order Line record that was created.
	 */
	public static PBSI__PBSI_Sales_Order_Line__c createSalesOrderLine(ID salesOrderID, ID itemID, ID lotID, ID locationID, Decimal quantity, Decimal price, Boolean doInsert) {
		PBSI__PBSI_Sales_Order_Line__c record = new PBSI__PBSI_Sales_Order_Line__c();
		record.PBSI__Sales_Order__c = salesOrderID;
		record.PBSI__Item__c = itemID;
		record.PBSI__Lot__c = lotID;
		record.PBSI__Location__c = locationID;
		record.PBSI__Quantity__c = quantity;
		record.PBSI__Quantity_Needed__c = quantity;
		record.PBSI__Price__c = price;


		if (doInsert) {
			insert record;
		}

		return record;
	}

	/* ------------------------------------------------- 5. Methods to create objects from AddressTools package ------------------------------------------ */

	/**
	 * Method used to create Country (API Name: pw_ccpro__CountryObject__c) record.
	 *
	 * @param name           Name of country. The value for Country Name (API Name: Name) country's field.
	 * @param x2letterIsoCode 2 letter ISO Code of country. The value for ISO 3166-2 Code (API Name: pw_ccpro__IsoCode_2__c) country's field.
	 * @param x3letterIsoCode 3 letter ISO Code of country. The value for ISO 3166-3 Code (API Name: pw_ccpro__IsoCode_3__c) country's field.
	 * @param doInsert       if it is true, created record will be insered to database.
	 * @return The Country (API Name: pw_ccpro__CountryObject__c) record that was created.
	 */
	public static pw_ccpro__CountryObject__c createCountry(String name, String x2letterIsoCode, String x3letterIsoCode, Boolean doInsert) {
		pw_ccpro__CountryObject__c record = new pw_ccpro__CountryObject__c();

		record.Name = name;
		record.pw_ccpro__IsoCode_2__c = x2letterIsoCode;
		record.pw_ccpro__IsoCode_3__c = x3letterIsoCode;

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/* ------------------------------------------------- 6. Methods to insert custom settings records ----------------------------------------------------- */

	/**
	 * Method used to enable all features.
	 */
	public static void enableAllFeatures() {
		if (!Features_enable_disable_settings__c.getAll().containsKey('organisation_setting')) {
			insert new Features_enable_disable_settings__c(Name = 'organisation_setting', Enable_company_assigment__c = true, Enable_packing_automation__c = true, Enable_invoicing_automation__c = true, Enable_counting_of_styles__c = true, Enable_account_pefilling__c = true, Enable_Shipping_automation__c = true);
		} else {
			Features_enable_disable_settings__c record = Features_enable_disable_settings__c.getAll().get('organisation_setting');

			record.Enable_account_pefilling__c = true;
			record.Enable_company_assigment__c = true;
			record.Enable_counting_of_styles__c = true;
			record.Enable_invoicing_automation__c = true;
			record.Enable_packing_automation__c = true;
			record.Enable_Shipping_automation__c = true;

			update record;
		}
	}

	/**
	 * Method used to create record of CountryToCompanyMapping custom setting (API Name: CountryToCompanyMapping__c).
	 *
	 * @param countryIsoCode 2-letter Country ISO Code.
	 * @param companyID      ID of Company record.
	 * @param doInsert       if it is true, created record will be insered to database.
	 * @return
	 */
	public static CountryToCompanyMapping__c createCountryToCompanyMappingRecord(String countryIsoCode, String companyID, Boolean doInsert) {
		CountryToCompanyMapping__c record = new CountryToCompanyMapping__c(Name = countryIsoCode, Company_ID__c = companyID);

		if (doInsert) {
			insert record;
		}

		return record;
	}

	/**
	 * Method used to create CompanySettings custom setting records.
	 *
	 * @param companyName Name of Company.
	 * @author Ewa Byra (ewa.byra@nefoscdc.com).
	 */
	public static void insertCompanySettings(String companyName) {
		List<CompanySettings__c> lCompanySettings = new List<CompanySettings__c>();

		lCompanySettings.add(new CompanySettings__c(Name = 'Canada', Company_Name__c = companyName));
		lCompanySettings.add(new CompanySettings__c(Name = 'United Stated', Company_Name__c = companyName));

		insert lCompanySettings;
	}

	/**
	 * Method used to create Sales Order Packing Settings (API: Sales_Order_Packing_Settings__c) custom setting records.
	 */
	public static void insertSalesOrderPackingSettings() {
		List<Sales_Order_Packing_Settings__c> lSalesOrderPackingSettings = new List<Sales_Order_Packing_Settings__c>();

		lSalesOrderPackingSettings.add(new Sales_Order_Packing_Settings__c(Name = 'WEB_ORDER_RECORD_TYPE_NAME', Value__c = 'Web_Order'));
		lSalesOrderPackingSettings.add(new Sales_Order_Packing_Settings__c(Name = 'SALES_ORDER_RECORD_TYPE_NAME', Value__c = 'Sales_Order'));
		lSalesOrderPackingSettings.add(new Sales_Order_Packing_Settings__c(Name = 'WEB_ORDER_COMPLETE_STATUS_VALUE', Value__c = 'Completion'));
		lSalesOrderPackingSettings.add(new Sales_Order_Packing_Settings__c(Name = 'SALES_ORDER_FINAL_STATUS', Value__c = 'closed'));
		lSalesOrderPackingSettings.add(new Sales_Order_Packing_Settings__c(Name = 'SALES_ORDER_FINAL_STAGE', Value__c = 'packed'));
		lSalesOrderPackingSettings.add(new Sales_Order_Packing_Settings__c(Name = 'SALES_ORDER_PARTIALLY_COMPLETE_STATUS', Value__c = 'partially complete'));
		lSalesOrderPackingSettings.add(new Sales_Order_Packing_Settings__c(Name = 'SALES_ORDER_OPEN_STAGE', Value__c = 'open'));

		insert lSalesOrderPackingSettings;
	}

	/**
	 * Method used to insert values of Account Settings (default field values) (API: Account_Settings_Default_Values__c) custom setting.<br>
	 * This method creates records of c2g__codaGeneralLedgerAccount__c, On_Payment_Terms__c and c2g__codaTaxCode__c to store relations to them in custom setting records.
	 */
	public static void insertAccountSettingsDefaultValuesRecords() {
		List<Account_Settings_Default_Values__c> lAccountSettingsRecords = new List<Account_Settings_Default_Values__c>();

		c2g__codaGeneralLedgerAccount__c generalLedgerAccountRecord = TestUtility.createGeneralLedgerAccount('1100', false, 'Balance Sheet', 1, true);

		List<c2g__codaTaxCode__c> lTaxCodeRecords = new List<c2g__codaTaxCode__c>();
		lTaxCodeRecords.add(TestUtility.createTaxCode('VOLU', generalLedgerAccountRecord.ID, false));
		lTaxCodeRecords.add(TestUtility.createTaxCode('VOSTD', generalLedgerAccountRecord.ID, false));
		lTaxCodeRecords.add(TestUtility.createTaxCode('VOUSZ', generalLedgerAccountRecord.ID, false));
		lTaxCodeRecords.add(TestUtility.createTaxCode('VOEU', generalLedgerAccountRecord.ID, false));
		lTaxCodeRecords.add(TestUtility.createTaxCode('VO3Z', generalLedgerAccountRecord.ID, false));
		insert lTaxCodeRecords;

		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #00', Field_Name__c = 'On_Payment_Term__c', Country__c = '', Value__c = String.valueOf(TestUtility.createOnPaymentTerm('Advance Payment', 0, 0.00, true).ID)));

		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #01', Field_Name__c = 'c2g__CODAAccountsReceivableControl__c', Country__c = '', Value__c = String.valueOf(generalLedgerAccountRecord.ID)));

		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #02', Field_Name__c = 'c2g__CODATaxCalculationMethod__c', Country__c = '', Value__c = 'Gross'));

		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #03', Field_Name__c = 'c2g__CODAOutputVATCode__c', Country__c = 'LU', Value__c = String.valueOf(lTaxCodeRecords.get(0).ID)));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #04', Field_Name__c = 'c2g__CODAOutputVATCode__c', Country__c = 'CH', Value__c = String.valueOf(lTaxCodeRecords.get(1).ID)));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #05', Field_Name__c = 'c2g__CODAOutputVATCode__c', Country__c = 'US', Value__c = String.valueOf(lTaxCodeRecords.get(2).ID)));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #06', Field_Name__c = 'c2g__CODAOutputVATCode__c', Country__c = 'CA', Value__c = String.valueOf(lTaxCodeRecords.get(2).ID)));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #07', Field_Name__c = 'c2g__CODAOutputVATCode__c', Country__c = 'DE', Value__c = String.valueOf(lTaxCodeRecords.get(4).ID)));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #08', Field_Name__c = 'c2g__CODAOutputVATCode__c', Country__c = 'AT', Value__c = String.valueOf(lTaxCodeRecords.get(4).ID)));

		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #09', Field_Name__c = 'c2g__CODAVATStatus__c', Country__c = 'CH', Value__c = 'Home'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #10', Field_Name__c = 'c2g__CODAVATStatus__c', Country__c = 'DE', Value__c = 'EC Non-registered'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #11', Field_Name__c = 'c2g__CODAVATStatus__c', Country__c = 'AT', Value__c = 'EC Non-registered'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #12', Field_Name__c = 'c2g__CODAVATStatus__c', Country__c = '', Value__c = 'Export'));

		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #13', Field_Name__c = 'c2g__CODASalesTaxStatus__c', Country__c = 'CH', Value__c = 'Taxable'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #14', Field_Name__c = 'c2g__CODASalesTaxStatus__c', Country__c = 'DE', Value__c = 'Taxable'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #15', Field_Name__c = 'c2g__CODASalesTaxStatus__c', Country__c = 'AT', Value__c = 'Taxable'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #16', Field_Name__c = 'c2g__CODASalesTaxStatus__c', Country__c = '', Value__c = 'Exempt'));

		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #17', Field_Name__c = 'PBSI__Default_Delivery_for_Purchase_Orders__c', Country__c = '', Value__c = 'true'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #18', Field_Name__c = 'Pre_Order_Discount__c', Country__c = '', Value__c = '0'));
		lAccountSettingsRecords.add(new Account_Settings_Default_Values__c(Name = 'Record #19', Field_Name__c = 'c2g__CODACreditLimitReviewed__c', Country__c = '', Value__c = String.valueOf(Date.today())));

		insert lAccountSettingsRecords;
	}

	/**
	 * Method used to insert values of Sales Invoice Settings (Automation) (API: Sales_Invoice_Settings_Automation__c) custom setting.
	 */
	/*
	   public static void insertSalesInvoiceAutomationRecords() {
	   List<Sales_Invoice_Settings_Automation__c> lSalesInvoiceAutomationRecords = new List<Sales_Invoice_Settings_Automation__c>();

	   c2g__codaCompany__c company1 = TestUtility.createCompany('Company 1', true);
	   c2g__codaCompany__c company2 = TestUtility.createCompany('Company 2', true);

	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #01', Country__c = '', Field_Name__c = 'c2g__Interval__c', Value__c = 'Monthly', Is_Value_taken_from_Sales_Order__c = false));
	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #02', Country__c = '', Field_Name__c = 'c2g__InvoiceStatus__c', Value__c = 'In Progress', Is_Value_taken_from_Sales_Order__c = false));
	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #03', Country__c = '', Field_Name__c = 'c2g__PrintStatus__c', Value__c = 'Not Printed', Is_Value_taken_from_Sales_Order__c = false));
	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #04', Country__c = '', Field_Name__c = 'ffbilling__CopyAccountValues__c', Value__c = 'true', Is_Value_taken_from_Sales_Order__c = false));
	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #05', Country__c = '', Field_Name__c = 'ffbilling__DerivePeriod__c', Value__c = 'true', Is_Value_taken_from_Sales_Order__c = false));
	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #06', Country__c = '', Field_Name__c = 'Ascent2FF__Sales_Order__c', Value__c = 'ID', Is_Value_taken_from_Sales_Order__c = true));
	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #07', Country__c = '', Field_Name__c = 'CurrencyIsoCode', Value__c = 'CurrencyIsoCode', Is_Value_taken_from_Sales_Order__c = true));
	   lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #08', Country__c = '', Field_Name__c = 'c2g__Account__c', Value__c = 'PBSI__Customer__c', Is_Value_taken_from_Sales_Order__c = true));
	//lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #09', Country__c = '', Field_Name__c = 'c2g__OwnerCompany__c', Value__c = String.valueOf(company1.ID), Is_Value_taken_from_Sales_Order__c = false));
	//lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #10', Country__c = 'US', Field_Name__c = 'c2g__OwnerCompany__c', Value__c = String.valueOf(company2.ID), Is_Value_taken_from_Sales_Order__c = false));
	//lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #11', Country__c = 'CA', Field_Name__c = 'c2g__OwnerCompany__c', Value__c = String.valueOf(company2.ID), Is_Value_taken_from_Sales_Order__c = false));
	lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #12', Country__c = '', Field_Name__c = 'c2g__ShippingMethod__c', Value__c = '', Is_Value_taken_from_Sales_Order__c = false));
	lSalesInvoiceAutomationRecords.add(new Sales_Invoice_Settings_Automation__c(Name = 'Record #13', Country__c = '', Field_Name__c = 'c2g__DiscardReason__c', Value__c = '', Is_Value_taken_from_Sales_Order__c = false));

	insert lSalesInvoiceAutomationRecords;
	   }
	 */

	/* ------------------------------------------------- 7. Utility methods ------------------------------------------------------------------------------- */

	/**
	 * Method used to get Record Type ID.
	 *
	 * @param objectApiName API Name of sObject.
	 * @param recordTypeName name of Record Type.
	 * @return Record Type ID.
	 */
	public static ID getRecordTypeID(String objectApiName, String recordTypeName) {
		ID recordTypeID = null;

		for (Schema.RecordTypeInfo recordTypeInfo : Schema.getGlobalDescribe().get(objectApiName).getDescribe().getRecordTypeInfos()) {
			if (recordTypeInfo.getName().equals(recordTypeName)) {
				recordTypeID = recordTypeInfo.getRecordTypeId();
				break;
			}
		}

		return recordTypeID;
	}

	/**
	 * Method used to get list of picklist values.
	 *
	 * @param objectApiName API Name of sObject.
	 * @param fieldApiName API name of picklist field.
	 * @return List of picklist values.
	 */
	public static List<Schema.PicklistEntry> getPicklistValues(String objectApiName, String fieldApiName) {
		return Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues();
	}

	/**
	 * @brief  Method used to create AccountGroup
	 * @param  name - Name of the Account Group
	 * @param  code - Account Group Code
	 * @param  doInsert - if it is true, created record will be insered to database.
	 * @return accountGroup
	 * @author Piotr Kożuchowski
	 */
	public static PBSI__Account_Group__c createAccountGroup (String name, String code, Boolean doInsert) {
		PBSI__Account_Group__c accountGroup = new PBSI__Account_Group__c(
				Name = name,
				PBSI__Account_Group_Code__c = code
				);


		if (doInsert) {
			insert accountGroup;
		}
		return accountGroup;
	}
	/******************************************************************************/

	/**
	 * Method creates and inserts list of contatcts with different functions. 
	 * This method is used in test for batch UpdateContactsFunction.
	 * @return List of Contacts.
	 */
	public static List<Contact> createContactsWithFunctions(){
		Account acc = createAccount('Test', null, true);
		List<Contact> contacts = new List<Contact>();

		Contact c1 = createContact('Without any f', acc, false);
		contacts.add(c1);

		Contact c2 = createContact('Buyer', acc, false);
		c2.Buyer__c = true;
		contacts.add(c2);

		Contact c3 = createContact('Department Manager', acc, false);
		c3.Department_manager__c = true;
		contacts.add(c3);

		Contact c4 =  createContact('Accounting', acc, false);
		c4.Accounting__c = true;
		contacts.add(c4);

		Contact c5 = createContact('Shop Assistant', acc, false);
		c5.Shop_assistant__c = true;
		contacts.add(c5);

		Contact c6 = createContact('Store Manager', acc, false);
		c6.Store_manager__c = true;
		contacts.add(c6);

		Contact c7 =  createContact('Store Manager & Buyer', acc, false);
		c7.Store_manager__c = true;
		c7.Buyer__c = true;
		contacts.add(c7);

		Contact c8 = createContact('Owner', acc, false);
		c8.owner__c = true;
		contacts.add(c8);

		Contact c9 = createContact('Owner & MSP Store Manager', acc, false);
		c9.owner__c = true;
		c9.Function__c = ContactFunctions.STORE_MANAGER;
		contacts.add(c9);

		PBSI__Account_Group__c aGroup = new PBSI__Account_Group__c(Name = 'Dealers', 
				PBSI__Account_Group_Code__c='1111');
		insert aGroup;

		Account b2bAccount = createAccount('Supersports', 'EUR', false);
		b2bAccount.PBSI__Account_Group__c = aGroup.Id;
		b2bAccount.E_Shop_Dealer__c = 'Dealer and Point of Sale';
		b2bAccount.ShippingCountry = 'Switzerland';
		b2bAccount.Status__c = 'Active';

		insert b2bAccount;

		Contact b2bContact = createContact(b2bAccount.Name + '1', b2bAccount, false);
		b2bContact.FirstName = 'Adam';
		b2bContact.Email = 'example@example.com';
		b2bContact.Portal_users_language__c = 'en_US';
		b2bContact.Portal_user_locale__c = 'es_ES_EURO';
		b2bContact.Store_manager__c = true;
		b2bContact.Function__c = 'B2B-Portal-User';

		contacts.add(b2bContact);
		insert contacts;
		System.debug('Contacts inseted');
		for (Contact c: contacts){
			System.debug('Contact id  is: ' + c);
		}
		return contacts;
	}

	public static KN_Integration_Settings__c createKNIntegrationSettings (Boolean toInsert){
		KN_Integration_Settings__c mycs = new KN_Integration_Settings__c(Name= 'ConfigurationSettings');
		mycs.Allowed_characters_expression__c = '^[\\w,\\.@\\-_()&$?!#%\\/ +]*$';
		mycs.Auth_User__c = 'madebymade';
		mycs.Auth_Password__c = 'j3dfyjHo';
		mycs.Endpoint__c = 'http://www.kuehne-nagel.com/listeners/prod';     
			mycs.Contact_Email__c = 'knglobal.edi@kuehne-nagel.com';
		mycs.Contact_CC_Email__c = 'rory@madetech.co.uk';
		mycs.Contact_Record__c = '003L000000HuIcV';          
		mycs.Email_Template_EU__c = '00XL0000000I60O';          
		mycs.Email_Template_US__c = '00XL0000000I60J'; 
		mycs.Email_Template_CA__c = '00XL0000000I60K';   
		mycs.Email_Template_JP__c = '00XL0000000I60K'; 
		mycs.Reciever_Identifier__c = 'LUX03';            
		mycs.Client_ID_EU__c = 'client_eu';
		mycs.Client_ID_US__c = 'client_us'; 
		mycs.Client_ID_CA__c = 'client_ca';
		mycs.Client_ID_JP__c = 'client_jp';
		mycs.Logical_Address_CA__c = 'logical_ca'; 
		mycs.Logical_Address_US__c = 'logical_us'; 
		mycs.Logical_Address_EU__c = 'logical_eu'; 
		mycs.Logical_Address_JP__c = 'logical_jp';
		mycs.Order_Type_CA__c = 'order_type_ca'; 
		mycs.Order_Type_US__c = 'order_type_us'; 
		mycs.Order_Type_EU__c = 'order_type_eu';
		mycs.Order_Type_JP__c = 'order_type_jp';
		mycs.Depot_CA__c = 'depot_ca';
		mycs.Depot_EU__c = 'depot_eu';
		mycs.Depot_US__c = 'depot_us';  
		mycs.Depot_JP__c = 'depot_jp';

		if (toInsert){
			insert mycs;
		}
		return mycs;
	}
}