/*******************************************************************************************
* @Name         ExternalUserSyncTest 
* @Author       Lawrence Tang
* @Date         10/11/2021
* @Description  This class is the test class of the ExternalUserSync Queueable
*******************************************************************************************/
@isTest
private class ExternalUserSyncTest {

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
        Contact lenderOfficer = new Contact();
        lenderOfficer.FirstName = 'Lara';
        lenderOfficer.LastName = 'Swift';   
        insert lenderOfficer;
    }
    
     @isTest static void testSyncPA(){
        Account personAccount = [select id from Account LIMIT 1];
        personAccount.PersonMailingStreet = 'A new Street';
        List<Account> personAccountList = new List<account>();
        personAccountList.add(personAccount);
        Test.startTest();
        PersonAccountUserSyncHandler.SyncExternalUser(personAccountList);
        Test.stopTest();
        Account updatedParticipant = [select id, PersonMailingStreet from Account LIMIT 1];
        System.assertEquals(updatedParticipant.PersonMailingStreet,'A new Street','Assertion failed: Address has not changed');    
    }
    
    @isTest static void testSyncContact(){
        Contact lenderContact = [select id from Contact LIMIT 1];
        lenderContact.LastName = 'Hay';
        List<Contact> contactList = new List<Contact>();
        contactList.add(lenderContact);
        Test.startTest();
        ContactUserSyncHandler.SyncContact(contactList);
        Test.stopTest();
        Contact updatedLender = [select id, LastName from Contact LIMIT 1];
        System.assertEquals(updatedLender.LastName,'Hay','Assertion failed: Last Name has not changed');    
    }
}