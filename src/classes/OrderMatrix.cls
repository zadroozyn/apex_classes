public without sharing class OrderMatrix implements Matrix {

	private final Id orderId;
	private final String dateFormatString;
	private boolean isB2bMode;
	private boolean showApparel;
	private boolean showAccessories;
	private PBSI__PBSI_Sales_Order__c order;
	private List<PBSI__PBSI_Sales_Order__c> orders;
	private Master_order__c master;
	private Id locId;
	private String orderType;

	public OrderMatrix(String orderId) {
		this.orderId = orderId;
		this.isB2bMode = !'standard'.equalsIgnoreCase(UserInfo.getUserType());
		dateFormatString = DateFormat.getDateFormatForCurrentUser();

		if(PBSI__PBSI_Sales_Order__c.sObjectType == this.orderId.getSObjectType()) {
			this.orders = [SELECT Id, Master_order__c, Sales_Order_type__c, PBSI__From_Location__c, PBSI__Due_date__c, PBSI__Customer__r.Item_category__c, (SELECT Id, PBSI__Quantity_Needed__c, PBSI__Quantity_Picked__c, PBSI__Item__c FROM PBSI__Sales_Order_Lines__r) FROM PBSI__PBSI_Sales_Order__c WHERE Id =: this.orderId];
			this.order = this.orders[0];
			this.orderType = this.order.Sales_Order_type__c;
			this.locId = this.order.PBSI__From_Location__c;
			this.showApparel = !this.isB2bMode || (String.isNotBlank(this.order.PBSI__Customer__r.Item_category__c) && this.order.PBSI__Customer__r.Item_category__c.containsIgnoreCase('apparel'));
			this.showAccessories = !this.isB2bMode || (String.isNotBlank(this.order.PBSI__Customer__r.Item_category__c) && this.order.PBSI__Customer__r.Item_category__c.containsIgnoreCase('accessories'));
		}

		if(Master_order__c.sObjectType == this.orderId.getSObjectType()) {
			setupMasterOrder(this.orderId);
		}
		if(String.isNotBlank(this.order.Master_order__c)){
			setupMasterOrder(this.order.Master_order__c);
		}
	}

	private void setupMasterOrder(Id moId) {
		this.master = [SELECT Id, RecordTypeId, From_location__c, Customer_contact__c, Pre_order_discount__c, Visibility_discount__c, Early_bird_discount__c, Customer__r.Item_category__c FROM Master_order__c WHERE Id =: moId];
		this.orders = [SELECT Id, Sales_Order_type__c, PBSI__From_Location__c, PBSI__Due_date__c, (SELECT Id, PBSI__Quantity_Needed__c, PBSI__Quantity_Picked__c, PBSI__Item__c FROM PBSI__Sales_Order_Lines__r) FROM PBSI__PBSI_Sales_Order__c WHERE Master_order__c =: moId ORDER BY PBSI__Due_date__c ASC];
		this.orderType = 'Pre-Order';
		this.locId = this.master.From_location__c;
		this.showApparel = !this.isB2bMode || (String.isNotBlank(this.master.Customer__r.Item_category__c) && this.master.Customer__r.Item_category__c.containsIgnoreCase('apparel'));
		this.showAccessories = !this.isB2bMode || (String.isNotBlank(this.master.Customer__r.Item_category__c) && this.master.Customer__r.Item_category__c.containsIgnoreCase('accessories'));
	}

	public Map<String, Object> getOptions() {
		Map<String, Object> output = new Map<String, Object>();
		output.put('isB2bMode', isB2bMode);
		output.put('showApparel', showApparel);
		output.put('showAccessories', showAccessories);
		output.put('showCollections', true);
		output.put('master', this.master != null);
		output.put('dateFormat', dateFormatString);
		output.put('startDate', Date.today().addDays(Integer.valueOf(B2B_Portal_New_Order_Date_Intervals__c.getInstance('Pre-Order').Min_days_in_the_future__c)).format());
		output.put('returnLoc', isB2bMode ? 'portalorders?orderId=' + this.orderId : '/'+this.orderId);
		return output;
	}

	public Object getFilterData() {
		List<Collection__c> locCollections = new List<Collection__c>();
		List<Collection__c> nolocCollections = new List<Collection__c>();
		for(Collection__c current : [SELECT Id, Name, Collection_type__c, Location__c, (SELECT Id, Item_Group__r.Name, Item_Group__r.PBSI__Parent_Group__r.Name, Item_Group__r.Photo_URL__c, Item_Group__c FROM Collection_Items__r) FROM Collection__c WHERE Collection_type__c IN : new MatrixCollectionService().getCollectionTypes(this.orderType) AND Status__c = 'Active']) {
			if(current.Location__c == null) {
				nolocCollections.add(current);
			} else if(current.Location__c == this.order.PBSI__From_Location__c) {
				locCollections.add(current);
			}
		}
		Map<String, FilterWindowDataBuilder.CollectionOption> collections = new FilterWindowDataBuilder(locCollections.isEmpty() ? nolocCollections : locCollections, this.orderType).getCollections();
		return collections;
	}

	public Object getMatrixData(Map<String, List<String>> input) {
		List<Collection_item__c> allCollItems = [SELECT Id, Fabric_code__c, Item_Group__c, Collection__r.Collection_Type__c FROM Collection_item__c WHERE Collection__c =: input.get('collections') AND Item_Group__c IN : input.get('itemGroups')];
		List<Collection_item__c> alleCollItems = [SELECT Id, Fabric_code__c, Item_Group__c, Collection__r.Collection_Type__c FROM Collection_item__c WHERE Collection__c =: input.get('collections') ];
		Set<Id> items = new Set<Id>();
		system.debug(this.orders);
		for(PBSI__PBSI_Sales_Order__c cOrder : this.orders) {
			for(PBSI__PBSI_Sales_Order_Line__c current : cOrder.PBSI__Sales_Order_Lines__r) {
				items.add(current.PBSI__Item__c);
			}
		}
		MatrixDataBuilder builder;
		if(items.isEmpty()) {
			builder = new MatrixDataBuilder(allCollItems, this.locId);
		} else {
			builder = new MatrixDataBuilder(allCollItems, this.locId, items);
		}
		if(this.showApparel){
			builder.addItemCategory('Apparel');
		}
		if(this.showAccessories){
			builder.addItemCategory('Accessories');
		}
		builder.populateData();
		new MatrixCollectionService().getIndicatorForItem(builder.getItemMap(), alleCollItems, this.orderType);
		Map<String, Object> data = new Map<String, Object>();
		data.put('items', builder.getItemList());
		data.put('others', builder.getOtherObjects());
		data.put('sizes', builder.getSizes());
		data.put('headers', this.getOrderData());
		return data;
	}

	private Map<String, Id> processHeaders(List<MatrixSaveJson.Header> source) {
		Map<String, PBSI__PBSI_Sales_Order__c> pId2so = new Map<String, PBSI__PBSI_Sales_Order__c>();
		Map<String, Id> pId2sId = new Map<String, Id>();
		for(MatrixSaveJson.Header current : source) {
			PBSI__PBSI_Sales_Order__c temp = new PBSI__PBSI_Sales_Order__c();
			temp.Sales_order_type__c = 'Pre-Order';
			temp.PBSI__Due_date__c = DateFormat.getDateFromString(current.shipDate, this.dateFormatString);
			temp.PBSI__Customer__c = this.master.Customer__c;
			temp.PBSI__Contact__c = this.master.Customer_contact__c;
			temp.PBSI__From_Location__c = this.master.From_Location__c;
			temp.Master_order__c = this.master.Id;
			temp.Pre_Order_Discount_New__c = this.master.Pre_order_discount__c;
			temp.Early_bird_discount__c = this.master.Early_bird_discount__c;
			temp.Visibility_discount__c = this.master.Visibility_discount__c;
			if(this.master.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal')) {
				temp.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_order__c', 'Proposal');
			} else {
				temp.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_order__c', 'B2B_portal');
			}
			if(String.isNotBlank(current.headId)) {
				temp.Id = current.headId;
			}
			pId2so.put(current.pageId, temp);
		}
		upsert pId2so.values();
		for(String key : pId2so.keySet()) {
			pId2sId.put(key, pId2so.get(key).Id);
		}
		return pId2sId;
	}
	private boolean processLines(List<MatrixSaveJson.Line> source) {
		List<PBSI__PBSI_Sales_Order_Line__c> lines = new List<PBSI__PBSI_Sales_Order_Line__c>();
		List<PBSI__PBSI_Sales_Order_Line__c> toDelete = new List<PBSI__PBSI_Sales_Order_Line__c>();
		for(MatrixSaveJson.Line current : source) {
			PBSI__PBSI_Sales_Order_Line__c temp = new PBSI__PBSI_Sales_Order_Line__c();
			temp.PBSI__Sales_Order__c = current.headId;
			temp.PBSI__Item__c = current.itemId;
			temp.PBSI__Quantity_Needed__c = Decimal.valueOf(current.newQuantity);
			if(!(current.existingId == null || current.existingId.isEmpty())) {
				List<Id> oldlines = current.existingId;
				temp.Id = oldlines.get(0);
				for(Integer i = 1; i < oldlines.size(); i++) {
					toDelete.add(new PBSI__PBSI_Sales_Order_Line__c(Id = oldlines.get(i)));
				}
			}
			if(temp.PBSI__Quantity_Needed__c > 0) {
				lines.add(temp);
			} else {
				toDelete.add(temp);
			}
		}
		try {
			if(!lines.isEmpty())
				upsert lines;
			if(!toDelete.isEmpty())
				delete toDelete;
			return true;
		} catch (Exception e) {
			System.debug(e);
		}
		return false;
	}

	public Map<String, Object> saveMatrixData(String input) {
		MatrixSaveJson data = (MatrixSaveJson) JSON.deserialize(input, MatrixSaveJson.class);
		Map<String, Id> pId2sId;
		boolean resp = true;
		try {
			if(data.headers != null && this.master != null) {
				pId2sId = processHeaders(data.headers);
			}
			system.debug('debug');
			system.debug(data);
			if(data.lines != null) {
				resp = processLines(data.lines);
			}
		} catch (Exception e) {
			system.debug(e);
			resp = false;
		}

		Map<String, Object> response = new Map<String, Object>();
		response.put('contextId', this.orderId);
		response.put('success', resp);
		if(pId2sId != null) {
			response.put('idmap', pid2sId);
		}
		return response;
	}

	private MatrixSaveJson getOrderData() {
		MatrixSaveJson output = new MatrixSaveJson();
		output.headers = new List<MatrixSaveJson.Header>();
		for(PBSI__PBSI_Sales_Order__c cOrder : this.orders) {
			output.headers.add(createHeader(cOrder));
		}
		return output;
	}

	private MatrixSaveJson.Header createHeader(PBSI__PBSI_Sales_Order__c source) {
		MatrixSaveJson.Header output = new MatrixSaveJson.Header();
		output.headId = source.Id;
		output.lines = new Map<Id, MatrixSaveJson.Line>();
		output.shipDate = DateFormat.getStringFromDate(source.PBSI__Due_date__c, this.dateFormatString);
		for(PBSI__PBSI_Sales_Order_Line__c current : source.PBSI__Sales_Order_Lines__r) {
			if(output.lines.containsKey(current.PBSI__Item__c)) {
				addLine(output.lines.get(current.PBSI__Item__c), current);
			} else {
				output.lines.put(current.PBSI__Item__c, createLine(current, source.Id));
			}
		}
		return output;
	}

	private MatrixSaveJson.Line createLine(PBSI__PBSI_Sales_Order_Line__c source, Id headId) {
		MatrixSaveJson.Line output = new MatrixSaveJson.Line();
		output.existingId = new List<Id>();
		output.prevQuantity = 0;
		output.newQuantity = 0;
		output.packedQuantity = 0;
		output.headId = headId;
		output.itemId = source.PBSI__Item__c;
		return addLine(output, source);
	}

	private MatrixSaveJson.Line addLine(MatrixSaveJson.Line input, PBSI__PBSI_Sales_Order_Line__c source) {
		input.existingId.add(source.Id);
		input.prevQuantity += Integer.valueOf(source.PBSI__Quantity_Needed__c);
		input.newQuantity += Integer.valueOf(source.PBSI__Quantity_Needed__c);
		input.packedQuantity += Integer.valueOf(source.PBSI__Quantity_Picked__c);
		return input;
	}

}