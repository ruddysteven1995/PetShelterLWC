import { LightningElement } from 'lwc';
import getAllOrders from "@salesforce/apex/TableWithSearchController.getAllOrders";
import getAllOrdersLargeVolumeOfData from "@salesforce/apex/TableWithSearchController.getAllOrdersLargeVolumeOfData";


export default class ContainerSearchOrdersTable extends LightningElement {

    orderColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'TotalAmount', fieldName: 'TotalAmount', type: 'text'},
        { label: 'Status', fieldName: 'Status' }, 
        { label: 'PoNumber', fieldName: 'PoNumber' }, 
        { label: 'OrderReferenceNumber', fieldName: 'OrderReferenceNumber' }
    ];
    orderData;
    orderDataCustomSearch;

    connectedCallback() {
        this.handleGetOrderRecords();
        this.handleGetOrderRecordsCustomSearch();
    }

    handleGetOrderRecords() {
        getAllOrders()
        .then((result) => {
            this.changeSpinnerValue(true, 'orderTableSimpleSearch');
            this.orderData = result;
            this.template.querySelector('c-custom-table[data-id="orderTableSimpleSearch"]').recordData = this.orderData;
            this.template.querySelector('c-custom-table[data-id="orderTableSimpleSearch"]').originalData = this.orderData;
            this.refreshList('orderTableSimpleSearch');
            this.changeSpinnerValue(false, 'orderTableSimpleSearch');
        })
        .catch((error) => {
            this.orderData = undefined;
            console.log("###Error : " + JSON.stringify(error));
            this.changeSpinnerValue(false, 'orderTableSimpleSearch');
        })
    }

    changeSpinnerValue(value, id) {
        this.template.querySelector(`c-custom-table[data-id="${id}"]`).changeSpinner(value);
    }

    refreshList(id) {
        this.template.querySelector(`c-custom-table[data-id="${id}"]`).setRecordsToDisplay();
    }

    handleGetOrderRecordsCustomSearch(searchValueParam = null) {
        getAllOrdersLargeVolumeOfData({searchValue: searchValueParam})
        .then((result) => {
            this.changeSpinnerValueCustomSearch(true, 'orderTableCustomSearch');
            console.log('this is the result');
            console.log(result);
            this.orderDataCustomSearch = result;
            this.template.querySelector('c-custom-table-with-custom-search[data-id="orderTableCustomSearch"]').recordData = this.orderDataCustomSearch;
            // this.template.querySelector('c-custom-table-with-custom-search[data-id="orderTableCustomSearch"]').originalData = this.orderData;
            this.refreshListCustomSearch('orderTableCustomSearch');
            this.changeSpinnerValueCustomSearch(false, 'orderTableCustomSearch');
        })
        .catch((error) => {
            this.orderDataCustomSearch = undefined;
            console.log("###Error : " + JSON.stringify(error));
            this.changeSpinnerValueCustomSearch(false, 'orderTableCustomSearch');
        })
    }

    changeSpinnerValueCustomSearch(value, id) {
        this.template.querySelector(`c-custom-table-with-custom-search[data-id="${id}"]`).changeSpinner(value);
    }

    refreshListCustomSearch(id) {
        this.template.querySelector(`c-custom-table-with-custom-search[data-id="${id}"]`).setRecordsToDisplay();
    }

    handleCustomSearch(event) {
        console.log('from parent: ' + event.detail);
        this.handleGetOrderRecordsCustomSearch(event.detail);
    }
}