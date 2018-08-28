global class ScheduleATPObjectHourly implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        ScheduleATPObject ba = new ScheduleATPObject();
        String sch ='0 0 0,2,4,6,8,10,12,14,16,18,20,22 * * ?';
        System.schedule('Schedule',sch,ba);
    }
}