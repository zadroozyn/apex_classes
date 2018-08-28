public class PortalHomePageController extends B2BPortalPageControllerBase {

	public User user {get; set;}
	public String userInitials {get; set;}
	public Account userAccount {get; set;}

	public PortalHomePageController() {
		userAccount = new Account();
		try {
			user = [Select Name, FirstName, LastName, AccountId, Title, Email, Contact.Phone From User Where Id = :UserInfo.getUserId()];
			userInitials = user.FirstName.substring(0, 1) + user.LastName.substring(0, 1);
			userAccount = [Select Id, Name, Owner.Name, B2B_Account_s_Manager_Email__c, B2B_Account_s_Manager_Name__c From Account Where Id = :user.AccountId];
		}
		catch (Exception ex) {
			System.debug(ex);
			ApexPages.addMessages(ex);

		}
	}

	public SalesOrderWrapper[] getLastOrders() {
		List<SalesOrderWrapper> lastOrders = new List<SalesOrderWrapper>();

		for (PBSI__PBSI_Sales_Order__C so:
				[SELECT Name,
				CurrencyIsoCode,
				PBSI__Due_Date__c,
				Total_Shoes_Shipped__c,
				Total_Quantity_To_Ship__c,
				PBSI__Order_Date__c,
				PBSI__Final_Order_Total__c,
				Sales_Order_Type__c,
				PBSI__Stage__c,
				PBSI__Customer_Purchase_Order__c,
				Master_order__r.Id,
				Master_order__r.Name,
				(SELECT Id FROM Attachments WHERE Name LIKE '%order confirmation%' AND ContentType = 'application/pdf' ORDER BY CreatedDate DESC LIMIT 1)
				FROM PBSI__PBSI_Sales_Order__c
				WHERE PBSI__Customer__c = :userAccount.Id
				ORDER BY PBSI__Due_Date__c DESC LIMIT 3
				]){
			lastOrders.add(new SalesOrderWrapper(so));
				}
		return lastOrders;
	}

	public PageReference checkIfGuest() {
		if(UserInfo.getUserType().equals('Guest')){
			return Page.SiteLogin;
		}
		return null;
	}

}