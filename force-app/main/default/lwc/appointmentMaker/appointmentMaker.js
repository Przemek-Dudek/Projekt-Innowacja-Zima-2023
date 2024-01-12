import { LightningElement, wire, api } from 'lwc';
import getDoctorsByFacility from '@salesforce/apex/AppointmentController.getDoctorsByFacility';

export default class AppointmentMaker extends LightningElement {
    @api recordId;
    doctors;

    @wire(getDoctorsByFacility, { facilityId: '$recordId' })
    wiredDoctors({ error, data }) {
        if (data) {
            this.doctors = data;
        } else if (error) {
            console.error('Error fetching doctors:', error);
        }
    }
}