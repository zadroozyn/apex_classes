public class OrderLineWrapper {

	private PBSI__PBSI_Sales_Order_Line__c line;
    
    public String name {get; set;}
    public String itemDescription {get; set;}
    public Double quantityNeeded {get; set;}
    public Double quantityPacked {get; set;}
    public Double quantityLeftToPack {get; set;}
    public Decimal price {get; set;}
    public Decimal totalPrice {get; set;}

	public Integer type;
	public Integer gender;
	public String itemGroupName;
    
      
    public OrderLineWrapper(PBSI__PBSI_Sales_Order_Line__c sourceLine){
		this.name = sourceLine.PBSI__Item__r.Name;
		this.quantityNeeded = sourceLine.PBSI__Quantity_Needed__c;
		this.quantityPacked = sourceLine.PBSI__Quantity_Picked__c;
		this.quantityLeftToPack = sourceLine.PBSI__Quantity_Left_To_Ship__c;
		this.price = sourceLine.PBSI__Price4__c;
		this.totalPrice = sourceLine.PBSI__Total_Price__c;
		this.type = getType(sourceLine);
		this.gender = getGender(sourceLine);
		this.itemGroupName = sourceLine.PBSI__Item__r.PBSI__Item_Group__r.Name;
		this.itemDescription = sourceLine.PBSI__ItemDescription__c;
    }

	private Integer getType(PBSI__PBSI_Sales_Order_Line__c source) {
		system.debug(source);
		if(source.PBSI__Item__r.PBSI__Item_Group__r.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_group__c', 'Shoes')) {
			return 0;
		} else if(source.PBSI__Item__r.PBSI__Item_Group__r.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_group__c', 'Apparel')) {
			return 1;
		} else if(source.PBSI__Item__r.PBSI__Item_Group__r.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_group__c', 'Accessories')) {
			return 2;
		}
		return -1;
	}

	private Integer getGender(PBSI__PBSI_Sales_Order_Line__c source) {
		if(source.PBSI__Item__r.Size__r.Type__c == '0') {
			return 0;
		} else if(source.PBSI__Item__r.Size__r.Type__c == '1') {
			return 1;
		} else if(source.PBSI__Item__r.Size__r.Type__c == '2') {
			return 2;
		}
		return -1;
	}
}