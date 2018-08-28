public with sharing virtual class ComponentControllerBase {

  public PageControllerBase pageController { get;     set {      if (value!= null) {    pageController = value;     pageController.setComponentController(this);      }    }
  }
  
    public PageControllerBase pageController1 { get;     set {      if (value!= null) {    pageController1 = value;    pageController1.setComponentController(this);      }    }
  }
}