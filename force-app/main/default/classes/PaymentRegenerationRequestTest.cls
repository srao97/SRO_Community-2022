/*******************************************************************************************
* @Name         Payment Regeneration Request Test Class (VHF-2979)
* @Author       Lavanya Kavuri
* @Date         09/12/2021
* @Description  This class is used for Payment Regeneration Request LWC.
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Lavanya Kavuri     09/12/2021          Created                                                    
*******************************************************************************************/
@isTest
public with sharing class PaymentRegenerationRequestTest {

    private static final Id APP_CASE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VHF_Application_Record_Type').getRecordTypeId();
    private static final Id PAYMENT_CASE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Early_Payment').getRecordTypeId();
    @TestSetup
    static void makeData(){

        UserRole customRole = new UserRole(DeveloperName = 'CustomRole', Name = 'Custom Role');
        insert customRole;

        //Insert Sys Admin Account 
        User adminUser = VHFTestDataFactory.createAdminUser(customRole.Id, 'testadminuser@srotest.com', 'testadminuser@srotest.com'+System.currentTimeMillis(), 'Sroadmin', 'userrec', 'arodsj' );
        insert adminUser;

        System.runAs(adminUser)
        {
            //Lender Account 
            Account bankAccount = VHFTestDataFactory.createLenderAccount('Oz Bank');
            insert bankAccount; 

            //Lender Contact 
            Contact bankLender = VHFTestDataFactory.createLenderContact(bankAccount.Id, 'ozbank', 'lender', 'ozbank.lender@banktest.com', '+61 03 9111 1111');
            insert bankLender; 

            //Applicant Person Account
            Account applicantAcct = VHFTestDataFactory.createApplicantPersonAccount('yes');
            insert applicantAcct;

            //Create Case 
            Case applicantCase = VHFTestDataFactory.createCase(applicantAcct.Id, 'Submitted', 'Pending', APP_CASE_RECORDTYPEID);
            insert applicantCase;

            //Create Reg Auth 
            RegulatoryAuthorizationType regAuth = VHFTestDataFactory.createRegAuth('Victorian Homebuyer Fund', 'License');
            insert regAuth;

            //Individual Application 
            IndividualApplication provApp = VHFTestDataFactory.createProvisionalApplication(regAuth.Id, bankAccount.Id, bankLender.Id, applicantAcct.Id, applicantCase.Id);
            insert provApp;

            //Applicant 
            Applicant__c applicant = VHFTestDataFactory.createApplicant(applicantAcct.Id, provApp.Id);
            insert applicant;

            //Final Application 
            Contract finalApp = VHFTestDataFactory.createFinalApplication(provApp.Id, applicantAcct.Id, 'Draft', applicantCase.Id, 20, '1', '1', '1', 999, bankLender.Id);
            insert finalApp;

            //Property 
            Order property1 = VHFTestDataFactory.createProperty(applicantAcct.Id, 'Draft', bankAccount.Id);
            insert property1;

            //Insert Payment Case 
            Case paymentCase = VHFTestDataFactory.createCase(applicantAcct.Id, 'In progress', 'Pending', PAYMENT_CASE_RECORDTYPEID);
            insert paymentCase;

            //Insert Payment 
            Payment__c paymentRecords = VHFTestDataFactory.createPayment('Created', paymentCase.Id, applicantAcct.Id);
            insert paymentRecords;

        }
    }

    /*
    * Unit Test Method for all Validations Passed Scenario.
    * Assert, Error Message List is Empty.
    */
    @IsTest
    static void validationSuccessTest(){
        
        Order property = [Select Id, Shared_Equity_Interest__c, Shared_Equity_Money__c from Order LIMIT1];
        property.Shared_Equity_Interest__c = 20;
        property.Shared_Equity_Money__c = 200000;
        update property;
        System.debug('Property=' + property);

        Case caseRec = [Select Id, SEI_OLD__c, SEM_OLD__c, Property__c from Case WHERE RecordTypeId =: PAYMENT_CASE_RECORDTYPEID];
        caseRec.SEI_OLD__c = 20;
        caseRec.SEM_OLD__c = 200000;
        caseRec.Property__c = property.Id;
        caseRec.Property_Valuation_Date__c = System.today();
        update caseRec;
        System.debug('Case =' + caseRec);

        Payment__c paymentRec = [Select Id, Property__c, Primary_Participant__c, Cancellation_Comments__c, Cancellation_Reason__c, Case__c, Status__c, Payment_Regenerated__c from Payment__c LIMIT 1];
        paymentRec.Property__c = property.Id;
        paymentRec.Cancellation_Reason__c = 'Other';
        paymentRec.Cancellation_Comments__c = 'Cancelled payment';
        paymentRec.Status__c = 'Cancelled';
        update paymentRec;
        System.debug('Payment=' + paymentRec);

        Test.startTest();
        String response = PaymentRegenerationRequest.validateRequest(paymentRec.Id);
        Map<String,Object> jsonResponse = (Map<String,Object>) JSON.deserializeUntyped(response);
        System.debug('jsonresponse=' + jsonResponse);
        String errorsData = (String)jsonResponse.get('errors');
        System.debug('errors' + errorsData);
        System.debug('errors length' + errorsData.length());
        System.assert(errorsData.length() == 0);
        Test.stopTest();
        
    }

    /*
    * Unit Test Method to validate if a payment regeneration was done for the payment record.
    * Assert, Error Message = Payment has already been regenerated for this Payment Record.
    */
    @IsTest
    static void validationFailureType1Test(){

        Order property = [Select Id, Shared_Equity_Interest__c, Shared_Equity_Money__c from Order LIMIT1];
        property.Shared_Equity_Interest__c = 20;
        property.Shared_Equity_Money__c = 200000;
        update property;
        System.debug('Property=' + property);

        Case caseRec = [Select Id, SEI_OLD__c, SEM_OLD__c, Property__c from Case WHERE RecordTypeId =: PAYMENT_CASE_RECORDTYPEID];
        caseRec.SEI_OLD__c = 20;
        caseRec.SEM_OLD__c = 200000;
        caseRec.Property__c = property.Id;
        caseRec.Property_Valuation_Date__c = System.today();
        update caseRec;
        System.debug('Case =' + caseRec);

        Payment__c paymentRec = [Select Id, Property__c, Case__c, Payment_Regenerated__c from Payment__c LIMIT 1];
        paymentRec.Property__c = property.Id;
        paymentRec.Payment_Regenerated__c = true;
        update paymentRec;
        System.debug('Payment=' + paymentRec);

        Test.startTest();
        try {
          PaymentRegenerationRequest.validateRequest(paymentRec.Id);
        } catch (AuraHandledException e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.assert(e.getMessage().contains('Payment has already been regenerated for this Payment Record.'));
        }

        Test.stopTest();
        
    }

    /*
    * Unit Test Method to validate there are no active payments exists for the property.
    * Assert, Error Message = active payment requests have been completed.
    */
    @IsTest
    static void validationFailureType2Test(){
        
        Order property = [Select Id, Shared_Equity_Interest__c, Shared_Equity_Money__c from Order LIMIT1];
        property.Shared_Equity_Interest__c = 20;
        property.Shared_Equity_Money__c = 200000;
        update property;
        System.debug('Property=' + property);

        Case caseRec = [Select Id, SEI_OLD__c, SEM_OLD__c, Property__c from Case WHERE RecordTypeId =: PAYMENT_CASE_RECORDTYPEID];
        caseRec.SEI_OLD__c = 20;
        caseRec.SEM_OLD__c = 200000;
        caseRec.Property__c = property.Id;
        caseRec.Property_Valuation_Date__c = System.today();
        update caseRec;
        System.debug('Case =' + caseRec);

        Payment__c paymentRec = [Select Id, Property__c, Case__c, Status__c, Payment_Regenerated__c from Payment__c LIMIT 1];
        paymentRec.Property__c = property.Id;
        update paymentRec;
        System.debug('Payment=' + paymentRec);

        Test.startTest();
        String response = PaymentRegenerationRequest.validateRequest(paymentRec.Id);
        Map<String,Object> jsonResponse = (Map<String,Object>) JSON.deserializeUntyped(response);
        System.debug('jsonresponse=' + jsonResponse);
        String errorsData = (String)jsonResponse.get('errors');
        System.debug('errors' + errorsData);
        System.debug('errors length' + errorsData.length());
        String errorMesage; 
        List<Object> errors = (List<Object>) JSON.deserializeUntyped(errorsData);
        for(Object obj: errors)
        {
            errorMesage = (String)obj;
            System.debug(errorMesage);
        }
        System.assert(errorMesage.contains('active payment requests have been completed'));
        Test.stopTest();
        
    }

    /*
    * Unit Test Method to validate SEI and SEM are same in case and property.
    * Assert, Error Message = current SEI matches on the case and property.
    */
    @IsTest
    static void validationFailureType3Test(){
        
        Order property = [Select Id, Shared_Equity_Interest__c, Shared_Equity_Money__c from Order LIMIT1];
        property.Shared_Equity_Interest__c = 10;
        property.Shared_Equity_Money__c = 100000;
        update property;
        System.debug('Property=' + property);

        Case caseRec = [Select Id, SEI_OLD__c, SEM_OLD__c, Property__c from Case WHERE RecordTypeId =: PAYMENT_CASE_RECORDTYPEID];
        caseRec.SEI_OLD__c = 20;
        caseRec.SEM_OLD__c = 200000;
        caseRec.Property__c = property.Id;
        caseRec.Property_Valuation_Date__c = System.today();
        update caseRec;
        System.debug('Case =' + caseRec);

        Payment__c paymentRec = [Select Id, Property__c, Case__c, Cancellation_Reason__c, Cancellation_Comments__c, Status__c, Payment_Regenerated__c from Payment__c LIMIT 1];
        paymentRec.Property__c = property.Id;
        paymentRec.Cancellation_Reason__c = 'Other';
        paymentRec.Cancellation_Comments__c = 'Cancelled payment';
        paymentRec.Status__c = 'Cancelled';
        update paymentRec;
        System.debug('Payment=' + paymentRec);

        Test.startTest();
        String response = PaymentRegenerationRequest.validateRequest(paymentRec.Id);
        Map<String,Object> jsonResponse = (Map<String,Object>) JSON.deserializeUntyped(response);
        System.debug('jsonresponse=' + jsonResponse);
        String errorsData = (String)jsonResponse.get('errors');
        System.debug('errors' + errorsData);
        System.debug('errors length' + errorsData.length());
        String errorMesage; 
        List<Object> errors = (List<Object>) JSON.deserializeUntyped(errorsData);
        for(Object obj: errors)
        {
            errorMesage = (String)obj;
            System.debug(errorMesage);
        }
        System.assert(errorMesage.contains('SEI and SEM has been updated. Create a new case and request payment'));
        Test.stopTest();
        
    }

    /*
    * Unit Test Method to validate if valuation of the property is current.
    * Assert, Error Message = Valuation details are less than 90 days old.
    */
    @IsTest
    static void validationFailureType4Test(){
        
        Order property = [Select Id, Shared_Equity_Interest__c, Shared_Equity_Money__c from Order LIMIT1];
        property.Shared_Equity_Interest__c = 20;
        property.Shared_Equity_Money__c = 200000;
        update property;
        System.debug('Property=' + property);

        Case caseRec = [Select Id, SEI_OLD__c, SEM_OLD__c, Property__c from Case WHERE RecordTypeId =: PAYMENT_CASE_RECORDTYPEID];
        caseRec.SEI_OLD__c = 20;
        caseRec.SEM_OLD__c = 200000;
        caseRec.Property__c = property.Id;
        caseRec.Property_Valuation_Date__c = System.today() - 92;
        update caseRec;
        System.debug('Case =' + caseRec);

        Payment__c paymentRec = [Select Id, Property__c, Cancellation_Comments__c, Cancellation_Reason__c, Case__c, Status__c, Payment_Regenerated__c from Payment__c LIMIT 1];
        paymentRec.Property__c = property.Id;
        paymentRec.Cancellation_Reason__c = 'Other';
        paymentRec.Cancellation_Comments__c = 'Cancelled payment';
        paymentRec.Status__c = 'Cancelled';
        update paymentRec;
        System.debug('Payment=' + paymentRec);

        Test.startTest();
        String response = PaymentRegenerationRequest.validateRequest(paymentRec.Id);
        Map<String,Object> jsonResponse = (Map<String,Object>) JSON.deserializeUntyped(response);
        System.debug('jsonresponse=' + jsonResponse);
        String errorsData = (String)jsonResponse.get('errors');
        System.debug('errors' + errorsData);
        System.debug('errors length' + errorsData.length());
        String errorMesage; 
        List<Object> errors = (List<Object>) JSON.deserializeUntyped(errorsData);
        for(Object obj: errors)
        {
            errorMesage = (String)obj;
            System.debug(errorMesage);
        }
        System.assert(errorMesage.contains('Valuation details are less than 90 days old'));
        Test.stopTest();
        
    }

    /*
    * Unit Test Method to generate a new payment request.
    * Assert, new payment record created.
    */
    @IsTest
    static void createPaymentRequestTest(){
        
        Order property = [Select Id, Shared_Equity_Interest__c, Shared_Equity_Money__c from Order LIMIT1];
        property.Shared_Equity_Interest__c = 20;
        property.Shared_Equity_Money__c = 200000;
        update property;
        System.debug('Property=' + property);

        Case caseRec = [Select Id, SEI_OLD__c, SEM_OLD__c, Property__c from Case WHERE RecordTypeId =: PAYMENT_CASE_RECORDTYPEID];
        caseRec.SEI_OLD__c = 20;
        caseRec.SEM_OLD__c = 200000;
        caseRec.Property__c = property.Id;
        caseRec.Property_Valuation_Date__c = System.today() - 92;
        update caseRec;
        System.debug('Case =' + caseRec);

        Payment__c paymentRec = [Select Id, Property__c, Case__c, Cancellation_Reason__c, Cancellation_Comments__c, Status__c, Payment_Regenerated__c from Payment__c LIMIT 1];
        paymentRec.Property__c = property.Id;
        paymentRec.Cancellation_Reason__c = 'Other';
        paymentRec.Cancellation_Comments__c = 'Cancelled payment';
        paymentRec.Status__c = 'Cancelled';
        update paymentRec;
        System.debug('Payment=' + paymentRec);

        Test.startTest();

        Payment__c newPaymentRec = PaymentRegenerationRequest.createPaymentRequest(paymentRec.Id, 'this is test'); 
        System.assert(newPaymentRec != null);
        
        Test.stopTest();
        
    }


}