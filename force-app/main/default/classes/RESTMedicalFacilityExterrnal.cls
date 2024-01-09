public class RESTMedicalFacilityExternal {
    //zwracanie voida
    public static void makeGetMedicalFacilities() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://cw-inn--inta.sandbox.my.salesforce.com/services/apexrest/Medical_Facility__c');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        Medical_Facility__c facilities= new Medical_Facility__c();
        if(response.getStatusCode() == 200) {
            List<Map<String, Object>> results = (List<Map<String, Object>>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> hours = (Map<String, Object>) results.get('openingHours');
            List<String> address = (List<Object>) results.get('address');

        } 
        
    }
}