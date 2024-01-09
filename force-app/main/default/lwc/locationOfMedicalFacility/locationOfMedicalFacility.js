import { LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue } from "lightning/uiRecordApi";

import City from "@salesforce/schema/Medical_Facility__c.City__c";
import Street_Name from "@salesforce/schema/Medical_Facility__c.Street_Name__c";
import Street_Number from "@salesforce/schema/Medical_Facility__c.Street_Number__c";
import Post_Code from "@salesforce/schema/Medical_Facility__c.Postcode__c";
import name from "@salesforce/schema/Medical_Facility__c.Name";
import fac_type from "@salesforce/schema/Medical_Facility__c.Type__c";

export default class LocationOfMedicalFacility extends LightningElement {
    @api recordId;
    

    @wire(getRecord, { recordId: '$recordId', 
    optionalFields: [City, Street_Name, Street_Number, Post_Code],
    })
    facility; 

    get city(){
        return getFieldValue(this.facility.data, City);
    }

    get street(){
        return getFieldValue(this.facility.data, Street_Name) + ' ' + getFieldValue(this.facility.Street_Number, Street_Number);
    }

    get postCode(){
        return getFieldValue(this.facility.data, Post_Code);
    }

    get facilityName(){
        return getFieldValue(this.facility.data, name);
    }

    get desc(){
        return getFieldValue(this.facility.data, fac_type);
    }

    get mapMarkers() {
        const my_city = this.city;
        const my_street = this.street;
        const my_post_code = this.postCode;
        const fac_name = this.facilityName;
        const desc = this.desc;
        if(this.facility.data){
            return [
                {
                    location: {
                        City: my_city,
                        Street: my_street,
                        PostalCode: my_post_code,
                    },
                   
                },
            ];
        }
        return [];
    }

    zoomLevel = 15;
}