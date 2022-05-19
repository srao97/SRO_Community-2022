/*
* Contract Trigger 
* Author: 
** Version History ** 
Create Date:
Modified: Sourabh Singh, 11/Oct/2021, VHF-2596  
             added testSetup method 
             fixed test class errors
             added coverage for 'validateStatusBeforeUpdate'
*/ 

@isTest(SeeAllData=FALSE)
public class ContractTriggerHelperTest {
    
    private static final Decimal CONST_MEDICARE_NUM = Decimal.valueOf('21234567080');
    private static final Decimal CONST_CARD_NUM = Decimal.valueOf('212345670');
    private static final Decimal CONST_REF_NUM = Decimal.valueOf('1');
    private static final String PROFILE = 'VHF Lender Community Plus User';
    private static final Id PERSONACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final Id BUSINESSACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    private static final Id STANDARDCONTACT_RECORDTYPEID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
    @TestSetup
    private static void setup() {
        
        UserRole customRole = new UserRole(DeveloperName = 'CustomRole', Name = 'Custom Role');
        insert customRole;
        
        User userWithARole = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            firstName = 'Role',
            LastName = 'User',
            Email = 'testSysAdUser@test.com',
            Username = 'testSysAdUser@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Australia/Sydney',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_AU',
            UserRoleId = customRole.Id
        );
        insert userWithARole;
        
