/**
 *   Batch class that updated functions on Contacts. Reads function chekboxes
 *   and transforms them into multiselect pick list.
 *   ver 1.0 2016-02-25 Dive Jakobusic
 * 
 *   Copyright (c) 2016 Nefos GmbH *
 */
global without sharing class UpdateContactsFunction implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id, Name, LastName, Owner__c, Accounting__c, Buyer__c, '+
   'Department_Manager__c, Function__c, Shop_Assistant__c, Store_Manager__c FROM Contact';
	
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contact> contacts) {

   		System.debug('Batch job execution' + BC.getJobId() + 'START');
         // save point has to be used to be able to rollback if 
         // if an error occurs during the insert of the Error_Log__c
         // records  (if they exist)
         Savepoint batchStart = Database.setSavepoint();

   		ContactFunctions cf = new ContactFunctions();
   		List<Contact> contactsToUpdate = new List<Contact>();
   		
         // create list of contacts for update
   		for (Contact c:contacts){
   			debugContact(c);
   			String newFunctionValue = cf.composeMultiSelectFunctionField(c);
   			if (c.function__c != newFunctionValue ){
   				System.debug('Setting new function value: '+ newFunctionValue);
   				c.function__c = newFunctionValue;
   				contactsToUpdate.add(c);
   			}
   		}

        // Update
         Database.SaveResult[] saveResults = Database.update(contactsToUpdate, false);
         processErrors(batchStart, saveResults, contactsToUpdate);
         System.debug('Batch job execution' + BC.getJobId() + 'END');
	}
	
   private void debugContact (Contact c){
      System.debug('Processing contact: ' + c.LastName + ' Function: '+ c.Function__c +
               ' Accounting__c ' + c.Accounting__c + 'Buyer__c '+ c.Buyer__c + 
               ' Department_manager__c ' + c.Department_Manager__c + ' Shop_assistant__c ' + c.Shop_Assistant__c + 
               ' Store_manager__c' + c.Store_Manager__c  + ' Owner ' + c.Owner__c);

   }

   @TestVisible
   private void processErrors( System.Savepoint batchStart,  List<Database.SaveResult> saveResults, List<Contact> contacts){
      if (saveResults == null ){
         return;
      }
      List<Error_Log__c> errorLogs = new List<Error_Log__c>();

      for (Integer i =0; i<saveResults.size(); i++){
         //SaveResult doesn't have an id if update wasn't successful;
         //The order of SaveResults matched the order of the list that was updated
            Database.SaveResult saveResult= saveResults.get(i);
           
            if(!saveResult.isSuccess()){
               errorLogs.add(ErrorLogUtility.createContactErrorLog((contacts.get(i)).id, saveResult.getErrors()));
               System.debug('ErrorLog created for record: '+ (contacts.get(i)).id + ' errors '+ saveResult.getErrors());
            }
         }
         System.debug('Error log size ' + errorLogs.size());
         if (!errorLogs.isEmpty()){
            System.debug('Inserting errorLogs: size '+ errorLogs.size());
            try{
               insert errorLogs;
            }catch(DmlException e) {
               // rollback all contacts that have been sucessfuly upodated
               Database.rollback(batchStart);
               throw new ContactFunctionUpdateException('DML Exception occured while inserting errorLogs for contacts' 
                  +contacts, e);
            }
         }
   }

	global void finish(Database.BatchableContext BC) {}
	
}