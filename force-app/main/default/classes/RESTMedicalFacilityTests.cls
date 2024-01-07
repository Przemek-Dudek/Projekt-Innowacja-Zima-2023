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
private class RESTMedicalFacilityTests {
    @TestSetup
    static void makeData(){
        Person__c person = new Person__c(
            First_Name__c = 'Jan',
            LastName__c = 'Kowalski'
        );
        insert person;

        Medical_Facility__c f = new Medical_Facility__c(
            Name = 'Facility 1',
            // City__c = 'Lodz',
            // Flat_Number__c = '11',
            // Postcode__c = '00-000',
            // Street_Name__c = 'Aleje Politechniki',
            // Street_Number__c = '111',
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
    private static void testGetMethod() {
        Medical_Facility__c testFacility = [SELECT Id, Name, (SELECT Day_of_Week__c, Opening_Time__c, Closing_Time__c FROM Operating_Hours__r) FROM Medical_Facility__c];

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;


        test.startTest();
        RESTMedicalFacility.getFacilities();
        test.stopTest();

        String responseBody = '[{"operatingHours":{"Sunday":{"openingHour":"08:00:00.000Z","closingHour":"16:00:00.000Z"},"Saturday":{"openingHour":"08:00:00.000Z","closingHour":"16:00:00.000Z"},"Friday":{"openingHour":"08:00:00.000Z","closingHour":"16:00:00.000Z"},"Thursday":{"openingHour":"08:00:00.000Z","closingHour":"16:00:00.000Z"},"Wednesday":{"openingHour":"08:00:00.000Z","closingHour":"16:00:00.000Z"},"Tuesday":{"openingHour":"08:00:00.000Z","closingHour":"16:00:00.000Z"},"Monday":{"openingHour":"08:00:00.000Z","closingHour":"16:00:00.000Z"}},"name":"Facility 1","id":"' + String.valueOf(testFacility.Id) + '","address":{"street_number":null,"street_name":null,"postcode":null,"flat_number":null,"city":null}}]';

        Assert.areEqual(200, response.statusCode);
        Assert.areEqual(responseBody, response.responseBody.toString());
    }
}