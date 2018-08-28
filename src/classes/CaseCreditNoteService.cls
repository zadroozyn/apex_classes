global with sharing class CaseCreditNoteService {
	webservice static String createCreditNote(Id caseId) {
		Map<String, Object> output = new Map<String, Object>();
		if(String.isBlank(caseId)) {
			output.put('success', false);
			output.put('msg', 'Incorrect case Id');
			return JSON.serialize(output);
		}
		Id scrId;
		try {
			Case c = [SELECT Id, Sales_Credit_Note__r.c2g__CreditNoteStatus__c, PBSI__Sales_Order__c FROM Case WHERE Id =: caseId FOR UPDATE];
			if(c.Sales_Credit_Note__c == null || c.Sales_Credit_Note__r.c2g__CreditNoteStatus__c != 'complete') {
				Map<Id, Double> product2price= new Map<Id, Double>();
				for(PBSI__PBSI_Sales_Order_Line__c current : [SELECT Id, PBSI__Item__r.PBSI__Product__c, PBSI__Price4__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c =: c.PBSI__Sales_Order__c]) {
					product2price.put(current.PBSI__Item__r.PBSI__Product__c, current.PBSI__Price4__c);
				}
				scrId = Ascent2FF.WebSerrviceClass.CreateCreditNote(c.Id);
				List<c2g__codaCreditNoteLineItem__c> toUpdate = new List<c2g__codaCreditNoteLineItem__c>();
				for(c2g__codaCreditNoteLineItem__c current : [SELECT Id, c2g__Product__c, c2g__Quantity__c, c2g__TaxRate1__c FROM c2g__codaCreditNoteLineItem__c WHERE c2g__creditNote__c =: scrId FOR UPDATE]) {
					current.c2g__unitPrice__c = product2price.get(current.c2g__Product__c);
					current.c2g__TaxValue1__c = (current.c2g__unitPrice__c * current.c2g__Quantity__c * current.c2g__TaxRate1__c * 0.01).setScale(2);
					toUpdate.add(current);
				}
				update toUpdate;
				c.Sales_Credit_Note__c = scrId;
				update c;
			} else {
				output.put('success', false);
				output.put('msg', 'This case already has SCR!');
				return JSON.serialize(output);
			}
		} catch (Exception e) {
			output.put('success', false);
			output.put('msg', 'Couldn\'t finish with Error: ' + e.getMessage());
			return JSON.serialize(output);
		}
		output.put('success', true);
		output.put('scrId', scrId);
		return JSON.serialize(output);
	}
}