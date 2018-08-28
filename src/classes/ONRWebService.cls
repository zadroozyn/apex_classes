global class ONRWebService{

	public static final String FULFILLER_KN = 'KN';

	public class NotifyFulfillerException extends Exception {}

	WebService static String notifyFulfillerService(String orderId) {
		Map<String, Map<Id, String>> result = notifyFulfiller(orderId);
		if(result.containsKey('done')) {
			setFulfillerInProgess(orderId);
		}
		return JSON.serialize(result);
	}

	WebService static void shippingNotificationWeb(String orderId) {
		PBSI__PBSI_Sales_Order__c order = [SELECT Id, Shipping_Confirmation_Invoice_Email_ID__c, PBSI__Contact__c FROM PBSI__PBSI_Sales_Order__c WHERE Id =: orderId];
		shippingNotificationWeb(order);
	}

	public static void shippingNotificationWeb(PBSI__PBSI_Sales_Order__c order) {
		ShippingConfirmationManager rManager = new ShippingConfirmationManager(order.Id, new CongaMsgBuilder(order, UserInfo.getSessionId()).getShippingEmailBuilder());
		rManager.enqueue();
	}

	@future
	WebService static void shippingNotificationWebFuture(String orderId) {
		shippingNotificationWeb(orderId);
	}

	WebService static void packAllLineItems(String orderId) {
		ONRWebService.packAllLineItemsImpl(orderId);
	}

	WebService static void UpdateAllLineItemsEstimatedShipDate(String orderId) {
		ONRWebService.UpdateAllLineItemsEstimatedShipDateImpl(orderId);
	}

	public static Map<String, Map<Id, String>> notifyFulfiller(Id orderId){
		return autoNotifyBulk(new Set<Id> {orderId});
	}

	public static void packAllLineItemsImpl(String orderId) {
		List<PBSI__PBSI_Sales_Order_Line__c> lineItems =  [SELECT Id, Name, PBSI__Total_Price__c, VAT_Amount__c, PBSI__Total_Price4__c, CurrencyIsoCode, PBSI__Item__r.Name, PBSI__Item__r.PBSI__Available_to_Promise__c, PBSI__Quantity_Needed__c, PBSI__Price__c, PBSI__ItemDescription__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c = :orderId];

		for (PBSI__PBSI_Sales_Order_Line__c line: lineItems) {
			//line.PBSI__Quantity_Picked__c = line.PBSI__Quantity_Needed__c;
		}
		update lineItems;
	}

	public static void UpdateAllLineItemsEstimatedShipDateImpl(String orderId) {
		PBSI__PBSI_Sales_Order__c parentSO = [select Id, Name, PBSI__Due_Date__c from PBSI__PBSI_Sales_Order__c where id =: orderId];
		List<PBSI__PBSI_Sales_Order_Line__c> allLineItems = [SELECT Id, Name, PBSI__Estimated_Ship_Date__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c =: orderId];
		List<PBSI__PBSI_Sales_Order_Line__c> updLineItems = new List<PBSI__PBSI_Sales_Order_Line__c>();

		for (PBSI__PBSI_Sales_Order_Line__c lineItem : allLineItems) {
			if (parentSO.PBSI__Due_Date__c != null && parentSO.PBSI__Due_Date__c != lineItem.PBSI__Estimated_Ship_Date__c) {
				lineItem.PBSI__Estimated_Ship_Date__c = parentSO.PBSI__Due_Date__c;
				updLineItems.add(lineItem);
			}
		}

		if (updLineItems.size() > 0) {
			update updLineItems;
		}
	}

    // Ascent WebService method called from the SO header "Update Pricing" button
    WebService static void RecalculateTradeAgreementPricing(String orderId) {
    	ONRWebService.RecalculateTradeAgreementPricingImpl(orderId);
    }
    
    public static void RecalculateTradeAgreementPricingImpl(String orderId) {
    	
    	Map<Id, PBSI__PBSI_Sales_Order_Line__c> linesMap = new Map<Id, PBSI__PBSI_Sales_Order_Line__c> (
    		[SELECT Id, PBSI__Sales_Order__c, PBSI__Item__c, PBSI__Discount__c, PBSI__Disable_Sales_Trade_Agreement__c, 
    			PBSI__Quantity_Needed__c, PBSI__hasInstructions__c, PBSI__SOAccount__c, PBSI__SOAccountGr__c, 
    			PBSI__Item_Group__c, PBSI__Unit_of_Measure__c, PBSI__Price_Type__c, PBSI__Sales_Order_Ship_Date__c, 
    			CurrencyIsoCode, PBSI__Trade_Agreement__c, PBSI__Price4__c, Sales_Order_Type__c
			FROM PBSI__PBSI_Sales_Order_Line__c 
			WHERE pbsi__sales_order__c =: orderId]);
    	
    	Set<Id> invoicedSoLines = new set<Id>();
        for (PBSI__Invoiced_Line__c i : 
        	[SELECT Id, PBSI__Sales_Order_Line__c, PBSI__Shipped_Sales_Order_Line__r.PBSI__Sales_Order_Line__c
        	FROM PBSI__Invoiced_Line__c 
        	WHERE PBSI__Sales_Order_Line__c IN : linesMap.keySet()
        	OR PBSI__Shipped_Sales_Order_Line__r.PBSI__Sales_Order_Line__c IN : linesMap.keySet()]) {
        		
        	if (i.PBSI__Sales_Order_Line__c != null)
				invoicedsolines.add(i.PBSI__Sales_Order_Line__c); 
			else
				invoicedsolines.add(i.PBSI__Shipped_Sales_Order_Line__r.PBSI__Sales_Order_Line__c);
        }
        
        list<PBSI__PBSI_Sales_Order_Line__c> linesToRecalculate=new list<PBSI__PBSI_Sales_Order_Line__c>();   
    	for (PBSI__PBSI_Sales_Order_Line__c s : linesMap.values()) {
			if (!invoicedsolines.contains(s.Id))
				linesToRecalculate.add(s);
    	}
        	 
    	UpdateSODetails.calculateTradeLine(linesToRecalculate,null,null);
    	update linesToRecalculate;
    }
    
	webservice static void AutoPackBulk(String soidStr) {
		List<String> soidList = soidStr.split(';');

		BulkPackSalesOrders bpso = new BulkPackSalesOrders(soidList);
		bpso.BulkPack();
	}

	webservice static String webAutoNotifyBulk(String input) {
		return JSON.Serialize(autoNotifyBulk((Set<Id>) JSON.deserialize(input, Set<Id>.class)));
	}

	webservice static String webAutoNotifySync(String input) {
		return JSON.Serialize(autoNotifySync((Set<Id>) JSON.deserialize(input, Set<Id>.class)));
	}

	public static Map<String, Map<Id, String>> autoNotifySync(Set<Id> oIds) {
		List<Order_stage__c> newStages = new List<Order_stage__c>();
		Map<String, Map<Id, String>> output;
		output = getOrderForNotification(oIds);
		if(output.containsKey('done')) {
			Id notificationSORecordType = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_SO');
			for(Id currentId : output.get('done').keySet()) {
				newStages.add(new Order_Stage__c(Sales_order__c = currentId, RecordtypeId = notificationSORecordType));
			}
		}
		insert newStages;
		for(Id currentId : new Map<Id, Order_Stage__c>(newStages).keySet()) {
			System.enqueueJob(new WebOrderNotifier(currentId));
		}
		return output;
	}

	public static Map<String, Map<Id, String>> autoNotifyBulk(Set<Id> orderIds) {
		Map<String, Map<Id, String>> output;
		List<Order_stage__c> newStages = new List<Order_stage__c>();
		try {
			output = getOrderForNotification(orderIds);
			Id notificationSORecordType = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_SO');
			for(Id currentId : output.get('done').keySet()) {
				newStages.add(new Order_Stage__c(Sales_order__c = currentId, RecordtypeId = notificationSORecordType));
			}
			insert newStages;
		} catch (Exception e) {
			LogService log = LogService.getLogService();
			log.addError().type('MASS_NOTIF').exception(e).createActivity();
			log.save();
			output.put('Error', new Map<Id, String> {null => e.getMessage()});
		} finally {
			if(output.containsKey('done') && !output.containsKey('Error')) {
				Database.executeBatch(new InitiateWarehouseNotificationBatch(new Map<Id, Order_Stage__c>(newStages).keySet()), 200);
			}
		}
		return output;
	}

	private static Map<String, Map<Id, String>> getOrderForNotification(Set<Id> orderIds) {
		Map<String, Map<Id, String>> output = new Map<String, Map<Id, String>>();
		List<PBSI__PBSI_Sales_Order__c> orders = [SELECT Id, Name, CreatedDate, Notified_Fulfiller__c, (SELECT Id, Stage__c FROM Order_stages__r WHERE Stage__c IN ('Scheduled', 'Processing')), (SELECT Id FROM PBSI__R00N60000001ZR62EAG__r WHERE Shipment_status__c = 'New')
			FROM PBSI__PBSI_Sales_Order__c
			WHERE Id IN : orderIds];
		for(PBSI__PBSI_Sales_Order__c current : orders) {
			if(current.Order_stages__r.size() != 0) {
				if(!output.containsKey('inprogress')) {
					output.put('inprogress', new Map<Id, String>());
				}
				output.get('inprogress').put(current.Id, current.Name);
			} else if(current.PBSI__R00N60000001ZR62EAG__r.size() == 0
					|| (current.Notified_Fulfiller__c && current.CreatedDate < Date.newInstance(2018, 3, 20)/* Date of deployment, used so we don't need to update all lines in the system */)) {
				if(!output.containsKey('nolines')) {
					output.put('nolines', new Map<Id, String>());
				}
				output.get('nolines').put(current.Id, current.Name);
			} else {
				if(!output.containsKey('done')) {
					output.put('done', new Map<Id, String>());
				}
				output.get('done').put(current.Id, current.Name);
			}
		}
		return output;
	}

    webservice static String notifyFulfillerTransferOrder(Id toId) {
    	LogService logSrv = LogService.getlogService();
    	ResponseObject responseObj = new ResponseObject();
    	try {
    		PBSI__Transfer_Order__c transferOrder = 
    			[SELECT Id,Fulfiller__c,Notified_Fulfiller__c, Name,
    			(SELECT Id, Stage__c FROM Order_Stages__r WHERE Stage__c IN ('Scheduled', 'Processing')),
    			(SELECT Id FROM PBSI__Shipped_Tranfer_Lines__r WHERE Sent_to_Fulfiller__c = false)
    				FROM PBSI__Transfer_Order__c
    				WHERE Id = :toId];

    		if(transferOrder.Fulfiller__c != FULFILLER_KN) {
    			throw new NotifyFulfillerException('This Fulfiller is not supported: '+transferOrder.Fulfiller__c);
			}
			list<Order_Stage__c> lstTO_Order = transferOrder.Order_Stages__r;
			List<PBSI__Shipped_Tranfer_Line__c> lstTO_Lines = transferOrder.PBSI__Shipped_Tranfer_Lines__r;
			Id notificationTORecordType = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_TO');

			if(!lstTO_Order.isEmpty()){
				throw new NotifyFulfillerException('There are notifications pending for this Transfer Order: ' + transferOrder.Order_Stages__r);
			}
			if(lstTO_Lines.isEmpty()){
				throw new NotifyFulfillerException('There is no shipped lines that were not send for this Transfer Order: ' + transferOrder.Name);
			}

			update new PBSI__Transfer_Order__c(
				Id = toId,
				Fulfiller_status__c = 'In progress'
			);
			Order_stage__c newStage = new Order_stage__c(Transfer_Order__c = transferOrder.id, 
				RecordtypeId = notificationTORecordType ,
				Stage__c = 'Processing'
			);
			insert newStage;
				
			for(PBSI__Shipped_Tranfer_Line__c current : lstTO_Lines) {
				current.Notification_transaction__c = newStage.id;
			}
			update lstTO_Lines;
			runTONotification(newStage.Id, toId);
			
			
		} catch(Exception e) {
			responseObj.isSuccess = false;
			responseObj.message = e.getMessage();
			logSrv.addError()
				.type('TO_WebService_NotifyFulfiller')
				.exception(e)
				.relatedObjId(toId)
				.createActivity();
		}
		logSrv.save();
		return JSON.serialize(responseObj);
    }
    
    @Future(Callout=true)
    private static void runTONotification(Id stageId, Id toId) {
    	LogService logSrv = LogService.getlogService();
    	try {
    		KN_TO_RequestBuilder requestBuilder = new KN_TO_RequestBuilder(stageId);
			AsyncRequestManager rManager = requestBuilder.getRequestManager();
			rManager.enqueue();
		} catch(Exception e) {
			update new PBSI__Transfer_Order__c(
				Id = toId,
				Fulfiller_status__c = 'Error'
			);

			update new Order_stage__c(
				Id = stageId,
				Stage__c = 'Error'
			);
			logSrv.addError()
				.type('TO_WebService_runTONotification')
				.exception(e)
				.relatedObjId(stageId)
				.createActivity();
		}
    	logSrv.save();
    }

    public class ResponseObject {
    	public String message;
    	public Boolean isSuccess;

    	public ResponseObject() {
    		message = '';
    		isSuccess = true;
    	}

    	public ResponseObject(Boolean isSuccess, String message) {
    		this.message = message;
    		this.isSuccess = isSuccess;
    	}
    }

	private static void setFulfillerInProgess(Id orderId) {
		update new PBSI__PBSI_Sales_Order__c(
			Id = orderId,
			Fulfiller_status__c = 'In progress',
			BoD_Generated__c = false
		);
	}
}