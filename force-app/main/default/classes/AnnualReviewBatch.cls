/*******************************************************************************************
* @Name         AnnualReviewBatch 
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         31/08/2021
* @Description  This class when executed via scheduled job creates Annual Review records for valid 
                Property records which are linked to an Active Primary Participant
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      31/08/2021          Initial Creation   
*  1.1              Sebastian      15/09/2021          Class now populates Applicant names 
*  1.2              Sebastian      07/10/2021          Added campaign reference to Annual Review records 
*  1.3              Sebastian      26/10/2021          Moved Annual Review creation to a service class per vhf-2600 
*  1.4				Lawrence       08/11/2021		   Resequenced Annual Review creation after campaign creation
*  1.5              Sebastian      10/11/2021          Batch will no longer create new Reviews if one has already been created in the current month
*  1.6              Lawrence       09/02/2022          VHF-4450 (added isActive__c = True to the batch query as a criteria)
*******************************************************************************************/
global class AnnualReviewBatch extends batchjobsch.BatchJobBase implements Database.Batchable<sObject>{
    global Integer specifiedMonth = Date.today().month();
    global Integer specifiedYear = Date.today().year();

    // Method: start
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('*** Annual Review Batch - Start ***');

        Date checkDate = Date.newInstance(specifiedYear-1, 12, 31);

        String query = 'SELECT Id, Actual_Settlement_Date__c, (SELECT Id, Name, PersonContactId, Is_Participant__pc, Primary_Participant__pc, IsActiveApplicant__pc FROM Accounts__r) ' +
                        'FROM Order '+
                        'WHERE CALENDAR_MONTH(Actual_Settlement_Date__c) = ' + specifiedMonth + ' ' +
                        'AND IsActive__c = True ' +
                        'AND Id IN (SELECT Property__c FROM Account WHERE ' + 
                        'IsActiveApplicant__pc = \'Yes\' ' +
                        'AND Primary_Participant__pc = True AND Is_Participant__pc = True) ' +
                        'AND CALENDAR_YEAR(Actual_Settlement_Date__c) !=' + specifiedYear + ' '+
                        'AND Id NOT IN (SELECT Property__c FROM Annual_Review__c WHERE CALENDAR_YEAR(Annual_Review_End_Date__c) = '+ specifiedYear +' OR Annual_Review_End_Date__c = '+ string.valueOf(checkDate) +')';
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;
    }

    // Method: execute
    public void execute(Database.BatchableContext BC, list<Order> activeProperties){
  
        System.debug('*** Annual Review Batch - Execute ***');
        System.debug('Active Properties: ' + activeProperties);

        // Create Campaign Record
        String campaignName = 'Annual Review - ' + specifiedMonth + '/' + specifiedYear;
        Campaign campaign = new Campaign(Name = campaignName);
        // Insert Campaign Record
        try{
            upsert campaign Campaign.fields.Name;
        }catch(exception e){
            System.debug('ERROR OCCURED: Failed Campaign Insertion: '+e.getMessage());
        }
        // Check Campaign Member Status Pending Available
        CampaignMemberStatus pendingCampaignMemberStatus; 
        try{
            pendingCampaignMemberStatus = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId = :campaign.Id AND Label = 'Pending'];
        }catch(System.QueryException qe){
            pendingCampaignMemberStatus = new CampaignMemberStatus(Label = 'Pending', CampaignId = campaign.Id, isDefault = True);
            try{
                insert pendingCampaignMemberStatus;
            }catch(exception e){
                System.debug('ERROR OCCURED: Failed CampaignMemberStatus Insertion: '+e.getMessage());
            }
        }
        
        // Create Annual Review Records
        list<Id> generatedAnnualReviews = AnnualReviewGeneratorService.generateAnnualReviews(activeProperties, campaign.Id, specifiedYear);
     }

    // Method: finish
    public void finish(Database.BatchableContext BC){
        System.debug('*** Annual Review Batch - Finish ***');
        super.finishBatch(BC);
    }
}