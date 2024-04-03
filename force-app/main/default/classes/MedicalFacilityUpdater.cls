public class MedicalFacilityUpdater implements Schedulable , Database.Stateful{
    public static final String JOB_NAME = 'Update medical facilities';
    public static final String CRON_EXPERSSION = '0 0 5 1/1 * ? *';

    public static void schedule() {
        MedicalFacilityUpdater updater = new MedicalFacilityUpdater();
        String cronExp = CRON_EXPERSSION;
        System.schedule(JOB_NAME, cronExp, updater);
    }


    public void execute(SchedulableContext ctx) {
        // po exterenal Id łatwiej trochę będzie zrobić upserta
    //   Map<Medical_Facility__c, List<Operating_Hours__c>> medicalFacilitesWithOpeningHours = RESTMedicalFacilityExternal.makeGetMedicalFacilities();
    //   upsert new List<Medical_Facility__c>(medicalFacilitesWithOpeningHours.keySet()) External_ID__c;
    //   List<Operating_Hours__c> operatingHoursToUpsert = new List<Operating_Hours__c>();
    //   for (Medical_Facility__c m : medicalFacilitesWithOpeningHours.keySet()) {
    //       for (Operating_Hours__c o : medicalFacilitesWithOpeningHours.get(m)) {
    //             o.Medical_Facility__c = m.Id;
    //             operatingHoursToUpsert.add(o);
    //       }
    //   }
    //   upsert operatingHoursToUpsert;
        putMedicalFacilities();
    }
    public static void putMedicalFacilities(){
        Map<Medical_Facility__c, List<Operating_Hours__c>> medicalFacilitesWithOpeningHours = RESTMedicalFacilityExternal.makeGetMedicalFacilities();
        Map<String, List<Operating_Hours__c>> operatingHoursWithFacilityExternalId = new Map<String, List<Operating_Hours__c>>();

        for (Medical_Facility__c m : medicalFacilitesWithOpeningHours.keySet()) {
            List<Operating_Hours__c> operatingHours = new List<Operating_Hours__c>();
            for (Operating_Hours__c o : medicalFacilitesWithOpeningHours.get(m)) {
                operatingHours.add(o);
            }
            operatingHoursWithFacilityExternalId.put(m.External_ID__c, operatingHours);
        }

        Database.upsert(new List<Medical_Facility__c>(medicalFacilitesWithOpeningHours.keySet()), Medical_Facility__c.External_ID__c, false);
        List<Operating_Hours__c> operatingHoursToUpsert = new List<Operating_Hours__c>();
        for(Medical_Facility__c m :medicalFacilitesWithOpeningHours.keySet()){
            for (Operating_Hours__c o : operatingHoursWithFacilityExternalId.get(m.External_ID__c)) {
                if(m.Id != null){
                    m.Id = m.Id;
                    o.Medical_Facility__c = m.Id;
                    operatingHoursToUpsert.add(o);
                }
            }
        }
        Database.upsert(operatingHoursToUpsert, false);
    }
}