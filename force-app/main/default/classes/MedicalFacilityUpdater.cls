public class MedicalFacilityUpdater implements Schedulable , Database.Stateful{
    public static final String JOB_NAME = 'Update medical facilities';
    public static final String CRON_EXPERSSION = '0 0 5 1/1 * ? *';

    public static void schedule() {
        MedicalFacilityUpdater updater = new MedicalFacilityUpdater();
        String cronExp = CRON_EXPERSSION;
        System.schedule(JOB_NAME, cronExp, updater);
    }


    public void execute(SchedulableContext ctx) {
      Map<Medical_Facility__c, List<Operating_Hours__c>> medicalFacilitesWithOpeningHours = RESTMedicalFacilityExternal.makeGetMedicalFacilities();
      List<Medical_Facility__c> medicalFacilitiesToUpsert = new List<Medical_Facility__c>();
      List<String> medicalFacilityExternalIds = new List<String>();
        for (Medical_Facility__c m : medicalFacilitesWithOpeningHours.keySet()) {
            medicalFacilitiesToUpsert.add(m);
            medicalFacilityExternalIds.add(m.External_ID__c);
        }
        List<Medical_Facility__c> medicalFacilitiesToUpdateFromDatabase = new List<Medical_Facility__c>([SELECT Id,External_ID__c FROM Medical_Facility__c WHERE External_ID__c IN :medicalFacilityExternalIds]);
        List<Medical_Facility__c> medicalFacilitiesToUpdate = new List<Medical_Facility__c>();
        List<Medical_Facility__c> medicalFacilitiesToInsert = new List<Medical_Facility__c>();
        List<String> medicalFacilityToInsertExternalIds = new List<String>();
        for (Medical_Facility__c m : medicalFacilitiesToUpdateFromDatabase) {
            for (Medical_Facility__c m2 : medicalFacilitiesToUpsert) {
                if (m.External_ID__c == m2.External_ID__c) {
                    m2.Id = m.Id;
                    medicalFacilitiesToUpdate.add(m2);
                } else {
                    medicalFacilitiesToInsert.add(m2);
                    medicalFacilityToInsertExternalIds.add(m2.External_ID__c);
                }
            }
        }
        update medicalFacilitiesToUpdate;
        insert medicalFacilitiesToInsert;

        List<Medical_Facility__c> idsToInstertedMedicalFacilities = new List<Medical_Facility__c>([SELECT Id,External_ID__c FROM Medical_Facility__c WHERE External_ID__c IN :medicalFacilityToInsertExternalIds]);
        Map<String,Id> idsToInstertedMedicalFacilitiesExternalIds = new Map<String,Id>();
        for (Medical_Facility__c m : idsToInstertedMedicalFacilities) {
            idsToInstertedMedicalFacilitiesExternalIds.put(m.External_ID__c,m.Id);
        }
        
        for (Medical_Facility__c m : medicalFacilitiesToInsert) {
            m.Id = idsToInstertedMedicalFacilitiesExternalIds.get(m.External_ID__c);
        }


        List<Operating_Hours__c> operatingHoursToUpdate = new List<Operating_Hours__c>();
        List<Operating_Hours__c> operatingHoursToInsert = new List<Operating_Hours__c>();
        for (Medical_Facility__c m : medicalFacilitiesToUpdate) {
            for (Operating_Hours__c o : medicalFacilitesWithOpeningHours.get(m)) {
                o.Medical_Facility__c = m.Id;
            }
        }
        for (Medical_Facility__c m : medicalFacilitiesToInsert) {
            for (Operating_Hours__c o : medicalFacilitesWithOpeningHours.get(m)) {
                o.Medical_Facility__c = m.Id;
            }
        }
        for (Operating_Hours__c o : operatingHoursToInsert) {
            operatingHoursToInsert.add(o);
        }
        for (Operating_Hours__c o : operatingHoursToUpdate) {
            operatingHoursToUpdate.add(o);
        }
        update operatingHoursToUpdate;
        insert operatingHoursToInsert;
    }
}