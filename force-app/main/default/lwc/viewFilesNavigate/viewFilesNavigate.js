import {commonUtils,dataFormatter,omniscriptUtils} from "vlocity_ins/insUtility";
import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin';

export default class ViewFilesNavigate extends OmniscriptBaseMixin(LightningElement) {
    @api annualReviewId;
    @api isSecondaryParticipant;
    handleClick(){
        if(this.isSecondaryParticipant==='true'){
            window.open(`/participants/s/viewallfiles?recordId=${this.annualReviewId}`);
        } else{
            window.open('/participants/s/relatedlist/'+`${this.annualReviewId}`+'/AttachedContentDocuments');
        }
    }
}