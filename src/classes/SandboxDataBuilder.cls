public class SandboxDataBuilder {

	List<Account> accounts;
	List<pw_ccpro__CountryObject__c> countries;
	Map<String, PBSI__PBSI_Location__c> locations;
	Map<String, PBSI__PBSI_Item_Group__c> parentGroups;
	List<PBSI__PBSI_Item_Group__c> shoeGroups;
	List<PBSI__PBSI_Item_Group__c> apparelGroups;
	List<PBSI__PBSI_Item_Group__c> accessoryGroups;
	List<PBSI__PBSI_Item_Group__c> accessoryGroupsOneSize;
	List<Sizes__c> shoeSizes;
	List<Sizes__c> apparelSizes;
	List<Sizes__c> accessorySizes;
	Sizes__c oneSize;
	List<Fabric__c> fabrics;
	List<PBSI__PBSI_Item__c> shoes;
	List<PBSI__PBSI_Item__c> apparel;
	List<PBSI__PBSI_Item__c> accessories;
	Map<String, PBSI__Account_Group__c> accountGroups;
	Map<String, Collection__c> collections;
	List<Collection_Item__c> collectionItems;

	public SandboxDataBuilder() {
		this.accounts = new List<Account>();
		this.accountGroups = new Map<String, PBSI__Account_Group__c>();
		this.countries = new List<pw_ccpro__CountryObject__c>();
		this.shoeSizes = new List<Sizes__c>();
		this.apparelSizes = new List<Sizes__c>();
		this.accessorySizes = new List<Sizes__c>();
		this.parentGroups = new Map<String, PBSI__PBSI_Item_Group__c>();
		this.fabrics = new List<Fabric__c>();
		this.shoeGroups = new List<PBSI__PBSI_Item_Group__c>();
		this.apparelGroups = new List<PBSI__PBSI_Item_Group__c>();
		this.accessoryGroups = new List<PBSI__PBSI_Item_Group__c>();
		this.accessoryGroupsOneSize = new List<PBSI__PBSI_Item_Group__c>();
		this.shoes = new List<PBSI__PBSI_Item__c>();
		this.apparel = new List<PBSI__PBSI_Item__c>();
		this.accessories = new List<PBSI__PBSI_Item__c>();
		this.locations = new Map<String, PBSI__PBSI_Location__c>();
		this.collections = new Map<String, Collection__c>();
		this.collectionItems = new List<Collection_Item__c>();
	}

	public void createLocations() {
		this.locations.put('eu-stock', new PBSI__PBSI_Location__c(Name = 'EU-stock'));
		this.locations.put('ch-stock', new PBSI__PBSI_Location__c(Name = 'CH-stock'));
	}

	public void createAccountGroups()  {
		this.accountGroups.put('dealer', new PBSI__Account_Group__c(Name='Dealers'));
	}

	public void createAccounts() {
		this.accounts.add(new Account(Name = 'Test Germany', BillingCountry = 'Germany', ShippingCountry = 'Germany', PBSI__Account_Group__c = this.accountGroups.get('dealer').Id, Status__c = 'Active'));
		this.accounts.add(new Account(Name = 'Test Switzerland', BillingCountry = 'Switzerland', ShippingCountry = 'Switzerland', PBSI__Account_Group__c = this.accountGroups.get('dealer').Id, Status__c = 'Active'));
	}

	public void createCountries() {
		this.countries.add(new pw_ccpro__CountryObject__c(Name='Germany', pw_ccpro__IsoCode_2__c = 'DE', pw_ccpro__IsoCode_3__c = 'DEU', Dealer_Location__c = this.locations.get('eu-stock').Id, Distributor_Location__c = this.locations.get('eu-stock').Id, Webshop_Location__c = this.locations.get('eu-stock').Id));
		this.countries.add(new pw_ccpro__CountryObject__c(Name='Switzerland', pw_ccpro__IsoCode_2__c = 'CH', pw_ccpro__IsoCode_3__c = 'CHE', Dealer_Location__c = this.locations.get('ch-stock').Id, Distributor_Location__c = this.locations.get('ch-stock').Id, Webshop_Location__c = this.locations.get('ch-stock').Id));

	}

	public void createSizes() {
		this.shoeSizes.add(new Sizes__c(Name='M 7', MM__c='250', European_size__c='40', UK_Size__c='6.5', US_Size__c='7', US_men__c='7', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Shoe_size')));

		this.apparelSizes.add(new Sizes__c(Name='M XXL', JP_Size__c = 'XXXL', European_size__c='XXL', US_Size__c='XL', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='M XL', JP_Size__c = 'XXL', European_size__c='XL', US_Size__c='L', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='M L', JP_Size__c = 'XL', European_size__c='L', US_Size__c='M', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='M M', JP_Size__c = 'L', European_size__c='M', US_Size__c='S', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='M S', JP_Size__c = 'M', European_size__c='S', US_Size__c='XX', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='W XL', JP_Size__c = 'XXL', European_size__c='XL', US_Size__c='L', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='W L', JP_Size__c = 'XL', European_size__c='L', US_Size__c='M', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='W M', JP_Size__c = 'L', European_size__c='M', US_Size__c='S', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='W S', JP_Size__c = 'M', European_size__c='S', US_Size__c='XS', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));
		this.apparelSizes.add(new Sizes__c(Name='W XS', JP_Size__c = 'S', European_size__c='XS', US_Size__c='XXs', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Apparel_size')));

		oneSize = new Sizes__c(Name='One Size', European_size__c='One Size', UK_Size__c='One Size', US_Size__c='One size', US_men__c='One Size', Type__c='0', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Accessory_size'));

		this.accessorySizes.add(new Sizes__c(Name='L', European_size__c='L', UK_Size__c='L', US_Size__c='M', US_men__c='M', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Accessory_size')));
		this.accessorySizes.add(new Sizes__c(Name='M', European_size__c='M', UK_Size__c='M', US_Size__c='S', US_men__c='S', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Accessory_size')));
		this.accessorySizes.add(new Sizes__c(Name='S', European_size__c='S', UK_Size__c='S', US_Size__c='XS', US_men__c='S', Type__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Accessory_size')));

		this.accessorySizes.add(new Sizes__c(Name='L', European_size__c='L', UK_Size__c='L', US_Size__c='M', US_women__c='M', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Accessory_size')));
		this.accessorySizes.add(new Sizes__c(Name='M', European_size__c='M', UK_Size__c='M', US_Size__c='S', US_women__c='S', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Accessory_size')));
		this.accessorySizes.add(new Sizes__c(Name='S', European_size__c='S', UK_Size__c='S', US_Size__c='XS', US_women__c='S', Type__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Sizes__c', 'Accessory_size')));
	}

	public void createParentGroups() {
		this.parentGroups.put('shoe', new PBSI__PBSI_Item_Group__c(Name='Shoes', PBSI__Item_Group_Code__c='0', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'parent_group'), Group_Description__c='test'));
		this.parentGroups.put('apparel', new PBSI__PBSI_Item_Group__c(Name='Performance Running Gear', PBSI__Item_Group_Code__c='1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'parent_group'), Group_Description__c='test'));
		this.parentGroups.put('accessory', new PBSI__PBSI_Item_Group__c(Name='Accessories', PBSI__Item_Group_Code__c='2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'parent_group'), Group_Description__c='test'));
	}

	public void createFabrics() {
		this.fabrics.add(new Fabric__c(Name='0.0000', Fabric_description__c='Black / Black'));
		this.fabrics.add(new Fabric__c(Name='0.00011', Fabric_description__c='Black / Whatever'));
		this.fabrics.add(new Fabric__c(Name='0.99999', Fabric_description__c='Whatever / Black'));
	}

	public void createItemGroups() {
		this.shoeGroups.add(new PBSI__PBSI_Item_Group__c(Name='Cloud', PBSI__Item_Group_Code__c='19', PBSI__Parent_Group__c = this.parentGroups.get('shoe').Id, RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'Shoes'), Group_Description__c='test'));
		this.shoeGroups.add(new PBSI__PBSI_Item_Group__c(Name='Cloud Edge', PBSI__Item_Group_Code__c='18', PBSI__Parent_Group__c = this.parentGroups.get('shoe').Id, RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'Shoes'), Group_Description__c='test'));

		this.apparelGroups.add(new PBSI__PBSI_Item_Group__c(Name='Hybrid shorts', PBSI__Item_Group_Code__c='201', PBSI__Parent_Group__c = this.parentGroups.get('apparel').Id, RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'Apparel'), Group_Description__c='test'));
		this.apparelGroups.add(new PBSI__PBSI_Item_Group__c(Name='Perfornce Running T-shirt', PBSI__Item_Group_Code__c='202', PBSI__Parent_Group__c = this.parentGroups.get('apparel').Id, RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'Apparel'), Group_Description__c='test'));


		this.accessoryGroups.add(new PBSI__PBSI_Item_Group__c(Name='Socks', PBSI__Item_Group_Code__c='302', PBSI__Parent_Group__c = this.parentGroups.get('accessory').Id, RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'Accessories'), Group_Description__c='test'));

		this.accessoryGroupsOneSize.add(new PBSI__PBSI_Item_Group__c(Name='Lightweight Cap', PBSI__Item_Group_Code__c='301', PBSI__Parent_Group__c = this.parentGroups.get('accessory').Id, RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'Accessories'), Group_Description__c='test'));
	}

	public void createShoes() {
		for(PBSI__PBSI_Item_Group__c iGroup : this.shoeGroups) {
			for(Fabric__c fabric : this.fabrics) {
				for(Sizes__c size : this.shoeSizes) {
					this.shoes.add(new PBSI__PBSI_Item__c(Name=iGroup.pbsi__item_group_code__c + fabric.name + size.name, Size__c=size.Id, PBSI__Item_Group__c=iGroup.id, Fabric_Code__c=fabric.id,PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA',EAN_Number__c='112288'));
				}
			}
		}
	}

	public void createApparel() {
		for(PBSI__PBSI_Item_Group__c iGroup : this.apparelGroups) {
			for(Fabric__c fabric : this.fabrics) {
				for(Sizes__c size : this.apparelSizes) {
					this.apparel.add(new PBSI__PBSI_Item__c(Name=iGroup.pbsi__item_group_code__c + fabric.name + size.name, Size__c=size.Id, PBSI__Item_Group__c=iGroup.id, Fabric_Code__c=fabric.id,PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA',EAN_Number__c='112288'));
				}
			}
		}
	}

	public void createAccessories() {
		for(PBSI__PBSI_Item_Group__c iGroup : this.accessoryGroups) {
			for(Fabric__c fabric : this.fabrics) {
				for(Sizes__c size : this.accessorySizes) {
					this.accessories.add(new PBSI__PBSI_Item__c(Name=iGroup.pbsi__item_group_code__c + fabric.name + size.name, Size__c=size.Id, PBSI__Item_Group__c=iGroup.id, Fabric_Code__c=fabric.id,PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA',EAN_Number__c='112288'));
				}
			}
		}
		for(PBSI__PBSI_Item_Group__c iGroup : this.accessoryGroupsOneSize) {
			for(Fabric__c fabric : this.fabrics) {
				Sizes__c size = this.oneSize;
				this.accessories.add(new PBSI__PBSI_Item__c(Name=iGroup.pbsi__item_group_code__c + fabric.name + size.name, Size__c=size.Id, PBSI__Item_Group__c=iGroup.id, Fabric_Code__c=fabric.id,PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA',EAN_Number__c='112288'));
			}
		}
	}



	public void createCollections() {
		this.collections.put('current', new Collection__c(Collection_type__c = 'Current collection', Name = 'FW19', status__c = 'active'));
		this.collections.put('next', new Collection__c(Collection_type__c = 'Next collection', Name = 'SS10', status__c = 'active'));
	}

	public void createCollectionItems() {
		for(Collection__c collection : this.collections.values()) {
			for(PBSI__PBSI_Item__c item : this.getItems()) {
				this.collectionItems.add(new Collection_Item__c(Collection__c = collection.Id, Item_Group__c = item.PBSI__Item_Group__c, Fabric_code__c = item.Fabric_code__c));
			}
		}
	}
	public List<sObject> getAll() {
		List<sObject> output = new List<sObject>();
		output.addAll((List<sObject>)this.countries);
		output.addAll((List<sObject>)this.accounts);
		output.addAll((List<sObject>)this.shoeSizes);
		output.addAll((List<sObject>)this.apparelSizes);
		output.addAll((List<sObject>)this.accessorySizes);
		output.add((sObject)this.oneSize);
		output.addAll((List<sObject>)this.fabrics);
		output.addAll((List<sObject>)this.shoeGroups);
		output.addAll((List<sObject>)this.apparelGroups);
		output.addAll((List<sObject>)this.accessoryGroups);
		output.addAll((List<sObject>)this.accessoryGroupsOneSize);
		output.addAll((List<sObject>)this.collections.values());
		return output;
	}

	public List<PBSI__PBSI_Item__c> getItems() {
		List<PBSI__PBSI_Item__c> output = new List<sObject>();
		output.addAll(this.shoes);
		output.addAll(this.apparel);
		output.addAll(this.accessories);
		return output;

	}

	public List<sObject> getThirdStep() {
		List<sObject> output = new List<sObject>();
		output.addAll((List<sObject>)this.shoes);
		output.addAll((List<sObject>)this.apparel);
		output.addAll((List<sObject>)this.accessories);
		output.addAll((List<sObject>)this.collectionItems);
		return output;

	}

	public List<sObject> getFirstStep() {
		List<sObject> output = new List<sObject>();
		output.addAll((List<sObject>)this.locations.values());
		output.addAll((List<sObject>)this.accountGroups.values());
		output.addAll((List<sObject>)this.parentGroups.values());
		return output;
	}
	public SandboxDataBuilder one() {
		this.createLocations();
		this.createAccountGroups();
		this.createParentGroups();
		Database.insert(this.getFirstStep(), true);
		return this;
	}
	public SandboxDataBuilder two() {
		this.createCountries();
		this.createAccounts();
		this.createSizes();
		this.createItemGroups();
		this.createFabrics();
		this.createCollections();
		Database.insert(this.getAll(), true);
		return this;
	}
	public SandboxDataBuilder three() {
		this.createShoes();
		this.createApparel();
		this.createAccessories();
		this.createCollectionItems();
		Database.insert(this.getThirdStep(), true);
		return this;
	}
}