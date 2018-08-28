/**
 * Batch job is used to update Number of styles on Sales Order level.
 *
 * @version 1.0  2015.02.18  Ewa Byra <ewa.byra@nefoscdc.com>.
 *                           Initial version of batch.
 */

global class CountSalesOrdersNumberOfStylesBatch implements Database.Batchable<sObject> {
    
    /**
     * It stores query
     */
    private String query;
    
    /**
     * Class's constructor.<br/>
     * It assigns query param to class's argument.
     * 
     * @param query value for query attribute.
     */
    global CountSalesOrdersNumberOfStylesBatch(String query) {
        this.query = query;
    }

    /**
     * Start batch job method.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /**
     * Execute batch job method.
     */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<ID> sSalesOrderIDs = new Set<ID>();

        for (sObject record : scope) {
            sSalesOrderIDs.add(record.ID);
        }

        SalesOrderMethods.updateNumberOfStyles(sSalesOrderIDs);
    }
    
    /**
     * Finish batch job method.
     */
    global void finish(Database.BatchableContext BC) {
        
    }
    
}