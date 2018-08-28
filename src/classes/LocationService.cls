public class LocationService {
	
	private static Boolean loaded = false;
	private static Map<Id, String> mapId2GLN;
	private static Map<String, Id> mapGLN2Id;
	private static Map<String, String> mapGLN2Name;
	private static Map<Id, String> mapId2Name;


	public LocationService() {
		if(!loaded) {
			loadData();
		}
		loaded = true;
	}

	private void loadData() {
		List<PBSI__PBSI_Location__c> lLocations = [Select Id,Gln__c,Name FROM PBSI__PBSI_Location__c];
		mapId2GLN = new Map<Id, String>();
		mapGLN2Id = new Map<String, Id>();
		mapGLN2Name = new Map<String, String>();
		mapId2Name = new Map<Id, String>();
	
		for(PBSI__PBSI_Location__c loc: lLocations) {
			if(loc.Gln__c != null) {
				mapId2GLN.put(loc.Id, loc.Gln__c);
				mapGLN2Id.put(loc.Gln__c, loc.Id);
				mapGLN2Name.put(loc.Gln__c, loc.Name);
			}
			mapId2Name.put(loc.Id, loc.Name);
		}
	}

	public Id getLocationIdByGLN(String gln) {
		return mapGLN2Id.get(gln);
	}

	public String getLocationGLNById(Id locId) {
		return mapId2GLN.get(locId);
	}

	public String getLocationNameByGLN(String gln) {
		return mapGLN2Name.get(gln);
	}

	public String getLocationNameById(Id locId) {
		return mapId2Name.get(locId);
	}

}