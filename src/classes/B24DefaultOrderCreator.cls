public virtual class B24DefaultOrderCreator extends B24SObjectCreatorBase {

	protected B24MessageWrapper.OrderModel messageOrder;

	public virtual override ParentChildren createSObjectImpl(B24MessageWrapper.MessageModel message, String messageId) {
		messageOrder = (B24MessageWrapper.OrderModel) message;

		Account accBuyer = getAccountByGLN(messageOrder.buyer.gln);
		PBSI__PBSI_Sales_Order__c order = createBaseOrder(accBuyer);
		order.B24_Message_Id__c = messageId;

		AddressFactory addrFactory = new AddressFactory();
		IAddressSource billAddr = addrFactory.getBillingAddress(accBuyer);

		order.PBSI__BillingCity__c = billAddr.getCity();
		order.PBSI__BillingCompany__c = billAddr.getName();
		order.PBSI__BillingCountry__c = billAddr.getCountry();
		order.Billing_Name__c = accBuyer.Billing_Name__c;
		order.PBSI__BillingState__c = billAddr.getState();
		order.PBSI__BillingStreet__c = billAddr.getStreet1();
		order.PBSI__BillingZip__c = billAddr.getZipCode();

		//if there is gln of delivery party - use it, itherwise delivery address like in Delivery party
		IAddressSource shipAddr;
		if(String.isBlank(messageOrder.getDeliveryPartyGLN())) {
			shipAddr = addrFactory.getShippingAddress(messageOrder);
		} else {
			Account accDelivery = getAccountByGLN(messageOrder.getDeliveryPartyGLN());
			shipAddr = addrFactory.getShippingAddress(accDelivery);
		}
		
		order.PBSI__Delivery_Streetnew__c = shipAddr.getStreet1();
		order.PBSI__Delivery_Address_line2__c = shipAddr.getStreet2();
		order.PBSI__Delivery_Address_line_3__c = shipAddr.getStreet3();
		order.PBSI__Delivery_ATTN_to_Phone__c = shipAddr.getPhone();
		order.PBSI__Delivery_City__c = shipAddr.getCity();
		order.PBSI__Delivery_Company__c = shipAddr.getName();
		order.PBSI__Delivery_Country__c = shipAddr.getCountry();
		order.PBSI__Delivery_Postal_Code__c = shipAddr.getZipCode();
		order.PBSI__Delivery_State__c = shipAddr.getState();


		for(B24MessageWrapper.DocumentReferenceModel docRef: messageOrder.documentReference ) {
			if(docRef.documentType == 'BuyerOrder') {
				order.PBSI__Customer_Purchase_Order__c = docRef.id;
			}
		}

		for(B24MessageWrapper.PropertyModel prop: messageOrder.properties) {
			if(prop.name == 'customerOrderRef') {
				order.PBSI__Comments__c = prop.text;
			} else if(prop.name == 'termsOfDelivery') {
				order.Delivery_instructions__c = prop.text;
			}
		}

		ParentChildren retObjs = new ParentChildren();
		retObjs.parent = order;
		retObjs.children = new List<SObject>();

		SOLineFactory lineFactory = new SOLineFactory(messageId);
		for(B24MessageWrapper.OrderItemModel item: messageOrder.item) {
			retObjs.children.add(
				lineFactory.salesOrderLine(item)
			);
		}

		//prices are populated from trade agreements

		return retObjs;
	}

	protected virtual PBSI__PBSI_Sales_Order__c createBaseOrder(Account accBuyer) {
		PBSI__PBSI_Sales_Order__c order = new PBSI__PBSI_Sales_Order__c();
		order.PBSI__Customer__c = accBuyer.Id;
		order.Sales_Order_Type__c = 'Drop ship';
		order.CurrencyISOCode = accBuyer.c2g__CODAAccountTradingCurrency__c;
		order.OwnerId = accBuyer.OwnerId;
		order.PBSI__Contact__c = accBuyer.c2g__CODAFinanceContact__c;
		order.PBSI__Stage__c = 'open';
		order.PBSI__Status__c = 'open';
		return order;
	}

	private class SOLineFactory {
		private PBSI__PBSI_Sales_Order__c orderReference;
		public SOLineFactory(String messageId) {
			orderReference = new PBSI__PBSI_Sales_Order__c(
				B24_Message_Id__c = messageId
			);
		}
		public PBSI__PBSI_Sales_Order_Line__c salesOrderLine(B24MessageWrapper.OrderItemModel orderItem) {
			String eanCode;
			String lineNo; 
			String buyerRegistry; 
			String buyerReference; 
			for(B24MessageWrapper.ItemReferenceModel ref: orderItem.itemReference) {
				if(!String.isBlank(ref.coding) && ref.coding.equalsIgnoreCase('EAN13')) {
					eanCode = ref.text;
				} else if(!String.isBlank(ref.registry) && ref.registry.equalsIgnoreCase('Buyer')) {
					buyerReference = ref.text;
					buyerRegistry = ref.name;
				}
			}
			if(orderItem.documentReference != null) {
				for(B24MessageWrapper.DocumentReferenceModel ref: orderItem.documentReference) {
					if(ref.documentType.equalsIgnoreCase('BuyerOrder')) {
						lineNo = ref.lineNo;
						break;
					}
				}
			}
			return new PBSI__PBSI_Sales_Order_Line__c(
				PBSI__Sales_Order__r = orderReference,
				PBSI__Quantity_Needed__c = orderItem.quantity,
				PBSI__Item__r = new PBSI__PBSI_Item__c(EAN_Number__c = eanCode),
				Line_Order_Number__c = lineNo,
				Buyer_Reference__c = buyerReference,
				Buyer_Registry__c = buyerRegistry
			);
		}
	}

}