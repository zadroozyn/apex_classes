@RestResource(urlMapping='/on/sessionInfo')
global with sharing class SessionInfo {
	@HttpGet
	global static String getSessionId() {
		return Userinfo.getSessionId();
	}
}