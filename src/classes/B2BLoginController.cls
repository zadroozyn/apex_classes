global with sharing class B2BLoginController {
	public String username {get;set;}
	public String password {get;set;}
	public String lang {get;set;}
    public String oldPassword{get;set;}
    public String newPassword {get; set;}
    public String confirmNewPassword {get; set;} 
	public boolean error {get; set;}

	public B2BLoginController() {
    	lang = ApexPages.currentPage().getHeaders().get('Accept-Language').split(',')[0];
		error = false;
	}

    public PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
		String uname = this.username;
		if(uname.indexOf('@') < 0) {
			uname += '@on-backstage.com';
		}
        PageReference result = Site.login(uname, password, startUrl);
		if(result == null) {
			error = true;
		}
        return result;
    }

    public PageReference forgotPassword() {
		if(String.isBlank(this.username)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Forgot_password_error_message));
			return null;
		}
		String uname = this.username;
		if(uname.indexOf('@') < 0) {
			uname += '@on-backstage.com';
		}
        boolean success = Site.forgotPassword(uname);
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        if (success) {              
            return pr;
        }
        return null;
    }

    public PageReference changePassword() {
        if(String.isEmpty(newPassword) || String.isEmpty(confirmNewPassword)){
            ApexPages.addMessage(new ApexPAges.Message(ApexPages.Severity.ERROR, Label.B2B_emptyPswErrorMsg));
            return null;
        } else {
            return Site.changePassword(newPassword, confirmNewPassword);    
        }
    }   

    public PageReference changePasswordInternal() {
        if(String.isEmpty(oldPassword) || String.isEmpty(newPassword) || String.isEmpty(confirmNewPassword)){
            ApexPages.addMessage(new ApexPAges.Message(ApexPages.Severity.ERROR, Label.B2B_emptyPswErrorMsg));
            return null;
        } else {
            return Site.changePassword(newPassword, confirmNewPassword, oldPassword);
        }
    }

}