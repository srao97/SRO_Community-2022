/*
* Description: Test class for caseTrigger  
** Version History ** 
Created: Sourabh Singh, 10/12/2021
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.1              Arjun             20/01/2022          Added test method for duration and validation duration calculation
*  1.2              Arjun Singh       03/02/2022          VHF-3082    
*  1.3              Manish             21/03/2022          VHF-4306
*/ 

@isTest
private class CaseTriggerHelperTest 
{   
    
    
    @TestSetup
    static void setup() 
    {    
        final Id LTA_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Long_Term_Absence').getRecordTypeId();
        
        UserRole newCustomRole = VHFTestDataFactory.createCustomRole('CustomRole', 'CustomRole');
        insert newCustomRole;
        
        User newAdminUser = VHFTestDataFactory.createAdminUser(newCustomRole.Id, 'testSysAdminUser@test.com', 'testSysAdminUser@test.com', 'testuser', 'admin', 'testad');
        insert newAdminUser;
        
        User adminUser = [Select Id from User where Email = 'testSysAdminUser@test.com'];
        
        System.runAs(adminUser)
        {
            Account accPerson = VHFTestDataFactory.createApplicantPersonAccountWithDetails('Yes', 'test', 'last', 'emailc@test.com');
            insert accPerson;
            
            
            Account acc = VHFTestDataFactory.createLenderAccount('Bank');
            insert acc;
            
            Order property = VHFTestDataFactory.createProperty(accPerson.Id, 'Draft', acc.Id);
            property.Actual_Settlement_Date__c = date.Today() - 10;
            insert property; 

            Annual_Review__c annualReview = VHFTestDataFactory.createAnnualReview(property.Id, accPerson.Id, date.today()-10, date.today()+354);
            insert annualReview;
            
           
            Case newLTACase = new Case();
            newLTACase.AccountId = accPerson.Id;
            newLTACase.ContactId = accPerson.PersonContactId;
            newLTACase.Status = 'New';
            newLTACase.Sub_Status__c = 'Pending';
            newLTACase.Subject = 'Test LTA case';
            newLTACase.recordTypeId = LTA_RECORDTYPEID;
            newLTACase.Property__c = property.id; 
            newLTACase.Annual_Review__c = annualReview.Id;
            insert newLTACase;

            
        
        }
    }
    
    public static testMethod void testResetBypass()        
    {
        Case c = [select id, status, BypassValidation__c from case limit 1 ];
        Test.startTest();
        c.status = 'In Review';
        c.BypassValidation__c = true;
        update c;
        Case cs = [select id, status, BypassValidation__c from case limit 1 ];
        System.assertEquals(cs.BypassValidation__c,false);
        Test.stopTest();         
    }
    public static testMethod void testTotalDuration()        
    {
        Case c = [select id, Absence_start_date__c, Absence_end_date__c from case limit 1 ];        
        c.Absence_start_date__c = date.today();
        c.Absence_end_date__c = date.today() + 92;

        Test.startTest();
        update c;
        Case cs = [select id, Absence_Duration_Months__c from case limit 1 ];        
        Test.stopTest();  
        System.assertEquals(cs.Absence_Duration_Months__c,3.0);
    }
    public static testMethod void testValidTotalDurationBeforeRange()        
    {
        Case c = [select id, Absence_start_date__c, Absence_end_date__c from case limit 1 ];        
        c.Absence_start_date__c = date.today() - 150;
        c.Absence_end_date__c = date.today() -90 ;

        Test.startTest();
        update c;
        Case cs = [select id, Valid_Absence_Duration_Months__c from case limit 1 ];        
        Test.stopTest(); 
        System.assertEquals(cs.Valid_Absence_Duration_Months__c,0);
    }
    public static testMethod void testValidTotalDurationInbetweenRange()        
    {
        Case c = [select id, Absence_start_date__c, Absence_end_date__c from case limit 1 ];        
        c.Absence_start_date__c = date.today() ;
        c.Absence_end_date__c = date.today() + 92 ;

        Test.startTest();
        update c;
        Case cs = [select id, Valid_Absence_Duration_Months__c from case limit 1 ];        
        Test.stopTest();  
        System.assertEquals(cs.Valid_Absence_Duration_Months__c,3.0);
    }
    public static testMethod void testValidTotalDurationInbetweenAndOutOfRange()        
    {
        Case c = [select id, Absence_start_date__c, Absence_end_date__c from case limit 1 ];        
        c.Absence_start_date__c = date.today() + 350;
        c.Absence_end_date__c = date.today() + 450 ;

        Test.startTest();
        update c;
        Case cs = [select id, Valid_Absence_Duration_Months__c from case limit 1 ];        
        Test.stopTest();  
        System.assertEquals(cs.Valid_Absence_Duration_Months__c,0.1);
    }
    public static testMethod void testValidTotalDurationOutOfRange()        
    {
        Case c = [select id, Absence_start_date__c, Absence_end_date__c from case limit 1 ];        
        c.Absence_start_date__c = date.today() + 390;
        c.Absence_end_date__c = date.today() + 450 ;

        Test.startTest();
        update c;
        Case cs = [select id, Valid_Absence_Duration_Months__c from case limit 1 ];        
        Test.stopTest(); 
        System.assertEquals(cs.Valid_Absence_Duration_Months__c,0.0);
    }
    public static testMethod void testParticipantPortalCreatedCases()        
    {
        Case c = [select id, Absence_start_date__c, Absence_end_date__c from case limit 1 ];        
        c.Absence_start_date__c = date.today() + 20;
        c.Absence_end_date__c = date.today() + 50 ;
        c.Origin = 'Participant Portal';
        c.Status = 'In Review';
        Test.startTest();
        update c;
        Case cs = [select id, Valid_Absence_Duration_Months__c, Absence_Duration_Months__c from case limit 1 ];        
        Test.stopTest(); 
        System.assertEquals(cs.Valid_Absence_Duration_Months__c,0.0);
    }
    public static testMethod void testFullPaymentCaseValidation()        
    {   Account participantRecord = [Select Id,PersonContactId from Account where PersonEmail ='emailc@test.com'];
        Id fullPaymentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Final_Payment').getRecordTypeId();
        Order property = [Select Id From Order limit 1];
        
        participantRecord.Property__c = property.Id;
        participantRecord.Is_Participant__pc = true;
        participantRecord.Is_Participant__pc = true;
        update participantRecord;
       
       Case FullPaymentCase = new Case();
        FullPaymentCase.AccountId = participantRecord.Id;
        FullPaymentCase.ContactId = participantRecord.PersonContactId;
        FullPaymentCase.Status = 'New';
        FullPaymentCase.Sub_Status__c = 'Pending';
        FullPaymentCase.Subject = 'Test Full Payment case';
        FullPaymentCase.recordTypeId = fullPaymentRecordTypeId;
        FullPaymentCase.Property__c = property.id; 
        insert FullPaymentCase;

        Payment__c payment = VHFTestDataFactory.createPayment('Created', FullPaymentCase.Id, participantRecord.Id);
        insert payment;

        Test.startTest();
        try{            
            FullPaymentCase.status = 'Rejected';
            update FullPaymentCase;
        }catch(Exception e){
            String errMsg = e.getMessage();
            System.assert(errMsg.contains(CaseTriggerHelper.Err_Msg));
        }
        Test.stopTest();
    }
    
