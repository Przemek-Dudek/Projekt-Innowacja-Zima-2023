public with sharing class AppointmentController {
    class HourWrapper {
        Datetime openingTime;
        Datetime closingTime;
        String label;
    }


    @AuraEnabled(cacheable=true)
    public static List<Person__c> getDoctorsBySpecialization(String specialization) {
        return [SELECT Id, First_Name__c, LastName__c, Specialization__c, Medical_Facility__r.Name
                FROM Person__c
                WHERE RecordType.Name = 'Doctor' AND Specialization__c = :specialization
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getSpecializations() {
        List<AggregateResult> tmp = [SELECT Specialization__c FROM Person__c WHERE RecordType.Name = 'Doctor' GROUP BY Specialization__c];

        List<String> specializationsList = new List<String>();

        for (AggregateResult p : tmp) {
            specializationsList.add((String)p.get('Specialization__c'));
        }

        return specializationsList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Datetime>> getAvailableHours(Datetime selectedDate, Id selectedDoctor) {
        Id selectedFacility = getFacilityId(selectedDoctor);
        String dayOfWeek = selectedDate.format('EEEE');

        List<Operating_Hours__c> operatingTime = getAllHours(dayOfWeek, selectedFacility);

        if (operatingTime.size() != 1) {
            system.debug('Error while querying allHours');
            return null;
        }

        List<HourWrapper> hours = generateOperatingHours(Datetime.newInstance(selectedDate.date(), operatingTime[0].Opening_Time__c), Datetime.newInstance(selectedDate.date(), operatingTime[0].Closing_Time__c));

        List<Medical_Appointment__c> existingAppointments = getExistingAppointments(selectedDate.date(), operatingTime[0].Opening_Time__c, operatingTime[0].Closing_Time__c, selectedFacility);

        removeConflictingHours(hours, existingAppointments);

        System.debug(hours);

        List<Map<String, Datetime>> hoursMapped = new List<Map<String, Datetime>>();

        for (HourWrapper h : hours) {
            Map<String, Datetime> tmp = new Map<String, Datetime>();

            tmp.put('openingTime', h.openingTime);
            tmp.put('closingTime', h.closingTime);

            hoursMapped.add(tmp);
        }

        return hoursMapped;
    }

    private static List<HourWrapper> generateOperatingHours(Datetime openingTime, Datetime closingTime) {
        List<HourWrapper> hours = new List<HourWrapper>();

        for (Datetime i = openingTime; i < closingTime; i = i.addMinutes(20)) {
            HourWrapper h = new HourWrapper();
            h.openingTime = i;
            h.closingTime = i.addMinutes(20);
            h.label = String.valueOf(h.openingTime.time()).substring(0, 5) + '  -  ' + String.valueOf(h.closingTime.time()).substring(0, 5);
            hours.add(h);
        }

        return hours;
    }

    private static Id getFacilityId(Id doctor) {
        List<Person__c> doc = [SELECT Medical_Facility__c FROM Person__c WHERE Id =: doctor];

        if(doc.size() != 1) {
            system.debug(doc);
            system.debug('Error while querying doctor');
            return null;
        }

        return doc[0].Medical_Facility__c;
    }

    private static List<Medical_Appointment__c> getExistingAppointments(Date selectedDate, Time openingTime, Time closingTime, Id selectedFacility) {
        return [SELECT Id, Appointment_Date__c 
                FROM Medical_Appointment__c 
                WHERE Appointment_Date__c >= :DateTime.newInstance(selectedDate, openingTime) 
                AND Appointment_Date__c < :DateTime.newInstance(selectedDate, closingTime) 
                AND Medical_Facility__c = :selectedFacility];
    }

    private static void removeConflictingHours(List<HourWrapper> hours, List<Medical_Appointment__c> existingAppointments) {
        for (Integer i = 0; i < hours.size(); i++) {
            for (Medical_Appointment__c appointment : existingAppointments) {
                Datetime appointmentTime = appointment.Appointment_Date__c;
                
                if (appointmentTime >= hours[i].openingTime && appointmentTime < hours[i].closingTime) {
                    hours.remove(i);
                    i--;
                    break;
                }
            }
        }
    }

    public static List<Operating_Hours__c> getAllHours(String selectedDay, Id selectedFacility) {
        return [SELECT Opening_Time__c, Closing_Time__c 
                FROM Operating_Hours__c 
                WHERE Day_of_Week__c = :selectedDay AND Medical_Facility__c = :selectedFacility
        ];
    }
}