import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import validateRequest from '@salesforce/apex/CasePaymentRequest.validateRequest';
import updateCase from '@salesforce/apex/CasePaymentRequest.updateCase'
import UTITLITY_ICONS from '@salesforce/resourceUrl/UtilityIcons';

export default class CasePaymentRequest extends LightningElement {
    @api recordId;
    @api showConfirmation = false;
    @api showSuccess = false;
    @api validationError = false;
    @api showError = false;
    @api showSpinner = false;
    @api paymentComments;
    errorMessage;
    errorIconUrl = UTITLITY_ICONS + '/icons/error.png';
    warningIconUrl = UTITLITY_ICONS + '/icons/warning.png';
    @api errorList = [];

    //Had to use this to get the RecordId, as there is a few seconds delay arghhhhh
    @wire(CurrentPageReference)
      currentPage;

    connectedCallback() {
        this.showSpinner = true;
        validateRequest({
            caseId: this.currentPage.state.recordId
        })
        .then(response => {
            console.log('response', response);
            const result = JSON.parse(response);
            console.log(result);
            if(result.errors.length > 0) 
            {
                console.log('there are errors');
                this.errorList = JSON.parse(result.errors);
                this.showSpinner = false;
                this.validationError = true;
            }
            else 
            {
                console.log('there are no errors');
                this.showSpinner = false;
                this.showConfirmation = true;
            }
        })
        .catch(error => {
            console.log('something went wrong' , JSON.stringify(error));
            this.showSpinner = false;
            this.showError = true
            this.errorMessage = error.body.message;
        })
    }

    handleComments(event) {
        this.paymentComments = event.detail.value;
        console.log(this.paymentComments);
    }

    updateCaseRecord() 
    {
        this.showSpinner = true;
        console.log(this.paymentComments);
        var commentsToUpdate = "N/A"; //VHF-4977
        if (Boolean(this.paymentComments)) {
            commentsToUpdate = this.paymentComments;
        }
        updateCase({
            caseId: this.currentPage.state.recordId,
            comments: commentsToUpdate
        })
        .then(response => {
            this.caseId = response.caseNumber;
            this.showSpinner = false;
            this.showSuccess = true;
            this.showConfirmation = false;
        })
    }

    //Cancel Button Method
    handleCancel(event) {
        // Add your cancel button implementation here
        
        this.dispatchEvent(new CloseActionScreenEvent());
        location.reload();
     }
}