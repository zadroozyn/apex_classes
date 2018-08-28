public with sharing class RunBatchATP 
{
	PBSI__Admin__c admin=PBSI__Admin__c.getorgdefaults();  
    public void syncbatchobject()  
    {
    	integer scope=100;
    	if (admin!=null && admin.Batch_Scope__c!=null)	scope = integer.Valueof(admin.Batch_Scope__c);
        Database.executeBatch(new BatchATPObject(),scope);  
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You will receive an email when ATP is updated!'));	
    }
    public void syncbatchobjectav() 
    {
    	integer scope=100;
    	if (admin!=null && admin.Batch_Scope__c!=null)	scope = integer.Valueof(admin.Batch_Scope__c);
        Database.executeBatch(new BatchATPObjectAvailability(),scope);  
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You will receive an email when ATP is updated!'));	
    }
}