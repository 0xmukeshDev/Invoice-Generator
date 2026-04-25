import { LightningElement, api, track, wire } from 'lwc';
import getOpportunityWithProducts from '@salesforce/apex/InvoiceController.getOpportunityWithProducts';
import createInvoice from '@salesforce/apex/InvoiceController.createInvoice';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import generateAndAttachPdf from '@salesforce/apex/InvoiceController.generateAndAttachPdf';
export default class CreateInvoice extends NavigationMixin(LightningElement) {
    @api recordId; 
    isStep1 = true;
    isStep2 = false;
    @track lineItems = [];
    isLoading = false;
    currentStep = 'step1';

    //Gets Opportunity Products details
     @wire(getOpportunityWithProducts, { oppId: '$recordId' })
    wiredOpp({ data, error }) {
        this.isLoading = true;
        if (data) {
            this.lineItems = (data.OpportunityLineItems || []).map(item => {
                return {
                    productId: item.PricebookEntry.Product2Id,
                    productName: item.PricebookEntry.Product2.Name,
                    quantity: item.Quantity,
                    price: item.UnitPrice,
                    total: item.Quantity * item.UnitPrice
                };
            });
            this.isLoading = false;
            console.log('lineItems', this.lineItems);
        } else if (error) {
            this.isLoading = false;
             this.showToastMessage("Error",error.body?.message || "Something went wrong", "error")
            console.error(error);
        }
    }
    
    handleNext() {
        this.isStep1 = false;
        this.isStep2 = true;
        this.currentStep = 'step2';
    }
    handleBack() {
        this.isStep1 = true;
        this.isStep2 = false;
        this.currentStep = 'step1';
    }
    handleQtyChange(event) {
        const index = event.target.dataset.index;
        this.lineItems[index].quantity = event.target.value;
        this.calculateRow(index);
    }
    handlePriceChange(event) {
        const index = event.target.dataset.index;
        this.lineItems[index].price = event.target.value;
        this.calculateRow(index);
    }
    calculateRow(index){
        let item = this.lineItems[index];
        item.total = item.quantity * item.price;
        this.lineItems = [...this.lineItems];
    }
    get totalAmount() {
        return this.lineItems.reduce((sum, item) => sum + item.total, 0);
    }

    //Invoice creation and genrating the PDF
    handleSave() {
        this.isLoading = true;

        if (!this.validateInputFields()) {
            this.isLoading = false;
            return; 
        }
        let lines = this.lineItems.map(item => {
            return {
                Product__c: item.productId,
                Quantity__c: item.quantity,
                Price__c: item.price,
                Total__c: item.total
            };
        });
        console.log("oppid", this.recordId, JSON.stringify(lines));
       
        
        createInvoice({ oppId: this.recordId, lines: lines, totalAmt: this.totalAmount })
        .then(invId => {

            return generateAndAttachPdf({ invoiceId: invId })
                .then(fileId => {
                    console.log('FileId:', fileId);
            this.isLoading = false;
            console.log("invId", invId);

            // const pdfUrl = `/apex/InvoicePDF?id=${invId}`;
            //     window.open(pdfUrl, '_blank');

            const downloadUrl = `/sfc/servlet.shepherd/version/download/${fileId}`;
            window.open(downloadUrl, '_blank');
            this.showToastMessage("Success","Invoice Created", "success")
            
            // Navigate
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: invId,
                    objectApiName: 'Invoice__c',
                    actionName: 'view'
                }
                });
            });
        })
        .catch(error => {
            this.isLoading = false;
            this.showToastMessage("Error",error.body?.message || "Something went wrong", "error")
            console.error("error");
        });
    }

    showToastMessage(title, message,variant){
        this.dispatchEvent(
                new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: variant
                })
            );
    }

    validateInputFields(){
        const allInputs = this.template.querySelectorAll('lightning-input');

        let isValid = true;

        allInputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        return isValid
    }
}