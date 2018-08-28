@RestResource(urlMapping='/osca/poline')
global without sharing class OscaPOLineREST  {

    public class ArgumentException extends Exception {}
    private static LogService logSrv = LogService.getlogService();

    @HttpPost
    global static String createLine() {

        Response res = new Response();

        String requestString = RestContext.request.requestBody.toString();
        try {
            logSrv.addDebug()
                .type('OSCA inbount insert POLine')
                .attachment('request-create.json', requestString);
            List<PBSI__PBSI_Purchase_Order_Line__c> lLinesToInsert = new List<PBSI__PBSI_Purchase_Order_Line__c>(); 
            Map<Id, PBSI__PBSI_Purchase_Order_Line__c> mLinesReceived = new Map<Id, PBSI__PBSI_Purchase_Order_Line__c>(
                (List<PBSI__PBSI_Purchase_Order_Line__c>) JSON.deserialize(requestString, List<PBSI__PBSI_Purchase_Order_Line__c>.class)
            );


            Set<Id> sExistingLinesIds = mLinesReceived.keySet();
            String query = 'SELECT Id,' + getPOLineCreatableFields() + ' FROM PBSI__PBSI_Purchase_Order_Line__c WHERE Id IN :sExistingLinesIds';
            System.debug(query);
            logSrv.addDebug().info(query);
            Map<Id, PBSI__PBSI_Purchase_Order_Line__c> mExistingLines = new Map<Id, PBSI__PBSI_Purchase_Order_Line__c>(
                (List<PBSI__PBSI_Purchase_Order_Line__c>)Database.query(query)
            );

            for(PBSI__PBSI_Purchase_Order_Line__c lineReceived: mLinesReceived.values()) {
                PBSI__PBSI_Purchase_Order_Line__c lineExisting = mExistingLines.get(lineReceived.Id);
                if(lineExisting == null) {
                    throw new ArgumentException('Line with following Id don\'t exist, can\'t clone: '+lineReceived.Id);
                }
                PBSI__PBSI_Purchase_Order_Line__c lineToCreate = lineExisting.clone(false, true, false, false);
                Map<String,Object> receivedLinePopulatedFields = lineReceived.getPopulatedFieldsAsMap();

                for(String fName: receivedLinePopulatedFields.keySet()) {
                    lineToCreate.put(fName, receivedLinePopulatedFields.get(fName));
                }

                lineToCreate.Id = null;
                lLinesToInsert.add(lineToCreate); 
            }


            insert lLinesToInsert;
        } catch(Exception e) {
            res.setError(e);
            logSrv.addError().exception(e);
        }
        return returnResponse(res);
    }

    @HttpPut
    global static String updateLine() {

        Response res = new Response();

        String requestString = RestContext.request.requestBody.toString();
        try {
            logSrv.addDebug()
                .type('OSCA inbount update POLine')
                .attachment('request-update.json', requestString);
            List<PBSI__PBSI_Purchase_Order_Line__c> lLinesToUpdate = (List<PBSI__PBSI_Purchase_Order_Line__c>) 
                JSON.deserialize(requestString, List<PBSI__PBSI_Purchase_Order_Line__c>.class);
            update lLinesToUpdate;
            OSCA_StagingService srv = new OSCA_StagingService();
            srv.updateStagingObject(lLinesToUpdate);
            srv.insertStagingObjects();
        } catch(Exception e) {
            res.setError(e);
        }
        return returnResponse(res);

    }

    @HttpDelete
    global static String cancelLine() {

        Response res = new Response();

        String requestString = RestContext.request.params.get('id');
        
        try {
            logSrv.addDebug()
                .type('OSCA inbount cancel POLine')
                .attachment('request-cancel.json', requestString);
            
            List<String> polineIdsReceived = new List<String>();
            if(!String.isBlank(requestString)) {
                polineIdsReceived = requestString.split(',');
            }
            if(polineIdsReceived.isEmpty()) {
                throw new ArgumentException('PO Line Id(s) missing');
            }
            List<Id> poLineIds = new List<Id>();
            for(String tmpId: polineIdsReceived) {
                poLineIds.add((Id) tmpId);
            }
            Set<Id> sIds = new Set<Id>(polineIds);

            Map<Id, PBSI__PBSI_Purchase_Order_Line__c> mapLines = new Map<Id, PBSI__PBSI_Purchase_Order_Line__c>(
                [SELECT Id, PBSI__Quantity_Ordered__c, PBSI__Quantity_Received__c 
                    FROM PBSI__PBSI_Purchase_Order_Line__c
                    WHERE Id IN :sIds]);
            sIds.removeAll(mapLines.keySet());
            if(!sIds.isEmpty()) {
                throw new ArgumentException('Invalid id: ' + sIds);
            }
            for(PBSI__PBSI_Purchase_Order_Line__c line: mapLines.values()) {
                if(line.PBSI__Quantity_Received__c > 0) {
                    throw new ArgumentException('Can\'t cancel line that has been received: ' + line.Id);
                }
                line.Cancelled_Quantity__c = line.PBSI__Quantity_Ordered__c;
                line.PBSI__Quantity_Ordered__c = 0;
                line.PBSI__Status__c = 'Cancelled';
            }
            update mapLines.values();
        } catch(Exception e) {
            res.setError(e);
        }

        return returnResponse(res);

    }

    public static String getPOLineCreatableFields() {
        return 'CurrencyIsoCode,PBSI__Purchase_Order__c,PBSI__Allow_manual_update_of_Qty_Received__c,'+
        'PBSI__Area__c,PBSI__BOM__c,PBSI__Carton__c,PBSI__Closed__c,PBSI__Createdate__c,PBSI__Discount__c,'+
        'PBSI__Due_Date__c,PBSI__Estimated_Production_Time__c,PBSI__HasInstructions__c,'+
        'PBSI__ItemDescription__c,PBSI__Item_Description_Long__c,PBSI__Item_Description__c,'+
        'PBSI__Item__c,PBSI__Lines_Have_Been_Added__c,PBSI__Location__c,PBSI__Lot__c,PBSI__Price4__c,'+
        'PBSI__Price__c,PBSI__Purchase_Order_Line__c,PBSI__Quantity_Ordered__c,PBSI__Quantity_Received__c,'+
        'PBSI__RMA_Line__c,PBSI__Sales_Order__c,PBSI__Serial_Numbers_To_Receive__c,'+
        'PBSI__Starting_SN_Received__c,PBSI__Starting_Serial_Number__c,PBSI__Status__c,'+
        'PBSI__Trade_Agreement__c,PBSI__Type__c,PBSI__Unit_of_Measure__c,PBSI__Vendor_Item_ID__c,'+
        'Ascent2FF__Input_Vat_Code__c,PBSI__Exchange_Rate__c,PBSI__Org_Exchange_Rate__c,'+
        'PBSI__Discount_Amount__c,PBSI__Item_Net_Weight__c,PBSI__Original_SO_Line__c,'+
        'PBSI__Department__c,PBSI__Item_Family__c,PBSI__Return_Line__c,Requested_in_house_date__c,'+
        'OSCA_integration__c,Cancelled_Quantity__c,Osca_OrderId__c,'+
        'Osca_ScheduleId__c';
    }

    private static String returnResponse(Response res) {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = res.code;
        logSrv.save();
        return JSON.serialize(res);
    }

    public class Response {
        public Integer code;
        public String status;
        public String message;
        public Response() {
            code = 200;
            status = 'OK';
            message = '';
        }
        public void setError(Exception e) {
            code = 400;
            status = 'BAD_REQUEST';
            message = e.getMessage();
        }
    }

}