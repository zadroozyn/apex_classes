@isTest
private class ApprovalGroupTest {
	
	@isTest static void testPositive() {
		ApprovalGroup testGroup = new ApprovalGroup('Test_Approval','Test_Approval','Case');
		List<String> fields = new List<String> {
			'Account.Name','Subject'
		};
		testGroup.setAdditionalFields(fields);

		System.assertEquals(2,testGroup.additionalFieldsList.size());
		for(ApprovalGroup.ApprovalField field: testGroup.additionalFieldsList) {
			if(field.path.equalsIgnoreCase('Account.Name')) {
				System.assertEquals(true,field.isReference);
				System.assertEquals(true,field.referenceIdPath.equalsIgnoreCase('Account.Id'));
			} else if(field.path.equalsIgnoreCase('Subject')) {
				System.assertEquals(false,field.isReference);
			} else {
				System.assert(false, 'Wrong field: '+field.path);
			}
		}

		System.assertEquals(true,fields.equals(testGroup.getAdditionalFieldsPaths()));

		Case c = new Case(Subject='mock subject');
		insert c;

		ApprovalGroup.PIWIWrapper piwiWrap = new ApprovalGroup.PIWIWrapper();
		piwiWrap.piwiId = c.Id;
		piwiWrap.piwiTargetName = 'Case';
		piwiWrap.piwiTargetId = c.Id;
		piwiWrap.processDevName = 'Test_Approval';
		piwiWrap.submitted = System.now().addMinutes(-3);
		piwiWrap.waitingFrom = System.now();
		piwiWrap.sObj = c;
			
	}

	@isTest static void testNegative() {
		ApprovalGroup testGroup = new ApprovalGroup('Test_Approval','Test_Approval');
		List<String> fields = new List<String> {
			'Account.Name','Subject'
		};

		Boolean hasError = false;
		try {
			testGroup.setAdditionalFields(fields);
		} catch (ApprovalGroup.SObjectTypeException e) {
			hasError = true;
		}

		System.assertEquals(true,hasError);
	}
	
}