public without sharing class FilterWindowDataBuilder {

	private Map<String, CollectionOption> collections;
	private final String ordertype;

	private FilterWindowDataBuilder () {
		collections = new Map<String, CollectionOption>();
	}

	public FilterWindowDataBuilder(List<Collection__c> source) {
		this();
		handleCollections(source);
	}

	public FilterWindowDataBuilder(List<Collection__c> source, String ordertype) {
		this(source);
		this.ordertype = ordertype;
		this.setupCollectionVisibility();
	}

	public FilterWindowDataBuilder(List<PBSI__PBSI_Item_Group__c> source) {
		this();
		handleItemGroups(source);
	}

	public Map<String, FilterWindowDataBuilder.CollectionOption> getCollections() {
		return this.Collections;
	}

	private void handleCollections (List<Collection__c> input) {
		for(Collection__c current : input) {
			collections.put(current.Name, new CollectionOption(current));
		}
	}

	private void handleItemGroups (List<PBSI__PBSI_Item_Group__c> items) {
		collections.put('main' , new CollectionOption('main', items));
	}

	private void setupCollectionVisibility() {
		CollectionOption primary, secondary;
		for(OM_collection_settings__c current : new MatrixCollectionService().getCollectionSettings(this.ordertype)) {
			if(current.Primary__c || current.Secondary__c) {
				for(CollectionOption currentCO : this.collections.values()) {
					if(currentCO.type == current.Collection_type__c) {
						if(current.Primary__c) {
							primary = currentCO;
						} else {
							secondary = currentCO;
						}
					}
				}
			}
		}
		if(primary != null) {
			primary.isSelectedByDefault = true;
		} else if(secondary != null) {
			secondary.isSelectedByDefault = true;
		}
	}

	public class CollectionOption {
		public String name;
		public String type;
		public Id collectionId;
		public boolean isSelectedByDefault; 
		public boolean isVisible;
		Map<String, ItemGroupOption> childItemGroups;

		private CollectionOption () {
			this.childItemGroups = new Map<String, ItemGroupOption>();
		}

		public CollectionOption (Collection__c source) {
			this();
			this.name = source.Name;
			this.type = source.Collection_type__c;
			this.collectionId = source.Id;
			this.isVisible = true;
			getChildItemGroups(source.Collection_items__r);
		}

		public CollectionOption (String name, List<PBSI__PBSI_Item_Group__c> items) {
			this();
			this.name = name;
			this.isVisible = false;
			getChildItemGroups(items);
		}

		private void getChildItemGroups(List<Collection_Item__c> input) {
			for(Collection_item__c current : input) {
				if(!childItemGroups.containsKey(current.Item_Group__r.Name)){
					childItemGroups.put(current.Item_Group__r.Name, new ItemGroupOption(current));
				}
			}
		}

		private void getChildItemGroups(List<PBSI__PBSI_Item_Group__c> input) {
			for(PBSI__PBSI_Item_Group__c current : input) {
				if(!childItemGroups.containsKey(current.Name)){
					childItemGroups.put(current.Name, new ItemGroupOption(current));
				}
			}
		}

	}

	class ItemGroupOption {
		public String name;
		public String category;
		public Id itemGroupId;
		public String pictureUrl;

		public ItemGroupOption (Collection_item__c source) {
			this.name = source.Item_Group__r.Name;
			this.category = this.getCategory(source.Item_Group__r.PBSI__Parent_Group__r.Name);
			this.pictureUrl = source.Item_Group__r.Photo_URL__c;
			this.itemGroupId = source.Item_Group__c;
		}

		public ItemGroupOption (PBSI__PBSI_Item_Group__c source) {
			this.name = source.name;
			this.category = this.getCategory(source.PBSI__Parent_Group__r.Name);
			this.pictureUrl = source.Photo_URL__c;
			this.itemGroupId = source.Id;
		}

		private String getCategory (String input) {
			if(input == 'performance running gear') {
				return 'apparel';
			} else if(input == 'shoes') {
				return 'shoes';
			} else if(input == 'accessories') {
				return 'accessories';
			}
			return '';
		}
	}
}