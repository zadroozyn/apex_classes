global class B24MessageScheduleINVRPT implements Schedulable {

	global static final String JOB_NAME = 'INVRPT out daily';
	global class JobAlreadyScheduledException extends Exception {}
	private Boolean informUser;

	global B24MessageScheduleINVRPT() {
		informUser = false;
	}

	global void informUser(Boolean sendInfo) {
		informUser = sendInfo;
	}

	global void execute(SchedulableContext sc) {
		B24Settings settings = new B24Settings();
		List<B24Settings.InvrptOutModel> invrptInfos = settings.getInvrptOutLines();
		Map<Id, Set<Id>> mapReportId2AccIds = new Map<Id, Set<Id>>();
		for(B24Settings.InvrptOutModel invrptInfo: invrptInfos) {
			if(mapReportId2AccIds.containsKey(invrptInfo.rptId)) {
				mapReportId2AccIds.get(invrptInfo.rptId).add(invrptInfo.accId);
			} else {
				mapReportId2AccIds.put(invrptInfo.rptId, new Set<Id>{invrptInfo.accId});
			}
		}
		B24MessageBatchINVRPT b = new B24MessageBatchINVRPT(mapReportId2AccIds);
		if(informUser) {
			b.setUserToInform(UserInfo.getUserId());
		}
		Database.executebatch(b, 1);
	}

	global static void singleRunSync(Id rptId, Id accId) {
		Map<Id, Set<Id>> mapReportId2AccIds = new Map<Id, Set<Id>>();
		mapReportId2AccIds.put(rptId, new Set<Id>{accId});
		system.debug(mapReportId2AccIds);
		B24MessageBatchINVRPT b = new B24MessageBatchINVRPT(mapReportId2AccIds);
		b.execute(null, new List<Report>{new Report(Id=rptId)});
	}

	global static String scheduleDaily(Integer hour) {
		if(!getAllScheduledJobs().isEmpty()) {
			throw new JobAlreadyScheduledException('Scheduling more that 1 job is not supported');
		}
		return System.Schedule(JOB_NAME, '0 0 '+hour+' * * ?', new B24MessageScheduleINVRPT());
	}

	global static void stopAllJobs() {
		List<CronTrigger> lJobs = getAllScheduledJobs();
		for(CronTrigger job: lJobs) {
			System.abortJob(job.Id);
		}
	}

	global static CronTrigger getScheduledJob() {
		List<CronTrigger> lJobs = getAllScheduledJobs();
		CronTrigger job = null;
		if(!lJobs.isEmpty()) {
			job = lJobs[0]; 
		}
		return job;
	}

	private static List<CronTrigger> getAllScheduledJobs() {
		return [SELECT Id, CronJobDetail.Name, NextFireTime, PreviousFireTime FROM CronTrigger 
			WHERE CronJobDetail.Name = :JOB_NAME];
	}
}