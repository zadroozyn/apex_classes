@isTest
public class OSCA_MockInbound {

	private static Integer oscaIdStartNumber = 476;
	private static Integer oscaSchdeduleIdStartNumber = 4186;

	public static Integer orderedQuantity = 11;
	public static String status = 'Open';
	public static Date requestedDate = System.today().addDays(30);
	public static Date dueDate = System.today().addDays(60);

	public static String getUpdateRequestBody(List<Id> lIds) {
		List<PBSI__PBSI_Purchase_Order_Line__c> lLines = new List<PBSI__PBSI_Purchase_Order_Line__c>();
		for(Id idTmp: lIds) {
			lLines.add(
				new PBSI__PBSI_Purchase_Order_Line__c(
					Id = idTmp,
					PBSI__Quantity_Ordered__c = orderedQuantity,
					PBSI__Status__c = status,
					Requested_in_house_date__c = requestedDate,
					PBSI__Due_Date__c = dueDate,
					Osca_OrderId__c = String.valueOf(oscaIdStartNumber++),
					Osca_ScheduleId__c = String.valueOf(oscaSchdeduleIdStartNumber++)
				)
			);
		}
		return JSON.serialize(lLines);
	}

	public static String getCreateRequestBody(List<Id> poLinesIds) {
		List<PBSI__PBSI_Purchase_Order_Line__c> lLines = new List<PBSI__PBSI_Purchase_Order_Line__c>();
		for(Id poLineId: poLinesIds) {
			lLines.add(
				new PBSI__PBSI_Purchase_Order_Line__c(
					Id = poLineId,
					PBSI__Quantity_Ordered__c = orderedQuantity,
					Osca_OrderId__c = String.valueOf(oscaIdStartNumber++),
					Osca_ScheduleId__c = String.valueOf(oscaSchdeduleIdStartNumber++)
				)
			);
		}
		return JSON.serialize(lLines);
	}

	public static String getCancelParam(List<Id> lIds) {
		return String.join(lIds, ',');
	}
	
}