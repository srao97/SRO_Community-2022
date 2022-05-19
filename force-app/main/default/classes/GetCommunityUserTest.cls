/*******************************************************************************************/
/*  LOG
* Version           Created by          Date               Description
*-------------------------------------------------------------------------------------------
*  1.1              Manish Jhingran      11/10/2021          Test class for GetCommunity User                                                   
*******************************************************************************************/
@isTest(SeeAllData = FALSE)
public class GetCommunityUserTest {
    public static testMethod void GetCommunityUserTestCase()

    {
        Account testAccount = new Account(Name = 'Test Name');
        insert testAccount;

        Contact cont = new Contact();
        cont.FirstName = 'Test';
        cont.LastName = 'testContact';
        cont.accountid = testAccount.id;
        cont.Email = 'Test@test.com';
        insert cont;
      
  
     List<Contact> conLocalList = new List<Contact>([select id from Contact where id =:cont.id ]);
        List < Id > CntId = new List < Id > ();
        for (Contact ConObj: conLocalList) {
            CntId.add(ConObj.Id);
        }

        Test.startTest();
        GetCommunityUser.GetCommunityPortalUser(CntId);
        Test.stopTest();
        
        }
        
        }