/*******************************************************************************************
* @Name         AnnualReviewRerunBatchTest
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         12/11/2021
* @Description  Tests AnnualReviewRerunBatch.cls
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      21/10/2021          Initial Creation
*******************************************************************************************/
@isTest
public with sharing class AnnualReviewRerunBatchTest {
    // Keep scope less than or equal to batchSize for assertion to work
    private static integer scope = 20;
    private static integer batchSize = 20;
    public static testMethod void testRerunAnnualReviewBatch(){
        // Create Person Account Records
        Id personAccountRT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        list<Account> individualAccounts = new list<account>();
        for(Integer i = 0; i < scope; i++){
                individualAccounts.add(new Account(FirstName = 'Test' + i,
                                            LastName = 'Person Account',
                                            RecordTypeId = personAccountRT_ID,
                                            Is_Participant__pc = True,
                                            Primary_Participant__pc = True,
                                            IsActiveApplicant__pc = 'Yes',
                                            personEmail = 'testEmail@sro.vic.gov.au.invalid',
                                            PersonMailingStreet = '2 ABC Street',
                                            PersonMailingCity = 'Melbourne',
                                            PersonMailingState = 'Victoria',
                                            PersonMailingPostalCode = '3000'));
        }
        insert individualAccounts;
        // Create Business Account Record
        Id businessAccountRT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account businessAccount = new Account(Name = 'Bank of Victoria', 
                                                RecordTypeID = businessAccountRT_ID);
        insert businessAccount;
        // Create Property Records
        integer currentMonth = Date.today().month();
        Integer lastYear = Date.today().year() - 1;
        list<Order> properties = new list<Order>();
        for(Integer i = 0; i < scope; i++){
            properties.add(new Order(AccountId = individualAccounts[i].Id,
                                        EffectiveDate = Date.newInstance(lastYear, currentMonth, 4),
                                        status = 'Draft',
                                        Panel_Financier_Name__c = businessAccount.Id,
                                        Actual_Settlement_Date__c = Date.newInstance(lastYear, currentMonth, 4)));
        }
        insert properties;
        for(integer i = 0; i < scope; i++){
            individualAccounts[i].Property__c = properties[i].Id;
        }
        update individualAccounts;

        // Attach One Secondary Applicant
        list<Account> oneSecondaryApplicants = AnnualReviewBatchTest.generatePersonAccounts(1, 'alpha');
        oneSecondaryApplicants[0].Property__c = properties[0].Id;
        update oneSecondaryApplicants;

        // Attach Two Secondary Applicant
        list<Account> twoSecondaryApplicants = AnnualReviewBatchTest.generatePersonAccounts(2, 'beta');
        twoSecondaryApplicants[0].Property__c = properties[1].Id;
        twoSecondaryApplicants[1].Property__c = properties[1].Id;
        update twoSecondaryApplicants;

        // Attach Three Secondary Applicant
        list<Account> threeSecondaryApplicants = AnnualReviewBatchTest.generatePersonAccounts(3, 'tango');
        threeSecondaryApplicants[0].Property__c = properties[2].Id;
        threeSecondaryApplicants[1].Property__c = properties[2].Id;
        threeSecondaryApplicants[2].Property__c = properties[2].Id;
        update threeSecondaryApplicants;

        // Run Batch
        Test.startTest();
        //AnnualReviewBatch annualReview = new AnnualReviewBatch();
        //Id batchProcessId = Database.executeBatch(annualReview, batchSize);
        list<Integer> month = new list<Integer>{Date.today().month(), Date.today().year()};
        list<list<Integer>> runVariable = new list<list<Integer>>();
        runVariable.add(month);
        AnnualReviewRerunBatch.AnnualReviewRerunBatch(runVariable);
        Test.stopTest();
        // Check Result
        Integer countAnnualReviews = [SELECT COUNT() FROM Annual_Review__c];
        System.assertEquals(scope, countAnnualReviews);
        
        //Check Campaign ID of Annual Reviews and Campaign Members are populated
        List<Annual_Review__c> AR = [SELECT Id, campaign__c FROM Annual_Review__c];
        for (Annual_Review__c myAR: AR){
            System.assertNotEquals(null, myAR.Campaign__c);
        }
        
        List<CampaignMember> members = [SELECT Id, CampaignId FROM CampaignMember];
        for (CampaignMember myCM: members){
            System.assertNotEquals(null, myCM.CampaignId);
        }
    }
}