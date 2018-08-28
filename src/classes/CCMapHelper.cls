public class CCMapHelper {
    public class MapModel {
        public Integer index { get; set; }
        public String country { get; set; }
        public String countryCode { get; set; }
        public String company { get; set; }
        public String companyId { get; set; }
        public Boolean editFlag { get; set; }
        public Datetime modifiedAt { get; set; }
    }
    
    public static List<MapModel> convertToList(String inpStr) {
        if(String.isBlank(inpStr)) {
            return new List<MapModel>();
        }
        return (List<MapModel>)JSON.deserialize(inpStr, List<MapModel>.class);    
    }
    
    public static Map<String, String> convertToMap(String inpStr) {
        Map<String, String> ccMap = new Map<String, String>();
        for(MapModel mData: convertToList(inpStr)) {
            ccMap.put(mData.Country, mData.CompanyId);
        }
        return ccMap;
    }
    
    public static String convertToString(List<MapModel> ccMapList) {
        return JSON.serialize(ccMapList);
    }
    
    public static String convertToString(MapModel ccMap) {
        return JSON.serialize(ccMap);
    }
    
    public static String getCompanyId(String inpStr, String country) {
		String company = '';
        for(MapModel mData: convertToList(inpStr)) {
            if(mData.country.equalsIgnoreCase('default') || 
               mData.country.equalsIgnoreCase(country) || 
               mData.countryCode.equalsIgnoreCase(country)) {
                company = mData.companyId;
            }
        }
        return company;
    }
}