/*
* Desription: TestData Factory for the Test Class Data Setup 
* Author: Lavanya Kavuri (lkavuri@salesforce.com)
** Version History ** 
Created: Date: Oct-13-2021
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.1             Arjun Singh        20/01/2022          Added method for Annual Review Creation
 */
public class VHFTestDataFactory {
  //Medicare Number 1
  private static final Decimal CONST_MEDICARE_NUM = Decimal.valueOf(
    '21234567080'
  );
  private static final Decimal CONST_CARD_NUM = Decimal.valueOf('212345670');
  private static final Decimal CONST_REF_NUM = Decimal.valueOf('1');

  /*
   * Account Methods
   */

  //Create Lender Account - RecordType: Business
  public static Account createLenderAccount(String name) {
    //Get the lender recordType Id
    Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Business')
      .getRecordTypeId();

    Account accRec = new Account();
    accRec.Name = name;
    accRec.RecordTypeId = lenderRecordTypeId;

    return accRec;
  }

  public static Account createApplicantPersonAccountWithDetails(
    String isActive,
    String firstName,
    String lastName,
    String email
  ) {
    //Get the Primary Participant RecordType Id
    Id primaryPartRecordId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account newPrimaryRec = new Account();
    newPrimaryRec.MedicareNumber__pc = CONST_MEDICARE_NUM;
    newPrimaryRec.Medicare_Card_Number__pc = CONST_CARD_NUM;
    newPrimaryRec.Medicare_Reference_Number__pc = CONST_REF_NUM;
    newPrimaryRec.FirstName = firstName;
    newPrimaryRec.PersonEmail = email;
    newPrimaryRec.LastName = lastName;
    //newPrimaryRec.Primary_Participant__pc = isPrimary;
    newPrimaryRec.IsActiveApplicant__pc = isActive;
    newPrimaryRec.PersonMailingCity = 'Melbourne';
    newPrimaryRec.PersonMailingPostalCode = '3000';
    newPrimaryRec.PersonMailingState = 'Victoria';
    newPrimaryRec.PersonMailingStreet = '150 Collins Street';
    newPrimaryRec.PersonMailingCountry = 'Australia';

    return newPrimaryRec;
  }

  //Create Primary Participant Account  - RecordType: PersonAccount
  public static Account createApplicantPersonAccount(String isActive) {
    //Get the Primary Participant RecordType Id
    Id primaryPartRecordId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account newPrimaryRec = new Account();
    newPrimaryRec.MedicareNumber__pc = CONST_MEDICARE_NUM;
    newPrimaryRec.Medicare_Card_Number__pc = CONST_CARD_NUM;
    newPrimaryRec.Medicare_Reference_Number__pc = CONST_REF_NUM;
    newPrimaryRec.PersonEmail = 'test@email.com.invalid';
    newPrimaryRec.LastName = 'TestLastName';
    //newPrimaryRec.Primary_Participant__pc = isPrimary;
    newPrimaryRec.IsActiveApplicant__pc = isActive;
    newPrimaryRec.PersonMailingCity = 'Melbourne';
    newPrimaryRec.PersonMailingPostalCode = '3000';
    newPrimaryRec.PersonMailingState = 'Victoria';
    newPrimaryRec.PersonMailingStreet = '150 Collins Street';
    newPrimaryRec.PersonMailingCountry = 'Australia';
    newPrimaryRec.IsActiveApplicant__pc = 'Yes';
    newPrimaryRec.Is_Participant__pc = true;
    return newPrimaryRec;
  }

  /*
   * Contact Methods
   */

  //Create Contact for Lender Account
  public static Contact createLenderContact(
    Id accountId,
    String firstName,
    String lastName,
    String email,
    String phone
  ) {
    Id standardRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Contact')
      .getRecordTypeId();

    Contact newConRec = new Contact();
    newConRec.AccountId = accountId;
    newConRec.FirstName = firstName;
    newConRec.LastName = lastName;
    newConRec.Email = email;
    newConRec.Phone = phone;
    newConRec.RecordTypeId = standardRecordTypeId;

    return newConRec;
  }

