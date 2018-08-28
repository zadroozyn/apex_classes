public class B24ConfirmMsgDeliveryStep implements IProcessStepDefinition {
	private ProcessRealization pInstance;
	public void executeStep(ProcessRealization pInstance) {
		this.pInstance = pInstance;
		System.debug('!!!### B24ConfirmMsgDeliveryStep for '+pInstance.getRecordIds());
		B24MessageSend sendHelper = new B24MessageSend(pInstance.context.b24AuthObj);
		List<PBSI__PBSI_Sales_Order__c> lSOtoConfirm = [SELECT B24_Message_Id__c FROM PBSI__PBSI_Sales_Order__c WHERE Id IN :pInstance.getRecordIds()];
		for(PBSI__PBSI_Sales_Order__c so: lSOtoConfirm) {
			sendHelper.statusDelivered(so.B24_Message_Id__c);			
		}
	}
	public String getStepName() {
		return 'Confirm Delivery';
	}
}