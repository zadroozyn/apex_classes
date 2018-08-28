@isTest
private class SetControllerTest {

	private static final String NAME_BASE = 'SimpleName_';
	
	@isTest static void oneFullPageNonDefaultSize() {
		Integer size = 10;
		List<Object> lObjects = getObjectList(size);
		SetController paginator = new SetController(lObjects,size);

		System.assertEquals(size,paginator.getToalObjectsCount());
		System.assertEquals(1,paginator.getNumberOfPages());
		System.assertEquals(0,paginator.getCurrentPage());

		List<Object> lObjReturned = paginator.getNextPage();
		System.assertEquals(1,paginator.getCurrentPage());
		System.assertEquals(true,lObjReturned.equals(lObjects));
		System.assertEquals(1,paginator.getPageBegin());
		System.assertEquals(size,paginator.getPageEnd());
		System.assertEquals(false,paginator.canGoNext());
		System.assertEquals(false,paginator.canGoPrev());
		System.assertEquals(false,paginator.isPageValid(0));
		System.assertEquals(false,paginator.isPageValid(2));
		System.assertEquals(true,paginator.isPageValid(1));
	}

	@isTest static void oneFullPageDefaultSize() {
		Integer size = SetController.DEFAULT_PAGE_SIZE;
		List<Object> lObjects = getObjectList(size);
		SetController paginator = new SetController(lObjects);

		System.assertEquals(size,paginator.getToalObjectsCount());
		System.assertEquals(1,paginator.getNumberOfPages());
		System.assertEquals(0,paginator.getCurrentPage());

		List<Object> lObjReturned = paginator.getNextPage();
		System.assertEquals(1,paginator.getCurrentPage());
		System.assertEquals(true,lObjReturned.equals(lObjects));
		System.assertEquals(1,paginator.getPageBegin());
		System.assertEquals(size,paginator.getPageEnd());
		System.assertEquals(false,paginator.canGoNext());
		System.assertEquals(false,paginator.canGoPrev());
		System.assertEquals(false,paginator.isPageValid(0));
		System.assertEquals(false,paginator.isPageValid(2));
		System.assertEquals(true,paginator.isPageValid(1));
	}

	@isTest static void secondPageNotFullPageDefaultSize() {
		Integer elementsNo = SetController.DEFAULT_PAGE_SIZE * 2 - 1;
		List<Object> lObjects = getObjectList(elementsNo);
		SetController paginator = new SetController(lObjects);

		System.assertEquals(elementsNo,paginator.getToalObjectsCount());
		System.assertEquals(2,paginator.getNumberOfPages());
		System.assertEquals(0,paginator.getCurrentPage());

		List<Object> lObjReturned = paginator.getNextPage();
		System.assertEquals(1,paginator.getCurrentPage());
		System.assertEquals(true,lObjReturned.equals( getArraySlice(lObjects,0,SetController.DEFAULT_PAGE_SIZE) ));
		System.assertEquals(1,paginator.getPageBegin());
		System.assertEquals(SetController.DEFAULT_PAGE_SIZE,paginator.getPageEnd());
		System.assertEquals(true,paginator.canGoNext());
		System.assertEquals(false,paginator.canGoPrev());
		System.assertEquals(false,paginator.isPageValid(0));
		System.assertEquals(true,paginator.isPageValid(2));
		System.assertEquals(true,paginator.isPageValid(1));

		lObjReturned = paginator.getNextPage();
		System.assertEquals(2,paginator.getCurrentPage());
		System.assertEquals(true,lObjReturned.equals( getArraySlice(lObjects,SetController.DEFAULT_PAGE_SIZE,SetController.DEFAULT_PAGE_SIZE) ));
		System.assertEquals(SetController.DEFAULT_PAGE_SIZE+1,paginator.getPageBegin());
		System.assertEquals(elementsNo,paginator.getPageEnd());
		System.assertEquals(false,paginator.canGoNext());
		System.assertEquals(true,paginator.canGoPrev());
		System.assertEquals(false,paginator.isPageValid(0));
		System.assertEquals(true,paginator.isPageValid(2));
		System.assertEquals(true,paginator.isPageValid(1));

		lObjReturned = paginator.getPrevPage();
		System.assertEquals(1,paginator.getCurrentPage());
		System.assertEquals(true,lObjReturned.equals( getArraySlice(lObjects,0,SetController.DEFAULT_PAGE_SIZE) ));
		System.assertEquals(1,paginator.getPageBegin());
		System.assertEquals(SetController.DEFAULT_PAGE_SIZE,paginator.getPageEnd());
		System.assertEquals(true,paginator.canGoNext());
		System.assertEquals(false,paginator.canGoPrev());
		System.assertEquals(false,paginator.isPageValid(0));
		System.assertEquals(true,paginator.isPageValid(2));
		System.assertEquals(true,paginator.isPageValid(1));
	}

