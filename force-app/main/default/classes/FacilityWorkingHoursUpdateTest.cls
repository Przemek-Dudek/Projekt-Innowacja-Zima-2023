/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class FacilityWorkingHoursUpdateTest {
    @TestSetup
    static void makeData(){
        Person__c person = new Person__c(
            First_Name__c = 'Jan',
            LastName__c = 'Kowalski'
        );
        insert person;

        Medical_Facility__c f = new Medical_Facility__c(
            Name = 'Facility 1',
            City__c = 'Lodz',
            Flat_Number__c = 11,
            Postcode__c = '00-000',
            Street_Name__c = 'Aleje Politechniki',
            Street_Number__c = 111,
            Doctors_List__c = person.Id
        );

        insert f;

        insert new Operating_Hours__c(
            Day_of_Week__c = 'Monday',
            Opening_Time__c = Time.newInstance(8, 0, 0, 0),
            Closing_Time__c = Time.newInstance(16, 0, 0, 0),
            Medical_Facility__c = f.Id
        );

        insert new Operating_Hours__c(
            Day_of_Week__c = 'Tuesday',
            Opening_Time__c = Time.newInstance(8, 0, 0, 0),
            Closing_Time__c = Time.newInstance(16, 0, 0, 0),
            Medical_Facility__c = f.Id
        );

        insert new Operating_Hours__c(
            Day_of_Week__c = 'Wednesday',
            Opening_Time__c = Time.newInstance(8, 0, 0, 0),
            Closing_Time__c = Time.newInstance(16, 0, 0, 0),
            Medical_Facility__c = f.Id
        );

        insert new Operating_Hours__c(
            Day_of_Week__c = 'Thursday',
            Opening_Time__c = Time.newInstance(8, 0, 0, 0),
            Closing_Time__c = Time.newInstance(16, 0, 0, 0),
            Medical_Facility__c = f.Id
        );

        insert new Operating_Hours__c(
            Day_of_Week__c = 'Friday',
            Opening_Time__c = Time.newInstance(8, 0, 0, 0),
            Closing_Time__c = Time.newInstance(16, 0, 0, 0),
            Medical_Facility__c = f.Id
        );

        insert new Operating_Hours__c(
            Day_of_Week__c = 'Saturday',
            Opening_Time__c = Time.newInstance(8, 0, 0, 0),
            Closing_Time__c = Time.newInstance(16, 0, 0, 0),
            Medical_Facility__c = f.Id
        );

        insert new Operating_Hours__c(
            Day_of_Week__c = 'Sunday',
            Opening_Time__c = Time.newInstance(8, 0, 0, 0),
            Closing_Time__c = Time.newInstance(16, 0, 0, 0),
            Medical_Facility__c = f.Id
        );
    }

    @isTest
    static void testScheduleMe() {
        Test.startTest();
        Id jobId = FacilityWorkingHoursUpdate.scheduleMe('Test Job');
        Test.stopTest();

        System.assertNotEquals(null, jobId);
    }

    @isTest
    static void testUpdateHoursRandomly() {
        List<Operating_Hours__c> Hours = [SELECT Id, Opening_Time__c, Closing_Time__c FROM Operating_Hours__c];

        Test.startTest();
        for(Operating_Hours__c h :Hours) {
            FacilityWorkingHoursUpdate.updateHoursRandomly(h);
        }

        update Hours;
        Test.stopTest();

        List<Operating_Hours__c> updatedHours = [SELECT Id, Opening_Time__c, Closing_Time__c FROM Operating_Hours__c];
        for (Operating_Hours__c h : updatedHours) {
            System.assertNotEquals(Time.newInstance(8, 0, 0, 0), h.Opening_Time__c);
            System.assertNotEquals(Time.newInstance(16, 0, 0, 0), h.Closing_Time__c);
        }
    }

    @isTest
    static void testBatchable(){
        List<Operating_Hours__c> Hours = [SELECT Id, Opening_Time__c, Closing_Time__c FROM Operating_Hours__c];

        Test.startTest();
        FacilityWorkingHoursUpdate batch = new FacilityWorkingHoursUpdate();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Operating_Hours__c> newHours = [SELECT Id, Opening_Time__c, Closing_Time__c FROM Operating_Hours__c];

        System.assertNotEquals(Hours, newHours);
    }

    @isTest
    static void testBatchableFailure(){

        Test.startTest();
        FacilityWorkingHoursUpdate batch = new FacilityWorkingHoursUpdate();
    
        batch.isUpdateSuccessful = False;
        Database.executeBatch(batch);
        Test.stopTest();

        List<EmailMessage> sentEmails = [
                        SELECT Id, ToAddress, Subject, TextBody
                        FROM EmailMessage
                    ];

        System.assertEquals(1, sentEmails.size());
    }
}