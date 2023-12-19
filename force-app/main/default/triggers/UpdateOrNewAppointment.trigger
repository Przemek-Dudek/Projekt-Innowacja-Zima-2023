trigger UpdateOrNewAppointment on Medical_Appointment__c (after insert, after update) {
    Set<String> patientPersonalIDs = new Set<String>();
    
    for (Medical_Appointment__c appointment : Trigger.new) {
        patientPersonalIDs.add(appointment.Patient__c);
    }
    
    Map<String, Person__c> patientDetails = new Map<String, Person__c>();
    
    List<Person__c> listOfPatients =  [SELECT Email__c, Personal_ID_Number__c, First_Name__c, LastName__c FROM Person__c WHERE Personal_ID_Number__c IN :patientPersonalIDs];

    for(Person__c person : listOfPatients) {
        patientDetails.put(person.Personal_ID_Number__c, person);
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for (Medical_Appointment__c appointment : Trigger.new) {
        Person__c patient = patientDetails.get(appointment.Patient__c);
        if (patient != null && patient.Email__c != null) {
            String patientName = patient.First_Name__c + ' ' + patient.LastName__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ patient.Email__c });
            mail.setSubject('Your Medical Appointment has been updated!');
            mail.setPlainTextBody('Medical Appointment created or updated.\n\nDetails:\nDate: ' + appointment.Appointment_Date__c +
                                 '\nPatient: ' + patientName +
                                 '\nMedical Facility: ' + appointment.Medical_Facility__c +
                                 '\nStatus: ' + appointment.Status__c +
                                 '\nSurgery: ' + appointment.Surgery__c);
            emails.add(mail);
        }
    }
    
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}
