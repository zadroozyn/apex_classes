/**
 * Trigger handler class for Attachment object.
 * 
 * @version 1.0  2015.09.15 Ewa Latoszek (ewa.latoszek@nefoscdc.com).
 * 							Initial version of class.<br/>
 */

public class AttachmentTriggerHandler implements ITriggerHandler {
	
	/**
	 * This method is called for list of records that need to be inserted during a BEFORE trigger.
	 * 
	 * @param lAttachments list of records that are instering.
	 */
	public static void beforeInsert(List<SObject> lAttachments) {
		
	}
	
	/**
	 * This method is called for records to be updated during a BEFORE trigger.
	 * 
	 * @param mAttachmentsOld map of records that contain data before changes.
	 * @param mAttachmentsNew map of records that contain data after changes.
	 */
	public static void beforeUpdate(Map<ID, SObject> mAttachmentsOld, Map<ID, SObject> mAttachmentsNew) {
		
	}	

	/**
	 * This method is called for records to be deleted during a BEFORE trigger.
	 * 
	 * @param mAttachmentsOld map of records that contain data before changes.
	 * @param lAttachments map of records that contain data before changes.
	 */
	public static void beforeDelete(Map<ID, SObject> mAttachmentsOld, List<SObject> lAttachments) {
		
	}

	/**
	 * This method is called for records inserted during an AFTER trigger.<br> 
	 * Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The records are 'read only' by this point.
	 * 
	 * @param mAttachments map of records that are inserted.
	 */
	public static void afterInsert(Map<ID, SObject> mAttachments) {
		PayableInvoiceMethods.fillNewInvoiceDocumentID((List<Attachment>) mAttachments.values());
	}

	/**
	 * This method is called for records updated during an AFTER trigger.
	 *
	 * @param mAttachmentsOld map of records that contain data before changes. 
	 * @param mAttachmentNew map of records that are updated.
	 */
	public static void afterUpdate(Map<ID, SObject> mAttachmentsOld, Map<ID, SObject> mAttachmentNew) {
		
	}

	/**
	 * This method is called for map of records deleted during an AFTER trigger.
	 * 
	 * @param mAttachments map of records that are deleted.
	 */
	public static void afterDelete(Map<ID, SObject> mAttachments) {
		PayableInvoiceMethods.changeInvoiceDocumentID((List<Attachment>) mAttachments.values());
	}
	
	/**
	 * This method is called for map of records undeleted during an AFTER trigger.
	 * 
	 * @param mAttachments map of records that are undeleted.
	 */
	public static void afterUnDelete(Map<ID, SObject> mAttachments) {
		
	}
	
}