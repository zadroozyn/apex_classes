public class SalesOrderTrackingInformationHelper {
	
	public static final String TRACKING_NO_SEPARATOR = ', ';

	public static Set<String> clalculateNewTrackingNumbers(PBSI__PBSI_Sales_Order__c oldSalesOrder, PBSI__PBSI_Sales_Order__c newSalesOrder){

		Set<String> oldTrackingNumbers = getAllTrackingNumbers(oldSalesOrder);
		Set<String> newTrackingNumbers = getAllTrackingNumbers(newSalesOrder);
		newTrackingNumbers.removeAll(oldTrackingNumbers);
		return newTrackingNumbers;
	}

	private static Set<String> getAllTrackingNumbers(PBSI__PBSI_Sales_Order__c salesOrder) {
		Set<String> trackNumbers = new Set<String>();
		if(!String.isEmpty(salesOrder.Tracking_Information__c)) {
			List<String> bulkNumbers = salesOrder.Tracking_Information__c.split(',');
			for(String trackNo: bulkNumbers) {
				String formattedTrackNo = trackNo.trim();
				if(!String.isBlank(formattedTrackNo)) {
					trackNumbers.add(formattedTrackNo);
				}
			}
		}
		for(Integer i=1;i<=30;i++) {
			try {
				String trackNo = (String) salesOrder.get('Tracking_Number_'+i+'__c');
				if(!String.isBlank(trackNo)) {
					trackNumbers.add(trackNo);
				}
			} catch (Exception e) {
				//field not exist
			}
		}

		for(Integer i=1;i<=6;i++) {
			try {
				String trackNo = (String) salesOrder.get('Back_Order_Tracking_Number_'+i+'__c');
				if(!String.isBlank(trackNo)) {
					trackNumbers.add(trackNo);
				}
			} catch (Exception e) {
				//field not exist
			}
		}
		
		return trackNumbers;
	}
}