import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import PHOTO_FIELD from "@salesforce/schema/Animal__c.Photo_URL__c";
import getCustomSettings from "@salesforce/apex/AnimalShelterController.getCustomSettings";


export default class ImagePreviewer extends LightningElement {
    
    @api recordId;
    record;
    photoURL;
    defaultPhotoURL;
    isLoading = true;
    
    @wire(getRecord, { recordId: '$recordId', fields: [PHOTO_FIELD], modes: 'View'})
      wiredRecord({ error, data }) {
        if (data) {
            this.record = data;
            this.photoURL = this.record.fields.Photo_URL__c.value;    
            this.isLoading = false;  
        } else if (error) {
          console.error(error);
        }
    }

    connectedCallback() {
        if (!this.defaultPhotoURL) {
            this.handleCustomSettings();
        }
    }

    handleCustomSettings() {
      getCustomSettings()
        .then((result) => {
          this.defaultPhotoURL = result.Default_Image_Url__c;
        })
        .catch((error) => {
          console.error(error);
        });
    }

    get imageURL() {
      return this.recordId && this.photoURL ? this.photoURL : this.defaultPhotoURL;
    }
}