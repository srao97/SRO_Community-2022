@isTest
public class VlocityCustomActionsTest {
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
            insert newRefinanceCase;

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
        Boolean bResult = new VlocityCustomActions().invokeMethod('UpdateNewPanelFinancier', input, output, options);
        
        Account oAccount = [select Id from Account where Name = :sNewPanelFinancier];
        Case oCase_After = [Select Id, New_Panel_Financier__c from Case where Id = :oCase_Before.Id];
        
        system.assertEquals(oAccount.Id, oCase_After.New_Panel_Financier__c);
        system.assertEquals(true, (Boolean)output.get('success'));
        Test.stopTest();
    }

    @isTest
    private static void TransformListtoObject_Success(){
        System.Test.startTest();
        String sMethodName = 'transformListtoObject';
        String sAddress1 = 'Levels Rd, GOLSPIE  NSW   2580';
        String sAddress2 = 'Levels  Rd,  TARALGA  NSW  2580';

        List<Object> listInput = new List<Object>{sAddress1, sAddress2};
        Map<String, Object> input = new Map<String, Object>{'arguments'=>listInput};
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        VlocityCustomActions oVlocityCustomActions = new VlocityCustomActions();
        oVlocityCustomActions.invokeMethod(sMethodName, input, output, options);

        List<Object> listOutput = (List<Object>)output.get('result');
        system.assertEquals(listInput.size(),listOutput.size());
        
        system.assertEquals(sAddress1.normalizeSpace(),(String)((Map<String, Object>)listOutput[0]).get('name'));
        system.assertEquals(sAddress2.normalizeSpace(),(String)((Map<String, Object>)listOutput[1]).get('name'));
        System.Test.stopTest();
    }
}