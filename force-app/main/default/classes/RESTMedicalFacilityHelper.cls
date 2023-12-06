public with sharing virtual class RESTMedicalFacilityHelper extends RESTMedicalFacilityUtils {

}

// public with sharing virtual class RESTMedicalFacilityHelper extends RESTMedicalFacilityUtils {
//     public static void updateFacility(FacilityWrapper wrapper) {
//         Medical_Facility__c facility = [SELECT Id, Name, Address__c, Opening_Hours__c FROM Medical_Facility__c WHERE Id = :wrapper.Id LIMIT 1];

//         Opening_Hours__c opHours = [SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
//            Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
//            Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
//            Sunday_Open__c, Sunday_Close__c FROM Opening_Hours__c WHERE Id = :facility.Opening_Hours__c];

//         if(wrapper.name != NULL) {
//             facility.Name = wrapper.name;
//         }
        
//         if(wrapper.address != NULL) {
//             facility.Address__c = wrapper.address;
//         }

//         try {
//             updateHours(opHours, wrapper);
//         } catch (Exception e) {
//             System.debug('Exception caught: ' + e.getMessage());
//             RestContext.response.statusCode = 400;
//             RestContext.response.responseBody = Blob.valueOf(e.getMessage());
//             throw e;
//         }

//         update opHours;
//         update facility;
//     }

//     public static void updateFacilities(List<FacilityWrapper> wrappers) {
//         Set<Id> facilityIds = new Set<Id>();
    
//         for (FacilityWrapper wrapper : wrappers) {
//             facilityIds.add(wrapper.Id);
//         }
    
//         Map<Id, Medical_Facility__c> facilityMap = new Map<Id, Medical_Facility__c>([
//             SELECT Id, Name, Address__c, Opening_Hours__c FROM Medical_Facility__c WHERE Id IN :facilityIds]);

//         List<Id> opHoursIds = new List<Id>();

//         for (FacilityWrapper wrapper : wrappers) {
//             Medical_Facility__c facility = facilityMap.get(wrapper.Id);

//             opHoursIds.add(facility.Opening_Hours__c);
//         }

//         List<Opening_Hours__c> hours = 
//             [SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
//            Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
//            Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
//            Sunday_Open__c, Sunday_Close__c FROM Opening_Hours__c WHERE Id IN :opHoursIds];
        
    
//         Set<Medical_Facility__c> facilitiesToUpdate = new Set<Medical_Facility__c>();
//         List<Opening_Hours__c> hoursToUpdate = new List<Opening_Hours__c>();
    
//         for (Integer i = 0; i < wrappers.size(); i++) {
//             FacilityWrapper wrapper = wrappers[i];
//             Medical_Facility__c facility = facilityMap.get(wrapper.Id);
//             Opening_Hours__c opHours = hours[i];
    
//             if (facility != null) {
//                 if(wrapper.name != NULL) {
//                     facility.Name = wrapper.name;
//                     facilitiesToUpdate.add(facility);
//                 }
                
//                 if(wrapper.address != NULL) {
//                     facility.Address__c = wrapper.address;
//                     facilitiesToUpdate.add(facility);
//                 }
                
//                 try {
//                     updateHours(opHours, wrapper);
//                 } catch (Exception e) {
//                     System.debug('Exception caught: ' + e.getMessage());
//                     RestContext.response.statusCode = 400;
//                     RestContext.response.responseBody = Blob.valueOf(e.getMessage());
//                     throw e;
//                 }

//                 hoursToUpdate.add(opHours);
//             }
//         }
        
//         update hoursToUpdate;
//         update new List<Medical_Facility__c>(facilitiesToUpdate);

//         RestContext.response.statusCode = 200;
//     }
// }