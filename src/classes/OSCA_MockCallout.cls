@isTest
public class OSCA_MockCallout implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    private String body;
    protected Map<String, String> responseHeaders;
    private String specialInstructions;

    public OSCA_MockCallout() {
        this('');
    }

    public OSCA_MockCallout(String specialInstructions) {
        this.specialInstructions = specialInstructions;
    }

    public HTTPResponse respond(HTTPRequest req) {
        body = req.getBody();
        System.debug('Mock received');
        System.debug(body);

        

        if(!String.isBlank(specialInstructions)) {
            if(specialInstructions == 'unauthorized') {
                HttpResponse res = unauthorized();
                return res;
            } else if(specialInstructions == 'failures' && body != 'xxx') {
                HttpResponse res = correct();
                res.setBody(allInvalid());
                return res;
            } else {
                return notFound();
            }
        }

        if(body == 'xxx') {
            return notFound();
        }
    
        if(req.getEndpoint().endsWithIgnoreCase('account')) {
            return account();
        } else if (req.getEndpoint().endsWithIgnoreCase('location')) {
            return location();
        } else if (req.getEndpoint().endsWithIgnoreCase('item')) {
            return item();
        } else if (req.getEndpoint().endsWithIgnoreCase('po')) {
            return po();
        } else if (req.getEndpoint().endsWithIgnoreCase('poline')) {
            return poline();
        }
        
        
        return forbidden();

    }

    private HTTPResponse account() {
        HttpResponse res = correct();
        res.setBody(allCorrect());
        return res;
    }

    private HTTPResponse location() {
        HttpResponse res = correct();
        res.setBody(allCorrect());
        return res;
    }

    private HTTPResponse item() {
        HttpResponse res = correct();
        res.setBody(allCorrect());
        return res;
    }

    private HTTPResponse po() {
        HttpResponse res = correct();
        res.setBody(allCorrect());
        return res;
    }

    private HTTPResponse poline() {
        HttpResponse res = correct();
        res.setBody(allCorrect());
        return res;
    }

    private HTTPResponse unauthorized() {
        HttpResponse res = new HttpResponse();
        res.setBody('You are not authorized to view the resource');
        res.setStatusCode(401);
        res.setStatus('UNAUTHORIZED');
        return res;
    }

    private HTTPResponse forbidden() {
        HttpResponse res = new HttpResponse();
        res.setBody('Accessing the resource you were trying to reach is forbidden');
        res.setStatusCode(403);
        res.setStatus('FORBIDDEN');
        return res;
    }

    private HTTPResponse notFound() {
        HttpResponse res = new HttpResponse();
        res.setBody('The resource you were trying to reach is not found');
        res.setStatusCode(404);
        res.setStatus('NOT FOUND');
        return res;
    }

    private HTTPResponse correct() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }

    private String allCorrect() {
        List<SObject> lObjs = (List<SObject>) JSON.deserialize(body, List<SObject>.class);
        OscaMessageSend.OscaResponse resObj = new OscaMessageSend.OscaResponse();
        resObj.successes = new List<OscaMessageSend.OscaLineResponse>();
        resObj.failures = new List<OscaMessageSend.OscaLineResponse>();
        for(SObject sObj: lObjs) {
            OscaMessageSend.OscaLineResponse line = new OscaMessageSend.OscaLineResponse();
            line.objId = sObj.Id;
            resObj.successes.add(line);
        }
        return JSON.serialize(resObj);
    }

    private String allInvalid() {
        List<SObject> lObjs = (List<SObject>) JSON.deserialize(body, List<SObject>.class);
        OscaMessageSend.OscaResponse resObj = new OscaMessageSend.OscaResponse();
        resObj.successes = new List<OscaMessageSend.OscaLineResponse>();
        resObj.failures = new List<OscaMessageSend.OscaLineResponse>();
        for(SObject sObj: lObjs) {
            OscaMessageSend.OscaLineResponse line = new OscaMessageSend.OscaLineResponse();
            line.objId = sObj.Id;
            line.cause = 'random';
            resObj.failures.add(line);
        }
        return JSON.serialize(resObj);
    }

}