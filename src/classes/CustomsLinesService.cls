global without sharing class CustomsLinesService {

	public static void recalculateCustomsLines(List<c2g__codaInvoice__c> invoices) {
		Set<Id> sInvoicesIds = new Map<Id,SObject>(invoices).keySet();
		System.debug(sInvoicesIds);
		removeExistingLines(sInvoicesIds);			
		
		Map<Id, List<CustomsInfo>> mapInvoicedCustoms = getInvoicedCustoms(sInvoicesIds);
		Map<Id, List<Customs_Line__c>> mapInvoice2CustomsLines = new Map<Id, List<Customs_Line__c>>();
		for(Id invoiceId: mapInvoicedCustoms.keySet()) {
			mapInvoice2CustomsLines.put(invoiceId, getCustomLines(mapInvoicedCustoms.get(invoiceId)));
		}

		List<Customs_Line__c> allCustomsLines = new List<Customs_Line__c>();
		for(List<Customs_Line__c> currentList: mapInvoice2CustomsLines.values()) {
			allCustomsLines.addAll(currentList);
		}
		insert allCustomsLines;
	}

	public static void recalculateCustomsLines(c2g__codaInvoice__c invoice) {
		recalculateCustomsLines( new List<c2g__codaInvoice__c>{invoice} );
	}

	webservice static void recalculateCustomsLines(Id invoiceId) {
		recalculateCustomsLines(new c2g__codaInvoice__c(Id=invoiceId));
	}

	private static void removeExistingLines(Set<Id> sInvoicesIds) {
		delete [SELECT Id FROM Customs_Line__c WHERE Sales_Invoice__c IN :sInvoicesIds];
	}

	private static Map<Id, List<CustomsInfo>> getInvoicedCustoms(Set<Id> sInvoicesIds) {
		List<c2g__codaInvoiceLineItem__c> lines = [SELECT Id, c2g__Invoice__c, 
					Ascent2FF__Invoiced_Line__r.PBSI__Item__r.PBSI__netweight__c, 
					Ascent2FF__Invoiced_Line__r.PBSI__Item__r.PBSI__Item_Group__r.Customs_Tariff_Number__c,
					c2g__NetValue__c, 
					c2g__Invoice__r.c2g__InvoiceCurrency__r.CurrencyIsoCode,
					c2g__Quantity__c
				FROM c2g__codaInvoiceLineItem__c WHERE c2g__Invoice__c IN :sInvoicesIds AND Is_Shipping__c = false AND Ascent2FF__Invoiced_Line__c != null];
		Map<Id, List<CustomsInfo>> invoiceId2CustomsInfos = new Map<Id, List<CustomsInfo>>();
		for(c2g__codaInvoiceLineItem__c line: lines) {
			CustomsInfo info = new CustomsInfo(line);
			if(invoiceId2CustomsInfos.containsKey(line.c2g__Invoice__c)) {
				invoiceId2CustomsInfos.get(line.c2g__Invoice__c).add(info);
			} else {
				invoiceId2CustomsInfos.put(line.c2g__Invoice__c, new List<CustomsInfo>{ info });
			}
		}
		return invoiceId2CustomsInfos;
	}

	private static List<Customs_Line__c> getCustomLines(List<CustomsInfo> customsInfos) {
		Map<String, Customs_Line__c> tariff2customInfos = new Map<String, Customs_Line__c>();
		for(CustomsInfo customInfo: customsInfos) {
			Customs_Line__c currentTariff;
			if(tariff2customInfos.containsKey(customInfo.tariff)) {
				currentTariff = tariff2customInfos.get(customInfo.tariff);
				currentTariff.Price_Sum__c += customInfo.price;
				currentTariff.Weight_Sum_grams__c += (customInfo.quantity * customInfo.weight);
				currentTariff.Quantity__c += customInfo.quantity;
			} else {
				currentTariff = new Customs_Line__c(
					Price_Sum__c = customInfo.price,
					Sales_Invoice__c = customInfo.invoiceId,
					Tariff_Number__c = customInfo.tariff,
					Weight_Sum_grams__c = customInfo.quantity * customInfo.weight,
					Quantity__c = customInfo.quantity,
					CurrencyIsoCode = customInfo.currencyCode
				);
				tariff2customInfos.put(customInfo.tariff,currentTariff);
			}

		}
		return tariff2customInfos.values();
	}

	private class CustomsInfo {
		public Id invoiceId;
		public Decimal weight;
		public Decimal price;
		public String tariff;
		public String currencyCode;
		public Decimal quantity;

		public CustomsInfo(c2g__codaInvoiceLineItem__c invoicedLine) {
			this.invoiceId = invoicedLine.c2g__Invoice__c;
			Decimal tmpWeight = invoicedLine.Ascent2FF__Invoiced_Line__r.PBSI__Item__r.PBSI__netweight__c;
			this.weight = tmpWeight != null ? tmpWeight : 0;
			this.price = invoicedLine.c2g__NetValue__c;
			this.tariff = invoicedLine.Ascent2FF__Invoiced_Line__r.PBSI__Item__r.PBSI__Item_Group__r.Customs_Tariff_Number__c;
			this.currencyCode = invoicedLine.c2g__Invoice__r.c2g__InvoiceCurrency__r.CurrencyIsoCode;
			Decimal tmpQuantity = invoicedLine.c2g__Quantity__c;
			this.quantity = tmpQuantity != null ? tmpQuantity : 0;
		}
	}
}