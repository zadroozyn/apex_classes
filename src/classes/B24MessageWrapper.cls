public class B24MessageWrapper {

	public interface MessageModel {
		String getBuyerGLN();
		String getSupplierGLN();
		String getSenderGLN();
		String getDeliveryPartyGLN();
	}

	public List<B24MessageModel> b24Message;

	public B24MessageWrapper() {
		b24Message = new List<B24MessageModel>();
		System.debug('New B24MessageWrapper created with '+b24Message);
	}

	public class B24MessageModel {
		public Boolean isOrder() {
			return order != null;
		}

		public Boolean isInvoice() {
			return invoice != null;
		}

		public Boolean isPricat() {
			return pricat != null;
		}

		public Boolean isDespatchAdvice() {
			return despatchAdvice != null;
		}

		public Boolean isInventoryReport() {
			return invrpt != null;
		}

		public Boolean isSalesReport() {
			return slsrpt != null;
		}

		public Boolean isEmpty() {
			return (!isOrder() && !isInvoice() && !isPricat() && !isDespatchAdvice() && !isInventoryReport() && !isSalesReport());
		}
		
		public String messageId;
		public OrderModel order;
		public InvoiceModel invoice;
		public PricatModel pricat;
		public DespatchAdviceModel despatchAdvice;
		public InventoryReportModel invrpt;
		public SalesReportModel slsrpt;
	}

	public class OrderModel implements MessageModel {
		public String text;
		public String environment;
		public String orderType;
		public String currencyCode;
		public String sender;
		public String recipient;
		public List<DocumentReferenceModel> documentReference;
		public List<PropertyModel> properties;
		public GLNModel supplier;
		public GLNModel buyer;
		public PartyModel deliveryParty;
		public List<OrderItemModel> item;

		public String getBuyerGLN() {
			return buyer.gln;
		}
		public String getSupplierGLN() {
			return supplier != null && supplier.gln != null ? supplier.gln : '';
		}
		public String getSenderGLN() {
			return sender != null ? sender : '';
		}
		public String getDeliveryPartyGLN() {
			return deliveryParty != null && deliveryParty.gln != null ? deliveryParty.gln : '';
		}

	}

	public class InvoiceModel implements MessageModel {
		public String text;
		public String environment;
		public String type;
		public Date invoiceDate;
		public String invoiceNumber;
		public String currencyCode;
		public PartyModel sender;
		public PartyModel recipient;
		public List<DocumentReferenceModel> documentReferences;
		public List<PropertyModel> properties;
		public PartyModel supplier;
		public PartyModel buyer;
		public PartyModel deliveryParty;
		public List<InvoiceItemModel> items;
		public List<AllowanceModel> allowances;
		public List<ChargeModel> charges;
		public List<TaxModel> taxes;
		public InvoiceTotalModel total;
		public PaymentDetailsModel paymentDetails;

		public String getBuyerGLN() {
			return buyer.gln;
		}
		public String getSupplierGLN() {
			return supplier.gln;
		}
		public String getSenderGLN() {
			return sender.gln;
		}
		public String getDeliveryPartyGLN() {
			return deliveryParty.gln;
		}
	}

	public class PricatModel implements MessageModel {
		public String text;
		public String environment;
		public Date validFrom;
		public Date validTo;
		public String currencyCode;
		public Date preOrderTo;
		public String composition;
		public String sender;
		public String recipient;
		public PartyModel supplier;
		public PartyModel buyer;
		public List<PricatItemModel> items;

		public String getBuyerGLN() {
			return buyer.gln;
		}
		public String getSupplierGLN() {
			return supplier.gln;
		}
		public String getSenderGLN() {
			return sender;
		}
		public String getDeliveryPartyGLN() {
			return '';
		}
	}

	public class DespatchAdviceModel implements MessageModel {
		public String text;
		public String environment;
		public String documentId;
		public Date requestedDeliveryDate;
		public Date deliveryDate;
		public Date shippingDate;
		public String shipmentNumber;
		public PartyModel sender;
		public PartyModel recipient;
		public List<DocumentReferenceModel> documentReferences;
		public PartyModel supplier;
		public PartyModel buyer;
		public PartyModel shipper;
		public PartyModel deliveryParty;
		public PartyModel ultimateCosignee;
		public PartyModel shipFrom;
		public List<PackageModel> packages;
		public List<PropertyModel> properties;

		public String getBuyerGLN() {
			return buyer.gln;
		}
		public String getSupplierGLN() {
			return supplier.gln;
		}
		public String getSenderGLN() {
			return sender.gln;
		}
		public String getDeliveryPartyGLN() {
			return deliveryParty.gln;
		}
	}

	public class InventoryReportModel implements MessageModel {
		public String environment;
		public Date documentDate;
		public Date inventoryDate;
		public String sender;
		public String recipient;
		public String buyer;
		public String supplier;
		public String msgRefNo;
		public List<InventoryLineModel> lines;
		public String getBuyerGLN() {
			return buyer;
		}
		public String getSupplierGLN() {
			return supplier;
		}
		public String getSenderGLN() {
			return sender;
		}
		public String getDeliveryPartyGLN() {
			return '';
		}
	}

	public class SalesReportModel implements MessageModel {
		public String environment;
		public Date documentDate;
		public Date periodStartDate;
		public Date periodEndDate;
		public String sender;
		public String recipient;
		public String buyer;
		public String supplier;
		public String msgRefNo;
		public List<SalesReportLineModel> lines;

		public String getBuyerGLN() {
			return buyer;
		}
		public String getSupplierGLN() {
			return supplier;
		}
		public String getSenderGLN() {
			return sender;
		}
		public String getDeliveryPartyGLN() {
			return '';
		}
	}

	public class InventoryLineModel {
		public String ean;
		public String itemName;
		public Integer quantity;
		public String location;
	}

	public class SalesReportLineModel {
		public String ean;
		public String itemId;
		public Integer salesQuantity;
		public Integer returnedQuantity;
		public String location;
		public Decimal netPrice;
		public Decimal salesPrice;
	}

	public class GLNModel {
		public String gln;
	}

	public class DocumentReferenceModel {
		public String documentType;
        public String id;
        public Date documentDate;
        public Date ddate; //Invoice
        public String lineNo;
	}

	public class PropertyModel {
		public String name;
		public String text;
		public String code;
	}

	public class PartyModel {
		public String gln;
		public String name;
		public String contact;
		public String orgNo;
		public String vatNo;
		public String reference;
		public LocationModel location;
	}

	public class LocationModel {
		public String address;
		public CityModel city;
		public CountryModel country;
		public CountryModel state;
		public String telephoneNumber;
		public String emailAddress;
		public List<PropertyModel> properties;
	}

	public class CityModel {
		public String code;
		public String text;
	}

	public class CountryModel {
		public String code;
		public String text;
	}

	public class OrderItemModel {
		public Integer quantity;
        public Date deliveryDate;
        public List<DocumentReferenceModel> documentReference;
        public List<PropertyModel> properties;
        public List<ItemReferenceModel> itemReference;
        public List<OrderPriceModel> prices;
	}

	public class DesadvItemModel {
		public String id;
		public Integer quantity;
        public Date deliveryDate;
        public List<DocumentReferenceModel> documentReferences;
        public List<PropertyModel> properties;
        public List<ItemReferenceModel> itemReference;
        public List<OrderPriceModel> prices;
	}

	public class InvoiceItemModel {
		public String id;
		public Integer quantity;
		public String unitOfMeasure;
		public Integer orderedQuantity;
        public List<DocumentReferenceModel> documentReferences;
        public List<ItemReferenceModel> itemReference;
        public InvoicePriceModel price;
	}	

	public class ItemReferenceModel {
		public String registry;
		public String coding;
		public String text;
		public String name;
	}

	public class OrderPriceModel {
		public String type;
		public Decimal value;
		public String currencyCode;
	}

	public class InvoicePriceModel {
		public String currencyCode;
		public Decimal unitGrossAmount;
		public Decimal unitNetAmount;
		public Decimal grossAmount;
		public Decimal netAmount;
		public Decimal taxRate;
		public Decimal taxAmount;
		public Decimal grossAmountIncTax;
		public Decimal netAmountIncTax;
	}

	public class AllowanceModel {
		public String name;
		public String code;
		public Decimal percent;
		public Decimal amount;
	}

	public class ChargeModel {
		public String name;
		public String code;
		public Decimal amount;
	}

	public class TaxModel {
		public String name;
		public String code;
		public Decimal rate;
		public Decimal amount;
		public Decimal taxableAmount;
	}

	public class InvoiceTotalModel {
		public Decimal grossAmount;
		public Decimal allowanceAmount;
		public Decimal chargeAmount;
		public Decimal netAmount;
		public Decimal taxableAmount;
		public Decimal nonTaxableAmount;
		public Decimal taxAmount;
		public Decimal rounding;
		public Decimal netAmountIncTax;
	}

	public class PaymentDetailsModel {
		public Date dueDate;
		public String paymentTerms;
		public Decimal penaltyInterestRate;
		public BankAccountModel account;
	}

	public class BankAccountModel {
		public String type;
		public String bankName;
		public String text;
	}

	public class PricatItemModel {
		public String action;
		public String id;
		public List<PropertyModel> properties;
		public List<DimensionModel> dimensions;
		public PartyModel manufacturer;
        public ItemReferenceModel itemReference;
        public List<GoodsClassModel> goodsClasses;
        public PriceBaseModel priceBase;
        public PresentationModel presentation;
	}

	public class DimensionModel {
		public String name;
		public String code;
		public String text;
		public String registry;
		public String dset;
	}

	public class GoodsClassModel {
		public String text;
		public String registry;
		public String dset;
	}

	public class PriceBaseModel {
		public Date validOrderDateFrom;
		public Date validOrderDateTo;
		public List<OrderPriceModel> prices;
	}

	public class PriceBracketModel {
		public Date validOrderDateFrom;
		public Date validOrderDateTo;
		public String type;
		public Integer quantity;
		public Date validShipDateFrom;
		public Date validShipDateTo;
		public List<OrderPriceModel> prices;
	}	

	public class PresentationModel {
		public String text;
		public List<ImageModel> images;
	}

	public class ImageModel {
		public String url;
		public String imageBankId;
		public String size;
		public String text;
		public Integer index;
	}

	public class PackageModel {
		public Integer quantity;
		public String packageType;
		public String hierarchyIdentity;
		public String parentHierarchyIdentity;
		public String SSCC;
		public String trackingUrl;
		public List<DesadvItemModel> items;
		public List<PropertyModel> properties;
	}

}