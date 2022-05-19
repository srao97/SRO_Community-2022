/*******************************************************************************************
* @Name         PaymentNotificationsFlowTest Class
* @Author       Lavanya Kavuri
* @Date         09/12/2021
* @Description  This is unit test for the Flow: PaymentNotifications
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Lavanya Kavuri     14/12/2021          Created                                                    
*******************************************************************************************/
@isTest
public with sharing class PaymentNotificationsFlowTest {

    private static final Id APP_CASE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VHF_Application_Record_Type').getRecordTypeId();
    private static final Id PAYMENT_CASE_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Final_Early_Payment').getRecordTypeId();
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
            Payment__c paymentRecords = VHFTestDataFactory.createPayment('Payment Registered', paymentCase.Id, applicantAcct.Id);
            insert paymentRecords;

        }
    }

    

    @IsTest
        static void paymentRegisteredNodeTest(){
            Payment__c payment = [Select Id, Status__c, Requested_Date__c from Payment__c LIMIT 1 ];
            System.debug('Payment Record=' + payment);
            Test.startTest();
            System.assertEquals('Payment Requested', payment.Status__c);
            System.assert(payment.Requested_Date__c != null);
            Test.stopTest();
            
        }
    
        @IsTest
        static void paymentReceivedNodeTest(){

            Order property = [Select Id, Shared_Equity_Interest__c, Shared_Equity_Money__c from Order LIMIT 1];

            Case paymentCase = [Select Id, Property__c, Type from Case Where RecordTypeId =: PAYMENT_CASE_RECORDTYPEID LIMIT 1] ;
            paymentCase.Type = 'Windfall Gain';
            paymentCase.Property__c = property.Id;
            paymentCase.SEI_new__c = 20;
            paymentCase.SEM_new__c = 200000;
            update paymentCase; 
            System.debug('case rec=' + paymentCase);

            Payment__c updatePayment = [Select Id, Status__c, Property__c, Case__c, Property__r.Shared_Equity_Interest__c, Property__r.Shared_Equity_Money__c from Payment__c LIMIT 1 ];
            updatePayment.Status__c = 'Payment Received';
            updatePayment.Case__c = paymentCase.Id;
            updatePayment.Property__c = property.Id;
            update updatePayment;
            System.debug('payment record=' + updatePayment);

            Payment__c paymentRec = [Select Id, Case__c, Property__c, Property__r.Shared_Equity_Interest__c, Property__r.Shared_Equity_Money__c, Status__c from Payment__c where Case__c =: paymentCase.Id ];
            System.debug('updated payment rec=' + paymentRec);
            
            Test.startTest();
            
            System.assertEquals(paymentRec.Property__r.Shared_Equity_Interest__c, paymentCase.SEI_new__c);
            System.assertEquals(paymentRec.Property__r.Shared_Equity_Money__c, paymentCase.SEM_new__c);

            Test.stopTest();
            
        }

        @IsTest
        static void paymentNotReceivedNodeTest(){
            Payment__c payment = [Select Id, Status__c, Requested_Date__c from Payment__c LIMIT 1 ];
            payment.Status__c = 'Payment Requested';
            payment.Requested_Date__c = System.today() - 15;

            EmailMessage emailMsg = new EmailMessage();
            emailMsg.FromAddress = 'no-reply@sro.vic.gov.au';
            emailMsg.FromName = 'State Revenue Office Victoria';
            emailMsg.HtmlBody =  '<h1>This is a test email message</h1>';
            emailMsg.IsTracked = true;
            emailMsg.MessageDate = System.today();
            emailMsg.RelatedToId = payment.Id;
            emailMsg.Status = '3';
            emailMsg.Subject = 'This is atest';
            emailMsg.ToAddress = 'test@testeamil.com';
            insert emailMsg;


            Test.startTest();
            
            EmailMessage emailMesasge = [Select Id, ParentId from EmailMessage where RelatedToId =: payment.Id ];
            System.assert(emailMessage.Id != null);

            Test.stopTest();
            
        }
}