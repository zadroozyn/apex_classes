/**
 * Class contains methods that operates on Sales Order Line object.<br>
 * Logic that is contained in this class is using i.a. in automation of packing functionality.
 *
 * @version 5.0  2015.11.30  Ewa Latoszek <ewa.latoszek@nefoscdc.com>
 *                           Added linkSalesOrderLineToCampainActivities(List<PBSI__PBSI_Sales_Order_Line__c>) method.
 *
 * @version 4.0  2015.11.18  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Added Map<ID, PBSI__PBSI_Inventory__c> getSalesOrderLineToInventoryMap(Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>>) method and removed
 *                           Map<ID, Decimal> getLotIdToQuantityMap(Map<ID, List<PBSI__Lot__c>>), Decimal getLeftItemsCount(Decimal, List<PBSI__Lot__c>, Map<ID, Decimal>) and
 *                           Map<ID, List<PBSI__Lot__c>> getSalesOrderLineIdToLots(Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>>) methods.
 *
 * @version 3.0  2015.11.03  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Changed API in createWSShipInfoLine(PBSI__PBSI_Sales_Order_Line__c, PBSI__Lot__c, Decimal) method from AscentSOAPI to SalesOrderAPI.
 *
 * @version 2.0  2015.02.18  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Implement logic that calculate Number of styles.
 *
 * @version 1.0  2014.08.18  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 *
 * @see SalesOrderLineTriggerHandler APEX class.
 * @see Sales Order Line (API: PBSI__PBSI_Sales_Order_Line__c) sObject.
 */

