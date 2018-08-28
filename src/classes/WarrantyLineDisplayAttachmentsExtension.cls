public with sharing class WarrantyLineDisplayAttachmentsExtension {
	public final Id lineId;
	public final List<Id> attachments {get; set;}

	public WarrantyLineDisplayAttachmentsExtension(ApexPages.StandardController controller) {
		lineId = controller.getId();
		attachments = new List<Id>();
		populateAttachments();
	}

	private void populateAttachments() {
		List<Attachment> temp = [SELECT Id, Name FROM Attachment WHERE ParentId =: this.lineId ORDER BY Name ASC];
		for(Attachment current : temp) {
			if(!String.isBlank(current.Name) && current.Name.containsIgnoreCase('attachment')) {
				attachments.add(current.Id);
			}
		}
	}
}