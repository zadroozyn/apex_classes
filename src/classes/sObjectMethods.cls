/**
 *	@author: Kamil Grzywacz
 *	@date: 2016-07-04 09:42:30 
 *	@description:
 *	    Class contains methods that can apply to various sObjects.
 *	
 *	Version History :   
 *		
 * 2016-07-04 - Initial version - initials
 	
 */
public class sObjectMethods {

	public static void preventApprovalStep(Map<Id, sObject> oldMap, Map<Id, sObject> newMap, String nameOfFieldWithStatus, String statusTrigger, String errorToDisplay){
		final Set<Id> idsToProcess = filterSObjectsByStringField(newMap.values(), nameOfFieldWithStatus, statusTrigger);
		idsToProcess.retainAll(getSObjectsWithChangedField(oldMap, newMap, nameOfFieldWithStatus));
		idsToProcess.retainAll(getSObjectsIdsWithoutComment(idsToProcess, '' + newMap.values()[0].getSObjectType()));
		addErrorToSObjects(idsToProcess, errorToDisplay, newMap);	
	}

	public static List<sObject> filterSObjectsByField(List<sObject> sObjects, String fieldName, Object fieldValue) {
		final List<sObject> returnValue = new List<sObject>();
		for(sObject current : sObjects) {
			if(fieldValue == current.get(fieldName)){
				returnValue.add(current);
			}
		}
		return returnValue;
	}

	public static Map<Id, sObject> filterSObjectsByField (Map<Id, sObject> sObjects, String fieldName, Object fieldValue) {
		return new Map<Id, sObject> (filterSObjectsByField(sObjects.values(), fieldName, fieldValue));
	}

	private static Set<Id> filterSObjectsByStringField(List<sObject> sObjectsToCheck, String nameOfFieldWithStatus, String statusTrigger) {
		final Set<Id> returnSet = new Set<Id>();
		for(sObject current : sObjectsToCheck) {
		    if(statusTrigger.equalsIgnoreCase((String)current.get(nameOfFieldWithStatus))) {
				returnSet.add(current.Id);
			}
		}
		return returnSet;
	}

	private static Set<Id>getSObjectsWithChangedField(Map<Id, sObject> oldMap, Map<Id, sObject> newMap, String nameOfFieldWithStatus) {
		final Set<Id> returnSet = new Set<Id>();
		for(Id current : newMap.keySet()) {
		    if(!(newMap.get(current).get(nameOfFieldWithStatus) == oldMap.get(current).get(nameOfFieldWithStatus))) {
				returnSet.add(current);
			}
		}
		return returnSet;
	}

	private static Set<Id> getSObjectsIdsWithoutComment(Set<Id> sObjectIds, String sObjectApiName) {
		final Set<Id> returnSet = new Set<Id>();
		List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId, (SELECT Id, Comments FROM Steps WHERE StepStatus = : 'Rejected' ORDER BY CreatedDate, Id DESC LIMIT 1) FROM ProcessInstance WHERE Id IN : getProcessInstanceIds(sObjectIds, sObjectApiName) ORDER BY CreatedDate DESC];
		System.debug('test');
		for(ProcessInstance current : processInstances) {
			System.debug('test 123 ' + current + ' ' + current.steps.size());
			if(current.Steps.size() != 0 && String.isBlank(current.Steps[0].Comments)){
				System.debug('test312 ' + current.Steps[0].Comments);
				returnSet.add(current.TargetObjectId);
			}
		}
		return returnSet;
	}

	private static Set<Id> getProcessInstanceIds(Set<Id> sObjects, String sObjectApiName) {
		final Set<Id> returnValue = new Set<Id>();
		String query = 'SELECT (SELECT Id FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM ' + sObjectApiName + ' WHERE Id IN : sObjects';
		for(sObject current : Database.query(query)) {
			if(current.getSObjects('ProcessInstances') != null && !current.getSObjects('ProcessInstances').isEmpty()) {
				returnValue.add(current.getSObjects('ProcessInstances')[0].Id);
			}
		}
		return returnValue;
	}

	private static void addErrorToSObjects(Set<Id> sObjectIds, String errorMsg, Map<Id, sObject> newMap){
		for(Id current : sObjectIds) {
		    newMap.get(current).addError(errorMsg);
		}
	}

	public static Map<Id, Id> getLatestActorInApproval(List<sObject> objects) {
		Map<Id, Id> returnValue = new Map<Id, Id>();
		for(ProcessInstance currentPI : [SELECT Id, TargetObjectId, (SELECT ActorId FROM Workitems ORDER BY CreatedDate DESC LIMIT 1) FROM ProcessInstance WHERE TargetObjectId IN: objects]) {
			try {
				returnValue.put(currentPI.TargetObjectId, currentPI.WorkItems[0].ActorId);
			} catch (ListException e) {
				//Just ignore it, it is possible that Workitems list will be empty
			}
		}
		return returnValue;
	}

	public static List<sObject> getListOfObjectsWithChangedLookupToUpdate(Map<Id, Id> mapToCompare, List<sObject> listToCompare, String fieldNameToCompare) {
		final List<sObject> returnValue = new List<sObject>();
		for(sObject current : listToCompare) {
		    if(current.get(fieldNameToCompare) != mapToCompare.get(current.Id)){
				current.put(fieldNameToCompare, mapToCompare.get(current.Id));
				returnValue.add(current);
			}
		}
		return returnValue;
	}

	/**
	  * Method will return values from firstMap
	  */
	public static Map<Id, sObject> getSObjectsWithChangedValue (Map<Id, sObject> firstMap, Map<Id, sObject> secondMap, String fieldName) {
		final Map<Id, sObject> returnMap = new Map<Id, sObject>();
		for(Id currentId : firstMap.keySet()){
			if(firstMap.get(currentId).get(fieldName) != secondMap.get(currentId).get(fieldName)){
				returnMap.put(currentId, firstMap.get(currentId));
			}
		}
		return returnMap;
	}

	public static Set<String> getValuesFromTextField(List<sObject> objects, String fieldName) {
		final Set<String> returnValue = new Set<String>();
		for(sObject current : objects) {
			returnValue.add((String) current.get(fieldName));
		}
		return returnValue;
	}

}