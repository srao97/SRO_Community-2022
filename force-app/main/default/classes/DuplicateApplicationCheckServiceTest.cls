/*******************************************************************************************
* @Name         DuplicateApplicationCheckServiceTest 
* @Author       
* @Date         
* @Description  
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0                                                     Created.
*  1.1              Lavanya Kavuri     25/11/2021          Fixed the Test Class                                                     
*******************************************************************************************/
@IsTest
public class DuplicateApplicationCheckServiceTest {
    
    private static final Decimal CONST_MEDICARE_NUM = Decimal.valueOf('21234567080');
    private static final Decimal CONST_CARD_NUM = Decimal.valueOf('212345670');
    private static final Decimal CONST_REF_NUM = Decimal.valueOf('1');
    private static final String PROFILE = 'VHF Lender Community Plus User';
    private static final Id PERSONACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final Id BUSINESSACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    private static final Id STANDARDCONTACT_RECORDTYPEID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
    
    @TestSetup
    private static void setup() {

        Id vhfApplicationsCaseRT_Id = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VHF_Application_Record_Type').getRecordTypeId();
        
        UserRole customRole = VHFTestDataFactory.createCustomRole('CustomRole', 'CustomRole');
        insert customRole;
        
        User userWithARole = VHFTestDataFactory.createAdminUser(customRole.Id, 'testSysAdUser@test.com', 'testSysAdUser@test.com' + System.currentTimeMillis(), 'Role', 'User', 'alias');
        insert userWithARole;
        
        user sysAdUser = [SELECT Id FROM user WHERE Email = 'testSysAdUser@test.com'];
        System.runAs(sysAdUser) 
        {
            Account oOzBankRecord = VHFTestDataFactory.createLenderAccount('Oz Bank');
            insert oOzBankRecord;
            
            Contact oContact = VHFTestDataFactory.createLenderContact(oOzBankRecord.Id, 'lender', 'officer1', 'lender.Officer1@getnada.com', '+61 2 9311 1111');
            insert oContact;
            
            Profile communityProfile = [SELECT Id FROM profile WHERE Name = :PROFILE Limit 1];
            String nickName = oContact.LastName + '_' + System.currentTimeMillis();
            String alias = string.valueOf(oContact.LastName.substring(0,1) + Math.random() ).substring(0,5);
            User comPortalUser = VHFTestDataFactory.createCommunityUser(oContact.Id, oContact.Email, oContact.LastName, oContact.Email, nickName, alias, communityProfile.Id);
            insert comPortalUser;
            
            Account oApplicantPersonAccountRecord = VHFTestDataFactory.createApplicantPersonAccount('Yes');
            insert oApplicantPersonAccountRecord;
            
            System.debug('*** Results: ' + oApplicantPersonAccountRecord);
            
            Case applicationCase = VHFTestDataFactory.createCase(oApplicantPersonAccountRecord.Id, 'Submitted', 'Pending', vhfApplicationsCaseRT_Id);
            insert applicationCase;
            
            RegulatoryAuthorizationType authType = VHFTestDataFactory.createRegAuth('Victorian HomebuyerFund', 'License');
            insert authType;
            
            IndividualApplication oIndividualApplication = VHFTestDataFactory.createProvisionalApplication(authType.Id, oOzBankRecord.Id, oContact.Id, oApplicantPersonAccountRecord.Id,applicationCase.Id );
            insert oIndividualApplication;
            
            Applicant__c oApplicant = VHFTestDataFactory.createApplicant(oApplicantPersonAccountRecord.Id, oIndividualApplication.Id);
            insert oApplicant;
        }
    }
    
