global class AccountFinanceCalculationScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		AccountFinanceCalculationBatch b = new AccountFinanceCalculationBatch();
		Database.executebatch(b,50);
	}
}