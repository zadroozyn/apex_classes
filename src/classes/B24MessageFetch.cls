public virtual class B24MessageFetch implements Queueable, Database.AllowsCallouts {

    public class MessageResponseException extends Exception {}  
	@testVisible
    private B24Authorization authObj;
    @testVisible
    private Map<String, List<MessageWrapper>> mapClassName2MessageWrappers;
    private HttpRequestBuilder fetchNextMessageBuilder;
    private String msgClassName;
    private Integer msgFetchCounter;


    public B24MessageFetch() {
        this(null, '');
    }

    protected B24MessageFetch(String className) {
        this(null, className);
    }

    protected B24MessageFetch(B24Authorization authObj) {
        this(authObj, '');
    }

    protected B24MessageFetch(B24Authorization authObj, String className) {
        this.authObj = authObj;
        this.msgClassName = className;
    }

    public void execute(QueueableContext context) {
        LogService logSrv = LogService.getlogService();
        mapClassName2MessageWrappers = new Map<String, List<MessageWrapper>>();
        msgFetchCounter = 0;
        try {
            auth();
            while(canFetchMessage()) {
                MessageWrapper message = callFetchMessage();
                msgFetchCounter++;
                System.debug('!!!### after callFetchMessage');
                System.debug(message);
                if(!message.isEmpty()) {
                    System.debug('!!!### there is message');
                    if(mapClassName2MessageWrappers.containsKey(message.className)) {
                        mapClassName2MessageWrappers.get(message.className).add(message);
                    } else {
                        mapClassName2MessageWrappers.put(message.className, new List<MessageWrapper>{message});
                    }
                } else {
                    System.debug('!!!### there is NO message');
                    break;
                }
            }
        } catch(Exception e) {
            logSrv.addError().type(B24MessageFetch.class.getName()).exception(e);
            System.debug('!!!### error '+e.getMessage());
            System.debug(e.getStackTraceString());
        }
        finally {
            System.debug('Messages to route: '+mapClassName2MessageWrappers);
            String authObjSerialized = JSON.serialize(authObj);
            for(String className: mapClassName2MessageWrappers.keySet()) {
                enqueuRouter(JSON.serialize(mapClassName2MessageWrappers.get(className)), authObjSerialized);                
            }
            enqueSelf(); 
            
        }
        logSrv.save();
    }

    private Boolean isForSpecificMsgClass() {
        return !String.isBlank(msgClassName);
    }

    public String getClassName() {
        return msgClassName;
    }

    public List<Object> fetchListAwatingMessages() {
        System.debug('!!!### fetchListAwatingMessages');
        auth();
        HttpRequestBuilder httpReq = 
            new HttpRequestBuilder('https://portal.btwentyfour.com/api/v1/endpoints/' + authObj.getEndpointKey() + '/messages'
                + (isForSpecificMsgClass() ? '?' + 'className=' + getClassName() : ''), 'GET');
            httpReq.setHeader('Authorization', authObj.getAuthHeader());
            httpReq.setHeader('Cache-Control', 'no-cache');
            httpReq.setHeader('Content-Type', 'application/json');
        HttpResponse msgResponse = httpReq.sendRequest();
        String resBody = msgResponse.getBody();
        return (List<Object>) JSON.deserializeUntyped(resBody);
    }

    @future(callout=true)
    private static void enqueuRouter(String messagesSerialized, String authObjSerialized) {
        B24Authorization authObj = (B24Authorization) JSON.deserialize(authObjSerialized, B24Authorization.class);
        List<MessageWrapper> lMessages = (List<MessageWrapper>) JSON.deserialize(messagesSerialized, List<MessageWrapper>.class);
        LogService logSrv = LogService.getlogService();
        List<B24MessageWrapper.B24MessageModel> messages = new List<B24MessageWrapper.B24MessageModel>();
        for(MessageWrapper msgWrap: lMessages) {
            try {
                B24MessageWrapper b24MsgWrap = (B24MessageWrapper) JSON.deserialize(msgWrap.msgJson, B24MessageWrapper.class);
                b24MsgWrap.b24Message[0].messageId = msgWrap.messageId;
                //System.enqueueJob(new B24MessageRouter(msgWrap.b24Message[0], authObj));
                messages.add(b24MsgWrap.b24Message[0]);
            } catch(Exception e) {
                logSrv.addError().type(B24MessageFetch.class.getName()+'_enqueuRouters').exception(e).info(msgWrap.messageId)
                    .attachment('message.json', JSON.serialize(msgWrap));
                new B24MessageSend(authObj).statusDeliveryError(msgWrap.messageId);
            }
        }
        if(!Test.isRunningTest()) {
            System.enqueueJob(new B24MessageRouter(messages, authObj));            
        }
        logSrv.save();
    } 


    private void auth() {
        if(authObj == null || !authObj.isValid()) {
            authObj = new B24Authorization();
            authObj.authorize();
        }
    }

    private Boolean canFetchMessage() {
        return msgFetchCounter < 10;
    }

    private MessageWrapper callFetchMessage() {
        System.debug('!!!### callFetchMessage');
        if(fetchNextMessageBuilder == null) {
            buildFetchMessageRequest();
        }
        MessageWrapper msgWrap = new MessageWrapper();
        HttpResponse msgResponse = fetchNextMessageBuilder.sendRequest();
        
        String resBody = msgResponse.getBody();
        if(msgResponse.getStatusCode() == 404 || String.isBlank(resBody)) {
            System.debug('There is no new messsages in queue. Response status code is 404');
        } else if(msgResponse.getStatusCode()<200 || msgResponse.getStatusCode()>299) {
            throw new MessageResponseException('Message fetch failed, response: ' + msgResponse.getStatusCode() + ' ' + msgResponse.getBody());
        } else {
            msgWrap.msgJson = resBody;
            msgWrap.messageId = msgResponse.getHeader('X-Message-ID');
            //TODO convince b24 to send messageClass in header
            B24MessageWrapper b24MsgWrap = (B24MessageWrapper) JSON.deserialize(msgWrap.msgJson, B24MessageWrapper.class);
            if(b24MsgWrap.b24Message[0].isOrder()) {
                msgWrap.className = 'order';
            } else if(b24MsgWrap.b24Message[0].isSalesReport()) {
                msgWrap.className = 'slsrpt';
            } else if(b24MsgWrap.b24Message[0].isInventoryReport()) {
                msgWrap.className = 'invrpt';
            }
        }
        return msgWrap;
    }  

    private void buildFetchMessageRequest() {
        fetchNextMessageBuilder = new HttpRequestBuilder('https://portal.btwentyfour.com/api/v1/endpoints/' + authObj.getEndpointKey() + '/messages/body?includeMetadata=true'
            + (isForSpecificMsgClass() ? '&' + 'className=' + getClassName() : ''), 'GET');
        fetchNextMessageBuilder.setHeader('Authorization', authObj.getAuthHeader());
        fetchNextMessageBuilder.setHeader('Cache-Control', 'no-cache');
        fetchNextMessageBuilder.setHeader('Content-Type', 'application/json');
    }

    private void enqueSelf() {
        if(!Test.isRunningTest()) {
            System.enqueueJob(new B24MessageFetch(authObj));
        }
    }

    public class MessageWrapper {
        public String msgJson;
        public String messageId;
        public String className;

        public MessageWrapper() {
            msgJson = '';
            messageId = 'undefined';
            className = '';
        }

        public Boolean isEmpty() {
            return String.isBlank(msgJson);
        }

    }

}