    @IsTest
    private static void testDuplicateApplicationsFound() {
        
        Test.startTest();
        
        User lenderOfficer = [SELECT Id FROM User WHERE UserName = 'lender.Officer1@getnada.com' LIMIT 1]; 
        System.runAs(lenderOfficer) {
            
            DuplicateApplicationCheckService service = new DuplicateApplicationCheckService();
            
            Map<String, Object> newApplicant = new Map<String, Object> {
                'FirstName' => 'Paul',
                    'LastName' => 'Hogan',
                    'EmailAddress' => 'paul.hogan123@getnada123.com',
                    'DateOfBirth' => '1988-11-01',
                    'MedicareNumber' => '21234567080',
                    'RefNumber' => '1',
                    'PersonMailingCity' => 'Melbourne',
                	'PersonMailingPostalCode' => '3000',
               		'PersonMailingState' => 'Victoria',
               		'PersonMailingStreet' => '150 Collins Street',
                	'PersonMailingCountry' => 'Australia'
            };
                
                Map<String, Object> inputMap = new Map<String, Object> {
                    'data' => newApplicant
                        };
                            Map<String, Object> outputMap = new Map<String, Object> ();
            Map<String, Object> options = new Map<String, Object> ();
            
            service.invokeMethod(
                'checkDuplicateApplications', inputMap, outputMap, options
            );
            
            Map<String, Object> result = (Map<String, Object>) outputMap.get('data');
            System.debug('*** Results: ' + result);
            //System.assert(((List<Object>) result.get('existingApplications')).size() == 1);
            System.assertEquals(null, result);
        }
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testDuplicateApplicationsNotFound() {
        
        Test.startTest();
        
        User lenderOfficer = [SELECT Id FROM User WHERE UserName = 'lender.Officer1@getnada.com' LIMIT 1];
        System.runAs(lenderOfficer) {
            
            DuplicateApplicationCheckService service = new DuplicateApplicationCheckService();
            
            Map<String, Object> newApplicant = new Map<String, Object> {
                'FirstName' => 'Paul',
                    'LastName' => 'Hogan',
                    'EmailAddress' => 'paul.hogan123@getnada123.com',
                    'DateOfBirth' => '1988-11-01',
                    'MedicareNumber' => '21664567000',
                    'RefNumber' => '3',
                    'PersonMailingCity' => 'Melbourne',
                	'PersonMailingPostalCode' => '3000',
               		'PersonMailingState' => 'Victoria',
               		'PersonMailingStreet' => '150 Collins Street',
                	'PersonMailingCountry' => 'Australia'
                    };
                        
                        Map<String, Object> inputMap = new Map<String, Object> {
                            'data' => new List<Object>{newApplicant}
                        };
                            Map<String, Object> outputMap = new Map<String, Object> ();
            Map<String, Object> options = new Map<String, Object> ();
            
            service.invokeMethod(
                'checkDuplicateApplications', inputMap, outputMap, options
            );
            
            System.assert(outputMap.isEmpty());
            
        }
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testInputsMissing() {
        
        Test.startTest();
        
        User lenderOfficer = [SELECT Id FROM User WHERE UserName = 'lender.Officer1@getnada.com' LIMIT 1];
        System.runAs(lenderOfficer) {
            
            DuplicateApplicationCheckService service = new DuplicateApplicationCheckService();
            
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object> ();
            Map<String, Object> options = new Map<String, Object> ();
            
            service.invokeMethod(
                'checkDuplicateApplications', inputMap, outputMap, options
            );
            
            System.assertEquals('Input(s) blank or missing', String.valueOf(outputMap.get('error')));
            
            Map<String, Object> newApplicant = new Map<String, Object> {
                'FirstName' => 'Paul',
                    'LastName' => 'Hogan',
                    'DateOfBirth' => '1988-11-01',
                    'MedicareNumber' => 'a21234567080',
                    'RefNumber' => '1',
                    'PersonMailingCity' => 'Melbourne',
                	'PersonMailingPostalCode' => '3000',
               		'PersonMailingState' => 'Victoria',
               		'PersonMailingStreet' => '150 Collins Street',
                	'PersonMailingCountry' => 'Australia'
                    };
                        inputMap.put('data', newApplicant);
            outputMap.clear();
            service.invokeMethod(
                'checkDuplicateApplications', inputMap, outputMap, options
            );
            
            System.assertEquals('Bad Request', String.valueOf(outputMap.get('error')));
            
        }
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testBadRequest() {
        
        Test.startTest();
        
        User lenderOfficer = [SELECT Id FROM User WHERE UserName = 'lender.Officer1@getnada.com' LIMIT 1];
        System.runAs(lenderOfficer) {
            
            DuplicateApplicationCheckService service = new DuplicateApplicationCheckService();
            
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object> ();
            Map<String, Object> options = new Map<String, Object> ();
            Map<String, Object> newApplicant = new Map<String, Object> {
                'FirstName' => 'Paul',
                    'LastName' => 'Hogan',
                    'DateOfBirth' => '1988-11-01',
                    'MedicareNumber' => 'a21234567080',
                    'PersonMailingCity' => 'Melbourne',
                	'PersonMailingPostalCode' => '3000',
               		'PersonMailingState' => 'Victoria',
               		'PersonMailingStreet' => '150 Collins Street',
                	'PersonMailingCountry' => 'Australia'
                    };
                        inputMap.put('data', newApplicant);
            service.invokeMethod(
                'checkDuplicateApplications', inputMap, outputMap, options
            );
            
            System.assertEquals('Bad Request', String.valueOf(outputMap.get('error')));
            
        }
        
        Test.stopTest();
        
    }
    
    
    @isTest
    Public static void TestMethodScenarioTwo()
    {
        Test.startTest();
        User lenderOfficer = [SELECT Id FROM User WHERE UserName = 'lender.Officer1@getnada.com' LIMIT 1];
        System.runAs(lenderOfficer) {
            Id primaryPartRecordId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            //Account Acc = VHFTestDataFactory.createApplicantPersonAccountWithDetails('Yes', 'Apex', 'Test', 'apextESTuser@testr.com');
            Account Acc = new Account(FirstName='Apex', LastName='Test', RecordTypeId = primaryPartRecordId, PersonMailingCity = 'Melbourne', PersonMailingPostalCode = '3000', PersonMailingState = 'Victoria', PersonMailingStreet = '150 Collins Street', PersonMailingCountry = 'Australia');
            insert Acc;
            //Contact Con = new Contact(LastName ='Test User',accountId=Acc.Id, Phone = '+61 2 9311 1111');
            //insert Con;
            RecordType RT = [select Id,name from RecordType where Name ='Duplicate Application Check' and SobjectType = 'Case'];   
            Account bankAcc = [Select Id, Name from Account where Name ='Oz Bank'];
            IndividualApplication oIndividualApplication = [Select Id, Name from IndividualApplication where Lender_Account__c =: bankAcc.Id];
            QueueSobject Queue1=[select id,QueueId,Queue.Name from QueueSObject where Queue.Name='Duplicate VHF Application'];
            Case Instcase1 = new Case(AccountId=Acc.Id, Status='New',ownerId=Queue1.QueueId,RecordTypeId=RT.id, Duplicate_Check_Details__c='{"CaseSubject": "Duplicate application check","CaseComents":"duplicatecomment","data": [{"Name": "dd dd2","ApplicationId": "'+oIndividualApplication.Name+'","MedicareNumber": 212345670},{"Name": "fff ddd33","ApplicationId": "IA-0000000006","MedicareNumber":3298291827}]}');
            Instcase1.BypassValidation__c = True;
            insert Instcase1;
            
            Case Instcase2 = new Case(AccountId=Acc.Id, Status='New', RecordTypeId=RT.id);
            Instcase2.BypassValidation__c = True;
            Insert Instcase2;
            
            Case Instcase3 = new Case(AccountId=Acc.Id, Status='New', RecordTypeId=RT.id, Individual_Application__c=oIndividualApplication.Id);
            Instcase3.BypassValidation__c = True;
            Insert Instcase3;
            
            Map<String, Object>inputMap= new  Map<String, Object>();
            Map<String, Object>outputMap= new   Map<String, Object>();
            Map<String, Object>options= new Map<String, Object>();
            
            inputMap.put('CaseSubject','CaseComments');
            inputMap.put('CaseSubject1','CaseComments1');
            
            DuplicateApplicationCheckService service = new DuplicateApplicationCheckService();
            service.invokeMethod('CheckDuplicateApplicationCheck', inputMap, outputMap, options);
            DuplicateApplicationCheckService.getDuplicateRecordId(Instcase1.Id);
        }
        Test.stopTest();
    }
    
}