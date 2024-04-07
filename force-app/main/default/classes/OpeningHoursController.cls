public with sharing class OpeningHoursController {
    @AuraEnabled(cacheable=true)
    public static List<Operating_Hours__c> getHours(Id facilityId) {
        List<Operating_Hours__c> hours = [SELECT Id, Closing_Time__c, Week_Day__c, Opening_Time__c FROM Operating_Hours__c WHERE Medical_Facility__c = :facilityId];
        List<Operating_Hours__c> sortedHours = new List<Operating_Hours__c>();
        List<String> days = new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
        for (String day : days) {
            for(Operating_Hours__c hour : hours) {
                if(hour.Week_Day__c == day) {
                    sortedHours.add(hour);
                    break;
                }
            }
        }
        return sortedHours;
    }
}