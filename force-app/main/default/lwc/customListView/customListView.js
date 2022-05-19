import { LightningElement, api, wire, track } from 'lwc';
import fetchObjectRecords from '@salesforce/apex/customListViewController.fetchObjectRecords';
import fetchFileRecords from '@salesforce/apex/customListViewController.fetchFileRecords';
import isPrimaryParticipant from '@salesforce/apex/customListViewController.isPrimaryParticipant';
import { NavigationMixin } from 'lightning/navigation';
import basePathName from '@salesforce/community/basePath';

/*
Use the below Columns array template to populate the Component Properties Column Labels in the Community Builder page. 

Id, CaseNumber, Record_Type_Name__c, Status, ContactId, Contact.Name, Property_Address__c, CreatedDate

const columns = [
    { label: 'Case Id', fieldName: 'linkName', type: 'url', hideDefaultActions:true, wrapText: true, typeAttributes: { label: { fieldName: 'CaseNumber'}, target: '_blank'}, sortable: false },
    { label: 'Case type', fieldName: 'Record_Type_Name__c',   hideDefaultActions:true, wrapText: true,type: 'text', sortable: false },
    { label: 'Status', fieldName: 'Status', type: 'text', hideDefaultActions:true, wrapText: true,  sortable: false },
    { label: 'Contact', fieldName: 'secondLink', type: 'url', hideDefaultActions:true, wrapText: true, typeAttributes: { label: { fieldName: 'secondLinkValue'}, target: '_blank'}, sortable: false },
    { label: 'Property Address', fieldName: 'Property_Address__c', type: 'text', hideDefaultActions:true, wrapText: true,  sortable: false },
    { label: 'Created date', fieldName: 'CreatedDate', type: 'date', hideDefaultActions:true, wrapText: true, sortable: true, typeAttributes:{
        month: "2-digit",
        day: "2-digit", 
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    } }
];
*/

const columns = [
    { label: 'Title', fieldName: 'fileUrl', hideDefaultActions:true, wrapText: true, type: 'url', typeAttributes: { label: {fieldName: 'Title'} }, cellAttributes: { iconName: {fieldName: 'icon'}, iconPosition: 'left' }},
    
    { label: 'Created date', fieldName: 'CreatedDate', type: 'date', hideDefaultActions:true, wrapText: true, sortable: true, typeAttributes:{
        month: "2-digit",
        day: "2-digit", 
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    } }
];

export default class CustomListView extends NavigationMixin(LightningElement) {
    /*
    ** Design Attribute Paramters from the LWC Component
    */
    @api listType;
    @api recordId;

    @api listTitle;
    @api listIcon;
    @api showIcon;
    @api showListAction;
    @api actionButtonLabel;
    @api actionButtonLink;
    @api actionForPrimaryParticipant;
    @api showViewAll;
    @api viewAllUrl;
    @api columnAttributes;
    @api objectApiName;
    @api secondLookup;
    @api secondObjField;
    @api networkURL;
    @api secondObjName;
    
    @api fieldApiNames;
    @api recordFilter;
    @api recordLimit;

    @api showPagination = false;
    @api pageSize = 10;
    
    /*
    ** LWC Local Parameters
    */ 
    @track result;
    @track columnsList = [];
    @track dataList;
    @track objRecords;
    @track fileRecords;
    @track primaryOnly;
    sortedBy = 'CreatedDate';
    defaultSortDirection = 'desc';
    sortDirection = 'desc';
    
    @track currentPage = 1;
    @track totalPages = 1;
    @track totalRecords = 1; 
    @track recordStart = 1;
    @track recordEnd = 1;
    

    


getBaseUrl() 
{
    let baseUrl = 'https://'+location.host+'/';
    return baseUrl;
}

