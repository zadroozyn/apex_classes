public class OSCA_OutboundFields {

	public static Boolean oscaFieldChanged(List<String> fields, SObject sObjA, SObject sObjB) {
		Boolean result = false;
		for(String fName: fields) {
			if(sObjA.get(fName) != sObjB.get(fName)) {
				result = true;
				break;
			}
		}
		return result;
	}

	public static final List<String> ACCOUNT_SOQL = new List<String>{
		'Name',
		'RecordType.Name',
		'BillingAddress',
		'Billing_Address_LOCODE__c',
		'Shipping_Address_LOCODE__c',
		'ShippingAddress',
		'Phone',
		'Fax',
		'CurrencyIsoCode',
		'PBSI__Standard_Discount__c',
		'PBSI__Taxes__c',
		'On_Payment_Term__r.Name',
		'On_Sales_Tax__c',
		'VAT_Categories__c',
		'Payment_Terms__c',
		'Billing_Name__c',
		'Shipping_Name__c',
		'CHF_Bank_Details__c',
		'Bank_Details__c',
		'Parent.Name',
		'Parent.RecordType.Name',
		'Parent.BillingAddress',
		'Parent.Billing_Address_LOCODE__c',
		'Parent.Shipping_Address_LOCODE__c',
		'Parent.ShippingAddress',
		'Parent.Phone',
		'Parent.Fax',
		'Parent.CurrencyIsoCode',
		'Parent.PBSI__Standard_Discount__c',
		'Parent.PBSI__Taxes__c',
		'Parent.On_Payment_Term__r.Name',
		'Parent.On_Sales_Tax__c',
		'Parent.VAT_Categories__c',
		'Parent.Payment_Terms__c',
		'Parent.Billing_Name__c',
		'Parent.Shipping_Name__c',
		'Parent.CHF_Bank_Details__c',
		'Parent.Bank_Details__c',
		'Osca_integration__c'
	};

	public static final List<String> ACCOUNT_TRIGGERS = new List<String>{
		'Name',
		'BillingCity',
		'BillingCountry',
		'BillingPostalCode',
		'BillingState',
		'BillingStreet',
		'BillingLatitude',
		'BillingLongitude',
		'Billing_Address_LOCODE__c',
		'Shipping_Address_LOCODE__c',
		'ShippingCity',
		'ShippingCountry',
		'ShippingPostalCode',
		'ShippingState',
		'ShippingStreet',
		'ShippingLatitude',
		'ShippingLongitude',
		'Phone',
		'Fax',
		'PBSI__Standard_Discount__c',
		'PBSI__Taxes__c',
		'On_Sales_Tax__c',
		'VAT_Categories__c',
		'Payment_Terms__c',
		'Billing_Name__c',
		'Shipping_Name__c',
		'CHF_Bank_Details__c',
		'Bank_Details__c'
	};

	public static final List<String> LOCATION_SOQL = new List<String>{
		'Name',
		'CurrencyIsoCode',
		'PBSI__Address_Line_1__c',
		'PBSI__Address_Line_2__c',
		'PBSI__City__c',
		'PBSI__Country__c',
		'City_LOCODE__c',
		'PBSI__Postal_Code__c',
		'PBSI__State__c',
		'PBSI__In_Transit__c',
		'(select Id, Party_type__c,Name, City__c, Contact_email__c, Contact_name__c, Contact_phone__c, Country__c, Importer_number__c, On_behalf_of__c, '
			+'Postal_Code__c, Street__c, City_LOCODE__c from PO_Notify_Parties__r)',
		'Osca_integration__c'
	};

	public static final List<String> LOCATION_TRIGGERS = new List<String>{
		'Name',
		'PBSI__Address_Line_1__c',
		'PBSI__Address_Line_2__c',
		'PBSI__City__c',
		'PBSI__Country__c',
		'City_LOCODE__c',
		'PBSI__Postal_Code__c',
		'PBSI__State__c',
		'PBSI__In_Transit__c'
	};

	public static final List<String> NOTIFY_PARTIES_TRIGGERS = new List<String>{
		'Party_type__c',
		'Name',
		'City__c',
		'Contact_email__c',
		'Contact_name__c',
		'Contact_phone__c',
		'Country__c',
		'Importer_number__c',
		'On_behalf_of__c',
		'Postal_Code__c',
		'Street__c',
		'City_LOCODE__c'
	};

	public static final List<String> ITEM_SOQL = new List<String>{
		'Fabric_Code__r.Id',
		'Fabric_Code__r.Name',
		'Fabric_Code__r.Fabric_Description__c',
		'PBSI__Item_Group__r.Id',
		'PBSI__Item_Group__r.Name',
		'PBSI__Item_Group__r.PBSI__Item_Group_Code__c',
		'EAN_Number__c',
		'Gender__c',
		'Description_Suffix__c',
		'PBSI__netweight__c',
		'Weight__c',
		'PBSI__Last_Purchase_Price_4__c',
		'PBSI__volume__c',
		'Osca_integration__c'
	};


	public static final List<String> ITEM_TRIGGERS = new List<String>{
		'EAN_Number__c',
		'Gender__c',
		'Description_Suffix__c',
		'PBSI__netweight__c',
		'Weight__c',
		'PBSI__Last_Purchase_Price_4__c',
		'PBSI__volume__c'
	};

	public static final List<String> PO_SOQL = new List<String>{
		'Name',
		'CurrencyIsoCode',
		'PBSI__Order_Date__c',
		'PBSI__Number_Of_Lines__c',
		'PBSI__Order_Total4__c',
		'PBSI__Total_Quant_to_receive__c',
		'PBSI__Total_Net_Weight__c',
		'PBSI__Account__c',
		'Osca_integration__c'
	};

	public static final List<String> PO_TRIGGERS = new List<String>{
		'Name',
		'PBSI__Order_Date__c',
		'PBSI__Number_Of_Lines__c',
		'PBSI__Order_Total4__c',
		'PBSI__Total_Quant_to_receive__c',
		'PBSI__Total_Net_Weight__c',
		'PBSI__Account__c'
	};

	public static final List<String> PO_LINE_SOQL = new List<String>{
		'PBSI__Purchase_Order__c',
		'CurrencyIsoCode',
		'PBSI__Item__c',
		'PBSI__Location__c',
		'PBSI__Price4__c',
		'PBSI__Quantity_Left_To_Receive__c',
		'PBSI__Quantity_Ordered__c',
		'PBSI__Quantity_Received__c',
		'PBSI__Status__c',
		'Requested_in_house_date__c',
		'PBSI__Due_Date__c',
		'Osca_integration__c',
		'Osca_OrderId__c',
		'Osca_ScheduleId__c'
	};

	public static final List<String> PO_LINE_TRIGGERS = new List<String>{
		'PBSI__Purchase_Order__c',
		'PBSI__Item__c',
		'PBSI__Location__c',
		'PBSI__Price4__c',
		'PBSI__Quantity_Left_To_Receive__c',
		'PBSI__Quantity_Ordered__c',
		'PBSI__Quantity_Received__c',
		'PBSI__Status__c',
		'Requested_in_house_date__c',
		'PBSI__Due_Date__c'
	};
}