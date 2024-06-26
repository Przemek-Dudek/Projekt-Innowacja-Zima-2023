public class RESTMedicalFacilityExternal {
    //zwracanie voida
    public static Map<Medical_Facility__c, List<Operating_Hours__c>> makeGetMedicalFacilities() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer '+getToken());
        request.setEndpoint('https://cw-inn--inta.sandbox.my.salesforce.com/services/apexrest/Medical_Facility__c');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        Map<Medical_Facility__c, List<Operating_Hours__c>> medicalFacilitesWithOpeningHours = new Map<Medical_Facility__c, List<Operating_Hours__c>>();
        if(response.getStatusCode() == 200) {
            try {
                List<MedicalFacilityWrapper> receivedFacilities = (List<MedicalFacilityWrapper>)JSON.deserialize(response.getBody(), List<MedicalFacilityWrapper>.class);
                for(MedicalFacilityWrapper receivedfacility : receivedFacilities) {
                    Medical_Facility__c medicalFacility = new Medical_Facility__c();
                    medicalFacility.City__c = receivedfacility.address[0];
                    medicalFacility.Street_Name__c = receivedfacility.address[1];
                    medicalFacility.Street_Number__c = Integer.valueOf(receivedfacility.address[2].split('/')[0]);
                    medicalFacility.Postcode__c = receivedfacility.address[3];
                    medicalFacility.Name = receivedfacility.name;
                    medicalFacility.External_ID__c = receivedfacility.id;
                    HourWrapper openingHours = new HourWrapper();
                    Map<String, HourWrapper> dayHours = openingHours.getHours(receivedfacility.openingHours);
                    //medicalFacility.Opening_Hours__c = openingHours.openingHour;
                    //medicalFacility.Phone__c = receivedfacility.phone;
                    List<Operating_Hours__c> operatingHours = new List<Operating_Hours__c>();
                    for(String day : dayHours.keySet()) {
                        Operating_Hours__c operatingHour = new Operating_Hours__c();
                        operatingHour.Day_of_Week__c = day;
                        //new
                        operatingHour.Week_Day__c = day;
                        operatingHour.Opening_Time__c = dayHours.get(day).openingHour;
                        operatingHour.Closing_Time__c = dayHours.get(day).closingHour;
                        operatingHours.add(operatingHour);
                    }
                    medicalFacilitesWithOpeningHours.put(medicalFacility, operatingHours);
                } 
            } catch(JSONException e){
                return medicalFacilitesWithOpeningHours;
            }
        }
        return medicalFacilitesWithOpeningHours;
    }
    public class HourWrapper {
        public Time openingHour;
        public Time closingHour;
        public HourWrapper() {
            this.openingHour = null;
            this.closingHour = null;
        }
        public HourWrapper(Time openingHour, Time closingHour) {
            this.openingHour = openingHour;
            this.closingHour = closingHour;
        }
        public HourWrapper(String openingTime){
            Integer[] hours= new Integer[2];
            Integer[] minutes= new Integer[2];
            for (String half : openingTime.split('-')) {
                hours.add(Integer.valueOf(half.split(':')[0]));
                minutes.add(Integer.valueOf(half.split(':')[1]));
            }
            this.openingHour = Time.newInstance(hours[0],minutes[0],0,0);
            this.closingHour = Time.newInstance(hours[1],minutes[1],0,0);
        }
        
        public Map<String, HourWrapper> getHours(Map<String, String> hoursMap) {
            Map<String, HourWrapper> openingHours = new Map<String, HourWrapper>();
            for (String day : hoursMap.keySet()) {
                String hourInString = hoursMap.get(day);
                Integer[] hours= new Integer[0];
                Integer[] minutes= new Integer[0];
                for (String half : hourInString.split('-')) {
                    hours.add(Integer.valueOf(half.split(':')[0]));
                    minutes.add(Integer.valueOf(half.split(':')[1]));
                }
                openingHours.put(day, new HourWrapper(Time.newInstance(hours[0],minutes[0],0,0), Time.newInstance(hours[1],minutes[1],0,0)));
            }
            return openingHours;
        }
    }
    
    public static String getToken(){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String clientId = '3MVG9Lu3LaaTCEgJ1gvddPIi1T5utERHWaDc6X7KsGl4WyYla265OOHwHod.ZQbfj62uw56a.QdS1iYC6TdV6';
        String clientSecret = '86399BB82656729E0E3A37CC6F7A6D189B9836F8899E2FF3A06750B6F2F27BEE';
        String body = 'grant_type=client_credentials&client_id='+clientId+'&client_secret='+clientSecret;
        request.setEndpoint('https://cw-inn--inta.sandbox.my.salesforce.com/services/oauth2/token');
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if(response.getStatusCode() == 200){
        String token = (String)results.get('access_token');
        return token;
        }else{
                 throw new CalloutException('FAILED TO GET TOKEN');
        }
    }
}