/*******************************************************************************************
* @Name         AnnualReviewGeneratorService
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         21/10/2021
* @Description  Service class to allow generation of Annual Review records from different contexts.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      21/10/2021          Initial Creation
*  1.1              Lawrence        1/11/2021          Calls BusinessDaysCalculation class
*  1.2				Lawrence		8/11/2021          Saves campaign id if available
*******************************************************************************************/
public class AnnualReviewGeneratorService {
    // Invocable method to be called from 'Create Replacement Annual Review' flow 
    @InvocableMethod(label='Create Replacement Annual Review' description='Creates replacement Annual Review Record for specified Annual Review and returns ID of new Annual Review. Only one Annual Review Can be generated at a time.'category='Annual Review')
    public static list<ID> AnnualReviewGeneratorService(list<Id> requestedAnnualReviews) {
        System.debug('*** INVOCABLE METHOD CALL: Create Annual Reviews ***');
        System.debug('Requested Properties: '+requestedAnnualReviews);
        list<Annual_Review__c> annualReviews = [SELECT Property__c, Annual_Review_Start_Date__c FROM Annual_Review__c WHERE Id IN :requestedAnnualReviews];
        list<Id> requestedProperties = new list<Id>();
        for(Annual_Review__c annualReview: annualReviews){
            requestedProperties.add(annualReview.Property__c);
        }
        list<Order> fullPropertyInfo = [SELECT Id, Actual_Settlement_Date__c, 
                                    (SELECT Id, Name, PersonContactId, Is_Participant__pc, Primary_Participant__pc, IsActiveApplicant__pc 
                                    FROM Accounts__r)
                                    FROM Order
                                    WHERE Id IN :requestedProperties];
        list<Id> newAnnualReviews = generateAnnualReviews(fullPropertyInfo, null, annualReviews[0].Annual_Review_Start_Date__c.year());
        return newAnnualReviews;
    }

