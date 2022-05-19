@isTest
public class updateAnnualReviewTaskTriggerHelperTest {
	@IsTest
    private static void testUpdateAnnualReview() {
        
        Account businessAcc = new account(Name='HSBC',type='Investor', vlocity_ins__Email__c='test191@yahoo.com');
        insert businessAcc;
        
        Order property = new order(accountId=businessAcc.id,EffectiveDate=System.today(), Status='Draft', Panel_Financier_Name__c=businessAcc.id);
        insert property;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
        RecordTypeID=recordTypeId ,
        FirstName='Test FName',
        LastName='Test LName',
        PersonMailingStreet='test@yahoo.com',
        PersonMailingPostalCode='1234',
        PersonMailingCity='SFO',
        PersonMailingState='Victoria',
        PersonEmail='test@yahoo.com',
        PersonHomePhone='1234567',
        PersonMobilePhone='12345678',
        property__c = property.id,
        Is_Participant__pc = true,
        IsActiveApplicant__pc = 'Yes'
        );
        
        insert acc;
        
        contact con = [select id from contact where accountid =: acc.id limit 1];
        Campaign camp = new Campaign(Name = 'Test11', IsActive = TRUE);            
		insert camp;
        
        CampaignMember member = new CampaignMember(
    	ContactId = con.id,
    	Status = 'Sent',
    	CampaignId = camp.Id
    	);
		insert member;
            
        Annual_review__c annualReview = new Annual_review__c(status__c='Awaiting Verification', Primary_Participant__c=acc.id, Property__c=property.id);
        insert annualReview;
            
        task newTask = new task(status='Open', whatId=annualReview.id);
        insert newTask;
            
        list<task> taskList = [select id, status from task where status = 'Open' limit 1];
        taskList[0].status = 'Completed';
        update taskList;
        
        system.assertEquals('Submitted',[select status__c from Annual_review__c].status__c);
    }

}