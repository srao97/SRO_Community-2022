@isTest
public  class sroPartnerCommunityCustomLogoTest {

private static final Decimal CONST_MEDICARE_NUM = Decimal.valueOf('21234567080');
    private static final Decimal CONST_CARD_NUM = Decimal.valueOf('212345670');
    private static final Decimal CONST_REF_NUM = Decimal.valueOf('1');
    private static final String PROFILE = 'VHF Lender Community Plus User';
    private static final Id PERSONACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final Id BUSINESSACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    private static final Id STANDARDCONTACT_RECORDTYPEID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
    
    @TestSetup
    private static void setup() {

        UserRole customRole = new UserRole(DeveloperName = 'CustomRole', Name = 'Custom Role');
        insert customRole;
        
        User userWithARole = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            firstName = 'Role',
            LastName = 'User',
            Email = 'testSysAdUser@test.com',
            Username = 'testSysAdUser@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Australia/Sydney',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_AU',
            UserRoleId = customRole.Id
        );
        insert userWithARole;
        
        user sysAdUser = [SELECT Id FROM user WHERE Email = 'testSysAdUser@test.com'];
        System.runAs(sysAdUser) {

            Account oOzBankRecord = new Account(
                Name = 'Oz Bank',
                ownerId= sysAdUser.id,
                recordtypeid = BUSINESSACCOUNT_RECORDTYPEID
            );
            insert oOzBankRecord;

            Contact oContact = new Contact(
                FirstName='lender',
                LastName='officer1',
                Email = 'lender.Officer1@getnada.com',
                Phone = '+61 2 9311 1111',
                AccountId = oOzBankRecord.Id,
                recordtypeid = STANDARDCONTACT_RECORDTYPEID
            );
            insert oContact;
            
            Profile communityProfile = [SELECT Id FROM profile WHERE Name = :PROFILE Limit 1];
            User comPortalUser = new User();
            comPortalUser.ContactId = oContact.Id;
            comPortalUser.Username = oContact.Email;
            comPortalUser.Email = oContact.Email;
            comPortalUser.LastName = oContact.LastName;
            comPortalUser.CommunityNickname = oContact.LastName + '_' + System.currentTimeMillis();
            comPortalUser.Alias = string.valueOf(oContact.LastName.substring(0,1) + Math.random() ).substring(0,5);
            comPortalUser.TimeZoneSidKey = 'Australia/Sydney';
            comPortalUser.LocaleSidKey = 'en_AU';
            comPortalUser.EmailEncodingKey = 'ISO-8859-1';
            comPortalUser.ProfileId = communityProfile.Id;
            comPortalUser.LanguageLocaleKey = 'en_US';
            comPortalUser.IsActive = true;
            insert comPortalUser;
            
            
            Account account = new Account();
            account.Name = 'Test';
            account.document_ID__c = '123456';
            insert account;
            
            
           
}
}
            
    static testMethod void testCase1() {
        user sysAdUser = [SELECT Id FROM user WHERE Email = 'testSysAdUser@test.com'];
        System.runAs(sysAdUser)
        {
        Test.startTest();
        System.debug(UserInfo.getUserId());
        sroPartnerCommunityCustomLogo.getDocumentLogoUrl();
        Test.stopTest();
        }
    }
}