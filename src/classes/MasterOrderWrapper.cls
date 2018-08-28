public without sharing class MasterOrderWrapper {

	private final static Integer SHOES = 0;
	private final static Integer APPAREL = 1;
	private final static Integer ACCESSORIES = 2;
	private final static Integer ALL = 0;
	private final static Integer MEN = 1;
	private final static Integer WOMEN = 2;

	public List<SalesOrderWrapper> orders {get; set;}
	public Integer totalShoesM {get; set;}
	public Integer totalShoesW {get; set;}
	public Integer totalApparelM {get; set;}
	public Integer totalApparelW {get; set;}
	public Integer totalAccessories {get; set;}
	public Decimal totalAmount {get; set;}
	public String name {get; set;}
	public Decimal subTotal {get; set;}
	public Decimal shippingTotal {get; set;}
	public Decimal finalTotal {get; set;}
	public Decimal taxTotal {get; set;}
	public Decimal discountTotal {get; set;}
	public Decimal quantityTotal {get; set;}
	public Decimal toShipTotal {get; set;}
	public Decimal shippedTotal {get; set;}
	public Decimal totalPreOrderDiscount {get; set;}
	public Decimal volumeDiscount {get; set;}
	public Decimal earlyBirdDiscount {get; set;}
	public Decimal visibilityDiscount {get; set;}
	public Decimal totalAmountShoes {get; set;}
	public Decimal totalAmountApparel {get; set;}
	public Decimal totalAmountAccessories {get; set;}
	public String status {get; set;}
	public String proposalStatus {get; set;}
	public Id rtId {get; set;}

	public MasterOrderWrapper(Master_order__c mo, List<PBSI__PBSI_Sales_Order__c> oList) {
		orders = getOrders(oList);
		totalShoesM = getTotal(SHOES, MEN);
		totalShoesW = getTotal(SHOES, WOMEN);
		totalApparelM = getTotal(APPAREL, MEN);
		totalApparelW = getTotal(APPAREL, WOMEN);
		totalAccessories = getTotal(ACCESSORIES, ALL);
		totalAmount = getAmount();
		rtId = mo.RecordTypeId;
		proposalStatus = mo.Proposal_status__c;
		name = mo.Name;
		totalPreOrderDiscount = mo.Total_pre_order_discount__c;
		volumeDiscount = mo.Pre_order_discount__c == null ? 0 : mo.Pre_order_discount__c;
		earlyBirdDiscount = mo.Early_bird_discount__c == null ? 0 : mo.Early_bird_discount__c;
		visibilityDiscount = mo.Visibility_discount__c == null ? 0 : mo.Visibility_discount__c;
		status = mo.Status__c;
		subTotal = 0;
		shippingTotal = 0;
		finalTotal = 0;
		taxTotal = 0;
		quantityTotal = 0;
		toShipTotal = 0;
		shippedTotal = 0;
		discountTotal = 0;
		totalAmountShoes = 0;
		totalAmountApparel = 0;
		totalAmountAccessories = 0;
		calcTotals();
	}

	private List<SalesOrderWrapper> getOrders(List<PBSI__PBSI_Sales_Order__c> oList) {
		List<SalesOrderWrapper> output = new List<SalesOrderWrapper>();
		for(PBSI__PBSI_Sales_Order__c current : oList) {
			output.add(new SalesOrderWrapper(current));
		}
		return output;
	}

	private Integer getTotal(Integer type, Integer gender) {
		Integer output = 0;
		for(SalesOrderWrapper order : this.orders) {
			for(OrderLineWrapper cLine : order.lines) {
				if(cLine.type == type && cLine.gender == gender) {
					output += Integer.valueOf(cLine.quantityNeeded);
				}
			}
		}
		return output;
	}

	private Double getAmount() {
		Double output = 0;
		for(SalesOrderWrapper order : this.orders) {
			for(OrderLineWrapper cLine : order.lines) {
				output += cLine.totalPrice;
			}
		}
		return output;
	}

	private void calcTotals() {
		for(SalesOrderWrapper current : orders) {
			subTotal += current.orderTotal == null ? 0 : current.orderTotal;
			shippingTotal += current.shippingCost == null ? 0 : current.shippingCost;
			finalTotal += current.prdeOrderFinalTotal == null ? 0 : current.prdeOrderFinalTotal;
			taxTotal += current.taxAmount == null ? 0 : current.taxAmount;
			quantityTotal += current.totalQuantity == null ? 0 : current.totalQuantity;
			totalAmountShoes += current.getSubtotal(SHOES);
			totalAmountApparel += current.getSubtotal(APPAREL);
			totalAmountAccessories += current.getSubtotal(ACCESSORIES);
		}
		discountTotal = subTotal*totalPreOrderDiscount/100;
	}
}