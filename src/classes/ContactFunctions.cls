/**
 *   Batch class that holds values, and methods related to the function
 *   fields on Contact object.
 *   
 *   ver 1.0 2016-02-25 Dive Jakobusic
 * 
 *   Copyright (c) 2016 Nefos GmbH *
 */
public without sharing class ContactFunctions {
	
	public static String STORE_MANAGER = 'Store Manager';
	public static String DEPARTMENT_MANAGER = 'Department Manager';
	public static String SHOP_ASSISTANT = 'Shop Assistant';
	public static String BUYER = 'Buyer';
	public static String ACCOUNTING = 'Accounting';
	public static String B2B_PORTAL_USER  = 'B2B-Portal-User';
	public static String OWNER = 'Owner';
	
	
	/**
	 * Method composes value for the multi select picklist field: Function__c.  
	 * New value is a combination of old value that is stored in that field, 
	 * along with values that are stored in checkboxes.
	 * @param  contact Contact whose function has to be updated.
	 * @return         String - new value for the field.
	 */
	public String composeMultiSelectFunctionField(Contact contact){
		
		// parse current function
		Set<String> currentMultiSelectFunction =  String.isNotBlank(contact.Function__c) ? 
			new Set<String>(contact.Function__c.split(';')): new Set<String>();

		// load data to the function string
		String functionToSet =contact.Function__c;
		if (contact.Owner__c != null && contact.Owner__c && !currentMultiSelectFunction.contains(OWNER)){
			functionToSet = composeFunctionString(functionToSet, OWNER);
		}
		if (contact.Store_Manager__c != null && 
				contact.Store_Manager__c && !currentMultiSelectFunction.contains(STORE_MANAGER)){
			functionToSet = composeFunctionString(functionToSet, STORE_MANAGER);
		}
		if (contact.Department_Manager__c != null &&
				contact.Department_Manager__c && !currentMultiSelectFunction.contains(DEPARTMENT_MANAGER)){
			functionToSet = composeFunctionString(functionToSet, DEPARTMENT_MANAGER);
		}
		if (contact.Shop_Assistant__c != null && contact.Shop_Assistant__c && 
				!currentMultiSelectFunction.contains(SHOP_ASSISTANT)){
			functionToSet = composeFunctionString(functionToSet, SHOP_ASSISTANT);
		}
		if (contact.Buyer__c != null && contact.Buyer__c && !currentMultiSelectFunction.contains(BUYER)){
			functionToSet = composeFunctionString(functionToSet, BUYER);
		}
		if (contact.Accounting__c  != null && 
				contact.Accounting__c && !currentMultiSelectFunction.contains(ACCOUNTING)){
			functionToSet = composeFunctionString(functionToSet, ACCOUNTING);
		}

		return functionToSet;
	}


	private String composeFunctionString(String oldFunction, String newFunction){
		if (String.isNotEmpty(oldFunction)){
			return oldFunction + ( (oldFunction.endsWith(';')) ? newFunction: ';'+newFunction);
		}else{
			return newFunction;
		}
	}

}