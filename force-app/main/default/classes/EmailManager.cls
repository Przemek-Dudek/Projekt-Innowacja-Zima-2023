public with sharing class EmailManager {
    private static final String EMAIL_SENDER_NAME = 'Medical Facility IT Administraion';
  
    public static Messaging.SingleEmailMessage createSingleEmail(
      String emailAddress,
      String emailTextBody,
      String emailSubject
    ) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ emailAddress };
      mail.setToAddresses(toAddresses);
      mail.setSubject(emailSubject);
      mail.setPlainTextBody(emailTextBody);
      mail.setSenderDisplayName(EMAIL_SENDER_NAME);
      return mail;
    }
  
    public static String createEmailContent(Set<Id> errorToIDs) {
        List<String> records = new List<String>();
        
        for (Id recordId : errorToIDs) {
            records.add(recordId);
        }
        return String.join(records, '\n');
    }

    public static void sendBatchErrorEmail(Set<Id> errorToIDs, String subject) {
        String body = String.format(
            'The batch failed to update records with the following IDs:\n\n%s',
            new List<String>{createEmailContent(errorToIDs)}
        );

        sendErrorMessage(subject, body);
    }
  
    public static void sendErrorMessage(String subject, String body) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(
            createSingleEmail(
                '240655@edu.p.lodz.pl',
                body,
                subject
            )
        );
        Messaging.sendEmail(mails);
    }
  }