@isTest
global class B24MockCallout implements HttpCalloutMock {

	private Integer callCounter;
	private String msgType;

	public B24MockCallout(String messageType) {
		this(messageType,1);
	}

	public B24MockCallout(String messageType, Integer noOfResponses) {
		callCounter = noOfResponses;
		msgType = messageType;
	}

	public HTTPResponse respond(HTTPRequest req) {
		if(req.getEndpoint().startsWithIgnoreCase('https://portal.btwentyfour.com/token')) {
			return sendToken();
		} else if(callCounter > 0) {
			callCounter--;
			return sendMessage();
		}
		else {
			return sendEmptyMessage();
		}
	}

	private HttpResponse sendEmptyMessage() {
		HttpResponse res = new HttpResponse();
		res.setStatus('Bad request');
		res.setStatusCode(404);
		return res;
	}

	private HttpResponse sendToken() {
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		res.setBody(
			TOKEN_MSG
		);
		return res;
	}

	private HttpResponse sendMessage() {
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String body = msgType2Response.get(msgType.toLowerCase());
		body = body != null ? body : '';
		res.setBody(
			body
		);
		return res;
	}

	public static final String TOKEN_MSG = 
		'{'+
			'"access_token":"fakeToken00001_893425098423573480n5v78956938742",'+
			'"token_type":"bearer",'+
			'"expires_in":1209599,'+
			'"userName":"test_user",'+
			'".issued":"Tue, 05 Sep 2017 11:01:30 GMT",'+
			'".expires":"Tue, 19 Sep 2017 11:01:30 GMT"'+
		'}';

	public static final String SLSRPT_MSG =
		'{'+
			'"b24Message": [{'+
				'"slsrpt": {'+
				'"environment": "Production",'+
  				'"documentDate": "2015-11-09",'+
              	'"periodStartDate": "2015-11-01",'+
  				'"periodEndDate": "2015-11-08",'+
  				'"buyer":"4038925000016",'+
  				'"supplier":"7640146810007",'+
  				'"msgRefNo":"I02065870016645",'+
  				'"lines": ['+
      				'{'+
                    	'"ean":"7640165317761",'+
                        '"itemID":"102191005",'+
                        '"netPrice":67.06,'+
      					'"salesPrice":159.95,'+
                      	'"salesQuantity":1,'+
      					'"returnedQuantity":1,'+
      					'"location":"4260373430019"'+
      				'},'+
      				'{'+
      					'"ean":"7630040505581",'+
      					'"itemID":"279279003",'+
                        '"netPrice":56.57,'+
                        '"salesPrice":134.95,'+
                        '"salesQuantity":10,'+
                        '"returnedQuantity":0,'+
                        '"location":"4038925000191"'+
      				'}'+
  				']'+
				'}'+
			'}]'+
		'}';

	public static final String INVRPT_MSG =
		'{'+
			'"b24Message": [{'+
				'"invrpt": {'+
				'"environment": "Production",'+
  				'"documentDate": "2015-11-09",'+
  				'"buyer":"4038925000016",'+
  				'"supplier":"7640146810007",'+
  				'"msgRefNo":"I02065870016644",'+
  				'"lines": ['+
      				'{'+
                    	'"ean":"7640165317761",'+
      					'"quantity":1,'+
      					'"location":"4260373430019"'+
      				'},'+
      				'{'+
      					'"ean":"7630040505581",'+
                        '"quantity":1,'+
                        '"location":"4038925000191"'+
      				'}'+
  				']'+
				'}'+
			'}]'+
		'}';

	public static final String ORDER_PSG_NO_GLN_MSG =
		'{'+
			  '"b24Message": ['+
			    '{'+
			      '"order": {'+
			        '"text": "",'+
			        '"environment": "Production",'+
			        '"orderType": "",'+
			        '"currency": "CHF",'+
			        '"sender": 4399902216555,'+
			        '"recipient": "",'+
			        '"documentReference": ['+
			          '{'+
			            '"documentType": "BuyerOrder",'+
			            '"id": "FGC678894912",'+
			            '"ddate": "2017-09-20",'+
			            '"lineNo": "2017-09-20",'+
			            '"parentLineNo": "2017-09-20"'+
			          '}'+
			        '],'+
			        '"properties": ['+
			          '{'+
			            '"name": "prodIDType",'+
			            '"text": "EAN"'+
			          '}'+
			        '],'+
			        '"buyer": {'+
			          '"gln": 4399902216555'+
			        '},'+
			        '"item": ['+
			          '{'+
			            '"quantity": "1",'+
			            '"documentReference": ['+
			              '{'+
			                '"documentType": "BuyerOrder",'+
			                '"id": "FGC678894912",'+
			                '"ddate": "2017-09-20",'+
			                '"lineNo": 1'+
			              '}'+
			            '],'+
			            '"properties": ['+
			              '{'+
			                '"name": "unitOfMeasure",'+
			                '"text": "PCS"'+
			              '}'+
			            '],'+
			            '"itemReference": ['+
			              '{'+
			                '"registry": "Supplier",'+
			                '"coding": "EAN13",'+
			                '"text": 7640165319192'+
			              '}'+
			            '],'+
			            '"price": ['+
			              '{'+
			                '"type": "netPrice",'+
			                '"value": 222.2222,'+
			                '"currency": "CHF"'+
			              '},'+
			              '{'+
			                '"type": "grossPrice",'+
			                '"value": 240.00,'+
			                '"currency": "CHF"'+
			              '}'+
			            ']'+
			          '}'+
			        '],'+
			    	'"deliveryParty": {'+
			    		'"name":"John Chocolade",'+
        				'"location": {'+
          					'"address": "Bahnhofstrasse 21, south enterance, ground floor",'+
          					'"city": {'+
            					'"code": "8001",'+
            					'"text": "Zürich"'+
          					'},'+
          					'"country": {'+
            					'"code": "Switzerland",'+
            					'"text": "CH"'+
          					'},'+
          					'"telephoneNumber": "+41780000000",'+
          					'"emailAddress": "sprungli@example.com"'+
        				'}'+
      				'}'+
			      '}'+
			    '}'+
			  ']'+
			'}';
	public static final String ORDER_PSG_WITH_GLN_MSG =
		'{'+
			  '"b24Message": ['+
			    '{'+
			      '"order": {'+
			        '"text": "",'+
			        '"environment": "Production",'+
			        '"orderType": "",'+
			        '"currency": "CHF",'+
			        '"sender": 4399902216555,'+
			        '"recipient": "",'+
			        '"documentReference": ['+
			          '{'+
			            '"documentType": "BuyerOrder",'+
			            '"id": "O-FGC678894912",'+
			            '"ddate": "2017-09-20",'+
			            '"lineNo": "2017-09-20",'+
			            '"parentLineNo": "2017-09-20"'+
			          '}'+
			        '],'+
			        '"properties": ['+
			          '{'+
			            '"name": "prodIDType",'+
			            '"text": "EAN"'+
			          '}'+
			        '],'+
			        '"buyer": {'+
			          '"gln": 4399902216555'+
			        '},'+
			        '"item": ['+
			          '{'+
			            '"quantity": "1",'+
			            '"documentReference": ['+
			              '{'+
			                '"documentType": "BuyerOrder",'+
			                '"id": "FGC678894912",'+
			                '"ddate": "2017-09-20",'+
			                '"lineNo": 1'+
			              '}'+
			            '],'+
			            '"properties": ['+
			              '{'+
			                '"name": "unitOfMeasure",'+
			                '"text": "PCS"'+
			              '}'+
			            '],'+
			            '"itemReference": ['+
			              '{'+
			                '"registry": "Supplier",'+
			                '"coding": "EAN13",'+
			                '"text": 7640165319192'+
			              '}'+
			            '],'+
			            '"price": ['+
			              '{'+
			                '"type": "netPrice",'+
			                '"value": 222.2222,'+
			                '"currency": "CHF"'+
			              '},'+
			              '{'+
			                '"type": "grossPrice",'+
			                '"value": 240.00,'+
			                '"currency": "CHF"'+
			              '}'+
			            ']'+
			          '}'+
			        '],'+
			    	'"deliveryParty": {'+
			    		'"gln":"4399902216555"'+
      				'}'+
			      '}'+
			    '}'+
			  ']'+
			'}';
	public static final String ORDER_PSG_GLN_LINE_ERROR_MSG =
		'{'+
			  '"b24Message": ['+
			    '{'+
			      '"order": {'+
			        '"text": "",'+
			        '"environment": "Production",'+
			        '"orderType": "",'+
			        '"currency": "CHF",'+
			        '"sender": 4399902216555,'+
			        '"recipient": "",'+
			        '"documentReference": ['+
			          '{'+
			            '"documentType": "BuyerOrder",'+
			            '"id": "FGC678894912",'+
			            '"ddate": "2017-09-20",'+
			            '"lineNo": "2017-09-20",'+
			            '"parentLineNo": "2017-09-20"'+
			          '}'+
			        '],'+
			        '"properties": ['+
			          '{'+
			            '"name": "prodIDType",'+
			            '"text": "EAN"'+
			          '}'+
			        '],'+
			        '"buyer": {'+
			          '"gln": 4399902216555'+
			        '},'+
			        '"item": ['+
			          '{'+
			            '"quantity": "1",'+
			            '"documentReference": ['+
			              '{'+
			                '"documentType": "BuyerOrder",'+
			                '"id": "FGC678894912",'+
			                '"ddate": "2017-09-20",'+
			                '"lineNo": 1'+
			              '}'+
			            '],'+
			            '"properties": ['+
			              '{'+
			                '"name": "unitOfMeasure",'+
			                '"text": "PCS"'+
			              '}'+
			            '],'+
			            '"itemReference": ['+
			              '{'+
			                '"registry": "Supplier",'+
			                '"coding": "EAN13",'+
			                '"text": "xxx"'+
			              '}'+
			            '],'+
			            '"price": ['+
			              '{'+
			                '"type": "netPrice",'+
			                '"value": 222.2222,'+
			                '"currency": "CHF"'+
			              '},'+
			              '{'+
			                '"type": "grossPrice",'+
			                '"value": 240.00,'+
			                '"currency": "CHF"'+
			              '}'+
			            ']'+
			          '}'+
			        '],'+
			    	'"deliveryParty": {'+
			    		'"gln":"4399902216555"'+
      				'}'+
			      '}'+
			    '}'+
			  ']'+
			'}';

	public static final String ORDER_RRS_MSG = 
	'{'+
      '"b24Message": ['+
        '{'+
          '"order": {'+
            '"text": "",'+
            '"environment": "Production",'+
            '"orderType": "",'+
            '"currency": "",'+
            '"sender": 7340117820218,'+
            '"recipient": 7640146810007,'+
            '"documentReference": ['+
              '{'+
                '"documentType": "BuyerOrder",'+
                '"id": "152-704-144263774",'+
                '"ddate": "2017-09-21",'+
                '"lineNo": "2017-09-21",'+
                '"parentLineNo": "2017-09-21"'+
              '}'+
            '],'+
            '"properties": ['+
              '{'+
                '"name": "prodIDType",'+
                '"text": "EAN"'+
              '},'+
              '{'+
                '"name": "deliveryDate",'+
                '"text": "2017-09-21T00:00:00+01:00"'+
              '}'+
            '],'+
            '"supplier": {'+
              '"gln": 7640146810007'+
            '},'+
            '"buyer": {'+
              '"gln": 7340117820218'+
            '},'+
            '"deliveryParty": {'+
              '"gln": "",'+
              '"name": "DOUGLAS HYDORN",'+
              '"location": {'+
                '"address": "4800 NE 21ST AVE",'+
                '"city": {'+
                  '"code": 33308,'+
                  '"text": "FORT LAUDERDALE"'+
                '},'+
                '"country": {'+
                  '"code": "US"'+
                '}'+
              '}'+
            '},'+
            '"item": ['+
              '{'+
                '"quantity": 1,'+
                '"documentReference": ['+
                  '{'+
                    '"documentType": "BuyerOrder",'+
                    '"id": "152-704-144263774",'+
                    '"ddate": "2017-09-21",'+
                    '"lineNo": 5580737'+
                  '}'+
                '],'+
                '"properties": ['+
                  '{'+
                    '"name": "unitOfMeasure",'+
                    '"text": "EA"'+
                  '}'+
                '],'+
                '"itemReference": ['+
                  '{'+
                    '"registry": "Supplier",'+
                    '"coding": "EAN13",'+
                    '"text": 7640165319338'+
                  '}'+
                '],'+
                '"price": ['+
                  '{'+
                    '"type": "netPrice",'+
                    '"value": 69.3'+
                  '}'+
                ']'+
              '},'+
              '{'+
                '"quantity": 1,'+
                '"documentReference": ['+
                  '{'+
                    '"documentType": "BuyerOrder",'+
                    '"id": "152-704-144263774",'+
                    '"ddate": "2017-09-21",'+
                    '"lineNo": 5580738'+
                  '}'+
                '],'+
                '"properties": ['+
                  '{'+
                    '"name": "unitOfMeasure",'+
                    '"text": "EA"'+
                  '}'+
                '],'+
                '"itemReference": ['+
                  '{'+
                    '"registry": "Supplier",'+
                    '"coding": "EAN13",'+
                    '"text": 7640165319345'+
                  '}'+
                '],'+
                '"price": ['+
                  '{'+
                    '"type": "netPrice",'+
                    '"value": 69.3'+
                  '}'+
                ']'+
              '}'+
            ']'+
          '}'+
        '}'+
      ']'+
    '}';

    public static final String ISG_PRE_ORDER = 
    	'{'+
		  	'"b24Message": ['+
		    '{'+
		      '"order": {'+
		        '"text": "",'+
		        '"environment": "Production",'+
		        '"orderType": "PRE_ORDER",'+
		        '"currency": "EUR",'+
		        '"sender": 4399901765108,'+
		        '"recipient": 7640146810007,'+
		        '"documentReference": ['+
		          '{'+
		            '"documentType": "BuyerOrder",'+
		            '"id": 1945951001'+
		          '}'+
		        '],'+
		        '"properties": ['+
		          '{'+
		            '"name": "prodIDType",'+
		            '"text": "EAN"'+
		          '},'+
		          '{'+
		            '"name": "deliveryDate",'+
		            '"text": "2018-09-03T00:00:00+01:00"'+
		          '},'+
		          '{'+
		            '"name": "status",'+
		            '"text": "ORDER_STATUS_PREORDER"'+
		          '}'+
		        '],'+
		        '"supplier": {'+
		          '"gln": 7640146810007'+
		        '},'+
		        '"buyer": {'+
		          '"gln": 4399901765108'+
		        '},'+
		        '"deliveryParty": {'+
		          '"gln": 4399901765108'+
		        '},'+
		        '"item": ['+
		          '{'+
		            '"quantity": 1,'+
		            '"documentReference": ['+
		              '{'+
		                '"documentType": "BuyerOrder",'+
		                '"id": 1945951001,'+
		                '"lineNo": 193'+
		              '}'+
		            '],'+
		            '"itemReference": ['+
		              '{'+
		                '"registry": "Supplier",'+
		                '"coding": "EAN13",'+
		                '"text": 7640165319338'+
		              '}'+
		            '],'+
		            '"price": ['+
		              '{'+
		                '"type": "netPrice",'+
		                '"value": 65.96,'+
		                '"currency": "EUR"'+
		              '},'+
		              '{'+
		                '"type": "grossPrice",'+
		                '"value": 65.96,'+
		                '"currency": "EUR"'+
		              '}'+
		            ']'+
		          '},'+
		          '{'+
		            '"quantity": 1,'+
		            '"documentReference": ['+
		              '{'+
		                '"documentType": "BuyerOrder",'+
		                '"id": 1945951001,'+
		                '"lineNo": 194'+
		              '}'+
		            '],'+
		            '"itemReference": ['+
		              '{'+
		                '"registry": "Supplier",'+
		                '"coding": "EAN13",'+
		                '"text": 7640165319345'+
		              '}'+
		            '],'+
		            '"price": ['+
		              '{'+
		                '"type": "netPrice",'+
		                '"value": 65.96,'+
		                '"currency": "EUR"'+
		              '},'+
		              '{'+
		                '"type": "grossPrice",'+
		                '"value": 65.96,'+
		                '"currency": "EUR"'+
		              '}'+
		            ']'+
		          '}'+
		        ']'+
		      '}'+
		    '}'+
		  ']'+
		'}';
	public static final String LIST_MESSAGES = '[]';

	private final Map<String, String> msgType2Response = new Map<String, String> {
		'slsrpt' => SLSRPT_MSG,
		'invrpt' => INVRPT_MSG,
		'order_psg_no_delivery_gln' => ORDER_PSG_NO_GLN_MSG,
		'isg_pre_order' => ISG_PRE_ORDER,
		'list' => LIST_MESSAGES
	};

	@isTest static void slsprt_test() {
		B24MockCallout mockCallout = new B24MockCallout('SLSRPT');
		HttpRequestBuilder httpReq = 
            new HttpRequestBuilder('https://portal.btwentyfour.com/api/v1/endpoints/','GET');
            httpReq.setHeader('Authorization', 'Fake auth');
            httpReq.setHeader('Cache-Control', 'no-cache');
            httpReq.setHeader('Content-Type', 'application/json');
        System.assertNotEquals(null, mockCallout.respond(httpReq.getRequest()));
	}

	@isTest static void token_test() {
		B24MockCallout mockCallout = new B24MockCallout('SLSRPT');
		HttpRequestBuilder httpReq = 
            new HttpRequestBuilder('https://portal.btwentyfour.com/token','GET');
            httpReq.setHeader('Authorization', 'Fake auth');
            httpReq.setHeader('Cache-Control', 'no-cache');
            httpReq.setHeader('Content-Type', 'application/json');
        HttpResponse res = mockCallout.respond(httpReq.getRequest());
        System.assertNotEquals(null, res);

	}
}