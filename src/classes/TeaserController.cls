public class TeaserController {

    public String Id {
        get;
        set{
            Id = value;
            if (Id != null) {
                TeaserFromId();
            }
        }
    }

    public String type {
        get;
        set{
            type = value;
            if (type != null) {
                TeaserFromType();
            }
        }
    }


    public Teaser_Version__c teaser {get; private set;}
    public Id backgroundImageId {get; private set;}
    public Boolean isRendered {get; private set;}

    public void TeaserFromType() {
        System.debug('Teaser: ' + type);
        isRendered = false;
        try {
			getLanguageTeaser(UserInfo.getLanguage());

			if( teaser == null) {
				getLanguageTeaser('en_US');
			}
            backgroundImageId = [Select Id
                                 From Attachment
                                 Where ParentId = :teaser.Id
                                                  Order By CreatedDate Desc
                                                  Limit 1].Id;

        }
        catch (Exception ex) {
            System.debug(ex);
        }
    }

	private void getLanguageTeaser(String languageCode) {
		try{
            teaser = [Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c
                      From Teaser_Version__c
                      Where
                      Teaser__r.Name = :type
                                       AND Start_Date__c <= :Date.Today() AND Language__c =: languageCode
                                       Order By Start_Date__c Desc
                                       Limit 1
                     ];
            isRendered = true;
		} catch (Exception e) {}
	}


    public void TeaserFromId() {
        try {
            teaser = [Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c
                      From Teaser_Version__c
                      Where
                      Id = :Id
                     ];

            isRendered = true;

            backgroundImageId = [Select Id
                                 From Attachment
                                 Where ParentId = :teaser.Id
                                                  Order By CreatedDate Desc
                                                  Limit 1].Id;
        }
        catch (Exception ex) {
            System.debug(ex);
        }
    }

}