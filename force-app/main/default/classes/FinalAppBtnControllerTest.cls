//Added testExtendExpDateBtn - Nayana R - Oct 1st
@IsTest
public with sharing class FinalAppBtnControllerTest {

   
  private static final String PROFILE = 'VHF Lender Community Plus User';
  

  @TestSetup
  private static void setupData(){
    Id vhfApplicationsCaseRT_Id = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VHF_Application_Record_Type').getRecordTypeId();

    UserRole customRole = VHFTestDataFactory.createCustomRole('CustomRole', 'CustomRole');
    insert customRole;
    
    User userWithARole = VHFTestDataFactory.createAdminUser(customRole.Id, 'testSysAdUser@test.com', 'testSysAdUser@test.com' + System.currentTimeMillis(), 'Role', 'User', 'alias');
    insert userWithARole;
    
    user sysAdUser = [SELECT Id FROM user WHERE Email = 'testSysAdUser@test.com'];
    System.runAs(sysAdUser) 
    {
        Account oOzBankRecord = VHFTestDataFactory.createLenderAccount('Oz Bank');
        insert oOzBankRecord;

        Contact oContact = VHFTestDataFactory.createLenderContact(oOzBankRecord.Id, 'lender', 'officer1', 'lender.Officer1@getnada.com', '+61 2 9311 1111');
        insert oContact;
            
        Profile communityProfile = [SELECT Id FROM profile WHERE Name = :PROFILE Limit 1];
        String nickName = oContact.LastName + '_' + System.currentTimeMillis();
        String alias = string.valueOf(oContact.LastName.substring(0,1) + Math.random() ).substring(0,5);
        User comPortalUser = VHFTestDataFactory.createCommunityUser(oContact.Id, oContact.Email, oContact.LastName, oContact.Email, nickName, alias, communityProfile.Id);
        insert comPortalUser;
            
        Account oApplicantPersonAccountRecord = VHFTestDataFactory.createApplicantPersonAccount('Yes');
        insert oApplicantPersonAccountRecord;

        System.debug('*** Results: ' + oApplicantPersonAccountRecord);

        Case applicationCase = VHFTestDataFactory.createCase(oApplicantPersonAccountRecord.Id, 'In Progress', 'Pending', vhfApplicationsCaseRT_Id);
        insert applicationCase;
        
        RegulatoryAuthorizationType authType = VHFTestDataFactory.createRegAuth('Victorian HomebuyerFund', 'License');
        insert authType;
        
        IndividualApplication oIndividualApplication = VHFTestDataFactory.createProvisionalApplication(authType.Id, oOzBankRecord.Id, oContact.Id, oApplicantPersonAccountRecord.Id,applicationCase.Id );
        insert oIndividualApplication;
        
        Applicant__c oApplicant = VHFTestDataFactory.createApplicant(oApplicantPersonAccountRecord.Id, oIndividualApplication.Id);
        insert oApplicant;

        Contract finalApp = VHFTestDataFactory.createFinalApplication(oIndividualApplication.Id, oApplicantPersonAccountRecord.Id, 'Final Application Submitted', applicationCase.Id, 28, '1', 'PS832324H', '1', 1, oContact.Id);
        insert finalApp;
    }
  }

  @isTest 
  private static void testGetBtnVisibileFalse() {
      Test.startTest();
      IndividualApplication app = [Select Id from IndividualApplication LIMIT 1];
      Boolean result = FinalAppBtnController.getBtnVisibile(app.Id);
      System.assertEquals(false, result);
      Test.stopTest();
  }

  @isTest static void testExtendExpDateBtn()
    {
        Test.startTest();
        Account acc = [Select Id, Name from Account where name = 'Oz Bank'];
        Account applicant = [Select Id, Name from Account where PersonEmail = 'test@email.com.invalid'];
        IndividualApplication app = [Select Id, Status, ByPassValidation__c from IndividualApplication where Lender_Account__c =: acc.Id];
        Case cs = [Select Id, Status, Sub_Status__c from Case where accountId =: applicant.Id];

        app.status = 'Provisionally Approved';
        app.ByPassValidation__c = false;
        update app;
        

        boolean result = FinalAppBtnController.displayButtonForExpiry(app.Id);
        Test.stopTest();
    }

    @isTest static void testGetBtnVisibileTrue()
    {
        Test.startTest();
        Individualapplication app = [Select Id from Individualapplication LIMIT 1];
        app.status = 'Rejected';
        app.Cancellation_Reason__c = 'Customer request';
        app.Rejection_Reason__c = 'Applicant owns a property in Victoria';
        update app;

        boolean result = FinalAppBtnController.getBtnVisibile(app.Id);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest private static void testExpiry() {
        Test.startTest();
        IndividualApplication app = [Select Id from IndividualApplication LIMIT 1];
        app.status = 'Provisionally Approved';
        app.Hard_Expiry_Date__c = System.today();
        app.Final_Application_In_Progress_c__c = false;
        app.Second_Extension_Requested__c = false;
        update app;

        boolean result = FinalAppBtnController.displayButtonForExpiry(app.Id);
        System.assertEquals(true, result);
    }


}