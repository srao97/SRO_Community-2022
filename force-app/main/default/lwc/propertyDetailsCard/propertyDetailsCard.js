import { LightningElement, api, track } from 'lwc';
import getPropertyDetails from '@salesforce/apex/propertyDetailsCardController.getPropertyDetails';

export default class PropertyDetailsCard extends LightningElement {

    //Design attributes 
    @api title;

    @api column1Label;
    @api column2Label;
    @api column3Label;

    @api column1HelpText;
    @api column2HelpText;
    @api column3HelpText;

    @api column1Value;
    @api column2Value;
    @api column3Value;

    @api column1ApiName;
    @api column2ApiName;
    @api column3ApiName;
    @api hightlightColumn3;

    @api propertyInfo;

    @api objectName;
    @api filterFieldApiName;
    @api showViewAll;
    @api viewAllUrl;

    @api response;
    @api showSpinner = false;


    connectedCallback() 
    {
        this.showSpinner = true;
        let fieldApiNames = this.column1ApiName + ',' + this.column2ApiName + ',' + this.column3ApiName
        console.log('column1 =' + this.column1ApiName);
        console.log('column2 =' + this.column2ApiName);
        console.log('column3 =' + this.column3ApiName);
        let column1 = null; 
        let column2 = null;
        let column3 = null;
        
        if(this.column1ApiName)
        {
            column1 = this.column1ApiName;
        }
        if(this.column2ApiName)
        {
            column2 = this.column2ApiName;
        }
        if(this.column3ApiName)
        {
            column3= this.column3ApiName;
        }
        
        console.log('1=' + column1);
        console.log('2=' + column2);
        console.log('3=' + column3);

        getPropertyDetails({
            field1: column1,
            field2: column2,
            field3: column3,
            objectApiName: this.objectName,
            filter: this.filterFieldApiName
        })
        .then(result => {
            this.showSpinner = false;
            this.propertyInfo = result;
            this.response = result;
            console.log(this.response);
            /*
            this.response = JSON.parse(result);
            console.log(this.response);
            console.log('column1' + this.response[this.column1ApiName]);
            this.column1Value = this.response[this.column1ApiName];
            this.column2Value = this.response[this.column2ApiName];
            this.column3Value = this.response[this.column3ApiName];
            */
            console.log(result);
        })
    }
}