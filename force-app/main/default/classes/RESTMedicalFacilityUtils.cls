public with sharing virtual class RESTMedicalFacilityUtils {
    public class FacilityWrapper {
        public String id;
        public String name;
        public String address;
        public Location geoLocation;
        public List<String> operatingHours;
    }

    public class DaysAndHours {
        public String day;
        public Time open;
        public Time close;
    }

    public class IncorrectDayException extends Exception {}
    public class IncorrectStatementException extends Exception {}

    public static String getTimeRangeAsString(Time openTime, Time closeTime) {
        String formattedOpenTime = String.valueOf(openTime).substring(0, 5);
        String formattedCloseTime = String.valueOf(closeTime).substring(0, 5);
        return formattedOpenTime + '-' + formattedCloseTime;
    }

    public static Time getTimeFromString(String timeStr) {
        String[] strTimeSplit = timeStr.split(':');
        Time t = Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);

        return t;
    }

    public static void wrapFacilities(List<Medical_Facility__c> facilities, List<Opening_Hours__c> hours, List<FacilityWrapper> wrappers) {
        for (Integer i = 0; i < facilities.size(); i++) {
            FacilityWrapper wrapper = new FacilityWrapper();
            wrapper.operatingHours = new List<String>();
            Medical_Facility__c facility = facilities[i];

            wrapper.id = facility.Id;
            wrapper.name = facility.Name;
            wrapper.address = facility.Address__c;
            wrapper.geoLocation = facility.Geo_location__c;

            wrapper.operatingHours.add('Monday ' + getTimeRangeAsString(hours[i].Monday_Open__c, hours[i].Monday_Close__c));
            wrapper.operatingHours.add('Tuesday ' + getTimeRangeAsString(hours[i].Tuesday_Open__c, hours[i].Tuesday_Close__c));
            wrapper.operatingHours.add('Wednesday ' + getTimeRangeAsString(hours[i].Wednesday_Open__c, hours[i].Wednesday_Close__c));
            wrapper.operatingHours.add('Thursday ' + getTimeRangeAsString(hours[i].Thursday_Open__c, hours[i].Thursday_Close__c));
            wrapper.operatingHours.add('Friday ' + getTimeRangeAsString(hours[i].Friday_Open__c, hours[i].Friday_Close__c));
            wrapper.operatingHours.add('Saturday ' + getTimeRangeAsString(hours[i].Saturday_Open__c, hours[i].Saturday_Close__c));
            wrapper.operatingHours.add('Sunday ' + getTimeRangeAsString(hours[i].Sunday_Open__c, hours[i].Sunday_Close__c));

            wrappers.add(wrapper);
        }
    }

    public static void updateHour(Opening_Hours__c opHours, DaysAndHours dayTime) {
        switch on dayTime.day {
            when 'Monday' {
                opHours.Monday_Open__c = dayTime.open;
                opHours.Monday_Close__c = dayTime.close;
            }
            when 'Tuesday' {
                opHours.Tuesday_Open__c = dayTime.open;
                opHours.Tuesday_Close__c = dayTime.close;
            }
            when 'Wednesday' {
                opHours.Wednesday_Open__c = dayTime.open;
                opHours.Wednesday_Close__c = dayTime.close;
            }
            when 'Thursday' {
                opHours.Thursday_Open__c = dayTime.open;
                opHours.Thursday_Close__c = dayTime.close;
            }
            when 'Friday' {
                opHours.Friday_Open__c = dayTime.open;
                opHours.Friday_Close__c = dayTime.close;
            }
            when 'Saturday' {
                opHours.Saturday_Open__c = dayTime.open;
                opHours.Saturday_Close__c = dayTime.close;
            }
            when 'Sunday' {
                opHours.Sunday_Open__c = dayTime.open;
                opHours.Sunday_Close__c = dayTime.close;
            }
            when else {
                throw new IncorrectDayException('Incorrect day: ' + dayTime.day);
            }
        }
    }

    public static void updateHours(Opening_Hours__c opHours, FacilityWrapper wrapper) {
        for (String str : wrapper.operatingHours) {
            DaysAndHours newDay = new DaysAndHours();
        
            List<String> strSplit = str.split('-|\\s', 5);

            if(strSplit.size() == 3) {
                newDay.day = strSplit[0];
                newDay.open = getTimeFromString(strSplit[1]);
                newDay.close = getTimeFromString(strSplit[2]);
            } else {
                throw new IncorrectStatementException('Incorrect statement: ' + str);
            }

            try {
                updateHour(opHours, newDay);
            } catch (IncorrectDayException e) {
                throw e;
            }
        }
    }

    public static Boolean checkHour(Opening_Hours__c opHours, DaysAndHours dayTime) {
        switch on dayTime.day {
            when 'Monday' {
                return opHours.Monday_Open__c <= dayTime.open && opHours.Monday_Close__c >= dayTime.close;
            }
            when 'Tuesday' {
                return opHours.Tuesday_Open__c <= dayTime.open && opHours.Tuesday_Close__c >= dayTime.close;
            }
            when 'Wednesday' {
                return opHours.Wednesday_Open__c <= dayTime.open && opHours.Wednesday_Close__c >= dayTime.close;
            }
            when 'Thursday' {
                return opHours.Thursday_Open__c <= dayTime.open && opHours.Thursday_Close__c >= dayTime.close;
            }
            when 'Friday' {
                return opHours.Friday_Open__c <= dayTime.open && opHours.Friday_Close__c >= dayTime.close;
            }
            when 'Saturday' {
                return opHours.Saturday_Open__c <= dayTime.open && opHours.Saturday_Close__c >= dayTime.close;
            }
            when 'Sunday' {
                return opHours.Sunday_Open__c <= dayTime.open && opHours.Sunday_Close__c >= dayTime.close;
            }
            when else {
                throw new IncorrectDayException('Incorrect day: ' + dayTime.day);
            }
        }
    }
}