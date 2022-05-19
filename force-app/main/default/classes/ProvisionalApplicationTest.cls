/*******************************************************************************************
* @Name         ProvisionalApplicationTest 
* @Author       Lawrence Tang
* @Date         07/09/2021
* @Description  This class is the test class of ProvisionalApplication Class
*******************************************************************************************/


@isTest
private class ProvisionalApplicationTest {
   
    @testSetup static void setup() {
        IndividualApplication testApp = new IndividualApplication();
        RegulatoryAuthorizationType licenseType = new  RegulatoryAuthorizationType();
        licenseType.name = 'VHF';
        insert licenseType;
        RegulatoryAuthorizationType licenseType2 = [select id from RegulatoryAuthorizationType where name = 'VHF' LIMIT 1];
        testApp.LicenseTypeId= licenseType2.id;
        testApp.Status = 'Draft';
        testApp.Processing_Officer__c = 'Test Class';
        testApp.Category = 'Grant';
  		testApp.AppliedDate = System.now();
        insert testApp;
    }

    @isTest static void testExpiryOverOneEighty() {
        
        IndividualApplication app = [select id from IndividualApplication where Processing_Officer__c = 'Test Class' LIMIT 1];
        Id testID = app.Id;
        List<Id> appIDs = new List<Id>();
        appIDs.add(testId);
        ProvisionalApplication.setExpiry(appIds);
        
        IndividualApplication app2 = [select id, Expiry_Date1__c from IndividualApplication where id = :testID];
        
        //expected minimum value is a number higher than 180 
        Date expDate = app2.Expiry_Date1__c;
        Integer difference = System.today().daysBetween(expDate);
        System.assert(difference > 180, 'The expiry date must be more than 180 days from today');
    }
    
    @isTest static void testExpiryUnderOneNinety() {

        IndividualApplication app = [select id from IndividualApplication where Processing_Officer__c = 'Test Class' LIMIT 1];
        Id testID = app.Id;
        List<Id> appIDs = new List<Id>();
        appIDs.add(testId);
        ProvisionalApplication.setExpiry(appIds);
        
        IndividualApplication app2 = [select id, Expiry_Date1__c from IndividualApplication where id = :testID LIMIT 1];
        
        //weekend not more than 2 days, public holidays in Australia can't be more than 2 in a row
        //so there should never be a scenario where 6 months from now including holidays will be 187 days away 
        Date expDate = app2.Expiry_Date1__c;
        Integer difference = System.today().daysBetween(expDate);
        System.assert(difference < 187, 'The expiry date must be less than 187 days from today');
    }
    
    @isTest static void testExpiryNotWeekend() {
        
        IndividualApplication app = [select id from IndividualApplication where Processing_Officer__c = 'Test Class' LIMIT 1];
        Id testID = app.Id;
        List<Id> appIDs = new List<Id>();
        appIDs.add(testId);
        ProvisionalApplication.setExpiry(appIds);
        
        IndividualApplication app2 = [select id, Expiry_Date1__c from IndividualApplication where id = :testID LIMIT 1];
        Date expDate = app2.Expiry_Date1__c;
        Datetime expDateTime = (DateTime)expDate;
        String dayOfWeek = expDateTime.format('EEEE');
        System.assertNotEquals(dayOfWeek, 'Sunday', 'The expiry date must not fall on a Sunday');
        System.assertNotEquals(dayOfWeek, 'Saturday', 'The expiry date must not fall on a Saturday');
    }
    
    @isTest static void testApprovalDate() {
        
        IndividualApplication app = [select id from IndividualApplication where Processing_Officer__c = 'Test Class' LIMIT 1];
        Id testID = app.Id;
        List<Id> appIDs = new List<Id>();
        appIDs.add(testId);
        ProvisionalApplication.setExpiry(appIds);
        
        IndividualApplication app2 = [select id, Provisional_Approval_Date__c from IndividualApplication where id = :testID LIMIT 1];
        Date expDate = app2.Provisional_Approval_Date__c;
        System.assertEquals(System.Date.today(), expDate, 'The provisional approval date must be today');
    }

}