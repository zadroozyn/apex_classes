public with sharing virtual class PageControllerBase 
{	
  public ComponentControllerBase myComponentController;
  public ViewSoLinesController newsocomponent; 
  
  public virtual ComponentControllerBase getMyComponentController() {
    return myComponentController;
  }

  public virtual void setComponentController(ComponentControllerBase compController) {
    myComponentController = compController;
  }
  
   public virtual ViewSoLinesController getnewsocomponent() {
    return newsocomponent;
  }

  public virtual void setnewsocomponent(ViewSoLinesController vp) {
    newsocomponent = vp;
  }	

  public PageControllerBase getThis() {
    return this;
  }
}