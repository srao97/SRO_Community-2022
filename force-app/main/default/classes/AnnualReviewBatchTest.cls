/*******************************************************************************************
* @Name         AnnualReviewBatchTest 
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         31/08/2021
* @Description  This class tests the functionality of the class AnnualReviewBatch
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      31/08/2021          Initial Creation          
*  1.1              Sebastian      16/09/2021          Tested instance were property has 
                                                       multiple applicants      
*  1.2              Lawrence       08/11/2021          Added Manual AR creation test 
*******************************************************************************************/
@IsTest
public with sharing class AnnualReviewBatchTest {
    // Keep scope less than or equal to batchSize for assertion to work
    private static integer scope = 20;
    private static integer batchSize = 20;

    public static list<Account> generatePersonAccounts(Integer numberOfAccounts, String lastName){
        // Create Person Account Records
        Id personAccountRT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        list<Account> individualAccounts = new list<account>();
        for(Integer i = 0; i < numberOfAccounts; i++){
                individualAccounts.add(new Account(FirstName = 'Test' + i,
                                            LastName = lastName,
                                            RecordTypeId = personAccountRT_ID,
                                            Is_Participant__pc = True,
                                            Primary_Participant__pc = False,
                                            IsActiveApplicant__pc = 'Yes',
                                            personEmail = 'testEmail@sro.vic.gov.au.invalid',
                                            PersonMailingStreet = '2 ABC Street',
                                            PersonMailingCity = 'Melbourne',
                                            PersonMailingState = 'Victoria',
                                            PersonMailingPostalCode = '3000'));
        }
        insert individualAccounts;
        return [SELECT Id FROM Account WHERE LastName = :lastName];
    } 

    @IsTest
    public static void  testInsertPropertyRecords(){
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
        list<Account> oneSecondaryApplicants = generatePersonAccounts(1, 'alpha');
        oneSecondaryApplicants[0].Property__c = properties[0].Id;
        update oneSecondaryApplicants;

        // Attach Two Secondary Applicant
        list<Account> twoSecondaryApplicants = generatePersonAccounts(2, 'beta');
        twoSecondaryApplicants[0].Property__c = properties[1].Id;
        twoSecondaryApplicants[1].Property__c = properties[1].Id;
        update twoSecondaryApplicants;

        // Attach Three Secondary Applicant
        list<Account> threeSecondaryApplicants = generatePersonAccounts(3, 'tango');
        threeSecondaryApplicants[0].Property__c = properties[2].Id;
        threeSecondaryApplicants[1].Property__c = properties[2].Id;
        threeSecondaryApplicants[2].Property__c = properties[2].Id;
        update threeSecondaryApplicants;

        // Run Batch
        Test.startTest();
        AnnualReviewBatch annualReview = new AnnualReviewBatch();
        Id batchProcessId = Database.executeBatch(annualReview, batchSize);
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
    
    @IsTest
    public static void testManualARCreation(){
        // Create Property Records
        integer currentMonth = Date.today().month();
        Integer lastYear = Date.today().year() - 1;
        
        Id personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'].Id;
        Account participant = new Account();
        participant.FirstName = 'John';
        participant.LastName = 'West';
        participant.RecordTypeId = personAccountRecordType;
        participant.PersonMailingStreet = '2 ABC Street';
        participant.PersonMailingCity = 'Melbourne';
        participant.PersonMailingState = 'Victoria';
        participant.PersonMailingPostalCode = '3000';
        participant.PersonEmail = 'test@test.com';
        participant.IsActiveApplicant__pc = 'Yes';
        participant.Is_Participant__pc = true;
        participant.Primary_Participant__pc = true;
        insert participant;
        Account lender = new Account();
        lender.Name = 'aBank';
        insert lender;
        Order property = new Order();
        property.Name = 'A property';
        property.Status = 'Draft';
        property.AccountId = participant.Id;
        property.EffectiveDate = System.today();
        property.Panel_Financier_Name__c = lender.Id;
        property.Actual_Settlement_Date__c = Date.newInstance(lastYear, currentMonth, 4);
        insert property;
        participant.Property__c = property.Id;
        update participant;
        Annual_Review__c ar = new Annual_Review__c();
        ar.Status__c = 'Cancelled';
        ar.Cancellation_Reason__c = 'No longer needed';
        ar.Primary_Participant__c =  participant.Id;
        ar.Property__c = property.Id;
        ar.Annual_Review_Start_Date__c = Date.newInstance(lastYear, currentMonth, 4);
        insert ar;
        List<Id> annualReviewId = new List<id>();
        annualReviewId.add(ar.Id);
        List<Id> newARId = AnnualReviewGeneratorService.AnnualReviewGeneratorService(annualReviewId);
        System.assertNotEquals(null, newARId[0]);
        System.assertNotEquals(ar.Id, newARId[0]);
    }
}