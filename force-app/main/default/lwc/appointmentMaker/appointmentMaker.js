import { LightningElement, wire, api, track } from 'lwc';

import getDoctorsBySpecialization from '@salesforce/apex/AppointmentController.getDoctorsBySpecialization';
import getSpecializations from '@salesforce/apex/AppointmentController.getSpecializations';
import getAvailableHours from '@salesforce/apex/AppointmentController.getAvailableHours';
import getPatients from '@salesforce/apex/AppointmentController.getPatients';
import makeAppointment from '@salesforce/apex/AppointmentController.makeAppointment';

export default class AppointmentMaker extends LightningElement {
    @track selectedSpecialization = '';
    @track doctors = [];
    @track specializationOptions = [];
    @track selectedDoctor = null;
    @track selectedDate = null;
    @track isHourAvailable;
    @track selectedHour;
    @track availableHours;
    @track patientOptions;
    @track selectedPatient;

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

    // get getSpecOptions() {
    //     return this.specializationOptions;
    // } wywalic

    // get getHourOptions() {
    //     return this.availableHours;
    // }

    // get getPatientOptions() {
    //     return this.patientOptions;
    // }

    // get getSelectedSpec() {
    //     return this.selectedSpecialization;
    // }

    // get getSelectedHour() {
    //     return this.selectedHour;
    // }

    // get getSelectedPatient() {
    //     return this.selectedPatient;
    // }

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

    @wire(getAvailableHours, { selectedDate: '$selectedDate', selectedDoctor: '$selectedDoctor' })
    wiredHours({ error, data }) {
        if (data) {
            this.availableHours = data.map(item => ({
                    label: item.openingTime.toString().substr(11, 5) + ' - ' + item.closingTime.toString().substr(11, 5),
                    value: item.openingTime
            })); //Nawias zwraca return niepotrzebny
            console.log('Hours: ', data);
        } else if (error) {
            this.availableHours = [];
            console.error('Error:', error);
        }
    }

    @wire(getPatients)
    wiredPatients({ error, data }) {
        if (data) {
            this.patientOptions = data.map(patient => ({
                value: patient.Id,
                label: `${patient.First_Name__c} ${patient.LastName__c}`
            }));
            console.log("Pacjenci: ", this.patientOptions);
        } else if (error) {
            this.error = error;
            this.patientOptions = [];
            console.error('Error fetching patients:', error);
        }
    }

    handleSpecializationChange(event) {
        this.selectedSpecialization = event.detail.value;
    }

    handlePatientChange(event) {
        this.selectedPatient = event.detail.value;
        console.log(this.selectedPatient);
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
        const doctorIndex = this.doctors.findIndex(doc => doc.Id === doctorId); //find zamiast find index
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
                    this.selectedFacility = this.doctors[doctorIndex].Medical_Facility__r.Id;
                    this.isHourAvailable = this.selectedDate && this.selectedDoctor;
                } else {
                    this.doctors.forEach((doc, index) => {
                        this.doctors[index].variant = 'neutral';
                    });

                    this.doctors[index].variant = 'destructive';
                    this.destroySelected();
                }
                
            } else {
                this.doctors[doctorIndex].variant = 'neutral';
                this.doctors[doctorIndex].clicked = 0;
                this.destroySelected();
            }
        }
    }

    destroySelected() {
        this.selectedDoctor = null;
        this.selectedHour = null;
        this.isHourAvailable = this.selectedDate && this.selectedDoctor;
    }

    handleDayChange(event) {
        this.selectedDate = new Date(event.target.value);

        console.log(this.selectedDate);

        this.isHourAvailable = this.selectedDate && this.selectedDoctor;
    }

    handleHourChange(event) {
        this.selectedHour = event.detail.value;
    }

    handleCancel() {
        this.showComponent = false;
        history.back();
    }

    handleSave() {
        if (!this.selectedDoctor || !this.selectedDate || !this.selectedHour || !this.selectedPatient) {
            console.error('Please fill in all required fields before saving.');
            return;
        }

        const appointmentData = { //required field
            doctorId: this.selectedDoctor.toString(),
            hour: this.selectedHour.toString(),
            patientId: this.selectedPatient.toString()
        };

        const appointmentDataString = JSON.stringify(appointmentData);

        console.log('AD: ', appointmentData);
        console.log('ADS: ', appointmentDataString);

        makeAppointment({ appointmentDataString: appointmentDataString })
            .then(result => {
                console.log('Appointment created successfully:', result);

                this.dispatchEvent(new CustomEvent('closemodal'));
            })
            .catch(error => {
                console.error('Error creating appointment:', error);
            });

        this.handleCancel();
    }
}