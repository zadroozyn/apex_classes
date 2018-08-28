/**
 * The Apex batch job class that is using to assign default values to Account records.
 * 
 * @version 1.0  2014.09.27 Ewa Byra (ewa.byra@nefoscdc.com).
 *                          Initial version of class.
 */

global class AccountDataUpdation implements Database.Batchable<sObject> {
   
   /**
    * Account query stored as String. It is using to query account record to processing.<br>
    * This parameter is constant.
    */
   global final String QUERY;
   
   /**
    * Class's constructor that is using to assing given query to QUERY class parameter.<br>
    * It invokes class's constructor with String parameter.
    */
   global AccountDataUpdation() {
       this('SELECT ' + String.join(new List<String>(AccountMethods.getAccountFieldAPINamesToAssignDefaultValues()),', ') + ' FROM Account');
   }

   /**
    * Class's constructor that is using to assing given query to QUERY class parameter.
    * 
    * @param query Account query stored as String that is assigning to QUERY class parameter.
    */
   global AccountDataUpdation(String query) {
       this.QUERY = query;
   }
   
   /**
    * The method is used to query account records that are going to be processed by the batch job.
    * 
    * @param context The Batch context.
    */
   global Database.QueryLocator start(Database.BatchableContext context) {
      return Database.getQueryLocator(this.QUERY);
   }

   /**
    * The method is used to processing Account records.<br>
    * It invokes AccountMethods.assignDefaultValues(List<Account>) method to assing account values.
    * 
    * @param context  The Batch context.
    * @param scope    Account records that are going to be processing.
    */
   global void execute(Database.BatchableContext context, List<sObject> scope) {
      System.debug(LoggingLevel.INFO, '****************** scope: ' + scope);
      AccountMethods.assignDefaultValues((List<Account>) scope, true);
   }

   /**
    * The method is used at the end when all account records were processed by the batch job.<br>
    * This method do nothing.
    * 
    * @param context The Batch context.
    */
   global void finish(Database.BatchableContext context) {

   }

}