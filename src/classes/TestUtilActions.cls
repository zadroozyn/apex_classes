/* 
	Util actions for test classes

	@author: Elena Iovcev
*/
@isTest
public class TestUtilActions 
{
    public static PBSI__PBSI_Item__c createItem() 
    {
        Account account = TestUtil.GetAccount();
        insert account; 
         
        PBSI__PBSI_Location__c location = TestUtil.GetLocation();
        location.PBSI__Account__c = account.Id;
        insert location;
        
        PBSI__PBSI_Item_Group__c itemGroup = TestUtil.GetItemGroup();
        insert itemGroup;
        
        PBSI__PBSI_Item__c item = TestUtil.GetItem(location.Id, itemGroup.Id);
        
        insert item;
        
        return item;
    }
}