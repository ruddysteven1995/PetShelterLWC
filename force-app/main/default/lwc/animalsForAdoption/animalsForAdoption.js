import { LightningElement, wire, api } from 'lwc';
import getAnimalsList from "@salesforce/apex/AnimalShelterController.getAnimalsList";
import { NavigationMixin } from "lightning/navigation";

export default class AnimalsForAdoption extends NavigationMixin(LightningElement) {
    
    animalsList;
    recordsToDisplay;
    totalRecords;
    currentPage = 1;
    recordsperpage = 8;
    totalPages = 1;

    statusOptions = [
        { label: 'All', value: 'AllStatus' },
        { label: 'Created', value: 'Created' },
        { label: 'Possible Candidate', value: 'Possible Candidate' },
        { label: 'Adopted', value: 'Adopted' }
    ]
    typeOptions = [
        { label: 'All', value: 'AllType' },
        { label: 'Dog', value: 'Dog' },
        { label: 'Cat', value: 'Cat' },
        { label: 'Rabbit', value: 'Rabbit' }
    ]
    filters = {};
    recordsFiltered;
    isFiltered = false;

    @wire(getAnimalsList)
    wiredAnimals({ data }) {
        if (data) {
            this.animalsList = data;
            this.recordsFiltered = this.animalsList;
            this.setRecordsToDisplay();
            this.sendEventToParent(this.animalsList);
        }
    }

    @api
    refreshList(newAnimal) {
        newAnimal = JSON.parse(JSON.stringify(newAnimal));
        let newData = [...this.animalsList];
        newData.unshift(newAnimal)
        this.animalsList = newData;
        this.recordsFiltered = newData;
        this.sortByFilter();
        this.sendEventToParent(newData);
    }

    sendEventToParent(animalsList) {
        this.dispatchEvent(
            new CustomEvent('sendanimalrecords', {
                detail: animalsList
            })
        );
    }

    handleViewMoreDetails(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                actionName: 'view',
            },
        });
    }

    setRecordsToDisplay() {
        if (this.animalsList && this.animalsList.length > 0) {
            this.totalRecords = this.recordsFiltered.length;
            this.currentPage = 1;
            this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
            this.preparePaginationList();
        }
    }

    preparePaginationList() {
        let begin = (this.currentPage - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        this.recordsToDisplay = this.recordsFiltered.slice(begin, end);
    }

    handleChangeFilter(event) {
        this.isFiltered = true;
        let value = event.target.value;
        let fieldName = event.target.name;
        
        this.filters[fieldName] = value
        this.sortByFilter();
    }

    sortByFilter() {
        let result = this.animalsList;
        for (const key in this.filters) {
            result = result.filter(item => {
                if ((this.filters[key]).includes('All')) {
                    return item
                } else {
                    return item[key] == this.filters[key]
                }
            });
        }
        this.recordsFiltered = result;
        this.setRecordsToDisplay();
    }

    handlePrevPage() {
        this.currentPage -= 1;
        this.preparePaginationList();
    }    

    handleNextPage() {
        this.currentPage += 1;
        this.preparePaginationList();
    }

    get disablePrevious(){ 
        return this.currentPage <= 1;
    }

    get disableNext(){ 
        return this.currentPage >= this.totalPages;
    }

    get showButtons() {
        let result = true;
        if (this.totalRecords <= 0 && !this.recordsFiltered) {
            result = false;
        }
        return result;
    }
}