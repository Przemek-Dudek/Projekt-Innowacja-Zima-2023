public with sharing class AppointmentController {
    @AuraEnabled(cacheable=true)
    public static List<Person__c> getDoctorsBySpecialization(String specialization) {
        return [SELECT Id, First_Name__c, LastName__c, Specialization__c, Medical_Facility__r.Name
                FROM Person__c
                WHERE RecordType.Name = 'Doctor' AND Specialization__c = :specialization
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getSpecializations() {
        List<AggregateResult> tmp = [SELECT Specialization__c FROM Person__c WHERE RecordType.Name = 'Doctor' GROUP BY Specialization__c];

        List<String> specializationsList = new List<String>();

        for (AggregateResult p : tmp) {
            specializationsList.add((String)p.get('Specialization__c'));
        }

        return specializationsList;
    }
}