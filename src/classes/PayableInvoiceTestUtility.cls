@isTest public class PayableInvoiceTestUtility {
	public class DataCreator {
		public Account testAccount {
			public get{
				if(this.testAccount == null) {
					try {
						this.testAccount = [SELECT Id, Name FROM Account WHERE Name =: 'Test account'];
					} catch (Exception e){
						this.testAccount = new Account(Name = 'Test account');
						insert this.testAccount;
					}
				}
				return this.testAccount;
			}
			private set;
		}
		public Contact testContact {
			public get{
				if(this.testContact == null) {
					try {
						this.testContact = [SELECT Id, LastName, AccountId FROM Contact WHERE LastName =: 'Test contact'];
					} catch (Exception e){
						this.testContact = new Contact(LastName = 'Test contact', AccountId = this.testAccount.Id);
						insert this.testContact;
					}
				}
				return this.testContact;
			}
			private set;
		}
		public User testAdmin {
			public get{
				if(this.testAdmin == null) {
					try {
						this.testAdmin = [SELECT Id, LastName FROM User WHERE LastName =: 'Admin_user'];
					} catch (Exception e){
						this.testAdmin = TestUtility.createUser('Admin_user', null, true);
					}
				}
				return this.testAdmin;
			}
			private set;
		}
		public User originalApprover {
			public get{
				if(this.originalApprover == null) {
					try {
						this.originalApprover = [SELECT Id, LastName FROM User WHERE LastName =: 'original_approver'];
					} catch (Exception e){
						this.originalApprover = TestUtility.createUser('original_approver', null, true);
					}
				}
				return this.originalApprover;
			}
			private set;
		}
		public User newApprover {
			public get{
				if(this.newApprover == null) {
					try {
						this.newApprover = [SELECT Id, LastName FROM User WHERE LastName =: 'new_approver'];
					} catch (Exception e){
						this.newApprover = TestUtility.createUser('new_approver', null, true);
					}
				}
				return this.newApprover;
			}
			private set;
		}

		public c2g__codaCompany__c testCompany {
			public get{
				if(this.testCompany == null) {
					try {
						this.testCompany = [SELECT Id, Name, c2g__CashMatchingCurrencyMode__c, c2g__YearEndMode__c, c2g__ExternalId__c, c2g__LogoURL__c, c2g__ECCountryCode__c, c2g__VATRegistrationNumber__c, c2g__Website__c, c2g__Country__c, ownerid FROM c2g__codaCompany__c WHERE Name =: 'Test Record'];
					} catch (Exception e){
						this.testCompany = TestUtility.createCompany(this.testAdmin, 'CHF', 'CH');
						TestUtility.createUserCompany(this.testCompany, this.originalApprover, true);
						TestUtility.createUserCompany(this.testCompany, this.newApprover, true);
					}
				}
				return this.testCompany;
			}
			private set;
		}

		public c2g__codaAccountingCurrency__c testCurrency {
			public get{
				if(this.testCurrency == null) {
					try {
						testCurrency = [SELECT ID FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c = : this.testCompany.Id AND Name = 'CHF'];
					} catch (Exception e){
					}
				}
				return this.testCurrency;
			}
			private set;
		}

		public c2g__codaPeriod__c testPeriod {
			public get{
				if(this.testPeriod == null) {
					try {
						testPeriod = [SELECT ID FROM c2g__codaPeriod__c WHERE c2g__OwnerCompany__c = :this.testCompany.Id LIMIT 1];
					} catch (Exception e){
					}
				}
				return this.testPeriod;
			}
			private set;
		}

		public Map<Id, c2g__codaPurchaseInvoice__C> testPins {
			public get{
				return new Map<Id, c2g__codaPurchaseInvoice__C>([SELECT Id, Name, Payment_Date__c, Approving_user__c, Approval_status__c FROM c2g__codaPurchaseInvoice__c]);
			}
			private set;
		}

		public Map<Id, c2g__codaPurchaseCreditNote__c> testPcrs {
			public get{
				return new Map<Id, c2g__codaPurchaseCreditNote__c>([SELECT Id, Approving_user__c, Approval_status__c FROM c2g__codaPurchaseCreditNote__c]);
			}
			private set;
		}

		public c2g__codaPurchaseInvoice__c createPIN(Integer counter, Id approverId) {
			c2g__codaPurchaseInvoice__c testPin = TestUtility.createPayableInvoice('Test_Invoice' + counter, this.testCompany.OwnerId, this.testAccount.Id, this.testCurrency.Id, this.testPeriod.Id, false);
			testPin.Approving_user__c = approverId;
			return testPin;
		}

		public c2g__codaPurchaseInvoice__c createPIN(String Name) {
			c2g__codaPurchaseInvoice__c testPin = TestUtility.createPayableInvoice(Name, this.testCompany.OwnerId, this.testAccount.Id, this.testCurrency.Id, this.testPeriod.Id, false);
			testPin.Approving_user__c = this.originalApprover.Id;
			return testPin;
		}

		public c2g__codaPurchaseCreditNote__c createPCR(Integer counter, Id approverId) {
			c2g__codaPurchaseCreditNote__c testPCR = TestUtility.createPayableCreditNote('Test_Credit_Note_' + counter, this.testCompany.OwnerId, this.testAccount.Id, this.testCurrency.Id, this.testPeriod.Id, false);
			testPCR.Approving_user__c = approverId;
			return testPCR;
		}

	}
}