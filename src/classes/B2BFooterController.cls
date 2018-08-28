public with sharing class B2BFooterController {

    public String lang {get; set;}

    public B2BFooterController() {
        lang = UserInfo.getLanguage();
    }

    public void changeLanguage() {
        System.debug(lang);
        User u = new User(
            Id = UserInfo.getUserId(),
            LanguageLocaleKey = lang
        );
        update u;
    }

    public String getLanguage() {
        return [Select toLabel(LanguageLocaleKey) from User Where Id = :UserInfo.getUserId()].LanguageLocaleKey;
    }

}