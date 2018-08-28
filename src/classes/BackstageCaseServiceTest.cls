@isTest
class BackstageCaseServiceTest {

	@isTest static void testAll() {
		BackstageService bss = new BackstageService();
		BackstageCaseService bcs = bss.bcs;
		bcs.getCases();
		bcs.clearFilters();
		bcs.getShoeCodes();
		bcs.getApparelCodes();
		bcs.loadCase();
	}

}