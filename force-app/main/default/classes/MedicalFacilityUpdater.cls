public class MedicalFacilityUpdater implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List<Medical_Facility__c> facilities = [SELECT Id, Name
            FROM MedicalFacilities
            WHERE MedicalFacilities = NULL LIMIT 200];
        

            
        upsert Medical_Facility__c;
    }
}