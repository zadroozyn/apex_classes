/** 
 * Interface contains methods for Trigger Handlers.
 * 
 * @version 1.0 18.06.2014  Ewa Byra (ewa.byra@nefoscdc.com)
 * 							Initial version of interface.
 * 
 */
 
public interface ITriggerHandler {
	
	/**
	 * This method is called for list of records that need to be inserted during a BEFORE
	 * trigger.
	 * 
	 * @param lSObjects list of records that are instering.
	 */
	void beforeInsert(List<SObject> lSObjects);
	
	/**
	 * This method is called for records to be updated during a BEFORE
	 * trigger.
	 * 
	 * @param mSObjectsOld map of records that contain data before changes.
	 * @param mSObjectsNew map of records that contain data after changes.
	 */
	void beforeUpdate(Map<ID, SObject> mSObjectsOld, Map<ID, SObject> mSObjectsNew);

	/**
	 * This method is called for records to be deleted during a BEFORE
	 * trigger.
	 * 
	 * @param mSObjectsOld map of records that contain data before changes.
	 * 
	 */
	void beforeDelete(Map<ID, SObject> mSObjectsOld, List<SObject> lSObjectsNew);

	/**
	 * This method is called for records inserted during an AFTER
	 * trigger. Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The records are 'read only' by this point.
	 * 
	 * @param mSObjects map of records that are inserted.
	 */
	void afterInsert(Map<ID, SObject> mSObjects);

	/**
	 * This method is called for records updated during an AFTER
	 * trigger.
	 *
	 * @param mSObjectsOld map of records that contain data before changes. 
	 * @param mSObjectsNew map of records that are updated.
	 */
	void afterUpdate(Map<ID, SObject> mSObjectsOld, Map<ID, SObject> mSObjectsNew);

	/**
	 * This method is called for map of records deleted during an AFTER
	 * trigger.
	 * 
	 * @param mSObjects map of records that are deleted.
	 */
	void afterDelete(Map<ID, SObject> mSObjects);
	
	/**
	 * This method is called for map of records undeleted during an AFTER
	 * trigger.
	 * 
	 * @param mSObjects map of records that are undeleted.
	 */
	void afterUnDelete(Map<ID, SObject> mSObjects);
}