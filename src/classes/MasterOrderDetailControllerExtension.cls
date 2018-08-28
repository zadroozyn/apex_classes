public with sharing class MasterOrderDetailControllerExtension {

	private final Master_order__c record;
	public MasterOrderWrapper mOrder {get; set;}
	public Map<String, Map<Integer, Integer>> shoes {get; set;}
	public Map<String, Map<Integer, Integer>> apparel {get; set;}

	public MasterOrderDetailControllerExtension(ApexPages.StandardController stdController) {
		this.record =  (Master_order__c) stdController.getRecord();
		this.initWrappers();
		this.initGroupNumbers();
	}

	private void initWrappers() {
		List<PBSI__PBSI_Sales_order__c> sOrders = [SELECT Name,
					CreatedById,
					OwnerId,
					PBSI__Customer_Purchase_Order__c,
					Total_Shoes_Shipped__c,
					Total_Quantity_To_Ship__c,
					PBSI__Final_Order_Total__c,
					PBSI__Stage__c,
					CurrencyIsoCode,
					Sales_Order_Type__c, toLabel(PBSI__Status__c),
					PBSI__Customer__r.On_Payment_Term__c,
					PBSI__Customer__r.B2B_Account_s_Manager_Email__c,
					PBSI__Order_Date__c, PBSI__Due_Date__c,
					Delivery_Date__c, Tracking_Number_1__c,
					Tracking_Number_2__c, Tracking_Number_3__c,
					PBSI__Customer__r.Pre_Order_Discount__c,
					PBSI__Customer__r.PBSI__Standard_Discount__c,
					Total_Quantity_Of_Shoes_On_Order__c,
					PBSI__Order_Total__c,
					PBSI__Shipping_Cost__c,
					PBSI__Sales_Tax__c,
					Pre_Order_Final_Order_Total__c,
					PBSI__Customer__r.IsPersonAccount,
					PBSI__Customer__r.B2B_On_Payment_Terms__c,
					On_Payment_Term__r.Discount_Available__c,
					PBSI__Customer__r.Name,
					Pre_Order_Discount_override__c,
					Early_bird_discount__c,
					Visibility_discount__c,
					Show_discount_info__c,
					Proposal_status__c,
					RecordTypeId,
					VAT_Amount__c,
					Master_order__r.Id,
					Master_order__r.Name,
					(SELECT Id,
					 PBSI__Item__r.Name,
					 PBSI__ItemDescription__c,
					 PBSI__Quantity_Needed__c,
					 PBSI__Quantity_Picked__c,
					 PBSI__Quantity_Left_To_Ship__c,
					 PBSI__Price4__c,
					 PBSI__Total_Price__c,
					 PBSI__Item__r.PBSI__Item_Group__r.RecordTypeId,
					 PBSI__Item__r.Size__r.Type__c,
					 PBSI__Item__r.PBSI__Item_Group__r.Name
					 FROM PBSI__Sales_Order_Lines__r),
					(SELECT Id
					 FROM Attachments
					 ORDER BY CreatedDate DESC
					 LIMIT 1)
						FROM PBSI__PBSI_Sales_Order__c WHERE Master_order__c =: this.record.Id];
		mOrder = new MasterOrderWrapper([select id, recordtypeId, proposal_status__c, name, Status__c, Total_pre_order_discount__c, Early_bird_discount__c, Pre_order_discount__c, Visibility_discount__c from master_order__c where id =: this.record.Id], sOrders);
	}

	private void initGroupNumbers() {
		shoes = new Map<String, Map<Integer, Integer>>();
		apparel = new Map<String, Map<Integer, Integer>>();
		for(SalesOrderWrapper current : mOrder.orders) {
			for(OrderLineWrapper cLine : current.lines) {
				if(cLine.type == 0) {
					this.putIntoMap(shoes, cLine);
				} else {
					this.putIntoMap(apparel, cLine);
				}
			}
		}
	}

	private void putIntoMap(Map<String, Map<Integer, Integer>> m, OrderLineWrapper line) {
		if(!m.containsKey(line.itemGroupName)) {
			m.put(line.itemGroupName, new Map<Integer, Integer>());
			m.get(line.itemGroupName).put(0, 0);
			m.get(line.itemGroupName).put(1, 0);
			m.get(line.itemGroupName).put(2, 0);
		}
		m.get(line.itemGroupName).put(line.gender, Integer.valueOf(m.get(line.itemGroupName).get(line.gender)+line.quantityNeeded));
	}
}