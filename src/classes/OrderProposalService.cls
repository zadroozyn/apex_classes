global without sharing class OrderProposalService {

	webservice static String sendProposal(Id orderId) {
		PBSI__PBSI_Sales_Order__c order = [SELECT Id, PBSI__Contact__c, Proposal_Status__c FROM PBSI__PBSI_Sales_Order__c WHERE Id =: orderId];
		User portalUser = [SELECT Id FROM User WHERE ContactId =: order.PBSI__Contact__c];
		order.Proposal_Status__c = 'Sent';
		order.OwnerId = portalUser.Id;
		update order;
		SObject shareOb = ShareHandler.createShare(portalUser.Id, orderId, 'Edit', 'PBSI__PBSI_Sales_Order__c', 'Portal_user_access__c');
		insert shareOb;
		return '';
	}

	webservice static String sendMasterProposal(Id mOrderId) {
		Map<String, Object> output = new Map<String, Object>();
		Master_Order__c mOrder;
		try {
			mOrder = [SELECT Id, Customer_contact__c, RecordTypeId, (SELECT Id FROM Sales_Orders__r) FROM Master_order__c WHERE Id =: mOrderId];
		} catch (QueryException  e) {
			output.put('msg', 'There is no Master Order with Id: \'' + mOrderId + '\'.');
			output.put('result', false);
			return JSON.serialize(output);

		} catch (Exception e) {
			output.put('msg', e.getMessage());
			output.put('result', false);
			return JSON.serialize(output);
		}
		if(mOrder.RecordTypeId != RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal')){
			output.put('msg', 'This Master order is not a Proposal');
			output.put('result', false);
			return JSON.serialize(output);
		}
		User backstageUser;
		try {
			backstageUser = [SELECT Id FROM User WHERE ContactId =: mOrder.Customer_contact__c AND IsActive = TRUE]; 
		} catch (QueryException e) {
			output.put('msg', 'Contact of this Master Order doesn\'t have Backstage enabled.');
			output.put('result', false);
			return JSON.serialize(output);
		} catch (Exception e) {
			output.put('msg', e.getMessage());
			output.put('result', false);
			return JSON.serialize(output);
		}
		try {
			mOrder.Proposal_status__c = 'Sent';
			update mOrder;
			List<sObject> shares = new List<sObject>();
			shares.add(ShareHandler.createShare(backstageUser.Id, mOrderId, 'Edit', 'Master_order__c', 'Backstage_access__c'));
			final List<Id> sOrderIds = new List<Id>();
			for(PBSI__PBSI_Sales_Order__c current : mOrder.Sales_Orders__r) {
				sOrderIds.add(current.Id);
			}
			shares.addAll(ShareHandler.createShares(new List<Id> {backstageUser.Id}, sOrderIds, 'Edit', 'PBSI__PBSI_Sales_Order__c', 'Portal_user_access__c', false));
			insert shares;
		} catch (Exception e) {
			output.put('msg', e.getMessage());
			output.put('result', false);
			return JSON.serialize(output);
		}
		output.put('result', true);
		return JSON.serialize(output);
	}

	webservice static String convertMasterProposal(Id mOrderId) {
		Master_order__c mOrder = [SELECT Id, RecordTypeId  FROM Master_order__c WHERE Id =: mOrderId];
		if(mOrder.RecordTypeId != RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal')){
			return String.valueOf(false);
		}
		mOrder.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Order');
		update mOrder;
		return String.valueOf(true);
	}

}