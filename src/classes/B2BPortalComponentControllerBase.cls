public with sharing virtual class B2BPortalComponentControllerBase {
	public B2BPortalPageControllerBase pageController;
	public virtual B2BPortalPageControllerBase getPageController() {
		return pageController;
	}
	public virtual void setPageController(B2BPortalPageControllerBase value) {
		if (value != null) {
			pageController = value;
			pageController.setComponentController(this);
		}
	}
    public virtual void initalizeOrder() {}
}