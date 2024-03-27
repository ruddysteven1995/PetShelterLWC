import { LightningElement, api } from 'lwc';

export default class CustomTable extends LightningElement {
    @api columns;
    @api recordData;
    @api originalData;
    @api sortedBy;
    @api sortedDirection;
    loadData= true;
    showButtons = false;

    recordsToDisplay;
    totalRecords;
    currentPage = 1;
    recordsperpage = 10;
    totalPages = 1;

    @api doSearch = false;

    onHandleSort(event) {
        this.loadData= true;
        this.showButtons = false;
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.recordsToDisplay = [];
        this.dispatchSortEvent();
    }

    dispatchSortEvent() {
        this.dispatchEvent(
            new CustomEvent('sortrecords', {
                detail: {
                    sortedBy: this.sortedBy,
                    sortedDirection: this.sortedDirection
                }
            })
        );
    }

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
        let regex = new RegExp(event.target.value,'gi')
        let filterData = this.originalData.filter(item => {
            for (let key in item) {
                if (key != 'Id' && regex.test(item[key])) {
                    return item;
                }
             }
        });

        this.recordData = filterData;
        if (filterData && filterData.length > 0) {
            this.setRecordsToDisplay();
        } else {
            this.recordsToDisplay = [];
        }
    }
}