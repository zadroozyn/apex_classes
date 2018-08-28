public class SalesOrderWrapper {

	private PBSI__PBSI_Sales_Order__c source;

	public Date deliveryDate { get { return source.Delivery_Date__c;}}
	public Date dueDate { get { return source.PBSI__Due_Date__c;} set{ source.PBSI__Due_Date__c = value ;}}
	public Date orderDate { get { return source.PBSI__Order_Date__c;}}
	public Decimal earlyBirdDiscount { get { return source.Early_bird_discount__c; }}
	public Decimal finalOrderTotal { get { return source.PBSI__Final_Order_Total__c;}}
	public Decimal orderTotal { get { return source.PBSI__Order_Total__c;}}
	public Decimal prdeOrderFinalTotal { get { return source.Pre_Order_Final_Order_Total__c;}}
	public Decimal preOrderDiscount { get { return source.Pre_Order_Discount_override__c; }}
	public Decimal salesTax { get { return source.PBSI__Sales_Tax__c;}}
	public Decimal shippingCost { get { return source.PBSI__Shipping_Cost__c;}}
	public Decimal taxAmount { get { return source.VAT_Amount__c;}}
	public Decimal totalQuantity { get { return source.Total_Quantity_Of_Shoes_On_Order__c;}}
	public Decimal totalQuantityToShip { get { return source.Total_Quantity_To_Ship__c;}}
	public Decimal totalShoesShipped { get { return source.Total_Shoes_Shipped__c;}}
	public Decimal visibilityDiscount { get { return source.Visibility_discount__c; }}
	public Id masterId {get; set;}
	public Id orderConfirmation { get { if(source.Attachments.size()>0){return source.Attachments[0].Id;} return null; }}
	public Id sourceId { get { return source.Id;}}
	public List<OrderLineWrapper> lines;
	public Map<String, Object> fields {get; set;}
	public String Status { get { return source.PBSI__Status__c;}}
	public String currencyIsoCode { get { return source.CurrencyIsoCode;}}
	public String customerPaymentTerm { get { return source.PBSI__Customer__r.B2B_On_Payment_Terms__c;}}
	public String customerPurchaseOrder { get { return source.PBSI__Customer_Purchase_Order__c;} set{ source.PBSI__Customer_Purchase_Order__c = value ;}}
	public String deliveryCity {get; set;}
	public String deliveryCountry {get; set;}
	public String deliveryName {get; set;}
	public String deliveryOption {get; set;}
	public String deliveryPO {get; set;}
	public String deliveryStreet {get; set;}
	public String newDeliveryCity {get; set;}
	public String newDeliveryCountry {get; set;}
	public String newDeliveryName {get; set;}
	public String newDeliveryPO {get; set;}
	public String newDeliveryStreet {get; set;}
	public String dueDateString { get { try {return source.PBSI__Due_Date__c.format();} catch (Exception e) {return '';}}}
	public String masterNumber {get; set;}
	public String name { get { return source.Name;}}
	public String orderDateString { get { try {return source.PBSI__Order_Date__c.format();} catch (Exception e) {return '';}}}
	public String orderNumber { get { return source.Name;}}
	public String stage { get { return source.PBSI__Stage__c;}}
	public String trackingNumber1 { get { return source.Tracking_Number_1__c;}}
	public String trackingNumber2 { get { return source.Tracking_Number_2__c;}}
	public String trackingNumber3 { get { return source.Tracking_Number_3__c;}}
	public String type { get { return source.Sales_Order_Type__c;}}
	public boolean hasLines { get { return lines.size() > 0;}}
	public boolean orderConfirmationDisplay { get { return orderConfirmation != NULL; } }

	public Decimal prdeOrderFinalTotalDiscounted {
		get { 
			return source.PBSI__Order_Total__c * ((100 - source.On_Payment_Term__r.Discount_Available__c)/100) + source.PBSI__Shipping_Cost__c;
		}
	}
	public Boolean showDiscountInfo {
		get {
			return source.Show_discount_info__c;
		}
	}

	public List<OrderLineWrapper> getLines(){
		return lines;
	}

	public SalesOrderWrapper (PBSI__PBSI_Sales_Order__c source) {
		lines = new List<OrderLineWrapper>(); 
		this.source = source; 
		fields = source.getPopulatedFieldsAsMap();
		this.deliveryName = (String)fields.get('PBSI__Delivery_Company__c');
		this.deliveryStreet = (String)fields.get('PBSI__Delivery_Streetnew__c');
		this.deliveryCity = (String)fields.get('PBSI__Delivery_City__c');
		this.deliveryPO = (String)fields.get('PBSI__Delivery_Postal_Code__c');
		this.deliveryCountry = this.newDeliveryCountry = (String)fields.get('PBSI__Delivery_Country__c');
		if((String)fields.get('PBSI__Delivery_Country__c') == 'United States'){
			this.newDeliveryName = this.deliveryName;
			this.newDeliveryStreet = this.deliveryStreet;
			this.newDeliveryCity = this.deliveryCity ;
			this.newDeliveryPO = this.deliveryPO;
		}

		if(fields.containsKey('Shipping_Options__c')) {
			this.deliveryOption = (String)fields.get('Shipping_Options__c');
		} else {
			this.deliveryOption = '01';
		}

		if(this.source.Master_order__r != null && String.isNotBlank(this.source.Master_order__r.Id) && String.isNotBlank(this.source.Master_order__r.Name)) {
			this.masterId = this.source.Master_order__r.Id;
			this.masterNumber = this.source.Master_order__r.Name;
		}
		for (PBSI__PBSI_Sales_Order_Line__c line: source.PBSI__Sales_Order_Lines__r){
			this.lines.add(new OrderLineWrapper(line));
		}
	}

	public boolean hasAddressChanged() {
		return (this.deliveryName != this.newDeliveryName && String.isNotBlank(this.newDeliveryName)) || (this.deliveryStreet != this.newDeliveryStreet && String.isNotBlank(this.newDeliveryStreet)) || (this.deliveryCity != this.newDeliveryCity && String.isNotBlank(this.newDeliveryCity)) || (this.deliveryPO != this.newDeliveryPO && String.isNotBlank(this.newDeliveryPO)) || (this.deliveryCountry != this.newDeliveryCountry && String.isNotBlank(this.newDeliveryCountry));
	}

	public Decimal getSubtotal(Integer type) {
		Decimal output = 0;
		for(OrderLineWrapper current : lines) {
			if(current.type == type) {
				output += current.totalPrice == null ? 0 : current.totalPrice ;
			}
		}
		return output;
	}
}