    public static testMethod void testFullPaymentCaseValidationCancellation()        
    {   Account participantRecord = [Select Id,PersonContactId from Account where PersonEmail ='emailc@test.com'];
        Id fullPaymentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Final_Payment').getRecordTypeId();
        Order property = [Select Id From Order limit 1];
        
        participantRecord.Property__c = property.Id;
        participantRecord.Is_Participant__pc = true;
        participantRecord.Is_Participant__pc = true;
        update participantRecord;
       
       Case FullPaymentCase = new Case();
        FullPaymentCase.AccountId = participantRecord.Id;
        FullPaymentCase.ContactId = participantRecord.PersonContactId;
        FullPaymentCase.Status = 'New';
        FullPaymentCase.Sub_Status__c = 'Pending';
        FullPaymentCase.Subject = 'Test Full Payment case';
        FullPaymentCase.recordTypeId = fullPaymentRecordTypeId;
        FullPaymentCase.Property__c = property.id; 
        insert FullPaymentCase;

        Payment__c payment = VHFTestDataFactory.createPayment('Created', FullPaymentCase.Id, participantRecord.Id);
        insert payment;

        Test.startTest();
        try{            
            FullPaymentCase.status = 'Cancelled';
            update FullPaymentCase;
        }catch(Exception e){
            String errMsg = e.getMessage();
            System.assert(errMsg.contains(CaseTriggerHelper.Err_Msg_Cancellation));
        }
        Test.stopTest();
    }
     public static testMethod void testITE_CaseValidationCancellation()        
    {   Account participantRecord = [Select Id,PersonContactId from Account where PersonEmail ='emailc@test.com'];
        Id ITERecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Income_Threshold_Exceeded').getRecordTypeId();
        Order property = [Select Id From Order limit 1];
        
        participantRecord.Property__c = property.Id;
        participantRecord.Is_Participant__pc = true;
        participantRecord.Is_Participant__pc = true;
        update participantRecord;
       
       Case ITECase = new Case();
        ITECase.AccountId = participantRecord.Id;
        ITECase.ContactId = participantRecord.PersonContactId;
        ITECase.Status = 'New';
        ITECase.Sub_Status__c = 'Pending';
        ITECase.Subject = 'Test ITE case';
        ITECase.recordTypeId = ITERecordTypeId;
        ITECase.Property__c = property.id; 
        ITECase.BypassValidation__c = true;
        ITECase.Cancellation_Reason_Comments__c = 'Test close comments';
        ITECase.Cancellation_Reason__c = 'Other';
        insert ITECase;

        Payment__c payment = VHFTestDataFactory.createPayment('Created', ITECase.Id, participantRecord.Id);
        insert payment;

        Test.startTest();
        try{            
            ITECase.Status = 'Cancelled';
            update ITECase;
        }catch(Exception e){
            String errMsg = e.getMessage();
            System.debug('Error Message: ' + errMsg);
            System.assert(errMsg.contains(CaseTriggerHelper.Err_Msg_Cancellation));
        }
        Test.stopTest();
    }
}