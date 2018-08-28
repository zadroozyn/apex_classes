@isTest
private class TeaserControllerTest {

	@testSetup
	static void initData() {
		Teaser__c teaser = new Teaser__c(
		    Name = 'Test Page'
		);
		insert teaser;

		Teaser_Version__c teaserVersionOld = new Teaser_Version__c(
		    Start_Date__c = Date.today() - 10,
		    Target_URL__c = 'https://testurl.com',
		    Teaser__c = teaser.Id,
		    Title__c = 'Home Page',
		    Subtitle__C = 'Test Teaser subtitle',
			Language__c = 'en_US'
		);
		insert teaserVersionOld;


		Teaser_Version__c teaserVersionNew = new Teaser_Version__c(
		    Start_Date__c = Date.today() - 1,
		    Target_URL__c = 'https://testurl.com',
		    Teaser__c = teaser.Id,
		    Title__c = 'Test Teaser',
		    Subtitle__C = 'Test Teaser subtitle',
			Language__c = 'en_US'
		);
		insert teaserVersionNew;

		Attachment backgroundImage = new Attachment(
		    Name = 'Test Background attachment',
		    Body = Blob.valueOf('Image content'),
		    IsPrivate = false,
		    ParentId = teaserVersionNew.Id
		);
		insert backgroundImage;
	}


	@isTest
	static void teaserIsFoundByPageName() {
		System.debug([Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c From Teaser_Version__c]);
		Teaser_Version__c teaser = [Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c
		                            From Teaser_Version__c
		                            Where
		                            Start_Date__c <= :Date.Today()
		                            Order By Start_Date__c Desc
		                            Limit 1];

		Attachment backgroundImage = [Select ID From Attachment Where ParentId = :teaser.Id];


		TeaserController ctrl = new TeaserController();
		ctrl.type = 'Test Page';
		System.assertEquals(teaser.Id, ctrl.teaser.Id);
		System.assertEquals(backgroundImage.Id, ctrl.backgroundImageId);
		System.assertEquals(true, ctrl.isRendered);
	}

	@isTest
	static void teaserIsFoundById() {
		System.debug([Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c From Teaser_Version__c]);

		Teaser_Version__c teaser = [Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c
		                            From Teaser_Version__c
		                            Where
		                            Start_Date__c <= :Date.Today()
		                            Order By Start_Date__c Desc
		                            Limit 1];

		Attachment backgroundImage = [Select ID From Attachment Where ParentId = :teaser.Id];

		TeaserController ctrl = new TeaserController();
		ctrl.Id = teaser.Id;
		System.assertEquals(teaser.Id, ctrl.teaser.Id);
		System.assertEquals(backgroundImage.Id, ctrl.backgroundImageId);
		System.assertEquals(true, ctrl.isRendered);
	}

	@isTest
	static void dontRenderWhenTeaserWasntFound() {
		System.debug([Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c From Teaser_Version__c]);

		Teaser_Version__c teaser = [Select Id, Title__c, Subtitle__c, Target_URL__c, Start_Date__c
		                            From Teaser_Version__c
		                            Where
		                            Start_Date__c <= :Date.Today()
		                            Order By Start_Date__c Desc
		                            Limit 1];

		Attachment backgroundImage = [Select ID From Attachment Where ParentId = :teaser.Id];

		TeaserController ctrl = new TeaserController();
		ctrl.type = 'Test Inexisting Page';

		System.assertEquals(null, ctrl.teaser);
		System.assertEquals(null, ctrl.backgroundImageId);
		System.assertEquals(false, ctrl.isRendered);

	}
}