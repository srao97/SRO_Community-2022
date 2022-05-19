/*
* Description: Test class for ProvAppTrigger  
** Version History ** 
Created: Sourabh Singh, 19/11/2021
*/ 

@isTest(SeeAllData=FALSE)
public class ProvAppTriggerHelperTest 
{
    private static final Decimal CONST_MEDICARE_NUM = Decimal.valueOf('21234567080');
    private static final Decimal CONST_CARD_NUM = Decimal.valueOf('212345670');
    private static final Decimal CONST_REF_NUM = Decimal.valueOf('1');
    private static final String PROFILE = 'VHF Lender Community Plus User';
    private static final Id PERSONACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final Id BUSINESSACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    private static final Id STANDARDCONTACT_RECORDTYPEID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
    
    @TestSetup
    private static void setup() 
    {
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
            oApplicantPersonAccountRecord.PersonMailingPostalCode = '3000';
            oApplicantPersonAccountRecord.PersonMailingCity = 'Melbourne';
            oApplicantPersonAccountRecord.PersonMailingState= 'Victoria';
            oApplicantPersonAccountRecord.PersonMailingCountry= 'Australia';
            oApplicantPersonAccountRecord.PersonMailingStreet = '3400 St';
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
        }        
    }
    
    public static testMethod void testResetBypass()        
    {
        IndividualApplication ia = [select id, Final_Application_Status__c, BypassValidation__c from IndividualApplication limit 1 ];
        Test.startTest();
        ia.Final_Application_Status__c = 'Approved';
        ia.BypassValidation__c = true;
        update ia;
        IndividualApplication iau = [select id, Final_Application_Status__c, BypassValidation__c from IndividualApplication limit 1 ];
        System.assertEquals(iau.BypassValidation__c,false);
        Test.stopTest();         
    }

    public static testMethod void testResetBypass2()        
    {
        IndividualApplication ia = [select id, Final_Application_Status__c, BypassValidation__c from IndividualApplication limit 1 ];
        Test.startTest();
        ia.Final_Application_Status__c = 'Approved';
        ia.BypassValidation__c = false;
        update ia;
        IndividualApplication iau = [select id, Final_Application_Status__c, BypassValidation__c from IndividualApplication limit 1 ];
        System.assertEquals(iau.BypassValidation__c,false);
        Test.stopTest();         
    }
}