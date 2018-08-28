@isTest 
public with sharing class TestPackSO {
	
	public static testMethod void TestPackSOcontroller() {

    PBSI__Admin__c admin =  PBSI__Admin__c.getOrgDefaults();
    admin.PBSI__Use_Ship_Lot_for_SOLine__c = true;
    admin.PBSI__Use_Pallets__c=true;
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
   
        //try {
            insert items ; 
        //}
       // catch(DmlException e) {
        //    System.debug(e.getMessage()); 
        //}
           PBSI__PBSI_Purchase_Order__c sot = new PBSI__PBSI_Purchase_Order__c(PBSI__Account__c = acc1.Id);
           insert sot;
             
           PBSI__PBSI_Purchase_Order_Line__c POtestLine1 = new PBSI__PBSI_Purchase_Order_Line__c(PBSI__Purchase_Order__c = sot.Id, PBSI__Quantity_Ordered__c = 8, PBSI__Item__c = item1.Id);     
           PBSI__PBSI_Purchase_Order_Line__c POtestLine2 = new PBSI__PBSI_Purchase_Order_Line__c(PBSI__Purchase_Order__c = sot.Id, PBSI__Quantity_Ordered__c = 3, PBSI__Item__c = item1.Id);
           PBSI__PBSI_Purchase_Order_Line__c POtestLine3 = new PBSI__PBSI_Purchase_Order_Line__c(PBSI__Purchase_Order__c = sot.Id, PBSI__Quantity_Ordered__c = 5, PBSI__Item__c = item1.Id);
           PBSI__PBSI_Purchase_Order_Line__c [] polines=new PBSI__PBSI_Purchase_Order_Line__c[] {POtestLine1,POtestLine2,POtestLine3};  
           insert polines;
        
            PBSI__Unit__c unit2 = TestUtil.GetItemUnit(item2.Id);
            insert unit2;
            PBSI__Item_Version__c ver1= TestUtil.GetItemVersion(item1.Id);
            insert ver1;
            PBSI__Bom__c bom11 = TestUtil.CreateBom();
    pbsi__bom__c bom=[select id from pbsi__bom__c where pbsi__item__c=:item1.id];
    pbsi__bom_line__c bl=new pbsi__bom_line__c(pbsi__item__c=item2.id,pbsi__quantity__c=1,pbsi__bom__c=bom.id);
    pbsi__bom_line__c bl2=new pbsi__bom_line__c(pbsi__item__c=item2.id,pbsi__quantity__c=1,pbsi__bom__c=bom.id);
    pbsi__bom_line__c[] bls = new pbsi__bom_line__c[] {bl,bl2};
    insert bls;
    
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
    
     //  PBSI__PBSI_Sales_Order_Line__c soline= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity_Needed__c=1);
    PBSI__PBSI_Sales_Order_Line__c soline1= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10, PBSI__Serial_Number__c='ser1;ser2;ser3',PBSI__Location__c=loc1.Id);
    PBSI__PBSI_Sales_Order_Line__c soline2= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item2.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10,PBSI__Location__c=loc1.Id,  PBSI__Unit_of_Measure__c = unit2.Id,   PBSI__Type__c = 'sale' );
    PBSI__PBSI_Sales_Order_Line__c soline3= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item3.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10,PBSI__Location__c=loc1.Id);
    PBSI__PBSI_Sales_Order_Line__c[] solines = new PBSI__PBSI_Sales_Order_Line__c[]{soline1,soline2,soline3};
    insert solines;

    PBSI__Staging_Order_Lines__c sg=new PBSI__Staging_Order_Lines__c(pbsi__sales_order__c=pwo.id,pbsi__sales_order_line__c=soline2.id,pbsi__item__c=item2.id,pbsi__stage_quantity__c=1);
   	insert sg;

      PBSI__Production_Work_Order__c POtest = new PBSI__Production_Work_Order__c(PBSI__Item__c=item1.Id,PBSI__Quantity__c=2);
      insert POtest;
      
	PBSI__BOM_Depletion_Line__c bl3=new PBSI__BOM_Depletion_Line__c(PBSI__Sales_Order_Line__c=soline1.Id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity__c=25);
	insert bl3;
      
    ApexPages.StandardController controller =new ApexPages.StandardController(pwo);
    PackSoControllerOn pn=new PackSoControllerOn(controller);
    pn.capturelines2();
    pn.capturelines3();
    pn.capturelines4();
    pn.capturelines5();
    pn.capturelines6();
    pn.capturelines7();
    pn.capturelines8();
    pn.capturelines9();
    pn.packAll();
    pn.stageall();
    pn.itemid = item1.Id;
    System.currentPageReference().getParameters().put('col', 'soname');
    pn.sortLines();
    pn.ignorevalidation=true;
    pn.getpacklines()[0].usecarton=true;
    pn.SetLineSerialsStyle(pn.getpacklines()[0]);
    try{
    pn.addOptions(pn.getpacklines()[0]);
    }catch(Exception e){}
    pn.getpacklines()[0].line.pbsi__quantity_shipped__c=8;
    System.currentPageReference().getParameters().put('lineNumber', pn.getpacklines()[0].lineNumber + '');
    pn.deleteChildlines();
    pn.getpacklines()[0].line.pbsi__quantity_shipped__c=1;
    System.currentPageReference().getParameters().put('lineNumber', pn.getpacklines()[0].lineNumber + '');
    pn.deleteChildlines();       
    System.currentPageReference().getParameters().put('lineNumber', pn.getpacklines()[0].lineNumber + '');
    pn.getpacklines()[0].usecarton=false;
    pn.getpacklines()[0].line.pbsi__lot__c=lot.id;
    pn.getpacklines()[1].line.pbsi__lot__c=lot2.id;
    pn.getpacklines()[2].line.pbsi__lot__c=lot2.id;
    pn.getpacklines()[0].oldlot=lot2.id; 
    System.currentPageReference().getParameters().put('lineNumber', pn.getpacklines()[0].lineNumber + '');
    pn.updateLine(); 
    pn.getpacklines()[0].usecarton=true;
    pn.getpacklines()[0].oldinv=inventory.id;
    pn.getpacklines()[0].inventory=inventory.id;
    pn.updateLine();
    pn.updateQty();
    pn.getpacklines()[0].inventory=inventory2.id;
    pn.updateLine();
    pn.updateQty();
    pn.updateQty(true);
   	pn.getpacklines()[1].getuom();
   	pn.getallLocations();
   	pn.getUseUserLocation();
   	pn.getshowtotalqty();
   FFPacksoController ff = new FFPacksoController(controller);
   ff.UpdateQuant = true;
   ff.UpdateQuants();
   ff.setComponentController(null);
   ff.getMyComponentController();
   ff.getalertstatus();
   ff.backtoso();
   //ff.savepacked();
    CommonUtils2.CalculateATPInventoryByLocation(solines);
    CommonUtils2.CalculateATPsolinesByLocation(solines);
    CommonUtils2.CalculateATPpolinesByLocation(solines);
    CommonUtils2.CalculateATPpwosByLocation(solines);
    CommonUtils2.CalculateATPbompwosByLocation(solines);
    set<Id> itemsids = new set<Id>();
    for (PBSI__PBSI_Item__c i: items)
    	itemsids.add(i.Id);    
    Date dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day()); 
  	Map<Id,Map<Id,double>> atpmap = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemsids,false,false);
   	Map<Id,Map<Id,double>> atpmap1 = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemsids,true,true);
   	Map<Id,Map<Id,double>> atpmap2 = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemsids,false,true);    
    Test.stopTest();
}

