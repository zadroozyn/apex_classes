public class ApprovalGroup {
		public String name {get;set;}
		public String id {get;set;}
		public List<ApprovalField> additionalFieldsList {get;set;}
		public List<PIWIWrapper> approvalRecords {get;set;}
		private Schema.SObjectType sObjType;
		private List<String> fieldsPaths = new List<String>();

		public class SObjectTypeException extends Exception {}

		public ApprovalGroup(String id, String name, String sObjTypeName) {
			this.id = id;
			this.name = name;
			approvalRecords = new List<PIWIWrapper>();
			additionalFieldsList = new List<ApprovalField>();
			if(sObjTypeName != null) {
				sObjType = Schema.getGlobalDescribe().get(sObjTypeName);
			}
		}

		public ApprovalGroup(String id, String name) {
			this(id,name,null);
		}

		public ApprovalGroup(ProcessDefinition procDef) {
			this(procDef.DeveloperName,procDef.Name,procDef.TableEnumOrId);
		}

		public List<String> getAdditionalFieldsPaths() {
			return this.fieldsPaths;
		}

		public void setAdditionalFields(List<String> fieldsPaths) {
			if(sObjType == null) {
				throw new SObjectTypeException('SObject Type is not defined');
			}
			this.fieldsPaths = fieldsPaths;
			additionalFieldsList = new List<ApprovalField>();
			Schema.DescribeSObjectResult dsr = sObjType.getDescribe();
			for(String fPath: fieldsPaths) {
				String[] fieldPathParts = fPath.split('\\.');
				ApprovalField af = new ApprovalField();
				af.path = fPath;
				if(fieldPathParts.size() == 1) {
					af.label = dsr.fields.getMap().get(fPath).getDescribe().getLabel();
				} else {
					Schema.DescribeSObjectResult currentSobjLevel = dsr;
					for(Integer i=0; i<fieldPathParts.size()-1; i++) {
						String relationFieldName = fieldPathParts[i].contains('__r') ? fieldPathParts[i].replace('__r','__c') 
							: fieldPathParts[i] + 'Id';
						currentSobjLevel = 
							currentSobjLevel
							.fields
							.getMap()
							.get(relationFieldName)
							.getDescribe()
							.getReferenceTo()[0]
							.getDescribe();
					}
					af.label = currentSobjLevel.fields.getMap().get(fieldPathParts[fieldPathParts.size()-1])
						.getDescribe().getLabel();
										
				}
				af.isReference = fieldPathParts[fieldPathParts.size()-1].equalsIgnoreCase('Name');
				if(af.isReference) {
					String[] referenceIdPathParts = fieldPathParts.clone();
					referenceIdPathParts[referenceIdPathParts.size()-1] = 'Id';
					af.referenceIdPath = String.join(referenceIdPathParts,'.');
				}
				additionalFieldsList.add(af);
			}
		}

		public class PIWIWrapper {
			public Id piwiId {get;set;}
			public String processDevName {get;set;}
			public DateTime submitted {get;set;}
			public DateTime waitingFrom {get;set;}
			public Sobject sObj {get;set;}
			public String piwiTargetName {get;set;}
			public String piwiTargetId {get;set;}

			public PIWIWrapper() {}

			public PIWIWrapper(ProcessinstanceWorkItem piwi) {
				piwiId = piwi.Id;
				piwiTargetName = piwi.ProcessInstance.TargetObject.Name;
				piwiTargetId = piwi.ProcessInstance.TargetObjectId;
				processDevName = piwi.ProcessInstance.ProcessDefinition.DeveloperName;
				submitted = piwi.ProcessInstance.CreatedDate;
				waitingFrom = piwi.CreatedDate;
				sObj = piwi.ProcessInstance.TargetObjectId.getSobjectType().newSobject();
				sObj.Id = piwi.ProcessInstance.TargetObjectId;
			}
		}

		public class ApprovalField {
			public String label {get;set;}
			public String path  {get;set;}
			public Boolean isReference  {get;set;}
			public String referenceIdPath  {get;set;}

			public ApprovalField() {
				isReference = false;
			}
		}
	}