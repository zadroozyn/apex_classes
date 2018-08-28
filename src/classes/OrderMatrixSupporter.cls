public class OrderMatrixSupporter {

	private static Map<Id, Map<Id, Collection_item__c>> groupXFabricToCollectionItem;
	public static List<Object> getCollectionsNormal(String orderId){
		PBSI__PBSI_Sales_Order__c order = [SELECT Sales_Order_Type__c, PBSI__From_Location__c FROM PBSI__PBSI_Sales_Order__c WHERE Id = :orderId];
		return getCollectionsForOrderType(order.Sales_Order_Type__c, order.PBSI__From_Location__c);
	}

	public static List<Object> getCollectionsAvailability(String accountId){
		Account acc = [SELECT Id, Automatic_location_id__c FROM Account WHERE Id =: accountId];
		return getCollectionsForOrderType('Re-order', acc.Automatic_location_id__c);
	}

	public static List<Object> getAllGroupsNormal(Integer parentGroup, String orderId){
		PBSI__PBSI_Sales_Order__c order = [SELECT Sales_Order_Type__c FROM PBSI__PBSI_Sales_Order__c WHERE Id = :orderId];
		return getAllGroupsForOrderType(order.Sales_Order_Type__c, parentGroup);
	}

	public static List<Object> getAllGroupsAvailability(Integer parentGroup){
		return getAllGroupsForOrderType('Re-order', parentGroup);
	}

	public static List<Object> getAllGroupsTransfer(Integer parentGroup, String orderId){
		String parentGroupString = getParentGroupString(parentGroup);
		List<PBSI__PBSI_Item_Group__c> filteredGroups = [
			SELECT id, Name, (SELECT Id, PBSI__Photo_URL__c FROM R00N60000001WhXDEA0 WHERE PBSI__Photo_URL__c != NULL LIMIT 1) 
				FROM PBSI__PBSI_Item_Group__c 
				WHERE Dont_show_in_OM__c = false
				AND PBSI__Parent_Group__r.PBSI__Item_Group_Code__c =: parentGroupString];
		return convertGroupsToOptionWrapper(filteredGroups);
	}

	public static List<List<Object>> getDataNormal(String orderId, List<OptionWrapper> allGroups, List<OptionWrapper> allCollections){
		final PBSI__PBSI_Sales_Order__c sOrder = [SELECT id, PBSI__From_Location__c, PBSI__Status__c FROM PBSI__PBSI_Sales_Order__c WHERE Id =: orderId];
		Set<PBSI__PBSI_Item__c> items = getItemsBasedOnSelection(allGroups, allCollections);

		Set<Id> filteredSizeIds = new Set<Id>(),
			filteredFabricsIds = new Set<Id>(),
			filteredGroupsIds = new Set<Id>(),
			filteredItemIds = new Set<Id>();
		List<PBSI__PBSI_Item__c> itemsWithSize  = new List<PBSI__PBSI_Item__c>();
		for(PBSI__PBSI_Item__c current : items){
			filteredSizeIds.add(current.Size__C);

			filteredFabricsIds.add(current.Fabric_Code__c);
			filteredGroupsIds.add(current.PBSI__Item_Group__c);
			filteredItemIds.add(current.Id);
			if(current.Size__R.Type__c != null && (current.size__r.Type__c.equals('1') || current.size__r.Type__c.equals('2') || current.size__r.Type__c.equals('0'))){
				itemsWithSize.add(current);
			}
		}

		final List<List<Object>> returnValue = new List<List<Object>>();
		returnValue.add([SELECT Id, Name, PBSI__Item_Group_Code__c FROM PBSI__PBSI_Item_Group__c WHERE Id IN : filteredGroupsIds]);
		returnValue.add([SELECT Id, Name, European_Size__c, MM__c, Type__c, UK_Size__c, US_Men__c, US_Women__c, US_Size__c, JP_Size__c FROM Sizes__c WHERE Id in : filteredSizeIds]);
		returnValue.add([SELECT Id, Name, Fabric_Description__c FROM Fabric__c WHERE Id IN : filteredFabricsIds]);
		returnValue.add(itemsWithSize);
		returnValue.add([SELECT PBSI__Quantity_Needed__c, PBSI__Item__c, PBSI__Item__r.PBSI__Item_Group__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c = : orderId ]);
		returnValue.add(wrapATPList([SELECT id, Current_ATP__c, Item__c, Availability_date__c FROM ATP__c WHERE Item__c IN : filteredItemIds AND Location__c = : sOrder.PBSI__From_Location__c]));
		returnValue.add(getItemMaps(itemsWithSize, groupXFabricToCollectionItem)) ;
		return returnValue;
	}

	public static List<List<Object>> getDataTransfer(String orderId, List<OptionWrapper> allGroups){
		final Set<Id> groupIds = getCheckedOptions(allGroups);
		PBSI__Transfer_Order__c to = [SELECT Id, PBSI__From_Location__c FROM PBSI__Transfer_Order__c WHERE Id =: orderId];

		final List<PBSI__PBSI_Item__c> lItems = [SELECT
			Id, 
			Name, 
			Size__c,
			Size__r.Name,
			Size__r.Type__c, 
			PBSI__Item_Group__c, 
			Fabric_Code__c, 
			Fabric_Description__c, 
			PBSI__description__c, 
			PBSI__Photo_URL__c,
			(SELECT PBSI__Real_Quantity__c FROM PBSI__Item_Inventory__r WHERE PBSI__location_lookup__c =: to.PBSI__From_Location__c)
				FROM PBSI__PBSI_Item__c 
				WHERE Size__c != null 
				AND PBSI__Item_Group__c IN : groupIds];

		final Set<Id> filteredIds = new Set<Id>();
		final List<PBSI__PBSI_Item__c> itemsWithSize  = new List<PBSI__PBSI_Item__c>();
		for(PBSI__PBSI_Item__c current : lItems){
			filteredIds.add(current.Size__C);
			filteredIds.add(current.Fabric_Code__c);
			filteredIds.add(current.PBSI__Item_Group__c);
			filteredIds.add(current.Id);
			if(current.Size__R.Type__c != null && (current.size__r.Type__c.equals('1') || current.size__r.Type__c.equals('2'))){
				itemsWithSize.add(current);
			}
		}
		final List<List<Object>> returnValue = new List<List<Object>>();
		returnValue.add([SELECT Id, Name, PBSI__Item_Group_Code__c FROM PBSI__PBSI_Item_Group__c WHERE Id IN : filteredIds]);
		returnValue.add([SELECT Id, Name, European_Size__c, MM__c, Type__c, UK_Size__c, US_Men__c, US_Women__c, US_Size__c, JP_Size__c FROM Sizes__c WHERE Id in : filteredIds]);
		returnValue.add([SELECT Id, Name, Fabric_Description__c FROM Fabric__c WHERE Id IN : filteredIds]);
		returnValue.add(itemsWithSize);
		returnValue.add([SELECT PBSI__Quantity_Needed__c, PBSI__Quantity_Shipped__c, PBSI__Item__c, PBSI__Item__r.PBSI__Item_Group__c FROM PBSI__Transfer_Order_Line__c WHERE PBSI__Transfer_Order__c = : orderId]);
		return returnValue;
	}

	public static List<List<Object>> getDataAvailability(Id accountId, List<OptionWrapper> allGroups, List<OptionWrapper> allCollections){
		final Account sAccount = [SELECT id, Automatic_location_id__c FROM Account  WHERE Id =: accountId];
		Set<PBSI__PBSI_Item__c> items = getItemsBasedOnSelection(allGroups, allCollections);

		Set<Id> filteredSizeIds = new Set<Id>(),
			filteredFabricsIds = new Set<Id>(),
			filteredGroupsIds = new Set<Id>(),
			filteredItemIds = new Set<Id>();

		List<PBSI__PBSI_Item__c> itemsWithSize  = new List<PBSI__PBSI_Item__c>();

		for(PBSI__PBSI_Item__c current : items){
			filteredSizeIds.add(current.Size__C);
			filteredFabricsIds.add(current.Fabric_Code__c);
			filteredGroupsIds.add(current.PBSI__Item_Group__c);
			filteredItemIds.add(current.Id);
			if(current.Size__R.Type__c != null && (current.size__r.Type__c.equals('1') || current.size__r.Type__c.equals('2') || current.size__r.Type__c.equals('0'))){
				itemsWithSize.add(current);
			}
		}

		final List<List<Object>> returnValue = new List<List<Object>>();
		returnValue.add([SELECT Id, Name, PBSI__Item_Group_Code__c FROM PBSI__PBSI_Item_Group__c WHERE Id IN : filteredGroupsIds]);
		returnValue.add([SELECT Id, Name, European_Size__c, MM__c, Type__c, UK_Size__c, US_Men__c, US_Women__c, US_Size__c, JP_Size__c FROM Sizes__c WHERE Id in : filteredSizeIds]);
		returnValue.add([SELECT Id, Name, Fabric_Description__c FROM Fabric__c WHERE Id IN : filteredFabricsIds]);
		returnValue.add(itemsWithSize);
		returnValue.add(wrapATPList([SELECT id, Current_ATP__c, Item__c, Availability_date__c FROM ATP__c WHERE Item__c IN : filteredItemIds AND Location__c = : sAccount.Automatic_location_id__c]));
		returnValue.add(getItemMaps(itemsWithSize, groupXFabricToCollectionItem));
		return returnValue;
	}

	public static void saveLinesNormal(String orderId, List<MatrixLine> objectsToSave, boolean isLastChunk){
		List<MatrixLine> linesToSave = (List<MatrixLine>) objectsToSave;
		final List<List<sObject>> processedLines = processLines(orderId, linesToSave);
		upsert processedLines[0];
		delete processedLines[1];
		/*Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];*/
		/*PBSI__PBSI_Sales_Order__c order = new PBSI__PBSI_Sales_Order__c(Id = orderId);*/
		/*if(isLastChunk && userProfile.Name.equalsIgnoreCase('B2B Portal User')){*/
		/*order.PBSI__Status__c = 'in progress';*/
		/*update order;*/
		/*}*/
	}

	public static void saveLinesTransfer(String orderId, List<Object> objectsToSave, boolean isLastChunk){
		final List<MatrixLine> linesToSave = (List<MatrixLine>) objectsToSave;
		final List<List<sObject>> processedLines = processLines(orderId, linesToSave);
		upsert processedLines[0];
		delete processedLines[1];
	}


	private static Set<PBSI__PBSI_Item__c> getItemsBasedOnSelection(List<OptionWrapper> groups, List<OptionWrapper> collections) {
		final Set<Id> selectedGroupIds = getCheckedOptions(groups);
		final Set<Id> selectedCollectionIds = getCheckedOptions(collections);
		final Map<String, Collections_order__c> collectionOrder = Collections_order__c.getAll();
		Set<String> sFabricCodesIds = new Set<String>();
		Set<String> sItemGroupsIds = new Set<String>();
		groupXFabricToCollectionItem = new Map<Id, Map<Id, Collection_item__c>>();

		for(Collection_item__c current : [SELECT Id, Fabric_Code__c, Item_group__c, Collection__r.Collection_type__c FROM Collection_item__c WHERE Collection__c IN : selectedCollectionIds]){
			sFabricCodesIds.add(current.Fabric_Code__c);
			if(selectedGroupIds.contains(current.Item_Group__c)){
				sItemGroupsIds.add(current.Item_Group__c);
			}
			if(groupXFabricToCollectionItem.get(current.Item_Group__c) == null) {
				groupXFabricToCollectionItem.put(current.Item_Group__c, new Map<Id, Collection_Item__c>());
				groupXFabricToCollectionItem.get(current.Item_Group__c).put(current.Fabric_Code__c, current);
			} else if (groupXFabricToCollectionItem.get(current.Item_Group__c).get(current.Fabric_code__c) == null
					|| collectionorder.get(groupXFabricToCollectionItem.get(current.Item_Group__c).get(current.Fabric_code__c).Collection__r.Collection_type__c).Collection_number__c > collectionOrder.get(current.Collection__r.Collection_type__c).Collection_number__c
					) 
			{
				groupXFabricToCollectionItem.get(current.Item_Group__c).put(current.Fabric_Code__c, current);
			} 
		}

		Set<PBSI__PBSI_Item__c> items = new Set<PBSI__PBSI_Item__c> ([SELECT  Id, 
			   Name, 
			   Size__c,
			   Size__r.Name,
			   Size__r.Type__c, 
			   PBSI__Item_Group__c, 
			   Fabric_Code__c, 
			   Fabric_Description__c, 
			   PBSI__description__c, 
			   PBSI__salesprice4__c,
			   PBSI__Photo_URL__c,
			   Discontinued__c,
			   PBSI__Quantity_on_Hand__c
				   FROM PBSI__PBSI_Item__c 
				   WHERE Size__c != null 
				   AND Discontinued__c != '2'
				   AND Fabric_Code__c IN : sFabricCodesIds 
				   AND PBSI__Item_Group__c IN : sItemGroupsIds
				   AND PBSI__Item_Group__c IN : selectedGroupIds
		]);

		for(PBSI__PBSI_Item__c current : items){
			if(!selectedGroupIds.contains(current.PBSI__Item_Group__c) || !groupXFabricToCollectionItem.get(current.PBSI__Item_Group__c).containsKey(current.Fabric_code__c)){
				items.remove(current);
			}
		}
		return items;
	}

	private static List<Object> getCollectionsForOrderType(String orderType, Id locId) {
		Map<String, Collections_order__c> mCollectionOrders = Collections_order__c.getAll();
		List<CollectionWrapper> returnValue = new List<CollectionWrapper>();
		Map<String, OM_collection_settings__c> mSettings = getOMColSettingsForOrderType(orderType);
		List<Collection__c> activeCollections = getActiveCollections(locId);
		boolean hasPrimary = false;
		for(Collection__c current : activeCollections) {
			if(mSettings.containsKey(current.Collection_type__c)){
				CollectionWrapper newCollectionObj = new CollectionWrapper (
						current.Name, 
						current.Id, 
						mSettings.get(current.Collection_type__c).Primary__c, 
						mSettings.get(current.Collection_type__c),
						mCollectionOrders.get(current.Collection_type__c).Collection_number__c,
						current.Collection_type__c);
				if(newCollectionObj.checked){
					hasPrimary = true;
				}
				returnValue.add(newCollectionObj);
			}
		}
		if(!hasPrimary){
			for(CollectionWrapper current : returnValue){
				current.checked = mSettings.get(current.collectionType).Secondary__c;
			}
		}
		return returnValue;
	}

	private static List<Object> getAllGroupsForOrderType(String orderType, Integer parentGroup){
		Map<String, OM_collection_settings__c> mSettings = getOMColSettingsForOrderType(orderType);
		String parentGroupString = getParentGroupString(parentGroup);
		List<PBSI__PBSI_Item_Group__c> filteredGroups = [
			SELECT id, Name, (SELECT Id, PBSI__Photo_URL__c FROM R00N60000001WhXDEA0 WHERE PBSI__Photo_URL__c != NULL LIMIT 1) 
				FROM PBSI__PBSI_Item_Group__c 
				WHERE Id IN (SELECT Item_Group__c FROM Collection_item__c WHERE Collection__r.collection_type__c IN : mSettings.keySet() AND collection__r.status__c = 'active')
				AND Dont_show_in_OM__c = false
				AND PBSI__Parent_Group__r.PBSI__Item_Group_Code__c =: parentGroupString];
		return convertGroupsToOptionWrapper(filteredGroups);
	}

	private static List<List<sObject>> processLines(Id orderId, List<MatrixLine> lines) {
		String masterApiName = orderId.getSObjectType().getDescribe().getName();
		String masterName = getMasterFieldName(masterApiName);
		Schema.SObjectType lineType = getLineType(masterApiName);
		List<List<sObject>> returnValue = new List<List<sObject>>();
		returnValue.add((List<SObject>)Type.forName('List<'+lineType+'>').newInstance());
		returnValue.add((List<SObject>)Type.forName('List<'+lineType+'>').newInstance());
		for(MatrixLine current : lines){
			if(Integer.valueOf(current.quantity) > 0){
				for(Integer i = 1; i < current.lineId.size(); i++){
					returnValue[1].add(lineType.newSObject(current.lineId[i]));
				}
				returnValue[0].add(createLineToUpsert(lineType, masterName, orderId, current));
			} else if (Integer.valueOf(current.quantity) == 0 && current.lineId.size() > 0) {
				returnValue[1].add(lineType.newSObject(current.lineId[0]));
			}
		}
		return returnValue;
	}

	private static Schema.SObjectType getLineType(String masterApiName) {
		if(masterApiName == 'PBSI__PBSI_Sales_Order__c') {
			return Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.getSObjectType();
		} else if(masterApiName == 'PBSI__Transfer_Order__c'){
			return Schema.SObjectType.PBSI__Transfer_Order_Line__c.getSObjectType();
		}
		return null;
	}

	private static String getMasterFieldName(String masterApiName) {
		if(masterApiName == 'PBSI__PBSI_Sales_Order__c') {
			return 'PBSI__Sales_Order__c';
		} else if(masterApiName == 'PBSI__Transfer_Order__c'){
			return 'PBSI__Transfer_Order__c';
		}
		return null;
	}

	private static sObject createLineToUpsert(Schema.SObjectType lineType, String masterName, String masterId, MatrixLine line){
		sObject returnValue = lineType.newSObject();
		returnValue.put(masterName, masterId);
		returnValue.put('PBSI__Item__c', line.itemId);
		returnValue.put('PBSI__Quantity_Needed__c', Decimal.valueOf(line.quantity));
		if(line.lineId.size() > 0 ) {
			returnValue.put('Id', line.lineId[0]);
		}
		return returnValue;
	}

	private static boolean checkIfOrderListContainsType(String orderType, String orderTypes){
		for(String current : orderTypes.split(';')){
			if(current.equalsIgnoreCase(orderType)){
				return true;
			}
		}
		return false;
	}

	private static Map<String, OM_collection_settings__c> getOMColSettingsForOrderType(String orderType) {
		Map<String, OM_collection_settings__c> mSettings = new Map<String, OM_collection_settings__c>();

		if(!String.isBlank(orderType)){
			for(OM_collection_settings__c current : OM_collection_settings__c.getAll().values()){
				if(!String.isBlank(current.Sales_orders_types__c) && checkIfOrderListContainsType(orderType, current.Sales_orders_types__c)){
					mSettings.put(current.Collection_type__c, current);
				}
			}
		}

		if(mSettings.isEmpty()){
			for(OM_collection_settings__c current : OM_collection_settings__c.getAll().values()){
				if(current.Sales_orders_types__c == null){
					mSettings.put(current.Collection_type__c, current);
				}
			}
		}
		return mSettings;
	}

	private static List<Collection__c> getActiveCollections(Id locationId) {
		List<Collection__c> output = [SELECT Id, Name, Collection_type__c FROM Collection__C WHERE Status__c = 'Active' AND Location__c =: locationId];
		if(output.isEmpty()) {
			output = [SELECT Id, Name, Collection_type__c FROM Collection__C WHERE Status__c = 'Active' AND Location__c = NULL];
		}
		return output;
	}

	private static Set<Id> getCheckedOptions(List<Object> allGroups) {
		final Set<Id> returnValue = new Set<Id>();
		final List<OptionWrapper> groups = (List<OptionWrapper>) allGroups;
		for(OptionWrapper current : groups) {
			if(current.checked){
				returnValue.add(current.Id);
			}
		}
		if(returnValue.isEmpty()){
			for(OptionWrapper current : groups) {
				returnValue.add(current.Id);
			}
		}
		return returnValue;
	}

	private static String getParentGroupString(Integer parentGroup){
		if(parentGroup == 0){
			return System.label.Item_group_shoes_code;
		} 
		return System.label.Item_group_apparel_code;
	}

	private static List<Object> convertGroupsToOptionWrapper (List<PBSI__PBSI_Item_Group__c> input) {
		List<OrderMatrixSupporter.OptionWrapper> returnValue = new List<OrderMatrixSupporter.OptionWrapper>();
		for(PBSI__PBSI_Item_Group__c current : input){
			returnValue.add(new OptionWrapper(current.Name, current.Id, true, 
						current.R00N60000001WhXDEA0__r.size()>0 ? current.R00N60000001WhXDEA0[0].PBSI__Photo_URL__c : ''));
		}
		return returnValue;
	}

	private static List<ItemMap> getItemMaps (List<PBSI__PBSI_Item__c> items, Map<Id, Map<Id, Collection_item__c>> inputMap) {
		final List<ItemMap> result = new List<ItemMap>();
		final Map<String, Collections_order__c> collectionOrder = Collections_order__c.getAll();

		for(PBSI__PBSI_Item__c current : items){
			result.add(new ItemMap(current.Id, collectionOrder.get(inputMap.get(current.PBSI__Item_Group__c).get(current.Fabric_Code__c).Collection__r.Collection_type__c).Collection_number__c));
		}

		return result;
	}

	private static List<ATPWrapper> wrapATPList (List<ATP__c> source) {
		final List<ATPWrapper> returnValue = new List<ATPWrapper>();
		for(ATP__c current : source) {
			returnValue.add(new ATPWrapper(current));
		}
		return returnValue;
	}

	public virtual class OptionWrapper {
		public boolean checked;
		public String name;
		public String id;
		public String picUrl;

		public OptionWrapper(String name, String id, boolean checked){
			this.name = name;
			this.id = id;
			this.checked = checked;
			this.picUrl = '';
		}

		public OptionWrapper(String name, String id, boolean checked, String picUrl){
			this.name = name;
			this.id = id;
			this.checked = checked;
			this.picUrl = picUrl;
		}
	}

	public class MatrixLine {
		public String itemId;
		public List<String> lineId;
		public String quantity;
		public String price;
	}

	@TestVisible private class CollectionWrapper extends OptionWrapper{
		String  availability1,
				availability2,
				availability3,
				availability0;
		String  collectionNumber;
		String  collectionType;

		public CollectionWrapper(String name, String id, boolean checked, OM_collection_settings__c setting, Decimal collectionNumber, String collectionType) {
			super(name, id, checked);
			this.availability1 = getNumberFromText(setting.More_than_10__c);
			this.availability2 = getNumberFromText(setting.Between_5_and_10__c);
			this.availability3 = getNumberFromText(setting.Less_than_5__c);
			this.collectionNumber = String.valueOf(Integer.valueOf(collectionNumber));
			this.collectionType = collectionType;
		}

		private string getnumberfromtext(string s){
			if(s.equalsignorecase('green')){
				return '0';
			} else if(s.equalsignorecase('orange')){
				return '1';
			} else if(s.equalsignorecase('gray')){
				return '2';
			} else if(s.equalsignorecase('red')){
				return '3';
			}
			return '-1';
		}
	}

	@TestVisible private class ItemMap {
		public Id itemId;
		public String collectionNumber;

		public ItemMap(Id id, Decimal orderNumber){
			this.itemId = Id;
			this.collectionNumber = String.valueOf(Integer.valueOf(orderNumber));
		}
	}

	@TestVisible private class ATPWrapper {
		public String availableOn;
		public Decimal currentAvailability;
		public String item;

		public ATPWrapper (ATP__c source) {
			system.debug(source);
			currentAvailability = source.Current_ATP__c;
			item = source.Item__c;
			try {
				availableOn = source.Availability_date__c.format();
				availableOn = availableOn.replace(String.valueOf(source.Availability_date__c.year()), String.valueOf(source.Availability_date__c.year()).subString(2));
			} catch (SObjectException  e) {
			} catch (NullPointerException e) {
			}
		}
	}
}