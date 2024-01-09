trigger TriggerHandler_MedicalAppointment on Medical_Appointment__c (after insert, after update, before insert) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            MedicalAppointmentHandler.handleFirstInternistAppointmentONSITE(Trigger.new);
        }
        
    }
    else if(Trigger.isAfter){
        if(Trigger.isUpdate){
            MedicalAppointmentHandler.handleUpdateOrNewAppointment(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
        }
        else if (Trigger.isInsert){
            MedicalAppointmentHandler.handleUpdateOrNewAppointment(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
        }
    }
}