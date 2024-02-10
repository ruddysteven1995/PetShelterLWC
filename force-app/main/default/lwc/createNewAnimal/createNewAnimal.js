import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import Toast from 'lightning/toast';


export default class CreateNewAnimal extends LightningModal {

    @api animalRecordId;
    animalObjectApiName = 'Animal__c';
    animalFields =['Name__c', 'Status__c', 'Type__c', 'Age_Range__c', 'Sex__c', 'Color__c', 'Size__c'];

    showDogBreed = false;
    @api dogsBreedList;
    dogBreedSelected;

    @api detailRecordId;
    detailObjectApiName = 'Animal_Detail__c';
    detailFields =['Observations__c', 'Special_Observations__c', 'Presentation__c'];

    newAnimalData = {};

    get title() {
        return this.recordId ? 'Edit Animal' : 'Register New Animal';
    }

    handleFieldChange(event) {
        let value = event.target.value;
        let fieldName = event.target.fieldName;
        if (fieldName == 'Type__c') {
            if (value == 'Dog') {
                this.showDogBreed = true;
            } else if (value) {
                this.showDogBreed = false;
            }
        }
    }

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        if (fields.Type__c == 'Dog') {
            fields.Breed__c = this.dogBreedSelected;
        }
        this.template.querySelector('lightning-record-edit-form[data-id="animalForm"]').submit(fields);
    }

    handleSuccessAnimal(event){
        event.preventDefault();
        if (event.detail.apiName == 'Animal__c') {
            let id = event.detail.id

            for (let key in event.detail.fields) {
                if (key.includes('__c')) {
                    this.newAnimalData[key] = event.detail.fields[key].value
                }
            }
            this.newAnimalData['Id'] = id;
            
            this.template.querySelectorAll('lightning-input-field[data-id="animalId"]').forEach((field) => {
                field.value = id;
            });
            
            if (this.template.querySelectorAll('lightning-input-field[data-id="detailFields"]')) {
                let detailFields = {};
                this.template.querySelectorAll('lightning-input-field[data-id="detailFields"]').forEach((field) => {
                    detailFields[field.fieldName] = field.value;
                });
                this.newAnimalData['Animal_Details__r'] = [detailFields];
            }
            
            this.template.querySelectorAll('lightning-record-edit-form[data-id="detailForm"]')
            .forEach((form) => {
                form.submit();
            });
    
            this.showToast('Success!', 'Animal Registered Successfully', 'success');
            this.close(this.newAnimalData);
        }
    }

    handleError(event){
        let message = event.detail.detail;
        this.showToast('Error', message ? message : 'Error Saving record', 'error');
        this.close('Error: ' + message);
    }

    handleChangeComboBox(event) {
        this.dogBreedSelected = event.detail.value;
    }

    handleCancel() {
        this.close();
    }

    showToast(label, message, variant) {
        Toast.show({
            label: label,
            message: message,
            mode: 'sticky',
            variant: variant
        }, this);
    }
}