global without sharing class OrganizationService {

	private static OrganizationService instance;

	private Organization org;

	public Id organizationId {
		public get {
			return org.Id;
		}
		private set {}
	}

	public boolean isSandbox {
		public get {
			return org.IsSandbox;
		}
		private set {}
	}

	private OrganizationService () {
		this.org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
	}

	global static OrganizationService getInstance() {
		if(instance == null) {
			OrganizationService.instance = new OrganizationService();
		}
		return instance;
	}
	 
}