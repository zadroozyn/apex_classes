public class MatrixSaveJson {
	public List<Header> headers;
	public List<Line> lines;

	public class Header {
		public Id headId;
		public String shipDate;
		public Map<Id, Line> lines;
		public String pageId;
	}

	public class Line {
		public Id headId;
		public Id itemId;
		public Integer prevQuantity;
		public Integer newQuantity;
		public Integer packedQuantity;
		public List<Id> existingId;
	}
}