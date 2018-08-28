/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestTradeAgreements {

    static testMethod void myUnitTest() {
        PBSI__Account_Group__c accg = new PBSI__Account_Group__c(Name = 'abcdefgryhrtyrty');
            try {
                insert accg;
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }
            
      	 Account acc = new Account(Name = 'abcdefgh', ShippingState = 'NJ', PBSI__Payment_Terms__c = 'Net 35',pbsi__Account_Group__c=accg.Id);
            try {
                insert acc; 
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }
            PBSI__junc_Accounts2AccountGroups__c acj=new PBSI__junc_Accounts2AccountGroups__c(pbsi__Account_Group__c=accg.id,pbsi__account__c=acc.id);
            insert acj;
            
         Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
            try {
                insert acc1;
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }   
             
              PBSI__junc_Accounts2AccountGroups__c acj1=new PBSI__junc_Accounts2AccountGroups__c(pbsi__Account_Group__c=accg.id,pbsi__account__c=acc1.id);
            insert acj1;         
             Contact contact = new Contact(LastName = 'Lorincz', Email = 'andreealorincz@gmail.com', AccountId = acc.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }
            
        PBSI__PBSI_Item_Group__c group3 = new PBSI__PBSI_Item_Group__c(Name = 'group3', PBSI__Description__c = 'PBS Tools2', PBSI__Item_Group_Code__c = '877',group_description__c='andrea'); 
        PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',PBSI__Parent_Group__c=group3.id,group_description__c='andrea');
        PBSI__PBSI_Item_Group__c group2 = new PBSI__PBSI_Item_Group__c(Name = 'sdedwdwefwe', PBSI__Description__c = 'PBS Tools2', PBSI__Item_Group_Code__c = '877',PBSI__Parent_Group__c=group1.id,group_description__c='andrea');
        
        PBSI__PBSI_Item_Group__c[] groups = new PBSI__PBSI_Item_Group__c[] {group1, group2,group3};
        insert groups ;
        PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd', PBSI__description__c = 'Shipping'); 
        PBSI__PBSI_Location__c[] locations = new PBSI__PBSI_Location__c[] {loc1}; 
        insert locations ;
            
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='item2', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group2.Id,EAN_Number__c='123444');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] { item2};
        insert items ;
        PBSI__junc_Items2ItemGroups__c igr=new PBSI__junc_Items2ItemGroups__c(pbsi__item__c=item2.id,pbsi__item_group__c=group1.id);
        PBSI__junc_Items2ItemGroups__c igr1=new PBSI__junc_Items2ItemGroups__c(pbsi__item__c=item2.id,pbsi__item_group__c=group1.id);
        PBSI__junc_Items2ItemGroups__c igr2=new PBSI__junc_Items2ItemGroups__c(pbsi__item__c=item2.id,pbsi__item_group__c=group1.id);
        insert igr;insert igr1;insert igr2;
        PBSI__PBSI_Sales_Order__c SOtest =new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = acc.Id,pbsi__due_date__c=system.today()+10);
        insert SOtest;
	    PBSI__Trade_Agreement__c t16=new pbsi__Trade_Agreement__c(Name='agr16',pbsi__Applies_To__c='Sales Order',pbsi__Item_Selection__c= item2.Id,pbsi__Account_Group_Selection__c=accg.Id,pbsi__Level__c='line',pbsi__Quantity__c=2,pbsi__Price__c=50,pbsi__date_from__c=system.today()-10,pbsi__date_to__c=system.today()+20);
	    PBSI__Trade_Agreement__c t15=new pbsi__Trade_Agreement__c(Name='agr15',pbsi__Applies_To__c='Sales Order',pbsi__Item_Selection__c= item2.Id,pbsi__Account_Group_Selection__c=accg.Id,pbsi__Level__c='line',pbsi__Price__c=40,pbsi__date_from__C=system.today()+30);
	    PBSI__Trade_Agreement__c [] t=new PBSI__Trade_Agreement__c[]{t16,t15};
        insert t;
        Test.startTest();
        PBSI__PBSI_Sales_Order_Line__c SOtestLine1 = new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = SOtest.Id, PBSI__Quantity_Needed__c = 1, PBSI__Item__c = item2.Id);
        insert sotestline1;
        sotest.PBSI__Due_Date__c=system.today()+31;
        update sotest;
     
   
         
   
    }
}