global class ScheduleATPObject implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
    	Integer bs = 0;
		PBSI__Admin__c CS = PBSI__Admin__c.getOrgDefaults();
		if (CS != null && CS.ATP_Batch_Size__c != null) bs = CS.ATP_Batch_Size__c.intValue();
		if (bs < 0 || bs > 200) bs = 0;
        BatchATPObject ba = new BatchATPObject();
        if (bs != 0) Database.executeBatch(ba, bs);
        else Database.executeBatch(ba);
    }   
}