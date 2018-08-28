@isTest
public with sharing class SalesCreditNotesTriggerHandlerTest {
	
	@isTest
	public static void prepareData() {
		pw_ccpro__CountryObject__c countryTmp = new pw_ccpro__CountryObject__c();
		countryTmp.Name = 'Poland';
		countryTmp.pw_ccpro__IsoCode_2__c = 'PL';
		countryTmp.pw_ccpro__IsoCode_3__c = 'Pol';
		insert countryTmp;

		c2g__codaCompany__c companyTmp = new c2g__codaCompany__c();
		companyTmp.Name = 'testCompany';
		insert companyTmp;

		User usr = [Select id from User where Id = :UserInfo.getUserId()];
		Group companyGroup = null;
		
		 System.RunAs(usr) { // to avoid mixDML error

			c2g.CODACompanyWebService.createQueue(companyTmp.Id, 'CAD', companyTmp.Name);
			c2g.CODAYearWebService.calculatePeriods(null);
			c2g.CODACompanyWebService.activateCompany(companyTmp.Id, 'CAD', companyTmp.Name);

			c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
			userCompany.c2g__Company__c = companyTmp.Id;
			userCompany.c2g__User__c = usr.Id;
			insert userCompany; 

			String queueName = 'FF ' + companyTmp.Name;
			companyGroup = [select Id from Group where Name = :queueName And Type = 'Queue'];
			insert new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = UserInfo.getUserId());
		 }

		c2g__codaYear__c finCalendar = new c2g__codaYear__c();
		finCalendar.c2g__StartDate__c = System.today();
		finCalendar.c2g__OwnerCompany__c = companyTmp.Id;
		finCalendar.c2g__NumberOfPeriods__c = 1;
		insert finCalendar;

		c2g.CODAYearWebService.calculatePeriods(finCalendar.Id);

		c2g__codaAccountingCurrency__c accCurrency = new c2g__codaAccountingCurrency__c();
		accCurrency.Name = 'CAD';
		accCurrency.c2g__OwnerCompany__c = companyTmp.Id;
		accCurrency.c2g__DecimalPlaces__c = 1;
		accCurrency.c2g__Home__c = true;
		accCurrency.c2g__Dual__c = true;
		insert accCurrency;

		c2g__codaGeneralLedgerAccount__c glAccount = new c2g__codaGeneralLedgerAccount__c();
		glAccount.c2g__ReportingCode__c = 'testCode';
		glAccount.c2g__Type__c = 'Balance Sheet';
		insert glAccount;

		Account acc = new Account();
		acc.Name = 'testKonto';
		acc.c2g__CODAAccountTradingCurrency__c = 'CAD'; 
		acc.BillingCountry = countryTmp.Name;
		acc.c2g__CODAAccountsReceivableControl__c = glAccount.Id;
		insert acc;

		c2g__codaCreditNote__c creditNote  = new c2g__codaCreditNote__c();
		creditNote.c2g__Account__c = acc.Id;
		creditNote.c2g__CreditNoteReason__c = 'Damaged Goods';
		//insert creditNote;

		Product2 product2 = new Product2();
		product2.Name = 'testProduct';
		product2.c2g__CODASalesRevenueAccount__c = glAccount.Id;
		insert product2;

		c2g__codaCreditNoteLineItem__c salesCreditLine = new c2g__codaCreditNoteLineItem__c();
		salesCreditLine.c2g__UnitPrice__c = 300;
		salesCreditLine.c2g__Quantity__c = 1.0;
		salesCreditLine.c2g__CreditNote__c = creditNote.Id;
		salesCreditLine.c2g__Product__c = product2.Id;
		//insert salesCreditLine;
		
		Test.startTest(); 
			c2g.CODAAPICommon_10_0.Context context = new c2g.CODAAPICommon_10_0.Context();
			context.CompanyName = companyTmp.Name;

			c2g.CODAAPICreditNoteTypes_10_0.CreditNote nref = new c2g.CODAAPICreditNoteTypes_10_0.CreditNote();
			nref.CreditNoteReason = c2g.CODAAPICreditNoteTypes_10_0.enumCreditNoteReason.DamagedGoods;
			nref.Account = c2g.CODAAPICommon.Reference.getRef(acc.Id, 'testKonto');
			
			c2g.CODAAPICreditNoteLineItemTypes_10_0.CreditNoteLineItem nLine = new c2g.CODAAPICreditNoteLineItemTypes_10_0.CreditNoteLineItem();
			nLine.CreditNote = c2g.CODAAPICommon.Reference.getRef(nref.Id, 'nref');

			c2g.CODAAPICreditNoteLineItemTypes_10_0.CreditNoteLineItems nLines = new c2g.CODAAPICreditNoteLineItemTypes_10_0.CreditNoteLineItems();
			nLines.LineItemList = new LIST<c2g.CODAAPICreditNoteLineItemTypes_10_0.CreditNoteLineItem>();

			c2g.CODAAPICreditNoteLineItemTypes_10_0.CreditNoteLineItem populateLines = new c2g.CODAAPICreditNoteLineItemTypes_10_0.CreditNoteLineItem();
			populateLines.Name = 'testLine';
			populateLines.Product = c2g.CODAAPICommon.Reference.getRef(product2.Id, 'product2');

			nLines.LineItemList.add(populateLines);
			nref.LineItems = nLines;

			c2g.CODAAPICommon.Reference newCreditNote = c2g.CODAAPISalesCreditNote_10_0.createCreditNote(context, nref);

			c2g.CODAAPISalesCreditNote_10_0.postCreditNote(context, newCreditNote);
			Test.stopTest(); 

			c2g__codaCreditNote__c postedCreditNote = [select id from c2g__codacreditnote__c where c2g__creditnotestatus__c = 'Complete'];
			List<attachment> attachmentList = [SELECT id, name, body FROM attachment WHERE parentId = : postedCreditNote.Id];

			for(attachment att : attachmentList) {
				System.assert(att.Name.containsIgnoreCase(newCreditNote.Name) && att.Name.containsIgnoreCase(nref.Account.Name));	
			}
	}

	
}