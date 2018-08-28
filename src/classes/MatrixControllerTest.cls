@isTest
private class MatrixControllerTest {
	
	@isTest static void options() {
		MatrixController.getOptions(new Map<String, String> {'pageName' => 'CaseComposer'});
	}
	
	@isTest static void filterData() {
		MatrixController.getFilterData(new Map<String, String> {'pageName' => 'CaseComposer'});
	}

	@isTest static void matrixData() {
		TestDataFactory tdf = TestDataFactory.instance;
		Case c = new Case(
			Subject = 'test case'
		);
		insert c;
		Map<String, String> pageOptions = new Map<String,String>{'contextId' => c.Id, 'pageName' => 'CaseComposer'};
		Map<String, List<String>> input = new Map<String, List<String>>();
		input.put(
			'itemGroups',
			new List<String>{(String)tdf.itemGroups.getAllSObjects()[0].get('Name'), (String)tdf.itemGroups.getAllSObjects()[1].get('Name')}
		);
		MatrixController.getMatrixData(
			pageOptions,
			input
		);
	}

	@isTest static void saveMatrixData() {
		TestDataFactory tdf = TestDataFactory.instance;
		Map<String, String> pageOptions = new Map<String,String>{'contextId' => null, 'pageName' => 'CaseComposer'};
		MatrixSaveJson data = new MatrixSaveJson();
		data.lines = new List<MatrixSaveJson.Line>();
		MatrixSaveJson.Line l = new MatrixSaveJson.Line();
		l.itemId = tdf.items.getAllSObjects()[0].Id;
		l.prevQuantity = 0;
		l.newQuantity = 1;
		data.lines.add(l);
		MatrixController.saveMatrixData(pageOptions,JSON.serialize(data));
	}

	@isTest static void accountId() {
		new CaseMatrix().getAccountId();
	}

	@isTest static void nonStandardUser() {
		TestDataFactory tdf = TestDataFactory.instance;
		Contact c = new Contact(
			LastName = 'Bond',
			accountId = tdf.accounts.getAllSObjects()[0].Id
		);
		insert c;
		Id profileId = [Select Id from Profile where Name = 'Backstage Distributor'].Id;
		User u = new User(
			ProfileId = profileId,
			UserName = 'MatrixControllerTestUser@example.com.test',
			LastName = 'Bond',
			Email = 'MatrixControllerTestUser@example.com',
			Alias = 'mctu',
			TimeZoneSidKey = 'Europe/Berlin',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			ContactId = c.Id
		);
		insert u;
		System.runAs(u) {
			new CaseMatrix();
		}
	}
	

	@testSetup
	static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.locations.createSObject('EU-Stock', true);
		tdf.collections.createSObject(
			'Warranty',
			'Warranty',
			'Active',
			null,
			true
		);
		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);
		tdf.itemGroups.createSObject('CloudX group', '800', 'EUR', 'No desc', null, true);

		tdf.items.createSObject(
			'Shoe1', 500, 600, 'a simple shoe', tdf.locations.getAllSObjects()[0].Id, tdf.itemGroups.getAllSObjects()[0].Id, '423646', true
		);

		tdf.accounts.createSObject(
			'Test Account', 'EUR', true
		);
	}
}