public without sharing class SalesOrderLineMethods {

    /**
     * It is used to calculate Number of styles.<br/>
     * All Sales Order Lines that are have Needed Quantity less than
     * number stored in this attribute, won't be included to this calculations.
     */
    public static final Integer QUANTITY_LIMIT_NOT_CALCULATED = 4;


    // ---------------------------------------------------------- METHODS THAT ARE INVOKED FROM TRIGGER HANDLER ----------------------------------------------------------------------

    /**
     * Method used to handle changes of number of styles field.<br/>
     * It is invoked on delete and insert event.
     *
     * @param lSalesOrderLines List of Sales Order Lines.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    public static void handleNumberOfStylesChange(List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines) {

        Set<ID> sSalesOrderIDs = SalesOrderLineMethods.getSalesOrderIDsWhichNumberOfStylesHasBeenChanged(lSalesOrderLines);

        if (!sSalesOrderIDs.isEmpty()) {
            SalesOrderMethods.updateNumberOfStyles(sSalesOrderIDs);
        }
    }

    /**
     * Method used to handle changes of number of styles field.<br/>
     * It is invoked on update event.
     *
     * @param lSalesOrderLines    List of Sales Order Lines.
     * @param mOldSalesOrderLines Map of Sales Order Lines.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    public static void handleNumberOfStylesChange(List<PBSI__PBSI_Sales_Order_Line__c> lNewSalesOrderLines, Map<ID, PBSI__PBSI_Sales_Order_Line__c> mOldSalesOrderLines) {
        Set<ID> sSalesOrderIDs = SalesOrderLineMethods.getSalesOrderIDsWhichNumberOfStylesHasBeenChanged(lNewSalesOrderLines, mOldSalesOrderLines);

        if (!sSalesOrderIDs.isEmpty()) {
            SalesOrderMethods.updateNumberOfStyles(sSalesOrderIDs);
        }
    }

    /**
     * Method used to get Set of Sales Order IDs that need to change updated value in Number_of_styles__c field.<br/>
     * It is invoked on delete and insert event.
     *
     * @param lSalesOrderLines List of Sales Order Lines.
     * @return Set of Sales Order ID that need to be updated.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    private static Set<ID> getSalesOrderIDsWhichNumberOfStylesHasBeenChanged(List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines) {
        Set<ID> sSalesOrderIDsAll = new Set<ID>();
        Set<ID> sSalesOrderIDs = new Set<ID>();
        ID webOrderRecordTypeID = SalesOrderMethods.getRecordTypeID(SalesOrderMethods.WEB_ORDER_RECORD_TYPE_NAME);

        for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : lSalesOrderLines) {
            sSalesOrderIDsAll.add(salesOrderLine.PBSI__Sales_Order__c);
        }

        Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrders = new Map<ID, PBSI__PBSI_Sales_Order__c>([SELECT ID, RecordTypeID FROM PBSI__PBSI_Sales_Order__c WHERE ID IN :sSalesOrderIDsAll]);

        for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : lSalesOrderLines) {
            if (mSalesOrders.get(salesOrderLine.PBSI__Sales_Order__c).RecordTypeID != webOrderRecordTypeID) {
                sSalesOrderIDs.add(salesOrderLine.PBSI__Sales_Order__c);
            }
        }

        return sSalesOrderIDs;
    }

    /**
     * Method used to get Set of Sales Order IDs that need to change updated value in Number_of_styles__c field.<br/>
     * It is invoked on update event. All changes on Sales Order Lines that have impact on Number of Styles
     * calculations are considered in the logic.
     *
     * @param lSalesOrderLines    List of Sales Order Lines.
     * @param mOldSalesOrderLines Map of Sales Order Lines.
     * @return Set of Sales Order ID that need to be updated.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    private static Set<ID> getSalesOrderIDsWhichNumberOfStylesHasBeenChanged(List<PBSI__PBSI_Sales_Order_Line__c> lNewSalesOrderLines, Map<ID, PBSI__PBSI_Sales_Order_Line__c> mOldSalesOrderLines) {
        Set<ID> sSalesOrderIDs = new Set<ID>();
        PBSI__PBSI_Sales_Order_Line__c oldSalesOrderLine;

        for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : lNewSalesOrderLines) {

            oldSalesOrderLine = mOldSalesOrderLines.get(salesOrderLine.ID);

            /*if (
                    (
                        salesOrderLine.PBSI__Quantity_Needed__c > SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED &&
                        oldSalesOrderLine.PBSI__Quantity_Needed__c <= SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED
                    ) ||
                    (
                        salesOrderLine.PBSI__Quantity_Needed__c <= SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED &&
                        oldSalesOrderLine.PBSI__Quantity_Needed__c > SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED
                    ) ||
                    salesOrderLine.PBSI__Item__c != oldSalesOrderLine.PBSI__Item__c
                ) {
            */
            if (salesOrderLine.PBSI__Quantity_Needed__c != oldSalesOrderLine.PBSI__Quantity_Needed__c || salesOrderLine.PBSI__Item__c != oldSalesOrderLine.PBSI__Item__c) {
                sSalesOrderIDs.add(salesOrderLine.PBSI__Sales_Order__c);
            }
        }

        return sSalesOrderIDs;
    }

    // ---------------------------------------------------------- METHODS THAT GETS SOME DATA BASED ON SALES ORDER LINE DATA ---------------------------------------------------------

    /**
     * Method used to get map of Lot Ids to its Quantity.
     * It is using in SalesOrgerTriggerMethods.packWebOrders(Map<ID, PBSI__PBSI_Sales_Order__c>, List<PBSI__PBSI_Sales_Order__c>) method.
     *
     * @param mSalesOrderLineIdToLots map Sales Order Lines Id to list of Lot records.
     * @return Map of Lot Ids to its Quantity.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    /*public static Map<ID, Decimal> getLotIdToQuantityMap(Map<ID, List<PBSI__Lot__c>> mSalesOrderLineIdToLots) {
        Map<ID, Decimal> mLotIdToQuantity = new Map<ID, Decimal>();

        for (ID salesOrderID : mSalesOrderLineIdToLots.keySet()) {
            for (PBSI__Lot__c lot : mSalesOrderLineIdToLots.get(salesOrderID)) {
                if (!mLotIdToQuantity.containsKey(lot.ID)) {
                    mLotIdToQuantity.put(lot.ID, lot.PBSI__Total_Quantity__c);
                }
            }
        }

        return mLotIdToQuantity;
    }*/

    /**
     * Method used to get map of Sales Order Line Ids to its Quantity on stock.
     * It is using in SalesOrgerTriggerMethods.packWebOrders(Map<ID, PBSI__PBSI_Sales_Order__c>, List<PBSI__PBSI_Sales_Order__c>) method.
     *
     * @param mSalesOrderToSalesOrderLines map Sales Order to its lines.
     * @return Map of Sales Order Line Ids to its Quantity on stock.
     * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
     */
    public static Map<ID, PBSI__PBSI_Inventory__c> getSalesOrderLineToInventoryMap(Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>> mSalesOrderToSalesOrderLines) {
       Map<ID, PBSI__PBSI_Inventory__c> mSalesOrderLineToInventory = new Map<ID, PBSI__PBSI_Inventory__c>();
       Set<ID> sItemIDs = new Set<ID>();
       Set<ID> sLocationIDs = new Set<ID>();
       Map<ID, Map<ID, Set<ID>>> mLocationIDToItemIDToSalesOrderLines = new Map<ID, Map<ID, Set<ID>>>();

       for (PBSI__PBSI_Sales_Order__c salesOrder : mSalesOrderToSalesOrderLines.keySet()) {
          sLocationIDs.add(salesOrder.PBSI__From_Location__c);

          if (!mLocationIDToItemIDToSalesOrderLines.containsKey(salesOrder.PBSI__From_Location__c)) {
              mLocationIDToItemIDToSalesOrderLines.put(salesOrder.PBSI__From_Location__c, new Map<ID, Set<ID>>());
          }

          for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : mSalesOrderToSalesOrderLines.get(salesOrder)) {
             sItemIDs.add(salesOrderLine.PBSI__Item__c);

             if (!mLocationIDToItemIDToSalesOrderLines.get(salesOrder.PBSI__From_Location__c).containsKey(salesOrderLine.PBSI__Item__c)) {
                mLocationIDToItemIDToSalesOrderLines.get(salesOrder.PBSI__From_Location__c).put(salesOrderLine.PBSI__Item__c, new Set<ID>());
             }

             mLocationIDToItemIDToSalesOrderLines.get(salesOrder.PBSI__From_Location__c).get(salesOrderLine.PBSI__Item__c).add(salesOrderLine.ID);
          }
       }

       for (PBSI__PBSI_Inventory__c inventory : [SELECT ID, PBSI__item_lookup__c, PBSI__location_lookup__c, PBSI__qty__c, PBSI__Lot__c, PBSI__Lot__r.Name
 																								 FROM 	PBSI__PBSI_Inventory__c
 																								 WHERE 	PBSI__item_lookup__c IN :sItemIDs AND
 																												PBSI__location_lookup__c IN :sLocationIDs]) {
           if (!mLocationIDToItemIDToSalesOrderLines.containsKey(inventory.PBSI__location_lookup__c) ||
                !mLocationIDToItemIDToSalesOrderLines.get(inventory.PBSI__location_lookup__c).containsKey(inventory.PBSI__item_lookup__c)) {
              continue;
           }

           for (ID salesOrderLineID : mLocationIDToItemIDToSalesOrderLines.get(inventory.PBSI__location_lookup__c).get(inventory.PBSI__item_lookup__c)) {
              mSalesOrderLineToInventory.put(salesOrderLineID, inventory);
           }
       }

       return mSalesOrderLineToInventory;
    }

    /**
     * Method used to get left quantity.
     *
     * @param quantityNeeded needed quantity of Sales Order Line.
     * @param lLots          Lot records which related to Sales Order Line.
     * @raturn Left quantity value.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    /*public static Decimal getLeftItemsCount(Decimal quantityNeeded, List<PBSI__Lot__c> lLots, Map<ID, Decimal> mLotIdToQuantity) {
        Decimal totalQuantity = 0;

        for (PBSI__Lot__c lot : lLots) {
            totalQuantity += mLotIdToQuantity.get(lot.ID);
        }

        return quantityNeeded - totalQuantity < 0 ? 0 : quantityNeeded - totalQuantity;
    }*/

    /**
     * Method used to retrieve style number from shoes number.</br>
     * Shoes number is built as follows: "Style_Number Sex Size"
     * (for example "4.4330 M 8.5" is number of item that has style number "4.4330").</br>
     * Method cuts item number from start to space character.
     *
     * @param salesOrderLine reference to the Sales Order Line record.
     * @return Style number.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    public static String getStyleNumber(PBSI__PBSI_Sales_Order_Line__c salesOrderLine) {
        String styleNumber = '';

        if (!String.isBlank(salesOrderLine.PBSI__Item__r.Name)) {
            styleNumber = salesOrderLine.PBSI__Item__r.Name.split(' ').get(0);
        }

        return styleNumber;
    }

    // ---------------------------------------------------------- METHODS THAT SETS SOME DATA OF SALES ORDER LINE --------------------------------------------------------------------

    // ---------------------------------------------------------- METHODS THAT OPERATES ON DATABASE ----------------------------------------------------------------------------------

    // ---------------------------------------------------------- METHODS THAT RETRIEVES RECORDS FROM DATABASE -----------------------------------------------------------------------

    /**
     * Method used to get map of web Sales Order to related Sales Order Line records.
     * It is using in SalesOrgerTriggerMethods.packWebOrders(Map<ID, PBSI__PBSI_Sales_Order__c>, List<PBSI__PBSI_Sales_Order__c>) method.
     *
     * @param lSalesOrders list of new Sales Orders.
     * @param mSalesOrders map of new Sales Orders.
     * @raturn Map of web Sales Order to related Sales Order Line records.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    public static Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>> getWebSalesOrderToSalesOrderLines(List<PBSI__PBSI_Sales_Order__c> lSalesOrders, Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrders) {
        Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>> mSalesOrderToSalesOrderLines = new Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>>();
        Map<ID, PBSI__PBSI_Sales_Order__c> mWebSalesOrdersToPack = new Map<ID, PBSI__PBSI_Sales_Order__c>();

        for (PBSI__PBSI_Sales_Order__c salesOrder : lSalesOrders) {
            if (salesOrder.Web_Order_Stage_Reached__c != null &&
                salesOrder.Web_Order_Stage_Reached__c.equals(SalesOrderMethods.WEB_ORDER_COMPLETE_STATUS_VALUE) &&
                (
                    mSalesOrders.get(salesOrder.ID).Web_Order_Stage_Reached__c == null ||
                    !mSalesOrders.get(salesOrder.ID).Web_Order_Stage_Reached__c.equals(SalesOrderMethods.WEB_ORDER_COMPLETE_STATUS_VALUE)
                )) {

                mWebSalesOrdersToPack.put(salesOrder.ID, salesOrder);
                mSalesOrderToSalesOrderLines.put(salesOrder, new List<PBSI__PBSI_Sales_Order_Line__c>());
            }
        }

        for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : [  SELECT ID, Name, PBSI__Item__c, PBSI__Item__r.Name, PBSI__Sales_Order__c,
                                                                       PBSI__Sales_Order__r.ID, PBSI__Sales_Order__r.PBSI__From_Location__c,
                                                                       PBSI__Sales_Order__r.PBSI__From_Location__r.Name, PBSI__Quantity_Needed__c
                                                                FROM   PBSI__PBSI_Sales_Order_Line__c
                                                                WHERE  PBSI__Sales_Order__r.ID IN :mWebSalesOrdersToPack.keySet()]) {

            mSalesOrderToSalesOrderLines.get(mWebSalesOrdersToPack.get(salesOrderLine.PBSI__Sales_Order__c)).add(salesOrderLine);
        }

        return mSalesOrderToSalesOrderLines;
    }

    /**
     * Method used to get map of Sales Order Line record IDs to related Lot records.
     * It is using in SalesOrgerTriggerMethods.packWebOrders(Map<ID, PBSI__PBSI_Sales_Order__c>, List<PBSI__PBSI_Sales_Order__c>) method.
     *
     * @param mSalesOrderToSalesOrderLines map of Sales Order to related Sales Order Line records.
     * @raturn Map of Sales Order Line record IDs to related Lot records.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    /*public static Map<ID, List<PBSI__Lot__c>> getSalesOrderLineIdToLots(Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>> mSalesOrderToSalesOrderLines) {
        Map<ID, List<PBSI__Lot__c>> mSalesOrderLineIdToLots = new Map<ID, List<PBSI__Lot__c>>();
        Map<ID, List<PBSI__PBSI_Sales_Order__c>> mLocatationIdToSalesOrders = new Map<ID, List<PBSI__PBSI_Sales_Order__c>>();
        Set<ID> sItemIDs = new Set<ID>();

        for (PBSI__PBSI_Sales_Order__c salesOrder : mSalesOrderToSalesOrderLines.keySet()) {
            if (!mLocatationIdToSalesOrders.containsKey(salesOrder.PBSI__From_Location__c)) {
                mLocatationIdToSalesOrders.put(salesOrder.PBSI__From_Location__c, new List<PBSI__PBSI_Sales_Order__c>());
            }

            mLocatationIdToSalesOrders.get(salesOrder.PBSI__From_Location__c).add(salesOrder);

            for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : mSalesOrderToSalesOrderLines.get(salesOrder)) {
                sItemIDs.add(salesOrderLine.PBSI__Item__c);
                mSalesOrderLineIdToLots.put(salesOrderLine.ID, new List<PBSI__Lot__c>());
            }
        }

        for (PBSI__Lot__c lot : [SELECT   ID, Name, PBSI__Total_Quantity__c, PBSI__Item__c, PBSI__Item__r.ID, PBSI__Item__r.Name, PBSI__Location__c, PBSI__Location__r.ID
                                 FROM     PBSI__Lot__c
                                 WHERE    PBSI__Item__c IN :sItemIDs AND
                                          PBSI__Location__c IN :mLocatationIdToSalesOrders.keySet()
                                 ORDER BY PBSI__Expiration_Date__c]) {

            for (PBSI__PBSI_Sales_Order__c salesOrder : mLocatationIdToSalesOrders.get(lot.PBSI__Location__c)) {
                for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : mSalesOrderToSalesOrderLines.get(salesOrder)) {
                    if (salesOrderLine.PBSI__Item__c == lot.PBSI__Item__c) {
                        mSalesOrderLineIdToLots.get(salesOrderLine.ID).add(lot);
                    }
                }
            }
        }

        return mSalesOrderLineIdToLots;
    }*/

    /**
     * Method used to query Sales Order Lines that are related to Sales Order with given ID.
     *
     * @param fieldsApiNames Set of fields' API Names that need to be selected.
     * @param salesOrderID   ID of Sales Order.
     * @return Sales Order Lines that are related to Sales Order with given ID.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    public static List<PBSI__PBSI_Sales_Order_Line__c> getSalesOrderLines(Set<String> fieldsApiNames, ID salesOrderID) {
        List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines;

        fieldsApiNames.add('ID');

        try {
            lSalesOrderLines = Database.query('SELECT ' + String.join(new List<String>(fieldsApiNames),', ') + ' FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c = :salesOrderID');
        } catch(System.QueryException ex) {
            lSalesOrderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
        }

        return lSalesOrderLines;
    }

    /**
     * Method queries Sales Order Lines that are related to Sales Orders which IDs are in sSalesOrderIDs set.<br/>
     * Then it creates map of Sales Order IDs to list of their Sales Order Lines.
     *
     * @param fieldsApiNames Set of fields' API Names that need to be selected.
     * @param sSalesOrderIDs Set of ID of Sales Order.
     * @return Map of Sales Order IDs to list of their Sales Order Lines.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    public static Map<ID, List<PBSI__PBSI_Sales_Order_Line__c>> getMapSalesOrderIdToSalesOrderLines(Set<String> fieldsApiNames, Set<ID> sSalesOrderIDs) {
        Map<ID, List<PBSI__PBSI_Sales_Order_Line__c>> mSalesOrderIdToSalesOrderLines = new Map<ID, List<PBSI__PBSI_Sales_Order_Line__c>>();

        fieldsApiNames.add('ID');
        fieldsApiNames.add('PBSI__Sales_Order__c');

        try {

            for (PBSI__PBSI_Sales_Order_Line__c record : (List<PBSI__PBSI_Sales_Order_Line__c>) Database.query('SELECT ' + String.join(new List<String>(fieldsApiNames),', ') + ' FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c IN :sSalesOrderIDs')) {
                if (!mSalesOrderIdToSalesOrderLines.containsKey(record.PBSI__Sales_Order__c)) {
                    mSalesOrderIdToSalesOrderLines.put(record.PBSI__Sales_Order__c, new List<PBSI__PBSI_Sales_Order_Line__c>());
                }

                mSalesOrderIdToSalesOrderLines.get(record.PBSI__Sales_Order__c).add(record);
            }

        } catch(System.QueryException ex) {
            System.debug(LoggingLevel.ERROR, '\n********************** QUERY EXCEPTION **********************\n********************** fieldsApiNames: ' + fieldsApiNames + ', sSalesOrderIDs: ' + sSalesOrderIDs);
        }

        return mSalesOrderIdToSalesOrderLines;
    }

    // ---------------------------------------------------------- METHODS THAT BUILDS WRAPPERS ---------------------------------------------------------------------------------------
    /**
     * Method used to create PBSI.AscentSOAPI.WSShipInfoLine record.
     *
     * @param salesOrderLine Sales Order Line record to pack.
     * @param lot            Lot record which will be used to create PBSI.AscentSOAPI.WSShipInfoLine record.
     * @param quantityToShip Quantity of Sales Order Line to process.
     * @raturn Created PBSI.AscentSOAPI.WSShipInfoLine record.
     * @author Ewa Byra <ewa.byra@nefoscdc.com>.
     */
    //public static PBSI.AscentSOAPI.WSShipInfoLine createWSShipInfoLine(PBSI__PBSI_Sales_Order_Line__c salesOrderLine, PBSI__Lot__c lot, Decimal quantityToShip) {
    public static PBSI.SalesOrderAPI.WSShipInfoLine createWSShipInfoLine(PBSI__PBSI_Sales_Order_Line__c salesOrderLine, String lotName, Decimal quantityToShip) {
        //PBSI.AscentSOAPI.WSShipInfoLine shipLine = new PBSI.AscentSOAPI.WSShipInfoLine();
        PBSI.SalesOrderAPI.WSShipInfoLine shipLine = new PBSI.SalesOrderAPI.WSShipInfoLine();

        shipLine.salesLineID = salesOrderLine.ID;
        shipLine.qtyToShip = quantityToShip;
        shipLine.fromLotName = lotName;
        shipLine.fromLocationName = salesOrderLine.PBSI__Sales_Order__r.PBSI__From_Location__r.Name;

        return shipLine;
    }

    /**
     * Method used to lik Sales Order Line to Campain Activity. This method is triggered on After Insert event of Sales Order Link records.
     * It uses Map<ID, List<wbsendit__Campaign_Activity__c>> getRelatedCampaignActivites(Set<ID>) method to retrieve related Campaign Activities.
     *
     * @param lSalesOrderLines Link of newly created Sales Order Lines.
     * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
     */
    public static void linkSalesOrderLineToCampainActivities(List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines) {
        List<Sales_Order_to_Campain_Activity__c> lSalesOrderToCampainActivities = new List<Sales_Order_to_Campain_Activity__c>();
        Set<ID> sAccountIDs = new Set<ID>();

        for (PBSI__PBSI_Sales_Order_Line__c line : lSalesOrderLines) {
            sAccountIDs.add(line.PBSI__SOAccount__c);
        }

        Map<ID, List<wbsendit__Campaign_Activity__c>> mAccountIDToCampaignActivities = AccountMethods.getRelatedCampaignActivites(sAccountIDs);

        for (PBSI__PBSI_Sales_Order_Line__c line : lSalesOrderLines) {
            for (wbsendit__Campaign_Activity__c campaign_activity : mAccountIDToCampaignActivities.get(line.PBSI__SOAccount__c)) {
                if (campaign_activity.wbsendit__Activity_Date__c < line.CreatedDate) {
                    lSalesOrderToCampainActivities.add(new Sales_Order_to_Campain_Activity__c(Email_Tracking_Statistics__c = campaign_activity.ID, Sales_Order__c = line.PBSI__Sales_Order__c, Sales_Order_Line__c = line.ID));
                }
            }
        }

        insert lSalesOrderToCampainActivities;
    }
}