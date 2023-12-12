@RestResource(UrlMapping='/Medical_Facility__c/*')
global with sharing class RESTMedicalFacility {

    @HttpGet
    global static void getFacilities() {
        List<Medical_Facility__c> facilities = [SELECT Id, Name, Address__c, Geo_location__c, Opening_Hours__c FROM Medical_Facility__c];

        List<FacilityWrapper> wrappers = new List<FacilityWrapper>();

        List<Id> opHours = new List<Id>();

        for (Medical_Facility__c facility : facilities) {
            opHours.add(facility.Opening_Hours__c);
        }

        List<Opening_Hours__c> hours = [
            SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
           Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
           Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
           Sunday_Open__c, Sunday_Close__c
            FROM Opening_Hours__c WHERE Id IN :opHours];

        for (Integer i = 0; i < facilities.size(); i++) {
            FacilityWrapper wrapper = new FacilityWrapper();
            wrapper.operatingHours = new List<String>();
            Medical_Facility__c facility = facilities[i];

            wrapper.id = facility.Id;
            wrapper.name = facility.Name;
            wrapper.address = facility.Address__c;
            wrapper.geoLocation = facility.Geo_location__c;

            wrapper.operatingHours.add('Monday: ' + getTimeRangeAsString(hours[i].Monday_Open__c, hours[i].Monday_Close__c));
            wrapper.operatingHours.add('Tuesday: ' + getTimeRangeAsString(hours[i].Tuesday_Open__c, hours[i].Tuesday_Close__c));
            wrapper.operatingHours.add('Wednesday: ' + getTimeRangeAsString(hours[i].Wednesday_Open__c, hours[i].Wednesday_Close__c));
            wrapper.operatingHours.add('Thursday: ' + getTimeRangeAsString(hours[i].Thursday_Open__c, hours[i].Thursday_Close__c));
            wrapper.operatingHours.add('Friday: ' + getTimeRangeAsString(hours[i].Friday_Open__c, hours[i].Friday_Close__c));
            wrapper.operatingHours.add('Saturday: ' + getTimeRangeAsString(hours[i].Saturday_Open__c, hours[i].Saturday_Close__c));
            wrapper.operatingHours.add('Sunday: ' + getTimeRangeAsString(hours[i].Sunday_Open__c, hours[i].Sunday_Close__c));

            wrappers.add(wrapper);
        }

        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(wrappers));
    }

    private static String getTimeRangeAsString(Time openTime, Time closeTime) {
        String formattedOpenTime = String.valueOf(openTime).substring(0, 5);
        String formattedCloseTime = String.valueOf(closeTime).substring(0, 5);
        return formattedOpenTime + '-' + formattedCloseTime;
    }

    @HttpPut
    global static void putFacilities() {
        String jsonBody = RestContext.request.requestBody.toString();

        if (jsonBody.startsWith('[')) {
            List<FacilityWrapper> wrappers = (List<FacilityWrapper>) JSON.deserialize(jsonBody, List<FacilityWrapper>.class);
            updateFacilities(wrappers);
        } else {
            FacilityWrapper wrapper = (FacilityWrapper) JSON.deserialize(jsonBody, FacilityWrapper.class);
            updateFacility(wrapper);
        }

        RestContext.response.statusCode = 200;
    }

    private static void updateFacility(FacilityWrapper wrapper) {
        Medical_Facility__c facility = [SELECT Id, Name, Address__c, Opening_Hours__c FROM Medical_Facility__c WHERE Id = :wrapper.Id LIMIT 1];

        facility.Name = wrapper.name;
        facility.Address__c = wrapper.address;

        update facility;
    }

    private static void updateFacilities(List<FacilityWrapper> wrappers) {
        Set<Id> facilityIds = new Set<Id>();
    
        for (FacilityWrapper wrapper : wrappers) {
            facilityIds.add(wrapper.Id);
        }
    
        Map<Id, Medical_Facility__c> facilityMap = new Map<Id, Medical_Facility__c>([
            SELECT Id, Name, Address__c, Opening_Hours__c FROM Medical_Facility__c WHERE Id IN :facilityIds]);
    
        List<Medical_Facility__c> facilitiesToUpdate = new List<Medical_Facility__c>();
    
        for (FacilityWrapper wrapper : wrappers) {
            Medical_Facility__c facility = facilityMap.get(wrapper.Id);
    
            if (facility != null) {
                facility.Name = wrapper.name;
                facility.Address__c = wrapper.address;
                facilitiesToUpdate.add(facility);
            }
        }
    
        update facilitiesToUpdate;

        RestContext.response.statusCode = 200;
    }

    // @HttpPost
    // global static void postFacility() {
        
    // }

    public class FacilityWrapper {
        public String id;
        public String name;
        public String address;
        public Location geoLocation;
        public List<String> operatingHours;
    }

    public class OpHoursWrapper {
        Time [] openingHours = new Time[7];
        Time [] closingHours = new Time[7];
    }
}