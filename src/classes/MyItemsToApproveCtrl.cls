global with sharing class MyItemsToApproveCtrl {
	
	public List<ApprovalGroup> lGroups { get; private set; }
	private String selectedGroupId;
	private Set<Id> userGroupsIds;
	public static final String TAB_ALL = Label.ItemsToApprove_TabAll;
	public static final String TAB_OTHER = Label.ItemsToApprove_TabOther;
	private Map<String,ApprovalGroup> mapApprovalGroups = new Map<String,ApprovalGroup>();
	private ApprovalGroup gOther = new ApprovalGroup(TAB_OTHER,TAB_OTHER);
	private ApprovalGroup gAll = new ApprovalGroup(TAB_ALL,TAB_ALL);
	private Map<String,ProcessDefinition> mapProcesDevName2Process;
	private ItemsToApproveFields approvalFields;
	private PIWISource piwiSource;

	public MyItemsToApproveCtrl() {
		userGroupsIds = getUserQueuesIds();
		approvalFields = new ItemsToApproveFields();
		piwiSource = getPIWISource(); 
		loadApprovals();
	}

	public void setSelectedGroupId(String selected) {
		selectedGroupId = selected;
		ApprovalGroup selectedAG = selected == TAB_OTHER ? gOther : selected == TAB_ALL ? gAll : mapApprovalGroups.get(selected);
		loadPIWIs(selectedAG);
	}

	public String getSelectedGroupId() {
		return selectedGroupId;
	}


	public PageReference dummy() {
		return null;
	}

	private void loadApprovals() {
		
		lGroups = new List<ApprovalGroup> {gAll};
		mapProcesDevName2Process = new Map<String,ProcessDefinition>();
		for(ProcessDefinition procDef: piwiSource.getApprovalProcesses()){
			mapProcesDevName2Process.put(
				procDef.DeveloperName,
				procDef
			);
		}
		
		
		for(String processName: approvalFields.getAllProcessesNames()) {
			ProcessDefinition pd = mapProcesDevName2Process.get(processName);
			if(pd == null) {
				System.debug('!!!### invalid process name: '+processName);
				continue;
			}
			ApprovalGroup ag = new ApprovalGroup(pd);
			ag.setAdditionalFields(approvalFields.getFieldsPaths(processName));
			mapApprovalGroups.put(processName,ag);
		}
		if(!mapApprovalGroups.values().isEmpty()) {
			lGroups.addAll(mapApprovalGroups.values());
			lGroups.add(gOther);
		}
		setSelectedGroupId(gAll.id);
	}

	private void loadPIWIs(ApprovalGroup selectedAG) {
		clearApprovalRecords();
		Set<Id> sObjectIds = new Set<Id>();
		List<ApprovalGroup.PIWIWrapper> lPiwisToLoadDetails = new List<ApprovalGroup.PIWIWrapper>();

		for(ApprovalGroup.PIWIWrapper piwiWrap: piwiSource.getPIWIs()){
			if(mapApprovalGroups.containsKey(piwiWrap.processDevName)) {
				mapApprovalGroups.get(piwiWrap.processDevName).approvalRecords.add(piwiWrap);
			} else {
				gOther.approvalRecords.add(piwiWrap);
			}
			gAll.approvalRecords.add(piwiWrap);
			if(piwiWrap.processDevName == selectedAG.id) {
				sObjectIds.add(piwiWrap.sObj.Id);
				lPiwisToLoadDetails.add(piwiWrap);
			}

		}

		if(selectedAG.id != TAB_OTHER && selectedAG.id != TAB_ALL) {
			Map<Id,Sobject> mapSobjects = getSobjects(mapProcesDevName2Process.get(selectedAG.id).TableEnumOrId, 
				selectedAG.getAdditionalFieldsPaths(), sObjectIds);
			for(ApprovalGroup.PIWIWrapper piwiWrap: lPiwisToLoadDetails) {
				piwiWrap.sObj = mapSobjects.get(piwiWrap.sObj.Id);
			}
		}
	}

	private void clearApprovalRecords() {
		for(ApprovalGroup ag: lGroups) {
			ag.approvalRecords.clear();
		}
	}

	private Set<Id> getUserQueuesIds() {
		Id userId = UserInfo.getUserId();
		List<GroupMember> lGroupMembers = [SELECT GroupId from GroupMember WHERE UserOrGroupId = :userId AND Group.Type = 'Queue'];
		Set<Id> groupIds = new Set<Id>();
		for(GroupMember gm: lGroupMembers) {
			groupIds.add(gm.GroupId);
		}
		return groupIds;
	}

	private Map<Id,Sobject> getSobjects(String sObjectName, List<String> fieldsPaths, Set<Id> sObjectIds) {
		return new Map<Id,Sobject>(Database.query('SELECT '+String.join(fieldsPaths,',')
			+' FROM '+sObjectName+' WHERE Id IN :sObjectIds'));
	}

	private PIWISource getPIWISource() {
		return Test.isRunningTest() ? (PIWISource) new PIWIInsideTest() 
		: (PIWISource) new PIWIOutsideTest(this);
	}

	public interface PIWISource {
		List<ProcessDefinition> getApprovalProcesses();
		List<ApprovalGroup.PIWIWrapper> getPIWIs();
	}

	private class PIWIOutsideTest implements PIWISource {
		private MyItemsToApproveCtrl pageCtrl;
		public PIWIOutsideTest(MyItemsToApproveCtrl controller) {
			this.pageCtrl = controller;
		}
		public List<ProcessDefinition> getApprovalProcesses() {
			return [SELECT DeveloperName,Name,TableEnumOrId FROM ProcessDefinition 
				WHERE DeveloperName IN :pageCtrl.approvalFields.getAllProcessesNames()];
		}
		public List<ApprovalGroup.PIWIWrapper> getPIWIs() {
			List<ApprovalGroup.PIWIWrapper> lWrappers = new List<ApprovalGroup.PIWIWrapper>();
			for(ProcessinstanceWorkItem piwi: selectPiwis()) {
				lWrappers.add(new ApprovalGroup.PIWIWrapper(piwi));
			}
			return lWrappers;
		}
		private List<ProcessinstanceWorkItem> selectPiwis() {
		Set<Id> actorIds = pageCtrl.userGroupsIds.clone();
		actorIds.add(UserInfo.getUserId());
		return [SELECT Id, ActorId, Actor.Name, ProcessInstanceId, ProcessInstance.Status, ProcessInstance.LastActorId, ProcessInstance.LastActor.Name,
					ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.ProcessDefinition.DeveloperName,
					ProcessInstance.ProcessDefinition.Name, CreatedDate, ProcessInstance.CreatedDate
				FROM ProcessinstanceWorkItem 
				WHERE ActorId IN :actorIds AND ProcessInstance.Status = 'Pending'];
		}
	}

	private class PIWIInsideTest implements PIWISource {
		public List<ProcessDefinition> getApprovalProcesses() {
			return new List<ProcessDefinition> {
				new ProcessDefinition(
					DeveloperName = 'MockApprovalProcess',
					Name = 'Mock Approval Process',
					TableEnumOrId = 'Case'
				)
			};
		}
		public List<ApprovalGroup.PIWIWrapper> getPIWIs() {
			List<ApprovalGroup.PIWIWrapper> lWrappers = new List<ApprovalGroup.PIWIWrapper>();

			Case c = new Case(Subject='mock subject');
			insert c;
			ApprovalGroup.PIWIWrapper piwiWrap = new ApprovalGroup.PIWIWrapper();
			piwiWrap.piwiId = c.Id;
			piwiWrap.piwiTargetName = 'Case';
			piwiWrap.piwiTargetId = c.Id;
			piwiWrap.processDevName = 'MockApprovalProcess';
			piwiWrap.submitted = System.now();
			piwiWrap.waitingFrom = System.now();
			piwiWrap.sObj = c;
			lWrappers.add(piwiWrap);

			return lWrappers;
		}
	}
}