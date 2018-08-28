/**
 * Class contains utlity methods that are using in many methods.<br>
 * This class is covered by test methods that are using to test methods that use utility methods.
 * 
 * @version 1.0  2014.08.12  Ewa Byra (ewa.byra@nefoscdc.com).
 *                           Initial version of class.
  *
 * @version 1.1  2014.08.20  Ewa Byra (ewa.byra@nefoscdc.com).
 *                           Added toString(Set<Object>) method.
 */
 
public without sharing class Utility {
    
    /**
     * Mapping of country name to three characters country ISO code.<br>
     * Vaues of this map are set based on 'Country ISO Code mapping' custom setting.
     */
    public static final Map<String, String> M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE = Utility.getMapCountryNameToCountryIsoCode();

    public static final String K_N_NOTIFICATION_FIELDS = 'k_n_notification_fields';
    
    /**
     * Method used to gets values for M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE map based on 'Country ISO Code mapping' custom setting records.
     * 
     * @return Map of Contry Name to Country ISO Code.
     */
    private static Map<String, String> getMapCountryNameToCountryIsoCode() {
        Map<String, String> mCountryNameToCountryISOCode = new Map<String, String>();
        
        for (pw_ccpro__CountryObject__c country : [SELECT Name, pw_ccpro__IsoCode_2__c FROM pw_ccpro__CountryObject__c ORDER BY Name]) {
            mCountryNameToCountryISOCode.put(country.Name, country.pw_ccpro__IsoCode_2__c);
        }
        /*
        Map<String, Country_ISO_Code_Mapping__c> mCountryISOCodeMappingRecords = Country_ISO_Code_Mapping__c.getAll();
        
        for (String countryName : mCountryISoCodeMappingRecords.keySet()) {
            mCountryNameToCountryISOCode.put(countryName, mCountryISOCodeMappingRecords.get(countryName).Country_ISO_Code__c);
        }
        */
        
        return mCountryNameToCountryISOCode;
    }

   /**
    *@brief NPE Safe method to search String withing String
    *@param input - input String
    *@param substring - substring searched within input string
    *@return Boolean value indicating whenever substring occurs in input string or not.
    */
    public static Boolean contains(String input, String substring) {
        String base = '' + input;
        String searchedSubstring = '' + substring;
        
        return base.contains(searchedSubstring);
    }
    
}