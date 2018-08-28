global class B2BSalesOrderShippingInfoTrackingCtrl {

	public Id trackingId { get; set; }

	public List<Tracking_Number__c> getTrackingNumbers() {
		List<Tracking_Number__c> lNumbers = [SELECT Number__c, Link__c FROM Tracking_Number__c 
			WHERE Tracking__c = :trackingId 
				AND Do_Not_Send__c = false
			ORDER BY CreatedDate ASC];
		return lNumbers;
	}

}