public class SalesOrderPacker {

	private static Set<Id> ordersPacked;

	private Map<Id, PBSI__PBSI_Sales_Order__c> orders;
	private Set<Id> instanceOrdersPacked;

	static {
		ordersPacked = new Set<id>();
	}
	private SalesOrderPacker() {
		system.debug('sales order packer initialised');
		this.instanceOrdersPacked = new Set<Id>();
		this.orders = new Map<Id, PBSI__PBSI_Sales_Order__c>();
	}

	public SalesOrderPacker(PBSI__PBSI_Sales_Order__c orderToBePacked) {
		this();
		this.orders.put(orderToBePacked.Id, orderToBePacked);
	}

	public SalesOrderPacker(Map<Id, PBSI__PBSI_Sales_Order__c> ordersToBePacked) {
		this();
		this.orders = ordersToBePacked;
	}

	public SalesOrderPacker(List<PBSI__PBSI_Sales_Order__c> ordersToBePacked) {
		this();
		for(PBSI__PBSI_Sales_Order__c current : ordersToBePacked) {
			this.orders.put(current.Id, current);
		}
	}

	public void pack(boolean updateOrders) {
		system.debug('first');
		this.ship(this.prepareLines());
		system.debug('second');
		this.markOrdersPacked(updateOrders);
		system.debug('third');
		ordersPacked.addAll(instanceOrdersPacked);
	}

	public void pack() {
		this.ship(this.prepareLines());
		this.markOrdersPacked(false);
		ordersPacked.addAll(instanceOrdersPacked);
		system.debug('last');
	}

	private void markOrdersPacked(boolean doUpdate) {
		List<PBSI__PBSI_Sales_Order__c> ordersToUpdate = new List<PBSI__PBSI_Sales_Order__c>();
		for(Id current : this.instanceOrdersPacked) {
			PBSI__PBSI_Sales_Order__c temp = orders.get(current);
			temp.PBSI__Status__c = 'closed';
			temp.PBSI__Stage__c = 'packed';
			temp.Is_Automatically_Packed__c = true;
			temp.PBSI__Packing_Date__c = Date.today();
			ordersToUpdate.add(temp);
		}
		if(doUpdate) {
			update ordersToUpdate;
		}
	}

	private List<PBSI.SalesOrderAPI.WSShipInfoLine> prepareLines () {
		Map<Id, Set<PBSI__PBSI_Sales_Order_Line__c>> orderId2Lines = getLinesPerOrder();
		Map<Id, Map<Id, PBSI__PBSI_Inventory__c>> loc2item2inv = buildLoc2Item2Inv(convertListOfSetsToSet(orderId2Lines.values()));
		List<PBSI.SalesOrderAPI.WSShipInfoLine> lines2ship = new List<PBSI.SalesOrderAPI.WSShipInfoLine>();
		for(Id currentOrder : orderId2Lines.keySet()){
			boolean packCurrentOrder = true;
			if(ordersPacked.contains(currentOrder)) {
				System.debug('Can\'t pack same order in the same transaction');
				continue;
			}
			try {
				Map<Id, Map<Id, Decimal>> orderQuantities = new Map<Id, Map<Id, Decimal>>();
				List<PBSI.SalesOrderAPI.WSShipInfoLine> shipLinesForOrder = new List<PBSI.SalesOrderAPI.WSShipInfoLine>();
				for(PBSI__PBSI_Sales_Order_Line__c currentLine : orderId2Lines.get(currentOrder)){
					if(!orderQuantities.containsKey(currentLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Id)){
						orderQuantities.put(currentLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Id, new Map<Id, Decimal>());
					}
					if(!orderQuantities.get(currentLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Id).containsKey(currentLine.PBSI__Item__c)){
						orderQuantities.get(currentLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Id).put(currentLine.PBSI__Item__c, 0);
					}
					orderQuantities.get(currentLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Id).put(currentLine.PBSI__Item__c, 
							orderQuantities.get(currentLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Id)
							.get(currentLine.PBSI__Item__c) + currentLine.PBSI__Quantity_Needed__c);
					shipLinesForOrder.add(createWSShipInfoLine(currentLine, 
								loc2item2inv.get(currentLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Id)
								.get(currentLine.PBSI__Item__c).PBSI__Lot__r.Name));
				}
				for(Id currentLoc : orderQuantities.keySet()) {
					for(Id currentItm : orderQuantities.get(currentLoc).keySet()){
						if(orderQuantities.get(currentLoc).get(currentItm) > loc2item2inv.get(currentLoc).get(currentItm).PBSI__qty__c) {
							packCurrentOrder = false;
							continue;
						}
					}
					if(packCurrentOrder){
						lines2ship.addAll(shipLinesForOrder);
						instanceOrdersPacked.add(currentOrder);
					}
				}
			} catch (System.NullPointerException e) {
				system.debug('Exception: ' + e);
			}
		}
		return lines2ship;
	}

