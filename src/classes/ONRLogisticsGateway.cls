public class ONRLogisticsGateway {

	public static string WEB_CHECKOUT_STAGE_COMPLETE;

	public static String EMAIL_TEMPLATE_EU;
	public static String EMAIL_TEMPLATE_US;
	public static String EMAIL_TEMPLATE_CA;
	public static String EMAIL_TEMPLATE_JP;
	public static String EMAIL_TEMPLATE_AU;
	public static String EMAIL_TO_ID;
	public static String EMAIL_CC;
	public static String KN_EMAIL;
	public static String KN_ENDPOINT;
	public static String BASIC_AUTH_USER;
	public static String BASIC_AUTH_PASS;
	public static String RECIEVER_IDENTIFIER;
	public static String CLIENT_ID_EU;
	public static String CLIENT_ID_US;
	public static String CLIENT_ID_CA;
	public static String CLIENT_ID_JP;
	public static String CLIENT_ID_AU;
	public static String DEPOT_EU;
	public static String DEPOT_US;
	public static String DEPOT_CA;
	public static String DEPOT_JP;
	public static String DEPOT_AU;
	public static String LOGICAL_ADDRESS_EU;
	public static String LOGICAL_ADDRESS_US;
	public static String LOGICAL_ADDRESS_CA;
	public static String LOGICAL_ADDRESS_JP;
	public static String LOGICAL_ADDRESS_AU;
	public static String ORDER_TYPE_EU;
	public static String ORDER_TYPE_US;
	public static String ORDER_TYPE_CA;
	public static String ORDER_TYPE_JP;
	public static String ORDER_TYPE_AU;
	public static String ALLOWED_CHARACTERS_EXPRESSION;
	public static boolean SAVE_XML;

	// MBI ADD BEGIN to make dependend class compile (ONRMockKNPostResponse)
	public static String KN_ENDPOINT_TEST;
	// MBI ADD END

	static {
		EMAIL_TEMPLATE_EU = '';
		EMAIL_TEMPLATE_US = '';
		EMAIL_TEMPLATE_CA = '';
		EMAIL_TEMPLATE_JP = '';
		EMAIL_TEMPLATE_AU = '';
		EMAIL_TO_ID = '';
		EMAIL_CC = '';
		KN_EMAIL = '';
		KN_ENDPOINT = '';
		BASIC_AUTH_USER = '';
		BASIC_AUTH_PASS = '';
		RECIEVER_IDENTIFIER = '';
		CLIENT_ID_EU = '';
		CLIENT_ID_US = '';
		CLIENT_ID_CA = '';
		CLIENT_ID_JP = '';
		CLIENT_ID_AU = '';
		DEPOT_EU = '';
		DEPOT_US = '';
		DEPOT_CA = '';
		DEPOT_JP = '';
		DEPOT_AU = '';
		LOGICAL_ADDRESS_EU = '';
		LOGICAL_ADDRESS_US = '';
		LOGICAL_ADDRESS_CA = '';
		LOGICAL_ADDRESS_JP = '';
		LOGICAL_ADDRESS_AU = '';
		ORDER_TYPE_EU = '';
		ORDER_TYPE_US = '';
		ORDER_TYPE_CA = '';
		ORDER_TYPE_JP = '';
		ORDER_TYPE_AU = '';
		ALLOWED_CHARACTERS_EXPRESSION = '';
		SAVE_XML = false;
		WEB_CHECKOUT_STAGE_COMPLETE = 'Completion';
		KN_ENDPOINT_TEST = '';
		setValuesFromCustomSettings();
	}

	public static void setValuesFromCustomSettings() {
		KN_Integration_Settings__c settings = KN_Integration_Settings__c.getInstance('ConfigurationSettings');
		if(settings != null) {             
			ONRLogisticsGateway.BASIC_AUTH_USER = settings.Auth_User__c;
			ONRLogisticsGateway.BASIC_AUTH_PASS = settings.Auth_Password__c;
			ONRLogisticsGateway.KN_ENDPOINT = settings.Endpoint__c;
			ONRLogisticsGateway.KN_EMAIL = settings.Contact_Email__c;
			ONRLogisticsGateway.EMAIL_CC = settings.Contact_CC_Email__c;
			ONRLogisticsGateway.EMAIL_TO_ID = settings.Contact_Record__c;
			ONRLogisticsGateway.EMAIL_TEMPLATE_EU = settings.Email_Template_EU__c;
			ONRLogisticsGateway.EMAIL_TEMPLATE_US = settings.Email_Template_US__c; 
			ONRLogisticsGateway.EMAIL_TEMPLATE_CA = settings.Email_Template_CA__c;
			ONRLogisticsGateway.EMAIL_TEMPLATE_JP = settings.Email_Template_JP__c;  
			ONRLogisticsGateway.EMAIL_TEMPLATE_AU = settings.Email_Template_AU__c;  
			ONRLogisticsGateway.RECIEVER_IDENTIFIER = settings.Reciever_Identifier__c;  
			ONRLogisticsGateway.CLIENT_ID_EU = settings.Client_ID_EU__c;  
			ONRLogisticsGateway.CLIENT_ID_US = settings.Client_ID_US__c;  
			ONRLogisticsGateway.CLIENT_ID_CA = settings.Client_ID_CA__c; 
			ONRLogisticsGateway.CLIENT_ID_JP = settings.Client_ID_JP__c; 
			ONRLogisticsGateway.CLIENT_ID_AU = settings.Client_ID_AU__c; 
			ONRLogisticsGateway.DEPOT_EU = settings.Depot_EU__c;  
			ONRLogisticsGateway.DEPOT_US = settings.Depot_US__c;  
			ONRLogisticsGateway.DEPOT_CA = settings.Depot_CA__c;
			ONRLogisticsGateway.DEPOT_JP = settings.Depot_JP__c;       
			ONRLogisticsGateway.DEPOT_AU = settings.Depot_AU__c;       
			ONRLogisticsGateway.LOGICAL_ADDRESS_EU = settings.Logical_Address_EU__c;  
			ONRLogisticsGateway.LOGICAL_ADDRESS_US = settings.Logical_Address_US__c;  
			ONRLogisticsGateway.LOGICAL_ADDRESS_CA = settings.Logical_Address_CA__c;
			ONRLogisticsGateway.LOGICAL_ADDRESS_JP = settings.Logical_Address_JP__c; 
			ONRLogisticsGateway.LOGICAL_ADDRESS_AU = settings.Logical_Address_AU__c; 
			ONRLogisticsGateway.ORDER_TYPE_EU = settings.Order_Type_EU__c;  
			ONRLogisticsGateway.ORDER_TYPE_US = settings.Order_Type_US__c;  
			ONRLogisticsGateway.ORDER_TYPE_CA = settings.Order_Type_CA__c; 
			ONRLogisticsGateway.ORDER_TYPE_JP = settings.Order_Type_JP__c;  
			ONRLogisticsGateway.ORDER_TYPE_AU = settings.Order_Type_AU__c;  
			ONRLogisticsGateway.ALLOWED_CHARACTERS_EXPRESSION = settings.Allowed_characters_expression__c;
			ONRLogisticsGateway.SAVE_XML = settings.Attach_xml_to_order__c;
		}
	}
}