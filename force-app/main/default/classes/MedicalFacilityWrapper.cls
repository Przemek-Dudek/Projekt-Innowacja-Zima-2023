public class MedicalFacilityWrapper {
    public String id;
    public String name;
    public Map<String, String> openingHours;
    public String phoneNumber;
    public List<String> address;
    
    @TestVisible
    public MedicalFacilityWrapper(String name, Map<String, String> hours, String phoneNumber, List<String> address, String id) {
        RESTMedicalFacilityExternal.HourWrapper hourWrapper = new RESTMedicalFacilityExternal.HourWrapper();
        this.id = id;
        this.name = name;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.openingHours = hours;
    }
}