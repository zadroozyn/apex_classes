//https://eu4.salesforce.com/services/apexrest/kn/shipconf
@RestResource(urlMapping='/kn/shipconf')
global with sharing class KN_DespatchInfo  {

    private static ResponseObj resObj;
    private static RestRequest req = RestContext.request;
    private static RestResponse res = RestContext.response;

    public class SObjectTypeException extends Exception {}

    private static string getXMLRequestSingleValue(XPath xp, string reqXpath){
        try{
            Dom.XmlNode ndWthotRoot = xp.findFirst(reqXpath);
            return ndWthotRoot.getText();
        }
        catch(exception e){
            throw new SObjectTypeException('Path of this xml:"'+reqXpath+'" is invalid.');
        }
    }

    private static string getXMLRequestSingleValue(XPath xp, Dom.XmlNode domPerantXml, string reqChildPath){
        try{
            Dom.XmlNode ndWthotRoot = xp.findFirst(domPerantXml, reqChildPath);
            return ndWthotRoot.getText();
        }
        catch(exception e){
            throw new SObjectTypeException('Path of this xml:"'+reqChildPath+'" is invalid.');
        }
    }

    @HttpPost
    global static ResponseObj create() {
        Savepoint sp = Database.setSavepoint();
        initResponse();

        LogService logSrv = LogService.getlogService();
        String reqBody;
        try {
            reqBody = req.requestBody.toString();
            XPath xp = new XPath(reqBody);
            Tracking__c trackingObj = new Tracking__c();
            SObject parentObj;
            Order_Stage__c orderStage;

            string strConsigneeOrderNumber, strShipmentNumber, strClientOrderReference, strTransmissionId, strCarrierCode;
            strConsigneeOrderNumber = getXMLRequestSingleValue(xp, 'Message/Header/OrderInformation/ConsigneeOrderNumber');
            
            Boolean isForSalesOrder, isForTransferOrder;
            isForSalesOrder = strConsigneeOrderNumber.startsWithIgnoreCase('SO');
            isForTransferOrder = strConsigneeOrderNumber.startsWithIgnoreCase('TO');
            strTransmissionId = getXMLRequestSingleValue(xp, 'Message/Header/OrderInformation/ClientOrderReference').toUpperCase();
            strShipmentNumber = getXMLRequestSingleValue(xp, 'Message/Header/OrderInformation/MovementOrderNumber');
            strclientOrderReference = getXMLRequestSingleValue(xp, 'Message/Header/OrderInformation/ClientOrderReference');
            
            strCarrierCode = getXMLRequestSingleValue(xp, 'Message/Header/OrderInformation/CarrierID');
            trackingObj.Movement_Order_Number__c = strShipmentNumber;
            trackingObj.Order_Stage__r = new Order_Stage__c(Transmission_Id__c = strTransmissionId);
            trackingObj.Carrier_Code__c = strCarrierCode;
            
            if(isForSalesOrder){
                parentObj = [Select Id,PBSI__Contact__c From PBSI__PBSI_Sales_Order__c Where Name = : strConsigneeOrderNumber];
                trackingObj.Sales_Order__c = parentObj.Id;
                trackingObj.Contact__c = (Id) parentObj.get('PBSI__Contact__c');
                insert trackingObj;
                orderStage = getOrderStageSO(strTransmissionId);
            }
            else if(isForTransferOrder){
                parentObj = [Select Id From PBSI__Transfer_Order__c Where Name = : strConsigneeOrderNumber];
                trackingObj.Transfer_Order__c = parentObj.Id;
                insert trackingObj;
                orderStage = getOrderStageTO(strTransmissionId);
            }
            else{
                throw new SObjectTypeException('SObject not supported: '+strConsigneeOrderNumber);
            }

            insert new Attachment(
                ParentId = trackingObj.Id,
                Body = Blob.valueOf(reqBody),
                Name = strClientOrderReference+'-shipconf.xml'
            );
            
            Integer masterCharLenght = getXMLRequestSingleValue(xp, 'Message/Line/SubtotalsInformation/GoodsItemInformation/MasterCaseNumber').length();
            map<string, Tracking_Number__c> mpUnitIdTrackNumber = new map<string, Tracking_Number__c> ();
            for(Dom.XmlNode domXml: xp.find(xp.root, '/DespatchConfirmationExt/Message/Header/ShippingUnitInformation')){
                mpUnitIdTrackNumber.put(
                    getXMLRequestSingleValue(xp, domXml, './ShippingUnitID').right(masterCharLenght),
                    new Tracking_Number__c(
                        Package_Weight__c = getXMLRequestSingleValue(xp, domXml, './CaseWeightActual/Value') 
                            +' '+ getXMLRequestSingleValue(xp, domXml, './CaseWeightActual/UOM'),
                        Tracking__c = trackingObj.Id,
                        Number__c = getXMLRequestSingleValue(xp, domXml, './AdditionalID')
                    )
                );
            }
            insert mpUnitIdTrackNumber.values();

            List<Tracking_Number_Item__c> items = new List<Tracking_Number_Item__c>();

            for(Dom.XmlNode domXml: xp.find(xp.root, '/DespatchConfirmationExt/Message/line/LineInformation')){
                Id trckId = mpUnitIdTrackNumber.get(getXMLRequestSingleValue(xp, domXml, '../SubtotalsInformation/GoodsItemInformation/MasterCaseNumber')).Id;
                trckId = trckId != null ? trckId : mpUnitIdTrackNumber.values()[0].id;
                items.add(
                    new Tracking_Number_Item__c(
                        Tracking_Number__c = trckId,
                        Quantity__c = Decimal.valueOf(getXMLRequestSingleValue(xp, domXml, './Quantity/QuantityValue')),
                        Item__r = new PBSI__PBSI_Item__c(EAN_Number__c = 
                                getXMLRequestSingleValue(xp, domXml, './ArticleDescription2')
                            ),
                        Description__c = getXMLRequestSingleValue(xp, domXml, './ArticleDescription1') 
                            + ' ' + getXMLRequestSingleValue(xp, domXml, './ArticleDescription2')
                    )
                );
            }
            if(isForSalesOrder){
                addShippedLineRef(items, orderStage.Shipped_Sales_Order_Lines__r);
            } else {
                addShippedLineRef(items, orderStage.Shipped_Transfer_Lines__r);
            }
            insert items;
            enqueueProcess(trackingObj.Id);
        } catch (Exception e) {
            setError(e);
            logSrv.addError().exception(e).info(reqBody).type(KN_DespatchInfo.class.getName());
            Database.rollback(sp);
        }

        logSrv.save();
        return resObj;
    }

    private static Order_Stage__c getOrderStageSO(String transmissionId) {
        return [SELECT Id,
            (SELECT Id, PBSI__Item__c FROM Shipped_Sales_Order_Lines__r)
        FROM Order_Stage__c
        WHERE Transmission_Id__c = :transmissionId];
    }

    private static Order_Stage__c getOrderStageTO(String transmissionId) {
        return [SELECT Id,
            (SELECT Id, PBSI__Item__c FROM Shipped_Transfer_Lines__r)
        FROM Order_Stage__c
        WHERE Transmission_Id__c = :transmissionId];
    }

    private static List<Tracking_Number_Item__c> addShippedLineRef(List<Tracking_Number_Item__c> items, List<PBSI__Shipped_Sales_Order_Line__c> shippedLines) {
        Map<Id, Id> mItemId2ShippedLineId = new Map<Id, Id>();
        for(PBSI__Shipped_Sales_Order_Line__c line: shippedLines) {
            mItemId2ShippedLineId.put(line.PBSI__Item__c, line.Id);
        }
        for(Tracking_Number_Item__c item: items) {
            item.Packed_Sales_Order_Line__c = mItemId2ShippedLineId.get(item.Item__c);
        }
        return items;
    }

    private static List<Tracking_Number_Item__c> addShippedLineRef(List<Tracking_Number_Item__c> items, List<PBSI__Shipped_Tranfer_Line__c> shippedLines) {
        Map<Id, Id> mItemId2ShippedLineId = new Map<Id, Id>();
        for(PBSI__Shipped_Tranfer_Line__c line: shippedLines) {
            mItemId2ShippedLineId.put(line.PBSI__Item__c, line.Id);
        }
        for(Tracking_Number_Item__c item: items) {
            item.Shipped_Transfer_Line__c = mItemId2ShippedLineId.get(item.Item__c);
        }
        return items;
    }

    private static void enqueueProcess(Id trackingObjId) {
        ProcessRealization pInstance = new ProcessRealization(trackingObjId, new ConsumeKNDesadvSOProcess());
        pInstance.context.put('trackingObjId', trackingObjId);
        if(!Test.isRunningTest()) {
            pInstance.startProcess();
        }
    }

    private static void initResponse() {
        resObj = new ResponseObj();
        res = new RestResponse();
        res.statusCode = 200;
    }

    private static void setError(Exception e) {
        resObj.setFailure(e);
        res.statusCode = 400;
    }

    global class ResponseObj {
        public String message;
        public Boolean isSuccess;

        public ResponseObj() {
            message = '';
            isSuccess = true;
        }

        public void setFailure(Exception e) {
            message = e.getMessage();
            isSuccess = false;
        }
    }
}