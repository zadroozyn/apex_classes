/**
 * Class contains methods that operates on Account object.<br>
 * Logic that is contained in this class is using i.a. in automation of invoicing functionality.
 *
 * @version 2.0  2015.11.30  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Added Map<ID, List<wbsendit__Campaign_Activity__c>> getRelatedCampaignActivites(Set<ID>) method.
 *
 * @version 1.1  2014.08.20  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Changes in automatic invoicing functionality. The Account records are given to actualize instead of their IDs.
 *
 * @version 1.0  2014.08.11  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 *
 * @see Account sObject.
 */

public without sharing class AccountMethods {

	/**
	 * Account sObject descibe.
	 */
	public static final Schema.DescribeSObjectResult ACCOUNT_OBJECT_SCHEMA_DESCRIBE_RESULT = Schema.SObjectType.Account;

	/**
	 * Method used to assign default values to Account records.<br>
	 * Settings for Account updation are getting from 'Account Settings (default field values)' custom setting.<br>
	 * This custom setting store information about Account's field API names, values that are assigning and Account customer country,
	 * because some values are defined depending on the customer country. Default values (that are not defined for specific country)
	 * have country field empty. Country field stores three characters country ISO code that is mapped based on 'Country' records.<br>
	 * Follow the Account's fields that are updating:
	 * <ul>
	 * 		<li>On Payment Terms (API Name: On_Payment_Term__c) - lookup field on On Payment Term records.</li>
	 * 		<li>Accounts Receivable Conrol (API Name: c2g__CODAAccountsReceivableControl__c) - lookup field on General Ledger Account record.</li>
	 * 		<li>Tax Calculation Method (API Name: c2g__CODATaxCalculationMethod__c) - picklist field.</li>
	 *		<li>Output VAT Code (API Name: c2g__CODAOutputVATCode__c) - lookup field on Tax Code.</li>
	 *		<li>Tax Status (API Name: c2g__CODAVATStatus__c) - picklist field.</li>
	 * 		<li>Sales Tax Status (API Name: c2g__CODASalesTaxStatus__c) - picklist field.</li>
	 * </ul>
	 *
	 * @param lAccounts List of Account records.
	 * @param doUpdate  If it is true, list of accounts will be updated.
	 */
	public static void assignDefaultValues(List<Account> lAccounts, Boolean doUpdate) {
		String value;
		String countryISOCode;
		Map<String, String> mCountryISOCodeToValue;
		Map<String, Map<String, String>> mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue = AccountMethods.getAccountSettingDefaultValuesMap();

		for (Account record : lAccounts) {
			for (String accountFieldAPIName : mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue.keySet()) {
				mCountryISOCodeToValue = mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue.get(accountFieldAPIName);

				countryISOCode = Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.containsKey(record.BillingCountry) ?
									Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.get(record.BillingCountry) :
									'';

				value = mCountryISOCodeToValue.containsKey(countryISOCode) ?
							mCountryISOCodeToValue.get(countryISOCode) :
							mCountryISOCodeToValue.containsKey(null) ?
								mCountryISOCodeToValue.get(null) :
								'';

				try {
					AccountMethods.setAccountFieldValue(record, accountFieldAPIName, value);
				} catch (Exception ex) {
					System.debug(LoggingLevel.ERROR, 'TYPE: ' + ex.getTypeName() +
											'\nMESSAGE: ' + ex.getMessage() +
											'\nACCOUNT ID: ' + record.ID +
											'\nFIELD API NAME: ' + accountFieldAPIName +
											'\nVALUE: ' + value);
				}
			}
		}

		if (doUpdate) {
			update lAccounts;
		}
	}

	/* --------------------------------------------------- GETTERS & SETTERS --------------------------------------------------- */

	/**
	 * Method used to create map of Account's field API names to map of country ISO code to field's value based on records store in 'Account Settings (default field values)' custom setting.<br>
	 * Method is used in actualizeAccountsAfterSalesInvoiceInsertion(Set<ID>) method.
	 *
	 * @return map of Account's field API names to map of country ISO code to field's value.
	 */
	private static Map<String, Map<String, String>> getAccountSettingDefaultValuesMap() {
		Map<String, Map<String, String>> mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue = new Map<String, Map<String, String>>();

		for (Account_Settings_Default_Values__c record : Account_Settings_Default_Values__c.getAll().values()) {

			if (!mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue.containsKey(record.Field_Name__c)) {
				mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue.put(record.Field_Name__c, new Map<String, String>());
			}

			mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue.get(record.Field_Name__c).put(record.Country__c, record.Value__c);
		}

		return mAccountFieldAPINameToMapOfCountryISOCodeToFieldValue;
	}

	/**
	 * Method used to get Account field API Names that will be actualized.
	 *
	 * @return Set of Account's field API Names.
	 */
	public static Set<String> getAccountFieldAPINamesToAssignDefaultValues() {
		Set<String> sAccountFieldAPINames = new Set<String>();
		sAccountFieldAPINames.addAll(AccountMethods.getAccountSettingDefaultValuesMap().keySet());
		sAccountFieldAPINames.add('BillingCountry');
		sAccountFieldAPINames.add('ID');

		return sAccountFieldAPINames;
	}

	/**
	 * Method used to set field value.<br>
	 * It checks and converts value to field type and sets it.
	 *
	 * @param record       Account record to update.
	 * @param fieldAPIName API Name of Account field to update.
	 * @param value        New value of Accout field as String.
	 */
	public static void setAccountFieldValue(Account record, String fieldAPIName, String value) {
		Schema.DisplayType fieldType = AccountMethods.ACCOUNT_OBJECT_SCHEMA_DESCRIBE_RESULT.fields.getMap().get(fieldAPIName).getDescribe().getType();

		if (fieldType == Schema.DisplayType.REFERENCE) {
			if (value != null && value != '') {
				record.put(fieldAPIName, (ID) value);
			}
		} else if (fieldType == Schema.DisplayType.Boolean) {
			record.put(fieldAPIName, Boolean.valueOf(value));
		} else if (fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Percent) {
			record.put(fieldAPIName, Decimal.valueOf(value));
		} else if (fieldType == Schema.DisplayType.Double) {
			record.put(fieldAPIName, Double.valueOf(value));
		} else if (fieldType == Schema.DisplayType.Integer) {
			record.put(fieldAPIName, Integer.valueOf(value));
		} else if (fieldType == Schema.DisplayType.Date) {
			record.put(fieldAPIName, Date.valueOf(value));
		} else if (fieldType == Schema.DisplayType.DateTime) {
			record.put(fieldAPIName, DateTime.valueOf(value));
		} else {
			record.put(fieldAPIName, value);
		}

	}

	/**
	 * Method used to get Account records that need to have actubalize default values.<br>
	 * It is invoked from trigger on account on before update event.
	 *
	 * @param mAccountsOld Map of old Account records (before changes).
	 * @param mAccountsNew Map of new Account records (after changes).
	 * @return List of Account record to that has changed Billing Country.
	 */
	public static List<Account> getAccountsToActualize(Map<ID, Account> mAccountsOld, Map<ID, Account> mAccountsNew) {
		List<Account> lAccounts = new List<Account>();

		for (Account newRecord : mAccountsNew.values()) {
			if (newRecord.BillingCountry != mAccountsOld.get(newRecord.ID).BillingCountry) {
				lAccounts.add(newRecord);
			}
		}

		return lAccounts;
	}

  /**
   * Method used to get Campaign Activities (API: wbsendit__Campaign_Activity__c) related to Accounts which IDs are in the given Set.
   *
   * @param sAccountIDs Set with Account IDs.
   * @return Map of Account IDs to list of related Campaign Activity records.
   * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
   */
  	public static Map<ID, List<wbsendit__Campaign_Activity__c>> getRelatedCampaignActivites(Set<ID> sAccountIDs) {
	    Map<ID, List<wbsendit__Campaign_Activity__c>> mAccountIDToCampaignActivities = new Map<ID, List<wbsendit__Campaign_Activity__c>>();

	  	for (ID accountID : sAccountIDs) {
	      	mAccountIDToCampaignActivities.put(accountID, new List<wbsendit__Campaign_Activity__c>());
	  	}
		Boolean toBeAdded;

	  	for (wbsendit__Campaign_Activity__c campaign_activity : [SELECT ID, Name, wbsendit__Activity_Date__c, wbsendit__Contact__r.AccountID, wbsendit__Contact__c 
	  			FROM wbsendit__Campaign_Activity__c 
	  			WHERE wbsendit__Contact__r.AccountID IN :sAccountIDs AND (wbsendit__Activity__c = 'Opened' OR wbsendit__Activity__c = 'Clicked') ORDER BY wbsendit__Activity_Date__c DESC]) {

	      	toBeAdded = true;

			for (wbsendit__Campaign_Activity__c campaign_activity_in_list : mAccountIDToCampaignActivities.get(campaign_activity.wbsendit__Contact__r.AccountID)) {
				if (campaign_activity_in_list.Name.equals(campaign_activity.Name)) {
					toBeAdded = false;
					break;
				}
			}

			if (toBeAdded) {
				mAccountIDToCampaignActivities.get(campaign_activity.wbsendit__Contact__r.AccountID).add(campaign_activity);
			}
	  	}

	    return mAccountIDToCampaignActivities;
  	}

  	private static final List<String> EURO_DEALERS_COUNTRIES = new List<String>{'France','Netherlands','Belgium','Ireland','Germany','Austria'};
  	private static Set<Id> EURO_DEALERS_COUNTRIES_IDS {
  		get {
  			if(EURO_DEALERS_COUNTRIES_IDS == null) {
  				EURO_DEALERS_COUNTRIES_IDS = new Map<Id,pw_ccpro__CountryObject__c>([SELECT Id FROM pw_ccpro__CountryObject__c WHERE Name IN :EURO_DEALERS_COUNTRIES]).keySet();
  			}
  			return EURO_DEALERS_COUNTRIES_IDS;
  		}
  		set;
  	}
  	private static Boolean euroDealerGroupSelected = false;
  	private static Id EURO_DEALERS_GROUP_ID {
  		get {
  			if(EURO_DEALERS_GROUP_ID == null && !euroDealerGroupSelected) {
  				List<PBSI__Account_Group__c> lGroups = [SELECT Id FROM PBSI__Account_Group__c WHERE Name = 'Dealers - Euro'];
  				EURO_DEALERS_GROUP_ID = lGroups.isEmpty() ? null : lGroups[0].Id;
  				euroDealerGroupSelected = true;
  			}
  			return EURO_DEALERS_GROUP_ID;
  		}
  		set;
  	}

  	public static void validateEuroDealers(List<Account> lAccsNew) {
  		if(EURO_DEALERS_GROUP_ID != null) {
  			Set<Id> coveredRecordTypes = new Set<Id>();
  			coveredRecordTypes.add( RecordTypeService.getRecordTypeIdByDeveloperName('Account','Business_Customer') );
  			coveredRecordTypes.add( RecordTypeService.getRecordTypeIdByDeveloperName('Account','Dealer_Supplier') );

  			for(Account acc: lAccsNew) {
  				if( coveredRecordTypes.contains(acc.RecordTypeId) && EURO_DEALERS_COUNTRIES_IDS.contains(acc.pw_ccpro__BillingCountryLookup__c) && acc.PBSI__Account_Group__c != EURO_DEALERS_GROUP_ID ) {
  					acc.addError(Label.Euro_Dealers_Validation);
  				}
  			}
  		}
  	}
}