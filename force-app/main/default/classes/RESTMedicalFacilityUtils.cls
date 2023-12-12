public with sharing virtual class RESTMedicalFacilityUtils {
    public class FacilityWrapper {
        public String id;
        public String name;
        public Address address;
        public Map<String, HourWrapper> operatingHours;

        public FacilityWrapper(String id, String name, Address address) {
            this.id = id;
            this.name = name;
            this.address = address;
            this.operatingHours = new Map<String, HourWrapper>();
        }

        public void addOperatingHours(String dayOfWeek, Time openingHour, Time closingHour) {
            this.operatingHours.put(dayOfWeek, new HourWrapper(openingHour, closingHour));
        }
    }

    public class Address {
        public String street_name;
        public String city;
        public Integer flat_number;
        public Integer street_number;
        public Integer postcode;

        public Address(String street_name, String city, Integer flat_number, Integer street_number, Integer postcode) {
            this.street_name = street_name;
            this.city = city;
            this.flat_number = flat_number;
            this.street_number = street_number;
            this.postcode = postcode;
        }
    }

    public class HourWrapper {
        public Time openingHour;
        public Time closingHour;

        public HourWrapper(Time openingHour, Time closingHour) {
            this.openingHour = openingHour;
            this.closingHour = closingHour;
        }
    }

    public static List<FacilityWrapper> listFacilities() {
        List<Medical_Facility__c> facilities = [SELECT Id, Name, City__c, Flat_Number__c, Postcode__c, Street_Name__c, Street_Number__c, 
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

        return facilityWrappers;
    }

    public static void updateFacility(FacilityWrapper facility, Medical_Facility__c tmp) {
        if(facility.name != NULL) {
            tmp.name = facility.name;
        }

        if(facility.address != NULL) {
            tmp.Address__c = facility.address;
        }

        if (facility.operatingHours != null) {
            List<Operating_Hours__c> operatingHoursToUpdate = new List<Operating_Hours__c>();

            upsertHours(operatingHoursToUpdate, facility, tmp);

            if (!operatingHoursToUpdate.isEmpty()) {
                upsert operatingHoursToUpdate;
            }
        }
    }

    public static void upsertHours(List<Operating_Hours__c> operatingHoursToUpdate, FacilityWrapper facility, Medical_Facility__c tmp) {
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
    }

    public static Boolean isFacilityOpen(FacilityWrapper facility, List<FacilityWrapper> openingHoursToCheck) {
        for (FacilityWrapper openingHours : openingHoursToCheck) {
            if (facilityMatchesCriteria(facility, openingHours)) {
                return true;
            }
        }
    
        return false;
    }
    
    public static Boolean facilityMatchesCriteria(FacilityWrapper facility, FacilityWrapper openingHours) {
        for (String dayOfWeek : openingHours.operatingHours.keySet()) {
            HourWrapper facilityHours = facility.operatingHours.get(dayOfWeek);
            HourWrapper openingHoursForDay = openingHours.operatingHours.get(dayOfWeek);
    
            if (facilityHours != null && openingHoursForDay != null) {
                if (!(facilityHours.openingHour >= openingHoursForDay.openingHour
                    && facilityHours.closingHour <= openingHoursForDay.closingHour)) {
                    return false;
                }
            }
        }
    
        return true;
    }
}
