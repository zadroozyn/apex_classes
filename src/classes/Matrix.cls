public interface Matrix {
	Map<String, Object> getOptions();
	Object getFilterData();
	Object getMatrixData(Map<String, List<String>> input);
	Map<String, Object> saveMatrixData(String data);
}