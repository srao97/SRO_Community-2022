/*******************************************************************************************
* @Name         ShareContentDocumentTriggerHandlerTest 
* @Author       
* @Date         
* @Description  
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              
*  1.1              Lavanya Kavuri     25/11/2021          Fixed the Test Class                                                     
*******************************************************************************************/
@IsTest
Public Class ShareContentDocumentTriggerHandlerTest{

@isTest
Public static void TestMethodCaseOne()
{
        Test.startTest();
        RegulatoryAuthorizationType testRegulatoryAuthorizationType = new RegulatoryAuthorizationType(Name = 'Test');
        insert testRegulatoryAuthorizationType;

        Case testCase = new Case();
        insert testCase;
        IndividualApplication testIndividualApplication = new IndividualApplication(
                                                                LicenseTypeId = testRegulatoryAuthorizationType.Id, 
                                                                AppliedDate = System.now(), 
                                                                ApplicationCaseId = testCase.Id,
                                                                Category = 'Grant');
        insert testIndividualApplication;

        
        Network oNetwork = [SELECT Id from Network where Name = 'Partner Portal'];
        
        ContentVersion ObjCV1= new ContentVersion(NetworkId = oNetwork.Id, Title='Test',PathOnClient='Test.jpg',VersionData=Blob.valueOf('Test Content'),IsmajorVersion=true);
        Insert ObjCV1;
        
        ContentVersion ObjCV2= [Select Id,title,ContentDocumentId from Contentversion Where Id=:ObjCV1.Id limit 1];
        List<ContentDocument> documents =[Select Id,title,parentid,LatestpublishedVersionId from ContentDocument where id=:ObjCV2.ContentDocumentId];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = testIndividualApplication.Id;
        cdl.ContentDocumentId = documents[0].Id;
        insert cdl;

        List<String> docIds = new List<Id>(); 
        for(ContentDocument cd : documents)
        {
                docIds.add(cd.Id);
        }

        ShareContentDocumentTriggerHandler.Executetriggeronce = true;
        ShareContentDocumentTriggerHandler.ShareContentDocuments(docIds);
        
        Test.stopTest();

}



}