public with sharing class PartialSOBodGeneratorController {
    public String orderStageId {get; set;}
    public List<PBSI__Shipped_Sales_Order_Line__c> lOrderLines {get; set;}
    public Id orderId;

    public PartialSOBodGeneratorController(){
        this.orderId = ApexPages.currentPage().getParameters().get('SalesOrderId');
    }

    public List<Selectoption> getOrderStages(){
        List<Selectoption> stages = new List<Selectoption>();
        stages.add(new selectOption('', '- None -'));
        for(Order_Stage__c order :[SELECT Id, Name FROM Order_Stage__c WHERE Sales_Order__c = : this.orderId AND Stage__c = 'Finished']) {
            stages.add(new selectoption(order.id,order.name));
        }
        return stages;
    }

    public void getShippedOrderLines(){
        List<Schema.FieldSetMember> fsMembers =  Schema.SObjectType.PBSI__Shipped_Sales_Order_Line__c.fieldSets.getMap().get('Order_Stage_Page').getFields();
        String query = 'Select ';
        for(Schema.FieldSetMember fsm : fsMembers) {
            query += fsm.getFieldPath() + ', ';
        }
        query += 'Id FROM PBSI__Shipped_Sales_Order_Line__c WHERE pbsi__sales_order__c = \'' + this.orderId + '\' AND Notification_transaction__c = :orderStageId';
        lOrderLines = Database.query(query);
    }

    public PageReference congaURL(){
        CongaMsgBuilder cmb = new CongaMsgBuilder(ApexPages.currentPage().getParameters().get('SalesOrderId'), UserInfo.getSessionId());
        HttpRequestBuilder output = cmb.getPartialBodBuilder(orderStageId);
        output.setParam('OFN', 'Bill+of+Delivery');
        output.setParam('APIMode', '1');
        output.setParam('UF0', '1');
        output.setParam('SC0', '1');
        output.setParam('SC1', 'Attachments');
        HttpResponse resp = output.sendRequest();
        String url = System.URL.getSalesforceBaseURL().toExternalForm() + '/servlet/servlet.FileDownload?file=' + resp.getBody();
        return(new PageReference(url));
    }

    public PageReference goBack(){
        String url = System.URL.getSalesforceBaseURL().toExternalForm() + '/' + this.orderId;
        return(new PageReference(url));
    }
}