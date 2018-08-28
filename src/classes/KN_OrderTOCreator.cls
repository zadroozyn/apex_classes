public class KN_OrderTOCreator {

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

		private PBSI__Transfer_Order__c to;
		private List<KN_OrderLine> linesWrapped;
		private Set<Id> linesIds;

		public Order(PBSI__Transfer_Order__c to, List<PBSI__Shipped_Tranfer_Line__c> toLines) {
			this.to = to;
			this.linesIds = new Set<Id>();
			evaluateValues();
			linesWrapped = new List<Line>();
			for(PBSI__Shipped_Tranfer_Line__c toLine: toLines) {
				linesWrapped.add( new Line(toLine) );
				linesIds.add(toLine.Id);
			}
		}

		private void evaluateValues() {
			evaluateServiceLevel();
			evaluateCountryCode();
		}

		private String serviceLevel;
		private String deliveryCountryCode;
		private KN_TO_RequestManager rManager;

		private void evaluateServiceLevel() {
			serviceLevel = String.isBlank(to.Shipping_Options__c) ? '01' : to.Shipping_Options__c;
		}

		private void evaluateCountryCode() {
			if(!mapCountry2ISOCode.containsKey(to.Country__c.toLowerCase())) {
				pw_ccpro__CountryObject__c c = [SELECT pw_ccpro__IsoCode_2__c FROM pw_ccpro__CountryObject__c WHERE Name =: to.Country__c LIMIT 1];
				mapCountry2ISOCode.put(to.Country__c.toLowerCase(),  c.pw_ccpro__IsoCode_2__c);
			}
			deliveryCountryCode = mapCountry2ISOCode.get(to.Country__c.toLowerCase());
		
		}

	    public String getReceiverIdentification() {
	    	return to.PBSI__From_Location__r.KN_Logical_Address__c;
	    }

	    public virtual String getEnvelopeIdentification() {
	    	return to.TransmissionIdentification__c;
	    }
	    public String getPackingInstructions() {
	    	return '';
	    }
	    public String getDeliveryInstructions() {
	    	return to.Special_Instructions__c;
	    }
	    public String getClientNumber() {
	    	return to.PBSI__From_Location__r.KN_Client_Id__c;
	    }
	    public virtual String getClientOrderReference() {
	    	return to.TransmissionIdentification__c;
	    }
	    public String getDepot() {
	    	return to.PBSI__From_Location__r.KN_depot__c;
	    }
	    public String getConsigneeCustomerNumber() {
	    	return '0';
	    }
	    public String getConsigneeOrderNumber() {
	    	return to.Name;
	    }
	    public String getOrderType() {
	    	return 'OAT';
	    }
	    public String getServiceLevel() {
	    	return serviceLevel;
	    }
	    public String getClientContactDetails() {
	    	return '';
	    }
	    public String getShipCode() {
	    	return '';
	    }
	    public String getTieInReference() {
	    	return 'B2B';
	    }
	    public String getDeliveryCompany() {
	    	return to.PBSI__To_Location__r.Name;
	    }
	    public String getDeliveryATTN() {
	    	return '';
	    }
	    public String getStreetLine1() {
	    	return to.Address_Line_1__c;
	    }
	    public String getStreetLine2() {
	    	return to.Address_Line_2__c;
	    }
	    public String getDeliveryState() {
	    	return to.State__c;
	    }
	    public String getDeliveryCity() {
	    	return to.City__c;
	    }
	    public String getDeliveryZIPCode() {
	    	return to.Postal_Code__c;
	    }
	    public String getDeliveryCountryCode() {
	    	return deliveryCountryCode;
	    }
	    public String getDeliveryPhone() {
	    	return '';
	    }

	    public String getDeliveryPhoneAlternate() {
	    	return '';
	    }

	    public String getDeliveryEmailAddress() {
	    	return '';
	    }
	    public List<KN_OrderLine> getLines() {
	    	return linesWrapped;
	    }
	}

	public class Line implements KN_OrderLine {
		private PBSI__Shipped_Tranfer_Line__c lineSObj;

		public Line(PBSI__Shipped_Tranfer_Line__c line) {
			this.lineSObj = line;
		}
		public String getArticleID() {
	    	return lineSObj.PBSI__Item__r.Name;
	    }
    	public String getArticleDescription() {
	    	return lineSObj.PBSI__Item__r.PBSI__description__c;
	    }
    	public String getArticleEAN() {
	    	return lineSObj.PBSI__Item__r.EAN_Number__c;
	    }
    	public Decimal getQuantity() {
	    	return lineSObj.PBSI__Quantity__c;
	    }
    	public String getUOM() {
	    	return lineSObj.PBSI__Transfer_Order__r.PBSI__From_Location__r.KN_Unit_of_measurement__c;
	    }
	}

	public class OrderStage extends Order {
		private Order_stage__c orderStageObj;
		public OrderStage(Order_stage__c orderStageObj, PBSI__Transfer_Order__c to, List<PBSI__Shipped_Tranfer_Line__c> shippedLines) {
			super(to, shippedLines);
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