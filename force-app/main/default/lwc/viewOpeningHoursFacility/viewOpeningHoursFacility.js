import { LightningElement, api, wire } from 'lwc';
import getHours from '@salesforce/apex/OpeningHoursController.getHours';

export default class ViewOpeningHoursFacility extends LightningElement {
    @api recordId;

    hours;

    @wire(getHours, { facilityId: '$recordId' })
    getHours({ error, data }) {
        if (data) {
            this.hours = data.map(hour => {
                const openingTime = new Date(hour.Opening_Time__c - 3600000);
                const closingTime = new Date(hour.Closing_Time__c - 3600000);
                return { ...hour, Opening_Time__c: openingTime.toLocaleTimeString(), Closing_Time__c: closingTime.toLocaleTimeString() };
            });
        } else if (error) {
            console.error(JSON.stringify(error));
        }
    }
}
