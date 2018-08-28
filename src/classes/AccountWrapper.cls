public with sharing class AccountWrapper {

	private Account source;
	public Decimal standardDiscount {get {return source.PBSI__Standard_Discount__c;}}
	public String billingCountry {get {return source.BillingCountry;} }
	public AccountWrapper( Account source) {
		this.source = source;
		
	}
}