public static testMethod void TestPackSOcontroller1() 
{
	  PBSI__Admin__c admin =  PBSI__Admin__c.getOrgDefaults();
    admin.PBSI__Use_Ship_Lot_for_SOLine__c = true;
    admin.PBSI__Use_Pallets__c=true;
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
	   PBSI__Tax_Code__c taxcode = new PBSI__Tax_Code__c(Name='TaxxAA',PBSI__Tax_Rate__c=10);
    PBSI__Tax_Code__c taxcode2 = new PBSI__Tax_Code__c(Name='TaxxBB',PBSI__Tax_Rate__c=20);
    PBSI__Tax_Code__c[] taxcodeall= new PBSI__Tax_Code__c[]{taxcode,taxcode2};
    insert taxcodeall;
 Account acc1 = new Account(BillingCity='asasa',Billingstate='nj',BillingStreet='1244555',Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35',PBSI__Tax_Code__c=taxcode.Id, Status__c='Active');
    Account acc2 = new Account(BillingCity='asasa',Billingstate='nj',BillingStreet='1244555',Name = 'efdfsdfsdfqwerty', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35',PBSI__Tax_Code__c=taxcode2.Id ,Status__c='Active');
    Account[] acc3 = new Account[]{acc1,acc2};
    insert acc3;  
     PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
    PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
    PBSI__PBSI_Location__c[] locs = new PBSI__PBSI_Location__c[] {loc1, loc2};
    insert locs ; 
     PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',group_description__c='descr1');
    insert group1 ;  
      PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item1testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223341');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item12testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,ean_number__c='11223342');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='item2testpackso', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223343');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,PBSI__Is_Serialized__c=true,ean_number__c='11223344');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,ean_number__c='11223345');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='item4testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,pbsi__default_vendor__c=acc1.id,ean_number__c='11223346');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
     insert items;
 PBSI__PBSI_Sales_Order__c pwo=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id,PBSI__Order_Discount__c=12,PBSI__Shipping_Discount__c=12,PBSI__Sales_Tax__c=12,PBSI__Shipping_Cost__c=12,PBSI__Misc_Charges__c=10,PBSI__Type__c='Scheduled',PBSI__Schedule_End_Date__c=system.today()+5);
 insert pwo;
 PBSI__PBSI_Sales_Order__c so2=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id,PBSI__Order_Discount__c=12,PBSI__Shipping_Discount__c=12,PBSI__Sales_Tax__c=12,PBSI__Shipping_Cost__c=12,PBSI__Misc_Charges__c=10,PBSI__Type__c='Scheduled',PBSI__Schedule_End_Date__c=system.today()+5);
 insert so2;
 PBSI__PBSI_Sales_Order_Line__c soline1= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10, PBSI__Serial_Number__c='ser1;ser2;ser3');
    PBSI__PBSI_Sales_Order_Line__c soline2= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item2.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10);
    PBSI__PBSI_Sales_Order_Line__c soline3= new PBSI__PBSI_Sales_Order_Line__c(pbsi__vendor__c=acc1.id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item3.Id,PBSI__Quantity_Needed__c=3,PBSI__Price__c=10,PBSI__Taxable__c=true, PBSI__Sales_Tax__c=10);
    PBSI__PBSI_Sales_Order_Line__c[] solines = new PBSI__PBSI_Sales_Order_Line__c[]{soline1,soline2,soline3};
    insert solines;
	 test.starttest();
	 ApexPages.StandardController controller =new ApexPages.StandardController(pwo);
    PackSoControllerOn pn=new PackSoControllerOn(controller);  
    pn.capturelines2();
    pn.capturelines3();
    pn.capturelines4();
    pn.capturelines5();
    pn.capturelines6();
    pn.capturelines7();
    pn.capturelines8();
    pn.capturelines9();
    pn.packAll() ;
    //pn.createMovementLine(pwo.id,item1.id, lot.Id ,lot.Id,87,'657575667','receive',null,78,88,0,76,null);
    //pn.createMovementLine(pwo.id,item1.id, lot.Id ,lot.Id,87,'657575667','sale',   null,78,88,0,76,null);
    pn.checkLotforLocation(false);
    pn.checkLotforLocation(true);
    pn.getpacklines()[0].inventory=null;
     System.currentPageReference().getParameters().put('lineNumber', pn.getpacklines()[0].lineNumber + '');
    pn.updateLine();
    pn.updateLine(true);
    pn.updateQty();
    pn.setOrderStatus();
    System.currentPageReference().getParameters().put('solineid', soline3.Id);
    pn.closeLine();
    
    ApexPages.StandardController controller2 =new ApexPages.StandardController(so2);
    PackSoControllerOn pn2=new PackSoControllerOn(controller2);
    pn2.capturelines2();
    pn2.capturelines3();
    pn2.capturelines4();
    pn2.capturelines5();
    pn2.capturelines6();
    pn2.capturelines7();
    pn2.capturelines8();
    pn2.capturelines9();
    pn2.packAll();
    //pn2.packAll(true,true);
    pn2.setOrderStatus();
    pn2.backtoitem();
    
    
     pn=new PackSoControllerOn(controller);
    System.currentPageReference().getParameters().put('linenodrop',soline1.id + '');
    pn.dropship();
    pn.savepacked();
    for (PackSoControllerOn.SLine p: pn.slines)
       p.isselected=true;
    pn.dropshipall();  
    pn.savepacked();

    
    
    pn.packall();
    pn.createSNT();
    pn.getshowShipLot();
    pn.previos();
    pn.GetPackLineModels();
    pn.getshownavigation();
    
    PBSI__Address_Tracker__c add1=new PBSI__Address_Tracker__c(Name='addss1',PBSI__Account__c=acc1.Id,PBSI__Tax_Code__c=taxcode.id,PBSI__Use_AddressTrackerName_for_Delivery_Comp__c=true);
    PBSI__Address_Tracker__c add2=new PBSI__Address_Tracker__c(Name='addss2',PBSI__Account__c=acc2.Id,PBSI__Tax_Code__c=taxcode2.id);
    PBSI__Address_Tracker__c[] add =  new PBSI__Address_Tracker__c[]{add1,add2};
    insert add;       
    pwo.PBSI__Address_Tracker__c = add2.Id;
    pwo.PBSI__Tax_Code__c=taxcode2.Id;
    pwo.PBSI__Customer__c = acc2.Id;
    update pwo;    
    test.stoptest();
}
public static testMethod void TestPackSOcontroller2() {
    PBSI__Admin__c admin =  PBSI__Admin__c.getOrgDefaults();
    admin.PBSI__Use_Ship_Lot_for_SOLine__c = false;
    admin.PBSI__Use_Pallets__c=true;
    admin.PBSI__Pack_More_than_Needed_on_SO__c=false;
    admin.PBSI__Allow_Packing_0_Qty_Orders__c=true;
    admin.PBSI__Do_Not_Allow_Display_More_Qty_Pack__c=false;
    admin.PBSI__Always_show_serial_number_on_pack_SO__c=false;
    admin.PBSI__Create_SNT_at_Pack_time_for_all_items__c=false;
    admin.pbsi__Don_t_change_SoLine_Q_Pack_on_Drop_Ship__c=false;
    admin.pbsi__Use_Not_Counted_Loc_on_Receive_and_Pack__c=false; 
    admin.PBSI__Use_tax_codes__c=true;
    admin.PBSI__Prevent_So_Packing_if_Status_is__c='Cancelled';
	admin.PBSI__Pack_More_than_Needed_on_SO__c = true;
    admin.PBSI__Use_ATP_by_Locations__c=true;
	admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c=3;
	admin.PBSI__Use_User_Location__c = true;
	    
    //insert admin;
    
    PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
    PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
    PBSI__PBSI_Location__c[] locs = new PBSI__PBSI_Location__c[] {loc1, loc2};
    insert locs ; 
          Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
          try { 
                insert acc1;  
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }     
            Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) { 
                    System.debug(e.getMessage()); 
            }
            PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',group_description__c='descr1');
     
       
                insert group1 ;  
           
            
       PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item1testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223344');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item12testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,ean_number__c='11223345');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='item2testpackso', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223346');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,PBSI__Is_Serialized__c=true,ean_number__c='11223347');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,ean_number__c='11223348');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='item4testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,pbsi__default_vendor__c=acc1.id,ean_number__c='11223349');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
         

        //    try {
                insert items ;
          //  }
            //catch(DmlException e) {
             //   System.debug(e.getMessage()); 
            //}
            
    PBSI__PBSI_Sales_Order__c pwo=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id,PBSI__Order_Discount__c=12,PBSI__Shipping_Discount__c=12,PBSI__Sales_Tax__c=12,PBSI__Shipping_Cost__c=12,PBSI__Misc_Charges__c=10);  
    insert pwo;
       
     //  PBSI__PBSI_Sales_Order_Line__c soline= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity_Needed__c=1);
      
     
      
    PBSI__PBSI_Sales_Order_Line__c soline1= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item3.Id,PBSI__Quantity_Needed__c=3);
    insert soline1;
      
       
      
       PBSI__Lot__c lot=new PBSI__Lot__c(pbsi__item__c=item3.id,pbsi__location__c=loc1.Id);
       insert lot;
       
        PBSI__Serial_Number_Tracker__c sn1=new  PBSI__Serial_Number_Tracker__c(pbsi__item__c=item3.Id,pbsi__serial_number__c='test1');
        PBSI__Serial_Number_Tracker__c sn2=new  PBSI__Serial_Number_Tracker__c(pbsi__item__c=item3.Id,pbsi__serial_number__c='test2');
        PBSI__Serial_Number_Tracker__c sn3=new  PBSI__Serial_Number_Tracker__c(pbsi__item__c=item3.Id,pbsi__serial_number__c='test3');
        PBSI__Serial_Number_Tracker__c[] sns = new PBSI__Serial_Number_Tracker__c[] {sn1, sn2,sn3};
        insert sns ; 

    PBSI__Staging_Order_Lines__c sg=new PBSI__Staging_Order_Lines__c(pbsi__sales_order__c=pwo.id,pbsi__sales_order_line__c=soline1.id,pbsi__item__c=item2.id,pbsi__stage_quantity__c=1);
   	insert sg;

      PBSI__Production_Work_Order__c POtest = new PBSI__Production_Work_Order__c(PBSI__Item__c=item1.Id,PBSI__Quantity__c=2);
     // insert POtest;
      
	PBSI__BOM_Depletion_Line__c bl3=new PBSI__BOM_Depletion_Line__c(PBSI__Sales_Order_Line__c=soline1.Id,PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity__c=25);
	insert bl3;
          Test.startTest();
      
        ApexPages.StandardController controller =new ApexPages.StandardController(pwo);
        PackSoControllerOn pn=new PackSoControllerOn(controller);
    	pn.capturelines2();
	    pn.capturelines3();
	    pn.capturelines4();
	    pn.capturelines5();
	    pn.capturelines6();
    	pn.capturelines7();
    	pn.capturelines8();
    	pn.capturelines9();
        pn.packAll(); 
        pn.SetLineSerialsStyle(pn.getpacklines()[0]);
        try{
        	pn.addOptions(pn.getpacklines()[0]);
    	}catch(Exception e){}
        System.currentPageReference().getParameters().put('lineNumber', pn.getpacklines()[0].lineNumber + '');
        pn.deleteChildlines();
        pn.updateQty();
        pn.DropShipAll();
        pn.getDropShipMessage();
        //pn.savepacked();
        pn.getpacklines()[0].line.pbsi__quantity_shipped__c=-2;
        pn.getpacklines()[0].getnegLot();
        pn.getpacklines()[0].line.pbsi__quantity_shipped__c=3;
        pn.getpacklines()[0].getLot();
        pn.getpacklines()[0].isshipping=false;
        pn.getpacklines()[0].getLot();
        
        
        pn.getpacklines()[0].getshipLot();
      
        pn.getpacklines()[0].getshowsn();
        pn.getpacklines()[0].getislineBomPhantom();
        pn.getpacklines()[0].getisshipping();
        pn.getpacklines()[0].getinvNotNeeded();
      
        pn.getpacklines()[0].line.pbsi__lot__c=lot.Id;
        pn.getpacklines()[0].serialnumbers[0].value='test1';
        pn.getpacklines()[0].serialnumbers[1].value='test2';
        pn.getpacklines()[0].serialnumbers[2].value='test3';
        pn.ignorevalidation=false;
        pn.savepacked();
        pn.packAll();
        pn.getpacklines()[0].line.pbsi__quantity_shipped__c=1;
        pn.getpacklines()[0].line.pbsi__quantity_shipped__c=3;
                     
        pn.getpacklines()[0].serialnumbers[0].value='test1'; 
        pn.getpacklines()[0].serialnumbers[1].value='test2'; 
        pn.getpacklines()[0].serialnumbers[2].value='test3';
        pn.ignorevalidation=true;
        pn.savepacked();
        pn.packAll();
      
            
        pn.savepacked();    
        pn.checkLotforLocation(false);
        pn.getDropShipMessage();
        pn.getshowItemSN(); 
        pn.getisoneserialized();
        pn.getsalesorder();
        pn.getshowShipLot();
        pn.getlistsize();
        pn.getusingcartonarea();
        pn.getalertstatus();
        pn.getispacksummary();
        pn.getlines();
        pn.createSNT();
     
        sn1.PBSI__New_Date_Received__c=system.today();
        sn2.PBSI__New_Date_Received__c=system.today();
        sn3.PBSI__New_Date_Received__c=system.today();
          
        //update sn1;update sn2;update sn3;
    update sns;
        pn.savepacked();   
            pn.ignorevalidation=true;
    pn.savestaged(); 
        pn.backtoso();
      //  pn.CreateNewSLine();
        pn.getssol();
        pn.selectAllLines();
       // Pack4SOControllerNew.Packline drop=new Pack4SOControllerNew.Packline(soline1,123);
        pn.backtoitem();
        test.stoptest();
  }
   
