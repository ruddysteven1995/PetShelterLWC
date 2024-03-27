import { LightningElement, api } from 'lwc';

export default class CustomTableWithCustomSearch extends LightningElement {
    @api columns;
    @api recordData;
    // @api originalData;
    loadData= true;
    showButtons = false;

    recordsToDisplay;
    totalRecords;
    currentPage = 1;
    recordsperpage = 10;
    totalPages = 1;

    searchInputValue;

    @api 
    changeSpinner(value){
        this.loadData = value;
    }

    @api
    setRecordsToDisplay() {
        if (this.recordData && this.recordData.length > 0) {
            this.totalRecords = this.recordData.length;
            this.currentPage = 1;
            this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
            this.preparePaginationList();
        } else {
            this.recordsToDisplay = [];
        }
        this.showButtons = true;
    }

    preparePaginationList() {
        let begin = (this.currentPage - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        this.recordsToDisplay = this.recordData.slice(begin, end);
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

    handleSearchInputChange(event) {
        this.searchInputValue = event.target.value;
    }

    handleSearch() {
        if (this.searchInputValue) {
            this.dispatchEvent(
                new CustomEvent('searchvalue', {
                    detail: this.searchInputValue
                })
            );
        }
    }
}