global without sharing class AccountApprovalWebService {

	public class ApprovalException extends Exception {}
	public class WebServiceResponse {
		public Boolean isSuccess;
		public String errorMessage;
	}

	webservice static String startActivationApprovalProcess(Id accountId) {
		WebServiceResponse response = new WebServiceResponse();
		response.isSuccess = true;
		try {
			Account acc = queryAccount(accountId);
			AccountApprovalService approvalService = new AccountApprovalService(acc);
			List<Approval.ProcessResult> lResults = approvalService.startActivationProcess();	
			if(!lResults[0].isSuccess()) {
				throw new ApprovalException('Account is not meeting requirements for Activation');
			}
		} catch (Exception e) {
			response.isSuccess = false;
			response.errorMessage = e.getMessage();
		}
		return JSON.serialize(response);
	}

	webservice static String startDeactivationApprovalProcess(Id accountId) {
		WebServiceResponse response = new WebServiceResponse();
		response.isSuccess = true;
		try {
			Account acc = queryAccount(accountId);
			AccountApprovalService approvalService = new AccountApprovalService(acc);
			List<Approval.ProcessResult> lResults = approvalService.startDeactivationProcess();	
			if(!lResults[0].isSuccess()) {
				throw new ApprovalException('Account is not meeting requirements for Deactivation');
			}
		} catch (Exception e) {
			response.isSuccess = false;
			response.errorMessage = e.getMessage();
		}
		return JSON.serialize(response);
	}

	private static String errorsToString(List<Database.Error> lErrors) {
		String errMsg = '';
		for(Database.Error err: lErrors) {
			errMsg += err.getMessage() + '\n';
		}
		return errMsg;
	}

	private static Account queryAccount(Id accountId) {
		return [SELECT Id,Status__c,RecordTypeId,Approval_Required__c,Name,Activated_At_Least_Once__c FROM Account WHERE Id = :accountId];
	}	
}