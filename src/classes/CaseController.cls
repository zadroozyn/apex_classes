public with sharing class CaseController {

	public final Id caseId;
	public boolean caseExists {get; set;}
	public String dateFormatString {get; set;}
	private transient CaseWrapper cw;
	private User currentUser;

	public CaseController () {
		caseExists = true;
		dateFormatString = DateFormat.getDateFormatForCurrentUser();
		try {
			caseId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
		} catch (Exception e) {
			caseExists = false;
			system.debug(e);
		}
	}

	public CaseWrapper getCaseWrapper() {
			cw = new CaseWrapper(this.caseId, this.dateFormatString);
			this.caseExists = cw.caseExists;
		system.debug('Sciagamy CW');
		return cw;
	}

	public PageReference exit() {
		return Page.Cases;
	}

	public class CaseWrapper {
		public Case source {get; set;}
		private List<WarrantyLineWrapper> warrantyLines;
		private Id caseId;
		public boolean caseExists {get; set;}
		private String dateFormatString;

		public CaseWrapper(Id caseId, String dateFormat) {
			this.caseExists = true;
			this.caseId = caseId;
			this.source = initCase();
			this.dateFormatString = dateFormat;
			this.warrantyLines = new List<WarrantyLineWrapper>();
			try {
				caseId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
			} catch (Exception e) {
				caseExists = false;
				system.debug(e);
			}
		}

		public Case initCase() {
			Case output;
			try {
				output = [SELECT Id, CaseNumber, Status, CreatedDate, On_agent_visit_required__c, Account.BillingCountry, (SELECT Id, Customer_name__c, Distance_run__c, Item__r.Id, Item__r.PBSI__description__c, Item__r.PBSI__Photo_URL__c, Refund_required__c, Purchase_date__c, Defect_reason__c, Status__c, Production_code__c, RecordTypeId, Machine_wash_frequency__c, Laundry_temperature__c, Fabric_softener__c, Dry_cleaned__c, Comments__c FROM Warranty_Lines__r) FROM Case WHERE Id =: caseId];
			} catch (Exception e) {
				caseExists = false;
			} finally {
				if(output == null) {
					caseExists = false;
				}
			}
			return output;
		}

		public List<WarrantyLineWrapper> getLines() {
			if(this.caseExists) {
				for(Warranty_Line__c current : source.Warranty_Lines__r) {
					warrantyLines.add(new WarrantyLineWrapper(current, this.dateFormatString, this));
				}
			}
			return warrantyLines;
		}

		public PageReference onLineDelete() {
			if(this.hasLines()) {
				return null;
			}
			delete this.source;
			return Page.Cases;
		}

		public boolean hasLines() {
			for(WarrantyLineWrapper current : warrantyLines) {
				if(!current.isDeleted) {
					return true;
				}
			}
			return false;
		}

		public String getFormatedCaseDate() {
			return this.source.CreatedDate.date().format();
		}

		public boolean getIsRefundAvailable() {
			return this.source.Account.BillingCountry == 'Canada' || this.source.Account.BillingCountry == 'United States';
		}

		public void saveAll() {
			List<Warranty_Line__c> lines = new List<Warranty_Line__c>();
			List<Attachment> attachments = new List<Attachment>();
			for(Integer i = 0; i < warrantyLines.size(); i+=1){
				if(!warrantyLines[i].isDeleted){
					lines.add(warrantyLines[i].getUpdatedSource());
					attachments.addAll(warrantyLines[i].getAttachments());
				}
			}
			update lines;
			upsert attachments;
		}

		public PageReference submit() {
			for(Integer i = 0; i < warrantyLines.size(); i+=1){
				warrantyLines[i].submit();
			}
			update new Case(Id = caseId, Status = 'In progress');
			saveAll();
			return Page.Cases;
		}

		public void updateSource() {
			update source;
		}
	}

	public class WarrantyLineWrapper {
		public final Warranty_line__c source {get; set;}
		public final List<Attachment> attachments {get; set;}
		public final PortalDateWrapper purchaseDate {get; set;}
		public final String description {get; set;}
		public final boolean isApparel {get; set;}
		public final String picUrl {get; set;}
		public final CaseWrapper parent;
		public boolean isDeleted {get; set;}
		public String distance {
			get; 
			set{ this.distance = value; }
		}

		WarrantyLineWrapper (Warranty_line__c source, String dFormat, CaseWrapper parent) {
			this.source = source;
			this.purchaseDate = new PortalDateWrapper(source.Purchase_date__c, dFormat);
			this.description = source.Item__r.PBSI__description__c;
			this.distance = source.Distance_run__c;
			this.attachments = new List<Attachment>();
			this.isApparel = source.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Warranty_line__c', 'Apparel');
			this.picUrl = source.Item__r.PBSI__Photo_URL__c;
			this.isDeleted = false;
			this.parent = parent;
			populateAttachments();
		}

		private void populateAttachments() {
			Map<String, Attachment> existingAttachments = queryAttachments();
			this.attachments.add(existingAttachments.containsKey('Attachment1') ? existingAttachments.get('Attachment1') : new Attachment(ParentId=source.Id));
			this.attachments.add(existingAttachments.containsKey('Attachment2') ? existingAttachments.get('Attachment2') : new Attachment(ParentId=source.Id));
			this.attachments.add(existingAttachments.containsKey('Attachment3') ? existingAttachments.get('Attachment3') : new Attachment(ParentId=source.Id));
			this.attachments.add(existingAttachments.containsKey('Attachment4') ? existingAttachments.get('Attachment4') : new Attachment(ParentId=source.Id));
		}

		private void Submit() {
			this.source.Status__c = 'Submitted';
		}

		public Map<String, Attachment> queryAttachments() {
			Map<String, Attachment> atts = new Map<String, Attachment>();
			for(Attachment current : [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId =: this.source.Id]) {
				atts.put(current.Name.split('\\.')[0], current);
			}
			return atts;
		}

		public Warranty_Line__c getUpdatedSource() {
			this.source.Purchase_date__c = this.purchaseDate.dateField;
			this.source.Distance_run__c = this.distance;
			return this.source;
		}

		public List<Attachment> getAttachments() {
			List<Attachment> output = new List<Attachment>();
			for(Integer i = 0; i < this.attachments.size(); i+=1) {
				if(this.attachments[i].Body != null) {
					List<String> nameParts = this.attachments[i].Name.split('\\.');
					this.attachments[i].Name = 'Attachment' + (i+1) + '.' + nameParts.get(nameParts.size()-1);
					output.add(this.attachments[i]);
				}
			}
			return output;
		}

		public void save() {
			parent.saveAll();
		}

		public PageReference deleteMe() {
			this.isDeleted = true;
			delete this.source;
			return parent.onLineDelete();
		}
	}
}