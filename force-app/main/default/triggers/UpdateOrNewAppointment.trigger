trigger UpdateOrNewAppointment on Medical_Appointment__c (after insert, after update) {
    Set<String> patientPersonalIDs = new Set<String>();
    
    for (Medical_Appointment__c appointment : Trigger.new) {
        patientPersonalIDs.add(appointment.Patient__c);
    }
    
    Map<String, Person__c> patientDetails = new Map<String, Person__c>();
    
    List<Person__c> listOfPatients =  [SELECT Email__c, Personal_ID_Number__c, First_Name__c, LastName__c FROM Person__c WHERE Id IN :patientPersonalIDs];

    for(Person__c person : listOfPatients) {
        patientDetails.put(person.Id, person);
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for (Medical_Appointment__c appointment : Trigger.new) {
        Person__c patient = patientDetails.get(appointment.Patient__c);
        if(Trigger.isUpdate){
            Medical_Appointment__c oldPatient = Trigger.oldMap.get(appointment.Id);
        
        if (patient != null && patient.Email__c != null && oldPatient != null) {
            if(appointment.Appointment_Date__c != oldPatient.Appointment_Date__c || 
            appointment.Status__c != oldPatient.Status__c || 
            appointment.Surgery__c != oldPatient.Surgery__c || 
            appointment.RecordTypeId != oldPatient.RecordTypeId){
                String patientName = patient.First_Name__c + ' ' + patient.LastName__c;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ patient.Email__c });
                mail.setSubject('Your Medical Appointment has been updated!');
    
                String build = String.format('Medical Appointment created or updated.\n Details:\nDate: {0}\nPatient: {1}\nStatus: {2}\nSurgery: {3}',
                    new List<Object> {
                        appointment.Appointment_Date__c,
                        patientName,
                        appointment.Status__c,
                        appointment.Surgery__c
                        }
                    );
    
                mail.setPlainTextBody(build); 
                emails.add(mail);
             }
            }
        }
        if(Trigger.isInsert){
            String patientName = patient.First_Name__c + ' ' + patient.LastName__c;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ patient.Email__c });
                mail.setSubject('Your Medical Appointment has been updated!');
    
                String build = String.format('Medical Appointment created or updated.\n Details:\nDate: {0}\nPatient: {1}\nStatus: {2}\nSurgery: {3}',
                    new List<Object> {
                        appointment.Appointment_Date__c,
                        patientName,
                        appointment.Status__c,
                        appointment.Surgery__c
                    }
                );
    
                mail.setPlainTextBody(build); 
                emails.add(mail);
        }
        
    }
    
    if(!emails.isEmpty()){
        Messaging.sendEmail(emails);
    }
}