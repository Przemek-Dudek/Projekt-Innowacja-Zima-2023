import { LightningElement, wire, api, track } from 'lwc';

import getDoctorsBySpecialization from '@salesforce/apex/AppointmentController.getDoctorsBySpecialization';
import getSpecializations from '@salesforce/apex/AppointmentController.getSpecializations';

export default class AppointmentMaker extends LightningElement {
    //@api recordId;

    @track selectedSpecialization = '';
    @track doctors = [];
    @track specializationOptions = [];
    @track selectedDoctor;
    @track selectedDay;
    @track isHourAvailable;

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
                buttonLabel: `${doctor.First_Name__c} ${doctor.LastName__c}`,
                clicked: 0
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
        this.selectedDoctor = null;
    }

    handleMouseOver(event) {
        const doctorId = event.target.dataset.key;
        const doctorIndex = this.doctors.findIndex(doc => doc.Id === doctorId);
        if (doctorIndex !== -1) {
            if(this.doctors[doctorIndex].clicked === 0) {
                this.doctors[doctorIndex].variant = 'brand';
            }
        }
    }

    handleMouseOut(event) {
        const doctorId = event.target.dataset.key;
        const doctorIndex = this.doctors.findIndex(doc => doc.Id === doctorId);
        if (doctorIndex !== -1) {
            if(this.doctors[doctorIndex].clicked === 0) {
                this.doctors[doctorIndex].variant = 'neutral';
            }
        }
    }

    handleButtonClick(event) {
        const doctorId = event.target.dataset.key;
        const doctorIndex = this.doctors.findIndex(doc => doc.Id === doctorId);
        if (doctorIndex !== -1) {
            if(this.doctors[doctorIndex].clicked === 0) {
                if(this.doctors[doctorIndex].Medical_Facility__r !== undefined) {
                    this.doctors.forEach((doc, index) => {
                        this.doctors[index].clicked = 0;
                        this.doctors[index].variant = 'neutral';
                    });
    
                    this.doctors[doctorIndex].variant = 'success';
                    this.doctors[doctorIndex].clicked = 1;
                    this.selectedDoctor = this.doctors[doctorIndex].Id;
                    this.isHourAvailable = this.selectedDay && this.selectedDoctor;
                } else {
                    this.doctors.forEach((doc, index) => {
                        this.doctors[index].variant = 'neutral';
                    });

                    this.doctors[index].variant = 'destructive';
                    this.selectedDoctor = null;
                    this.isHourAvailable = this.selectedDay && this.selectedDoctor;
                }
                
            } else {
                this.doctors[doctorIndex].variant = 'neutral';
                this.doctors[doctorIndex].clicked = 0;
                this.selectedDoctor = null;
                this.isHourAvailable = this.selectedDay && this.selectedDoctor;
            }
            //do zrobienia handel
        }
    }

    handleDayChange(event) {
        const selectedDate = new Date(event.target.value);
        
        const dayOfWeekNumber = selectedDate.getDay();
    
        const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        this.selectedDay = daysOfWeek[dayOfWeekNumber];
        this.isHourAvailable = this.selectedDay && this.selectedDoctor;
    }
}
