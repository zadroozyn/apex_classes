/**
 * Utility class contains methods for the object Error_Log__c.
 */
public with sharing class ErrorLogUtility {
	
	/**
	 * Creates instace of Error_Log__c object that has related 
	 * contact id. 
	 * @param  contactId    id of the related contact.
	 * @param  errorMessage error message
	 * @return              newly created record.
	 */
	public static Error_Log__c createContactErrorLog(Id contactId, List<Database.Error> errorMessages){
		Error_Log__c errorLog = new Error_Log__c();
		errorLog.Related_Contact__c = contactId;
		String errorMessage = '';
		for (Database.Error error: errorMessages){
			errorMessage += 'StatusCode = ' + error.getStatusCode() + '; Error message ='+ error.getMessage();
		}
		errorLog.Error_Message__c = errorMessage;
		return errorLog;
	} 
}