  /*
   * Case Methods
   */

  public static Case createCase(
    String participantAcctId,
    String status,
    String subStatus,
    String recordTypeId
  ) {
    Case newAppCase = new Case();
    newAppCase.RecordTypeId = recordTypeId;
    newAppCase.AccountId = participantAcctId;
    newAppCase.Status = status;
    newAppCase.Sub_Status__c = subStatus;
    newAppCase.Subject = 'Test case for application - Vic house funding';

    return newAppCase;
  }

  /*
   * Provisional Application Methods
   */

  //Create Provisional Application - Depdens on Regulatory Authorization Type. So, we need to create that first

  //Create Regulatory Authorization Type
  public static RegulatoryAuthorizationType createRegAuth(
    String name,
    String authType
  ) {
    RegulatoryAuthorizationType newRegAuth = new RegulatoryAuthorizationType();
    newRegAuth.Name = name;
    newRegAuth.RegulatoryAuthCategory = authType;
    return newRegAuth;
  }

  //Create Comprehensive Provisional Application  - With all the fields
  public static IndividualApplication createProvisionalApplication(
    String licenseId,
    String lenderAcctId,
    String panelOfficerId,
    String participantAcctId,
    String caseId
  ) {
    IndividualApplication newProvApp = new IndividualApplication();
    newProvApp.AccountId = participantAcctId;
    newProvApp.ApplicationCaseId = caseId;
    newProvApp.Category = 'Grant';
    newProvApp.Status = 'Draft';
    newProvApp.AppliedDate = Date.today();
    newProvApp.LicenseTypeId = licenseId;
    newProvApp.Lender_Account__c = lenderAcctId;
    newProvApp.Panel_Finance_Officer__c = panelOfficerId;
    return newProvApp;
  }

  //Create simple Provisional Application - With Few Fields
  public static IndividualApplication createSimpleProvApp(
    String licenseId,
    String status,
    Date appliedDate
  ) {
    IndividualApplication newSimpleApp = new IndividualApplication();
    newSimpleApp.LicenseTypeId = licenseId;
    newSimpleApp.Status = status;
    newSimpleApp.AppliedDate = appliedDate;
    return newSimpleApp;
  }

  //Create Provisional Application Shadow
  public static Individual_Application_Shadow__c createProvAppShadow(
    Id provAppId
  ) {
    Individual_Application_Shadow__c shadowApplication = new Individual_Application_Shadow__c();
    shadowApplication.Individual_Application__c = provAppId;
    return shadowApplication;
  }

  //Create Applicant

  public static Applicant__c createApplicant(
    String participantId,
    String applicationId
  ) {
    Applicant__c newApplicant = new Applicant__c();
    newApplicant.Account__c = participantId;
    newApplicant.IndividualApplication__c = applicationId;

    return newApplicant;
  }

  //Create Final Application

  public static Contract createFinalApplication(
    String provAppId,
    string participantAcctId,
    String status,
    String caseId,
    Integer loanterm,
    string lotnum,
    string plannum,
    string folio,
    Decimal volume,
    string panelOfficerId
  ) {
    Contract newFinalApp = new Contract();
    newFinalApp.IndividualApplicationId__c = provAppId;
    newFinalApp.AccountId = participantAcctId;
    newFinalApp.Status = status;
    newFinalApp.ApplicationCaseId__c = caseId;
    newFinalApp.Loan_Term_Years__c = loanterm;
    newFinalApp.Lot_Number__c = lotnum;
    newFinalApp.Plan_Number__c = plannum;
    newFinalApp.Folio__c = folio;
    newFinalApp.Volume__c = volume;
    newFinalApp.Panel_Finance_Officer__c = panelOfficerId;

    return newFinalApp;
  }

  //Create Property Record

