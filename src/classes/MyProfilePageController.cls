/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
 *  Guest users are never able to access this page.
 */
public without sharing class MyProfilePageController {

    public User user {get; set;}
    public Account userAccount {get; set;}
    public Date birthdate {get; set;}
    public String[] distributorFunction {get; set;}
    public String distributorFunctionSingle {get; set;}

    public MyProfilePageController() {
        loadDefaults();

        System.debug('is Accessible' + Schema.sObjectType.Contact.fields.Shoe_size__c.isAccessible());
    }

    public void loadDefaults() {
        user = [SELECT ID, Name, AccountID, ContactID, usertype, Email, LastName, FirstName,
                Contact.Salutation, Contact.FirstName, Contact.LastName, Contact.Gender__c, Contact.MobilePhone,
                Contact.Shoe_size__c, Contact.Distributor_s_Function__c, Contact.Birthdate, Contact.Phone, Contact.Model__c
                FROM User
                WHERE id = :UserInfo.getUserId()];

        distributorFunction = new String[] {};
        if (user.Contact.Distributor_s_Function__c != null) {
            distributorFunction = User.Contact.Distributor_s_Function__c.split(';');
            System.debug(distributorFunction);
        }


        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }

        try {
            userAccount = [Select Name, Customer_Language__c, c2g__CODAAccountTradingCurrency__c, IsPersonAccount, Agent__c, Association__c, Invoices_to_be_emailed__c, BillingStreet, BillingPostalCode, BillingCountry, BillingCity, BillingState, ShippingStreet, ShippingPostalCode, ShippingCity, ShippingState, ShippingCountry, POS_Street__c, POS_City__c, POS_State__c, POS_Country__c, POS_Phone__c, UST_ID_Number__c
                           From Account
                           Where ID = :user.AccountId];
        }
        catch (Exception ex) {
            System.debug(ex);
        }
    }

    public void save() {
        System.debug(distributorFunction);
        try {
            setUserFields();
            user.Contact.Birthdate = this.birthdate;
            user.Contact.Distributor_s_Function__c = String.join(distributorFunction,';');
			user.Contact.FirstName = user.FirstName;
			user.Contact.LastName = user.LastName;

            update user;
            update user.Contact;
            /*Account securedAccount = new Account(*/
                /*Id = userAccount.Id,*/
                /*Customer_Language__c = userAccount.Customer_Language__c,*/
                /*Association__c = userAccount.Association__c,*/
                /*Invoices_to_be_emailed__c = userAccount.Invoices_to_be_emailed__c,*/
                /*ShippingStreet = userAccount.ShippingStreet,*/
                /*ShippingPostalCode = userAccount.ShippingPostalCode,*/
                /*ShippingCity = userAccount.ShippingCity,*/
                /*ShippingState = userAccount.ShippingState,*/
                /*UST_ID_Number__c = userAccount.UST_ID_Number__c*/
            /*);*/
            /*update securedAccount;*/
            /*update userAccount;*/
            ApexPages.Message savedSuccessfullyMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Saved successfully');
            ApexPages.addMessage(savedSuccessfullyMsg);

        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            System.debug(e);
        }
    }

    public PageReference cancel() {
        if (ApexPages.currentPage().getParameters().containsKey('retURL')) {
            return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        }
        else {
            return Page.PortalHomePage;
        }
    }

    public void setUserFields() {
        user.firstname = user.contact.firstname;
        user.lastname = user.contact.lastname;
        user.phone = user.contact.phone;
    }

    public SelectOption[] getDistributorFunctionPicklistValues() {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> picklistValues = Contact.Distributor_s_Function__c.getDescribe().getPicklistValues();

        for ( Schema.PicklistEntry f : picklistValues) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }

    public SelectOption[] getShoeSizes(){
        SelectOption[] options = new SelectOption[]{};
        for(Sizes__c size : [Select Id,Name From Sizes__c]){
            options.add(new SelectOption(size.Id,size.Name));
        }
        return options;
    }



}