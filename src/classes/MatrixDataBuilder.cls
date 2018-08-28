global without sharing class MatrixDataBuilder {
	private final List<Collection_Item__c> source;
	private final List<Item> items;
	private final Map<Id, Item> mItems;
	private final Map<Id, Object> otherObjects;
	private final Map<String, Map<String, Map<Id, Size>>> sizes;
	private final Id location;
	private final Set<Id> itemsRequired;
	private Set<String> itemCategories;

	private MatrixDataBuilder () {
		this.items = new List<Item>();
		this.mItems = new Map<Id, Item>();
		this.otherObjects = new Map<Id, Object>();
		this.sizes = new Map<String, Map<String, Map<Id, Size>>>();
		this.itemCategories = new Set<String>{'Shoes'};
	}

	public MatrixDataBuilder(List<Collection_Item__c> source) {
		this();
		this.source = source;
	}

	public MatrixDataBuilder(List<Collection_Item__c> source, Id location) {
		this(source);
		this.location = location;
	}

	public MatrixDataBuilder(List<Collection_Item__c> source, Id location, Set<Id> items) {
		this(source);
		this.location = location;
		this.itemsRequired = items;
	}

	public List<Item> getItemList() {
		return this.items;
	}
	public Map<Id, Item> getItemMap() {
		return this.mItems;
	}
	public Map<Id, Object> getOtherObjects() {
		return this.otherObjects;
	}
	public Map<String, Map<String, List<Size>>> getSizes() {
		Map<String, Map<String, List<Size>>> output = new Map<String, Map<String, List<Size>>>();
		for(String s1 : sizes.keySet()) {
			output.put(s1, new Map<String, List<Size>>());
			for(String s2 : sizes.get(s1).keySet()) {
				output.get(s1).put(s2, new List<Size>(sizes.get(s1).get(s2).values()));
				output.get(s1).get(s2).sort();
			}
		}
		return output;
	}

	public boolean populateData() {
		Set<Id> fabrics = new Set<Id>();
		Set<Id> itemGroups = new Set<Id>();
		System.debug(this.source);
		for(Collection_item__c current : this.source) {
			fabrics.add(current.Fabric_Code__c);
			itemGroups.add(current.Item_Group__c);
		}
		System.debug('item groups: ' + itemGroups);
		for(PBSI__PBSI_Item__c current : this.filterItems(Database.query(this.getItemQuery()), this.getItemToFabricIds(this.source))) {
			this.processItem(current);
		}
		return true;
	}

	public void addItemCategory(String val) {
		this.itemCategories.add(val);
	}

	private String getItemQuery() {
		String output = 'SELECT '
				+ 'Id,'
				+ 'Name,'
				+ 'Size__r.Id,'
				+ 'Size__r.Name,'
				+ 'Size__r.Type__c,'
				+ 'Size__r.European_Size__c,'
				+ 'Size__r.MM__c,'
				+ 'Size__r.UK_Size__c,'
				+ 'Size__r.US_Men__c,'
				+ 'Size__r.US_Women__c,'
				+ 'Size__r.US_Size__c,'
				+ 'Size__r.JP_Size__c,'
				+ 'Size__r.RecordTypeId,'
				+ 'Size__r.RecordType.DeveloperName,'
				+ 'PBSI__Item_Group__r.Id,'
				+ 'PBSI__Item_Group__r.PBSI__Parent_Group__r.Name,'
				+ 'PBSI__Item_Group__r.Name,'
				+ 'PBSI__Item_Group__r.PBSI__Item_Group_Code__c,'
				+ 'PBSI__Item_Group__r.RecordType.DeveloperName,'
				+ 'Fabric_Code__r.Id,'
				+ 'Fabric_Code__r.Name,'
				+ 'Fabric_Description__c,'
				+ 'PBSI__description__c,'
				+ 'PBSI__salesprice4__c,'
				+ 'PBSI__Photo_URL__c,'
				+ 'Discontinued__c,'
				+ (this.location == null ? '' : '(SELECT Id, Current_Atp__c, Availability_date__c FROM Atps__r WHERE Location__c = \'' + this.location + '\'),')
				+ 'PBSI__Quantity_on_Hand__c'
			+ ' FROM PBSI__PBSI_Item__c'
			+ ' WHERE Size__c != null'
			+ ' AND Discontinued__c != \'2\''
			+ ' AND PBSI__Item_Group__r.RecordType.DeveloperName IN : itemCategories'
			+ ' AND ((Fabric_Code__c IN : fabrics'
			+ ' AND PBSI__Item_Group__c IN : itemGroups)';
		if(this.itemsRequired != null) {
			output += ' OR Id IN : itemsRequired';
		}
		output += ')';
		System.debug(output);
		System.debug(itemCategories);
		return output;
	}

	private void processItem(PBSI__PBSI_Item__c input) {
		Item nItem = new Item(input);
		items.add(nItem);
		mItems.put(input.Id, nItem);
		if(!this.otherObjects.containsKey(input.PBSI__Item_Group__r.Id)) {
			this.otherObjects.put(input.PBSI__Item_Group__r.Id, new ItemGroup(input));
		} else {
			((ItemGroup)otherObjects.get(input.PBSI__Item_Group__r.Id)).increment(input.Size__r.Type__c);
		}
		if(!otherObjects.containsKey(input.Fabric_Code__c)) {
			otherObjects.put(input.Fabric_Code__r.Id, new Fabric(input));
		}
		if(!this.sizes.containsKey(nItem.type)) {
			this.sizes.put(nItem.type, new Map<String, Map<Id, Size>>());
		}
		if(!this.sizes.get(nItem.type).containsKey(nItem.gender)) {
			this.sizes.get(nItem.type).put(nItem.gender, new Map<Id, Size>());
		}
		if(!this.sizes.get(nItem.type).get(nItem.gender).containsKey(input.Size__r.Id)) {
			this.sizes.get(nItem.type).get(nItem.gender).put(input.Size__r.Id, new Size(input.Size__r));
		}
	}

	private List<PBSI__PBSI_Item__c> filterItems(List<PBSI__PBSI_Item__c> input, Map<Id, Set<Id>> filter) {
		List<PBSI__PBSI_Item__c> output = new List<PBSI__PBSI_Item__c>();
		for(PBSI__PBSI_Item__c current : input) {
			if((filter.containsKey(current.PBSI__Item_Group__r.Id) && filter.get(current.PBSI__Item_Group__r.Id).contains(current.Fabric_Code__c))
				|| (this.itemsRequired != null && this.itemsRequired.contains(current.Id))) {
				output.add(current);
			}
		}
		return output;
	}

	private Map<Id, Set<Id>> getItemToFabricIds (List<Collection_Item__c> cItems) {
		Map<Id, Set<Id>> output = new Map<Id, Set<Id>>();
		for(Collection_Item__c current : cItems) {
			if(!output.containsKey(current.Item_Group__c)) {
				output.put(current.Item_Group__c, new Set<Id>());
			}
			output.get(current.Item_Group__c).add(current.Fabric_Code__c);
		}
		return output;
	}

	public class Item {
		public Id itemId;
		Id sizeId;
		public Id groupId;
		public Id fabricId;
		public Set<Id> lineIds;
		public Integer quantity;
		public Integer minQuantity;
		public Integer maxQuantity;
		public String color;
		public Integer atp;
		public String availabilityDate;
		String type;
		String gender;
		String picUrl;

		public Item (PBSI__PBSI_Item__c input) {
			this.itemId = input.Id;
			this.sizeId = input.Size__r.Id;
			this.groupId = input.PBSI__Item_Group__r.Id;
			this.fabricId = input.Fabric_Code__r.Id;
			this.quantity = 0;
			this.minQuantity = 0;
			/*this.type = input.PBSI__Item_Group__r.PBSI__Parent_Group__r.Name == 'Performance running gear' ? 'Apparel' : input.PBSI__Item_Group__r.PBSI__Parent_Group__r.Name;*/
			this.type = input.PBSI__Item_Group__r.RecordType.DeveloperName;
			this.gender = input.Size__r.Type__c;
			this.picUrl = input.PBSI__Photo_URL__c;
			if(input.Atps__r != null && input.Atps__r.size() > 0 ) {
				this.atp = Integer.valueOf(input.Atps__r[0].Current_Atp__c);
				/*this.availabilityDate = String.valueOf(input.Atps__r[0].Availability_date__c);*/
				if(input.Atps__r[0].Availability_date__c != null) {
					this.availabilityDate = input.Atps__r[0].Availability_date__c.format();
					this.availabilityDate = this.availabilityDate.replace(String.valueOf(input.Atps__r[0].Availability_date__c.year()), String.valueOf(input.Atps__r[0].Availability_date__c.year()).subString(2));
				}
			}
		}
	}

	private class ItemGroup {
		Id groupId;
		String name;
		String code;
		Map<String, Integer> counts;

		public ItemGroup (PBSI__PBSI_Item__c input) {
			this.name = input.PBSI__Item_Group__r.Name;
			this.groupId = input.PBSI__Item_Group__r.Id;
			this.code = input.PBSI__Item_Group__r.PBSI__Item_Group_Code__c;
			this.counts = new Map<String, Integer>();
			this.increment(input.Size__r.Type__c);
		}

		private void increment(String gender) {
			if(this.counts.containsKey(gender)) {
				this.counts.put(gender, this.counts.get(gender) + 1);
			} else {
				this.counts.put(gender, 1);
			}
		}
	}

	private class Fabric {
		Id fabricId;
		String name;
		String code;

		public Fabric (PBSI__PBSI_Item__c input) {
			this.name = input.Fabric_description__c;
			this.fabricId = input.Fabric_Code__c;
			this.code = input.Fabric_Code__r.Name.subString(1);
		}
	}

	global class Size implements Comparable {
		Id sizeId;
		String eu;
		String jp;
		String us;
		String usm;
		String usw;
		String uk;
		String mm;
		String name;
		String type;
		String gender;
		boolean isApparel;

		public Size (Sizes__c input) {
			this.sizeId = input.Id;
			this.eu = input.European_Size__c;
			this.jp = input.JP_Size__c;
			this.us = input.Type__c == '1' ? input.US_Men__c : input.US_Women__c;
			/*this.usm = input.US_Men__c;*/
			/*this.usw = input.US_Women__c;*/
			this.uk = input.UK_Size__c;
			this.mm =  input.MM__c;
			this.name = input.Name;
			this.type = input.RecordType.DeveloperName;
			this.gender = input.Type__c;
		}

		global Integer compareTo(Object o) {
			Size s = (Size) o;
			System.debug(this.name);
			System.debug(s.name);
			if(this.type == 'Shoe_size') {
				return Integer.valueOf(Long.valueOf(this.mm) - Long.valueOf(s.mm));
			} else if (this.type == 'Apparel_size') {
				return Integer.valueOf(Apparels_sizes_order__c.getAll().get(this.name).Position__c) - Integer.valueOf(Apparels_sizes_order__c.getAll().get(s.name).Position__c);
			} else if (this.type == 'Accessory_size') {
				return Integer.valueOf(Apparels_sizes_order__c.getAll().get(this.name).Position__c) - Integer.valueOf(Apparels_sizes_order__c.getAll().get(s.name).Position__c);
			}
			return 0;
		}
	}
}