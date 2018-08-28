public with sharing class SetController {

	public static final Integer DEFAULT_PAGE_SIZE = 5;
	public class InvalidArgumentException extends Exception {}

	public List<Object> lObjects {
		get;
		private set {
			if(value == null) {
				throw new InvalidArgumentException('List of objects can\'t be null');
			}
			lObjects = value;
		}
	}
	public Integer objectsPerPage {
		get;
		private set {
			if(value == null || value < 1) {
				throw new InvalidArgumentException('Number of objects per page must be greater than 0, passed value is '+value);
			}
			objectsPerPage = value;
		} 
	}

	private Integer currentPage = 0;
	private Integer currentPageBegin = 0;
	private Integer currentPageEnd = 0;

	public SetController(List<Object> objects) {
		this(objects,DEFAULT_PAGE_SIZE);
	}

	public SetController(List<Object> objects, Integer objectsPerPage) {
		lObjects = objects;
		setObjectsPerPage(objectsPerPage);
	}

	public void setObjectsPerPage(Integer objectsPerPage) {
		this.objectsPerPage = objectsPerPage;
		setCurrentPosition(0,0,0);
	}

	private void setCurrentPosition(Integer page, Integer pageBegin, Integer pageEnd) {
		currentPage = page;
		currentPageBegin = pageBegin;
		currentPageEnd = pageEnd;
	}

	public Integer getNumberOfPages() {
		if(lObjects.isEmpty()) {
			return 1;
		}
		Integer nrPages = lObjects.size() / objectsPerPage;
		return Math.mod(lObjects.size(),objectsPerPage) == 0 ? nrPages : nrPages + 1;
	}

	public Integer getCurrentPage() {
		return currentPage;
	}

	public Integer getToalObjectsCount() {
		return lObjects.size();
	}

	public Integer getPageBegin() {
		return currentPageBegin;
	}

	public Integer getPageEnd() {
		return currentPageEnd;
	}

	public List<Object> getNextPage() {
		return getPage(currentPage + 1);
	}

	public List<Object> getPrevPage() {
		return getPage(currentPage - 1);
	}

	public List<Object> getPage(Integer pageNr) {
		if(!isPageValid(pageNr)) {
			throw new InvalidArgumentException('Page number out of bounds: '+pageNr);
		}

		List<Object> retList = new List<Object>();
		Integer pageBegin = pageNr*objectsPerPage-objectsPerPage;
		Integer pageEnd = pageBegin;
		for(Integer i = pageBegin; i < pageNr*objectsPerPage; i++) {
			if(i>=lObjects.size()) {
				break;
			}
			pageEnd++;
			retList.add(lObjects[i]);
		}
		setCurrentPosition(pageNr,pageBegin+1,pageEnd);
		return retList;
	}

	public Boolean canGoNext() {
		return isPageValid(currentPage + 1);
	}

	public Boolean canGoPrev() {
		return isPageValid(currentPage - 1);
	}

	public Boolean isPageValid(integer pageNr) {
		return pageNr >= 1 && pageNr <= getNumberOfPages();
	}

}