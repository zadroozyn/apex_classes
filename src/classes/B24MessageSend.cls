public class B24MessageSend {

	private static B24Authorization authObj;
	private static final String B24_BASE_URL_API1 = 'https://portal.btwentyfour.com/api/v1/';

	public B24MessageSend() {
		this(null);
	}

	public B24MessageSend(B24Authorization b24AuthObj) {
		authObj = b24AuthObj;
	}

	public StatusResponse statusDelivered(String b24MessageId) {
		return setMessageStatus(b24MessageId, 'Delivered');
	}

	public StatusResponse statusAwaitingDelivery(String b24MessageId) {
		return setMessageStatus(b24MessageId, 'AwaitingDelivery');
	}

	public StatusResponse statusDeliveryError(String b24MessageId) {
		return setMessageStatus(b24MessageId, 'DeliveryError');
	}

	public MessageResponse sendOrder(String msg) {
		return sendMessage(msg, 'Order');
	}

	public MessageResponse sendOrderResponse(String msg) {
		return sendMessage(msg, 'OrderResponse');
	}

	public MessageResponse sendDespatchAdvice(String msg) {
		return sendMessage(msg, 'DespatchAdvice');
	}

	public MessageResponse sendInvoice(String msg) {
		return sendMessage(msg, 'Invoice');
	}
	
	public MessageResponse sendInventoryReport(String msg) {
		return sendMessage(msg, 'InventoryReport');
	}
	
	private static StatusResponse processResponse(HttpResponse res) {
		return new StatusResponse(res.getStatusCode(), res.getBody());
	} 

	private MessageResponse sendMessage(String msg, String msgClass) {
		auth();
		HttpRequestBuilder httpReq = 
        	new HttpRequestBuilder(B24_BASE_URL_API1 + '/endpoints/' + authObj.getEndpointKey() + '/messages?className=' + msgClass,'POST');
        httpReq.setHeader('Authorization', authObj.getAuthHeader());
        httpReq.setHeader('Cache-Control', 'no-cache');
        httpReq.setHeader('Content-Length', '0');
        httpReq.setBody(msg);
        HttpResponse res = httpReq.sendRequest();
        return (MessageResponse) JSON.deserialize(res.getBody(), MessageResponse.class);
	}

	private StatusResponse setMessageStatus(String b24MessageId, String status) {
		auth();
		HttpRequestBuilder httpReq = 
        	new HttpRequestBuilder(B24_BASE_URL_API1 + '/messages/'+ b24MessageId +'/status/' + status,'PUT');
        httpReq.setHeader('Authorization', authObj.getAuthHeader());
        httpReq.setHeader('Cache-Control', 'no-cache');
        httpReq.setHeader('Content-Length', '0');
        HttpResponse res = httpReq.sendRequest();
        return processResponse(res);
	}

	private void auth() {
        if(authObj == null || !authObj.isValid()) {
            authObj = new B24Authorization();
            authObj.authorize();
        }
    }

    public class StatusResponse {
    	public Integer statusCode;
    	public Boolean isSuccess;
    	public String message;

    	public StatusResponse(Integer statusCode, String message) {
    		this.statusCode = statusCode;
    		this.message = message != null ? message : '';
    		this.isSuccess = statusCode >= 200 && statusCode <= 299;
    	}
    }

    public class MessageResponse {
    	public Integer Id;	
    	public Integer ParentMessageId;
    	public Datetime ReceivedDateTime;
		public PartyModel SenderParty;
		public PartyModel RecipientParty;
		public String ClassName;
		public String Status;
		public List<MetadataModel> Metadata;
    	public Integer QueuePlace;
    	public MessageFormatModel Format;
    	public String Filename;
    	public Integer Size;
	}

	public class PartyModel {
		public String Key;
		public String Gln;
		public String Name;
	}

	public class MetadataModel {
		public String Key;
		public String Value;
	}

	public class MessageFormatModel {
		public String ContentType;
		public String Name;
		public String Version;
	}
    
}