	private void ship(List<PBSI.SalesOrderAPI.WSShipInfoLine> input) {
		system.debug('Shipping: ' + input);
		if(input.size() == 0) {
			return;
		}
		PBSI.SalesOrderAPI.WSResponse response = PBSI.SalesOrderAPI.ShipSalesOrderLines(input);
		system.debug('pbsi response: ' + response);
	}

	private Map<Id, Set<PBSI__PBSI_Sales_Order_Line__c>> getLinesPerOrder() {
		Map<Id, Set<PBSI__PBSI_Sales_Order_Line__c>> output = new Map<Id, Set<PBSI__PBSI_Sales_Order_Line__c>>();
		List<PBSI__PBSI_Sales_Order_Line__c> allLines = [SELECT 
				Id, PBSI__Item__c, 
				PBSI__Quantity_Needed__c,
				PBSI__Sales_Order__r.ID, 
				PBSI__Sales_Order__r.PBSI__From_Location__r.Id,
				PBSI__Sales_Order__r.PBSI__From_Location__r.Name
			FROM PBSI__PBSI_Sales_Order_Line__c
			WHERE PBSI__Sales_Order__r.ID IN :this.orders.keySet()];
		for(PBSI__PBSI_Sales_Order_Line__c current : allLines) {
			if(!output.containsKey(current.PBSI__Sales_Order__r.Id)) {
				output.put(current.PBSI__Sales_Order__r.Id, new Set<PBSI__PBSI_Sales_Order_Line__c>());
			}
			output.get(current.PBSI__Sales_Order__r.Id).add(current);
		}
		return output;
	}

	private Set<PBSI__PBSI_Sales_Order_Line__c> convertListOfSetsToSet(List<Set<PBSI__PBSI_Sales_Order_Line__c>> input ) {
		Set<PBSI__PBSI_Sales_Order_Line__c> output = new Set<PBSI__PBSI_Sales_Order_Line__c>();
		for(Set<PBSI__PBSI_Sales_Order_Line__c> current : input) {
			output.addAll(current);
		}
		return output;
	}

	private Map<Id, Map<Id, PBSI__PBSI_Inventory__c>> buildLoc2Item2Inv(Set<PBSI__PBSI_Sales_Order_Line__c> lines) {
		Set<Id> itemIds = new Set<Id>();
		Set<Id> locationIds = new Set<Id>();
		for(PBSI__PBSI_Sales_Order_Line__c current : lines) {
			itemIds.add(current.PBSI__Item__c);
			locationIds.add(current.PBSI__Sales_Order__r.PBSI__From_Location__r.Id);
		}
		List<PBSI__PBSI_Inventory__c> inv = [SELECT 
				Id, PBSI__item_lookup__c, PBSI__location_lookup__c, 
				PBSI__qty__c, PBSI__Lot__c, PBSI__Lot__r.Name 
			FROM PBSI__PBSI_Inventory__c 
			WHERE PBSI__item_lookup__c IN :itemIds AND PBSI__location_lookup__c IN :locationIds];
		Map<Id, Map<Id, PBSI__PBSI_Inventory__c>> output = new Map<Id, Map<Id, PBSI__PBSI_Inventory__c>>();
		for(PBSI__PBSI_Inventory__c current : inv) {
			if(!output.containsKey(current.PBSI__Location_Lookup__c)){
				output.put(current.PBSI__Location_Lookup__c, new Map<Id, PBSI__PBSI_Inventory__c>());
			}
			output.get(current.PBSI__Location_Lookup__c).put(current.PBSI__Item_Lookup__c, current);
		}
		return output;
	}

    private PBSI.SalesOrderAPI.WSShipInfoLine createWSShipInfoLine(PBSI__PBSI_Sales_Order_Line__c line, String lotName) {
		PBSI.SalesOrderAPI.WSShipInfoLine output = new PBSI.SalesOrderAPI.WSShipInfoLine();
        output.salesLineID = line.ID;
        output.qtyToShip = line.PBSI__Quantity_Needed__c;
        output.fromLotName = lotName;
        output.fromLocationName = line.PBSI__Sales_Order__r.PBSI__From_Location__r.Name;
        return output;
    }
}