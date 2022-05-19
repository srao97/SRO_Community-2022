/*******************************************************************************************
* @Author       Arjun Singh
* @Date         08/03/2022
* @Description  Test Class for PropertySalePayoutDocumentPreChecks
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Arjun Singh       08/03/2022          Created  
*******************************************************************************************/
@isTest
private class PropertySalePayoutDocumentPreChecksTest {
    @TestSetup
    static void setup() 
    { 
        final Id ProperySale_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Property_Sale').getRecordTypeId();
        
        UserRole newCustomRole = VHFTestDataFactory.createCustomRole('CustomRole', 'CustomRole');
        insert newCustomRole;
        
        User newAdminUser = VHFTestDataFactory.createAdminUser(newCustomRole.Id, 'testSysAdminUser@test.com', 'testSysAdminUser@test.com', 'testuser', 'admin', 'testad');
        insert newAdminUser;
        
        User adminUser = [Select Id from User where Email = 'testSysAdminUser@test.com'];
        
        System.runAs(adminUser)
        {
            Account accPerson = VHFTestDataFactory.createApplicantPersonAccountWithDetails('Yes', 'test', 'last', 'emailc@test.com');
            insert accPerson;
            
            
            Account acc = VHFTestDataFactory.createLenderAccount('Bank');
            insert acc;
            
            Order property = VHFTestDataFactory.createProperty(accPerson.Id, 'Draft', acc.Id);
            property.Actual_Settlement_Date__c = date.Today() - 10;
            insert property;     
            
            accPerson.Property__c = property.Id;
            accPerson.Is_Participant__pc = true;
            accPerson.Is_Participant__pc = true;
            update accPerson;
           
            Case newPropertySaleCase = new Case();
            newPropertySaleCase.AccountId = accPerson.Id;
            newPropertySaleCase.ContactId = accPerson.PersonContactId;
            newPropertySaleCase.Status = 'New';
            newPropertySaleCase.Sub_Status__c = 'Pending';
            newPropertySaleCase.Subject = 'Test ProperySale case';
            newPropertySaleCase.recordTypeId = ProperySale_RECORDTYPEID;
            newPropertySaleCase.Property__c = property.id; 
            insert newPropertySaleCase;            
        
        }
    }
    public static testMethod void testvalidateRequest()        
    {
        Case caseRecord = [Select Id from Case limit 1];
        String validationMsg;
        Test.startTest();
        validationMsg = PropertySalePayoutDocumentPreChecks.validateRequest(String.valueOf(caseRecord.Id));
        Test.stopTest();
        System.assertEquals(validationMsg, PropertySalePayoutDocumentPreChecks.CALCULATE_PIA_MSG);
    }
    public static testMethod void testvalidateRequest_AwaitingSettlement()        
    {
        Case caseRecord = [Select Id, status from Case limit 1];
        caseRecord.status= 'Awaiting Settlement';
        caseRecord.Proportionate_interest_amount__c = 10;
        update caseRecord;
        String validationMsg;
        Test.startTest();
        validationMsg = PropertySalePayoutDocumentPreChecks.validateRequest(String.valueOf(caseRecord.Id));
        Test.stopTest();
        System.assertEquals(validationMsg, PropertySalePayoutDocumentPreChecks.AWAITIING_SETTLEMENT_MSG);
    }
    public static testMethod void testupdatePropertySaleCase()        
    {
        Case caseRecord = [Select Id, status from Case limit 1];
        Group propertySaleVGSOQueue = new Group();
        propertySaleVGSOQueue.Name = 'Property Sale VGSO queue';
        insert propertySaleVGSOQueue;
        Test.startTest();
            PropertySalePayoutDocumentPreChecks.updatePropertySaleCase(String.valueOf(caseRecord.Id));
        Test.stopTest();
        Case caseRecordAfterUpdate = [Select Id, status from Case limit 1];
        System.assertEquals(caseRecordAfterUpdate.status, PropertySalePayoutDocumentPreChecks.AWAITING_SETTLEMENT_STATUS);
    }
}