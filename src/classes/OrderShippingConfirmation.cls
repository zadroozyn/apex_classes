public class OrderShippingConfirmation implements IProcessStepDefinition {

	private ProcessRealization pInstance;
	private Id trackingObjId;
	private Tracking__c trObj;

	private Features_enable_disable_settings__c features_settings {
		get {
			if(features_settings == null) {
				Map<String, Features_enable_disable_settings__c> mFeatureSettings = Features_enable_disable_settings__c.getAll();
				if (mFeatureSettings.containsKey('organisation_setting')) {
					features_settings = mFeatureSettings.get('organisation_setting');
				} else {
					features_settings = new Features_enable_disable_settings__c();
				}
			}
			return features_settings;
		}
		private set;
	}

	public void executeStep(ProcessRealization pInstance) {
		if (features_settings.Enable_Shipping_automation__c) {
			this.pInstance = pInstance;
			trackingObjId = (Id)pInstance.context.get('trackingObjId');
			trObj = [SELECT Id, Is_Sales_Order__c, Sales_Order__r.RecordTypeId, Has_Contact__c, Tracking_Link_Base__c, Sales_Order__r.PBSI__Customer__r.IsDistributor__c FROM Tracking__c WHERE Id =: trackingObjId];

			if(trObj.Is_Sales_Order__c) {
				if(trObj.Sales_Order__r.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order')){
					sendShippingConfimationB2C(trObj.Sales_Order__c);
				}
				else if(trObj.Has_Contact__c && !String.isBlank(trObj.Tracking_Link_Base__c) && !trObj.Sales_Order__r.PBSI__Customer__r.IsDistributor__c) {
					sendShippingConfimationB2B();
				}
			}
		}
	}

	public void sendShippingConfimationB2C(Id orderId) {
		ONRWebService.shippingNotificationWeb(orderId);
	}

	public void sendShippingConfimationB2B() {
		trObj.Send_B2B_Shipping_Confirmation__c = true;
		update trObj;
	}

	public String getStepName() {
		return 'OrderShippingConfirmation';
	}
}