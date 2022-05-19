import { LightningElement, api, wire  } from 'lwc';
import validateRequest from '@salesforce/apex/PropertySalePayoutDocumentPreChecks.validateRequest';
import updatePropertySaleCase from '@salesforce/apex/PropertySalePayoutDocumentPreChecks.updatePropertySaleCase';
import UTITLITY_ICONS from '@salesforce/resourceUrl/UtilityIcons';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class VHFPropertySalePayoutDocumentPreValidations extends LightningElement {
    @api recordId;
    @api showSpinner = false;
    @api showError = false;
    @api showSuccess = false;
    @api showConfirmation = false;
    @api validationError = false;
    @api hasError = false ;
    errorMessage;    
    errorIconUrl = UTITLITY_ICONS + '/icons/error.png';
    warningIconUrl = UTITLITY_ICONS + '/icons/warning.png';
    @api errorList = [];
    @wire(CurrentPageReference)
      currentPage;

    connectedCallback() {
        this.showSpinner = true;
        validateRequest({
            caseId: this.currentPage.state.recordId
        })
        .then(response => {
            console.log('response>>>', response);
            if(response === 'GenerateDocument'){
                this.showConfirmation = true;
                this.showSpinner = false;
            }else{
                this.showSpinner = false;
                this.validationError = true
                this.errorList.push(response); 
            }
                       
        })
        .catch(error => {
            console.log('something went wrong' , JSON.stringify(error));
            this.showSpinner = false;
            this.hasError = true
            this.errorMessage = error.body.message;
        })
    }
    //Cancel Button Method
    handleCancel(event) {
        // Add your cancel button implementation here
        
        this.dispatchEvent(new CloseActionScreenEvent());
        location.reload();
     }

     sendpayoutdocument(event){
        this.showSpinner = true;
        updatePropertySaleCase({
            caseId: this.currentPage.state.recordId
        })
        .then(response => {
            console.log('response>>>', response);
            if(response ==='true'){
                this.showSpinner = false;
                this.validationError = false;
                this.showConfirmation = false;
                this.showSuccess = true;
            }else{
                this.showSpinner = false;
                this.showConfirmation = false;
                this.hasError = true;
                this.errorList.push(response); 
            }
        })
        .catch(error => {
            console.log('something went wrong' , JSON.stringify(error));
            this.showSpinner = false;
            this.hasError = true
            this.errorMessage = error.body.message;
        })
     }
}