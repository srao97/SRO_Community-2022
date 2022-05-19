/*******************************************************************************************
* @Name         TaskTriggerHelperTest 
* @Author       Arjun Singh
* @Date         18/11/2021
* @Description  : Handler of task trigger event
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Arjun            18/11/2021          Initial Creation                                 
*******************************************************************************************/
@isTest
public with sharing class TaskTriggerHelperTest {
    @IsTest
    private static void testTaskReassignment() {
        RegulatoryAuthorizationType RegulatoryAuthorizationTypeRec = TestDataFactory.getRegulatoryAuthorizationType();
        insert RegulatoryAuthorizationTypeRec;
       
        IndividualApplication applicationRecord = TestDataFactory.getIndividualApplication(RegulatoryAuthorizationTypeRec.Id, 'Provisional Application Submitted', system.today());
        insert applicationRecord;
        
        Individual_Application_Shadow__c shadowRecord = TestDataFactory.getIndividualApplicationShadow(applicationRecord.Id);
        insert shadowRecord;

        task newTask = new task();
        newTask.subject = 'Provisional approval extended: Victorian Homebuyer Fund - IA000';
        newTask.whatId = shadowRecord.Id;
        Test.StartTest();
            insert newTask;
        Test.StopTest();
        task createdTask = [Select Id From Task where whatId =: applicationRecord.Id];
        System.assert(createdTask != null);
        
    }
}