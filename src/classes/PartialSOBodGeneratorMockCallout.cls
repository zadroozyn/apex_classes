@isTest
public class PartialSOBodGeneratorMockCallout implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;

    public PartialSOBodGeneratorMockCallout() {
        this.code = 200;
        this.status = 'OK';
        this.body = '1235441563626';
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}