public class B24AdminController {

	private static final String B24_MESSAGE_FETCH_CLASS_NAME = B24MessageFetch.class.getName();
	private static final String B24_INVRPT_OUT_CLASS_NAME = B24MessageScheduleINVRPT.class.getName();
	
	private B24Settings b24settings;

	public List<B24Settings.DesadvModel> desadvLinesSO {get; set;}
	public List<B24Settings.DesadvModel> desadvLinesTO {get; set;}
	public List<B24Settings.InvrptOutModel> invrptOutLines {get; set;}

	public PBSI__PBSI_Sales_Order__c so {get; set;}
	public PBSI__Transfer_Order__c to {get; set;}
	public Boolean addingDesadvTO {get; set;}

	public Contact invrpt_out_daily_acc {get; set;}
	public String invrpt_out_daily_rpt {get; set;}
	public Boolean adding_invrpt_out_daily {get; set;}

	public Id b24FetchJobId {get; private set;}
	public CronTriggerWrapper b24InvrptOutJob {get; private set;}
	public String removeLineId {get; set;}
	public String sendNowLineId {get; set;}
	public Map<Id, String> mAccounts {get; set;}
	public Map<Id, String> mReports {get; set;}

	public B24AdminController() {
		zeroSetUp();
	}

	private void zeroSetUp() {
		this.b24settings = new B24Settings();
		reloadData();
		desadvLinesSO = new List<B24Settings.DesadvModel>();
		desadvLinesTO = new List<B24Settings.DesadvModel>();
		so = new PBSI__PBSI_Sales_Order__c();
		to = new PBSI__Transfer_Order__c();
		invrpt_out_daily_acc = new Contact();
		addingDesadvTO = false;
		adding_invrpt_out_daily = false;
		getB24FetchJobId();
		getB24InvrptOutJobId();
	}

	private void reloadData() {
		splitDesadvLines( b24settings.getDeasadvLines() );
		invrptOutLines = b24settings.getInvrptOutLines();

		Set<Id> accIds = new Set<Id>();
		Set<Id> rptIds = new Set<Id>();
		for(B24Settings.InvrptOutModel invprtOut: invrptOutLines) {
			accIds.add(invprtOut.accId);
			rptIds.add(invprtOut.rptId);
		}
		mAccounts = new Map<Id, String>();
		List<Account> lAccs = [SELECT Id,Name FROM Account WHERE Id IN :accIds];
		for(Account acc: lAccs) {
			mAccounts.put(acc.Id, acc.name);
		}

		mReports = new Map<Id, String>();
		List<Report> lReports = [SELECT Id,DeveloperName FROM Report WHERE Id IN :rptIds];
		for(Report rpt: lReports) {
			mReports.put(rpt.Id, rpt.DeveloperName);
		}
		System.debug(mReports);
	}

	public String getMessageFetchClassName() {
		return B24_MESSAGE_FETCH_CLASS_NAME;
	}

	public String getInvrptOutClassName() {
		return B24_INVRPT_OUT_CLASS_NAME;
	}

	public void showAddNewDesadvTO() {
		addingDesadvTO = true;
	}

	public void showAddNewInvrptDaily() {
		adding_invrpt_out_daily = true;
	}

	public void hideAddNewInvrptDaily() {
		adding_invrpt_out_daily = false;
	}

	public void addNewDesadvTO() {
		System.debug(to.PBSI__From_Location__c +' '+ to.PBSI__To_Location__c +' '+ so.PBSI__Customer__c);
		b24settings.addDesadv(to.PBSI__From_Location__c, to.PBSI__To_Location__c, so.PBSI__Customer__c);
		addingDesadvTO = false;
	}

	public void addNewInvrptDaily() {
		b24settings.addInvrpt(invrpt_out_daily_acc.AccountId, invrpt_out_daily_rpt);
		adding_invrpt_out_daily = false;
		invrpt_out_daily_acc = new Contact();
		invrpt_out_daily_rpt = '';
		reloadData();
	}

	public void removeInvrptOut() {
		b24settings.removeInvrptOut(removeLineId);
		reloadData();
	}

	public void sendNowSingleInvrpt() {
		String rptId = system.CurrentPageReference().getParameters().get('sendLineRptId');
		String accId = system.CurrentPageReference().getParameters().get('sendLineAccId');
		System.debug(rptId + ' ' + accId );
		B24MessageScheduleINVRPT.singleRunSync(rptId, accId);
	}

	public void sendNowAllInvrpt() {
		B24MessageScheduleINVRPT scheduler = new B24MessageScheduleINVRPT();
		scheduler.informUser(true);
		scheduler.execute(null);
	}

	public void turnOffMessageFetch() {
		List<AsyncApexJob> lJobs = getAllWorkingFetchMessageJobs();
		for(AsyncApexJob msgFetchJob: lJobs) {
			System.abortJob(msgFetchJob.Id);
		}
		getB24FetchJobId();
	}

	public void turnOnMessageFetch() {
		B24MessageFetch fetchJob = new B24MessageFetch();
		System.enqueueJob(fetchJob);
		getB24FetchJobId();
	}

	public void turnOffInvrptOut() {
		B24MessageScheduleINVRPT.stopAllJobs();
		getB24InvrptOutJobId();
	}

	public void turnOnInvrptOut() {
		B24MessageScheduleINVRPT.scheduleDaily(6);
		getB24InvrptOutJobId();
	}

	public void saveAllChanges() {
		b24settings.save();
		zeroSetUp();
	}

	public void cancelAllChanges() {
		zeroSetUp();
	}

	private void splitDesadvLines(List<B24Settings.DesadvModel> allDesadvLines) {
		for(B24Settings.DesadvModel line: allDesadvLines) {
			if(line.type == 'SO') {
				desadvLinesSO.add(line);
			} else if(line.type == 'TO') {
				desadvLinesTO.add(line);
			}
		}
	}

	private void getB24FetchJobId() {
		List<AsyncApexJob> lJobs = getAllWorkingFetchMessageJobs();
		b24FetchJobId = !lJobs.isEmpty() ? lJobs[0].Id : null;
	}

	private static List<AsyncApexJob> getAllWorkingFetchMessageJobs() {
		return [SELECT Id FROM AsyncApexJob
			WHERE JobType='Queueable' and ApexClass.Name = :B24_MESSAGE_FETCH_CLASS_NAME 
			and (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')];
	}

	private void getB24InvrptOutJobId() {
		CronTrigger job = B24MessageScheduleINVRPT.getScheduledJob();
		job = job != null ? job : new CronTrigger();
		b24InvrptOutJob = new CronTriggerWrapper(job);
	}

	public class CronTriggerWrapper {
		private CronTrigger cTrigger;

		public CronTriggerWrapper(CronTrigger cTrigger) {
			this.cTrigger = cTrigger;
		}

		public Id jobId {
			get {
				return cTrigger.Id;
			}
		}

		public String nextRunTime {
			get {
				String ret = 'N/A';
				if(cTrigger.NextFireTime != null) {
					ret = cTrigger.NextFireTime.format();
				}
				return ret;
			}
		}
	}

}