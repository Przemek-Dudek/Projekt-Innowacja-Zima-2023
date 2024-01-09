public with sharing class FacilityWorkingHoursUpdate implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
    public static final String CRON_EXPERSSION = '0 0 1 * * ?';

    private Set<Id> errorToIDs = new Set<Id>();
    public Boolean isUpdateSuccessful = true;

    public static Id scheduleMe(String jobname) {
        FacilityWorkingHoursUpdate schedule = new FacilityWorkingHoursUpdate();
        return System.schedule(
          jobname,
          CRON_EXPERSSION,
          schedule
        );
    }

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new FacilityWorkingHoursUpdate());
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        errorToIDs = new Set<Id>();

        return Database.getQueryLocator([SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c FROM Operating_Hours__c]);
    }

    public void execute(Database.BatchableContext context, List<Operating_Hours__c> scope) {
        for (Operating_Hours__c h : scope) {
            updateHoursRandomly(h);
        }

        try {
            update scope;
        } catch (Exception e) {
            isUpdateSuccessful = false;

            for (Operating_Hours__c h : scope) {
                errorToIDs.add(h.Id);
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        if (!isUpdateSuccessful) {
            EmailManager.sendBatchErrorEmail(errorToIDs, 'Error in FacilityWorkingHoursUpdate Batch');
        }
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

    public static void updateHoursRandomly(Operating_Hours__c h) {
        h.Opening_Time__c = generateRandomTime();
        h.Closing_Time__c = generateRandomTimeIncrement(h.Opening_Time__c);
    }
}