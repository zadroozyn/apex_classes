public class B24SObjectWorker implements Queueable {
	public class SettingsException extends Exception {}
	public class UnexpectedException extends Exception {}
	private Settings settings;
	public B24SObjectWorker(Settings settings) {
		validateSettings(settings);
		this.settings = settings;
	}

	private void validateSettings(Settings sets) {
		if(sets.lObjectsToProcess.isEmpty() || 
			String.isBlank(sets.authObjSerial) ||
			String.isBlank(sets.b24IdField) ||
			String.isBlank(sets.relNameToParent)
			) {
			throw new SettingsException('Missing informations in settings.');
		}
	}

	public void execute(QueueableContext context) {
		Map<SObject, List<SObject>> mapSO2Lines = new Map<SObject, List<SObject>>();
		List<SObject> soLinesToInsert = new List<SObject>();
		List<SObject> soToDelete = new List<SObject>();
		List<SObject> lSalesOrders = new List<SObject>();
		Set<Id> accIdsToLock = new Set<Id>();
		LogService logSrv = LogService.getlogService();

		for(B24SObjectCreatorBase.ParentChildren soWithLines: settings.lObjectsToProcess) {
			mapSO2Lines.put(soWithLines.parent, soWithLines.children);
			lSalesOrders.add(soWithLines.parent);
			if(!String.isBlank(settings.relationOnParentToLock)) {
				accIdsToLock.add((Id)soWithLines.parent.get(settings.relationOnParentToLock));
			}
		}
		accIdsToLock.remove(null);
		String sObjToLockName;
		if(!accIdsToLock.isEmpty()) {
			//Avoid deadlock	
			List<SObject> accsLocked;
			sObjToLockName = new List<Id>(accIdsToLock)[0].getSobjectType().getDescribe().getName();
			for(Integer i=0; i < 2; i++) {
				try {
					accsLocked = Database.query('SELECT Id FROM ' + sObjToLockName + ' WHERE Id = :accIdsToLock FOR UPDATE');
					break;
				} catch(System.QueryException e) {
					//try again
				}
			}
			if(accsLocked == null) {
				System.enqueueJob(this);
				return;
			}
		}
		
		List<Database.SaveResult> srs = Database.insert(new List<SObject>(mapSO2Lines.keySet()) , false);
		System.debug('!!!### insert so results');
		System.debug(srs);
		lSalesOrders = new List<SObject>(mapSO2Lines.keySet()); 
		for(Integer i=0; i<srs.size(); i++) {
			Database.SaveResult sr = srs[i];
			if(!sr.isSuccess()) {
				reportDeliveryError((String)(lSalesOrders[i].get(settings.b24IdField)), settings.authObjSerial);
				logSrv.addError().type(B24MessageRouter.class.getName()+'_SO')
					.attachment(settings.errorLogAttName, JSON.serialize(settings.lObjectsToProcess[i]));
				mapSO2Lines.remove(lSalesOrders[i]);
			}
		}

		for(List<SObject> lLines: mapSO2Lines.values()) {
			soLinesToInsert.addAll(lLines);
		}

		srs = Database.insert(soLinesToInsert, false);
		System.debug('!!!### insert lines results');
		System.debug(srs);
		Set<String> b24MsgIdsFailed = new Set<String>();
		for(Integer i=0; i<srs.size(); i++) {
			Database.SaveResult sr = srs[i];
			if(!sr.isSuccess()) {
				String b24MsgId = (String) soLinesToInsert[i].getSObject(settings.relNameToParent).get(settings.b24IdField);
				b24MsgIdsFailed.add(b24MsgId);
				logSrv.addError().exception(new UnexpectedException(String.valueOf(sr.getErrors()))).type(B24MessageRouter.class.getName()+'_SOLine').info((String) soLinesToInsert[i].getSObject(settings.relNameToParent).get(settings.b24IdField))
					.attachment(settings.errorLogAttName, JSON.serialize(soLinesToInsert[i]));
			}
		}
		
		Set<Id> sObjIds = new Set<Id>();
		for(SObject so: mapSO2Lines.keySet()) {
			if(!b24MsgIdsFailed.contains((String)so.get(settings.b24IdField))) {
				sObjIds.add(so.Id);
			} else {
				SObject tmp = so.Id.getSobjectType().newSObject();
				tmp.Id = so.Id;
				soToDelete.add(tmp);
			}
		}

		for(String b24MsgId: b24MsgIdsFailed) {
			reportDeliveryError(b24MsgId, settings.authObjSerial);
		}
		Database.delete(soToDelete);
		if(!String.isBlank(settings.processDefinitionImplName)) {
			enqueueProcess(sObjIds, settings.processDefinitionImplName, settings.authObjSerial);				
		}
		logSrv.save();			
	}

	@future
	private static void enqueueProcess(Set<Id> sObjIds, String processDefinitionImplName, String authObjSerialized) {
		ProcessRealization pInstance = new ProcessRealization(new List<Id>(sObjIds), (IProcessDefinition)Type.forName(processDefinitionImplName).newInstance());
		pInstance.context.b24AuthObj = (B24Authorization) JSON.deserialize(authObjSerialized, B24Authorization.class);
		if(!Test.isRunningTest()) {
			pInstance.startProcess();
		}
	}

	@future(callout=true)
	private static void reportDeliveryError(String msgId, String authObjSerialized) {
		B24Authorization authObj = (B24Authorization) JSON.deserialize(authObjSerialized, B24Authorization.class);
		new B24MessageSend(authObj).statusDeliveryError(msgId);
	}

	public class Settings {
		public List<B24SObjectCreatorBase.ParentChildren> lObjectsToProcess;
		public String authObjSerial;
		public String processDefinitionImplName;
		public String relationOnParentToLock;
		public String b24IdField;
		public String errorLogAttName;
		public String relNameToParent;

		public Settings() {
			lObjectsToProcess = new List<B24SObjectCreatorBase.ParentChildren>();
			errorLogAttName = 'struct.json';
		}
	}
		
}