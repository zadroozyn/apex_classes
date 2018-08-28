public without sharing class OrderMatrixController {

	private final static Integer MODE_NORMAL = 0, MODE_TRANSFER = 1, MODE_AVAILABILITY = 2, MODE_CASECREATOR = 3;

	public static boolean isB2bmode {
		get { 
			return !'Standard'.equalsIgnoreCase(UserInfo.getUserType());
		}
	}

	public static boolean showApparel {
		get {
			if(!isB2bmode){
				return true;
			}
			try {
				String s = [SELECT Account.Item_category__c FROM User WHERE Id =: UserInfo.getUserId()].Account.Item_category__c;
				if(s.containsIgnoreCase('apparel')) {
					return true;
				}
			} catch (Exception e) { }
			return false;
		}
	}

	@RemoteAction
	public static Integer getOMMode(String orderId){
		final Id oId;
		try{
			oId = orderId;
		} catch (System.StringException e){
			return MODE_AVAILABILITY;
		}
		Schema.SObjectType token = oId.getSObjectType();
		if(token == Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getSObjectType()){
			return MODE_NORMAL;
		}
		if(token == Schema.SObjectType.PBSI__Transfer_Order__c.getSObjectType()){
			return MODE_TRANSFER;
		}
		return MODE_AVAILABILITY;
	}

	@RemoteAction
	public static List<Object> fetchAvailableCollections(String orderId){
		Integer transactionMode = getOMMode(orderId);
		if(transactionMode == MODE_AVAILABILITY){
			return OrderMatrixSupporter.getCollectionsAvailability(orderId);
		} else if(transactionMode == MODE_NORMAL){
			return OrderMatrixSupporter.getCollectionsNormal(orderId);
		} else if(transactionMode == MODE_TRANSFER){
			return null;
		}
		return null;
	}

	@RemoteAction
	public static List<Object> fetchAvailableItemGroups(Integer parentGroup, String orderId){
		Integer transactionMode = getOMMode(orderId);
		if(transactionMode == MODE_AVAILABILITY){
			return OrderMatrixSupporter.getAllGroupsAvailability(parentGroup);
		} else if(transactionMode == MODE_NORMAL) {
			return OrderMatrixSupporter.getAllGroupsNormal(parentGroup, orderId);
		} else if(transactionMode == MODE_TRANSFER) {
			return OrderMatrixSupporter.getAllGroupsTransfer(parentGroup, orderId);
		}
		return null;
	}

	@RemoteAction
	public static List<List<Object>> getOMData(String objectId, List<OrderMatrixSupporter.OptionWrapper> groups, List<OrderMatrixSupporter.OptionWrapper> collections){
		Integer transactionMode = getOMMode(objectId);
		if(transactionMode == MODE_AVAILABILITY){
			return OrderMatrixSupporter.getDataAvailability(objectId, groups, collections);
		} else if(transactionMode == MODE_NORMAL) {
			return OrderMatrixSupporter.getDataNormal(objectId, groups, collections);
		} else if(transactionMode == MODE_TRANSFER) {
			return OrderMatrixSupporter.getDataTransfer(objectId, groups);
		}
		return null;
	}


	@RemoteAction 
	public static List<Apparels_sizes_order__c> getSizesOrder(){
		return Apparels_sizes_order__c.getAll().values();
	}

	@RemoteAction
	public static void saveLines (String orderId, List<OrderMatrixSupporter.MatrixLine> objectsToSave, boolean isLastChunk){
		Integer transactionMode = getOMMode(orderId);
		if(transactionMode == MODE_AVAILABILITY){
			//TODO
		} else if(transactionMode == MODE_NORMAL) {
			OrderMatrixSupporter.saveLinesNormal(orderId, objectsToSave, isLastChunk);
		} else if(transactionMode == MODE_TRANSFER) {
			OrderMatrixSupporter.saveLinesTransfer(orderId, objectsToSave, isLastChunk);
		}
	}
}