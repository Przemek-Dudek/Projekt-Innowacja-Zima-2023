trigger FirstInternistAppointmentONSITE on Medical_Appointment__c (before insert) {
    List<Id> patientPersonalIDs = new List<Id>();
    Map<Id, Medical_Appointment__c> appointmentList = new Map<Id, Medical_Appointment__c> ();
    List<Id> usedIds = new List<Id>();
    List<Id> doctorPersonalIDs = new List<Id>();

    for(Medical_Appointment__c app : Trigger.new){
        Id getInfo = Schema.getGlobalDescribe()
        .get('Medical_Appointment__c')
        .getDescribe()
        .getRecordTypeInfosByName()
        .get('Online')
        .getRecordTypeId();
        if(app.RecordTypeId == getInfo){
            appointmentList.put(app.id, app);
            patientPersonalIDs.add(app.Patient__c);
        }
    }

    List<Person__c> doctorsList = [SELECT Id FROM Person__c WHERE Specialization__c = 'Internist'];
    for(Person__c doc : doctorsList){
        doctorPersonalIDs.add(doc.Id);
    }
    
    List<Medical_Appointment__c> used = [SELECT Patient__c FROM Medical_Appointment__c WHERE Doctor__c IN :doctorPersonalIDs AND Patient__c IN :patientPersonalIDs];
    for(Medical_Appointment__c i : used){
        usedIds.add(i.Patient__c);
    }

    for (Medical_Appointment__c i : appointmentList.values()) {
        if(!usedIds.contains(i.Patient__c) && doctorPersonalIDs.contains(i.Doctor__c)){
            i.addError('First Internists Visit must be "On Site"');
        }
    }
}