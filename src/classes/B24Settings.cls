public without sharing class B24Settings {
	
	private B24_Settings__c settingObj;
	private SettingDefinition allSettings;
	public class B24SettingsException extends Exception {}
	
	public B24Settings() {
		loadSettings();
	}

	public void save() {
		settingObj.Desadv__c = JSON.serialize(allSettings.mapDesadv);
		settingObj.Invrpt_Out__c = JSON.serialize(allSettings.mapInvrptOut);
		upsert settingObj;
	}

	public void cancel() {
		loadFromDB();
	}

	public List<DesadvModel> getDeasadvLines() {
		return allSettings.mapDesadv.values();
	}

	public List<InvrptOutModel> getInvrptOutLines() {
		return allSettings.mapInvrptOut.values();
	}

	public void addDesadv(String fromLocation, String toLocation, String accountId) {
		DesadvModel tmp = new DesadvModel(fromLocation, toLocation, accountId);
		allSettings.mapDesadv.put(
			tmp.lineId,
			tmp
		);
	}

	public void addInvrpt(String accId, String rptId) {
		InvrptOutModel tmp = new InvrptOutModel(accId, rptId);
		System.debug('!!!### '+allSettings.mapInvrptOut);
		allSettings.mapInvrptOut.put(
			tmp.lineId,
			tmp
		);
	}

	public void removeDesadv(String lineId) {
		allSettings.mapDesadv.remove(lineId);
	}

	public void removeInvrptOut(String lineId) {
		allSettings.mapInvrptOut.remove(lineId);
	}

	public Boolean desadvInfoExist(PBSI__Transfer_Order__c to) {
		DesadvModel tmp = new DesadvModel(to.PBSI__From_Location__c, to.PBSI__To_Location__c, null);
		return allSettings.mapDesadv.containsKey(tmp.lineId);
	}

	public Boolean desadvInfoExist(Account acc) {
		//TODO, add logic for sales orders
		return false;
	}

	private void loadSettings() {
		if(settingObj == null) {
			querySettings();
		}
	}

	private void querySettings() {
		List<B24_Settings__c> lSettings = [SELECT Id,Desadv__c,Invrpt_Out__c FROM B24_Settings__c ORDER BY CreatedDate ASC LIMIT 1];
		if(lSettings.isEmpty()) {
			createNewSettings();
		} else {
			settingObj = lSettings[0];
			loadFromDB();
		}
	}

	private void createNewSettings() {
		settingObj = new B24_Settings__c();
		allSettings = new SettingDefinition();
		allSettings.mapDesadv = new Map<String, DesadvModel>();
		allSettings.mapInvrptOut = new Map<String, InvrptOutModel>();
	}

	private void loadFromDB() {
		allSettings = new SettingDefinition();
		if(settingObj.Desadv__c != null) {
			allSettings.mapDesadv = (Map<String, DesadvModel>) JSON.deserialize(settingObj.Desadv__c, Map<String, DesadvModel>.class);
		} else {
			allSettings.mapDesadv = new Map<String, DesadvModel>();
		}
		if(settingObj.Invrpt_Out__c != null) {
			allSettings.mapInvrptOut = (Map<String, InvrptOutModel>) JSON.deserialize(settingObj.Invrpt_Out__c, Map<String, InvrptOutModel>.class);
		} else {
			allSettings.mapInvrptOut = new Map<String, InvrptOutModel>();
		}
	}

	private class SettingDefinition {
		Map<String, DesadvModel> mapDesadv;
		Map<String, InvrptOutModel> mapInvrptOut;
	}

	public class DesadvModel {
		public String lineId {
			public get;
			private set;
		}
		public String type {
			public get;
			private set;
		}
		public Id fromLocationId;
		public Id toLocationId;
		public Id accountId;

		public DesadvModel(String fromLocationId, String toLocationId, String accountId) {
			this.fromLocationId = fromLocationId;
			this.toLocationId = toLocationId;
			this.accountId = accountId;
			this.lineId = ((String)fromLocationId).left(15) + ((String)toLocationId).left(15);
			this.type = 'TO';
		}

		public DesadvModel(String accountId) {
			this.lineId = accountId.left(15);
			this.type = 'SO';
		}
	}

	public class InvrptOutModel {
		public String lineId {
			public get;
			private set;
		}
		public Id accId {
			public get;
			private set;
		}
		public Id rptId {
			public get;
			private set;
		}

		public InvrptOutModel(Id accId, Id rptId) {
			this.rptId = rptId;
			this.accId = accId;
			this.lineId = '' + this.rptId + this.accId;
		}
	}

	public B24SObjectCreator getOrderCreatorClass(String accountGLN) {

		if(!accGLN2OrderCreatorClass.containskey(accountGLN) && !glnsAlreadySelected.contains(accountGLN)){
			try{
				glnsAlreadySelected.add(accountGLN);
				Account acc = [Select id, B24_Integration_Model__r.Order_InBound__c from account where GLN__c =: accountGLN];
				accGLN2OrderCreatorClass.put(accountGLN, acc.B24_Integration_Model__r.Order_InBound__c);
			}
			catch(Exception e){
				throw new B24SettingsException('There is no Account mapping for this GLN: '+accountGLN);
			}
		}

		B24SObjectCreator orderCreator;
		String className = accGLN2OrderCreatorClass.get(accountGLN);
		if(className == null) {
          	throw new B24SettingsException('There is no class for this GLN: '+accountGLN);
		} else {
			orderCreator = (B24SObjectCreator) Type.forName(className).newInstance();
		}
		return orderCreator;
	}

	private static Map<String, String> accGLN2OrderCreatorClass = new Map<String, String>();
	private static Set<String> glnsAlreadySelected = new Set<String>();
}