public static testMethod void TestPackSOcontroller12() {
    PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
    PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
    PBSI__PBSI_Location__c[] locs = new PBSI__PBSI_Location__c[] {loc1, loc2};
    insert locs ; 
          Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
            try {
                insert acc1; 
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }     
            Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) { 
                    System.debug(e.getMessage()); 
            }
            PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',group_description__c='descr1');
     
       
                insert group1 ;
        
            
      PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item1testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223344');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item12testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,ean_number__c='11223345');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='item2testpackso', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223346');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,PBSI__Is_Serialized__c=true,ean_number__c='11223347');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,ean_number__c='11223348');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='item4testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,pbsi__default_vendor__c=acc1.id,ean_number__c='11223349');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
             // try {
                insert items ;
           // }
           // catch(DmlException e) {
            //    System.debug(e.getMessage()); 
            //}
            PBSI__Maintenance__c mm=new PBSI__Maintenance__c(pbsi__item__c=item4.Id);
      insert mm;
      PBSI__Maintenance_Lines__c mlm=new PBSI__Maintenance_Lines__c(pbsi__item__C=item1.Id,PBSI__Quantity__c=1,PBSI__Period__c=1,PBSI__Maintenance__c=mm.Id);
      
      insert mlm;
                  PBSI__PBSI_Sales_Order__c pwo=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id,PBSI__Contact__c=contact.Id);  
       insert pwo;
       
           System.currentPageReference().getParameters().put('id',pwo.Id);
      
      List<PBSI__PBSI_Sales_Order_Line__c> soLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
      
      PBSI__PBSI_Sales_Order_Line__c soline3= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item4.Id,PBSI__Quantity_Needed__c=3);     
      soLines.add(soline3);
      
      PBSI__PBSI_Sales_Order_Line__c soline4= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item4.Id,PBSI__Quantity_Needed__c=3);
      soLines.add(soline4);
      
      PBSI__PBSI_Sales_Order_Line__c soline5= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity_Needed__c=3);
      soLines.add(soline5);
      
      insert soLines;
      
      PBSI__Invoice__c i=new PBSI__Invoice__c(PBSI__Sales_Order__c=pwo.Id,pbsi__Shipping_Cost__c=0,pbsi__Sales_Tax__c=20);
      insert i; 
      
      PackSoControllerOn pn2=new PackSoControllerOn();
      System.currentPageReference().getParameters().put('linenodrop',soline3.Id);
      pn2.ignorevalidation=true;
      pn2.dropship();
      pn2.DropShipAll();
      pn2.savepacked();
      pn2.backtoso();
      pn2.gethasdropship();
      
      PBSI__BOM_Depletion_Line__c bl=new PBSI__BOM_Depletion_Line__c(pbsi__sales_order_line__c=soline5.id,pbsi__item__C=item2.Id,pbsi__quantity__c=1);
      insert bl;
     
        test.startTest();
        System.currentPageReference().getParameters().put('id',pwo.Id);
        PackSoControllerOn pn3=new PackSoControllerOn();
        System.currentPageReference().getParameters().put('lineNo',soline5.Id);
        pn3.ignorevalidation=true;
        pn3.pack();
        pn3.getpacklines()[0].line.pbsi__quantity_shipped__C=1;
        pn3.getpacklines()[1].isshipping=false;
        pn3.getpacklines()[1].getLocation();
        pn3.checkLotforLocation(false);
        pn3.savepacked();
        pn3.packAll();
        pn3.savepacked();
        pn3.next();
        pn3.setcurin(0);
        pn3.getcurin();
        pn3.getcurentindex();
        pn3.backtoso();
        test.stopTest();
} 