    public static list<Id> generateAnnualReviews(list<Order> activeProperties, id campaignId, Integer specifiedYear){
        // Create Annual Review Records
        System.debug('*** METHOD CALL: AnnualReviewGeneratorService.generateAnnualReviews ***');
        System.debug('Active Properties: ' + activeProperties);
        System.debug('Test actual settlement date: '+activeProperties[0].Actual_Settlement_Date__c);
        Id queueId = [SELECT Id FROM Group WHERE Name = 'VHF Annual Review Queue' AND Type = 'Queue' LIMIT 1].Id;
        //Call BusinessDaysCalculation.getWorkingDayDateAfterNDays with 10 business working days
        Datetime now = Datetime.now();
        String currentDateTime = now.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        string sMethodName = 'getWorkingDayDateAfterNDays';
        Map<String, Object> inputMap = new Map<String, Object>{'NthWorkingDay'=>10,'startDate'=>currentDateTime};
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        new BusinessDaysCalculation().invokeMethod(sMethodName, inputMap, outputMap, options);
        Date dueDate = (Date)outputMap.get('NthWorkingDay_Date');
        List<Annual_Review__c> annualReviewRecordsToInsert= new List<Annual_Review__c>();
        list<Id> primaryApplicantContactIds = new list<Id>();

        for(Order activeProperty: activeProperties){

            // Calculate Annual Review Period
            date startDate = date.newInstance(specifiedYear-1, activeProperty.Actual_Settlement_Date__c.month(), activeProperty.Actual_Settlement_Date__c.day());
            date endDate = startDate.addYears(1).addDays(-1);
            System.debug('Start Date: ' + startDate + ' End Date: ' + endDate);

            Account primaryApplicant;
            Id primaryApplicantContactId;
            List<Account> nonPrimaryApplicants = new List<Account>();
            System.debug('related accounts: ' + activeProperty.Accounts__r);
            for(Account applicant: activeProperty.Accounts__r){
                System.debug('*** Active Property: ' + activeProperty.Id);
                System.debug('*** Debug: ' + applicant.Name + ' ID: ' + applicant.Id);
                if(applicant.Primary_Participant__pc == true){
                    primaryApplicant = applicant;
                    primaryApplicantContactId = applicant.PersonContactId;
                }else if(applicant.IsActiveApplicant__pc == 'Yes' && applicant.Primary_Participant__pc == false){
                    nonPrimaryApplicants.add(applicant);
                }
            } // End - for(Account)
            System.debug('Non Primary Applicants: ' + nonPrimaryApplicants);

            primaryApplicantContactIds.add(primaryApplicantContactId);

            if(nonPrimaryApplicants.size() == 0){
                annualReviewRecordsToInsert.add(new Annual_Review__c(
                                                OwnerId = queueId,
                                                Status__c = 'Awaiting Submission',
                                                Primary_Participant__c = primaryApplicant.Id,
                                                Property__c = activeProperty.Id,
                                                Due_Date__c = dueDate,
                                                Participant_Name_1__c = primaryApplicant.Name,
                								campaign__c = campaignId,
                                                Annual_Review_Start_Date__c = startDate,
                                                Annual_Review_End_Date__c = endDate));
            }else if(nonPrimaryApplicants.size() == 1){
                annualReviewRecordsToInsert.add(new Annual_Review__c(
                                                OwnerId = queueId,
                                                Status__c = 'Awaiting Submission',
                                                Primary_Participant__c = primaryApplicant.Id,
                                                Participant_Two__c = nonPrimaryApplicants[0].Id,
                                                Property__c = activeProperty.Id,
                                                Due_Date__c = dueDate,
                                                Participant_Name_1__c = primaryApplicant.Name,
                                                Participant_Name_2__c = nonPrimaryApplicants[0].Name,
                								campaign__c = campaignId,
                                                Annual_Review_Start_Date__c = startDate,
                                                Annual_Review_End_Date__c = endDate));
            }else if(nonPrimaryApplicants.size() == 2){
                annualReviewRecordsToInsert.add(new Annual_Review__c(
                                                OwnerId = queueId,
                                                Status__c = 'Awaiting Submission',
                                                Primary_Participant__c = primaryApplicant.Id,
                                                Participant_Two__c = nonPrimaryApplicants[0].Id,
                                                Participant_Three__c = nonPrimaryApplicants[1].Id,
                                                Property__c = activeProperty.Id,
                                                Due_Date__c = dueDate,
                                                Participant_Name_1__c = primaryApplicant.Name,
                                                Participant_Name_2__c = nonPrimaryApplicants[0].Name,
                                                Participant_Name_3__c = nonPrimaryApplicants[1].Name,
                								campaign__c = campaignId,
                                                Annual_Review_Start_Date__c = startDate,
                                                Annual_Review_End_Date__c = endDate));
            }else if(nonPrimaryApplicants.size() == 3){
                annualReviewRecordsToInsert.add(new Annual_Review__c(
                                                OwnerId = queueId,
                                                Status__c = 'Awaiting Submission',
                                                Primary_Participant__c = primaryApplicant.Id,
                                                Participant_Two__c = nonPrimaryApplicants[0].Id,
                                                Participant_Three__c = nonPrimaryApplicants[1].Id,
                                                Participant_Four__c = nonPrimaryApplicants[2].Id,
                                                Property__c = activeProperty.Id,
                                                Due_Date__c = dueDate,
                                                Participant_Name_1__c = primaryApplicant.Name,
                                                Participant_Name_2__c = nonPrimaryApplicants[0].Name,
                                                Participant_Name_3__c = nonPrimaryApplicants[1].Name,
                                                Participant_Name_4__c = nonPrimaryApplicants[2].Name,
                								campaign__c = campaignId,
                                                Annual_Review_Start_Date__c = startDate,
                                                Annual_Review_End_Date__c = endDate));
            }
        } // End - for(Order)

        if (campaignId != null){
            // Create Campaign Member Records
            list<CampaignMember> campaignMembersToInsert = new list<CampaignMember>();
            for(Id primaryAppContactId: primaryApplicantContactIds){
                campaignMembersToInsert.add(new CampaignMember(CampaignId = campaignId, ContactId = primaryAppContactId, Status = 'Pending'));
            } // End for(Id)
            // Insert Campaign Member Records
            list<Id> successfullyInsertedCampaignMemberRecords = new list<Id>();
            if(!campaignMembersToInsert.isEmpty()){
                list<Database.SaveResult> saveResults = Database.insert(campaignMembersToInsert, false);
                for(Database.SaveResult sr: saveResults){
                    if(sr.isSuccess()){
                        successfullyInsertedCampaignMemberRecords.add(sr.getId());
                    } else {
                        for(Database.Error err: sr.getErrors()){
                            System.debug('ERROR OCCURED: Failed Campaign Member Insertion: ID = '+sr.Id+' Status Code: '+err.getStatusCode()+ 'Message: '+err.getMessage());
                        }
                    }
                } // End - for(Database.saveResult)
            }
            if(!successfullyInsertedCampaignMemberRecords.isEmpty()){
                System.debug('*** Successfully Inserted Campaign Members: '+successfullyInsertedCampaignMemberRecords);
            }
        }
        
        // Insert Annual Review Records
        list<Id> successfullyInsertedAnnualReviewRecords = new list<Id>();
        list<Id> failureRecords = new list<Id>();
        Integer totalRecords = 0, errorRecords = 0, successfulRecords = 0;
        String processLog = '';
        if(!annualReviewRecordsToInsert.isEmpty()){
            list<Database.SaveResult> saveResults = Database.insert(annualReviewRecordsToInsert, false);
            for(Database.SaveResult sr: saveResults){
                if(sr.isSuccess()){
                    successfulRecords++;
                    successfullyInsertedAnnualReviewRecords.add(sr.getId());
                } else {
                    for(Database.Error err: sr.getErrors()){
                        errorRecords++;
                        String error = 'ERROR OCCURED: Failed Annual Review Insertion: ID = '+sr.Id+' Status Code: '+err.getStatusCode()+ 'Message: '+err.getMessage();
                        System.debug(error);
                        failureRecords.add(sr.Id);
                        processLog += error  + '<br>';
                    }
                }
            } // End - for(Database.saveResult)
        }
        if(!successfullyInsertedAnnualReviewRecords.isEmpty()){
            System.debug('*** Successfully Inserted Annual Reviews: '+successfullyInsertedAnnualReviewRecords);
        }
        if(!failureRecords.isEmpty()){
            processLog = 
            '#########################' + '<br>' +
            'Annual Review Insertion' + '<br>' +
            'End DateTime: ' + DateTime.now() + '<br>' +
            'Total Success Records: ' + successfulRecords + '<br>' +
            'Total Failed Records: ' + errorRecords + '<br>' +
            'List of Failed Records: ' + failureRecords + '<br>' +
            '#########################' + '<br>' +
            processLog;

            // Notify Admin of Failed Records
            list<Messaging.SingleEmailMessage> singleEmailMessages = new list<Messaging.SingleEmailMessage>();
            // Awaiting email address from vhf-2787. Implement using custom metadata type.
            list<String> toAddresses = new list<String>{'test@sro.vic.gov.au.invalid'};
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setSubject('Test Single Email');
            singleEmail.setToAddresses(toAddresses);
            singleEmail.setHtmlBody(processLog);
            singleEmail.setSubject('Annual Review Batch Failure');
            singleEmailMessages.add(singleEmail);
            Messaging.sendEmail(singleEmailMessages);
        }

        return successfullyInsertedAnnualReviewRecords;
    }
}