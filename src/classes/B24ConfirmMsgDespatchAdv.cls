public class B24ConfirmMsgDespatchAdv implements IProcessStepDefinition {
	private ProcessRealization pInstance;
	protected B24MessageFactory b24MsgFct;
	@TestVisible
	protected B24MessageFactory.Order msgFactOrderWarp;
	private B24MessageSend msgSend;
	private LogService logSrv;
	private Tracking__c trackingObj;
	private SObject order;
	private List<Tracking_Number__c> lTrackingNumbers;
	private String msg;
	private B24MessageSend.MessageResponse response;

	public class B24ConfirmMsgDespatException extends Exception {}

	public void executeStep(ProcessRealization pInstance) {
		this.pInstance = pInstance;
		logSrv = LogService.getlogService();

		//try-catch is here because fail of this step should not block next steps
		try {
			queryTracking(pInstance.getRecordIds()[0]);
			if(!trackingObj.DESADV_automation__c) {
				return;
			}
			if(trackingObj.Is_Sales_Order__c) {
				querySalesOrder();
			} else if(trackingObj.Is_Transfer_Order__c) {
				queryTransferOrder();
			} else {
				throw new B24ConfirmMsgDespatException('Tracking object not support. It\'s not for Sales or Transfer order');
			}
			queryTrackingNumbers();

		
			b24MsgFct = new B24MessageFactory();
			msgSend = new B24MessageSend();
			msgFactOrderWarp = new SalesOrderTrackingWrapper(trackingObj.Order_Stage__r, lTrackingNumbers);

			msg = b24MsgFct.desadv(msgFactOrderWarp, trackingObj.Order_Stage__r.Transmission_Id__c, trackingObj.Carrier_Code__c );
			if(!Test.isRunningTest()) {
				response = msgSend.sendDespatchAdvice(msg);
			} else {
				response = new B24MessageSend.MessageResponse();
			}

			setShippedLinesDesadvSent();
			saveReqestAndResponse();
		}
		catch(Exception e){
 			logSrv.addError().exception(e).type(B24ConfirmMsgDespatchAdv.class.getName());
		}
		logSrv.save();
		
	}

	private void queryTracking(Id trackingId) {
		this.trackingObj = [SELECT Id,
			DESADV_automation__c,
			Movement_Order_Number__c,
			Is_Sales_Order__c,
			Sales_Order__c,
			Is_Transfer_Order__c,
			Transfer_Order__c,
			Carrier_Code__c,
			Order_Stage__c,
			Order_Stage__r.Transmission_Id__c,
			Order_Stage__r.DESADV_Number__c
			FROM Tracking__c
			WHERE Id = :trackingId];
	}

	private void querySalesOrder() {
		this.order = [SELECT Id,
			PBSI__Customer__r.GLN__c,
			Transmission_Count__c,
			PBSI__Customer_Purchase_Order__c,
			Name,
			Sales_Order_Type__c,
			PBSI__Delivery_Company__c,
			PBSI__Delivery_ATTN_to_Phone__c,
			PBSI__Delivery_Streetnew__c,
			PBSI__Delivery_Address_line2__c,
			PBSI__Delivery_City__c,
			PBSI__Delivery_Country__c,
			PBSI__Delivery_State__c,
			PBSI__Delivery_Postal_Code__c,
			PBSI__From_Location__r.GLN__c,
			CreatedDate
			FROM PBSI__PBSI_Sales_Order__c 
			WHERE Id = :trackingObj.Sales_Order__c];
		trackingObj.Order_Stage__r.Sales_Order__r = (PBSI__PBSI_Sales_Order__c) this.order;
	}

	private void queryTransferOrder() {
		this.order = [SELECT Id,
			PBSI__From_Location__c,
			Transmission_Count__c,
			Name,
			PBSI__To_Location__r.B24_Recipient_Override__c,
			PBSI__To_Location__r.B24_Recipient_Override__r.GLN__c ,
			Delivery_Party_Account__r.GLN__c,
			Customer_PO__c,
			PBSI__To_Location__r.GLN__c,
			Delivery_Party_Account__r.Name,
			Delivery_Party_Account__r.Phone,
			Address_Line_1__c,
			Address_Line_2__c,
			City__c,
			Country__c,
			State__c,
			Postal_Code__c,
			Ultimate_Cosignee_Account__r.GLN__c,
			PBSI__From_Location__r.GLN__c,
			Ultimate_Cosignee_Account__r.Name,
			Ultimate_Cosignee_Account__r.Phone,
			UC_Address_Line_1__c,
			UC_Address_Line_2__c,
			UC_City__c,
			UC_Country__c,
			UC_State__c,
			UC_Postal_Code__c,
			CreatedDate
			FROM PBSI__Transfer_Order__c 
			WHERE Id = :trackingObj.Transfer_Order__c];
		trackingObj.Order_Stage__r.Transfer_Order__r = (PBSI__Transfer_Order__c) this.order;
	}

	private void queryTrackingNumbers() {
		this.lTrackingNumbers = [SELECT Id,
			Package_Weight__c,
			Number__c,
			Link__c,
			Tracking__c,
				(SELECT Id,
				Quantity__c,
				Item__r.Name,
				Item__r.EAN_Number__c,
				Tracking_Number__r.Tracking__r.Tracking_Numbers__c,
				Description__c,
				Is_For_Sales_Order__c,
				Packed_Sales_Order_Line__r.PBSI__Sales_Order_Line__r.Line_Order_Number__c,
				Shipped_Transfer_Line__r.PBSI__Transfer_Order_Line__r.Line_Order_Number__c,
				Packed_Sales_Order_Line__r.PBSI__Sales_Order_Line__r.Buyer_Reference__c,
				Packed_Sales_Order_Line__r.PBSI__Sales_Order_Line__r.Buyer_Registry__c
				FROM Tracking_Number_Items__r)
			FROM Tracking_Number__c
			WHERE Tracking__c = :trackingObj.Id];
	}

	private void setShippedLinesDesadvSent() {
		Set<Id> sShippedLinesIds = new Set<Id>(); 
		for(Tracking_Number__c tNumber: lTrackingNumbers) {
			for(Tracking_Number_Item__c tnItem: tNumber.Tracking_Number_Items__r) {
				Id lineId = trackingObj.Is_Sales_Order__c ? tnItem.Packed_Sales_Order_Line__c : tnItem.Shipped_Transfer_Line__c;
				sShippedLinesIds.add(lineId);
			}
		} 
		String query = 'SELECT Id FROM '+ (trackingObj.Is_Sales_Order__c ? 'PBSI__Shipped_Sales_Order_Line__c' : 'PBSI__Shipped_Tranfer_Line__c')
			+ ' WHERE Id IN :sShippedLinesIds';
		List<SObject> lShippedLines = Database.query(query);
		for(SObject line: lShippedLines) {
			line.put('DESADV_sent__c', true);
		}
		update lShippedLines;
	}

	private void saveReqestAndResponse() {
		Attachment attMsg = new Attachment(
            ParentId = order.Id,
            Name = 'desadv-' + response.Id +'.json',
            Body = Blob.valueOf(msg)
        );
        Attachment attMsgRes = new Attachment(
            ParentId = order.Id,
            Name = 'response-' + response.Id +'.json',
            Body = Blob.valueOf(JSON.serialize(response))
        );
        insert new List<Attachment>{attMsg, attMsgRes};
	}

	public String getStepName() {
		return 'Send DESADV';
	}

	public class SalesOrderTrackingWrapper extends B24MessageFactory.SalesOrderStageWrapper {
		private List<Tracking_Number__c> lTrackingNumbers;
		public SalesOrderTrackingWrapper(Order_Stage__c orderStage, List<Tracking_Number__c> lTrackingNumbers) {
			super(orderStage);
			this.lTrackingNumbers = lTrackingNumbers;
		}

		protected override List<B24MessageFactory.PackageBox> populatePackeges() {
			List<B24MessageFactory.PackageBox> retVal = new List<B24MessageFactory.PackageBox>();
			for(Tracking_Number__c tn: this.lTrackingNumbers) {
				retVal.add(
					new TrackingNumber(tn)
				);
			}
			return retVal;
		}
	}

	public class TransferOrderTrackingWrapper extends B24MessageFactory.TransferOrderStageWrapper {
		private List<Tracking_Number__c> lTrackingNumbers;
		public TransferOrderTrackingWrapper(Order_Stage__c orderStage, List<Tracking_Number__c> lTrackingNumbers) {
			super(orderStage);
			this.lTrackingNumbers = lTrackingNumbers;
		}

		protected override List<B24MessageFactory.PackageBox> populatePackeges() {
			List<B24MessageFactory.PackageBox> retVal = new List<B24MessageFactory.PackageBox>();
			for(Tracking_Number__c tn: this.lTrackingNumbers) {
				retVal.add(
					new TrackingNumber(tn)
				);
			}
			return retVal;
		}
	}

	private class TrackingNumber implements B24MessageFactory.PackageBox {
		private Tracking_Number__c trackingNumberObj;
		private List<B24MessageFactory.OrderLine> lines;
		public TrackingNumber(Tracking_Number__c trackingNumberObj) {
			this.trackingNumberObj = trackingNumberObj;
			lines = new List<B24MessageFactory.OrderLine>();
			for(Tracking_Number_Item__c item: trackingNumberObj.Tracking_Number_Items__r) {
				lines.add(
					new TrackingNumberLine(item)
				);
			}
		}

		public List<B24MessageFactory.OrderLine> getLines() {
			return lines;
		}

		public String getTrackingLink() {
			return this.trackingNumberObj.Link__c;
		}

		public String getTrackingNumber() {
			return this.trackingNumberObj.Number__c;
		}
	}

	private class TrackingNumberLine implements B24MessageFactory.OrderLine {
		private Tracking_Number_Item__c item;
		public TrackingNumberLine(Tracking_Number_Item__c item) {
			this.item = item;
		}
		public Integer getQuantity() {
			return Integer.valueOf(item.Quantity__c);
		}
		public String getItemNumber() {
			return item.Item__r.Name;
		}
		public String getItemEAN() {
			return item.Item__r.EAN_Number__c;
		}
		public String getLineNo() {
			return item.Is_For_Sales_Order__c ? item.Packed_Sales_Order_Line__r.PBSI__Sales_Order_Line__r.Line_Order_Number__c : 
				item.Shipped_Transfer_Line__r.PBSI__Transfer_Order_Line__r.Line_Order_Number__c;
		}
		public Boolean hasBuyerReference() {
			return item.Is_For_Sales_Order__c ? (!String.isBlank(item.Packed_Sales_Order_Line__r.PBSI__Sales_Order_Line__r.Buyer_Reference__c)) : false;
		}
		public String getBuyerReference() {
			return  item.Is_For_Sales_Order__c ? item.Packed_Sales_Order_Line__r.PBSI__Sales_Order_Line__r.Buyer_Reference__c : '';
		}
		public String getBuyerRegistry() {
			return  item.Is_For_Sales_Order__c ? item.Packed_Sales_Order_Line__r.PBSI__Sales_Order_Line__r.Buyer_Registry__c : '';
		}
	}
}