public static testMethod void TestPack4SOControllerNew3() {
    PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
 PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
    PBSI__PBSI_Location__c[] locs = new PBSI__PBSI_Location__c[] {loc1, loc2};
    insert locs ; 
          
          Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
            try {
                insert acc1; 
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }     
            Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) { 
                    System.debug(e.getMessage()); 
            }
            PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',group_description__c='descr1');
     
       
                insert group1 ;
        
            
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item1testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223344');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item12testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,ean_number__c='11223345');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='item2testpackso', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223346');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,PBSI__Is_Serialized__c=true,ean_number__c='11223347');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,ean_number__c='11223348');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='item4testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,pbsi__default_vendor__c=acc1.id,ean_number__c='11223349');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
            //try {
                insert items ;
            //}
            //catch(DmlException e) {
              //  System.debug(e.getMessage()); 
            //}
            
        PBSI__BOM__c item12BOM = TestUtil.CreateBom(item12.Id); 
        insert item12BOM;
        
        PBSI__BOM_Line__c item12BomLine = TestUtil.GetBomLine(item3.Id, item12BOM.Id);
        insert item12BomLine; 
            
            PBSI__Maintenance__c mm=new PBSI__Maintenance__c(pbsi__item__c=item4.Id);
      insert mm;
      PBSI__Maintenance_Lines__c mlm=new PBSI__Maintenance_Lines__c(pbsi__item__C=item1.Id,PBSI__Quantity__c=1,PBSI__Period__c=1,PBSI__Maintenance__c=mm.Id);
      
      insert mlm;
       test.startTest();
                  PBSI__PBSI_Sales_Order__c pwo=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id,PBSI__Contact__c=contact.Id);  
       insert pwo;
       
           System.currentPageReference().getParameters().put('id',pwo.Id);
      
      List<PBSI__PBSI_Sales_Order_Line__c> soLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
      
      PBSI__PBSI_Sales_Order_Line__c soline3= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item4.Id,PBSI__Quantity_Needed__c=3);     
      soLines.add(soline3);
      
      PBSI__PBSI_Sales_Order_Line__c soline4= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item4.Id,PBSI__Quantity_Needed__c=3);
      soLines.add(soline4);
      
      PBSI__PBSI_Sales_Order_Line__c soline5= new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,PBSI__Item__c=item1.Id,PBSI__Quantity_Needed__c=3);
      soLines.add(soline5);
     
      insert soLines;
      
      PackSOControllerOn pn2=new PackSOControllerOn();
      System.currentPageReference().getParameters().put('linenodrop',soline3.Id);
      pn2.ignorevalidation=true;
      pn2.dropship();
      pn2.DropShipAll();
      pn2.savepacked();
      pn2.backtoso();
      
      PBSI__BOM_Depletion_Line__c bl=new PBSI__BOM_Depletion_Line__c(pbsi__sales_order_line__c=soline5.id,pbsi__item__C=item2.Id,pbsi__quantity__c=1);
      insert bl;
      
      
       ApexPages.StandardController controller =new ApexPages.StandardController(pwo);
     
       PBSI__Property__c prop;
       try
       {
       prop=[select id from PBSI__Property__c where pbsi__property_name__c='Lot_Usage'  ];
       }
       catch(exception e){}
       
       if (prop == null)
       
        {
          prop =new PBSI__Property__c(pbsi__property_name__c ='Lot_Usage',pbsi__property_value__c = 'No');
     
          insert prop;
        }
        else
        {
        prop.pbsi__property_value__c='No';
        update prop; 
        }

      
        

        

        
 
        test.stopTest();      
    }   
    public static testMethod void TestPack4SOControllerNew4()    
    {
    	      Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
            try {
                insert acc1; 
            }
            catch(DmlException e) {
                    System.debug(e.getMessage());
            }  
    	 PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
    	 insert loc1;
    	     PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',group_description__c='descr1');
     
       
                insert group1 ;
        
            
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item1testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223344');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom',name='item12testpackso', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,ean_number__c='11223345');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='item2testpackso', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,ean_number__c='11223346');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,PBSI__Is_Serialized__c=true,ean_number__c='11223347');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='item3testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,ean_number__c='11223348');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='item4testpackso', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,pbsi__default_vendor__c=acc1.id,ean_number__c='11223349');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
            //try {
                insert items ;
    	
    	
    	        PBSI__Lot__c lot12=new PBSI__Lot__c(pbsi__item__c=item12.id,pbsi__location__c=loc1.Id);
        insert lot12;
                       PBSI__PBSI_Sales_Order__c pwo=new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id);  
       insert pwo;
    
        PBSI__PBSI_Sales_Order_Line__c soline12 = new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c=pwo.Id,
                                                                                     PBSI__Item__c=item12.Id,
                                                                                     PBSI__Quantity_Needed__c=1);
      
        insert soline12;
    	  PBSI__BOM_Depletion_Line__c blSoline12=new PBSI__BOM_Depletion_Line__c(pbsi__sales_order_line__c=soline12.id,
                                                                               pbsi__item__C=item12.Id,
                                                                               pbsi__quantity__c=1);
        insert blSoline12;

        PBSI__Staging_Order_Lines__c sg=new PBSI__Staging_Order_Lines__c(pbsi__sales_order__c=pwo.id,pbsi__sales_order_line__c=soline12.id,pbsi__item__c=item12.id,pbsi__stage_quantity__c=1);
        insert sg;
        
        
        PBSI__PBSI_Inventory__c item12Inv = new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c = item12.Id,
                                                                        PBSI__Lot__c = lot12.Id,
                                                                        PBSI__location_lookup__c = loc1.Id,
                                                                        PBSI__qty__c = 3);
        PBSI__PBSI_Inventory__c item13Inv = new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c = item12.Id,
                                                                        PBSI__Lot__c = lot12.Id,
                                                                        PBSI__location_lookup__c = loc1.Id,
                                                                        PBSI__qty__c = 5);
        PBSI__PBSI_Inventory__c[] itemInvs = new PBSI__PBSI_Inventory__c[] {item12Inv, item13Inv};
        insert itemInvs ; 
        
        pwo.PBSI__Type__c = 'Scheduled';
        update pwo;
        test.startTest();
 		User us = TestUtil.createAdminUser('admin@on.com');
 		On_Payment_Terms__c op1 = TestUtil.createPaymentTerms(10);
    	soline12.PBSI__Use_ExactShip__c = true;
        soline12.PBSI__Do_Not_Ship_Yet__c = false;
        update soline12;
         ApexPages.StandardController controller =new ApexPages.StandardController(pwo);
    	PackSoControllerOn        pn2 = new PackSoControllerOn(controller);
        System.currentPageReference().getParameters().put('lineNo',soline12.Id);
        pn2.pack();
        pn2.getpacklines()[0].line.pbsi__quantity_shipped__c = 3;
        pn2.savepacked();
        System.currentPageReference().getParameters().put('lineNumber','1');
        pn2.deleteChildlinesstage();
    	       controller =new ApexPages.StandardController(pwo);
        pn2 = new PackSoControllerOn(controller);
        pn2.packAll();  
        //pn2.SetLineSerialsStyle(pn2.getpacklines()[0], 6);
		try{        
        pn2.addOptions(pn2.getpacklines()[0]);
    	}catch(Exception e){}
       // pn2.addOptions(pn2.getpacklines()[0], true);
        pn2.savepacked();
        pn2.getusepallets();
        pn2.UpdateLinesLotQty(1, 3, 1, lot12.Id);
        pn2.UpdateLinesLotQty(1, 3, 1, lot12.Id, true);
        test.stopTest();
    }
}