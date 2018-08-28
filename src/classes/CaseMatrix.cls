public without sharing class CaseMatrix implements Matrix {

	private Id caseId;
	private final boolean isB2bMode;
	private final boolean showApparel;
	private final boolean showAccessories;
	private User currentUser;
	private Map<Id, PBSI__PBSI_Item__c> items;

	public CaseMatrix () {
		this.isB2bMode = !'standard'.equalsIgnoreCase(UserInfo.getUserType());
		this.showApparel = !this.isB2bMode || (String.isNotBlank(this.getCurrentUser().Account.Item_category__c) && this.getCurrentUser().Account.Item_category__c.containsIgnoreCase('apparel'));
		this.showAccessories = !this.isB2bMode || (String.isNotBlank(this.getCurrentUser().Account.Item_category__c) && this.getCurrentUser().Account.Item_category__c.containsIgnoreCase('accessories'));
	}

	public CaseMatrix (String caseId) {
		this();
		if(!String.isBlank(caseId)) {
			this.caseId = Id.valueOf(caseId);
		}
	}

	public Map<String, Object> getOptions() {
		Map<String, Object> output = new Map<String, Object>();
		output.put('isB2bMode', isB2bMode);
		output.put('showApparel', showApparel);
		output.put('showAccessories', showAccessories);
		output.put('showCollections', false);
		output.put('hideQuantityIndication', true);
		output.put('returnLoc','/case?id=');
		output.put('cases', true);
		return output;
	}

	public Object getFilterData() {
		List<Collection__c> caseCollections = [SELECT Id, Name, Collection_type__c, (SELECT Id, Item_Group__r.Name, Item_Group__r.PBSI__Parent_Group__r.Name, Item_Group__r.Photo_URL__c, Item_Group__c FROM Collection_Items__r) FROM Collection__c WHERE Collection_type__c = 'Warranty' AND Status__c = 'Active'];
		Map<String, FilterWindowDataBuilder.CollectionOption> collections = new FilterWindowDataBuilder(caseCollections).getCollections();
		collections.get('Warranty').isVisible = false;
		collections.get('Warranty').isSelectedByDefault = true;
		return collections;
	}

	public Object getMatrixData (Map<String, List<String>> input) {
		Id warrantyId = this.getWarrantyCollectionId();
		List<Collection_item__c> allCollItems = [SELECT Id, Fabric_code__c, Item_Group__c, Collection__r.Collection_Type__c FROM Collection_item__c WHERE Collection__c =: warrantyId AND Item_Group__c IN : input.get('itemGroups')];
		MatrixDataBuilder builder = new MatrixDataBuilder(allCollItems);
		if(this.showApparel){
			builder.addItemCategory('Apparel');
		}
		if(this.showAccessories){
			builder.addItemCategory('Accessories');
		}
		builder.populateData();
		this.getDataWithQuantities(builder.getItemMap());
		Map<String, Object> data = new Map<String, Object>();
		data.put('items', builder.getItemList());
		data.put('others', builder.getOtherObjects());
		data.put('sizes', builder.getSizes());
		return data;
	}

	public Map<String, Object> saveMatrixData(String input) {
		MatrixSaveJson data = (MatrixSaveJson) JSON.deserializeStrict(input, MatrixSaveJson.class);
		system.debug('Data to save: ');
		system.debug(data);
		this.initItems(data.lines);
		List<Warranty_Line__c> lines = new List<Warranty_Line__c>();
		if(this.caseId == null) {
			this.caseId = this.createNewCase();
		}
		for(MatrixSaveJson.Line current : data.lines) {
			lines.addAll(this.saveItem(current.itemId, current.newQuantity - current.prevQuantity));
		}
		Map<String, Object> response = new Map<String, Object>();
		response.put('contextId', this.caseId);
		response.put('returnLoc', 'case?id=' + this.caseId);
		response.put('caseId', this.caseId);
		try {
			response.put('success', true);
			insert lines;
		} catch (Exception e) {
			response.put('success', false);
			System.debug(e);
		}
		return response;
	}

	private List<Warranty_Line__c> saveItem(Id item, Integer quantity) {
		List<Warranty_Line__c> output = new List<Warranty_Line__c>();
		Id rt = RecordTypeService.getRecordTypeIdByDeveloperName('Warranty_Line__c', (this.items.get(item).PBSI__Item_Group__r.PBSI__Parent_Group__r.Name == 'shoes') ? 'Shoe' : 'Apparel');
		for(Integer i = 0; i < quantity; i++) {
			output.add(new Warranty_Line__c(Item__c = item, Case__c = this.caseId, RecordTypeId=rt));
		}
		return output;
	}

	private User getCurrentUser() {
		if(this.currentUser == null) {
			this.currentUser = [SELECT Id, ContactId, AccountId, Account.Item_category__c FROM User WHERE Id =: UserInfo.getUserId()];
		}
		return this.currentUser;
	}

	private Id createNewCase() {
		Case c = new Case();
		c.AccountId = this.getCurrentUser().AccountId;
		c.ContactId = this.getCurrentUser().ContactId;
		c.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('case', 'backstage_warranty');
		c.Subject = 'Backstage warranty';
		c.Origin = 'Backstage';
		c.Status = 'New';
		insert c;
		return c.Id;
	}

	@testVisible
	private Id getAccountId() {
		try {
			return this.getCurrentUser().AccountId;
		} catch (Exception e) {
		}
		return null;
	}

	private Map<Id, MatrixDataBuilder.Item> getDataWithQuantities (Map<Id, MatrixDataBuilder.Item> input) {
		Map<Id, MatrixDataBuilder.Item> output = new Map<Id, MatrixDataBuilder.Item>();
		List<Warranty_Line__c> lines = [SELECT Id, Item__c FROM Warranty_Line__c WHERE Case__c =: this.caseId];
		for(Warranty_Line__c current : lines) {
			input.get(current.Item__c).quantity += 1;
			input.get(current.Item__c).minQuantity += 1;
		}
		return output;
	}

	private Id getWarrantyCollectionId() {
		try {
			return [SELECT Id FROM Collection__c WHERE Name = 'Warranty'][0].Id;
		} catch (Exception e) {
		}
		return null;
	}

	private void initItems(List<MatrixSaveJson.Line> l) {
		Set<Id> itemIds = new Set<Id>();
		for(MatrixSaveJson.Line current : l) {
			itemIds.add(current.itemId);
		}
		this.items = new Map<Id, PBSI__PBSI_Item__c>([SELECT Id, PBSI__Item_Group__r.PBSI__Parent_Group__r.Name FROM PBSI__PBSI_Item__c WHERE Id IN: itemIds]);
	}
}