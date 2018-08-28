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
private class TestSOCancellation {

    static testMethod void myUnitTest() {

	    PBSI__Admin__c admin =  PBSI__Admin__c.getOrgDefaults();
	    admin.PBSI__Use_Ship_Lot_for_SOLine__c = true;
	    admin.PBSI__Use_Pallets__c=true;
	    admin.PBSI__do_not_calculate_atp__c = true;
	    admin.PBSI__Pack_More_than_Needed_on_SO__c=true; 
	    admin.PBSI__Allow_Packing_0_Qty_Orders__c=true; 
	    admin.PBSI__Do_Not_Allow_Display_More_Qty_Pack__c=true;
	    admin.PBSI__Always_show_serial_number_on_pack_SO__c=true;
	    admin.PBSI__Create_SNT_at_Pack_time_for_all_items__c=false;
	    admin.pbsi__Don_t_change_SoLine_Q_Pack_on_Drop_Ship__c=false;
	    admin.pbsi__Use_Not_Counted_Loc_on_Receive_and_Pack__c=false;
	    admin.PBSI__Show_taxable_field_on_line_items__c = true;
	    admin.PBSI__Use_tax_codes__c = true;
	    admin.PBSI__Prevent_So_Packing_if_Status_is__c = 'Y';
	    admin.PBSI__Update_Ship_Date_on_Line_Shipping__c = true;
	    admin.PBSI__Update_Ship_Date_when_all_Lines_Shipped__c = true;
	    admin.PBSI__Use_ATP_by_Locations__c=true;
		admin.PBSI__Force_Packing_From_Location__c=true;    
		admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c=3;
		admin.PBSI__Use_User_Location__c = false;
		//insert admin;
	
		system.debug('qqww1='+admin.PBSI__Use_ATP_by_Locations__c);
	    admin.PBSI__Use_ATP_by_Locations__c=false;
		system.debug('qqww2='+admin.PBSI__Use_ATP_by_Locations__c);
	    admin.PBSI__Use_ATP_by_Locations__c=true;
		system.debug('qqww3='+admin.PBSI__Use_ATP_by_Locations__c);
		upsert admin;
		
	    PBSI__Property__c prop;
	    try 
	    {
	        prop=[select id from PBSI__Property__c where pbsi__property_name__c='Lot_Usage'  ];
	    }
	    catch(exception e){}
	    if (prop == null)
	    {
	        prop = TestUtil.GetProperty('Lot_Usage','Yes');//new PBSI__Property__c(pbsi__property_name__c ='Lot_Usage',pbsi__property_value__c = 'Yes');
	        insert prop;
	    }
	    else
	    {
	        prop.pbsi__property_value__c='Yes';
	        update prop; 
	    }
	
	    PBSI__Tax_Code__c taxcode = new PBSI__Tax_Code__c(Name='TaxxAA',PBSI__Tax_Rate__c=10);
	    PBSI__Tax_Code__c taxcode2 = new PBSI__Tax_Code__c(Name='TaxxBB',PBSI__Tax_Rate__c=20);
	    PBSI__Tax_Code__c[] taxcodeall= new PBSI__Tax_Code__c[]{taxcode,taxcode2};
	    insert taxcodeall;
	
	    PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
	    PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
	    PBSI__PBSI_Location__c[] locs = new PBSI__PBSI_Location__c[] {loc1, loc2};
	    PBSI__PBSI_Location__c loc3 = TestUtil.GetLocation(); 
	    insert locs ; 
	    
	  	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User us = new User(Alias = 'newUser', Email='newuser@testorg.com', 
	         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	         LocaleSidKey='en_US', ProfileId = p.Id, 
	         TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
	  	PBSI__User_Location__c uloc = new PBSI__User_Location__c(PBSI__User__c=us.Id,PBSI__Location__c=loc1.Id);
	    
	    
	    Account acc4 = TestUtil.GetAccount();
	    Account acc1 = new Account(BillingCity='asasa',Billingstate='nj',BillingStreet='1244555',Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35',PBSI__Tax_Code__c=taxcode.Id);
	    Account acc2 = new Account(BillingCity='asasa',Billingstate='nj',BillingStreet='1244555',Name = 'efdfsdfsdfqwerty', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35',PBSI__Tax_Code__c=taxcode2.Id);
	    Account[] acc3 = new Account[]{acc1,acc2};
	    insert acc3;  
	    Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
	    try {
	        insert contact;
	    }
	    catch(DmlException e) { 
	            System.debug(e.getMessage()); 
	    }
	    
	    PBSI__Address_Tracker__c add1=new PBSI__Address_Tracker__c(Name='addss1',PBSI__Account__c=acc1.Id,PBSI__Tax_Code__c=taxcode.id,PBSI__Use_AddressTrackerName_for_Delivery_Comp__c=true);
	    PBSI__Address_Tracker__c add2=new PBSI__Address_Tracker__c(Name='addss2',PBSI__Account__c=acc2.Id,PBSI__Tax_Code__c=taxcode2.id);
	    PBSI__Address_Tracker__c[] add =  new PBSI__Address_Tracker__c[]{add1,add2};
	    insert add;      
	       
	    PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',group_description__c='descr1');
	    insert group1 ;  
	    PBSI__PBSI_Item_Group__c group2 = TestUtil.GetItemGroup();
	    
	     PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item1testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223344');
	        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item12testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,ean_number__c='11223345');
	        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='item2testpackso', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223346');
	        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,PBSI__Is_Serialized__c=true,ean_number__c='11223347');
	        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,ean_number__c='11223348');
	        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='item4testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,pbsi__default_vendor__c=acc1.id,ean_number__c='11223349');
	        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
	     PBSI__PBSI_Item__c item5 = TestUtil.GetItem(loc1.Id, group1.Id );
	   
         insert items ; 
	        
	     PBSI__Unit__c unit2 = TestUtil.GetItemUnit(item2.Id);
	     insert unit2;
	    
	    PBSI__PBSI_Sales_Order__c pwo=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id,PBSI__Order_Discount__c=12,PBSI__Shipping_Discount__c=12,PBSI__Sales_Tax__c=12,PBSI__Shipping_Cost__c=12,PBSI__Misc_Charges__c=10,PBSI__Type__c='Scheduled',PBSI__Schedule_End_Date__c=system.today()+5,PBSI__Address_Tracker__c = add1.Id,PBSI__staging_location__c=loc2.Id,PBSI__From_Location__c=loc1.Id);  
	    //insert pwo;
	    PBSI__PBSI_Sales_Order__c so2=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id,PBSI__Order_Discount__c=12,PBSI__Shipping_Discount__c=12,PBSI__Sales_Tax__c=12,PBSI__Shipping_Cost__c=12,PBSI__Misc_Charges__c=10,PBSI__Type__c='Scheduled',PBSI__Schedule_End_Date__c=system.today()+5);  
	    //insert so2;
	    PBSI__PBSI_Sales_Order__c[] sos = new PBSI__PBSI_Sales_Order__c[]{pwo,so2};
	    insert sos;
	    
	    PBSI__PBSI_Sales_Order_Line__c sol1 = TestUtil.GetSalesOrderLine(pwo.ID, item1.Id);
	    PBSI__Lot__c lot=new PBSI__Lot__c(pbsi__item__c=item3.id,pbsi__location__c=loc1.Id);
	    PBSI__Lot__c lot2=new PBSI__Lot__c(pbsi__item__c=item2.id,pbsi__location__c=loc1.Id);
	    PBSI__Lot__c lot3=new PBSI__Lot__c(pbsi__item__c=item3.id,pbsi__location__c=loc1.Id);
	    PBSI__Lot__c[] lots = new PBSI__Lot__c[] {lot,lot2,lot3};
	    insert lots;
	    
	    PBSI__Pallet__c pall = new PBSI__Pallet__c(PBSI__Description__c='pall1',PBSI__Location__c=loc1.Id);
	    insert pall;
	    
	    PBSI__PBSI_Inventory__c inventory = new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c = item1.Id,
	                                                                        PBSI__Lot__c = lot.Id,
	                                                                        PBSI__location_lookup__c = loc1.Id,
	                                                                        PBSI__qty__c = 5,
	                                                                        PBSI__pallet__c=pall.Id);
	    PBSI__PBSI_Inventory__c inventory2 = new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c = item2.Id,
	                                                                        PBSI__Lot__c = lot2.Id,
	                                                                        PBSI__location_lookup__c = loc1.Id,
	                                                                        PBSI__qty__c = 5,
	                                                                        PBSI__pallet__c=pall.Id);
	    PBSI__PBSI_Inventory__c inventory3 = new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c = item3.Id,
	                                                                        PBSI__Lot__c = lot3.Id,
	                                                                        PBSI__location_lookup__c = loc1.Id,
	                                                                        PBSI__qty__c = 5);
	    PBSI__PBSI_Inventory__c[] inventorys = new PBSI__PBSI_Inventory__c[] {inventory,inventory2,inventory3};
	    insert inventorys;
	    
	    PBSI__Serial_Number_Tracker__c  snt1=new PBSI__Serial_Number_Tracker__c (PBSI__Serial_Number__c='ser1',PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=item1.Id);
	    PBSI__Serial_Number_Tracker__c  snt2=new PBSI__Serial_Number_Tracker__c (PBSI__Serial_Number__c='ser2',PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=item1.Id);
	    PBSI__Serial_Number_Tracker__c  snt3=new PBSI__Serial_Number_Tracker__c (PBSI__Serial_Number__c='ser3',PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=item1.Id);
	    List<PBSI__Serial_Number_Tracker__c> snttoinsert=new List<PBSI__Serial_Number_Tracker__c>{snt1,snt2,snt3};
	    insert  snttoinsert;
	    
	    Test.startTest();
	    	    
	    PBSI__PBSI_Sales_Order_Line__c soline1= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10, PBSI__Serial_Number__c='ser1;ser2;ser3',PBSI__Location__c=loc1.Id);
	    PBSI__PBSI_Sales_Order_Line__c soline2= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item2.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10,PBSI__Location__c=loc1.Id,  PBSI__Unit_of_Measure__c = unit2.Id,   PBSI__Type__c = 'sale' );
	    PBSI__PBSI_Sales_Order_Line__c soline3= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item3.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10,PBSI__Location__c=loc1.Id);
	    PBSI__PBSI_Sales_Order_Line__c[] solines = new PBSI__PBSI_Sales_Order_Line__c[]{soline1,soline2,soline3};
	    insert solines;
	    
	    ApexPages.StandardController controller = new ApexPages.StandardController(pwo);
    	SOCancellationController pn = new SOCancellationController(controller);
	    pn.so.SO_Cancel_Reason__c = 'Input error';
    	pn.CancelChanges();
    	pn.SaveChanges();
    	pn.CheckBatch();
    	
	    Test.stopTest();
    }
}