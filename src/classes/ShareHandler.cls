/**
 * This class contains methods that help insert and delete __share records
 * for any SObject.
 * 
 * @version 1.0  2015.09.29 Kamil Grzywacz (kamil.grzywacz@nefoscdc.com)
 * 							Initial version of class.
 * 
 */

public without sharing class ShareHandler {

    private final static String shareStandardSuffix = 'share';
    private final static String shareCustomSuffix = '__share';
    private final static String customObjSuffix = '__c';
    private final static String customParentPrefix = 'Parent';

    private final static Set<String> possibleAccessLevels = new Set<String>{'read', 'edit', 'all'};

    public final static String NONEACCESSLEVEL = 'None';
    public final static String READACCESSLEVEL = 'Read';
    public final static String EDITACCESSLEVEL = 'Edit';
    public final static String ALLACCESSLEVEL = 'All';
    
    private static Map<String, Schema.SObjectType> mObjectTypes = new Map<String, Schema.SObjectType>();
    private static Map<String, List<Schema.PicklistEntry>> mPicklistForObjectType = new Map<String, List<Schema.PicklistEntry>>();

    /**
      * Method creates __share records for all parent records with specified access level for all users.
      * @Param lUserIds     List of user ids for which __share records should be created.
      * @Param lParentIds   List of parent object ids for which __share records should be created
      * @Param accessLevel  Access level of share records to insert
      * @Param objectName   API Name of SObject for which we create __share records
      * @Param toInsert     Specifies if __share records should be insert immediately
      * @Return             List of __share records as SObjects
      */
    public static List<SObject> createShares(List<Id> lUserIds, List<Id> lParentIds, String accessLevel, String objectName, String rowCauseApiName, Boolean toInsert) {
        Long stopWatch = System.currentTimeMillis();
        if(!verifyAccessLevel(accessLevel)) {
            throw new ShareHandlerException ('Specified access level is not permited. Possible access levels are: Read, Edit and All');
        }
        List<SObjecT> lNewShares = new List<SObject>();
        for(Id currentUserId : lUserIds) {
            for(Id currentParentId : lParentIds) {
                lNewShares.add(createShare(currentUserId, currentParentId, accessLevel, objectName, rowCauseApiName));
            }
        }
        if(toInsert) {
            insert lNewShares;
        }
        System.debug('Share object created for '+ lParentIds.size() + 'objects.');
        System.debug('ShareHanfer.createShares() finished in ' + (System.currentTimeMillis() - stopWatch));
        return lNewShares;
    }

    /**
      * Method creates __share record for specified parent, user and access level,
      * it does not inserts __share record immediately. 
      * @Param userId           Id of an user
      * @Param parentRecordId   Id of a parent record
      * @Param accessLevel      Access level of share records to insert
      * @Param objectName       API Name of SObject for which we create __share records
      * @Return                 __share record as SObject. 
      */
    public static SObject createShare(Id userId, Id parentRecordId, String accessLevel, String objectName, String rowCauseApiName) {
        return createShare(userId, parentRecordId, accessLevel, objectName, rowCauseApiName, false);
    }

    /**
      * Method creates __share record for specified parent, user and access level,
      * it lets user decide if __share records will be inserted immediately
      * @Param userId           Id of an user
      * @Param parentRecordId   Id of a parent record
      * @Param accessLevel      Access level of share records to insert
      * @Param objectName       API Name of SObject for which we create __share records
      * @Param toInsert         Specifies if record should be inserted immediately
      * @Return                 __share record as SObject. 
      */
    public static SObject createShare(Id userId, Id parentRecordId, String accessLevel, String objectName, String rowCauseApiName, Boolean toInsert) {
   
        if(!verifyRowCause(makeShareObjName(objectName), rowCauseApiName)) {
            throw new ShareHandlerException('Specified rowCause(Sharing reason) doesn\'t exists for object ' + makeShareObjName(objectName) + '.');
        }
        String parentPrefix;
        String accessLevelPrefix;

        if(isCustomObjectName(objectName)){
            parentPrefix = customParentPrefix;
            accessLevelPrefix = '';
        } else {
            parentPrefix = objectName;
            accessLevelPrefix = objectName;
        }
        
        Schema.SObjectType targetType = getObjectType(objectName);
        SObject newShare = targetType.newSObject();
        newShare.put(parentPrefix + 'Id', parentRecordId);
        newShare.put('UserOrGroupId', userId);
        newShare.put(accessLevelPrefix + 'AccessLevel', accessLevel);
        newShare.put('RowCause', rowCauseApiName);
        if(toInsert){
            insert newShare;
        }
        return newShare;
    }

    public static List<SObject> getShares (List<Id> parents, String sobjectName, String rowCauseApiName) {
        System.debug(makeShareObjName(sobjectName));
        return Database.query('SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel FROM ' + makeShareObjName(sobjectName) + ' WHERE RowCause = : rowCauseApiName AND ParentId in : parents');
    }

    /**
      * Method converts object name into its share name.
      * @Param targetName   String containing API name of an SObject
      * @Return             String containing API name of SObject's share
      */
    private static String makeShareObjName (String targetName) {
        if(targetName.endsWithIgnoreCase(shareStandardSuffix) || targetName.endsWithIgnoreCase(shareCustomSuffix)) {
            return targetName;
        } else if (isCustomObjectName(targetName)) {
            return targetName.toLowerCase().mid(0, targetName.lastIndexOfIgnoreCase(customObjSuffix)) + shareCustomSuffix;
        } else {
            return targetName + shareStandardSuffix;
        }
        return '';
    }
    
    /**
     * Method checks if given string is custom object name
     * @param name  string to check
     * @return      boolean
     */
    private static boolean isCustomObjectName(String name) {
        return name.endsWithIgnoreCase(customObjSuffix);
    }

    /**
      * Method checks if provided access level is valid.
      * @Param accessLevel      Access level to check.
      * @Return Boolean         True if access level is valid
      */
    private static Boolean verifyAccessLevel(String accessLevel) {
        return possibleAccessLevels.contains(accessLevel.toLowerCase());
    }

    /**
      * Method verifies if provided rowcause exists for given shareObject,
      * @Param shareObjectName      Api name of share object to check.
      * @Param shareReasonApiName   Api name of share reason on shareObject
      * @Return Boolean             True if given share reason exists for the share object
      */
    private static boolean verifyRowCause (String shareObjectName, String shareReasonApiName) {
        

        for(Schema.PicklistEntry current : getPickListEntries(shareObjectName)){
            if(current.getValue().equalsIgnoreCase(shareReasonApiName)){
                return true;
            }
        }
        return false;
    }

    /**
     * Method gets SObjectType for the given object name. 
     * Values are cached in static map, so the actul call is done
     * only once.
     * @param  objectName the object name. 
     * @return            Schema.SObjectType
     */
     private static Schema.SObjectType getObjectType(String objectName){

      Schema.SObjectType type = ShareHandler.mObjectTypes.get(objectName);
      if (type == null){
          type = Schema.getGlobalDescribe().get(makeShareObjName(objectName));
          ShareHandler.mObjectTypes.put(objectName, type);
      }
      return type;
    }


    /**
     * Method gets picklist entites for the given object. Value is cached in static map,
     * so the actual call is done only once.
     * @param  objectName name of the object for which values have to be retrieved.
     * @return            List of Schema.PicklistEntries.
     */
    private static List<Schema.PicklistEntry> getPickListEntries(String objectName){
		System.debug('Searching for rowcause of ' +  objectName);
		System.debug('currently we have ' + mPicklistForObjectType.keySet());
		List<Schema.PicklistEntry> lPicklistEntries = mPicklistForObjectType.get(objectName);
		if (lPicklistEntries == null){
			lPicklistEntries = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get('rowCause').getDescribe().getPicklistValues();
			if (lPicklistEntries == null){
			  lPicklistEntries = new List<Schema.PicklistEntry>();
			}
			mPicklistForObjectType.put(objectName, lPicklistEntries);
		}
		return lPicklistEntries;
    }

	private static List<SObject> getExistingShares(String shareObjectName, List<Id> lUserIds, List<Id> lParentIds) {
		return Database.query('SELECT Id, ParentId, UserOrGroupId FROM ' + shareObjectName + ' ParentId IN : lParentIds AND UserOrGroupId IN : lUserIds');
	}



    private class ShareHandlerException extends Exception {}
}