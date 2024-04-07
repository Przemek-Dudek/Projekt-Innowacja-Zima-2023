public with sharing class MedicalAppointmentHandler {
   
   
    public static void handleUpdateOrNewAppointment(List<Medical_Appointment__c> newAppointments, Map<Id, Medical_Appointment__c> oldAppointmentsMap, Boolean isInsert, Boolean isUpdate) {
      Set<String> patientPersonalIDs = new Set<String>();
  
      for (Medical_Appointment__c appointment : newAppointments) {
          patientPersonalIDs.add(appointment.Patient__c);
      }
      
      Map<String, Person__c> patientDetails = new Map<String, Person__c>();
      
      List<Person__c> listOfPatients =  [SELECT Email__c, Personal_ID_Number__c, First_Name__c, LastName__c FROM Person__c WHERE Id IN :patientPersonalIDs];
  
      for(Person__c person : listOfPatients) {
          patientDetails.put(person.Id, person);
      }
  
      List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
      
      for (Medical_Appointment__c appointment : newAppointments) {
          Person__c patient = patientDetails.get(appointment.Patient__c);
          if(isUpdate){
              Medical_Appointment__c oldPatient = oldAppointmentsMap.get(appointment.Id);
          
          if (patient != null && patient.Email__c != null && oldPatient != null) {
              if(appointment.Appointment_Date__c != oldPatient.Appointment_Date__c || 
              appointment.Status__c != oldPatient.Status__c || 
              appointment.Surgery__c != oldPatient.Surgery__c || 
              appointment.RecordTypeId != oldPatient.RecordTypeId){
                  
                Messaging.SingleEmailMessage mail = EmailMessageBuilder.createEmailMessage(appointment, patient);
                  emails.add(mail);
               }
              }
          }
          if(isInsert){
            Messaging.SingleEmailMessage mail = EmailMessageBuilder.createEmailMessage(appointment, patient);
            emails.add(mail);
          }
          
      }
      
      if(!emails.isEmpty()){
          Messaging.sendEmail(emails);
      }
  }

  public static void handleFirstInternistAppointmentONSITE(List<Medical_Appointment__c> newAppointment){
      List<Id> patientPersonalIDs = new List<Id>();
      Map<Id, Medical_Appointment__c> appointmentList = new Map<Id, Medical_Appointment__c> ();
      List<Id> usedIds = new List<Id>();
      List<Id> doctorPersonalIDs = new List<Id>();
  
      for(Medical_Appointment__c app : newAppointment){
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


  public static void handleInsuranceRequired(List<Medical_Appointment__c> newAppointment){
      List<Medical_Appointment__c> appointmentsWithInsurance = newAppointment;
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

}