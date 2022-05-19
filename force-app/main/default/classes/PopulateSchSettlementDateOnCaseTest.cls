/*******************************************************************************************
* @Name         PopulateSchSettlementDateOnCaseTest
* @Author       
* @Date         
* @Description  
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             
*  1.1              Lavanya Kavuri       25/11/2021          Fixing Test Class   
* 1.2				Sourabh		 		26/11/2021	         Fixes errors  	
*******************************************************************************************/
@isTest
public class PopulateSchSettlementDateOnCaseTest {

    @TestSetup
    static void makeData(){
        Id vhfApplicationsCaseRT_Id = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VHF_Application_Record_Type').getRecordTypeId();
        Account oOzBankRecord = VHFTestDataFactory.createLenderAccount('Oz Bank');
        insert oOzBankRecord;

        Contact oContact = VHFTestDataFactory.createLenderContact(oOzBankRecord.Id, 'lender123', 'officer1', 'lender.Officer112@getnada.com', '+61 2 9311 1111');
        insert oContact;

        Account applicant1 = VHFTestDataFactory.createApplicantPersonAccountWithDetails('Yes', 'app', 'one', 'app.onetwo@apptwo.com');
        insert applicant1;

        Case applicationCase = VHFTestDataFactory.createCase(applicant1.Id, 'Final Approval Requested', 'Pending', vhfApplicationsCaseRT_Id);
        applicationCase.Scheduled_Settlement_Date__c = System.Today();
        applicationCase.BypassValidation__c = true;
        applicationCase.Settlement_Status__c = 'Upcoming Settlement';
        insert applicationCase;
                
        RegulatoryAuthorizationType authType = VHFTestDataFactory.createRegAuth('Victorian HomebuyerFund', 'License');
        insert authType;
                
        IndividualApplication oIndividualApplication = VHFTestDataFactory.createProvisionalApplication(authType.Id, oOzBankRecord.Id, oContact.Id, applicant1.Id, applicationCase.Id );
        insert oIndividualApplication;

        Applicant__c oApplicant1 = VHFTestDataFactory.createApplicant(applicant1.Id, oIndividualApplication.Id);
        insert oApplicant1;

        Contract finalApp = VHFTestDataFactory.createFinalApplication(oIndividualApplication.Id, applicant1.Id, 'draft', applicationCase.Id, 28, '1', 'PS832324H', '1', 1, oContact.Id);
        insert finalApp;
    }
    public static testMethod void populateScheduledSettlementDateOnCaseTestCaseone()

    {
        
        List <Contract> lstContract1 = [SELECT Id, Lot_Number__c, Volume__c, Plan_Number__c, Folio__c FROM Contract];
        List <Case> lstCase1 = [Select Id, Status, Scheduled_Settlement_Date__c from case];
        List <Id> CSId = new List <Id>();
        for (Case CSObj: lstCase1) 
        {
            CSId.add(CSObj.Id);
        }
        Test.startTest();
        PopulateScheduledSettlementDateOnCase.calculateSettlementDate(CSId);
        Test.stopTest();

    }
    
    public static testMethod void populateScheduledSettlementDateOnCaseTestCasetwo() {
        Date yesterday = System.Today().addDays(-1);
        Account testAccount2 = new Account(Name = 'Test Name');
        insert testAccount2;

        Contact cont2 = new Contact();
        cont2.FirstName = 'Test';
        cont2.LastName = 'testContact2';
        cont2.accountid = testAccount2.id;
        cont2.Email = 'Test@test.com';
        insert cont2;
        Case testCase2 = new Case(Status = 'Final Approval Requested', Scheduled_Settlement_Date__c = yesterday);
        insert testCase2;
        RegulatoryAuthorizationType testRegulatoryAuthorizationType2 = new RegulatoryAuthorizationType(Name = 'Test');
        insert testRegulatoryAuthorizationType2;
        IndividualApplication testIndividualApplication2 = new IndividualApplication(
            LicenseTypeId = testRegulatoryAuthorizationType2.Id,
            AppliedDate = System.now(),
            Aboriginal_Applicants__c = false,
            Panel_Finance_Officer__c = cont2.id,
            Category = 'Grant',
            ApplicantNames__c = 'Test One, Test Two');
        insert testIndividualApplication2;


        Contract testContract2 = new Contract(IndividualApplicationId__c = testIndividualApplication2.Id,
            Status = 'Final Application Submitted',
            Panel_Finance_Officer__c = cont2.id,
            Bypassvalidation__c = true,
            ApplicationCaseId__c = testCase2.Id,
            Settlement_Date__c = yesterday, AccountId = testAccount2.Id, Plan_Number__c = 'LP074245', Lot_Number__c = '13G', Folio__c = '1', Volume__c = integer.ValueOf(23623));
        insert testContract2;
        List < Contract > lstContract2 = new List < Contract > ([SELECT Id, Lot_Number__c, Volume__c, Plan_Number__c, Folio__c FROM Contract WHERE Id =: testContract2.Id and Status NOT IN('Cancelled', 'Rejected', 'Cancelled Settlement')]);

        List < Case > lstCase2 = new List <
            case >([Select Id, Status, Scheduled_Settlement_Date__c from
                case WHERE Id =: testCase2.Id
            ]);
        List < Id > CSId2 = new List < Id > ();
        for (Case CSObj2: lstCase2) {
            CSId2.add(CSObj2.Id);
        }

        Test.startTest();
        PopulateScheduledSettlementDateOnCase.calculateSettlementDate(CSId2);
        Test.stopTest();

    }
}