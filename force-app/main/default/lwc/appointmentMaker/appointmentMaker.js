import { LightningElement, wire, api, track } from 'lwc';

import getDoctorsBySpecialization from '@salesforce/apex/AppointmentController.getDoctorsBySpecialization';
import getSpecializations from '@salesforce/apex/AppointmentController.getSpecializations';

export default class AppointmentMaker extends LightningElement {
    //@api recordId;

    @track selectedSpecialization = '';
    @track doctors = [];
    @track specializationOptions = [];

    @wire(getSpecializations, {})
    getSpecializations({ data, error }) {
        if (data) {
            this.specializationOptions = data.map(item => {
                return {
                    label: item,
                    value: item
                };
            });
            this.error = undefined;
            console.log('Specialization Options:', this.specializationOptions);
        } else if (error) {
            this.error = error;
            this.specializationOptions = [];
            console.error('Error fetching specializations:', error);
        }
    }

    get specOptions() {
        return this.specializationOptions;
    }

    @wire(getDoctorsBySpecialization, { specialization: '$selectedSpecialization' })
    wiredDoctors({ error, data }) {
        if (data) {
            this.doctors = data.map(doctor => ({
                ...doctor,
                buttonLabel: `${doctor.First_Name__c} ${doctor.LastName__c}`
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.doctors = [];
            console.error('Error fetching doctors:', error);
        }
    }

    handleSpecializationChange(event) {
        this.selectedSpecialization = event.detail.value;
        console.log('Selected Specialization:', this.selectedSpecialization);
    }

    handleMouseOver(event) {
        const doctorId = event.target.dataset.key;
        const doctorIndex = this.doctors.findIndex(doc => doc.Id === doctorId);
        if (doctorIndex !== -1) {
            this.doctors[doctorIndex].buttonLabel = 'Make Appointment';
        }
    }

    handleMouseOut(event) {
        const doctorId = event.target.dataset.key;
        const doctorIndex = this.doctors.findIndex(doc => doc.Id === doctorId);
        if (doctorIndex !== -1) {
            this.doctors[doctorIndex].buttonLabel = `${this.doctors[doctorIndex].First_Name__c} ${this.doctors[doctorIndex].LastName__c}`;
        }
    }

    handleButtonClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__yourOtherLWC'
            }
        });
    }
}
