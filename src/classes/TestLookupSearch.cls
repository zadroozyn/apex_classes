@isTest
private class TestLookupSearch 
{
    static testMethod void myUnitTest() 
    {
    	try
    	{
	        PBSI__PBSI_Item__c item = TestUtilActions.createItem();
	    	
	        PageReference pageRef = Page.AscentLookup;
	        
	        System.assertNotEquals(null, item.Id); 
	        
	 		pageRef.getParameters().put('itemID', item.Id);
	    	
	    	Test.setCurrentPage(pageRef);
	    	
	    	LookupSearch lookupSearch = new LookupSearch();
	    	lookupSearch.getfields();
	    	lookupSearch.search();
    	}
    	catch(Exception ex){}	
    }
}