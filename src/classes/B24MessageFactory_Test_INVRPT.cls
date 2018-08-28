/*
	(SeeAllData=true) - reports can't be created in test
*/
@isTest (SeeAllData=true)
private class B24MessageFactory_Test_INVRPT {
	
	@isTest static void sendPSGReport() {
		Id reportId = '00O570000077nly'; //PSG invrpt
		String recipientGLN = '11111111111'; //fake gln
		B24MessageFactory msgFactory = new B24MessageFactory();
		String msg = msgFactory.invrpt(reportId, recipientGLN);
	}
	
}