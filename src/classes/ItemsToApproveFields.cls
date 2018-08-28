public with sharing class ItemsToApproveFields {

	public class ProcessNotDefinedException extends Exception {}
	
	public ItemsToApproveFields() {
		if(mapProcessName2Fields == null) {
			loadFields();
		}
	}

	public Set<String> getAllProcessesNames() {
		return mapProcessName2Fields.keySet();
	}

	public List<String> getFieldsPaths(String processName) {
		if(!mapProcessName2Fields.containsKey(processName)) {
			throw new ProcessNotDefinedException('This process is not defined: '+processName);
		}
		return mapProcessName2Fields.get(processName);
	}

	private static Map<String,List<String>> mapProcessName2Fields;	

	private static void loadFields() {
		mapProcessName2Fields = new Map<String,List<String>>();
		List<Items_to_Approve_Fields__c> lFields = Items_to_Approve_Fields__c.getAll().values();
		for(Items_to_Approve_Fields__c field: lFields) {
			String fPath = field.Field_API_Name__c;
			if(mapProcessName2Fields.containsKey(field.Process_name__c)) {
				mapProcessName2Fields.get(field.Process_name__c).add(fPath);
			} else {
				mapProcessName2Fields.put(field.Process_name__c, new List<String> {fPath});
			}
		}
	}
}