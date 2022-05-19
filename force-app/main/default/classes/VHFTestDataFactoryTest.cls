/*******************************************************************************************
 * @Name         VHFTestDataFactoryTest
 * @Author       Lavanya Kavuri
 * @Date         25/11/2021
 * @Description
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.1          Lavanya Kavuri          25/11/2021      Created.
 *  1.2          Arjun Singh             20/01/2022      modified to pass case recordType Id in createCase() method
 *******************************************************************************************/
@IsTest
public with sharing class VHFTestDataFactoryTest {
  @IsTest
  static void methodName1() {
    UserRole customRole = VHFTestDataFactory.createCustomRole(
      'CustomRole',
      'CustomRole'
    );
    insert customRole;
    System.assert(customRole.Id != null);

    User userWithARole = VHFTestDataFactory.createAdminUser(
      customRole.Id,
      'testSysAdUser@test.com',
      'testSysAdUser@test.com' + System.currentTimeMillis(),
      'test',
      'last',
      'alias'
    );
    insert userWithARole;
    System.assert(userWithARole.Id != null);

    System.runAs(userWithARole) {
      Account acc = VHFTestDataFactory.createLenderAccount('Bank');
      insert acc;
      System.assert(acc.Id != null);

      Account accPerson = VHFTestDataFactory.createApplicantPersonAccountWithDetails(
        'Yes',
        'test',
        'last',
        'email@test.com'
      );
      insert accPerson;
      System.assert(accPerson.Id != null);

      Contact lenderCon = VHFTestDataFactory.createLenderContact(
        acc.Id,
        'lender',
        'contact',
        'lender@contact.com',
        '+61 9311 1111'
      );
      insert lenderCon;
      System.assert(lenderCon.Id != null);

      Account acc2 = VHFTestDataFactory.createLenderAccount('NewEraBank');
      insert acc2;
      System.assert(acc2.Id != null);

      Contact lenderCon2 = VHFTestDataFactory.createLenderContact(
        acc2.Id,
        'nick',
        'hercules',
        'nick.hercules@contact.com',
        '+61 9311 1671'
      );
      insert lenderCon2;
      System.assert(lenderCon2.Id != null);

      Id vhfCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('VHF_Application_Record_Type')
        .getRecordTypeId();
      Case newCase = VHFTestDataFactory.createCase(
        accPerson.Id,
        'Submitted',
        'Pending',
        vhfCaseRecordTypeId
      );
      insert newCase;
      System.assert(newCase.Id != null);

      RegulatoryAuthorizationType authType = VHFTestDataFactory.createRegAuth(
        'Victorian HomebuyerFund',
        'License'
      );
      insert authType;
      System.assert(authType.Id != null);

      IndividualApplication provApp = VHFTestDataFactory.createProvisionalApplication(
        authType.Id,
        acc.Id,
        lenderCon.Id,
        accPerson.Id,
        newCase.Id
      );
      insert provApp;
      System.assert(provApp.Id != null);

      IndividualApplication provApp1 = VHFTestDataFactory.createSimpleProvApp(
        authType.Id,
        'draft',
        System.today()
      );
      insert provApp1;
      System.assert(provApp1.Id != null);

      Individual_Application_Shadow__c shadow = VHFTestDataFactory.createProvAppShadow(
        provApp1.Id
      );
      insert shadow;
      System.assert(shadow.Id != null);

      Applicant__c applicant = VHFTestDataFactory.createApplicant(
        accPerson.Id,
        provApp.Id
      );
      insert applicant;
      System.assert(applicant.Id != null);

      Contract finalApp = VHFTestDataFactory.createFinalApplication(
        provApp.Id,
        accPerson.Id,
        'Final Application Submitted',
        newCase.Id,
        28,
        '1',
        'PS832324H',
        '1',
        1,
        lenderCon.Id
      );
      insert finalApp;
      System.assert(finalApp.Id != null);

      Order property = VHFTestDataFactory.createProperty(
        accPerson.Id,
        'Draft',
        acc.Id
      );
      insert property;
      System.assert(property.Id != null);

      /* Group publicGroup = new Group();
            publicGroup.Name = 'All_SRO_Operations_Users';
            publicGroup.DeveloperName = 'All_SRO_Operations_Users';
            publicGroup.Type = 'Regular';
            insert publicGroup;*/
      Group publicGroup = [
        SELECT Id, Name, DeveloperName, Type
        FROM Group
        WHERE DeveloperName = 'All_SRO_Operations_Users'
      ];

      Profile internalProfile = [
        SELECT Id
        FROM profile
        WHERE Name = 'Operations'
        LIMIT 1
      ];
      User userInternal = VHFTestDataFactory.createInternalUser(
        customRole.Id,
        internalProfile.Id,
        'testInternal@test.com',
        'testInternal@test.com' + System.currentTimeMillis(),
        'test',
        'last',
        'alsas'
      );
      insert userInternal;
      System.assert(userInternal.Id != null);

      Profile communityProfile = [
        SELECT Id
        FROM profile
        WHERE Name = 'VHF Lender Community Plus User'
        LIMIT 1
      ];
      User commUser = VHFTestDataFactory.createCommunityUser(
        lenderCon.Id,
        'lenderuser@test.com',
        'lander',
        'lenderuser@test.com',
        'conlen',
        'conel',
        communityProfile.Id
      );
      insert commUser;
      System.assert(commUser.Id != null);
    }

  }
}