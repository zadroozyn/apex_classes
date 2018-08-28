global class PaymentTermsDaysCalcScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new PaymentTermsDaysCalc());
	}
}