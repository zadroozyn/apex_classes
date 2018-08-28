public class KN_OrderSOCreator {

	private static Map<String, String> mapCountry2ISOCode {
		get {
			if(mapCountry2ISOCode == null) {
				mapCountry2ISOCode = new Map<String, String>();
			}
			return mapCountry2ISOCode;
		}
		private set;
	}

	public virtual class Order implements KN_Order {

		private PBSI__PBSI_Sales_Order__c so;
		private List<KN_OrderLine> linesWrapped;
		

		public Order(PBSI__PBSI_Sales_Order__c so, List<PBSI__Shipped_Sales_Order_Line__c> soLines) {
			this.so = so;
			evaluateValues();
			linesWrapped = new List<Line>();
			for(PBSI__Shipped_Sales_Order_Line__c soLine: soLines) {
				linesWrapped.add( new Line(soLine) );
			}
		}

		private void evaluateValues() {
			evaluateTypeByRT();
			evaluateOrderType();
			evaluateServiceLevel();
			evaluateShipCode();
			evaluateDeliveryCompany();
			evaluateCountryCode();
			evaluateDeliveryPhone();
		}

		private String orderType;
		private String serviceLevel;
		private String shipCode;
		private String tieInReference;
		private String deliveryCompany;
		private String deliveryCountryCode;
		private String deliveryPhone;
		private SORequestManager rManager;

		private void evaluateOrderType() {
			orderType = so.PBSI__From_Location__r.KN_Order_type_code__c;
			if (getTieInReference() == 'B2C'){
				orderType = so.PBSI__From_Location__r.KN_Order_Type_Code_B2C__c;
			}
			
			if(orderType == 'OAO' || orderType == 'OA1') {
				if(String.isNotBlank(so.Packing_instructions__c) || String.isNotBlank(so.Delivery_instructions__c)) {
					orderType = 'OAS';
				} else if(so.Sales_Order_Type__c == 'Warranty') {
					orderType = 'OAW';
				} else if(so.Sales_Order_Type__c == 'Pre-Order') {
					orderType = 'OAP';
				}
			}
		}

		private void evaluateServiceLevel() {
			serviceLevel = String.isBlank(so.Shipping_Options__c) ? '01' : so.Shipping_Options__c;
		}

		private void evaluateShipCode() {
			shipCode = '';
		}

		private void evaluateTypeByRT() {
			tieInReference = 'TBD';
			if(so.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('pbsi__pbsi_sales_order__c', 'web_order')) {
				tieInReference = 'B2C';
			} else if (so.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('pbsi__pbsi_sales_order__c', 'sales_order')
					|| so.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('pbsi__pbsi_sales_order__c', 'b2b_portal')) {
				tieInReference = 'B2B';
			}
		}

		private void evaluateDeliveryCompany() {
			if(String.isNotBlank(so.PBSI__Delivery_Company__c)) {
				deliveryCompany = so.PBSI__Delivery_Company__c;
			} else {
				deliveryCompany = so.Delivery_Name__c;
			}
		}

		private void evaluateCountryCode() {
			if(!KN_OrderSOCreator.mapCountry2ISOCode.containsKey(so.PBSI__Delivery_country__c.toLowerCase())) {
				pw_ccpro__CountryObject__c c = [SELECT pw_ccpro__IsoCode_2__c FROM pw_ccpro__CountryObject__c WHERE Name =: so.PBSI__Delivery_country__c LIMIT 1];
				KN_OrderSOCreator.mapCountry2ISOCode.put(so.PBSI__Delivery_country__c.toLowerCase(),  c.pw_ccpro__IsoCode_2__c);
			}
			deliveryCountryCode = KN_OrderSOCreator.mapCountry2ISOCode.get(so.PBSI__Delivery_country__c.toLowerCase());
		
		}

		private void evaluateDeliveryPhone() {
			deliveryPhone = so.Fulfiller_no_sms__c ? '' : so.PBSI__Delivery_ATTN_to_Phone__c;
		}

	    public String getReceiverIdentification() {
	    	return so.PBSI__From_Location__r.KN_Logical_Address__c;
	    }

	    public virtual String getEnvelopeIdentification() {
	    	return so.TransmissionIdentification__c;
	    }
	    public String getPackingInstructions() {
	    	return so.Packing_instructions__c;
	    }
	    public String getDeliveryInstructions() {
	    	return so.Delivery_instructions__c;
	    }
	    public String getClientNumber() {
	    	return so.PBSI__From_Location__r.KN_Client_Id__c;
	    }
	    public virtual String getClientOrderReference() {
	    	return so.TransmissionIdentification__c;
	    }
	    public String getDepot() {
	    	return so.PBSI__From_Location__r.KN_depot__c;
	    }
	    public String getConsigneeCustomerNumber() {
	    	return so.Customer_Number__c;
	    }
	    public String getConsigneeOrderNumber() {
	    	return so.Name;
	    }
	    public String getOrderType() {
	    	return orderType;
	    }
	    public String getServiceLevel() {
	    	return serviceLevel;
	    }
	    public String getClientContactDetails() {
	    	return so.PBSI__Delivery_ATTN_to_Phone__c;
	    }
	    public String getShipCode() {
	    	return shipCode;
	    }
	    public String getTieInReference() {
	    	return tieInReference;
	    }
	    public String getDeliveryCompany() {
	    	return deliveryCompany;
	    }
	    public String getDeliveryATTN() {
	    	return so.PBSI__Delivery_ATTN_to__c;
	    }
	    public String getStreetLine1() {
	    	return so.PBSI__Delivery_Streetnew__c;
	    }
	    public String getStreetLine2() {
	    	return so.PBSI__Delivery_Address_line2__c;
	    }
	    public String getDeliveryState() {
	    	return so.PBSI__Delivery_State__c;
	    }
	    public String getDeliveryCity() {
	    	return so.PBSI__Delivery_City__c;
	    }
	    public String getDeliveryZIPCode() {
	    	return so.PBSI__Delivery_Postal_Code__c;
	    }
	    public String getDeliveryCountryCode() {
	    	return deliveryCountryCode;
	    }
	    public String getDeliveryPhone() {
	    	return deliveryPhone;
	    }

	    public String getDeliveryPhoneAlternate() {
	    	return so.PBSI__Delivery_ATTN_to_Phone__c;
	    }

	    public String getDeliveryEmailAddress() {
	    	return so.PBSI__Contact_Email__c;
	    }
	    public List<KN_OrderLine> getLines() {
	    	return linesWrapped;
	    }
	}

	public class Line implements KN_OrderLine {
		private PBSI__Shipped_Sales_Order_Line__c lineSObj;

		public Line(PBSI__Shipped_Sales_Order_Line__c line) {
			this.lineSObj = line;
		}
		public String getArticleID() {
	    	return lineSObj.PBSI__Item__r.Name;
	    }
    	public String getArticleDescription() {
	    	return lineSObj.PBSI__Sales_Order_Line__r.PBSI__ItemDescription__c;
	    }
    	public String getArticleEAN() {
	    	return lineSObj.PBSI__Item__r.EAN_Number__c;
	    }
    	public Decimal getQuantity() {
	    	return lineSObj.PBSI__Quantity_Shipped__c;
	    }
    	public String getUOM() {
	    	return lineSObj.PBSI__Sales_Order__r.PBSI__From_Location__r.KN_Unit_of_measurement__c;
	    }
	}

	public class OrderStage extends Order {
		private Order_stage__c orderStageObj;
		public OrderStage(Order_stage__c orderStageObj, PBSI__PBSI_Sales_Order__c so, List<PBSI__Shipped_Sales_Order_Line__c> soLines) {
			super(so, soLines);
			this.orderStageObj = orderStageObj;
		}
		public override String getEnvelopeIdentification() {
	    	return orderStageObj.Transmission_Id__c;
	    }
	    public override String getClientOrderReference() {
	    	return orderStageObj.Transmission_Id__c;
	    }
	}
}