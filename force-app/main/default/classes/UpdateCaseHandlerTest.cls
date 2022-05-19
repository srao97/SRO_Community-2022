@isTest
public class UpdateCaseHandlerTest {
    @TestSetup
    static void testDataSetup(){

        UserRole newCustomRole = VHFTestDataFactory.createCustomRole('CustomRole', 'CustomRole');
        insert newCustomRole;

        User VlocityCustomActionsTestUser = VHFTestDataFactory.createAdminUser(newCustomRole.Id, 'VlocityCustomActions.Test@test.com', 'VlocityCustomActions.Test@test.com', 'VlocityCustomActions', 'Test', 'vcatest');
        insert VlocityCustomActionsTestUser;
        
        System.runAs(VlocityCustomActionsTestUser){

            Account oBendigoAccount = VHFTestDataFactory.createLenderAccount('Bendigo Bank');
            oBendigoAccount.Shared_Mailbox__c = 'VlocityCustomActionsTest.Bendigo@getnada.com';
            insert oBendigoAccount;

            Account oBankofAustraliaAccount = VHFTestDataFactory.createLenderAccount('Bank of Australia');
            oBankofAustraliaAccount.Shared_Mailbox__c = 'VlocityCustomActionsTest.BankofAustralia@getnada.com';
            insert oBankofAustraliaAccount;

            Account accPerson = VHFTestDataFactory.createApplicantPersonAccountWithDetails('Yes', 'test', 'last', 'emailc@test.com');
            insert accPerson;
            
            Order oProperty = VHFTestDataFactory.createProperty(accPerson.Id, 'Draft', oBendigoAccount.Id);
            oProperty.Actual_Settlement_Date__c = date.Today() - 10;
            insert oProperty;
           
            Id Refinance_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Refinance').getRecordTypeId();
            Case newRefinanceCase = VHFTestDataFactory.createCase(accPerson.Id, 'New', 'Pending', Refinance_RECORDTYPEID);
            newRefinanceCase.Subject = 'Test Refinance case';
            newRefinanceCase.Current_Panel_Financier__c = oBendigoAccount.Id;
            newRefinanceCase.Property__c = oProperty.id; 
            newRefinanceCase.ByPassValidation__c =true;
            newRefinanceCase.New_Panel_Financier__c= oBankofAustraliaAccount.id;
            newRefinanceCase.ContactId = [SELECT PersonContactId FROM Account WHERE Id = :accPerson.Id].PersonContactId;
            insert newRefinanceCase;

            Confirmation__c confirmation = new Confirmation__c();
            confirmation.Refinance_Case_ID__c = newRefinanceCase.Id;
            confirmation.Property_Id__c =  oProperty.id; 
            insert confirmation;

        }
    }

    @isTest
    private static void UpdateNewPanelFinancier_Success(){
        Test.startTest();
        String sNewPanelFinancier = 'Bank of Australia';
        Case oCase_Before = [Select Id from Case LIMIT 1];
        Map<String, Object> input = new Map<String, Object>{'CaseId'=>oCase_Before.Id,'NewPanelFinancier' => 'Bank of Australia'};
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        UpdateCaseHandler.UpdateNewPanelFinancier(input, output, options);
        
        Account oAccount = [select Id from Account where Name = :sNewPanelFinancier];
        Case oCase_After = [Select Id, New_Panel_Financier__c from Case where Id = :oCase_Before.Id];
        
        system.assertEquals(oAccount.Id, oCase_After.New_Panel_Financier__c);
        system.assertEquals(true, (Boolean)output.get('success'));
        List<Confirmation__c> CList = [Select Id, New_PF__c From Confirmation__c Where Refinance_Case_ID__c =: oCase_After.Id order by createdDate desc];
        system.assertEquals(CList[0].New_PF__c,oCase_After.New_Panel_Financier__c);
        Test.stopTest();
    }
}