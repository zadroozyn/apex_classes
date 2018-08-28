global class CongaFileGeneratorBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

	private Set<Id> sObjectIds;
	private Schema.sObjectType type;
	private String sessionId;
	global Set<Id> processedOrders;
	private Conga_login__c loginInfo;

	global CongaFileGeneratorBatch () {}

	global CongaFileGeneratorBatch (Set<Id> sObjectsIds, Schema.sObjectType type, String sessionId){
		this.sObjectIds = sObjectsIds;
		this.type = type;
		this.sessionId = sessionId;
		processedOrders = new Set<Id>();
		loginInfo = Conga_login__c.getInstance('Conga');
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String s = buildQuery(type);
		return Database.getQueryLocator(buildQuery(type));
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		if(scope.size() > 1) {
			return;
		}
		if(loginInfo != null) {
			sessionId = CustomApexLogin.getSessionId();
		}
		if(isAttachmentNeeded(scope[0])) {
			generateAttachment(scope[0]);
			processedOrders.add(scope[0].Id);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	@testVisible
	private String buildQuery(Schema.sObjectType objectType) {
		if(objectType == getObjectType('PBSI__PBSI_Sales_Order__c')){
			return buildQuerySalesOrder();
		}
		return null;
	}

	private String buildQuerySalesOrder() {
		return 'SELECT Id, Conga_Order_Confirmation_Link__c, (SELECT ID FROM Attachments) FROM PBSI__PBSI_Sales_Order__c WHERE Id IN : sObjectIds AND Id NOT IN : processedOrders';
	}

	@testVisible
	private String generateAttachment(sObject obj) {
		if(obj.getSObjectType() == getObjectType('PBSI__PBSI_Sales_Order__c')){
			PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c) obj;
			return SalesOrderMethods.generateOrderConfirmation(order, this.sessionId);
		}
		return null;
	}

	@testVisible
	private boolean isAttachmentNeeded(sObject obj) {
		if(obj.getSObjectType() == getObjectType('PBSI__PBSI_Sales_Order__c')){
			PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c) obj;
			return order.Attachments.size() == 0;
		}
		return false;

	}

	private Schema.sObjectType getObjectType(String objName) {
		return Schema.getGlobalDescribe().get(objName);
	}
}