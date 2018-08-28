@isTest
global class ONRMockKNGETResponse implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals(ONRLogisticsGateway.KN_ENDPOINT_TEST, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        res.setBody('OK');
        res.setStatusCode(200);
        return res;
    }
}