public with sharing class PortalCasesController {
	/*final private User currentUser;*/
	/*final public List<Case> cases {public get; private set;}*/
	/*public PortalDateWrapper filterOpenedStart {public get; public set;}*/
	/*public PortalDateWrapper filterOpenedEnd {public get; public set;}*/
	/*public String dateFormatString;*/

	public BackstageService bss { get; private set;}

	public PortalCasesController () {
		if(!String.isBlank(ApexPages.currentPage().getParameters().get('userId'))) {
			bss = new BackstageService(ApexPages.currentPage().getParameters().get('userId'));
		} else {
			bss = new BackstageService();
		}

		/*filterOpenedStart = new PortalDateWrapper(Date.newInstance(Date.today().addYears(-1).year(), Date.today().month(), 1), dateFormatString);*/
		/*filterOpenedEnd = new PortalDateWrapper(Date.today(), dateFormatString);*/
	}

}