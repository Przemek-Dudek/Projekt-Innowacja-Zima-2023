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
                WHERE RecordType.DeveloperName = 'Doctor' AND Specialization__c = :specialization
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getSpecializations() {
        List<String> specializationsList = new List<String>();

        Schema.DescribeFieldResult fieldDescribe = Person__c.Specialization__c.getDescribe();

        if (fieldDescribe != null && fieldDescribe.getPicklistValues() != null) {
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();

            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                specializationsList.add(picklistEntry.getLabel());
            }
        }

        return specializationsList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Datetime>> getAvailableHours(Datetime selectedDate, Id selectedDoctor) {
        System.debug('selectedDate: ' + selectedDate + 'selectedDoctor: ' + selectedDoctor);

        Id selectedFacility = getFacilityId(selectedDoctor);
        String dayOfWeek = selectedDate.format('EEEE');

        List<Operating_Hours__c> operatingTime = getAllHours(dayOfWeek, selectedFacility);

        if (operatingTime.size() != 1) {
            system.debug('Error while querying allHours');
            return null;
        }

        List<HourWrapper> hours = generateOperatingHours(Datetime.newInstance(selectedDate.date(), operatingTime[0].Opening_Time__c), Datetime.newInstance(selectedDate.date(), operatingTime[0].Closing_Time__c));

        List<Medical_Appointment__c> existingAppointments = getExistingAppointments(selectedDate, selectedDoctor);

        removeConflictingHours(hours, existingAppointments);

        System.debug(existingAppointments);

        List<Map<String, Datetime>> hoursMapped = new List<Map<String, Datetime>>();

        for (HourWrapper h : hours) {
            Map<String, Datetime> tmp = new Map<String, Datetime>();

            tmp.put('openingTime', h.openingTime);
            tmp.put('closingTime', h.closingTime);

            hoursMapped.add(tmp);
        }

        return hoursMapped;
    }

    @AuraEnabled(cacheable=true)
    public static List<Person__c> getPatients() {
        return [SELECT Id, First_Name__c, LastName__c
                FROM Person__c
                WHERE RecordType.DeveloperName = 'Patient'
        ];
    }

    public class AppointmentWrapper {
        public String doctorId;
        public Datetime hour;
        public String patientId;
    }

    @AuraEnabled(cacheable=false)
    public static void makeAppointment(String appointmentDataString) {
        try {
            AppointmentWrapper appointmentData = (AppointmentWrapper) JSON.deserialize(appointmentDataString, AppointmentWrapper.class);
            
            System.debug(appointmentData);

            Medical_Appointment__c newAppointment = new Medical_Appointment__c();

            newAppointment.Doctor__c = (Id) appointmentData.doctorId;
            newAppointment.Appointment_Date__c = appointmentData.hour;
            newAppointment.Patient__c = (Id) appointmentData.patientId;

            System.debug(newAppointment);

            insert newAppointment;

            System.debug(newAppointment);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
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

    private static List<Medical_Appointment__c> getExistingAppointments(Datetime selectedDate, Id selectedDoctor) {
        return [SELECT Id, Appointment_Date__c 
                FROM Medical_Appointment__c 
                WHERE DAY_ONLY(Appointment_Date__c) = :selectedDate.date()
                AND Doctor__c = :selectedDoctor];
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