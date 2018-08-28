public with sharing class SiteTemplateController {

    private Map<String, String> mapPageToName = new Map<String, String>();
    public String pageLabel {get; set;}
    public User currentUser;
    public Boolean blockBackstageWarranty {get; set;}

    public SiteTemplateController() {

        currentUser = [SELECT Id, Contact.Account.Block_backstage_warranty__c FROM User WHERE Id = : UserInfo.getUserId()];
        blockBackstageWarranty = currentUser.Contact.Account.Block_backstage_warranty__c;
        mapPageToName.put(Page.PortalOrders.getUrl(), Label.B2B_Orders);
        mapPageToName.put(Page.OrderMatrix.getUrl(), Label.B2B_Orders);
        mapPageToName.put(Page.B2BInvoicesPayments.getUrl(), Label.B2B_InvoicesPayments);
        mapPageToName.put(Page.B2BProducts.getUrl(), Label.B2B_Products);
        mapPageToName.put(Page.MyProfilePage.getUrl(), Label.B2B_MyProfile);
        mapPageToName.put(Page.ChangePasswordInternal.getUrl(), Label.B2B_MyProfile);
        mapPageToName.put(Page.B2BMarketing.getUrl(), Label.B2B_Marketing);
		mapPageToName.put(Page.Case.getUrl(), Label.B2B_Cases);
		mapPageToName.put(Page.Cases.getUrl(), Label.B2B_Cases);
		mapPageToName.put(Page.CaseComposer.getUrl(), Label.B2B_Cases);
		mapPageToName.put(Page.Dashboard.getUrl(), Label.B2B_Dashboard);

		String key;
		if(ApexPages.currentPage().getUrl().indexOf('?') > 0) {
			key = ApexPages.currentPage().getUrl().left(ApexPages.currentPage().getUrl().indexOf('?'));
		} else {
			key = ApexPages.currentPage().getUrl();
		}
        pageLabel = mapPageToName.get(key.toLowerCase());
    }

    public Boolean hasErrors {
        get{
            return ApexPages.hasMessages();
        }
    }
}