	@isTest static void fiftyPagesNotFullPageDefaultSize() {
		Integer elementsNo = SetController.DEFAULT_PAGE_SIZE * 50 - 1;
		List<Object> lObjects = getObjectList(elementsNo);
		SetController paginator = new SetController(lObjects);

		System.assertEquals(elementsNo,paginator.getToalObjectsCount());
		System.assertEquals(50,paginator.getNumberOfPages());
		System.assertEquals(0,paginator.getCurrentPage());

		List<Object> lObjReturned;
		for(Integer i = 0; i < 49; i++) {
			lObjReturned = paginator.getNextPage();
		}
		System.assertEquals(49,paginator.getCurrentPage());
		Integer beginPos = elementsNo-(2*SetController.DEFAULT_PAGE_SIZE)+1;
		System.assertEquals(true,lObjReturned.equals( 
			getArraySlice(lObjects,beginPos,SetController.DEFAULT_PAGE_SIZE) ));
		System.assertEquals(beginPos+1,paginator.getPageBegin());
		System.assertEquals(SetController.DEFAULT_PAGE_SIZE*49,paginator.getPageEnd());
		System.assertEquals(true,paginator.canGoNext());
		System.assertEquals(true,paginator.canGoPrev());
		for(Integer i = 1; i <= 50; i++) {
			System.assertEquals(true,paginator.isPageValid(i));
		}
		System.assertEquals(false,paginator.isPageValid(51));
		System.assertEquals(false,paginator.isPageValid(0));

		lObjReturned = paginator.getNextPage();
		System.assertEquals(50,paginator.getCurrentPage());
		beginPos = elementsNo-SetController.DEFAULT_PAGE_SIZE+1;
		System.assertEquals(true,lObjReturned.equals( 
			getArraySlice(lObjects,beginPos,SetController.DEFAULT_PAGE_SIZE) ));
		System.assertEquals(beginPos+1,paginator.getPageBegin());
		System.assertEquals(elementsNo,paginator.getPageEnd());
		System.assertEquals(false,paginator.canGoNext());
		System.assertEquals(true,paginator.canGoPrev());
		System.assertEquals(false,paginator.isPageValid(0));
		System.assertEquals(false,paginator.isPageValid(51));

		lObjReturned = paginator.getPrevPage();
		System.assertEquals(49,paginator.getCurrentPage());
		beginPos = elementsNo-(2*SetController.DEFAULT_PAGE_SIZE)+1;
		System.assertEquals(true,lObjReturned.equals( 
			getArraySlice(lObjects,beginPos,SetController.DEFAULT_PAGE_SIZE) ));
		System.assertEquals(beginPos+1,paginator.getPageBegin());
		System.assertEquals(SetController.DEFAULT_PAGE_SIZE*49,paginator.getPageEnd());
		System.assertEquals(true,paginator.canGoNext());
		System.assertEquals(true,paginator.canGoPrev());
	}

	@isTest static void errors() {
		Integer size = null;
		List<Object> lObjects = getObjectList(0);

		SetController paginator = new SetController(lObjects);
		System.assertEquals(1,paginator.getNumberOfPages());
		Boolean hasError = false;
		try {
			paginator.getPage(2);
		} catch (SetController.InvalidArgumentException e) {
			hasError = true;
		}
		System.assertEquals(true,hasError);

		hasError = false;
		try {
			paginator = new SetController(lObjects,null);
		} catch (SetController.InvalidArgumentException e) {
			hasError = true;
		}
		System.assertEquals(true,hasError);

		hasError = false;
		try {
			paginator = new SetController(lObjects,0);
		} catch (SetController.InvalidArgumentException e) {
			hasError = true;
		}
		System.assertEquals(true,hasError);

		hasError = false;
		try {
			paginator = new SetController(null,2);
		} catch (SetController.InvalidArgumentException e) {
			hasError = true;
		}
		System.assertEquals(true,hasError);
	}

	static List<Object> getArraySlice(List<Object> lObjects, Integer beginPosition, Integer noOfElements) {
		List<Object> retlist = new List<Object>();
		for(Integer i = beginPosition; i < beginPosition+noOfElements; i++) {
			if(i>=lObjects.size()) {
				break;
			}
			retlist.add(lObjects[i]);
		}
		return retlist;
	}
	
	static List<TestObj> getObjectList(Integer nrOfObjects) {
		List<TestObj> lObjects = new List<TestObj>();
		for(Integer i = 0; i < nrOfObjects; i++) {
			TestObj tObj = new TestObj();
			tObj.name = NAME_BASE+i;
			tObj.value = String.valueOf(i);
			lObjects.add(tObj);
		}
		return lObjects;
	}

	private class TestObj {
		public String name;
		public String value;
	}
	
}