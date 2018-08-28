@isTest
class InvoiceCreditNoteValidatorTest {
	@isTest
	static void testSolution() {
		Id id = 'a2i57000001dFnBAAU';
		System.assert(InvoiceCreditNoteValidator.canCreateCreditNote(id));
	}
}