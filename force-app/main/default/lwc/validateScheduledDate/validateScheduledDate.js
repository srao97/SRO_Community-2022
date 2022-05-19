import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin';
import { getDataHandler } from "vlocity_ins/utility";
export default class ValidateScheduledDate extends OmniscriptBaseMixin(LightningElement) {
    errorMessage = false;
    pastDateErrorMsg = false;
    errorMoreThan2yrs = false;
    errorScheduledDtNull = true;
    connectedCallback() {
        this.enteredVal = this.schDate;
    }    
    handleChange(event) {
        let scheduledDate = event.detail.value;
        let sDate = {"StepContractDetails:SettlementDate" : scheduledDate}
        this.omniApplyCallResp(sDate);
        let datasource = JSON.stringify({
            type: 'apexremote',
            value: {
                className: 'BusinessDaysCalculation',
                methodName: 'validateDays',
                inputMap: {"scheduledDate":scheduledDate}, 
                optionsMap: {}
            }
        });        
        
        getDataHandler(datasource).then(data => {
            var responseObj = JSON.parse(data);
            this.errorMessage=responseObj.ErrorMsg;
            this.pastDateErrorMsg=responseObj.pastDateErrorMsg;
            this.errorMoreThan2yrs=responseObj.ErrorMoreThan2yrs;
            this.errorScheduledDtNull=responseObj.ErrorScheduledDtNull;
            console.log('this.errorScheduledDtNull:' + this.errorScheduledDtNull);
            let myData = {"FmlErrSettleDateTooCloseSV" : this.errorMessage}
            this.omniApplyCallResp(myData);
            myData = {"PastScheduledDateSV" : this.pastDateErrorMsg}
            this.omniApplyCallResp(myData);
            myData = {"FmlErrSettleDateMoreTwoyrsSV" : this.errorMoreThan2yrs}
            this.omniApplyCallResp(myData);
            myData = {"ErrScheduledDateNull" : this.errorScheduledDtNull}
            this.omniApplyCallResp(myData);
        }).catch(error => {
            console.log(`Error calling ApexRemote ${error}`);
        });
    }
}