  public static Order createProperty(
    String accountId,
    String status,
    String panelOfficerId
  ) {
    Order newProperty = new Order();
    newProperty.accountId = accountId;
    newProperty.Status = status;
    newProperty.EffectiveDate = System.today();
    newProperty.Panel_Financier_Name__c = panelOfficerId;

    return newProperty;
  }

  //Create User Methods

  /* Custom Role */
  public static UserRole createCustomRole(
    String roleName,
    String developerName
  ) {
    UserRole newRole = new UserRole();
    newRole.DeveloperName = developerName;
    newRole.Name = roleName;

    return newRole;
  }

  /*Create Admin User with Role */
  public static User createAdminUser(
    String roleId,
    String email,
    String username,
    String firstName,
    String lastName,
    String alias
  ) {
    User newUser = new User();
    newUser.profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
    ]
    .Id;
    newUser.FirstName = firstName;
    newUser.LastName = lastName;
    newUser.Email = email;
    newUser.Username = username + System.currentTimeMillis();
    newUser.CompanyName = 'TESTSRO';
    newUser.Title = 'title';
    newUser.Alias = alias;
    newUser.TimeZoneSidKey = 'Australia/Sydney';
    newUser.EmailEncodingKey = 'ISO-8859-1';
    newUser.LanguageLocaleKey = 'en_US';
    newUser.LocaleSidKey = 'en_AU';
    newUser.UserRoleId = roleId;

    return newUser;
  }

  public static User createInternalUser(
    String roleId,
    String profileId,
    String email,
    String username,
    String firstName,
    String lastName,
    String alias
  ) {
    User newUser = new User();
    newUser.FirstName = firstName;
    newUser.LastName = lastName;
    newUser.Email = email;
    newUser.Username = username + System.currentTimeMillis();
    newUser.CompanyName = 'TESTSRO';
    newUser.Title = 'title';
    newUser.Alias = alias;
    newUser.TimeZoneSidKey = 'Australia/Sydney';
    newUser.EmailEncodingKey = 'ISO-8859-1';
    newUser.LanguageLocaleKey = 'en_US';
    newUser.LocaleSidKey = 'en_AU';
    newUser.UserRoleId = roleId;
    newUser.ProfileId = profileId;

    return newUser;
  }

  public static User createCommunityUser(
    String personContactId,
    String email,
    String lastName,
    String username,
    String nickname,
    String alias,
    String profileId
  ) {
    User comPortalUser = new User();
    comPortalUser.ContactId = personContactId;
    comPortalUser.Username = username;
    comPortalUser.Email = email;
    comPortalUser.LastName = lastName;
    comPortalUser.CommunityNickname = nickname;
    comPortalUser.Alias = alias;
    comPortalUser.TimeZoneSidKey = 'Australia/Sydney';
    comPortalUser.LocaleSidKey = 'en_AU';
    comPortalUser.EmailEncodingKey = 'ISO-8859-1';
    comPortalUser.ProfileId = profileId;
    comPortalUser.LanguageLocaleKey = 'en_US';
    comPortalUser.IsActive = true;

    return comPortalUser;
  }

  //Payment Creation Methods
  public static Payment__c createPayment(
    String status,
    String caseId,
    String applicantAcctId
  ) {
    Payment__c newPayment = new Payment__c();
    newPayment.Status__c = status;
    newPayment.Amount__c = 25000;
    newPayment.Case__c = caseId;
    newPayment.Primary_Participant__c = applicantAcctId;
    newPayment.Requested_Date__c = System.today();

    return newPayment;
  }

  public static Annual_Review__c createAnnualReview(
    String propertyId,
    String primaryParticipantId,
    date annualReviewStartDate,
    date annualReviewEndDate
  ) {
    Annual_Review__c annualReview = new Annual_Review__c();
    annualReview.Property__c = propertyId;
    annualReview.Primary_Participant__c = primaryParticipantId;
    annualReview.Annual_Review_Start_Date__c = annualReviewStartDate;
    annualReview.Annual_Review_End_Date__c = annualReviewEndDate;

    return annualReview;
  }
}