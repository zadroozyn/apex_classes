@isTest
public class CongaFileGeneratorMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public CongaFileGeneratorMock() {
        this.code = 200;
        this.status = 'OK';
        this.responseHeaders = new Map<String, String>{'Content-Type' => 'text/xml', 'charset' => 'UTF-8'};
        this.body =  '<?xml version="1.0" encoding="utf-8" ?>' +
                                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
                                'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                                    '<soapenv:Body xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                                    '</soapenv:Body>' +
                                '</soapenv:Envelope>';
                                
    }


    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }


}