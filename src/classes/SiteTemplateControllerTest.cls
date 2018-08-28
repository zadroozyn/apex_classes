@isTest
private class SiteTemplateControllerTest {
    @isTest
    static void testHasErrorMessages() {
        PageReference testedPage = Page.SiteTemplate;
        Test.setCurrentPage(testedPage);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Test ERROR'));
        SiteTemplateController ctlr = new SiteTemplateController();
        System.assertEquals(true, ctlr.hasErrors);
    }

    @isTest
    static void testHasNoErrorMessages() {
        PageReference testedPage = Page.SiteTemplate;
        Test.setCurrentPage(testedPage);
        SiteTemplateController ctlr = new SiteTemplateController();
        System.assertEquals(false, ctlr.hasErrors);
    }
}