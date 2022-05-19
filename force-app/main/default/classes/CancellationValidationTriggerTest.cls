/*******************************************************************************************
* @Name         CancellationValidationTriggerTest 
* @Author       Lawrence Tang
* @Date         19/10/2021
* @Description  This class is the test class of the Cancellation Validation Trigger
*               on Annual Review object
*******************************************************************************************/


@isTest
private class CancellationValidationTriggerTest {

      @testSetup static void setup() {
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
        insert property;
        participant.Property__c = property.Id;
        update participant;
        Annual_Review__c ar = new Annual_Review__c();
        ar.Status__c = 'Awaiting Submission';
        ar.Primary_Participant__c =  participant.Id;
        ar.Property__c = property.Id;
        insert ar;
        Case activeCase = new Case();
        activeCase.Annual_Review__c = ar.Id;
        activeCase.Status = 'New';
        activeCase.Subject = 'Test';
        insert activeCase;          
    }
    
    @isTest static void testActiveCase(){
        Annual_Review__c annualReview = [select id from Annual_Review__c LIMIT 1];
        annualReview.Status__c = 'Cancelled';
        annualReview.Cancellation_Reason__c = 'No longer needed';
        try {
           update annualReview; 
        }
        catch (System.DmlException e){
            System.debug('Exception: ' + e.getMessage());
        }
       Annual_Review__c updatedAR = [select id, Status__c from Annual_Review__c LIMIT 1];
        System.assert(updatedAR.Status__c == 'Awaiting Submission','Assertion failed: Status should remain in Awaiting Submission');    
    }
    
    @isTest static void testCloseCase(){
        Case openCase = [select id from Case LIMIT 1];
        openCase.Status = 'Closed';
        try {
           update openCase; 
        }
        catch (System.DmlException e){
            System.debug('Exception: ' + e.getMessage());
        }
        Annual_Review__c annualReview = [select id from Annual_Review__c LIMIT 1];
        annualReview.Status__c = 'Cancelled';
        annualReview.Cancellation_Reason__c = 'No longer needed';
        try {
           update annualReview; 
        }
        catch (System.DmlException e){
            System.debug('Exception: ' + e.getMessage());
        }
       Annual_Review__c updatedAR = [select id, Status__c from Annual_Review__c LIMIT 1];
       System.assert(updatedAR.Status__c == 'Cancelled','Assertion failed: Status should be Cancelled');    
    }
}