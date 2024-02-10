import { LightningElement, wire } from 'lwc';
import Modal from 'c/createNewAnimal';
import getDogBreedList from "@salesforce/apex/AnimalShelterController.getDogBreedList";
import getCustomSettings from "@salesforce/apex/AnimalShelterController.getCustomSettings";


export default class Container extends LightningElement {

    animalRecordId = '';
    detailRecordId = '';

    dogsBreedList;
    
    animalRecords;
    showEmptyHeader = true;
    isLoading = true;

    newAnimalCreated;

    defaultPhotoURL;

    @wire(getDogBreedList)
    wiredBreeds({ error, data }) {
        if (data) {
            this.dogsBreedList = data;
        } else if (error) {
            console.error(error)
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

    handleGetAnimalRecords(event) {
        this.animalRecords = event.detail;

        if (this.animalRecords && this.animalRecords.length > 1) {
            this.showEmptyHeader = false
        }
        this.isLoading = false;
    }

    handleCreateNewAnimal() {
        Modal.open({
            size: 'small',
            animalRecordId: this.recordId,
            detailRecordId: this.detailRecordId,
            dogsBreedList: this.dogsBreedList
        }).then((result) => {
            if (result) {
                this.isLoading = true;
                this.newAnimalCreated = result;
                this.newAnimalCreated.Photo_URL__c = this.defaultPhotoURL;
                this.template.querySelector("c-animals-for-adoption").refreshList(this.newAnimalCreated);
            }
        });
    }
}