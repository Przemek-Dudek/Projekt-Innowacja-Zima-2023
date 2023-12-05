public with sharing class FacilityWorkingHoursUpdate implements Schedulable{
    public void execute(SchedulableContext ctx) {
        FacilityWorkingHoursUpdate.updateWorkingHours();
    }

    public static void updateWorkingHours() {
        List<Opening_Hours__c> hours = [
            SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
           Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
           Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
           Sunday_Open__c, Sunday_Close__c
            FROM Opening_Hours__c];

        for (Opening_Hours__c h : hours) {
            updateWorkweekRandomly(h);
        }

        update hours;
    }

    public static Time generateRandomTime() {
        Integer randomHour = Math.mod(Math.abs(Crypto.getRandomInteger()), 12);
        Integer randomMinute = Math.mod(Math.abs(Crypto.getRandomInteger()), 60);
    
        return Time.newInstance(randomHour, randomMinute, 0, 0);
    }

    public static Time generateRandomTimeIncrement(Time base) {
        Integer rand = (Integer)Math.floor(Math.random() * 240) + 480;

        return base.addMinutes(rand);
    }

    public class Hours {
        public Time open;
        public Time close;
    }

    public static List<Hours> generateNewWorkweek() {
        List<Hours> workweek = new List<Hours>();

        for (Integer i = 0; i < 7; i++) {
            Hours tmp = new Hours();

            tmp.open = generateRandomTime();
            tmp.close = generateRandomTimeIncrement(tmp.open);

            workweek.add(tmp);
        }

        return workweek;
    }

    public static void updateWorkweekRandomly(Opening_Hours__c hours) {
        List <Hours> workweek = generateNewWorkweek();

        hours.Monday_Open__c = workweek[0].open;
        hours.Monday_Close__c = workweek[0].close;
        hours.Tuesday_Open__c = workweek[1].open;
        hours.Tuesday_Close__c = workweek[1].close;
        hours.Wednesday_Open__c = workweek[2].open;
        hours.Wednesday_Close__c = workweek[2].close;
        hours.Thursday_Open__c = workweek[3].open;
        hours.Thursday_Close__c = workweek[3].close;
        hours.Friday_Open__c = workweek[4].open;
        hours.Friday_Close__c = workweek[4].close;
        hours.Saturday_Open__c = workweek[5].open;
        hours.Saturday_Close__c = workweek[5].close;
        hours.Sunday_Open__c = workweek[6].open;
        hours.Sunday_Close__c = workweek[6].close;
    }
}