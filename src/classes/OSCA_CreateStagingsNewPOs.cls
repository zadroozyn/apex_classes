global class OSCA_CreateStagingsNewPOs implements Database.Batchable<sObject>, Database.Stateful {

	public static final Integer DEFAULT_BATCH_SIZE = 1000; //PO lines

	static String poSOQL = 'SELECT Id, PBSI__Account__r.Osca_Integration__c, PBSI__Account__r.Id FROM PBSI__PBSI_Purchase_Order__c WHERE Id = :currentPOId';

	static String poLinesSOQL = 'SELECT Id, PBSI__Item__r.Osca_Integration__c, PBSI__Item__r.Id, PBSI__Location__r.Osca_Integration__c, PBSI__Location__r.Id '+
		' FROM PBSI__PBSI_Purchase_Order_Line__c WHERE PBSI__Purchase_Order__c = :currentPOId';

	static String staginsSOQL = 'SELECT Id, Object_Id__c, RecordType.Name FROM OSCA_staging__c '+
		' WHERE RecordTypeId = :newPOStagingId ORDER BY CreatedDate ASC LIMIT ';

	private Boolean executeWholeChain;
	private Queue.SObj poStagingQueue;
	private static Id newPOStagingId;
	private Id currentPOId;
	private List<OSCA_staging__c> lStagingObjs;
	private OSCA_staging__c currentStaging;

	global OSCA_CreateStagingsNewPOs() {
		this(5); //number of max po processed
	}

	@testVisible
	private static Queue.SObj getFullQueue(Integer poLimit) {
		newPOStagingId = RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO');
		List<OSCA_staging__c> lStagingObjs = Database.query(staginsSOQL + String.valueOf(poLimit));
		System.debug(lStagingObjs);
		return new Queue.SObj(lStagingObjs);
	}

	global OSCA_CreateStagingsNewPOs(Integer poLimit) {
		this.poStagingQueue = getFullQueue(poLimit);
		executeWholeChain = false;
	}

	public void executeOSCAOutbound(Boolean outbound) {
		executeWholeChain = outbound;
	}

	global OSCA_CreateStagingsNewPOs(String poQueueSerialized) {
		this.poStagingQueue = (Queue.SObj) JSON.deserialize(poQueueSerialized, Queue.SObj.class);
		executeWholeChain = false;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator ql;
		if(!poStagingQueue.isEmpty()) {
			currentStaging = (OSCA_staging__c) poStagingQueue.dequeue();
			currentPOId = currentStaging.Object_Id__c;
			currentStaging.Processing__c = true;
			update currentStaging;
			PBSI__PBSI_Purchase_Order__c po = Database.query(poSOQL);
			OSCA_StagingService stagingService = new OSCA_StagingService();
			if(po.PBSI__Account__r != null && (!po.PBSI__Account__r.Osca_Integration__c)) {
				stagingService.updateStagingObject(po.PBSI__Account__r);
				
			}
			stagingService.updateStagingObject(po);
			stagingService.insertStagingObjects();
			ql = Database.getQueryLocator(poLinesSOQL);
		} else {
			ql = Database.getQueryLocator('select id from PBSI__PBSI_Purchase_Order_Line__c limit 0');
		}

		return ql;
	}

   	global void execute(Database.BatchableContext BC, List<PBSI__PBSI_Purchase_Order_Line__c> scope) {
		OSCA_StagingService stagingService = new OSCA_StagingService();

		for(PBSI__PBSI_Purchase_Order_Line__c orderLine: scope) {

			stagingService.updateStagingObject(orderLine);

			if(!orderLine.PBSI__Location__r.Osca_Integration__c) {
				stagingService.updateStagingObject(orderLine.PBSI__Location__r);
			}

			if(!orderLine.PBSI__Item__r.Osca_Integration__c) {
				stagingService.updateStagingObject(orderLine.PBSI__Item__r);
			}

		}

		stagingService.insertStagingObjects();
	}
	
	global void finish(Database.BatchableContext BC) {
		if(currentStaging != null) {
			delete currentStaging;
		}
		if(!poStagingQueue.isEmpty()) {
			OSCA_CreateStagingsNewPOs nextPoBatch = new OSCA_CreateStagingsNewPOs(JSON.serialize(poStagingQueue));
			nextPoBatch.executeOSCAOutbound(executeWholeChain);
			executeNextBatch(nextPoBatch, DEFAULT_BATCH_SIZE);
		} else if(executeWholeChain) {
			OSCA_Outbound oscaBatch = new OSCA_Outbound();
			//TODO set to true when batch should cycle
			oscaBatch.restart(true);
			executeNextBatch(oscaBatch, oscaBatch.getCurrentBatchSize());
		}

	}

	private static void executeNextBatch(Database.Batchable<SObject> nextBatch, Integer batchSize) {
		if(!Test.isRunningTest()) {
			Database.executeBatch(nextBatch, batchSize);
		}
	}
	
}