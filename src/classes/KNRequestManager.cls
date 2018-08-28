public abstract class KNRequestManager implements AsyncRequestManager, Queueable, Database.AllowsCallouts {
	protected List<HttpRequestBuilder> requests;
	protected Integer currentRequest;
	protected Integer currentRepetition;
	protected boolean doContinue;

	public KNRequestManager() {
		this.requests = new List<HttpRequestBuilder>();
		this.doContinue = true;
		this.currentRequest = 0;
		this.currentRepetition = 0;
	}

	public HttpRequestBuilder getRequestBuilder() {
		return this.requests.get(this.currentRequest);
	}

	public void callback(HttpResponse response) {
		this.currentRepetition = 0;
		this.currentRequest += 1;
		if(this.currentRequest == this.requests.size() || Test.isRunningTest()) {
			this.orderUpdate();
		} else {
			this.enqueue();
		}
	}

	public void addRequestBuilder(HttpRequestBuilder input) {
		this.requests.add(input);
	}

	public Id enqueue() {
		return System.enqueueJob(this);
	}
	
	public abstract void onError(Exception e);
	public abstract void execute(QueueableContext context);
	protected abstract void orderUpdate();
}