 connectedCallback() {
    //Convert Column Labels from String to Array 
    this.columnsList = eval('(' + this.columnAttributes + ')');
    let recordCount; 
    
    
    //Check for the record count limit 

    /*
    ** Fetch the List View Records if List Type = Object
    */
     if(this.listType === 'object')
     {
        this.preparePaginationDataList();
     }

     /*
    ** Fetch the List View Records if List Type = Files
    */

     if(this.listType === 'files')
     {
         this.fileRecords = true;
         this.objRecords = false;
         fetchFileRecords({
            relatedId: this.recordId
         })
         .then(response => {
             console.log(response);
             //let parsedData = JSON.parse(response);
             //let stringifiedData = JSON.parse(parsedData); 
             let finaldata = response;
             let baseURL = this.getBaseUrl();
             finaldata.forEach(file => {
                 file.thumbnailUrl = baseURL +'participants/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId='+file.Id;
                 file.downloadUrl = baseURL+'participants/sfsites/c/sfc/servlet.shepherd/document/download/'+file.ContentDocumentId;
                 file.fileUrl= baseURL+'participants/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+file.Id;
                 file.CREATED_BY = file.ContentDocument.CreatedBy.Name;
             });
             this.dataList = finaldata;
         })
         .catch(error => {
             console.log('error=' + JSON.stringify(error));
         })
     }
 }

 preparePaginationDataList(){
    let objName;
    let secondObjName;
    if(this.objectApiName)
    {
        objName = this.objectApiName;
    }
    if(this.secondObjName)
    {
        secondObjName = this.secondObjName;
    }

    if(this.listType === 'object')
     {
         let secLookup = this.secondLookup;
         let secObjName =  this.secondObjName;
         let secObjField = this.secondObjField;
         this.objRecords = true;
         this.fileRecords = false;
         fetchObjectRecords({
             objectName: this.objectApiName,
             fields: this.fieldApiNames,
             filter: this.recordFilter,
             recordLimit: this.recordLimit,
             pageSize : this.pageSize,
             pageNumber : this.currentPage,
             pagenationEnabled : this.showPagination,
             sortBy : this.sortedBy,
             sortDirection : this.sortDirection
         })
         .then(response => {
             
             var resultData = JSON.parse(response);
             this.dataList = resultData.records;
             this.totalPages = resultData.totalPages;
             this.totalRecords = resultData.totalRecords;
             this.recordStart = resultData.recordStart;
             this.recordEnd = resultData.recordEnd;
             console.log('result data = ' + this.dataList);
            /**
             * Code to remove the __c from objName for Custom Object
             */
            if(objName.endsWith('__c')){
                let splitObjName = objName.split('__c');
                objName = splitObjName[0];
            }
             this.dataList.forEach(function(record) { 
                 console.log('looping...');
                 record.linkName = basePathName + '/' + objName + '/' + record.Id + '/detail';
                 console.log('linkName' + record.linkName);
                 if(secLookup)
                 {
                    let secondLinkAPI = 'record.' + secObjField;
                    record.secondLink  = basePathName + '/detail/' + record[secObjField];
                    let obj = record[secObjName];
                    let linkValue = obj.Name;
                    record.secondLinkValue = linkValue
                    
                 }
                 
            })
         }).then(() => {
            if(this.actionForPrimaryParticipant)
            {
                isPrimaryParticipant({
                }).then(resp => {
                    this.primaryOnly = resp;
                });
            }
        }).
        catch(error => {
            console.log(JSON.stringify(error.message));
        })
     }
 }
 handleRowAction(event)
 {
     const action = event.detail.action; 
     const row = event.detail.row;
     switch(action.name) {
         case 'download':
            this.handleNavigation(row.downloadUrl);
     }
 }

 handleNavigation(navigateToUrl)
 {
    const config = {
        type: 'standard__webPage',
        attributes: {
            url: navigateToUrl
        }
	};
    this[NavigationMixin.Navigate](config);
 }

 handleSort(event)
 {
    const { fieldName: sortedBy, sortDirection } = event.detail;
   // const cloneData = [...this.dataList];
   // cloneData.sort(this.sortBy(sortedBy, sortDirection === 'desc' ? 1:-1));
   // this.dataList = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy; 
    this.preparePaginationDataList();

 }

sortBy(field, reverse, primer) 
{
    const key = primer 
    ? function(x) {
        return primer(x[field]);
    }
    :function(x) {
        return x[field];
    };

    return function(a,b) {
        a = key(a);
        b= key(b);
        return reverse * ((a>b) - (b>a));
    };
}

previousHandler(){ 
    if(this.currentPage>1){
        this.currentPage = this.currentPage-1;
        this.preparePaginationDataList();
    }
}

nextHandler(){
    if(this.currentPage < this.totalPages){
        this.currentPage = this.currentPage+1;
        this.preparePaginationDataList();
    }
}

get disableNext(){ 
    return this.currentPage>=this.totalPages;
}
get disablePrevious(){ 
    return this.currentPage<=1;
}

}