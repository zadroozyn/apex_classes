global without sharing class WarrantyCaseWebService {

	final private static WarrantyReasonConverter REASON_CONVERTER = new WarrantyReasonConverter();
	private Case source;
	private PBSI__PBSI_Sales_Order__c order;
	private List<Warranty_Line__c> sourceLines;
	private List<PBSI__PBSI_Sales_Order_Line__c> orderLines;

	webservice static String approveAndGenerateOrder(Id sourceId) {
		WarrantyCaseWebService instance = new WarrantyCaseWebService(sourceId);
		instance.convert();
		instance.save();
		instance.pack();
		return instance.order.Id;
	}

	private WarrantyCaseWebService(Id sourceId) {
		System.assertNotEquals(null, sourceId,  'You need to provide valid id of a case for this constructor.');
		System.assertEquals(Schema.Case.SObjectType, sourceId.getSObjectType(), 'You need to provide valid id of a case for this constructor.');
		this.source = getCase(sourceId);
		this.order = new PBSI__PBSI_Sales_Order__c();
		this.sourceLines = this.source.Warranty_Lines__r;
		this.orderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
	}

	private void convert() {
		createOrder();
		createLines();
	}

	private void save() {
		List<sObject> insertList = new List<sObject>();
		List<sObject> updateList = new List<sObject>();
		updateList.add(new Case(Id = this.source.Id, Status = 'Closed'));
		for(Warranty_Line__c current : this.sourceLines) {
			updateList.add(new Warranty_Line__c(Id = current.Id, Status__c = 'Approved'));
		}
		update updateList;
		insert this.orderLines;
	}

	private void pack() {
		SalesOrderPacker packer = new SalesOrderPacker(this.order);
		try {
			packer.pack();
		} catch (Exception e) {
		}
	}

	private void createOrder() {
		this.order.Sales_Order_Type__c = 'Warranty';
		this.order.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Sales_order');
		this.order.PBSI__Customer__c = this.source.AccountId;
		this.order.PBSI__Contact__c = this.source.CreatedBy.ContactId;
		this.order.PBSI__Stage__c='open';
		this.order.PBSI__Status__c='open';
		this.order.PBSI__Order_Date__c = Date.today();
		this.order.From_Warranty_Case__c = this.source.Id;
		insert this.order;
	}

	private Case getCase(Id sourceId) {
		return [SELECT Id, AccountId, CreatedBy.ContactId, (SELECT Id, Item__c, New_Item__c, Status__c, Defect_reason__c, RecordType.DeveloperName FROM Warranty_Lines__r WHERE Status__c = 'Approved' OR Status__c = 'Submitted') FROM Case WHERE Id =: sourceId];
	}

	private void createLines(){
		for(Warranty_Line__c current : this.sourceLines) {
			PBSI__PBSI_Sales_Order_Line__c temp = new PBSI__PBSI_Sales_Order_Line__c();
			temp.PBSI__Sales_Order__c = this.order.Id;
			temp.PBSI__Item__c = (current.New_Item__c == null) ? current.Item__c : current.New_Item__c;
			temp.PBSI__Quantity_Needed__c = 1;
			temp.PBSI__Price__c = 0;
			temp.PBSI__Price4__c = 0;
			if(current.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Warranty_Line__c', 'Apparel')) {
				temp.Warranty_reason_shoes__c = REASON_CONVERTER.getReason(current.Defect_Reason__c);
			} else {
				temp.Return_Reason__c = REASON_CONVERTER.getReason(current.Defect_Reason__c);
			}
			this.orderLines.add(temp);
		}
	}

	private Class WarrantyReasonConverter {
		final private Map<String, String> reasons;

		private WarrantyReasonConverter() {
			reasons = new Map<String, String>();
			populate();
		}

		private void populate() {
			for(Schema.PicklistEntry current : Schema.Warranty_Line__c.fields.Defect_reason__c.getDescribe().getPicklistValues()) {
				reasons.put(current.getValue(), null);
			}
			List<Schema.PicklistEntry> wReasons = new List<Schema.PicklistEntry>();
			wReasons.addAll(Schema.PBSI__PBSI_Sales_Order_Line__c.fields.Warranty_reason_shoes__c.getDescribe().getPicklistValues());
			wReasons.addAll(Schema.PBSI__PBSI_Sales_Order_Line__c.fields.Return_Reason__c.getDescribe().getPicklistValues());
			for(Schema.PicklistEntry current : wReasons) {
				String cValue = current.getValue();
				String cCode = current.getValue().split(' ')[0];
				if(reasons.keySet().contains(cValue)) {
					reasons.put(cValue, cValue);
				} else if (reasons.keySet().contains(cCode)) {
					reasons.put(cCode, cValue);
				}
			}
		}

		private String getReason(String code) {
			return reasons.get(code);
		}
	}
}