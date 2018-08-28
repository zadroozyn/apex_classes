public interface AsyncRequestManager {
	HttpRequestBuilder getRequestBuilder();
	void callback(HttpResponse response);
	void onError(Exception e);
	Id enqueue();
}