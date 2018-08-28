@RestResource(urlMapping='/osca/po')
global with sharing class OSCA_POIntegration  {

    @testVisible private static final String PARAM_ID_SEPARATOR = ',';
    @testVisible private static final String PARAM_ID_NAME = 'id';
    @testVisible private static final String PARAM_ID_MISSING = 'Id of Purchase Order(s) is missing';

    @HttpGet
    global static String initIntegration() {
        Response res = new Response();
        try {
            String requestIds = RestContext.request.params.get(PARAM_ID_NAME);
            if(String.isBlank(requestIds)) {
                throw new ParamException(PARAM_ID_MISSING);
            }
            List<String> idsString = requestIds.split(PARAM_ID_SEPARATOR);
            List<Id> ids = new List<Id>();
            for(String tmpId: idsString) {
                ids.add((Id) tmpId);
            }
            createNewStagings(ids);
        } catch(Exception e) {
            res.setError(e);
        }

        return restResponse(res);

    }

    webservice static String initIntegrationSingle(Id poId) {
        return initIntegrationMultiple(new List<Id> {poId});
    }

    webservice static String initIntegrationMultiple(List<Id> poIds) {
        Response res = new Response();
        try {
            if(poIds.isEmpty()) {
                throw new ParamException(PARAM_ID_MISSING);
            }
            createNewStagings(poIds);
        } catch(Exception e) {
            res.setError(e);
        }
        return JSON.serialize(res);
    }

    private static String restResponse(Response res) {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = res.code;
        return JSON.serialize(res);
    }

    public class Response {
        public Integer code;
        public String status;
        public String message;
        public Response() {
            code = 200;
            status = 'OK';
            message = 'Integration with OSCA initialized';
        }
        public void setError(Exception e) {
            code = 400;
            status = 'BAD_REQUEST';
            message = e.getMessage();
        }
    }

    private static void createNewStagings(List<Id> ids) {
        String errMsg = '';
        OSCA_StagingService stagingService = new OSCA_StagingService();
        List<PBSI__PBSI_Purchase_Order__c> pos = [SELECT Id FROM PBSI__PBSI_Purchase_Order__c WHERE Id IN :ids and PBSI__Account__c = null];
        if(!pos.isEmpty()) {
            for(PBSI__PBSI_Purchase_Order__c po: pos) {
                errMsg += 'Missing Account/Vendor in PO Id: '+po.Id;
            }
            throw new ParamException(errMsg);
        }
        for(String poId: ids) {
            PBSI__PBSI_Purchase_Order__c poObj = new PBSI__PBSI_Purchase_Order__c(Id = poId);
            stagingService.newPOStagingObject(poObj);
        }
        stagingService.insertStagingObjects();
    }

    public class ParamException extends Exception {}

}