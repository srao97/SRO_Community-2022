/*******************************************************************************************
* @Name         TaskTriggerHelperTest 
* @Author       Arjun Singh
* @Date         18/11/2021
* @Description  : Test Data Creation 
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Arjun            18/11/2021          Initial Creation                                 
*******************************************************************************************/
@isTest
public with sharing class TestDataFactory {
    public static RegulatoryAuthorizationType getRegulatoryAuthorizationType(){
        return new RegulatoryAuthorizationType(Name = 'Victorian Homebuyer Fund');
    }
    public static IndividualApplication getIndividualApplication(Id RegulatoryAuthorizationTypeId, String statusVar ,date AppliedDateVar){
        IndividualApplication IndividualApplicationRecord = new IndividualApplication();
        IndividualApplicationRecord.LicenseTypeId = RegulatoryAuthorizationTypeId;
        IndividualApplicationRecord.status = statusVar;
        IndividualApplicationRecord.AppliedDate = AppliedDateVar;

        return IndividualApplicationRecord;

    }

    public static Individual_Application_Shadow__c getIndividualApplicationShadow(Id provisionalApplicataionId){
        Individual_Application_Shadow__c IndividualApplicationShadowRec = new Individual_Application_Shadow__c();
        IndividualApplicationShadowRec.Individual_Application__c = provisionalApplicataionId;

        return IndividualApplicationShadowRec;
    }
}