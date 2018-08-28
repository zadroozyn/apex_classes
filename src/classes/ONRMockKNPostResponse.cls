@isTest
global class ONRMockKNPostResponse implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals(ONRLogisticsGateway.KN_ENDPOINT_TEST, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        res.setBody('OK');
        res.setStatusCode(200);
        return res;
    }
}