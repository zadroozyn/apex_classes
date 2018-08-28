public with sharing class DashboardController {
	transient private User backstageUser;
	transient private LookerUrlGenerator looker;

	public DashboardController() {
		this.backstageUser = [SELECT Id, AccountId, Firstname, Lastname FROM User WHERE Id =: Userinfo.getUserId()];
		List<String> models = new List<String>{'backstage'};
		List<String> permissions = new List<String>{'access_data', 'see_looks', 'see_user_dashboards'};
		Map<String, String> attributes = new Map<String, String>{'sf_account_id' => backstageUser.AccountId};
		LookerUrlGenerator.LookerUser lUser = new LookerUrlGenerator.LookerUser(backstageUser.Id, '', new List<Integer>{17}, backstageUser.Firstname, backstageUser.Lastname, models, permissions, attributes, new Map<String, String>());
		this.looker = new LookerUrlGenerator('/embed/dashboards/70', lUser);
	}

	public String getLookerUrl() {
		return this.looker.generateUrl();
	}
}