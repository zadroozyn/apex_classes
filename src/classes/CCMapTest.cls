@isTest
public class CCMapTest {
    static testMethod void tstMethod01() {
        PBSI__PBSI_Location__c loc = new PBSI__PBSI_Location__c();
        loc.name = 'Test Location';
        List<CCMapHelper.MapModel> ccmapList = new List<CCMapHelper.MapModel>();
        CCMapHelper.MapModel def = new CCMapHelper.MapModel();
        def.country = 'Default';
        def.countryCode = 'Deffault';
        def.company = 'Provider 1';
        def.companyId = '12345678901';
        def.index = 0;
        def.editFlag = false;
        def.modifiedAt = System.now();
        ccmapList.add(def);
        loc.Country_Company_Map__c = JSON.serialize(ccmapList);
        insert loc;
        
        CCMapHelper.convertToString(def);
        
        List<pw_ccpro__CountryObject__c> ctryList = new List<pw_ccpro__CountryObject__c>();
        List<Tracking_Providers__c> spList = new List<Tracking_Providers__c>();
        for(Integer i=1;i<8;i++) {
        	pw_ccpro__CountryObject__c ctry = new pw_ccpro__CountryObject__c();
            ctry.name = 'Country ' + i;
            ctry.pw_ccpro__IsoCode_2__c = 'A' + i;
            ctry.pw_ccpro__IsoCode_3__c = 'BB' + i;
            ctryList.add(ctry);
            
            Tracking_Providers__c sp = new Tracking_Providers__c();
            sp.Name = 'Provider ' + i;
            //sp.id__c = '1234567890' + i;
            sp.Base_Url__c = 'http://www.google' + i + '.com';
            spList.add(sp);
        }
        insert ctryList;
        insert spList;
        
        PageReference myVfPage = Page.CCMap;
        ApexPages.currentPage().getParameters().put('id', loc.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(loc);
        CCMapExtension mapExt = new CCMapExtension(sc);
        mapExt.getCompanyNames();
        mapExt.getSelectedCountryList();
        
        mapExt.ccList[0]=def;
        
        mapExt.selIndex = 0;
        mapExt.editData();
        mapExt.ccList[0].company = 'Provider 2';
        System.debug(mapExt.ccList);
        mapExt.saveCompany();
        mapExt.saveData();
        
        mapExt.editData();
        mapExt.cancelData();
        
        mapExt.getCompanyNames();
        mapExt.getSelectedCountryList();
        mapExt.newCountry();
        mapExt.selIndex = 1;
        mapExt.ccList[1].country = '--None--';
		mapExt.ccList[1].company = '--None--';
        mapExt.saveAll();
        
        mapExt.ccList[1].country = 'Country 1';
        mapExt.saveCountry();
        mapExt.saveAll();
        
        mapExt.ccList[1].company = 'Provider 1';
        mapExt.saveCompany();
        mapExt.saveAll();
        
        mapExt.delData();
        
        mapExt.newCountry();
        mapExt.addCancel();
        
        CCMapHelper.convertToList('');
        CCMapHelper.convertToMap(JSON.serialize(mapExt.getCCList()));
        CCMapHelper.getCompanyId(CCMapHelper.convertToString(mapExt.ccList), 'default');
    }
}