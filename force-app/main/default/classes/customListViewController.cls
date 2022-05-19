/*******************************************************************************************
* @Name         Custom List View Controller. This is a reusable Controller to show List Views
* @Author       Lavanya Kavuri
* @Date         01/02/2022
* @Description  This class is used populating data into the lwc list view.
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Lavanya Kavuri     01/02/2022          Created  	
*******************************************************************************************/
public with sharing class customListViewController {
    private static final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
    private static List<Network> network;
    
    /*
    ** Method to Fetch the List View Records if List Type = Object
    */

    @AuraEnabled
    public static String fetchObjectRecords(String objectName, String fields, String filter, Integer recordLimit, Integer pageSize, Integer pageNumber, Boolean pagenationEnabled, String sortBy, string sortDirection){
        try {
            
            Integer offset = 0;
            Integer totalRecords =0;
            String jsonData = '';

            System.debug('Inside methood call>>>>');
            String soqlQueryStr = 'Select ' + fields + ' FROM ' + objectName; 
            String soqlCountQueryStr = 'Select Count() FROM ' + objectName; 
            if(!String.isEmpty(filter))
            {
                soqlQueryStr = soqlQueryStr + ' WHERE ' + filter;
                soqlCountQueryStr = soqlCountQueryStr + ' WHERE ' + filter;
                totalRecords = Database.countQuery(soqlCountQueryStr);
            }
            soqlQueryStr = soqlQueryStr + ' ORDER BY ' + sortBy + ' ' + sortDirection;

            //If pagination enabled, basic limit is not taken into consideration even if provided
            if(recordLimit > 0 && !pagenationEnabled) 
            {
                soqlQueryStr = soqlQueryStr + ' LIMIT ' + recordLimit;
            }
            if(pagenationEnabled){
                
                 offset = (pageNumber - 1) * pageSize;
                 system.debug('Pagination enabled with Offset' + offset + ' Pagesize ' + pageSize);
                 soqlQueryStr = soqlQueryStr + ' LIMIT ' + pageSize + ' OFFSET ' + offset;
            }
            System.debug('soql query =' + soqlQueryStr);
            List<SObject> sObjList = Database.query(soqlQueryStr);
            System.debug('obj list =' + sObjList); 
            //return sObjList;
            objectsWrapperClass owc = new objectsWrapperClass();
            if(pageSize!=null && pageSize != 0 && pagenationEnabled){
                if(totalRecords<=pageSize){
                    owc.totalPages = 1;
                }else{
                    owc.totalPages = Integer.valueOf(Math.ceil(Decimal.valueOf(totalRecords)/Decimal.valueOf(pageSize)));
                }
                owc.totalRecords = totalRecords;
                owc.recordStart = offset + 1;
                owc.recordEnd = offset  + pageSize;
                if (owc.recordEnd > owc.totalRecords){
                    owc.recordEnd = owc.totalRecords;
                }
                if(owc.recordStart> owc.totalRecords){
                    owc.recordStart = owc.totalRecords;
                }
            }else{
                owc.totalPages = 1;
                owc.totalRecords = totalRecords;
                owc.recordStart = 1;
                owc.recordEnd = totalRecords;
            }
            system.debug('OWC ' + owc);
            owc.records = sObjList;
            jsonData = JSON.serialize(owc);
            system.debug('objectsWrapperClass JSONdata ' + jsonData);
            return jsonData;
           
        } catch (Exception e) {
            System.debug('error>>'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        
    }

    /*
    ** Method to Fetch the List View Records if List Type = Files
    */

    @AuraEnabled
    public static List<ContentVersion> fetchFileRecords(String relatedId){
        Set<Id> contentIds = new Set<Id>();
        String result;
        try {
            List<ContentDocumentLink> contentDocsList = [Select 
                                                            ContentDocumentId, LinkedEntityId
                                                         From 
                                                            ContentDocumentLink 
                                                         Where 
                                                            LinkedEntityId = :relatedId 
                                                          ]; 
            
            if(!contentDocsList.isEmpty())
            {
                for(ContentDocumentLink cdRec: contentDocsList)
                {
                    contentIds.add(cdRec.ContentDocumentId);
                }
            }

            List<ContentVersion> contentVersionList = [
                                                        Select 
                                                            Id, VersionData, FileType, Title, FileExtension,
                                                            ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                            CreatedDate,ContentDocumentId, ContentDocument.FileType
                                                        from 
                                                            ContentVersion 
                                                        Where 
                                                            ContentDocumentId in : contentIds
                                                            and 
                                                            ContentDocument.FileType != 'SNOTE'
            ];
            if(!contentVersionList.isEmpty())
            {
                return contentVersionList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /*
    * Method to check if the user is primary participant
    */
    @AuraEnabled
    public static boolean isPrimaryParticipant(){
        boolean showNewRequest;
        try
        {
            //Get the current running user 
            Id currentUser = UserInfo.getUserId();
            User userRec = [Select Id, ContactId from User where Id =: currentUser];
            if(userRec.ContactId != null)
            {
                Contact contactRec = [Select Id, Primary_Participant__c from Contact where Id =: userRec.ContactId ]; 

                if(contactRec.Primary_Participant__c)
                {
                    showNewRequest = true;
                }
                else 
                {
                    showNewRequest = false;
                }
            }

        } catch (Exception e) {
           
            throw new AuraHandledException(e.getMessage());
            
        }

        return showNewRequest;
        
    }

    public class objectsWrapperClass {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalPages {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public Integer totalRecords {get;set;}
        public List<SObject> records {get;set;}
    }
}