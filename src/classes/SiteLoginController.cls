/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
	global String error {get; set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
		if(username.indexOf('@') < 0) {
			username += '@on-backstage.com';
		}
        PageReference output = Site.login(username, password, startUrl);
		System.debug(output);
		system.debug('test login');
		return output;
    }
    
   	global SiteLoginController () {}
}