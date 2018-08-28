public with sharing class CollectionBuilderExtension {
	private final Collection__c collection;
	public String code {get; set;}
	public String gender {get; set;}
	public List<SelectOption> types {get; set;}
	public List<SelectOption> genders {get; set;}
	public List<CollectionItemWrapper> items {get; set;}
	transient public Map<Id, PBSI__PBSI_Item_Group__c> mGroups {get; set;}
	transient public Map<Id, Fabric__c> mFabrics {get; set;}
	public Map<Id, Set<Id>> newItems;
	public Set<Id> itemsToDelete;

	public CollectionBuilderExtension(ApexPages.StandardController stdCtrl) {
		this.types = new List<SelectOption>{new SelectOption('0', 'Shoes'), new SelectOption('1', 'Apparel'), new SelectOption('2', 'Accessories')};
		this.genders = new List<SelectOption>{new SelectOption('0', 'Unisex'), new SelectOption('1', 'Men'), new SelectOption('2', 'Women')};
		this.collection = (Collection__c) stdCtrl.getRecord();
		this.code = '0';
		this.gender = '1';
		this.newItems = new Map<Id, Set<Id>>();
		this.itemsToDelete = new Set<Id>();
		items = new List<CollectionItemWrapper>();
		this.populate();
	}

	private void storeCurrent() {
		for(CollectionItemWrapper current : this.items) {
			if(current.checked && current.cItemId == null) {
				if(!newItems.containsKey(current.groupId)) {
					newItems.put(current.groupId, new Set<Id>());
				}
				newItems.get(current.groupId).add(current.fabricId);
			} else if(!current.checked && current.cItemId != null) {
				itemsToDelete.add(current.cItemId);
			}
		}
	}

	public void populate() {
		storeCurrent();
		List<Collection_Item__c> cItems = [select id, fabric_code__c, item_group__c from collection_item__c where collection__c =: this.collection.Id];
		Map<Id, Map<Id, Id>> collectionItemMap = new Map<Id, Map<Id, Id>>();
		for(Collection_item__c current: cItems) {
			if(!collectionItemMap.containsKey(current.Item_group__c)) {
				collectionItemMap.put(current.Item_group__c, new Map<Id, Id>());
			}
			collectionItemMap.get(current.item_group__c).put(current.fabric_code__c, current.id);
		}
		Set<Id> itemGroups = new Set<Id>();
		Set<Id> fabrics = new Set<Id>();
		List<AggregateResult> aResults = [SELECT Count(Id), PBSI__Item_Group__c, Fabric_Code__c FROM PBSI__PBSI_Item__c WHERE PBSI__Item_Group__r.PBSI__Parent_Group__r.PBSI__Item_Group_Code__c =: this.code AND Size__r.Type__c =: this.gender AND PBSI__Item_Group__c != null AND Fabric_Code__c != null AND PBSI__Item_Group__r.Dont_show_in_OM__c = false GROUP BY PBSI__Item_Group__c, fabric_code__c ORDER BY PBSI__Item_Group__c];
		items = new List<CollectionItemWrapper>();
		for(AggregateResult current : aResults) {
			CollectionItemWrapper temp;
			Id gId = (Id)current.get('PBSI__Item_Group__c');
			Id fId = (Id)current.get('Fabric_Code__c');
			Id cId = null;
			if(collectionItemMap.containsKey(gId) && collectionItemMap.get(gId).containsKey(fId)) {
				cId = collectionItemMap.get(gId).get(fId);
			}
			itemGroups.add(gId);
			fabrics.add(fId);
			temp = new CollectionItemWrapper(gId, fId, cId);
			if(itemsToDelete.contains(temp.cItemId)) {
				temp.checked = false;
				itemsToDelete.remove(temp.cItemId);
			}
			if(newItems.containsKey(temp.groupId) && newItems.get(temp.groupId).contains(temp.fabricId)) {
				temp.checked = true;
				newItems.get(temp.groupId).remove(temp.fabricId);
			}
			items.add(temp);
		}
		mGroups = new Map<id, PBSI__PBSI_Item_Group__c>([SELECT Id, Name, PBSI__Item_Group_Code__c FROM pbsi__pbsi_item_group__c  WHERE Id IN: itemGroups]);
		mFabrics = new Map<id, fabric__c>([SELECT Id, Name, Fabric_description__c FROM Fabric__c WHERE Id IN: fabrics]);
		for(CollectionItemWrapper current : items) {
			current.fabricCode = mFabrics.get(current.FabricId).Name;
			current.groupCode = mGroups.get(current.groupId).PBSI__Item_Group_Code__c;
		}
		items.sort();
	}

	public PageReference returnToCollection() {
		return new PageReference('/'+this.collection.Id);
	}

	public PageReference save() {
		storeCurrent();
		List<Collection_Item__c> toInsert = new List<Collection_Item__c>();
		List<Collection_Item__c> toDelete = new List<Collection_Item__c>();
		for(Id currentGroupId : newItems.keySet()) {
			for(Id currentFabricId : newItems.get(currentGroupId)) {
				toInsert.add(new Collection_Item__c(Collection__c = this.collection.Id, Item_group__c = currentGroupId, Fabric_code__c = currentFabricId));
			}
		}
		for(Id current : itemsToDelete) {
			toDelete.add(new Collection_Item__c(Id = current));
		}
		Database.insert(toInsert);
		Database.delete(toDelete);
		return returnToCollection();
	}

	public class CollectionItemWrapper implements Comparable{
		public boolean checked {get; set;}
		public Id groupId {get; set;}
		public Id fabricId {get; set;}
		public Id cItemId {get; set;}
		public String groupCode {get; set;}
		public String fabricCode {get; set;}

		public CollectionItemWrapper(Id gId, Id fId, Id cId) {
			this.groupId = gId;
			this.fabricId = fId;
			this.cItemId = cId;
			this.checked = !String.isBlank(this.cItemId);
		}
		
		public Integer compareTo(Object o) {
			CollectionItemWrapper ciw = (CollectionItemWrapper)o;
			if(Integer.valueOf(this.groupCode) > Integer.valueOf(ciw.groupCode)) {
				return 1;
			} else if(Integer.valueOf(this.groupCode) == Integer.valueOf(ciw.groupCode)) {
				if(this.fabricCode > ciw.fabricCode) {
					return 1;
				}
			}
			return -1;
		}
	}
}