@RestResource(UrlMapping='/Medical_Facility__c/*')
global with sharing class RESTMedicalFacility extends RESTMedicalFacilityUtils {
    @HttpGet
    global static void getFacilities() {
        List<FacilityWrapper> facilityWrappers = listFacilities();

        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(facilityWrappers));  
    }

    @HttpPut
    global static void putFacilities() {
        String jsonBody = RestContext.request.requestBody.toString();

        List<FacilityWrapper> facilityWrappers = (List<FacilityWrapper>) JSON.deserialize(jsonBody, List<FacilityWrapper>.class);

        Set<Id> facilityIds = new Set<Id>();
    
        for (FacilityWrapper wrapper : facilityWrappers) {
            facilityIds.add(wrapper.Id);
        }

        Map<Id, Medical_Facility__c> facilities = new Map<ID, Medical_Facility__c>([SELECT Id, Name, City__c, Flat_Number__c, Postcode__c, Street_Name__c, Street_Number__c, 
        (SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c FROM Operating_Hours__r) FROM Medical_Facility__c WHERE Id IN :facilityids]);

        List<Medical_Facility__c> facilitiesToUpdate = new List<Medical_Facility__c>();
        
        for (FacilityWrapper facility : facilityWrappers) {
            Medical_Facility__c tmp = facilities.get(facility.Id);
            List<Operating_Hours__c> operatingHoursToUpdate = new List<Operating_Hours__c>();

            updateFacility(facility, tmp, operatingHoursToUpdate);

            if (!operatingHoursToUpdate.isEmpty()) {
                upsert operatingHoursToUpdate; //wyniosłem wyzej
            }

            facilitiesToUpdate.add(tmp);
        }

        update facilitiesToUpdate;
        RestContext.response.statusCode = 200;
    }

    @HttpPost
    global static void postFacility() {
        String jsonBody = RestContext.request.requestBody.toString(); //mapa do dni, bez zbednych informacji
        List<FacilityWrapper> facilityWrappers = (List<FacilityWrapper>) JSON.deserialize(jsonBody, List<FacilityWrapper>.class);

        List<FacilityWrapper> allFacilities = listFacilities(); //querry dni z listy, min max godziny/dynamic querry (lepsze)

        List<FacilityWrapper> openFacilities = new List<FacilityWrapper>();

        for (FacilityWrapper facility : allFacilities) {
            if (isFacilityOpen(facility, facilityWrappers)) {
                openFacilities.add(facility);
            }
        }

        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(openFacilities));  
    }
}