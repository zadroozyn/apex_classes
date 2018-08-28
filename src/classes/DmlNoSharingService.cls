public without sharing class DmlNoSharingService {
	private class NullArgumetException extends Exception {}
	private List<sObject> baseList;

	public DmlNoSharingService(List<sObject> lSObjects) {
		if(lSObjects == null) {
			throw new NullArgumetException('DmlNoSharingService: List can\'t be null');
		}
		baseList = lSObjects;
	}

	public DmlNoSharingService(sObject sObj) {
		this(new List<sObject>{sObj});
	}

	public void doInsert() {
		Database.insert(baseList);
	}

	public void doUpdate() {
		Database.update(baseList);
	}

	public void doUpsert() {
		Database.upsert(baseList);
	}
}