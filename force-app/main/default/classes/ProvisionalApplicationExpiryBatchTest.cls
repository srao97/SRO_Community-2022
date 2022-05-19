/*******************************************************************************************
* @Name         ProvisionalApplicationExpiryBatchTest
* @Author       Manish Jhingran<manish.jhingran@salesforce.com>
* @Date         10/09/2021
* @Description  This class tests the functionality of ProvisionalApplicationExpiryBatchTest
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Manish Jhingran      10/09/2021          Initial Creation                                                      
*******************************************************************************************/
@isTest
public with sharing class ProvisionalApplicationExpiryBatchTest {
    // Keep scope less than or equal to batchSize for assertion to work
    private static integer scope = 200;
    private static integer batchSize = 200;

    public static testMethod void TestInsertProvApplicationRecords(){
        // Create ProvApplication Records
          // Regulatory Authorisation Type
    RegulatoryAuthorizationType testRegulatoryAuthorizationType = new RegulatoryAuthorizationType(Name = 'Test');
    insert testRegulatoryAuthorizationType;
    Case testCase = new Case();
        insert testCase;
       
         List<IndividualApplication>  ProvAppList1 = new  List<IndividualApplication> ();
         List<IndividualApplication>  ProvAppList2 = new  List<IndividualApplication> ();
         List<IndividualApplication>  ProvAppList3 = new  List<IndividualApplication> ();
         for(Integer i = 0; i < scope; i++){
         ProvAppList1.add(new IndividualApplication( LicenseTypeId = testRegulatoryAuthorizationType.Id, 
                                                                AppliedDate = System.now(), 
                                                                ApplicationCaseId = testCase.Id,
                                                                Hard_Expiry_Date__c=Date.valueOf(System.now()),
                                                                Final_Application_In_Progress_c__c=false,
                                                                ApplicantNames__c='Test',
                                                                //Status = 'Provisionally Approved',
                                                                Expiry_Date1__c=Date.valueOf(System.now())));
        }
        
 
        insert ProvAppList1;
        // Run Batch
        Test.startTest();
       
 
        ProvisionalApplicationExpiryBatch ProvisionalApplicationExpiry = new ProvisionalApplicationExpiryBatch();
        ProvisionalApplicationExpiry.execute(null,ProvAppList1);
        DataBase.executeBatch(ProvisionalApplicationExpiry); 
        ProvisionalApplicationExpiry.execute(null,ProvAppList1);
        Test.stopTest();

        
    }
}