global virtual class B24DesadvController {

    public class ValidationException extends Exception {}
    public class OrderTypeNotSupportedException extends Exception {}

    private static final String FEDEX_CARRIER_CODE = 'FDEG';

    public Id sObjId {get; protected set;}
    public String orderNumber {get; protected set;}
    public String orderType {get; protected set;}
    public List<LineWrapper> lines {get; set;}
    public String packageNumber {get; set;}
    public Account deliveryParty {get; set;}
    public Account ultimateCosginee {get; set;}
    public PBSI__PBSI_Location__c fromLocation {get; set;}
    public PBSI__PBSI_Location__c toLocation {get; set;}
    public List<String> pkgNumbersUsed {get; set;}

    protected List<Id> linesToSendIds;

    protected B24MessageFactory msgFactory;
    private B24MessageSend msgSend;

    webservice static Boolean hasOrderStages(Id objId) {
        Boolean ret = false;
        if(objId.getSobjectType() == PBSI__PBSI_Sales_Order__c.sObjectType) {
            ret = ![SELECT Id FROM Order_Stage__c WHERE Sales_Order__c = :objId].isEmpty();
        } else if(objId.getSobjectType() == PBSI__Transfer_Order__c.sObjectType) {
            ret = ![SELECT Id FROM Order_Stage__c WHERE Transfer_Order__c = :objId].isEmpty();
        }
        return ret;
    }

    public Boolean isTransferOrder() {
        return orderType == PBSI__Transfer_Order__c.getSObjectType().getDescribe().getName();
    }

    public Boolean isSalesOrder() {
        return orderType == PBSI__PBSI_Sales_Order__c.getSObjectType().getDescribe().getName();
    }

    public B24DesadvController() {
        sObjId = ApexPages.currentPage().getParameters().get('id');
        msgFactory = new B24MessageFactory();
        msgSend = new B24MessageSend();
        pkgNumbersUsed = new List<String>();
        orderType = sObjId.getSObjectType().getDescribe().getName();

        if(isTransferOrder()) {
            PBSI__Transfer_Order__c transferOrder = [SELECT Id,Name,PBSI__From_Location__r.Id,PBSI__From_Location__r.Name,PBSI__From_Location__r.GLN__c,PBSI__To_Location__r.Id,PBSI__To_Location__r.Name,
                        PBSI__To_Location__r.GLN__c,Customer_PO__c,CreatedDate,
                    Delivery_Party_Account__r.Id,Delivery_Party_Account__r.GLN__c,Delivery_Party_Account__r.Name,
                    Ultimate_Cosignee_Account__r.Id,Ultimate_Cosignee_Account__r.GLN__c,Ultimate_Cosignee_Account__r.Name,
                    City__c,Country__c,State__c,Postal_Code__c,Address_Line_1__c,Address_Line_2__c,
                    UC_City__c,UC_Address_Line_1__c,UC_Address_Line_2__c,UC_Country__c,UC_State__c,UC_Postal_Code__c
                FROM PBSI__Transfer_Order__c
                WHERE Id = :sObjId];

                deliveryParty = transferOrder.Delivery_Party_Account__r != null ? transferOrder.Delivery_Party_Account__r : new Account();
                ultimateCosginee = transferOrder.Ultimate_Cosignee_Account__r != null ? transferOrder.Ultimate_Cosignee_Account__r : new Account();
                fromLocation = transferOrder.PBSI__From_Location__r;
                toLocation = transferOrder.PBSI__To_Location__r;
                orderNumber = transferOrder.Name;
                deliveryParty.ShippingCity = transferOrder.City__c;
                deliveryParty.ShippingCountry = transferOrder.Country__c;
                deliveryParty.ShippingState = transferOrder.State__c;
                deliveryParty.ShippingPostalCode = transferOrder.Postal_Code__c;
                deliveryParty.ShippingStreet = transferOrder.Address_Line_1__c;
                if(!String.isBlank(transferOrder.Address_Line_2__c)) {
                    deliveryParty.ShippingStreet += ' '+transferOrder.Address_Line_2__c;
                }
                ultimateCosginee.ShippingCity = transferOrder.UC_City__c;
                ultimateCosginee.ShippingCountry = transferOrder.UC_Country__c;
                ultimateCosginee.ShippingState = transferOrder.UC_State__c;
                ultimateCosginee.ShippingPostalCode = transferOrder.UC_Postal_Code__c;
                ultimateCosginee.ShippingStreet = transferOrder.UC_Address_Line_1__c;
                if(!String.isBlank(transferOrder.UC_Address_Line_2__c)) {
                    ultimateCosginee.ShippingStreet += ' '+transferOrder.UC_Address_Line_2__c;
                }
        } else if(isSalesOrder()) {
            PBSI__PBSI_Sales_Order__c salesOrder = [SELECT Id,Name,PBSI__From_Location__r.Id,PBSI__From_Location__r.Name,PBSI__From_Location__r.GLN__c,
                    PBSI__Customer__r.Id,PBSI__Customer__r.Name,PBSI__Customer__r.GLN__c,Sales_Order_Type__c,
                        PBSI__Delivery_Company__c,PBSI__Delivery_ATTN_to_Phone__c,PBSI__Delivery_Streetnew__c,PBSI__Delivery_Address_line2__c,PBSI__Delivery_City__c,PBSI__Delivery_Country__c,
                        PBSI__Delivery_State__c,PBSI__Delivery_Postal_Code__c
                FROM PBSI__PBSI_Sales_Order__c
                WHERE Id = :sObjId];
                deliveryParty = salesOrder.PBSI__Customer__r != null ? salesOrder.PBSI__Customer__r : new Account();
                deliveryParty.Name = salesOrder.PBSI__Delivery_Company__c;
                deliveryParty.ShippingCity = salesOrder.PBSI__Delivery_City__c;
                deliveryParty.ShippingCountry = salesOrder.PBSI__Delivery_Country__c;
                deliveryParty.ShippingState = salesOrder.PBSI__Delivery_State__c;
                deliveryParty.ShippingPostalCode = salesOrder.PBSI__Delivery_Postal_Code__c;
                deliveryParty.ShippingStreet = salesOrder.PBSI__Delivery_Streetnew__c;
                if(!String.isBlank(salesOrder.PBSI__Delivery_Address_line2__c)) {
                    deliveryParty.ShippingStreet += ' '+salesOrder.PBSI__Delivery_Address_line2__c;
                }
                ultimateCosginee =  new Account();
                fromLocation = salesOrder.PBSI__From_Location__r;
                toLocation = new PBSI__PBSI_Location__c();
                orderNumber = salesOrder.Name;
        } else {
            throw new OrderTypeNotSupportedException(orderType);
        }
        createLinesWrappers();

        packageNumber = '';
        initialWarnings();

        String deliveryCountry = deliveryParty.ShippingCountry;
        if(!String.isEmpty(deliveryCountry)) {
            if(deliveryCountry.equalsIgnoreCase('United States') || deliveryCountry.equalsIgnoreCase('Canada')) {
                selectedCarrier = FEDEX_CARRIER_CODE;
            }
        }
    }

    public virtual void createLinesWrappers() {
        lines = new List<LineWrapper>();
        if(isTransferOrder()) {
            for(PBSI__Shipped_Tranfer_Line__c line: [SELECT Id,Name,PBSI__Item__r.Name,PBSI__Item__r.EAN_Number__c,PBSI__Quantity__c, CreatedDate, DESADV_sent__c
                    FROM PBSI__Shipped_Tranfer_Line__c WHERE PBSI__Transfer_Order__c = :sObjId AND DESADV_sent__c = false]) {
                lines.add( new LineWrapper(line) );
            }
        } else {
            for(PBSI__Shipped_Sales_Order_Line__c line: [SELECT Id,Name, PBSI__Item__r.Name, PBSI__Item__r.EAN_Number__c,PBSI__Quantity_Shipped__c, PBSI__Sales_Order_Line__r.Line_Order_Number__c,
                        CreatedDate, DESADV_sent__c
                        FROM PBSI__Shipped_Sales_Order_Line__c WHERE PBSI__Sales_Order__c = :sObjId AND DESADV_sent__c = false]) {
                lines.add( new LineWrapper(line) );
            }
        }

    }

    public void initialWarnings() {
        if(ultimateCosginee.GLN__c == null) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.WARNING, 
                    'Ultimate cosignee GLN number is empty ant it won\'t be used. In case when target store is different from shipping location it is not correct.')
            );
        }
        if(deliveryParty.GLN__c == null) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.WARNING, 
                    'Delivery Party GLN number is empty ant DESADV won\'t be sent.')
            );
        }
    }

    public void selectAllLines() {
        for(LineWrapper line: lines) {
            if(!line.sent) {
                line.toSend = true;
            }
        }
    }

    public void unselectAllLines() {
        for(LineWrapper line: lines) {
            if(!line.sent) {
                line.toSend = false;
            }
        }
    }

    public void sendDesadv() {
        List<LineWrapper> linesToSend = new List<LineWrapper>();
        linesToSendIds = new List<Id>();
        for(LineWrapper line: lines) {
            if(line.toSend && !line.sent) {
                linesToSend.add(line);
                linesToSendIds.add(line.lineId);
            }
        }
        System.debug(linesToSend);
        
        Map<Id, SObject> linesFromDB;
        try {
            if(deliveryParty.GLN__c == null) {
                throw new ValidationException('Delivery Party GLN is empty. Please fill proper account on order first');
            }
            if(String.isBlank(packageNumber)) {
                throw new ValidationException('Package number is empty');
            } else {
                packageNumber = packageNumber.trim();
            }
            if(linesToSend.isEmpty()) {
                throw new ValidationException('No lines selected');
            }
            linesFromDB = new Map<Id, SObject>(Database.query('SELECT Id FROM '+ linesToSendIds[0].getSObjectType().getDescribe().getName() 
                +' WHERE Id IN :linesToSendIds AND DESADV_sent__c = false FOR UPDATE'));
            if(linesToSend.size() != linesFromDB.values().size() && !Test.isRunningTest()) {
                throw new ValidationException('Lines state has changed in databse, please refresh page.');
            }
        } catch(Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
            );
            return;
        }
        
        String msg = createJsonString();
        System.debug(msg);
        B24MessageSend.MessageResponse res;
        if(!Test.isRunningTest()) {
            res = msgSend.sendDespatchAdvice(msg);
        } else {
            res = new B24MessageSend.MessageResponse();
        }
        Attachment attMsg = new Attachment(
            ParentId = sObjId,
            Name = 'desadv-' + res.Id +'.json',
            Body = Blob.valueOf(msg)
        );
        Attachment attMsgRes = new Attachment(
            ParentId = sObjId,
            Name = 'response-' + res.Id +'.json',
            Body = Blob.valueOf(JSON.serialize(res))
        );


        for(LineWrapper line: linesToSend) {
            line.sent = true;
            line.packageNumber = packageNumber;
            linesFromDB.get(line.lineId).put('DESADV_sent__c', true);
        }
        pkgNumbersUsed.add(packageNumber);
        packageNumber = '';
        insert new List<Attachment> {attMsg, attMsgRes};
        update linesFromDB.values();
        ApexPages.addMessage(
            new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Lines sent')
        );
    }

    protected virtual String createJsonString() {
        return msgFactory.desadv(sObjId, new Set<Id>(linesToSendIds), packageNumber, selectedCarrier);
    }

    public PageReference retLink() {
        return new PageReference('/'+sObjId);
    }

    public String selectedCarrier {get; set;}

    public List<SelectOption> getCarrierCodes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        options.add(new SelectOption(FEDEX_CARRIER_CODE, FEDEX_CARRIER_CODE));      
        return options;
       
    }

    public class LineWrapper {
        public String lineId {get; set;}
        public String name {get; set;}
        public String itemNumber {get; set;}
        public String itemEan {get; set;}
        public Integer quantity {get; set;}
        public Boolean toSend {get; set;}
        public Boolean sent {get; set;}
        public String created {get; set;}
        public String packageNumber {get; set;}

        private LineWrapper() {
            toSend = true;
            sent = false;
            packageNumber = '';
        }

        public LineWrapper(PBSI__Shipped_Tranfer_Line__c line) {
            this();
            lineId = line.Id;
            name = line.Name;
            itemNumber = line.PBSI__Item__r.Name;
            itemEan = line.PBSI__Item__r.EAN_Number__c;
            quantity = (Integer) line.PBSI__Quantity__c;
            created = line.CreatedDate != null ? line.CreatedDate.format() : '';
            sent = line.DESADV_sent__c;
            toSend = !sent;
        }

        public LineWrapper(PBSI__Shipped_Sales_Order_Line__c line) {
            this();
            lineId = line.Id;
            name = line.Name;
            itemNumber = line.PBSI__Item__r.Name;
            itemEan = line.PBSI__Item__r.EAN_Number__c;
            quantity = (Integer) line.PBSI__Quantity_Shipped__c;
            created = line.CreatedDate != null ? line.CreatedDate.format() : '';
            sent = line.DESADV_sent__c;
            toSend = !sent;
        }
    }

}