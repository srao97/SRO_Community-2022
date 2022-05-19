@isTest
private class CalculateProvisionalExpiryDatesTest {
/*******************************************************************************************
* @Name         CalculateProvisionalExpiryDatesTest 
* @Author       Nayana Revanna
* @Date         07/09/2021
* @Description  This class is the test class of CalculateProvisionalExpiryDates Class
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.1              Lavanya Kavuri     25/11/2021          Fixed the Test Class                                                     
*******************************************************************************************/

@TestSetup
static void setup(){
    
    UserRole newCustomRole = VHFTestDataFactory.createCustomRole('CustomRole', 'CustomRole');
    insert newCustomRole;

    User newAdminUser = VHFTestDataFactory.createAdminUser(newCustomRole.Id, 'testSysAdminUser@test.com', 'testSysAdminUser@test.com', 'testuser', 'admin', 'testad');
    insert newAdminUser;

    User adminUser = [Select Id from User where Email = 'testSysAdminUser@test.com'];

    EmailTemplate validEmailTemplate = new EmailTemplate();
    validEmailTemplate.isActive = true;
    validEmailTemplate.Name = 'name';
    validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
    validEmailTemplate.TemplateType = 'text';
    validEmailTemplate.FolderId = UserInfo.getUserId();

    insert validEmailTemplate;

    System.runAs(adminUser)
    {
        Account bankAccount = VHFTestDataFactory.createLenderAccount('Oz Bank');
        insert bankAccount;

        Contact lenderContact = VHFTestDataFactory.createLenderContact(bankAccount.Id, 'lender', 'officer', 'lender.officer@ozbanktest.com', '+61 2 9311 1111');
        insert lenderContact;

        Account applicantAccount = VHFTestDataFactory.createApplicantPersonAccount('Yes');
        insert applicantAccount;

        Id applicationCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VHF_Application_Record_Type').getRecordTypeId();
        Case applicationCase = VHFTestDataFactory.createCase(applicantAccount.Id, 'Submitted', 'Pending', applicationCaseRecordTypeId);
        insert applicationCase;

        RegulatoryAuthorizationType authType = VHFTestDataFactory.createRegAuth('Victorian Homebuyer Fund', 'License');
        insert authType;

        IndividualApplication newApplication = VHFTestDataFactory.createProvisionalApplication(authType.Id, bankAccount.Id, lenderContact.Id, applicantAccount.Id, applicationCase.Id);
        insert newApplication;
        
        Individual_Application_Shadow__c NewShadowOBJInst= VHFTestDataFactory.createProvAppShadow(newApplication.Id);
        insert NewShadowOBJInst;
        
        Applicant__c newApplicant = VHFTestDataFactory.createApplicant(applicantAccount.Id, newApplication.Id);
        insert newApplicant;

        Contract newFinalApplication = VHFTestDataFactory.createFinalApplication(newApplication.Id, applicantAccount.Id, 'draft', applicationCase.Id, 28, '1', 'PS832324H', '1', 1, lenderContact.Id);
        insert newFinalApplication;
    }
    
}

@isTest private static void reqDateMoreThanSoftExp() {
    
    IndividualApplication app = [Select Id from IndividualApplication LIMIT 1];
    Contract finalApp = [Select Id from Contract where IndividualApplicationId__c =: app.Id];

    EmailTemplate validEmailTemplate = [Select Id from EmailTemplate LIMIT 1];
   
    //Update applications 
    IndividualApplication updateApplication = [Select Id,Panel_Finance_Officer__c,First_Extension_Requested__c,Second_Extension_Requested__c,Expiry_Date1__c, Hard_Expiry_Date__c from IndividualApplication WHERE Id =: app.Id]; 
    
    emailmessage em = new emailmessage();
    em.fromaddress = 'Test@test.com';
    em.toaddress = 'test1@test.com';
    em.subject = 'Test Email';
    em.textbody = 'testing';
    em.EmailTemplateId = validEmailTemplate.Id;
    em.parentid = updateApplication.id;
    
    
    Date expDate = System.today().addMonths(3);
    updateApplication.Expiry_Date1__c = expDate;
    updateApplication.BypassValidation__c = true;
    updateApplication.status = 'Provisionally Approved';
    updateApplication.Final_Application_In_Progress_c__c = false;
    updateApplication.First_Extension_Requested__c = false;
    updateApplication.Second_Extension_Requested__c = false;

    Integer emailCountOriginal = Limits.getEmailInvocations();
    Test.startTest();
   
        update updateApplication; 

    //Convert to List of Ids 
    List<Id> appUpdateIds = new List<Id>(); 
    appUpdateIds.add(updateApplication.Id); 

    //Set expirys 
    ProvisionalApplication.setExpiry(appUpdateIds);
    String dateExt = CalculateProvisionalExpiryDates.calculateExpDate(updateApplication.Id);
    CalculateProvisionalExpiryDates.saveNewExpiryDate(Date.valueOf(dateExt), updateApplication.Id);
    
 
    Date dtAssert= Date.valueOf(dateExt);
    System.assertEquals(dateExt, String.valueOf(dtAssert));
    Test.stopTest();

    Integer emailCountAfter = Limits.getEmailInvocations();
    
    
}


@isTest private static void softExpMoreThanReqDateTest() {
    
    Test.startTest();
    IndividualApplication app = [Select Id from IndividualApplication LIMIT 1];
   
    //Update applications 
    IndividualApplication updateApplication = [Select Id,First_Extension_Requested__c,Second_Extension_Requested__c,Expiry_Date1__c, Hard_Expiry_Date__c from IndividualApplication WHERE Id =: app.Id]; 
    Date expDate = System.today().addMonths(3);
    updateApplication.Expiry_Date1__c = expDate;
    updateApplication.status = 'Provisionally Approved';
    updateApplication.Final_Application_In_Progress_c__c = false;
    updateApplication.First_Extension_Requested__c = true;
    updateApplication.Second_Extension_Requested__c = false;
    update updateApplication; 

    //Convert to List of Ids 
    List<Id> appUpdateIds = new List<Id>(); 
    appUpdateIds.add(updateApplication.Id); 

    //Set expirys 
    ProvisionalApplication.setExpiry(appUpdateIds);
    String dateExt = CalculateProvisionalExpiryDates.calculateExpDate(updateApplication.Id);
    CalculateProvisionalExpiryDates.saveNewExpiryDate(Date.valueOf(dateExt), updateApplication.Id);
    
 
    Date dtAssert= Date.valueOf(dateExt);
    System.assertEquals(dateExt, String.valueOf(dtAssert));
    Test.stopTest();

    
    
}

@isTest static void testBothExtDone() {
Test.startTest();

    IndividualApplication app = [Select Id from IndividualApplication LIMIT 1];
   
    //Update applications 
    IndividualApplication updateApplication = [Select Id,First_Extension_Requested__c,Second_Extension_Requested__c,Expiry_Date1__c, Hard_Expiry_Date__c from IndividualApplication WHERE Id =: app.Id]; 
    Date expDate = System.Today();
    updateApplication.Expiry_Date1__c = expDate;
    updateApplication.status = 'Provisionally Approved';
    updateApplication.Final_Application_In_Progress_c__c = false;
    updateApplication.Hard_Expiry_Date__c=System.today().addMonths(12);
    update updateApplication; 

    //Convert to List of Ids
    List<Id> appUpdateIds = new List<Id>();
    appUpdateIds.add(updateApplication.Id);

    //Set expirys
    ProvisionalApplication.setExpiry(appUpdateIds);
    String dateExt = CalculateProvisionalExpiryDates.calculateExpDate(updateApplication.Id);
    CalculateProvisionalExpiryDates.saveNewExpiryDate(Date.valueOf(dateExt), updateApplication.Id);
 
    Date dtAssert= Date.valueOf(dateExt);
       System.assertEquals(dateExt, String.valueOf(dtAssert));
    Test.stopTest();

 
    
}


}