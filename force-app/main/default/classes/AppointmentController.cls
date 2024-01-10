public with sharing class AppointmentController {
    @AuraEnabled(cacheable=true)
    public static List<Person__c> getDoctorsByFacility(Id facilityId) {
        return [SELECT Id, First_Name__c, LastName__c, Specialization__c FROM Person__c WHERE RecordType.Name = 'Doctor' AND Medical_Facility__c = :facilityId];
    }
}