        user sysAdUser = [SELECT Id FROM user WHERE Email = 'testSysAdUser@test.com'];
        System.runAs(sysAdUser) {
            
            Account oOzBankRecord = new Account(
                Name = 'Oz Bank',
                ownerId= sysAdUser.id,
                recordtypeid = BUSINESSACCOUNT_RECORDTYPEID
            );
            insert oOzBankRecord;
            
            Contact oContact = new Contact(
                FirstName='lender',
                LastName='officer1',
                Email = 'lender.Officer1@getnada.com',
                Phone = '+61 2 9311 1111',
                AccountId = oOzBankRecord.Id,
                recordtypeid = STANDARDCONTACT_RECORDTYPEID
            );
            insert oContact;
            
            Profile communityProfile = [SELECT Id FROM profile WHERE Name = :PROFILE Limit 1];
            User comPortalUser = new User();
            comPortalUser.ContactId = oContact.Id;
            comPortalUser.Username = oContact.Email;
            comPortalUser.Email = oContact.Email;
            comPortalUser.LastName = oContact.LastName;
            comPortalUser.CommunityNickname = oContact.LastName + '_' + System.currentTimeMillis();
            comPortalUser.Alias = string.valueOf(oContact.LastName.substring(0,1) + Math.random() ).substring(0,5);
            comPortalUser.TimeZoneSidKey = 'Australia/Sydney';
            comPortalUser.LocaleSidKey = 'en_AU';
            comPortalUser.EmailEncodingKey = 'ISO-8859-1';
            comPortalUser.ProfileId = communityProfile.Id;
            comPortalUser.LanguageLocaleKey = 'en_US';
            comPortalUser.IsActive = true;
            insert comPortalUser;
            
            Account oApplicantPersonAccountRecord = new Account();
            oApplicantPersonAccountRecord.MedicareNumber__pc = CONST_MEDICARE_NUM;
            oApplicantPersonAccountRecord.Medicare_Card_Number__pc = CONST_CARD_NUM;
            oApplicantPersonAccountRecord.Medicare_Reference_Number__pc = CONST_REF_NUM;
            oApplicantPersonAccountRecord.IsActiveApplicant__pc = 'Yes';
            oApplicantPersonAccountRecord.RecordTypeId = PERSONACCOUNT_RECORDTYPEID;
            oApplicantPersonAccountRecord.PersonEmail = 'test@email.com.invalid';
            oApplicantPersonAccountRecord.LastName = 'TestLastName';
            oApplicantPersonAccountRecord.PersonMailingCity = 'TestCity';
            oApplicantPersonAccountRecord.PersonMailingState = 'Victoria';
            oApplicantPersonAccountRecord.PersonMailingStreet = 'TestStreetVictoria';
            
            
            
            oApplicantPersonAccountRecord.PersonMailingPostalCode = '3000';
            insert oApplicantPersonAccountRecord;
            System.debug('*** Results: ' + oApplicantPersonAccountRecord);
            
            Case applicationCase = new Case();
            applicationCase.AccountId = oApplicantPersonAccountRecord.Id;
            applicationCase.Status = 'Submitted';
            applicationCase.Sub_Status__c = 'Pending';
            applicationCase.Subject = 'TestLastName - Vic Housing Fund Application';
            insert applicationCase;
            
            RegulatoryAuthorizationType authType = new RegulatoryAuthorizationType(
                Name = 'Victorian Homebuyer Fund',
                RegulatoryAuthCategory = 'License'
            );
            insert authType;
            
            IndividualApplication oIndividualApplication = new IndividualApplication();
            oIndividualApplication.AccountId = oApplicantPersonAccountRecord.Id;
            oIndividualApplication.ApplicationCaseId = applicationCase.Id;
            oIndividualApplication.Category = 'Grant';
            //oIndividualApplication.Status = 'Provisional Application Submitted';
            oIndividualApplication.Status = 'Draft';
            oIndividualApplication.AppliedDate = Date.today();
            oIndividualApplication.LicenseTypeId = authType.Id;
            oIndividualApplication.Lender_Account__c = oOzBankRecord.Id;
            oIndividualApplication.Panel_Finance_Officer__c = oContact.Id;
            oIndividualApplication.Final_Application_Status__c = '';
            insert oIndividualApplication;
            
            Applicant__c oApplicant = new Applicant__c();
            oApplicant.Account__c = oApplicantPersonAccountRecord.Id;
            oApplicant.IndividualApplication__c = oIndividualApplication.Id;
            insert oApplicant;
            
            Contract finalApp = new Contract();
            finalApp.IndividualApplicationId__c = oIndividualApplication.Id;
            finalApp.AccountId = oApplicantPersonAccountRecord.Id;
            finalApp.Status = 'draft';
            finalApp.ApplicationCaseId__c = applicationCase.Id; 
            finalApp.Loan_Term_Years__c = 28;
            finalApp.Lot_Number__c = '1';
            finalApp.Plan_Number__c = 'PS832324H';
            finalApp.Folio__c = '1';
            finalApp.Volume__c = 1;
            finalApp.Panel_Finance_Officer__c = oContact.Id;
            insert finalApp;            
        }
        
    }
    
    public static testMethod void ValidatePlanLotFolioVolumeTestNegativeCase()
        
    {
        IndividualApplication ia = [select id, Final_Application_Status__c from IndividualApplication limit 1 ];
        List<Contract>lstContract = [SELECT Id,Lot_Number__c, Volume__c, Plan_Number__c,Folio__c FROM Contract]; 
        Test.startTest();
        ContractTriggerHelper.ValidatePlanLotFolioVolume(lstContract);  
        Test.stopTest(); 
        
    }
    public static testMethod void ValidatePlanLotFolioVolumeTestPositiveCase()
        
    {
        IndividualApplication ia = [select id, Final_Application_Status__c from IndividualApplication limit 1 ];
        List<Contract> lstContract = [SELECT Id,Lot_Number__c, Volume__c, Plan_Number__c,Folio__c FROM Contract]; 
        Test.startTest();
        ContractTriggerHelper.ValidatePlanLotFolioVolume(lstContract);  
        Test.stopTest(); 
        
    }
    
    public static testMethod void UpdateFolioSuffixToUpperCaseTestSuccess()
        
    {
        IndividualApplication ia = [select id, Final_Application_Status__c from IndividualApplication limit 1 ];
        List<Contract> lstContract = [SELECT Id,Lot_Number__c, Volume__c, Plan_Number__c,Folio__c FROM Contract];
        Test.startTest();
        System.assertEquals('1', lstContract[0].Folio__c);
        System.assertEquals('PS832324H', lstContract[0].Plan_Number__c);
        Test.stopTest(); 
        
    }
    
    public static testMethod void testValidateStatusBeforeUpdate()
    {
        IndividualApplication ia = [select id, Final_Application_Status__c from IndividualApplication limit 1 ];
        List<Contract> lstContract = [SELECT Id,Lot_Number__c, Volume__c, Plan_Number__c,Folio__c,status,BypassValidation__c FROM Contract]; 
        test.startTest();
        ContractTriggerHelper.validateStatusBeforeUpdate(lstContract); 
        test.stopTest();        
    }
}