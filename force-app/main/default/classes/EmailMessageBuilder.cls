public with sharing class EmailMessageBuilder {
    public static Messaging.SingleEmailMessage createEmailMessage(Medical_Appointment__c appointment, Person__c patient) {
        String patientName = patient.First_Name__c + ' ' + patient.LastName__c;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{patient.Email__c});
        mail.setSubject('Your Medical Appointment has been updated!');

        String build = String.format('Medical Appointment created or updated.\n Details:\nDate: {0}\nPatient: {1}\nStatus: {2}\nSurgery: {3}',
            new List<Object>{
                appointment.Appointment_Date__c,
                patientName,
                appointment.Status__c,
                appointment.Surgery__c
            }
        );

        mail.setPlainTextBody(build);

        return mail;
    }
}