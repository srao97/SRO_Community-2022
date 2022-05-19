import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import validateRequest from '@salesforce/apex/PaymentRegenerationRequest.validateRequest';
import createPaymentRequest from '@salesforce/apex/PaymentRegenerationRequest.createPaymentRequest';
import UTITLITY_ICONS from '@salesforce/resourceUrl/UtilityIcons';

export default class PaymentRegenerationRequest extends LightningElement {

    @api regenerate = false;
    @api validationError = false;
    @api paymentRecordCreated = false;
    @api showError = false;
    @api paymentId;
    errorMessage;
    @api recordId;
    errorIconUrl = UTITLITY_ICONS + '/icons/error.png';
    warningIconUrl = UTITLITY_ICONS + '/icons/warning.png';
    @api errorList = [];

    //Had to use this to get the RecordId, as there is a few seconds delay arghhhhh
    @wire(CurrentPageReference)
      currentPage;

    //Actions to perform on Component Load.
    connectedCallback() {
        validateRequest({
            paymentRecId: this.currentPage.state.recordId
        })
        .then(response => {
            console.log('response', response);
            const result = JSON.parse(response);
            console.log(result);
            if(result.errors.length > 0)
            {
                console.log('there are errors');
                this.errorList = JSON.parse(result.errors);
                this.validationError = true;

            }
            else
            {
                console.log('there are no errors');
                this.regenerate = true;
            }
        })
        .catch(error => {
            console.log('something went wrong' , JSON.stringify(error));
            this.showError = true
            this.errorMessage = error.body.message;
        })
    }
    
    generatePaymentRequest() {
        createPaymentRequest({ 
            paymentRecId: this.currentPage.state.recordId
        })
        .then(response => {
            console.log('payment is registered');
            console.log(response);
            
            this.paymentId = response.Name;
            this.paymentRecordCreated = true;
            this.regenerate = false;
            console.log('paymentId' + this.paymentId);
        })
    }

    //Cancel Button Method
    handleCancel(event) {
        // Add your cancel button implementation here
        this.dispatchEvent(new CloseActionScreenEvent());
     }
}