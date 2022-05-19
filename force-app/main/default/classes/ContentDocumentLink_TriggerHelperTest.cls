/*******************************************************************************************
* @Name         ContentDocumentLink_TriggerHelperTest 
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         31/08/2021
* @Description  Tests ContentDocumentLink_TriggerHelper.cls
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      31/08/2021          Initial Creation	 
*  1.1              Sebastian      19/01/2022          Added Participant File Upload Test
*  1.2              Arjun Singh    21/02/2022          VHF-3316 - Final Payment - Generate Payout Document
*******************************************************************************************/
@isTest(SeeAllData=FALSE)
public class ContentDocumentLink_TriggerHelperTest {
    public static testMethod void testContentDocumentLink(){
        // Regulatory Authorisation Type
        RegulatoryAuthorizationType testRegulatoryAuthorizationType = new RegulatoryAuthorizationType(Name = 'Test');
        insert testRegulatoryAuthorizationType;

        Case testCase = new Case();
        insert testCase;
        IndividualApplication testIndividualApplication = new IndividualApplication(
                                                                LicenseTypeId = testRegulatoryAuthorizationType.Id, 
                                                                AppliedDate = System.now(), 
                                                                ApplicationCaseId = testCase.Id,
                                                                Category = 'Grant');
        insert testIndividualApplication;
        Individual_Application_Shadow__c testIndividualApplicationShadow = new Individual_Application_Shadow__c(
                                                                                Individual_Application__c = testIndividualApplication.Id);
        insert testIndividualApplicationShadow;
        
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion content = new ContentVersion(Title = 'Test',
                                                        PathOnClient = '/Test.txt',
                                                        VersionData = bodyBlob);
        insert content;

        Id contentDocumentId = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :content.Id].contentDocumentId;
        Test.startTest();
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
                                                            LinkedEntityId = testIndividualApplicationShadow.id,
                                                            ContentDocumentId = contentDocumentId,
                                                            ShareType = 'I',
                                                            Visibility = 'AllUsers');
        insert testContentDocumentLink;
        Test.stopTest();
        
        Integer countContentDocumentLink = [SELECT Count() FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId];
        System.assertEquals(4, countContentDocumentLink);
    }

    public static testMethod void testRestrictFileExtensionUpload(){
        Profile operationsProfile = [SELECT Id FROM Profile WHERE Name = 'Operations' LIMIT 1];
        String uniqueUserNameOperationsUser = 'operationsuser' + DateTime.now().getTime() + '@testorg.com';
        User operationsUser = new User(Alias='opsusr',
                                        Email='operationsuser@testorg.com',
                                        EmailEncodingKey='UTF-8',
                                        LastName='Testing',
                                        LanguageLocaleKey='en_US',
                                        LocaleSidKey='en_US', 
                                        ProfileId = operationsProfile.Id,
                                        TimeZoneSidKey='America/Los_Angeles',
                                        UserName=uniqueUserNameOperationsUser);
        insert operationsUser;

        Database.SaveResult invalidContentUpload;

        System.runAs(operationsUser){
            Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
            ContentVersion contentVersion = new ContentVersion(Title = 'Test',
                                                            PathOnClient = '/test.bat',
                                                            VersionData = bodyBlob,
                                                            Origin = 'H');
            //insert contentVersion;
            invalidContentUpload = Database.insert(contentVersion, false);
        }
        System.assert(invalidContentUpload.isSuccess() == false, 'Invalid file extention blocked');
        System.assert(invalidContentUpload.getErrors().size() == 1);
    }

    private static final Decimal CONST_MEDICARE_NUM = Decimal.valueOf('21234567080');
    private static final Decimal CONST_CARD_NUM = Decimal.valueOf('212345670');
    private static final Decimal CONST_REF_NUM = Decimal.valueOf('1');
    private static final String PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER = 'VHF Participant Community Plus User';
    private static final Id PERSONACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    @isTest
    static void testValidContentDocumentLink(){
        System.debug('*** Entered testValidContentDocumentLink');
        // Create Admin user
        UserRole customRole = new UserRole(DeveloperName = 'CustomRole', Name = 'Custom Role');
        insert customRole;
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User adminUser = new User(ProfileId = adminProfile.Id,
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
                                    UserRoleId = customRole.Id);
        insert adminUser;

        User contextUser;
        System.runAs(adminUser){
            // Create participant person account
            Account personAccount = new Account(MedicareNumber__pc = CONST_MEDICARE_NUM,
                                                    Medicare_Card_Number__pc = CONST_CARD_NUM,
                                                    Medicare_Reference_Number__pc = CONST_REF_NUM,
                                                    IsActiveApplicant__pc = 'Yes',
                                                    Is_Participant__pc = true,
                                                    Primary_Participant__pc = true,
                                                    RecordTypeId = PERSONACCOUNT_RECORDTYPEID,
                                                    PersonMailingPostalCode = '6004',
                                                    PersonEmail = 'participant.user1@email.com.invalid',
                                                    LastName = 'userone',
                                                    PersonMailingCity = 'Melbourne',
                                                    PersonMailingState = 'Victoria',
                                                    PersonMailingStreet = 'Collins Street');
            insert personAccount;
            // Create participant portal user
            Id personContactId = [Select PersonContactId from Account where Id =:personAccount.Id].PersonContactId;
            Profile communityProfile = [SELECT Id FROM profile WHERE Name = :PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER Limit 1];
            contextUser = new User(ContactId = personContactId,
                                            Username = personAccount.PersonEmail,
                                            Email = personAccount.PersonEmail,
                                            LastName = personAccount.LastName,
                                            CommunityNickname = personAccount.LastName + '_' + System.currentTimeMillis(),
                                            Alias = string.valueOf(personAccount.LastName.substring(0,1) + Math.random() ).substring(0,5),
                                            TimeZoneSidKey = 'Australia/Sydney',
                                            LocaleSidKey = 'en_AU',
                                            EmailEncodingKey = 'ISO-8859-1',
                                            ProfileId = communityProfile.Id,
                                            LanguageLocaleKey = 'en_US',
                                            IsActive = true);
            insert contextUser;
        }

        Test.startTest();
        System.runAs(contextUser){
            // Retrieve Person Account
            Account personAccount = [SELECT id, name, PersonContactId FROM Account WHERE personEmail = 'participant.user1@email.com.invalid' LIMIT 1]; 
            // Create Panel Financier
            Account panelFinancier = new Account(Name = 'Bank of Australia', 
                                                    RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
            insert panelFinancier; 
            // Create Property
            Order property = new Order(AccountId = personAccount.Id,
                                        EffectiveDate = Date.newInstance(Date.today().year() - 1, Date.today().month(), 4),
                                        status = 'Draft',
                                        Panel_Financier_Name__c = panelFinancier.Id,                                    
                                        Actual_Settlement_Date__c = Date.newInstance(Date.today().year() - 1, Date.today().month(), 4),
                                        ByPassValidation__c = True);
            insert property;
            // Create Annual Review
            Annual_Review__c annualReview = new Annual_Review__c(Primary_Participant__c = personAccount.Id,
                                                                    Property__c = property.Id,
                                                                    Status__c = 'Awaiting Submission');
            insert annualReview;
            // Create Content Version
            NetworkMember membership = [SELECT NetworkID, MemberID FROM NetworkMember WHERE memberID = :contextUser.id];
            Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
            ContentVersion content = new ContentVersion(Title = 'Test',
                                                            PathOnClient = '/Test.txt',
                                                            VersionData = bodyBlob,
                                                            NetworkId = membership.NetworkId);
            insert content;
            // Create Content Document Link
            ContentDocument contentDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
            ContentDocumentLink contentDocumentLink1 = new ContentDocumentLink(LinkedEntityId = annualReview.Id,
                                                                                    ContentDocumentId = contentDocument.id,
                                                                                    ShareType = 'V',
                                                                                    Visibility = 'AllUsers');                                        
            insert contentDocumentLink1;
        }
        Test.stopTest();
    }

    @isTest
    static void testInvalidContentDocumentLink(){
        System.debug('*** Entered testValidContentDocumentLink');
        // Create Admin user
        UserRole customRole = new UserRole(DeveloperName = 'CustomRole', Name = 'Custom Role');
        insert customRole;
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User adminUser = new User(ProfileId = adminProfile.Id,
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
                                    UserRoleId = customRole.Id);
        insert adminUser;

        User contextUser;
        System.runAs(adminUser){
            // Create participant person account
            Account personAccount = new Account(MedicareNumber__pc = CONST_MEDICARE_NUM,
                                                    Medicare_Card_Number__pc = CONST_CARD_NUM,
                                                    Medicare_Reference_Number__pc = CONST_REF_NUM,
                                                    IsActiveApplicant__pc = 'Yes',
                                                    Is_Participant__pc = true,
                                                    Primary_Participant__pc = true,
                                                    RecordTypeId = PERSONACCOUNT_RECORDTYPEID,
                                                    PersonMailingPostalCode = '6004',
                                                    PersonEmail = 'participant.user1@email.com.invalid',
                                                    LastName = 'userone',
                                                    PersonMailingCity = 'Melbourne',
                                                    PersonMailingState = 'Victoria',
                                                    PersonMailingStreet = 'Collins Street');
            insert personAccount;
            // Create participant portal user
            Id personContactId = [Select PersonContactId from Account where Id =:personAccount.Id].PersonContactId;
            Profile communityProfile = [SELECT Id FROM profile WHERE Name = :PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER Limit 1];
            contextUser = new User(ContactId = personContactId,
                                            Username = personAccount.PersonEmail,
                                            Email = personAccount.PersonEmail,
                                            LastName = personAccount.LastName,
                                            CommunityNickname = personAccount.LastName + '_' + System.currentTimeMillis(),
                                            Alias = string.valueOf(personAccount.LastName.substring(0,1) + Math.random() ).substring(0,5),
                                            TimeZoneSidKey = 'Australia/Sydney',
                                            LocaleSidKey = 'en_AU',
                                            EmailEncodingKey = 'ISO-8859-1',
                                            ProfileId = communityProfile.Id,
                                            LanguageLocaleKey = 'en_US',
                                            IsActive = true);
            insert contextUser;
        }

        Test.startTest();
        System.runAs(contextUser){
            // Retrieve Person Account
            Account personAccount = [SELECT id, name, PersonContactId FROM Account WHERE personEmail = 'participant.user1@email.com.invalid' LIMIT 1]; 
            // Create Panel Financier
            Account panelFinancier = new Account(Name = 'Bank of Australia', 
                                                    RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
            insert panelFinancier; 
            // Create Property
            Order property = new Order(AccountId = personAccount.Id,
                                        EffectiveDate = Date.newInstance(Date.today().year() - 1, Date.today().month(), 4),
                                        status = 'Draft',
                                        Panel_Financier_Name__c = panelFinancier.Id,                                    
                                        Actual_Settlement_Date__c = Date.newInstance(Date.today().year() - 1, Date.today().month(), 4),
                                        ByPassValidation__c = True);
            insert property;
            // Create Annual Review
            Annual_Review__c annualReview = new Annual_Review__c(Primary_Participant__c = personAccount.Id,
                                                                    Property__c = property.Id,
                                                                    Status__c = 'In Review');
            insert annualReview;
            // Create Content Version
            NetworkMember membership = [SELECT NetworkID, MemberID FROM NetworkMember WHERE memberID = :contextUser.id];
            Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
            ContentVersion content = new ContentVersion(Title = 'Test',
                                                            PathOnClient = '/Test.txt',
                                                            VersionData = bodyBlob,
                                                            NetworkId = membership.NetworkId);
            insert content;
            // Create Content Document Link
            ContentDocument contentDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
            try{
                ContentDocumentLink contentDocumentLink1 = new ContentDocumentLink(LinkedEntityId = annualReview.Id,
                                                                                    ContentDocumentId = contentDocument.id,
                                                                                    ShareType = 'V',
                                                                                    Visibility = 'AllUsers');                                        
                insert contentDocumentLink1;
            }catch(Exception e){
                System.debug('Exception caught: '+e);
            } 
        }
        Test.stopTest();
    }
    public static testMethod void testPayoutContentDocumentLink(){
        // Regulatory Authorisation Type
        RegulatoryAuthorizationType testRegulatoryAuthorizationType = new RegulatoryAuthorizationType(Name = 'Test');
        insert testRegulatoryAuthorizationType;

        Account accPerson = VHFTestDataFactory.createApplicantPersonAccountWithDetails('Yes', 'test', 'last', 'emailc@test.com');
        insert accPerson;
        Account acc = VHFTestDataFactory.createLenderAccount('Bank');
        insert acc;

        Account participantRecord = [Select Id,PersonContactId from Account where PersonEmail ='emailc@test.com'];
        Id fullPaymentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Final_Payment').getRecordTypeId();
        
        Order property = VHFTestDataFactory.createProperty(accPerson.Id, 'Draft', acc.Id);
        property.Actual_Settlement_Date__c = date.Today() - 10;
        insert property; 
        
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
        
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion content = new ContentVersion(Title = 'Test',
                                                        PathOnClient = '/Test.txt',
                                                        VersionData = bodyBlob);
        insert content;

        Id contentDocumentId = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :content.Id].contentDocumentId;
        Test.startTest();
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
                                                            LinkedEntityId = payment.id,
                                                            ContentDocumentId = contentDocumentId,
                                                            ShareType = 'I',
                                                            Visibility = 'AllUsers');
        insert testContentDocumentLink;
        Test.stopTest();
        
        ContentDocumentLink CaseDocumentRecord = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId =: FullPaymentCase.Id];
        System.debug('CaseDocumentRecord>>>'+CaseDocumentRecord);
        System.assert(CaseDocumentRecord != null);
    }
}