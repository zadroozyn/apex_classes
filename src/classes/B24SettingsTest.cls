@isTest
private class B24SettingsTest {
	
	@isTest static void createEmpty() {
		B24Settings b24set = new B24Settings();
		b24set.save();
		b24set.cancel();
		List<B24_Settings__c> lb24Settings = [SELECT Id,Desadv__c,Invrpt_Out__c FROM B24_Settings__c];
		System.assertEquals(1, lb24Settings.size());
		System.assert(!String.isBlank(lb24Settings[0].Desadv__c));
		System.assert(!String.isBlank(lb24Settings[0].Invrpt_Out__c));
	}
	
	@isTest static void desadvTO() {
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('TO test', 'CHF', true);
		tdf.locations.createSObject('EU-Stock', true);
		tdf.locations.createSObject('Special-Stock', true);

		B24Settings b24set = new B24Settings();
		b24set.addDesadv(tdf.locations.getSObject('EU-Stock').Id, tdf.locations.getSObject('Special-Stock').Id, tdf.accounts.getSObject('TO test').Id);
		b24set.save();

		PBSI__Transfer_Order__c to = new PBSI__Transfer_Order__c(
			PBSI__From_Location__c = tdf.locations.getSObject('EU-Stock').Id,
			PBSI__To_Location__c = tdf.locations.getSObject('Special-Stock').Id
		);
		B24Settings b24set2 = new B24Settings();
		System.assert(b24set2.desadvInfoExist(to));
		List<B24Settings.DesadvModel> lDesadv = b24set2.getDeasadvLines();
		b24set2.removeDesadv(lDesadv[0].lineId);
		System.assert(!b24set2.desadvInfoExist(to));
		b24set2.cancel();

		B24Settings b24set3 = new B24Settings();
		System.assert(b24set3.desadvInfoExist(to));
		lDesadv = b24set3.getDeasadvLines();
		b24set3.removeDesadv(lDesadv[0].lineId);
		b24set3.save();

		B24Settings b24set4 = new B24Settings();
		System.assert(!b24set4.desadvInfoExist(to));
	}

	@isTest static void invrptOut() {
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('TO test', 'CHF', true);

		B24Settings b24set = new B24Settings();
		Id reportId = (Id) '00OD0000005s9bg';
		b24set.addInvrpt(tdf.accounts.getSObject('TO test').Id, reportId);
		b24set.save();
		List<B24Settings.InvrptOutModel> lInvOut = b24set.getInvrptOutLines();
		System.assertEquals(1, lInvOut.size());
	}
	
}