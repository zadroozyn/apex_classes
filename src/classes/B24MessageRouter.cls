public class B24MessageRouter implements Queueable, Database.AllowsCallouts {

	public class UnsupportedMessageTypeException extends Exception {}
	public class UnsupportedException extends Exception {}

	@testVisible private B24SObjectFactory sObjFactory;
	@testVisible private List<B24MessageWrapper.B24MessageModel> messages;
	@testVisible private B24Authorization authObj;
	@testVisible private List<B24SObjectCreatorBase.ParentChildren> lSalesOrdersToProcess;
	@testVisible private List<B24SObjectCreatorBase.ParentChildren> lSalesReportToProcess;
	@testVisible private List<B24SObjectCreatorBase.ParentChildren> lInventoryReportToProcess;
	@testVisible private String authObjSerial;
	
	public B24MessageRouter(B24MessageWrapper.B24MessageModel message, B24Authorization authObj) {
		this(new List<B24MessageWrapper.B24MessageModel> {message}, authObj);
	}

	public B24MessageRouter(List<B24MessageWrapper.B24MessageModel> messages, B24Authorization authObj) {
		sObjFactory = new B24SObjectFactory();
		this.messages = messages;
		this.authObj = authObj;
		this.authObjSerial = JSON.serialize(authObj);
	}

	public void execute(QueueableContext context) {
		System.debug('!!!### in router');
		LogService logSrv = LogService.getlogService();
		lSalesOrdersToProcess = new List<B24SObjectCreatorBase.ParentChildren>();
		lSalesReportToProcess = new List<B24SObjectCreatorBase.ParentChildren>();
		lInventoryReportToProcess = new List<B24SObjectCreatorBase.ParentChildren>();
		for(B24MessageWrapper.B24MessageModel message: messages) {
			try {
				if(message.isOrder()) {
					System.debug('!!!### is order');
					B24SObjectCreatorBase.ParentChildren soWithLines = sObjFactory.salesOrder(message.order, message.messageId);
					lSalesOrdersToProcess.add(soWithLines);
				} else if(message.isSalesReport()) {
					System.debug('!!!### is SLSRPT');
					B24SObjectCreatorBase.ParentChildren rptWithLines = sObjFactory.salesReport(message.slsrpt);
					lSalesReportToProcess.add(rptWithLines);
				} else if(message.isInventoryReport()) {
					System.debug('!!!### is INVRPT');
					B24SObjectCreatorBase.ParentChildren iptWithLines = sObjFactory.inventoryReport(message.invrpt);
					lInventoryReportToProcess.add(iptWithLines);
				} else {
					throw new UnsupportedMessageTypeException();
				}
			} catch(Exception e) {
				System.debug('!!!### B24MessageRouter exception');
				logSrv.addError().exception(e).type(B24MessageRouter.class.getName()).attachment('message.json', JSON.serialize(message));
				System.debug(e);
				reportDeliveryError(message.messageId, authObjSerial);
			}
		}
		processSalesOrders();
		processSalesReports();
		processInventoryReports();
		logSrv.save();
	}

	@future(callout=true)
	private static void reportDeliveryError(String msgId, String authObjSerialized) {
		B24Authorization authObj = (B24Authorization) JSON.deserialize(authObjSerialized, B24Authorization.class);
		new B24MessageSend(authObj).statusDeliveryError(msgId);
	}

	private void processSalesOrders() {
		if(!lSalesOrdersToProcess.isEmpty()) {
			B24SObjectWorker.Settings settings = new B24SObjectWorker.Settings();
			settings.relationOnParentToLock = 'PBSI__Customer__c';
			settings.lObjectsToProcess = lSalesOrdersToProcess;
			settings.authObjSerial = authObjSerial;
			settings.processDefinitionImplName = PartnerSalesOrder.class.getName();
			settings.b24IdField = 'B24_Message_Id__c';
			settings.errorLogAttName = 'soWithLines.json';
			settings.relNameToParent = 'PBSI__Sales_Order__r';
			B24SObjectWorker sow = new B24SObjectWorker(settings);
			sow.execute(null);
		}
	}

	private void processSalesReports() {
		if(!lSalesReportToProcess.isEmpty()) {
			B24SObjectWorker.Settings settings = new B24SObjectWorker.Settings();
			settings.relationOnParentToLock = 'Account__c';
			settings.lObjectsToProcess = lSalesReportToProcess;
			settings.authObjSerial = authObjSerial;
			settings.processDefinitionImplName = B24ConsignmentSLSRPTProcess.class.getName();
			settings.b24IdField = 'B24_Message_Id__c';
			settings.errorLogAttName = 'SLSRPT_WithLines.json';
			settings.relNameToParent = 'Sales_Report__c';
			B24SObjectWorker sow = new B24SObjectWorker(settings);
			sow.execute(null);
		}
	}

	private void processInventoryReports() {
		if(!lInventoryReportToProcess.isEmpty()) {
			B24SObjectWorker.Settings settings = new B24SObjectWorker.Settings();
			settings.relationOnParentToLock = 'Account__c';
			settings.lObjectsToProcess = lInventoryReportToProcess;
			settings.authObjSerial = authObjSerial;
			settings.processDefinitionImplName = B24ConsignmentINVRPTProcess.class.getName();
			settings.b24IdField = 'B24_Message_Id__c';
			settings.errorLogAttName = 'INVRPT_WithLines.json';
			settings.relNameToParent = 'Inventory_Report__c';
			B24SObjectWorker sow = new B24SObjectWorker(settings);
			sow.execute(null);
		}
	}

}