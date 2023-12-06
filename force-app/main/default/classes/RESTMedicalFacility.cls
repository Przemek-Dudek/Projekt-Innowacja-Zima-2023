@RestResource(UrlMapping='/Medical_Facility__c/*')
global with sharing class RESTMedicalFacility extends RESTMedicalFacilityUtils {
    @HttpGet
    global static void getFacilities() {
        List<Medical_Facility__c> facilities = [SELECT Id, Name, Address__c, 
        (SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c FROM Operating_Hours__r) FROM Medical_Facility__c];

        List<FacilityWrapper> facilityWrappers = new List<FacilityWrapper>();

        for (Medical_Facility__c facility : facilities) {
            FacilityWrapper wrapper = new FacilityWrapper(
                facility.Id,
                facility.Name,
                facility.Address__c
            );
    
            for (Operating_Hours__c operatingHours : facility.Operating_Hours__r) {
                wrapper.addOperatingHours(
                    operatingHours.Day_of_Week__c,
                    operatingHours.Opening_Time__c,
                    operatingHours.Closing_Time__c
                );
            }
    
            facilityWrappers.add(wrapper);
        }

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

        Map<Id, Medical_Facility__c> facilities = new Map<ID, Medical_Facility__c>([SELECT Id, Name, Address__c, 
        (SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c FROM Operating_Hours__r) FROM Medical_Facility__c WHERE Id IN :facilityids]);

        List<Medical_Facility__c> facilitiesToUpdate = new List<Medical_Facility__c>();
        
        for (FacilityWrapper facility : facilityWrappers) {
            Medical_Facility__c tmp = facilities.get(facility.Id);

            if(facility.name != NULL) {
                tmp.name = facility.name;
            }

            if(facility.address != NULL) {
                tmp.Address__c = facility.address;
            }

            if (facility.operatingHours != null) {
                List<Operating_Hours__c> operatingHoursToUpdate = new List<Operating_Hours__c>();
    
                for (String dayOfWeek : facility.operatingHours.keySet()) {
                    HourWrapper hours = facility.operatingHours.get(dayOfWeek);
    
                    Operating_Hours__c operatingHour = null;
                    for (Operating_Hours__c tmpOperatingHour : tmp.Operating_Hours__r) {
                        if (tmpOperatingHour.Day_of_Week__c == dayOfWeek) {
                            operatingHour = tmpOperatingHour;
                            break;
                        }
                    }
    
                    if (operatingHour != null) {
                        operatingHour.Opening_Time__c = hours.openingHour;
                        operatingHour.Closing_Time__c = hours.closingHour;
                        operatingHoursToUpdate.add(operatingHour);
                    } else {
                        operatingHoursToUpdate.add(new Operating_Hours__c(
                            Day_of_Week__c = dayOfWeek,
                            Opening_Time__c = hours.openingHour,
                            Closing_Time__c = hours.closingHour,
                            Medical_Facility__c = tmp.Id
                        ));
                    }
                }
    
                if (!operatingHoursToUpdate.isEmpty()) {
                    upsert operatingHoursToUpdate;
                }
            }

            facilitiesToUpdate.add(tmp);
        }

        update facilitiesToUpdate;
        RestContext.response.statusCode = 200;
    }
}

// @RestResource(UrlMapping='/Medical_Facility__c/*')
// global with sharing class RESTMedicalFacility extends RESTMedicalFacilityHelper {
//     @HttpGet
//     global static void getFacilities() {
//         List<Medical_Facility__c> facilities = [SELECT Id, Name, Address__c, Geo_location__c, Opening_Hours__c FROM Medical_Facility__c];

//         List<FacilityWrapper> wrappers = new List<FacilityWrapper>();

//         List<Id> opHours = new List<Id>();

//         for (Medical_Facility__c facility : facilities) {
//             opHours.add(facility.Opening_Hours__c);
//         }

//         List<Opening_Hours__c> hours = [
//             SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
//            Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
//            Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
//            Sunday_Open__c, Sunday_Close__c
//             FROM Opening_Hours__c WHERE Id IN :opHours];

//         wrapFacilities(facilities, hours, wrappers);

//         RestContext.response.statusCode = 200;
//         RestContext.response.responseBody = Blob.valueOf(JSON.serialize(wrappers));     
//     }

//     @HttpPut
//     global static void putFacilities() {
//         String jsonBody = RestContext.request.requestBody.toString();

//         if (jsonBody.startsWith('[')) {
//             List<FacilityWrapper> wrappers = (List<FacilityWrapper>) JSON.deserialize(jsonBody, List<FacilityWrapper>.class);
//             try {
//                 updateFacilities(wrappers);
//             } catch (Exception e) {
//                 RestContext.response.statusCode = 400;
//                 RestContext.response.responseBody = Blob.valueOf(e.getMessage());
//                 return;
//             }
            
//         } else {
//             FacilityWrapper wrapper = (FacilityWrapper) JSON.deserialize(jsonBody, FacilityWrapper.class);
//             try {
//                 updateFacility(wrapper);
//             } catch (Exception e) {
//                 RestContext.response.statusCode = 400;
//                 RestContext.response.responseBody = Blob.valueOf(e.getMessage());
//                 return;
//             }
//         }

//         RestContext.response.statusCode = 200;
//     }

//     @HttpPost
//     global static void postFacility() {
//         String jsonBody = RestContext.request.requestBody.toString();
//         FacilityWrapper wrapper = (FacilityWrapper) JSON.deserialize(jsonBody, FacilityWrapper.class);

//         List<DaysAndHours> serchedHours = new List<DaysAndHours>();

//         for (String str : wrapper.operatingHours) {
//             DaysAndHours newDay = new DaysAndHours();
            
//             List<String> strSplit = str.split('-|\\s', 5);

//             if(strSplit.size() == 3) {
//                 newDay.day = strSplit[0];
//                 newDay.open = getTimeFromString(strSplit[1]);
//                 newDay.close = getTimeFromString(strSplit[2]);
//             } else {
//                 RestContext.response.statusCode = 400;
//                 RestContext.response.responseBody = Blob.valueOf('Incorrect input string: ' + str);
//                 return;
//             }
            
//             serchedHours.add(newDay);
//         }

//         List<Opening_Hours__c> hours = 
//             [SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
//             Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
//             Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
//             Sunday_Open__c, Sunday_Close__c FROM Opening_Hours__c];

//             List<Opening_Hours__c> correctHours = new List<Opening_Hours__c>();

//         for (Opening_Hours__c h : hours) {
//             for (Integer i = 0; i < serchedHours.size(); i++) {
//                 if(!checkHour(h, serchedHours[i])) {
//                     break;
//                 }

//                 if(i == serchedHours.size()-1) {
//                     correctHours.add(h);
//                 }
//             }
//         }

//         List<Medical_Facility__c> facilities = [SELECT Id, Name, Address__c, Geo_location__c, Opening_Hours__c FROM Medical_Facility__c WHERE Opening_Hours__c IN :correctHours];

//         List<FacilityWrapper> wrappers = new List<FacilityWrapper>();

//         wrapFacilities(facilities, correctHours, wrappers);

//         RestContext.response.statusCode = 200;
//         RestContext.response.responseBody = Blob.valueOf(JSON.serialize(wrappers));
//     }
// }\

