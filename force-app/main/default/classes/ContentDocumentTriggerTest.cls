/*******************************************************************************************
* @Name         ContentDocumentTriggerTest 
* @Author       Sourabh Singh
* @Date         9/Sep/2021
* @Description  This class tests the ContentDocumentTrigger
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sourabh Singh      09/09/2021          Created.
*  1.1              Lavanya Kavuri     25/11/2021          Fixed the Test Class                                                     
*******************************************************************************************/

@isTest
public class ContentDocumentTriggerTest 
{
    private static final String PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER = 'VHF Participant Community Plus User';

    @TestSetup
    static void makeData(){

        UserRole newCustomRole = VHFTestDataFactory.createCustomRole('CustomRole', 'CustomRole');
        insert newCustomRole;

        User newAdminUser = VHFTestDataFactory.createAdminUser(newCustomRole.Id, 'testSysAdminUser@test.com', 'testSysAdminUser@test.com', 'testuser', 'admin', 'testad');
        insert newAdminUser;

        System.runAs(newAdminUser) {

            Account oApplicantPersonAccountRecord = VHFTestDataFactory.createApplicantPersonAccount('Yes');
            insert oApplicantPersonAccountRecord;

            Id personContactId = [Select PersonContactId from Account where Id =:oApplicantPersonAccountRecord.Id].PersonContactId;
            Profile communityProfile = [SELECT Id FROM profile WHERE Name = :PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER Limit 1];

            String nickName = oApplicantPersonAccountRecord.LastName + '_' + System.currentTimeMillis();
            String alias = string.valueOf(oApplicantPersonAccountRecord.LastName.substring(0,1) + Math.random() ).substring(0,5);
            User comPortalUser = VHFTestDataFactory.createCommunityUser(personContactId, oApplicantPersonAccountRecord.PersonEmail, oApplicantPersonAccountRecord.LastName,oApplicantPersonAccountRecord.PersonEmail,nickName , alias, communityProfile.Id);
            insert comPortalUser;

        }
    }

    @isTest
    static void processDocumentDelete() 
    {       
        UserRole r = VHFTestDataFactory.createCustomRole('BranchManagerCustomRole', 'BranchManagerCustomRole');
        insert r;

        /*Group publicGroup = new Group();
        publicGroup.Name = 'All_SRO_Operations_Users';
        publicGroup.DeveloperName = 'All_SRO_Operations_Users1';
        publicGroup.Type = 'Regular';
        insert publicGroup;*/

        Group publicGroup = [Select Id, Name, Type, DeveloperName from Group where DeveloperName = 'All_SRO_Operations_Users'];

        String profileId = [SELECT Id FROM Profile WHERE Name = 'Operations'].Id;

        User u = VHFTestDataFactory.createInternalUser(r.Id, profileId, 'testuser@srotest.com', 'testuser@srotest.com' + System.currentTimeMillis(), 'test', 'last', 'alias');
        insert u;

        Test.startTest();
        system.runAs(u)
        {
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        try
        { 
           delete documents;      
        }
        catch(exception e)
        {
            system.debug(e);
        }
        }
        Test.stopTest();
        
    }

    /** Sourabh:26/11/2021 commented as participant profile has been removed as member of participant portal
    @isTest
    static void processDocumentDelete_ParticipantUser() 
    {       
        Test.startTest();
        User participantUser = [Select Id from user where email ='test@email.com.invalid'];
        System.debug('**Test** Participant uSER=' + participantUser);
        system.runAs(participantUser)
        {
            //Network oNetwork = [SELECT Id from Network where Name = 'Participant Portal'];
            ContentVersion contentVersion_1 = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
                //NetworkId = oNetwork.Id
            );
            insert contentVersion_1;
            System.debug('**Test** Content Version=' + contentVersion_1);
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            System.assertEquals(documents.size(), 1);
            try
            { 
            delete documents;      
            }
            catch(exception e)
            {
                system.debug(e);
            }
        }
        Test.stopTest();
        
    }*/
}