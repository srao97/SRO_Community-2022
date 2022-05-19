/*******************************************************************************************
* @Name         ContentDocumentLink_TriggerHelper 
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         31/08/2021
* @Description  Triggered each time a content document is generated against a specified objects
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      31/08/2021          Initial Creation   
*  1.1              Sebastian      14/10/2021          Adjusted to copy notes related to Individual Applications to Case   
*  1.2              Sourabh		   1/12/2021           VHF-3560: Updated file visibility to 'AllUsers'
*  1.3              Sebastian      19/01/2022          Added verifyParticipantFileUploadAccess method to prevent participants uploading files
*                                                      when they are not permitted
*  1.4              Arjun Singh    21/02/2022          VHF-3316 - Final Payment - Generate Payout Document
*******************************************************************************************/
public class ContentDocumentLink_TriggerHelper {
    // Method: congaFileLinkToCase
    public static void congaFileLinkToCase(List<ContentDocumentLink> contentDocumentLinks){
        
        // Identify if any relevant ContentDocumentLinks have been inserted
        Map<Id, List<Id>> shadowApplicationContentDocumentLinksByLinkedEntityId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> contractContentDocumentLinksByLinkByLinkedEntityId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> individualApplicationContentDocumentLinksByLinkedEntityId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> paymentContentDocumentLinksByLinkedEntityId = new Map<Id, List<Id>>();
        Set<Id> paymentContentDocumentIds = new Set<Id>();
        Set<Id> paymentPayoutDocumentContentDocumentsIds = new Set<Id>();

        for(ContentDocumentLink contentDocumentLink: contentDocumentLinks){
            System.debug('contentDocumentLink>>>>>'+contentDocumentLink);
            if(String.valueOf(contentDocumentLink.LinkedEntityID.getsObjectType()) == 'Individual_Application_Shadow__c'){
                if(shadowApplicationContentDocumentLinksByLinkedEntityId.containsKey(contentDocumentLink.linkedEntityId)){
                    shadowApplicationContentDocumentLinksByLinkedEntityId.get(contentDocumentLink.linkedEntityId).add(contentDocumentLink.contentdocumentId);
                }else{
                    shadowApplicationContentDocumentLinksByLinkedEntityId.put(contentDocumentLink.linkedEntityId, new List<String>{contentDocumentLink.contentdocumentId});
                }
                System.debug('*** Shadow CDL Processed: ' + contentDocumentLink.linkedEntityId + ' ' + contentDocumentLink.contentdocumentId);
            }else if(String.valueOf(contentDocumentLink.LinkedEntityID.getsObjectType()) == 'Contract'){
                if(contractContentDocumentLinksByLinkByLinkedEntityId.containsKey(contentDocumentLink.linkedEntityId)){
                    contractContentDocumentLinksByLinkByLinkedEntityId.get(contentDocumentLink.linkedEntityId).add(contentDocumentLink.contentdocumentId);
                }else{
                    contractContentDocumentLinksByLinkByLinkedEntityId.put(contentDocumentLink.linkedEntityId, new List<String>{contentDocumentLink.contentdocumentId});
                }
                System.debug('*** Contract CDL Processed: '+contentDocumentLink.linkedEntityId+' '+contentDocumentLink.contentdocumentId);
            }else if(String.valueOf(contentDocumentLink.linkedEntityID.getsObjectType()) == 'IndividualApplication'){
                if(individualApplicationContentDocumentLinksByLinkedEntityId.containsKey(contentDocumentLink.LinkedEntityId)){
                    individualApplicationContentDocumentLinksByLinkedEntityId.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink.contentDocumentId);
                }else{
                    individualApplicationContentDocumentLinksByLinkedEntityId.put(contentDocumentLink.linkedEntityId, new List<String>{contentDocumentLink.contentdocumentId});
                }
                System.debug('*** Individual Application CDL Processed: '+contentDocumentLink.linkedEntityId+' '+contentDocumentLink.contentdocumentId);
            }else if(String.valueOf(contentDocumentLink.linkedEntityID.getsObjectType()) == 'Payment__c'){
                paymentContentDocumentIds.add(contentDocumentLink.ContentDocumentId);
                if(paymentContentDocumentLinksByLinkedEntityId.containsKey(contentDocumentLink.LinkedEntityId)){
                    paymentContentDocumentLinksByLinkedEntityId.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink.contentDocumentId);
                }else{
                    paymentContentDocumentLinksByLinkedEntityId.put(contentDocumentLink.linkedEntityId, new List<String>{contentDocumentLink.contentdocumentId});
                }
                System.debug('*** Payment CDL Processed: '+contentDocumentLink.linkedEntityId+' '+contentDocumentLink.contentdocumentId);
            }
        } // End - for(ContentDocumentLink)l

        System.debug('*** Documents Linked to Shadow Application: ' + shadowApplicationContentDocumentLinksByLinkedEntityId);
        System.debug('*** Documents Linked to Contract: ' + contractContentDocumentLinksByLinkByLinkedEntityId);
        System.debug('*** Documents Linked to Individual Application: ' + individualApplicationContentDocumentLinksByLinkedEntityId);

        // Check if the Payment attched document is Payout Document and store it in paymentPayoutDocumentContentDocumentsIds
        for(ContentDocument cd: [Select Id from ContentDocument where Id IN : paymentContentDocumentIds AND title = 'Payout Document.pdf']){
            paymentPayoutDocumentContentDocumentsIds.add(cd.Id);
        }

        // If relevant ContentDocumentLinks are found then create links to appropirate objects 
        if(!shadowApplicationContentDocumentLinksByLinkedEntityId.isEmpty() || !contractContentDocumentLinksByLinkByLinkedEntityId.isEmpty() || !individualApplicationContentDocumentLinksByLinkedEntityId.isEmpty() || !paymentContentDocumentLinksByLinkedEntityId.isEmpty()){
            List<Individual_Application_Shadow__c> relatedShadowApplications = [SELECT ID, Individual_Application__c, Individual_Application__r.ApplicationCaseId 
                                                                                FROM Individual_Application_Shadow__c 
                                                                                WHERE ID 
                                                                                IN :shadowApplicationContentDocumentLinksByLinkedEntityId.keySet()];

            List<Contract> relatedContracts = [SELECT ID, ApplicationCaseId__c
                                                FROM Contract
                                                WHERE ID
                                                IN :contractContentDocumentLinksByLinkByLinkedEntityId.keySet()];

            List<IndividualApplication> relatedIndividualApplications = [SELECT ID, ApplicationCaseId
                                                                            FROM IndividualApplication
                                                                            WHERE ID
                                                                            IN :individualApplicationContentDocumentLinksByLinkedEntityId.keySet()];

            List<Payment__c> paymentRecords = [SELECT ID, Case__c  FROM Payment__c WHERE ID IN:  paymentContentDocumentLinksByLinkedEntityId.keySet()];

            List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();

            for(Individual_Application_Shadow__c relatedShadowApplication: relatedShadowApplications){
                for(Id contentDocumentLinkId: shadowApplicationContentDocumentLinksByLinkedEntityId.get(relatedShadowApplication.Id)){
                    contentDocumentLinksToInsert.add(new ContentDocumentLink(
                                                    ContentDocumentId = contentDocumentLinkId,
                                                    LinkedEntityId = relatedShadowApplication.Individual_Application__c,
                                                    ShareType = 'V',
                                                    Visibility = 'AllUsers'));
                } // End - for(Id)
            } // End - for(Individual_Application_Shadow)
            for(Contract relatedContract: relatedContracts){
                for(Id contentDocumentLinkId: contractContentDocumentLinksByLinkByLinkedEntityId.get(relatedContract.Id)){
                    contentDocumentLinksToInsert.add(new ContentDocumentLink(
                                                    ContentDocumentId = contentDocumentLinkId,
                                                    linkedEntityId = relatedContract.ApplicationCaseId__c,
                                                    ShareType = 'V',
                                                    Visibility = 'AllUsers'));
                } // End - for(Id)
            } // End - for(Contract)
            for(IndividualApplication relatedIndividualApplication: relatedIndividualApplications){
                for(Id contentDocumentLinkId: individualApplicationContentDocumentLinksByLinkedEntityId.get(relatedIndividualApplication.Id)){
                    contentDocumentLinksToInsert.add(new ContentDocumentLink(
                                                    ContentDocumentId = contentDocumentLinkId,
                                                    linkedEntityId = relatedIndividualApplication.ApplicationCaseId,
                                                    ShareType = 'V',
                                                    Visibility = 'AllUsers'));
                } // End - for(Id)
            } // End - for(IndividualApplication)
            // Payout docuement 
            for(Payment__c paymentRecord : paymentRecords){
                for(Id contentDocumentLinkId: paymentContentDocumentLinksByLinkedEntityId.get(paymentRecord.Id)){
                    contentDocumentLinksToInsert.add(new ContentDocumentLink(
                                                    ContentDocumentId = contentDocumentLinkId,
                                                    linkedEntityId = paymentRecord.Case__c,
                                                    ShareType = 'V',
                                                    Visibility = 'AllUsers'));
                }
            }
            System.debug('*** Content Document Links to Insert: ' + contentDocumentLinksToInsert);

            // Insert new ContentDocumentLinks in to Salesforce
            List<Id> successfullyInsertedContentDocumentLinkIds = new List<Id>();
            if(!contentDocumentLinksToInsert.isEmpty()){
                List<Database.SaveResult> saveResults = Database.insert(contentDocumentLinksToInsert, false);
                for(Database.SaveResult sr: saveResults){
                    if(sr.isSuccess()){
                        successfullyInsertedContentDocumentLinkIds.add(sr.getId());
                    } else {
                        for(Database.Error err: sr.getErrors()){
                            System.debug('ERROR OCCURED: Failed Content Document Link Insertion: ID = '+sr.Id+' Status Code: '+err.getStatusCode()+' Message: '+err.getMessage());
                        }
                    }
                } // End - for(Database.saveResult)
            }
            System.debug('*** Successfully Inserted Content Document Links: ' + successfullyInsertedContentDocumentLinkIds);
        }
    } // End - congaFileLinkToCase
    
     /**
    * Methods     :  RestrictFileExtensionUpload
    * @author     :  Manish Jhingran
    * @version    :  $Revision: 1.0 $, $Date: 18/Sep/2021
    * @Description:  This method restrict the SRO users/User assigned to Operation profile to upload files with extensions exe,msg,bat and wrf
    */
    public static void restrictFileExtensionUpload(List<ContentDocumentLink> contentDocumentLinks){ 
        if(!contentDocumentLinks.isEmpty()){
            Id Operation_PROFILE_ID = [SELECT ProfileId FROM User WHERE Profile.Name = 'Operations' LIMIT 1].ProfileId;
            if(UserInfo.getProfileId() == Operation_PROFILE_ID){
                Set<Id> linkedContentDocuments = new Set<Id>();
                for(ContentDocumentLink contentDocumentLink: contentDocumentLinks){
                    linkedContentDocuments.add(contentDocumentLink.ContentDocumentId);
                }
                map<Id, ContentDocument> contentDocumentsByContentDocumentId = new map<Id, ContentDocument>([SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN :linkedContentDocuments]);
                for(ContentDocumentLink contentDocumentLink: contentDocumentLinks) {
                    ContentDocument currentContentDocument = contentDocumentsByContentDocumentId.get(contentDocumentLink.ContentDocumentId);
                    if(currentContentDocument != null){
                        // Allow all files except : exe,wrf,msg and bat  
                        if((currentContentDocument.FileExtension == 'exe')||(currentContentDocument.FileExtension == 'msg')|| (currentContentDocument.FileExtension =='wrf')||(currentContentDocument.FileExtension =='bat')){
                            contentDocumentLink.addError('You can not upload file with extensions exe, msg, wrf and bat.');//Showing error    
                            System.debug('*** You can not upload file with extensions exe, msg, wrf and bat.');
                        }
                    }                        
                } // End - for(ContentDocumentLink)
            }  
        }
    }// End - restrictFileExtentionUpload

    // method: verifyParticipantFileUploadAccess
    public static void verifyParticapantFileUploadAccess(List<ContentDocumentLink> contentDocumentLinks){
        System.debug('*** Enter verifyParticapantFileUploadAccess method in ContentDocumentLink_TriggerHelper');
        System.debug('*** contentDocumentLinks to process: ' + contentDocumentLinks);
        // Find Annual Reviews linked to Content Document Links
        Set<Id> linkedAnnualReviewIds = new Set<Id>();
        for(ContentDocumentLink contentDocumentLink: contentDocumentLinks){
            if(String.valueOf(contentDocumentLink.LinkedEntityId.getsObjectType()) == 'Annual_Review__c'){
                linkedAnnualReviewIds.add(contentDocumentLink.LinkedEntityId);
            }
        } // End - for(ContentDocumentLink)

        // Check if file upload is allowed on each related Annual Review
        if(!linkedAnnualReviewIds.isEmpty()){
            // Check context user Profile is Participant
            Id participantProfileId = [SELECT Id FROM Profile WHERE Name = 'VHF Participant Community Plus User' LIMIT 1].Id;
            // Check context user if Primary Participant
            Boolean isPrimaryParticipant = [SELECT Contact.Primary_Participant__c FROM User WHERE Id = :userinfo.getUserId() LIMIT 1].Contact.Primary_Participant__c;
            if(userinfo.getProfileId() == participantProfileId && isPrimaryParticipant == true){
                // Create list of Annual Reviews Where file attachment is blocked
                Set<Id> blockedAnnualReviewIds = new Set<Id>();
                List<Annual_Review__c> linkedAnnualReviews = [SELECT Id, Status__c, Revision__c FROM Annual_Review__c WHERE Id IN :linkedAnnualReviewIds];
                for(Annual_Review__c annualReview: linkedAnnualReviews){
                    if((annualReview.Status__c == 'Awaiting Submission' || annualReview.Status__c == 'Awaiting Verification' || annualReview.Revision__c == 'Minor Update Requested') == false){
                        blockedAnnualReviewIds.add(annualReview.Id);
                        System.debug('*** File upload blocked on Annual Review: ' + annualReview.Id);
                    }
                } // End - for(Annual_Review__c)
                // Add errors to blocked content document links
                if(!blockedAnnualReviewIds.isEmpty()){
                    for(ContentDocumentLink contentDocumentLink: contentDocumentLinks){
                        if(blockedAnnualReviewIds.contains(contentDocumentLink.LinkedEntityId)){
                            contentDocumentLink.addError('Files cannot be uploaded at this time');
                        }
                    } // End - for(ContentDocumentLink)
                }
            }
        }
    } // End - verifyParticipantFileUploadAccess
}