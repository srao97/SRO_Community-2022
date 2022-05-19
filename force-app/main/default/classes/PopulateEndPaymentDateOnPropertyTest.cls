/*******************************************************************************************
* @Name         PopulateEndPaymentDateOnPropertyTest
* @Author       Pradeep Selvaraj
* @Date         14/04/2022
* @Description  : Test class for PopulateEndPaymentDateOnProperty
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Pradeep            13/04/2022          Initial Creation                                 
*******************************************************************************************/

@IsTest
public class PopulateEndPaymentDateOnPropertyTest {
	
    @IsTest
     static void testEndPaymentDatePopulation(){
         
      /*   Account lender = VHFTestDataFactory.createLenderAccount('Commbank');
         insert lender;
         Account a = VHFTestDataFactory.createApplicantPersonAccountWithDetails('Yes','Mike','The Tester','mike@testing101.com');
         a.Is_Participant__pc = true;
         insert a;
         Order property = VHFTestDataFactory.createProperty(String.valueOf(a.id), 'Draft', String.valueOf(lender.id));
         insert property;
         a.Property__c = property.id;
         update a;
         Id refinanceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Refinance').getRecordTypeId();
         
         Case testCase = VHFTestDataFactory.createCase(String.valueOf(a.id), 'Refinanced - Same PF', 'Completed', String.valueOf(refinanceRecordTypeId));
         insert testCase;
         
         //update case
         testCase.Property__c = property.id ; 
         testCase.Current_Loan_Maturity_Date__c = Date.newInstance(2052, 02, 03);
         testcase.Actual_Settlement_Date__c = Date.newInstance(2022, 01, 02);
         testCase.Refinanced_Loan_Maturity_Date__c = Date.newInstance(2052, 02, 02);
         system.debug(testCase);
         update testCase;
         */
         
         //check if property is updated 
         
     }
}