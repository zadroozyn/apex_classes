public class CCMapExtension {

    public class DataValidationException extends Exception {}

    private Id locId;
    public String pageTitle { get; set; }
    public Boolean hasLocation { get; set; }
    public Boolean addFlag { get; set; }
    public Boolean hideAddButton { get; set; }
    public Integer selIndex { get; set; }	
    
    public Set<String> selCountries = new Set<String>();
    public String defTrackingCompany { get; set; }
    public List<CCMapHelper.MapModel> ccList = new List<CCMapHelper.MapModel>();
    public Map<String, Tracking_Providers__c> companylist;
    public PBSI__PBSI_Location__c loc;
    public Boolean hasDefaultFlag = false;
    
    public List<CCMapHelper.MapModel> getCCList() {
        return ccList;
    }
    
	public CCMapExtension(ApexPages.StandardController controller) {
        locId = Apexpages.currentPage().getParameters().get('id');
        pageTitle = 'Country Company Mapping for Location ';
        addFlag = false;
        hideAddButton = false;
        if(String.isNotBlank(locId)) {
           	loc = [Select id, Name, Country_Company_Map__c from PBSI__PBSI_Location__c where id=:locId][0];
            pageTitle += loc.Name;
            ccList = CCMapHelper.convertToList(loc.Country_Company_Map__c);
            for(CCMapHelper.MapModel data: ccList) {
                selCountries.add(data.country);
                if(data.country.equalsIgnoreCase('Default')) {
                    hasDefaultFlag = true;
                    defTrackingCompany = data.company;
                }
            }
            hasLocation = true;
        } else {
            hasLocation = false;
        }
    }

    public List<SelectOption> getCompanyNames() {
        List<SelectOption> options = new List<SelectOption>();
        companylist = Tracking_Providers__c.getAll();
        options.add(new SelectOption('--None--','--None--'));
        for (String companyName: companyList.keySet()) {
            if(!companyName.equalsIgnoreCase(defTrackingCompany)) {
            	options.add(new SelectOption(companyName,companyName));    
            }
        }
        return options;
    }
    
    public List<String> getSelectedCountryList() {
        List<String> ctryList = new List<String>();
        
        if(!hasDefaultFlag) {
            ctryList.add('Default');
        }
        
        for(String country : Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.keySet()){
            if(!selCountries.contains(country)) {
                ctryList.add(country);
            }
        }
        
        return ctryList;
    }

    public void newCountry() {
        hideAddButton = true;
        addFlag = true;
        CCMapHelper.MapModel newCCMap = new CCMapHelper.MapModel();
        if(!selCountries.contains('Default')) { newCCMap.country = 'Default'; }
        newCCMap.editFlag = true;
        newCCMap.index = ccList.size();
		ccList.add(newCCMap);
    }
    
    public void saveCountry() {
        CCMapHelper.MapModel selData = ccList[selIndex];
        selData.CountryCode = Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.get(selData.country);
    }

    public void saveCompany() {
        CCMapHelper.MapModel selData = ccList[selIndex];
        selData.CompanyId = selData.Company;
    }
    
    public void editData() {
        hideAddButton = true;
        ccList[selIndex].editFlag = true;
        updateData();
    }
    
    public PageReference delData() {
        if(ccList[selIndex].country == 'Default') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Cannot Delete Default Value'));
        } else {
            for(CCMapHelper.MapModel dat: ccList) {
                if(dat.index > selIndex) { dat.index--; }
            }
            selCountries.remove(ccList[selIndex].country);
            ccList.remove(selIndex);
        	updateData();            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Mapping Deleted Successfully'));
        }
        return null;
    }
    
    public void saveData() {
        try {
            CCMapHelper.MapModel line = ccList[selIndex];
            validateLine(line);
            hideAddButton = false;
            line.editFlag = false;
            line.modifiedAt = System.now();
            if(line.country.equalsIgnoreCase('default')) {
                defTrackingCompany = line.company;
                line.countryCode = 'Default';
            }
            updateData();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Mapping Updated Successfully'));
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        
    }

    private void validateLine(CCMapHelper.MapModel dat) {
        if(String.isBlank(dat.country) || dat.country.equalsIgnoreCase('--None--')) {
            throw new DataValidationException('Please select valid COUNTRY before saving the mapping');
        }
        if(String.isBlank(dat.company) || dat.company.equalsIgnoreCase('--None--')) {
            throw new DataValidationException('Please select valid COMPANY before saving the mapping');
        }
    }
    
    public void saveAll() {
        hideAddButton = false;
        addFlag = false;
        companylist = Tracking_Providers__c.getAll();
        try {
            for(CCMapHelper.MapModel dat: ccList) {
                validateLine(dat);
                if(dat.editFlag) {
                    dat.editFlag = false;
                    Tracking_Providers__c trak = companylist.get(dat.Company);
                    dat.CompanyId = dat.Company;
                    dat.CountryCode = Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.get(dat.country);    
                    dat.modifiedAt = System.now();
                    selCountries.add(dat.country);
                }
            }
            if(addFlag) { addFlag = false; }
            updateData();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Mapping Added Successfully'));
        } catch(Exception e) {
            hideAddbutton = true;
            addFlag = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
    }

    public void updateData() {
		PBSI__PBSI_Location__c updLoc = new PBSI__PBSI_Location__c();
        updLoc.Id = locId;    
        updLoc.Country_Company_Map__c = JSON.serialize(ccList);
        update updLoc;
    }
    
    public void cancelData() {
        hideAddButton = false;
        ccList[selIndex].editFlag = false;
        updateData();
    }
    
    public PageReference addCancel() {
        hideAddButton = false;
        addFlag = false;
        List<CCMapHelper.MapModel> ccOldList = new List<CCMapHelper.MapModel>();
        for(CCMapHelper.MapModel dat: ccList) {
            if(!dat.editFlag && dat.Company != null) {
				ccOldList.add(dat);
            }
        }
        ccList.clear();
        ccList.addAll(ccOldList);
        return null;
    }
}