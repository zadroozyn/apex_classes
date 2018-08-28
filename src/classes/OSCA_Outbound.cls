global class OSCA_Outbound implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	private String stagingsQuery;
	private String sObjsQuery;
	private Set<Id> sObjsIds = new Set<Id>();
	private OscaMessageSend oscaMsgSendService;
	private Queue objectInfosQueue;
	private ObjectInfo currentObjectType;
	private Boolean selfRestart;
	private List<SObject> lSObjects;
	private Boolean loginCredentialsValid;
	
	global class AuthorizationException extends Exception {}
	global class UnsupportedObjectException extends Exception {}

	global OSCA_Outbound() {
		objectInfosQueue = defaultQueue();
		prepareData();
	}

	@testVisible
	private OSCA_Outbound(String objectInfosQueueSerialized) {
		this.objectInfosQueue = (Queue) JSON.deserialize(objectInfosQueueSerialized, Queue.class);
		prepareData();
	}

	private void prepareData() {
		loginCredentialsValid = true;
		selfRestart = false;
		currentObjectType = objectInfosQueue.dequeue();

		stagingsQuery = 'SELECT Id,Object_Id__c FROM OSCA_staging__c WHERE '
			+ ' RecordTypeId = \'' + RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'Update_Object') + '\''
			+ ' AND Object_Type__c = \'' + currentObjectType.sObjTypeName + '\' ORDER BY CreatedDate ASC';

		sObjsQuery = 'SELECT Id,' + String.join(currentObjectType.fields, ',') + ' FROM ' + currentObjectType.sObjTypeName + ' WHERE Id IN :sObjsIds';
	}

	private void verifyAuthInfo() {
		oscaMsgSendService = new OscaMessageSend();
		try {
			OscaMessageSend.OscaResponse response = oscaMsgSendService.sendMessage('account','xxx');
		} catch(OscaMessageSend.UnauthorizedException e) {
			throw new AuthorizationException('Login credentials invalid');
		} catch(OscaMessageSend.ResponseException e) {
			//silent, bad request only to confirm auth info
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		LogService logSrv = LogService.getLogService();
		try {
			verifyAuthInfo();
		} catch(AuthorizationException e) {
			logSrv.addError().exception(e).type('OSCA_Outbound_Login');
			loginCredentialsValid = false;
		}
		logSrv.save();
		return Database.getQueryLocator(stagingsQuery + (loginCredentialsValid ? '' : ' LIMIT 0'));
	}

	global void execute(Database.BatchableContext BC, List<OSCA_staging__c> scope) {
   		LogService logSrv = LogService.getLogService();
   		try {
   			lSObjects = getScopeSObjects(scope);

			String sObjectsSerialized = JSON.serialize(lSObjects);

			OscaMessageSend.OscaResponse response;
			try {
				response = oscaMsgSendService.sendMessage(currentObjectType.urlEndpoint, sObjectsSerialized);
			} catch(OscaMessageSend.MissingDependeciesException e) {
				logSrv.addError().type('OSCA_Outbound_MissingDependecies').exception(e);
				//silent
			}
			saveOscaResults(response, lSObjects);
			logSrv.addDebug()
				.type('OSCA_Outbound_Debug')
				.attachment('request_'+currentObjectType.sObjTypeName+'.json', sObjectsSerialized);
			delete scope;
   		} catch(Exception e) {
   			logSrv.addError().exception(e).type('OSCA_Outbound_Execute');
   		}
		logSrv.save();

	}

	webservice static void executeSingleStaging(Id stagingObjId) {	
		OSCA_staging__c stagingObj = [SELECT Id,Object_Type__c,Object_Id__c FROM OSCA_staging__c WHERE Id =:stagingObjId];
		ObjectInfo objInfo;
		Queue allObjects = defaultQueue();
		while(!allObjects.isEmpty()) {
			ObjectInfo tmp = allObjects.dequeue();
			if(tmp.sObjTypeName.equalsIgnoreCase(stagingObj.Object_Type__c)) {
				objInfo = tmp;
				break;
			}
		}
		if(objInfo != null) {
			OSCA_Outbound outboundBatch = new OSCA_Outbound();
			outboundBatch.currentObjectType = objInfo;
			outboundBatch.verifyAuthInfo();
			outboundBatch.execute(null, new List<OSCA_staging__c>{stagingObj});
		} else {
			throw new UnsupportedObjectException('This Object is not supported: '+stagingObj.Object_Type__c);
		}
		
	}

	private List<sObject> getScopeSObjects(List<OSCA_staging__c> scope) {
		sObjsIds = new Set<Id>();
		for(OSCA_staging__c stagingObj: scope) {
			sObjsIds.add(stagingObj.Object_Id__c);
		}
		return Database.query(sObjsQuery);
	}

	private void saveOscaResults(OscaMessageSend.OscaResponse response, List<sObject> lScopeSObjects) {
		LogService logSrv = LogService.getLogService();
		Map<Id, SObject> mapSObjects = new Map<Id, SObject>(lSObjects);
		List<SObject> lSuccess = new List<SObject>();
		for(OscaMessageSend.OscaLineResponse line: response.successes) {
			SObject sObj = mapSObjects.get((Id)line.objId);
			if(sObj.get('Osca_integration__c') != true) {
				SObject sObjTmp = Schema.getGlobalDescribe().get(currentObjectType.sObjTypeName).newSObject();

				sObjTmp.Id = line.objId;
				sObjTmp.put('Osca_integration__c', true);
				lSuccess.add(sObjTmp);
			}
		}
		for(OscaMessageSend.OscaLineResponse line: response.failures) {
			logSrv.addError().relatedObjId(line.objId).info(line.cause).type('OSCA_Outbound_Result');
		}
		try {
			update lSuccess;		
		} catch(Exception e) {
			logSrv.addError().exception(e).type('OSCA_Outbound_SaveResults');
		}
		logSrv.save();

	}

	global void restart(Boolean selfRestart) {
		this.selfRestart = selfRestart;
	}

	global void finish(Database.BatchableContext BC) {
		//if(loginCredentialsValid) {
			if(!objectInfosQueue.isEmpty()) {
				System.debug('OSCA_Outbound I have more objects to go');
				OSCA_Outbound nextBatch = new OSCA_Outbound(JSON.serialize(objectInfosQueue));
				executeNextBatch(nextBatch, nextBatch.getCurrentBatchSize());
			} else {
				System.debug('OSCA_Outbound I will try to run scheduler');
				OSCA_CreateStagingsNewPOs nextBatch = new OSCA_CreateStagingsNewPOs();
				nextBatch.executeOSCAOutbound(true);
				executeNextBatch(nextBatch, OSCA_CreateStagingsNewPOs.DEFAULT_BATCH_SIZE);
			}
		//}
	}

	private void executeNextBatch(Database.Batchable<SObject> nextBatch, Integer batchSize) {
		if(!Test.isRunningTest()) {
			Database.executeBatch(nextBatch, batchSize);
		}
	}

	public Integer getCurrentBatchSize() {
		return currentObjectType.batchSize;
	}

	@testVisible
	private class ObjectInfo {
		public String sObjTypeName;
		public List<String> fields;
		public String urlEndpoint;
		public Integer batchSize;

		public ObjectInfo sObjTypeName(String sObjTypeName) {
			this.sObjTypeName = sObjTypeName;
			return this;
		}

		public ObjectInfo fields(List<String> fields) {
			this.fields = fields;
			return this;
		}

		public ObjectInfo urlEndpoint(String urlEndpoint) {
			this.urlEndpoint = urlEndpoint;
			return this;
		}

		public ObjectInfo batchSize(Integer batchSize) {
			this.batchSize = batchSize;
			return this;
		}
	}

	private static Queue defaultQueue() {
		return new Queue()
			.enqueue(
				new ObjectInfo()
					.sObjTypeName('Account')
					.fields(OSCA_OutboundFields.ACCOUNT_SOQL)
					.urlEndpoint('account')
					.batchSize(50)
			)
			.enqueue(
				new ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Location__c')
					.fields(OSCA_OutboundFields.LOCATION_SOQL)
					.urlEndpoint('location')
					.batchSize(50)
			)
			.enqueue(
				new ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Item__c')
					.fields(OSCA_OutboundFields.ITEM_SOQL)
					.urlEndpoint('item')
					.batchSize(50)
			)
			.enqueue(
				new ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Purchase_Order__c')
					.fields(OSCA_OutboundFields.PO_SOQL)
					.urlEndpoint('po')
					.batchSize(50)
			)
			.enqueue(
				new ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Purchase_Order_Line__c')
					.fields(OSCA_OutboundFields.PO_LINE_SOQL)
					.urlEndpoint('poline')
					.batchSize(50)
			);

	}

	public class EmptyQueueException extends Exception {}

	@testVisible
	private class Queue {

		private List<ObjectInfo> elements;
		
		public Queue() {
			elements = new List<ObjectInfo>();
		}

		public Queue(List<ObjectInfo> objList) {
			this();
			for(ObjectInfo obj: objList) {
				enqueue(obj);
			}
		}	

		public Queue enqueue(ObjectInfo obj) {
			elements.add(obj);
			return this;
		}

		public ObjectInfo dequeue() {
			if(!elements.isEmpty()) {
				return elements.remove(0);
			} else {
				throw new EmptyQueueException();
			}
		}

		public Boolean isEmpty() {
			return elements.isEmpty();
		}
	}
	
}