global class ScheduleCountTotalsPersonAccountStart implements Schedulable{
    global void execute(SchedulableContext sc) {
		BatchCountTotalsPersonAccountStart job = new BatchCountTotalsPersonAccountStart('LAST_N_DAYS:8');
		Database.executeBatch(job);
	}
}