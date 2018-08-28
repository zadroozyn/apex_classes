public with sharing virtual class B2BPortalPageControllerBase {
	
	@TestVisible protected B2BPortalComponentControllerBase myComponentController;
	public boolean placeNewOrderMode {get; set;}
	public boolean viewOrderMode {get; set;}
	public Id orderId {get; set;}
	public String dateFormatForSorting{get; set;}

	public virtual B2BPortalComponentControllerBase getMyComponentController() {
		return myComponentController;
	}

	public virtual void setComponentController(B2BPortalComponentControllerBase compController) {
		myComponentController = compController;
	}

	public virtual void refreshData() {}
	public B2BPortalPageControllerBase getThis() {
		return this;
	}
	public void enterViewOrderMode() {
		viewOrderMode = true;
	}
	public void enterPlaceNewOrderMode() {
		placeNewOrderMode = true;
	}

    public void initialiseOrderDetail() {
        myComponentController.initalizeOrder();
    }

}