public virtual class RESTMedicalFacilityHelper {
    public class FacilityWrapper {
        public String id;
        public String name;
        public String address;
        public Location geoLocation;
        public List<String> operatingHours;
    }

    public static String getTimeRangeAsString(Time openTime, Time closeTime) {
        String formattedOpenTime = String.valueOf(openTime).substring(0, 5);
        String formattedCloseTime = String.valueOf(closeTime).substring(0, 5);
        return formattedOpenTime + '-' + formattedCloseTime;
    }

    public static void updateFacility(FacilityWrapper wrapper) {
        Medical_Facility__c facility = [SELECT Id, Name, Address__c, Opening_Hours__c FROM Medical_Facility__c WHERE Id = :wrapper.Id LIMIT 1];

        Opening_Hours__c opHours = [SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
           Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
           Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
           Sunday_Open__c, Sunday_Close__c FROM Opening_Hours__c WHERE Id = :facility.Opening_Hours__c];

        facility.Name = wrapper.name;
        facility.Address__c = wrapper.address;
        updateHours(opHours, wrapper);

        update opHours;
        update facility;
    }

    public static void updateFacilities(List<FacilityWrapper> wrappers) {
        Set<Id> facilityIds = new Set<Id>();
    
        for (FacilityWrapper wrapper : wrappers) {
            facilityIds.add(wrapper.Id);
        }
    
        Map<Id, Medical_Facility__c> facilityMap = new Map<Id, Medical_Facility__c>([
            SELECT Id, Name, Address__c, Opening_Hours__c FROM Medical_Facility__c WHERE Id IN :facilityIds]);

        List<Id> opHoursIds = new List<Id>();

        for (FacilityWrapper wrapper : wrappers) {
            Medical_Facility__c facility = facilityMap.get(wrapper.Id);

            opHoursIds.add(facility.Opening_Hours__c);
        }

        List<Opening_Hours__c> hours = 
            [SELECT Monday_Open__c, Monday_Close__c, Tuesday_Open__c, Tuesday_Close__c,
           Wednesday_Open__c, Wednesday_Close__c, Thursday_Open__c, Thursday_Close__c,
           Friday_Open__c, Friday_Close__c, Saturday_Open__c, Saturday_Close__c,
           Sunday_Open__c, Sunday_Close__c FROM Opening_Hours__c WHERE Id IN :opHoursIds];
        
    
        List<Medical_Facility__c> facilitiesToUpdate = new List<Medical_Facility__c>();
        List<Opening_Hours__c> hoursToUpdate = new List<Opening_Hours__c>();
    
        for (Integer i = 0; i < wrappers.size(); i++) {
            FacilityWrapper wrapper = wrappers[i];
            Medical_Facility__c facility = facilityMap.get(wrapper.Id);
            Opening_Hours__c opHours = hours[i];
    
            if (facility != null) {
                facility.Name = wrapper.name;
                facility.Address__c = wrapper.address;
                facilitiesToUpdate.add(facility);
                updateHours(opHours, wrapper);
                hoursToUpdate.add(opHours);
            }
        }
        
        update hoursToUpdate;
        update facilitiesToUpdate;

        RestContext.response.statusCode = 200;
    }

    public static Time getTimeFromString(String timeStr) {
        String[] strTimeSplit = timeStr.split(':');
        Time t = Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);

        return t;
    }

   public static void updateHours(Opening_Hours__c opHours, FacilityWrapper wrapper) {
        opHours.Monday_Open__c = getTimeFromString(wrapper.operatingHours[0].substring(8, 13));
        opHours.Monday_Close__c = getTimeFromString(wrapper.operatingHours[0].substring(14, 19));
        opHours.Tuesday_Open__c = getTimeFromString(wrapper.operatingHours[1].substring(9, 14));
        opHours.Tuesday_Close__c = getTimeFromString(wrapper.operatingHours[1].substring(15, 20));
        opHours.Wednesday_Open__c = getTimeFromString(wrapper.operatingHours[2].substring(11, 16));
        opHours.Wednesday_Close__c = getTimeFromString(wrapper.operatingHours[2].substring(17, 22));
        opHours.Thursday_Open__c = getTimeFromString(wrapper.operatingHours[3].substring(10, 15));
        opHours.Thursday_Close__c = getTimeFromString(wrapper.operatingHours[3].substring(16, 21));
        opHours.Friday_Open__c = getTimeFromString(wrapper.operatingHours[4].substring(8, 13));
        opHours.Friday_Close__c = getTimeFromString(wrapper.operatingHours[4].substring(14, 19));
        opHours.Saturday_Open__c = getTimeFromString(wrapper.operatingHours[5].substring(10, 15));
        opHours.Saturday_Close__c = getTimeFromString(wrapper.operatingHours[5].substring(16, 21));
        opHours.Sunday_Open__c = getTimeFromString(wrapper.operatingHours[6].substring(8, 13));
        opHours.Sunday_Close__c = getTimeFromString(wrapper.operatingHours[6].substring(14, 19));
    }
}