global class B24MessageInvoiceWebService {

	webservice static String sendInvoice(Id invObjId, String recipientGLN){
		B24MessageFactory msgFactory = new B24MessageFactory();
		String invoice = msgFactory.invoice(invObjId, recipientGLN);
		B24MessageSend.MessageResponse res = new B24MessageSend().sendInvoice(invoice);
		Attachment attMsg = new Attachment(
            ParentId = invObjId,
            Name = 'invoice-' + res.Id +'.json',
            Body = Blob.valueOf(invoice)
        );
        String resSerialized = JSON.serialize(res);
        Attachment attMsgRes = new Attachment(
            ParentId = invObjId,
            Name = 'response-' + res.Id +'.json',
            Body = Blob.valueOf(resSerialized)
        );
        insert new List<Attachment> {attMsg, attMsgRes};
		return resSerialized;
	}

}