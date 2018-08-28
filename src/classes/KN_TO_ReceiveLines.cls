@RestResource(urlMapping='/kn/to/receiveLines/*')
global with sharing class KN_TO_ReceiveLines  {
    /*
    public class LineException extends Exception {}

    private static String responseMsg = 'OK';
    private static Integer responseCode = 200;
    private static List<PBSI__Received_Transfer_Line__c> lReceivedLines = new List<PBSI__Received_Transfer_Line__c>();

    @HttpPost
    global static String post() {
        LogService logSrv = LogService.getlogService();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {

            ReceivedTO recivedOrder = (ReceivedTO) JSON.deserialize(req.requestBody.toString(), ReceivedTO.class);
            Map<String, PBSI__Shipped_Tranfer_Line__c> mapItem2Line = createMapItem2Line(recivedOrder);

            for(ReceivedLine rLine: recivedOrder.lines) {
                PBSI__Shipped_Tranfer_Line__c shippedLine = mapItem2Line.get(rLine.itemNumber);
                if(shippedLine == null) {
                    throw new LineException('Following Item was not shipped in this Transfer Order: '+rLine.itemNumber);
                }
                lReceivedLines.add(
                    createRecivedLine(rLine, shippedLine)
                );
            }

            insert lReceivedLines;
        } catch(JSONException e) {
            setResponse(400, 'Malformed JSON');
        } catch(LineException e) {
            setResponse(404, e.getMessage());
        } catch(Exception e) {
            setResponse(400, e.getMessage());
        }

        logSrv.save();
        res.statusCode = responseCode;
        return responseMsg;

    }

    private static Map<String, PBSI__Shipped_Tranfer_Line__c> createMapItem2Line(ReceivedTO recivedOrder) {
        Set<Id> sShippedLinesIds = new Set<Id>();
        for(ReceivedLine rLine: recivedOrder.lines) {
            sShippedLinesIds.add(rLine.shippedTransferLineId);
        }
        List<PBSI__Shipped_Tranfer_Line__c> lShippedLines = [SELECT Id, PBSI__Item__r.Name, PBSI__Transfer_Order__c, PBSI__Item__c, 
                                                                    PBSI__Transfer_Order_Line__c, PBSI__Transfer_Order__r.PBSI__To_Location__c
                                                                FROM PBSI__Shipped_Tranfer_Line__c
                                                                WHERE PBSI__Transfer_Order__r.Name = :recivedOrder.transferOrderNumber
                                                                AND Id IN :sShippedLinesIds];
        Map<String, PBSI__Shipped_Tranfer_Line__c> mapItem2Line = new Map<String, PBSI__Shipped_Tranfer_Line__c>();
        for(PBSI__Shipped_Tranfer_Line__c line: lShippedLines) {
            if(!mapItem2Line.containsKey(line.PBSI__Item__r.Name)) {
                mapItem2Line.put(line.PBSI__Item__r.Name, line);
            }
        }

        return mapItem2Line;
    }

    private static PBSI__Received_Transfer_Line__c createRecivedLine(ReceivedLine rLine, PBSI__Shipped_Tranfer_Line__c shippedLine) {
        return new PBSI__Received_Transfer_Line__c(
            PBSI__Transfer_Order__c = shippedLine.PBSI__Transfer_Order__c,
            PBSI__Item__c = shippedLine.PBSI__Item__c,
            PBSI__Shipped_Tranfer_Line2__c = shippedLine.Id,
            PBSI__Quantity__c = rLine.quantity,
            PBSI__Transfer_Order_Line__c = shippedLine.Id,
            PBSI__To_Location__c = shippedLine.PBSI__Transfer_Order__r.PBSI__To_Location__c
        );
    }

    private static void setResponse(Integer code, String msg) {
        responseMsg = msg;
        responseCode = code;
    }

    private class ReceivedTO {
        public Id transferOrderId;
        public String transferOrderNumber;
        public List<ReceivedLine> lines;
    }

    private class ReceivedLine {
        public Id shippedTransferLineId;
        public String itemNumber;
        public Integer quantity;        
    }*/

}