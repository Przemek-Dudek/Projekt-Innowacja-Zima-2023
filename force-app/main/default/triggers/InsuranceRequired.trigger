trigger InsuranceRequired on Medical_Appointment__c (before insert, before update){
    List<Medical_Appointment__c> appointmentsWithInsurance = trigger.new;
    Set<Id> medicalFacilitiesIds = new Set<Id>();
    Set<Id> patientsIds = new Set<Id>();
    for(Medical_Appointment__c appointment : appointmentsWithInsurance) {
        patientsIds.add(appointment.Patient__c);
        medicalFacilitiesIds.add(appointment.Medical_Facility__c);
    }
    Map<Id, Medical_Facility__c> facilityMap = new Map<Id, Medical_Facility__c>([SELECT Id, Insurance_required__c FROM Medical_Facility__c WHERE Id IN :medicalFacilitiesIds]);
    Map<Id, Medical_Facility__c> appointmentFacility = new Map<Id, Medical_Facility__c>();
    for(Medical_Appointment__c appointment : appointmentsWithInsurance) {
        appointmentFacility.put(appointment.Id, facilityMap.get(appointment.Medical_Facility__c));
    }
    Map<Id, Person__c> patientMap = new Map<Id, Person__c>([SELECT Id, Medical_insurance__c FROM Person__c WHERE Id IN :patientsIds]);
    
    for(Medical_Appointment__c appointment : appointmentsWithInsurance) {
        Person__c patient = patientMap.get(appointment.Patient__c);
        Medical_Facility__c facility = appointmentFacility.get(appointment.Id);
        if (patient.Medical_insurance__c == null&&
        facility.Insurance_required__c==true) {
            appointment.addError('Insurance is required for this appointment');
        }           
    }
}