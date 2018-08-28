public with sharing class MatrixController {

	@RemoteAction
	public static Object getOptions(Map<String, String> options) {
		return getMatrix(options).getOptions();
	}

	@RemoteAction 
	public static Object getFilterData(Map<String, String> options) {
		return getMatrix(options).getFilterData();
	}

	@RemoteAction 
	public static Object getMatrixData(Map<String, String> options, Map<String, List<String>> input) {
		return getMatrix(options).getMatrixData(input);
	}

	@RemoteAction
	public static Map<String, Object> saveMatrixData(Map<String, String> options, String data) {
		return getMatrix(options).saveMatrixData(data);
	}

	private static Matrix getMatrix(Map<String, String> options) {
		if(options.get('pageName') == 'CaseComposer')
			return new CaseMatrix();
		return new OrderMatrix(options.get('contextId'));
	}
}