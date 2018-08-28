public class B24MessageFactory {

	public class OrderTypeNotSupportedException extends Exception {}

	private Map<Id, B24MessageWrapper.InventoryReportModel> reportsResults;

	public B24MessageFactory() {
		reportsResults = new Map<Id, B24MessageWrapper.InventoryReportModel>();
	}
	
	public String desadv(Id orderId, Set<Id> shippedLinesIds, String shipmentNumber, String carrierCode) {
		Order orderWrap = fetchDataFromDB(orderId, shippedLinesIds);
		return desadv(orderWrap, shipmentNumber, carrierCode);
	}

	public String desadv(Order_Stage__c orderStage, String carrierCode) {
		if(orderStage.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_SO')) {
			return desadvSO(orderStage, carrierCode);
		} else if(orderStage.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_TO')) {
			return desadvTO(orderStage, carrierCode);
		} else {
			throw new OrderTypeNotSupportedException('Order Stage recordTypeId '+orderStage.RecordTypeId);
		}
	}

	public String desadvSO(Order_Stage__c orderStage, String carrierCode) {
		orderStage = [SELECT Id, Stage__c, Sales_Order__c, Transmission_Id__c, DESADV_Number__c, RecordTypeId,
			Sales_Order__r.Id,
			Sales_Order__r.Name,
			Sales_Order__r.PBSI__From_Location__r.GLN__c,
			Sales_Order__r.PBSI__Customer__r.GLN__c,
			Sales_Order__r.PBSI__Customer_Purchase_Order__c,
			Sales_Order__r.CreatedDate,
			Sales_Order__r.Sales_Order_Type__c,
			Sales_Order__r.PBSI__Delivery_Company__c,
			Sales_Order__r.PBSI__Delivery_ATTN_to_Phone__c,
			Sales_Order__r.PBSI__Delivery_Streetnew__c,
			Sales_Order__r.PBSI__Delivery_Address_line2__c,
			Sales_Order__r.PBSI__Delivery_City__c,
			Sales_Order__r.PBSI__Delivery_Country__c,
			Sales_Order__r.PBSI__Delivery_State__c,
			Sales_Order__r.PBSI__Delivery_Postal_Code__c,
			Sales_Order__r.TransmissionIdentification__c,
			Sales_Order__r.Transmission_Count__c,
			Sales_Order__r.Customer_PO_Date__c,
					(SELECT Id,Name, PBSI__Item__r.Name, PBSI__Item__r.EAN_Number__c,PBSI__Quantity_Shipped__c, PBSI__Sales_Order_Line__r.Line_Order_Number__c,
						PBSI__Sales_Order_Line__r.Buyer_Reference__c, PBSI__Sales_Order_Line__r.Buyer_Registry__c
						FROM Shipped_Sales_Order_Lines__r WHERE DESADV_Sent__c = false)
				FROM Order_Stage__c WHERE Id = :orderStage.Id];
		Order orderWrap = new SalesOrderStageWrapper(orderStage);
		return desadv(orderWrap, orderStage.Transmission_Id__c, carrierCode);
	}

	public String desadvTO(Order_Stage__c orderStage, String carrierCode) {
		orderStage = [SELECT Id, Stage__c, Sales_Order__c, Transmission_Id__c, DESADV_Number__c, RecordTypeId,
			Transfer_Order__r.Id,
			Transfer_Order__r.Name,
			Transfer_Order__r.PBSI__From_Location__r.GLN__c,
			Transfer_Order__r.Delivery_Party_Account__r.GLN__c,
			Transfer_Order__r.Customer_PO__c,
			Transfer_Order__r.CreatedDate,
			Transfer_Order__r.Ultimate_Cosignee_Account__r.GLN__c,
			Transfer_Order__r.Delivery_Party_Account__r.Name,
			Transfer_Order__r.Delivery_Party_Account__r.Phone,
			Transfer_Order__r.Address_Line_1__c,
			Transfer_Order__r.Address_Line_2__c,
			Transfer_Order__r.City__c,
			Transfer_Order__r.Country__c,
			Transfer_Order__r.State__c,
			Transfer_Order__r.Postal_Code__c,
			Transfer_Order__r.UC_Address_Line_1__c,
			Transfer_Order__r.UC_Address_Line_2__c,
			Transfer_Order__r.UC_City__c,
			Transfer_Order__r.UC_Country__c,
			Transfer_Order__r.UC_State__c,
			Transfer_Order__r.UC_Postal_Code__c,
			Transfer_Order__r.Ultimate_Cosignee_Account__r.Name,
			Transfer_Order__r.Ultimate_Cosignee_Account__r.Phone,
			Transfer_Order__r.TransmissionIdentification__c,
			Transfer_Order__r.Transmission_Count__c,
			Transfer_Order__r.PBSI__To_Location__r.GLN__c,
			Transfer_Order__r.PBSI__To_Location__r.B24_Recipient_Override__r.GLN__c,
						(SELECT Id,Name,PBSI__Item__r.Name,PBSI__Item__r.EAN_Number__c,PBSI__Quantity__c, CreatedDate, PBSI__Transfer_Order_Line__r.Line_Order_Number__c
							FROM Shipped_Transfer_Lines__r WHERE DESADV_Sent__c = false)
						FROM Order_Stage__c WHERE Id = :orderStage.Id];
		Order orderWrap = new TransferOrderStageWrapper(orderStage);
		return desadv(orderWrap, orderStage.Transmission_Id__c, carrierCode);
	}

	private Order fetchDataFromDB(Id orderId, Set<Id> shippedLinesIds) {
		String orderType = orderId.getSObjectType().getDescribe().getName();
		Order retOrder;
		if(orderType == PBSI__Transfer_Order__c.getSObjectType().getDescribe().getName()) {
			PBSI__Transfer_Order__c transferOrder = [SELECT Id,Name,PBSI__From_Location__r.GLN__c,Delivery_Party_Account__r.GLN__c,Customer_PO__c,CreatedDate,
					Ultimate_Cosignee_Account__r.GLN__c,Delivery_Party_Account__r.Name,Delivery_Party_Account__r.Phone,Address_Line_1__c,Address_Line_2__c,
					City__c,Country__c,State__c,Postal_Code__c,UC_Address_Line_1__c,UC_Address_Line_2__c,UC_City__c,UC_Country__c,UC_State__c,UC_Postal_Code__c,
					Ultimate_Cosignee_Account__r.Name,Ultimate_Cosignee_Account__r.Phone,TransmissionIdentification__c,Transmission_Count__c,PBSI__To_Location__r.GLN__c,
					PBSI__To_Location__r.B24_Recipient_Override__r.GLN__c,
						(SELECT Id,Name,PBSI__Item__r.Name,PBSI__Item__r.EAN_Number__c,PBSI__Quantity__c, CreatedDate, PBSI__Transfer_Order_Line__r.Line_Order_Number__c
							FROM PBSI__Shipped_Tranfer_Lines__r WHERE Id IN :shippedLinesIds)
						FROM PBSI__Transfer_Order__c WHERE Id = :orderId];
			retOrder = new TransferOrderWrapper(transferOrder);
		} else if(orderType == PBSI__PBSI_Sales_Order__c.getSObjectType().getDescribe().getName()) {
			PBSI__PBSI_Sales_Order__c salesOrder = [SELECT Id,Name,PBSI__From_Location__r.GLN__c, PBSI__Customer__r.GLN__c,PBSI__Customer_Purchase_Order__c,CreatedDate,Sales_Order_Type__c,
			PBSI__Delivery_Company__c,PBSI__Delivery_ATTN_to_Phone__c,PBSI__Delivery_Streetnew__c,PBSI__Delivery_Address_line2__c,PBSI__Delivery_City__c,PBSI__Delivery_Country__c,
			PBSI__Delivery_State__c,PBSI__Delivery_Postal_Code__c,TransmissionIdentification__c,Transmission_Count__c,
					(SELECT Id,Name, PBSI__Item__r.Name, PBSI__Item__r.EAN_Number__c,PBSI__Quantity_Shipped__c, PBSI__Sales_Order_Line__r.Line_Order_Number__c,
						PBSI__Sales_Order_Line__r.Buyer_Reference__c, PBSI__Sales_Order_Line__r.Buyer_Registry__c
						FROM PBSI__R00N60000001ZR62EAG__r WHERE Id IN :shippedLinesIds)
				FROM PBSI__PBSI_Sales_Order__c WHERE Id = :orderId];
			retOrder = new SalesOrderWrapper(salesOrder);
		} else {
			throw new OrderTypeNotSupportedException(orderType);
		}
		return retOrder;
	}

	public String desadv(Order orderWrap, String shipmentNumber, String carrierCode) {
		SingleMessageWrapper msgWrap = new SingleMessageWrapper();
		B24MessageWrapper.DespatchAdviceModel desadv = new B24MessageWrapper.DespatchAdviceModel();
		desadv.environment = thisEnvironment;
		desadv.documentId = shipmentNumber;
		desadv.recipient = new B24MessageWrapper.PartyModel();
		desadv.recipient.gln = orderWrap.getCustomerGLN();
		desadv.buyer = new B24MessageWrapper.PartyModel();
		desadv.buyer.gln = orderWrap.getCustomerGLN();
		
		desadv.properties = new List<B24MessageWrapper.PropertyModel>();
		B24MessageWrapper.PropertyModel carrierAlphaCode = new B24MessageWrapper.PropertyModel();
		if(!String.isBlank(carrierCode)) {
			carrierAlphaCode.name = 'carrierAlphaCode';
			carrierAlphaCode.text = carrierCode;
			desadv.properties.add(carrierAlphaCode);
		}		
		
		B24MessageWrapper.PartyModel deliveryParty = new B24MessageWrapper.PartyModel();
		deliveryParty.gln = orderWrap.getDeliveryPartyGLN();
		deliveryParty.name = orderWrap.getDeliveryPartyName();

		deliveryParty.location = new B24MessageWrapper.LocationModel();
		deliveryParty.location.address = orderWrap.getDeliveryPartyStreet1();
		if(!String.isBlank(orderWrap.getDeliveryPartyStreet2())) {
			deliveryParty.location.address += ' ' + orderWrap.getDeliveryPartyStreet2();
		}
		deliveryParty.location.telephoneNumber = orderWrap.getDeliveryPartyPhone();
		deliveryParty.location.city = new B24MessageWrapper.CityModel();
		deliveryParty.location.city.text = orderWrap.getDeliveryPartyCity();
		deliveryParty.location.country = new B24MessageWrapper.CountryModel();
		deliveryParty.location.country.text = orderWrap.getDeliveryPartyCountry();
		
		if(!String.isEmpty(orderWrap.getDeliveryPartyState())) {
			deliveryParty.location.state = new B24MessageWrapper.CountryModel();
			deliveryParty.location.state.text = orderWrap.getDeliveryPartyState();
		}

		desadv.deliveryParty = deliveryParty;

		
		if(!String.isBlank(orderWrap.getUltimateCosigneeGLN())) {
			B24MessageWrapper.PartyModel ultimateCosignee = new B24MessageWrapper.PartyModel();
			ultimateCosignee.gln = orderWrap.getUltimateCosigneeGLN();
			ultimateCosignee.name = orderWrap.getUltimateCosigneeName();

			ultimateCosignee.location = new B24MessageWrapper.LocationModel();
			ultimateCosignee.location.address = orderWrap.getUltimateCosigneeStreet1();
			if(!String.isBlank(orderWrap.getUltimateCosigneeStreet2())) {
				ultimateCosignee.location.address += ' ' + orderWrap.getUltimateCosigneeStreet2();
			}
			ultimateCosignee.location.telephoneNumber = orderWrap.getUltimateCosigneePhone();
			ultimateCosignee.location.city = new B24MessageWrapper.CityModel();
			ultimateCosignee.location.city.text = orderWrap.getUltimateCosigneeCity();
			ultimateCosignee.location.country = new B24MessageWrapper.CountryModel();
			ultimateCosignee.location.country.text = orderWrap.getUltimateCosigneeCountry();

			if(!String.isEmpty(orderWrap.getUltimateCosigneeState())) {
				ultimateCosignee.location.state = new B24MessageWrapper.CountryModel();
				ultimateCosignee.location.state.text = orderWrap.getUltimateCosigneeState();
			}
			desadv.ultimateCosignee = ultimateCosignee;
		}
		
			

		desadv.documentReferences = new List<B24MessageWrapper.DocumentReferenceModel>();
		if(!String.isBlank(orderWrap.getCustomerPO())) {
			B24MessageWrapper.DocumentReferenceModel poNumber = new B24MessageWrapper.DocumentReferenceModel();
			poNumber.documentType = 'BuyerOrder';
			poNumber.id = orderWrap.getCustomerPO();
			desadv.documentReferences.add(poNumber);
		}
		B24MessageWrapper.DocumentReferenceModel onNumber = new B24MessageWrapper.DocumentReferenceModel();
		onNumber.documentType = 'SupplierOrder';
		onNumber.id = orderWrap.getOrderNumber();
		onNumber.documentDate = orderWrap.getSupplierOrderDate();
		desadv.documentReferences.add(onNumber);

		B24MessageWrapper.DocumentReferenceModel desadvInfo = new B24MessageWrapper.DocumentReferenceModel();
		desadvInfo.documentType = 'DespatchAdvice';
		desadvInfo.id = orderWrap.getDESADVNumber();
		desadvInfo.documentDate = System.today();
		desadv.documentReferences.add(desadvInfo);

		desadv.sender = new B24MessageWrapper.PartyModel();
		desadv.sender.gln = '7640146810007';
		desadv.supplier = new B24MessageWrapper.PartyModel();
		desadv.supplier.gln = '7640146810007';
		desadv.shipFrom = new B24MessageWrapper.PartyModel();
		desadv.shipFrom.gln = orderWrap.getShipFromGLN();
		desadv.shipmentNumber = shipmentNumber;
		desadv.shippingDate = System.today();
		
		desadv.packages = new List<B24MessageWrapper.PackageModel>();
		for(PackageBox pkg: orderWrap.getPackages()) {
			B24MessageWrapper.PackageModel b24Pkg = new B24MessageWrapper.PackageModel();
			b24Pkg.items = new List<B24MessageWrapper.DesadvItemModel>();
			b24Pkg.quantity = 1;
			b24Pkg.packageType = 'BX';
			if(!String.isBlank(pkg.getTrackingLink())) {
				b24Pkg.trackingUrl = pkg.getTrackingLink();
			}
			b24Pkg.properties = new List<B24MessageWrapper.PropertyModel>();
			if(!String.isBlank(pkg.getTrackingNumber())) {
				B24MessageWrapper.PropertyModel carrierPackageID = new B24MessageWrapper.PropertyModel();
				carrierPackageID.name = 'carrierPackageID';
				carrierPackageID.text = pkg.getTrackingNumber();
				b24Pkg.properties.add(carrierPackageID);
			}

			for(OrderLine shippedLine: pkg.getLines()) {
				B24MessageWrapper.DesadvItemModel item = new B24MessageWrapper.DesadvItemModel();
				item.documentReferences = desadv.documentReferences.clone();

				for(B24MessageWrapper.DocumentReferenceModel ref: item.documentReferences) {
					ref.lineNo = shippedLine.getLineNo();
				}

				item.itemReference = new List<B24MessageWrapper.ItemReferenceModel>();
				B24MessageWrapper.ItemReferenceModel ean13ItemReference = new B24MessageWrapper.ItemReferenceModel();
				ean13ItemReference.registry = 'Supplier';
				ean13ItemReference.coding = 'EAN13';
				ean13ItemReference.text = shippedLine.getItemEAN();

				item.id = shippedLine.getItemNumber();

				item.itemReference.add(ean13ItemReference);

				if(shippedLine.hasBuyerReference()) {
					B24MessageWrapper.ItemReferenceModel buyerReference = new B24MessageWrapper.ItemReferenceModel();
					buyerReference.registry = 'Buyer';
					buyerReference.name = shippedLine.getBuyerRegistry();
					buyerReference.text = shippedLine.getBuyerReference();
					item.itemReference.add(buyerReference);
				}
				
				item.quantity = shippedLine.getQuantity();
				b24Pkg.items.add(item);
			}

			desadv.packages.add(b24Pkg);
		}
		
		msgWrap.b24Message.despatchAdvice = desadv;
		return JSON.serialize(msgWrap, true);
	}
	

	private String getEnvironment() {
		return thisEnvironment;
	}

	private static String thisEnvironment {
		get {
			if(thisEnvironment == null) {
				Organization thisInstance = [SELECT Id, Name, IsSandbox from Organization];
  				thisEnvironment = thisInstance.IsSandbox ? 'Test_' + thisInstance.Id : 'Production';
			}
			return thisEnvironment;
		}
		set;
	}

	public interface Order {
		String getCustomerGLN();
		String getCustomerPO();
		String getOrderNumber();
		String getDeliveryPartyGLN();
		String getDeliveryPartyName();
		String getDeliveryPartyPhone();
		String getDeliveryPartyStreet1();
		String getDeliveryPartyStreet2();
		String getDeliveryPartyCity();
		String getDeliveryPartyCountry();
		String getDeliveryPartyState();
		String getDeliveryPartyZIPCode();
		String getUltimateCosigneeGLN();
		String getUltimateCosigneeName();
		String getUltimateCosigneePhone();
		String getUltimateCosigneeStreet1();
		String getUltimateCosigneeStreet2();
		String getUltimateCosigneeCity();
		String getUltimateCosigneeCountry();
		String getUltimateCosigneeState();
		String getUltimateCosigneeZIPCode();
		String getShipFromGLN();
		List<PackageBox> getPackages();
		Date getSupplierOrderDate();
		String getDESADVNumber();
	}

	public interface PackageBox {
		List<OrderLine> getLines();
		String getTrackingLink();
		String getTrackingNumber();
	}

	public interface OrderLine {
		Integer getQuantity();
		String getItemNumber();
		String getItemEAN();
		String getLineNo();
		Boolean hasBuyerReference();
		String getBuyerReference();
		String getBuyerRegistry();
	}
	
	public virtual class SalesOrderWrapper implements Order {
		protected PBSI__PBSI_Sales_Order__c salesOrder;
		protected List<PackageBox> lPackages;
		protected String transmissionId;
		public SalesOrderWrapper(PBSI__PBSI_Sales_Order__c order) {
			salesOrder = order;
			Integer nextTransmissionNumber = Integer.valueOf(salesOrder.Transmission_Count__c != null ? salesOrder.Transmission_Count__c : 0);
			transmissionId = salesOrder.Name + '-' + (nextTransmissionNumber - 1);
		}
		protected virtual List<PackageBox> populatePackeges() {
			List<PackageBox> retVal = new List<PackageBox>();
			retVal.add(
				new SinglePackageWrapper(salesOrder.PBSI__R00N60000001ZR62EAG__r)
			);
			return retVal;
		}
		public String getCustomerGLN() {
			return salesOrder.PBSI__Customer__r.GLN__c;
		}
		public String getCustomerPO() {
			return salesOrder.PBSI__Customer_Purchase_Order__c;
		}
		public String getOrderNumber() {
			return salesOrder.Name;
		}
		public String getDeliveryPartyGLN() {
			return salesOrder.Sales_Order_Type__c == 'Drop Ship' ? null : salesOrder.PBSI__Customer__r.GLN__c;
		}
		public String getDeliveryPartyName() {
			return salesOrder.PBSI__Delivery_Company__c;
		}
		public String getDeliveryPartyPhone() {
			return salesOrder.PBSI__Delivery_ATTN_to_Phone__c;
		}
		public String getDeliveryPartyStreet1() {
			return salesOrder.PBSI__Delivery_Streetnew__c;
		}
		public String getDeliveryPartyStreet2() {
			return salesOrder.PBSI__Delivery_Address_line2__c;
		}
		public String getDeliveryPartyCity() {
			return salesOrder.PBSI__Delivery_City__c;
		}
		public String getDeliveryPartyCountry() {
			return salesOrder.PBSI__Delivery_Country__c;
		}
		public String getDeliveryPartyState() {
			return salesOrder.PBSI__Delivery_State__c;
		}
		public String getDeliveryPartyZIPCode() {
			return salesOrder.PBSI__Delivery_Postal_Code__c;
		}
		public String getUltimateCosigneeGLN() {
			return null;
		}
		public String getUltimateCosigneeName() {
			return null;
		}
		public String getUltimateCosigneePhone(){
			return null;
		}
		public String getUltimateCosigneeStreet1(){
			return null;
		}
		public String getUltimateCosigneeStreet2(){
			return null;
		}
		public String getUltimateCosigneeCity(){
			return null;
		}
		public String getUltimateCosigneeCountry(){
			return null;
		}
		public String getUltimateCosigneeState(){
			return null;
		}
		public String getUltimateCosigneeZIPCode(){
			return null;
		}
		public String getShipFromGLN() {
			return salesOrder.PBSI__From_Location__r.GLN__c;
		}
		public List<PackageBox> getPackages() {
			if(lPackages == null) {
				lPackages = populatePackeges();
			}
			return lPackages;
		}
		public Date getSupplierOrderDate() {
			return salesOrder.CreatedDate.date();
		}

		public String getDESADVNumber() {
			return transmissionId;
		}
	}

	public virtual class SinglePackageWrapper implements PackageBox {
		protected List<OrderLine> lines;
		public SinglePackageWrapper(List<PBSI__Shipped_Sales_Order_Line__c> shippedLines) {
			lines = new List<OrderLine>();
			for(PBSI__Shipped_Sales_Order_Line__c line: shippedLines) {
				lines.add( new SalesOrderLineWrapper(line) );
			}
		}

		public SinglePackageWrapper(List<PBSI__Shipped_Tranfer_Line__c> shippedLines) {
			lines = new List<OrderLine>();
			for(PBSI__Shipped_Tranfer_Line__c line: shippedLines) {
				lines.add( new TransferOrderLineWrapper(line) );
			}
		}
		public virtual List<OrderLine> getLines() {
			return lines;
		}
		public virtual String getTrackingLink() {
			return '';
		}
		public virtual String getTrackingNumber() {
			return '';
		}
	}

	public virtual class SalesOrderStageWrapper extends SalesOrderWrapper {
		private Order_Stage__c orderStage;
		public SalesOrderStageWrapper(Order_Stage__c orderStage) {
			super(orderStage.Sales_Order__r);
			this.transmissionId = orderStage.DESADV_Number__c;
			this.orderStage = orderStage;
		}

		protected virtual override List<PackageBox> populatePackeges() {
			List<PackageBox> retVal = new List<PackageBox>();
			retVal.add(
				new SinglePackageWrapper(orderStage.Shipped_Sales_Order_Lines__r)
			);
			return retVal;
		}
	}

	private class SalesOrderLineWrapper implements OrderLine {
		private PBSI__Shipped_Sales_Order_Line__c shippedLine;
		public SalesOrderLineWrapper(PBSI__Shipped_Sales_Order_Line__c line) {
			shippedLine = line;
		}
		public Integer getQuantity() {
			return Integer.valueOf(shippedLine.PBSI__Quantity_Shipped__c);
		}
		public String getItemNumber() {
			return shippedLine.PBSI__Item__r.Name;
		}
		public String getItemEAN() {
			return shippedLine.PBSI__Item__r.EAN_Number__c;
		}
		public String getLineNo() {
			return shippedLine.PBSI__Sales_Order_Line__r.Line_Order_Number__c;
		}
		public Boolean hasBuyerReference() {
			return !String.isBlank(this.getBuyerReference());
		}
		public String getBuyerReference() {
			return shippedLine.PBSI__Sales_Order_Line__r.Buyer_Reference__c;
		}
		public String getBuyerRegistry() {
			return shippedLine.PBSI__Sales_Order_Line__r.Buyer_Registry__c;
		}
	}

	public virtual class TransferOrderWrapper implements Order {
		protected PBSI__Transfer_Order__c transferOrder;
		protected List<PackageBox> lPackages;
		protected String transmissionId;
		public TransferOrderWrapper(PBSI__Transfer_Order__c order) {
			transferOrder = order;
			Integer nextTransmissionNumber = Integer.valueOf(transferOrder.Transmission_Count__c != null ? transferOrder.Transmission_Count__c : 0);
			transmissionId = transferOrder.Name + '-' + (nextTransmissionNumber - 1);
		}
		protected virtual List<PackageBox> populatePackeges() {
			List<PackageBox> retVal = new List<PackageBox>();
			retVal.add(
				new SinglePackageWrapper(transferOrder.PBSI__Shipped_Tranfer_Lines__r)
			);
			return retVal;
		}
		public String getCustomerGLN() {
			return transferOrder.PBSI__To_Location__r.B24_Recipient_Override__c != null ? transferOrder.PBSI__To_Location__r.B24_Recipient_Override__r.GLN__c : transferOrder.Delivery_Party_Account__r.GLN__c;
		}
		public String getCustomerPO() {
			return transferOrder.Customer_PO__c;
		}
		public String getOrderNumber() {
			return transferOrder.Name;
		}
		public String getDeliveryPartyGLN() {
			return transferOrder.PBSI__To_Location__r.GLN__c;
		}
		public String getDeliveryPartyName() {
			return transferOrder.Delivery_Party_Account__r.Name;
		}
		public String getDeliveryPartyPhone() {
			return transferOrder.Delivery_Party_Account__r.Phone;
		}
		public String getDeliveryPartyStreet1() {
			return transferOrder.Address_Line_1__c;
		}
		public String getDeliveryPartyStreet2() {
			return transferOrder.Address_Line_2__c;
		}
		public String getDeliveryPartyCity() {
			return transferOrder.City__c;
		}
		public String getDeliveryPartyCountry() {
			return transferOrder.Country__c;
		}
		public String getDeliveryPartyState() {
			return transferOrder.State__c;
		}
		public String getDeliveryPartyZIPCode() {
			return transferOrder.Postal_Code__c;
		}
		public String getUltimateCosigneeGLN() {
			return transferOrder.Ultimate_Cosignee_Account__r != null ? transferOrder.Ultimate_Cosignee_Account__r.GLN__c : null;
		}
		public String getShipFromGLN() {
			return transferOrder.PBSI__From_Location__r.GLN__c;
		}
		public String getUltimateCosigneeName() {
			return transferOrder.Ultimate_Cosignee_Account__r != null ? transferOrder.Ultimate_Cosignee_Account__r.Name : null;
		}
		public String getUltimateCosigneePhone() {
			return transferOrder.Ultimate_Cosignee_Account__r != null ? transferOrder.Ultimate_Cosignee_Account__r.Phone : null;
		}
		public String getUltimateCosigneeStreet1() {
			return transferOrder.UC_Address_Line_1__c;
		}
		public String getUltimateCosigneeStreet2() {
			return transferOrder.UC_Address_Line_2__c;
		}
		public String getUltimateCosigneeCity() {
			return transferOrder.UC_City__c;
		}
		public String getUltimateCosigneeCountry() {
			return transferOrder.UC_Country__c;
		}
		public String getUltimateCosigneeState() {
			return transferOrder.UC_State__c;
		}
		public String getUltimateCosigneeZIPCode() {
			return transferOrder.UC_Postal_Code__c;
		}
		public List<PackageBox> getPackages() {
			if(lPackages == null) {
				lPackages = populatePackeges();
			}
			return lPackages;
		}
		public Date getSupplierOrderDate() {
			return transferOrder.CreatedDate.date();
		}

		public String getDESADVNumber() {
			//return transferOrder.TransmissionIdentification__c;
			// below is temporary workaround, replace with Order Stage object info
			return transmissionId;
		}
	}

	public virtual class TransferOrderStageWrapper extends TransferOrderWrapper {
		protected Order_Stage__c orderStage;
		public TransferOrderStageWrapper(Order_Stage__c orderStage) {
			super(orderStage.Transfer_Order__r);
			this.transmissionId = orderStage.DESADV_Number__c;
			this.orderStage = orderStage;
		}

		protected virtual override List<PackageBox> populatePackeges() {
			List<PackageBox> retVal = new List<PackageBox>();
			retVal.add(
				new SinglePackageWrapper(orderStage.Shipped_Transfer_Lines__r)
			);
			return retVal;
		}
	}

	public class TransferOrderLineWrapper implements OrderLine {
		private PBSI__Shipped_Tranfer_Line__c shippedLine;
		public TransferOrderLineWrapper(PBSI__Shipped_Tranfer_Line__c line) {
			shippedLine = line;
		}
		public Integer getQuantity() {
			return Integer.valueOf(shippedLine.PBSI__Quantity__c);
		}
		public String getItemNumber() {
			return shippedLine.PBSI__Item__r.Name;
		}
		public String getItemEAN() {
			return shippedLine.PBSI__Item__r.EAN_Number__c;
		}
		public String getLineNo() {
			return shippedLine.PBSI__Transfer_Order_Line__r.Line_Order_Number__c;
		}
		public Boolean hasBuyerReference() {
			return false;
		}
		public String getBuyerReference() {
			return '';
		}
		public String getBuyerRegistry() {
			return '';
		}
	}

	public String invrpt(Id reportId, String recipientGLN) {
		SingleMessageWrapper msgWrap = new SingleMessageWrapper();
		msgWrap.b24Message.invrpt = getInvrptFromReport(reportId);
		msgWrap.b24Message.invrpt.recipient = recipientGLN;
		msgWrap.b24Message.invrpt.buyer = recipientGLN;
		system.debug(msgWrap);
		return JSON.serialize(msgWrap, true);
	}

	private B24MessageWrapper.InventoryReportModel getInvrptFromReport(Id reportId) {
		B24MessageWrapper.InventoryReportModel invrptModel = reportsResults.get(reportId);
		if(invrptModel == null) {
			invrptModel = buildInvrptWrapper(reportId);
		}
		return invrptModel;
	}

	private B24MessageWrapper.InventoryReportModel buildInvrptWrapper(Id reportId) {
		B24MessageWrapper.InventoryReportModel invrptModel = new B24MessageWrapper.InventoryReportModel();
		invrptModel.environment = thisEnvironment;
		invrptModel.sender = '7640146810007';
		invrptModel.recipient = '';
		invrptModel.supplier = '7640146810007';
		invrptModel.buyer = '';
		invrptModel.documentDate = System.today();
		invrptModel.inventoryDate = System.today();
		invrptModel.msgRefNo = '' + reportId + '_' + System.today();
		invrptModel.lines = buildInvrptLinesFromReport(reportId);

		reportsResults.put(reportId, invrptModel);
		return invrptModel;
	}

	private List<B24MessageWrapper.InventoryLineModel> buildInvrptLinesFromReport(Id reportId) {
		List<B24MessageWrapper.InventoryLineModel> lines = new List<B24MessageWrapper.InventoryLineModel>();
		Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
		Reports.Dimension dim = results.getGroupingsDown();
		LocationService locServ = new LocationService();
		for(Reports.GroupingValue groupingVal: dim.getGroupings()) {
			B24MessageWrapper.InventoryLineModel line = new B24MessageWrapper.InventoryLineModel();
			Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(groupingVal.getKey()+'!T');
			System.debug(factDetails);
		    Reports.SummaryValue sumVal = factDetails.getAggregates()[0];

		    Reports.ReportFactWithDetails locationDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(groupingVal.getKey()+'_0!T');
			System.debug(locationDetails);

    		String locationId = String.valueOf(locationDetails.getRows()[0].getDataCells()[1].getValue());
			String locationGLN = locServ.getLocationGLNById(locationId);

			if(locationGLN == null) {
				locationGLN = locServ.getLocationNameById(locationId);
			}

		    line.ean = groupingVal.getGroupings()[0].getLabel();
		    line.itemName = groupingVal.getLabel();
			
			Integer quantity = 0;
			try {
				quantity = Integer.valueOf(sumVal.getLabel());
			} catch(Exception e) {
				//silent
			}
			line.quantity = quantity;
			line.location = locationGLN;
			lines.add(line);
		}

		return lines;
	}

	@testVisible
	private class SingleMessageWrapper {
		public B24MessageWrapper.B24MessageModel b24Message;
		public SingleMessageWrapper() {
			b24Message = new B24MessageWrapper.B24MessageModel();
		}
	}

	public String invoice(Id invObjId, String recipientGLN) {
		c2g__codaInvoice__c invObj = [SELECT Id,Name,c2g__InvoiceDate__c,Sales_order_name__c,Customer_PO__c,c2g__InvoiceTotal__c,c2g__TaxTotal__c,c2g__NetTotal__c,c2g__DueDate__c,
		Terms_of_Invoice__c,Bank_Details__c,Shipping_Amount__c,Sales_Tax__c,
			c2g__Account__r.GLN__c, c2g__InvoiceCurrency__r.Name,Ascent2FF__Sales_Order__r.CreatedDate, Ascent2FF__Sales_Order__r.PBSI__Due_Date__c,
			Ascent2FF__Sales_Order__r.Sales_Order_Type__c, Ascent2FF__Sales_Order__r.PBSI__Customer__r.GLN__c,
			Ascent2FF__Sales_Order__r.PBSI__Delivery_Company__c,
			Ascent2FF__Sales_Order__r.PBSI__Delivery_Streetnew__c,
			Ascent2FF__Sales_Order__r.PBSI__Delivery_Address_line2__c,
			Ascent2FF__Sales_Order__r.PBSI__Delivery_City__c,
			Ascent2FF__Sales_Order__r.PBSI__Delivery_Country__c,
			Ascent2FF__Sales_Order__r.PBSI__Delivery_State__c,
			Ascent2FF__Sales_Order__r.PBSI__Delivery_ATTN_to_Phone__c,
			(SELECT Id,Name,Ascent2FF__Sales_Order_Line__r.PBSI__Item__r.Name,c2g__Quantity__c,
			Ascent2FF__Sales_Order_Line__r.PBSI__Quantity_Needed__c,
			Ascent2FF__Sales_Order_Line__r.PBSI__Item__r.EAN_Number__c,c2g__NetValue__c,c2g__TaxRateTotal__c,c2g__UnitPrice__c,
			c2g__TaxValueTotal__c FROM c2g__InvoiceLineItems__r)
			FROm c2g__codaInvoice__c WHERE Id = :invObjId];
		return invoice(invObj, recipientGLN);
	}

	public String invoice(c2g__codaInvoice__c invObj, String recipientGLN) {
		SingleMessageWrapper msgWrap = new SingleMessageWrapper();
		B24MessageWrapper.InvoiceModel inv = new B24MessageWrapper.InvoiceModel();
		// header start
		inv.environment = thisEnvironment;
		inv.invoiceNumber = invObj.Name;
		inv.invoiceDate = invObj.c2g__InvoiceDate__c;
		inv.sender = new B24MessageWrapper.PartyModel();
		inv.sender.gln = '7640146810007';
		inv.supplier = new B24MessageWrapper.PartyModel();
		inv.supplier.gln = '7640146810007';
		inv.buyer = new B24MessageWrapper.PartyModel();
		inv.buyer.gln = invObj.c2g__Account__r.GLN__c;
		inv.recipient = new B24MessageWrapper.PartyModel();
		inv.recipient.gln = !String.isBlank(recipientGLN) ? recipientGLN : inv.buyer.gln;
		inv.currencyCode = invObj.c2g__InvoiceCurrency__r.Name;
		inv.type = 'Debit';
		inv.deliveryParty = new B24MessageWrapper.PartyModel();
		if(!invObj.Ascent2FF__Sales_Order__r.Sales_Order_Type__c.equalsIgnoreCase('Drop ship') && !String.isBlank(invObj.Ascent2FF__Sales_Order__r.PBSI__Customer__r.GLN__c)) {
			inv.deliveryParty.gln = invObj.Ascent2FF__Sales_Order__r.PBSI__Customer__r.GLN__c;
		} else {
			inv.deliveryParty.name = invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_Company__c;
			inv.deliveryParty.location = new B24MessageWrapper.LocationModel();
			inv.deliveryParty.location.address = invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_Streetnew__c;
			if(!String.isBlank(invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_Address_line2__c)) {
				inv.deliveryParty.location.address += ' '+invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_Address_line2__c;
			}
			inv.deliveryParty.location.city = new B24MessageWrapper.CityModel();
			inv.deliveryParty.location.city.text = invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_City__c;
			inv.deliveryParty.location.country = new B24MessageWrapper.CountryModel();
			inv.deliveryParty.location.country.text = invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_Country__c;
			
			if(!String.isEmpty(invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_State__c)) {
				inv.deliveryParty.location.state = new B24MessageWrapper.CountryModel();
				inv.deliveryParty.location.state.text = invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_State__c;
			}
			inv.deliveryParty.location.telephoneNumber = invObj.Ascent2FF__Sales_Order__r.PBSI__Delivery_ATTN_to_Phone__c;
		}
		// header end

		// properties start
		inv.properties = new List<B24MessageWrapper.PropertyModel>();
		B24MessageWrapper.PropertyModel deliveryDate = new B24MessageWrapper.PropertyModel();
		deliveryDate.name = 'deliveryDate';
		deliveryDate.text = String.valueOf(invObj.Ascent2FF__Sales_Order__r.PBSI__Due_Date__c);
		inv.properties.add(deliveryDate);
		// properties end

		// references start
		inv.documentReferences = new List<B24MessageWrapper.DocumentReferenceModel>();
		B24MessageWrapper.DocumentReferenceModel buyerOrder = new B24MessageWrapper.DocumentReferenceModel();
		if(!String.isBlank(invObj.Customer_PO__c)) {
			buyerOrder.documentType = 'BuyerOrder';
			buyerOrder.id = invObj.Customer_PO__c;
			inv.documentReferences.add(buyerOrder);
		}

		B24MessageWrapper.DocumentReferenceModel supplierOrder = new B24MessageWrapper.DocumentReferenceModel();
		supplierOrder.documentType = 'SupplierOrder';
		supplierOrder.id = invObj.Sales_order_name__c;
		inv.documentReferences.add(supplierOrder);
		// references end

		// charges start
		inv.charges = new List<B24MessageWrapper.ChargeModel>();
		B24MessageWrapper.ChargeModel freight = new B24MessageWrapper.ChargeModel();
		freight.amount = invObj.Shipping_Amount__c;
		freight.code = 'FC';
		freight.name = 'freight charge';
		inv.charges.add(freight);
		// charges end

		// taxes start
		inv.taxes = new List<B24MessageWrapper.TaxModel>();
		B24MessageWrapper.TaxModel vat = new B24MessageWrapper.TaxModel();
		vat.name = 'Value Added Tax';
		vat.code = 'VAT';
		vat.rate = invObj.Sales_Tax__c;
		vat.amount = invObj.c2g__TaxTotal__c;
		inv.taxes.add(vat);
		// taxes end

		// total start
		inv.total = new B24MessageWrapper.InvoiceTotalModel();
		inv.total.grossAmount = invObj.c2g__InvoiceTotal__c;
		inv.total.netAmount = invObj.c2g__NetTotal__c;
		inv.total.taxAmount = invObj.c2g__TaxTotal__c;
		inv.total.netAmountIncTax = 0;
		// total end

		// payment start
		inv.paymentDetails = new B24MessageWrapper.PaymentDetailsModel();
		inv.paymentDetails.dueDate = invObj.c2g__DueDate__c;
		inv.paymentDetails.paymentTerms = invObj.Terms_of_Invoice__c;
		inv.paymentDetails.account = new B24MessageWrapper.BankAccountModel();
		inv.paymentDetails.account.type = 'Bank';
		inv.paymentDetails.account.text = invObj.Bank_Details__c;
		// payment end

		// lines start
		inv.items = new List<B24MessageWrapper.InvoiceItemModel>();
		for(c2g__codaInvoiceLineItem__c line: invObj.c2g__InvoiceLineItems__r) {
			B24MessageWrapper.InvoiceItemModel item = new B24MessageWrapper.InvoiceItemModel();
			item.id = line.Ascent2FF__Sales_Order_Line__r.PBSI__Item__r.Name;
			item.quantity = Integer.valueOf(line.c2g__Quantity__c);
			item.unitOfMeasure = 'PCE';
			item.orderedQuantity = Integer.valueOf(line.Ascent2FF__Sales_Order_Line__r.PBSI__Quantity_Needed__c);
			item.documentReferences = new List<B24MessageWrapper.DocumentReferenceModel>();

			if(!String.isBlank(invObj.Customer_PO__c)) {
				B24MessageWrapper.DocumentReferenceModel poNumber = new B24MessageWrapper.DocumentReferenceModel();
				poNumber.documentType = 'BuyerOrder';
				poNumber.id = invObj.Customer_PO__c;
				item.documentReferences.add(poNumber);
			}
			B24MessageWrapper.DocumentReferenceModel onNumber = new B24MessageWrapper.DocumentReferenceModel();
			onNumber.documentType = 'SupplierOrder';
			onNumber.id = invObj.Sales_order_name__c;
			onNumber.ddate = invObj.Ascent2FF__Sales_Order__r.CreatedDate.date();
			item.documentReferences.add(onNumber);

			item.itemReference = new List<B24MessageWrapper.ItemReferenceModel>();
			B24MessageWrapper.ItemReferenceModel ean13ItemReference = new B24MessageWrapper.ItemReferenceModel();
			ean13ItemReference.registry = 'Supplier';
			ean13ItemReference.coding = 'EAN13';
			ean13ItemReference.text = line.Ascent2FF__Sales_Order_Line__r.PBSI__Item__r.EAN_Number__c;
			item.itemReference.add(ean13ItemReference);

			item.price = new B24MessageWrapper.InvoicePriceModel();
			item.price.currencyCode = invObj.c2g__InvoiceCurrency__r.Name;
			item.price.unitGrossAmount = 
				(line.c2g__UnitPrice__c + 
					(line.c2g__TaxRateTotal__c * line.c2g__UnitPrice__c) / 100).setScale(2, System.RoundingMode.FLOOR);
			
			item.price.unitNetAmount = (line.c2g__UnitPrice__c).setScale(2, System.RoundingMode.FLOOR);
			item.price.grossAmount = (item.price.unitGrossAmount * item.quantity).setScale(2, System.RoundingMode.FLOOR);
			item.price.taxRate = line.c2g__TaxRateTotal__c.setScale(2, System.RoundingMode.FLOOR);
			item.price.taxAmount = line.c2g__TaxValueTotal__c.setScale(2, System.RoundingMode.FLOOR);
			item.price.grossAmountIncTax = (item.price.grossAmount + item.price.taxAmount).setScale(2, System.RoundingMode.FLOOR);
			inv.total.netAmountIncTax += item.price.grossAmount;
			inv.items.add(item);
		}
		// lines end

		msgWrap.b24Message.invoice = inv;
		return JSON.serialize(msgWrap, true);
	}
}