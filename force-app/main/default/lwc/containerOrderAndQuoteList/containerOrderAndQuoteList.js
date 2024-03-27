import { LightningElement, wire, api } from 'lwc';
import getOrderListByAccount from "@salesforce/apex/OrderAndQuotesController.getOrderListByAccount";
import getQuoteListByAccount from "@salesforce/apex/OrderAndQuotesController.getQuoteListByAccount";
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = ['Account.Id', 'Account.Name'];


export default class ContainerOrderAndQuoteList extends LightningElement {
    @api recordId;
    accountData;

    orderColumns = [
        { label: 'Order Number', fieldName: 'OrderNumber', sortable: true },
        { label: 'Status', fieldName: 'Status', type: 'text', sortable: true },
        { label: 'Account Name', fieldName: 'Account.Name' }
    ];
    orderData;
    orderSortedBy = 'OrderNumber';
    orderSortedDirection = 'ASC';

    quoteColumns = [
        { label: 'Quote Number', fieldName: 'QuoteNumber', sortable: true },
        { label: 'Status', fieldName: 'Status', type: 'text', sortable: true },
        { label: 'Account Name', fieldName: 'Account.Name' }
    ];
    quoteData;
    quoteSortedBy = 'QuoteNumber';
    quoteSortedDirection = 'ASC';

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    getAccountData(result) {
        if (result.data) {
            this.accountData = result.data
            this.handleGetOrderRecords();
            this.handleGetQuoteRecords();
        }
    }

    handleGetOrderRecords() {
        getOrderListByAccount({ accountId: this.accountData.fields.Id.value, orderBy: this.orderSortedBy, direction: this.orderSortedDirection })
        .then((result) => {
            this.changeSpinnerValue(true, 'orderTable');
            let ordersArray = [];
            for (let row of result) {
                const flattenedRow = {}
                let rowKeys = Object.keys(row); 
                rowKeys.forEach((rowKey) => {
                    const singleNodeValue = row[rowKey];
                    if(singleNodeValue.constructor === Object){
                        this.flatten(singleNodeValue, flattenedRow, rowKey)        
                    }else{
                        flattenedRow[rowKey] = singleNodeValue;
                    }
                    
                });
                ordersArray.push(flattenedRow);
            }
            this.changeSpinnerValue(false, 'orderTable');
            this.orderData = ordersArray;
            this.template.querySelector('c-custom-table[data-id="orderTable"]').recordData = this.orderData;
            this.refreshList('orderTable');
        })
        .catch((error) => {
            this.orderData = undefined;
            console.log("###Error : " + JSON.stringify(error));
            this.changeSpinnerValue(false, 'orderTable');
        })
    }
    
    changeSpinnerValue(value, id) {
        this.template.querySelector(`c-custom-table[data-id="${id}"]`).changeSpinner(value);
    }

    refreshList(id) {
        this.template.querySelector(`c-custom-table[data-id="${id}"]`).setRecordsToDisplay();
    }

    // This method will help to flat the data
    flatten = (nodeValue, flattenedRow, nodeName) => {
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

    handleSortOrderRecords(event) {
        this.orderSortedBy = event.detail.sortedBy;
        this.orderSortedDirection = event.detail.sortedDirection;
        this.handleGetOrderRecords();
    }

    handleSortQuoteRecords(event) {
        this.quoteSortedBy = event.detail.sortedBy;
        this.quoteSortedDirection = event.detail.sortedDirection;
        this.handleGetQuoteRecords();
    }

    handleGetQuoteRecords() {
        getQuoteListByAccount({ accountId: this.accountData.fields.Id.value, orderBy: this.quoteSortedBy, direction: this.quoteSortedDirection })
        .then((result) => {
            this.changeSpinnerValue(true, 'quoteTable');
            let quotesArray = [];
            for (let row of result) {
                const flattenedRow = {}
                let rowKeys = Object.keys(row); 
                rowKeys.forEach((rowKey) => {
                    const singleNodeValue = row[rowKey];
                    if(singleNodeValue.constructor === Object){
                        this.flatten(singleNodeValue, flattenedRow, rowKey)        
                    }else{
                        flattenedRow[rowKey] = singleNodeValue;
                    }
                    
                });
                quotesArray.push(flattenedRow);
            }
            this.changeSpinnerValue(false, 'quoteTable');
            this.quoteData = quotesArray;
            this.template.querySelector('c-custom-table[data-id="quoteTable"]').recordData = this.quoteData;
            this.refreshList('quoteTable');
        })
        .catch((error) => {
            this.quoteData = undefined;
            console.log("###Error : " + JSON.stringify(error));
            this.changeSpinnerValue(false, 'quoteTable');
        })
    }

}