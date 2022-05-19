/*******************************************************************************************/
/*  LOG
* Version           Created by          Date               Description
*-------------------------------------------------------------------------------------------
*  1.1              Manish Jhingran      06/10/2021          Get Community User by related ContactId                                                    
*******************************************************************************************/

public class GetCommunityUser
{
@InvocableMethod
Public static List<Id> GetCommunityPortalUser(List < ID > contactID)
{

List<id> ComUserList=new List<id>();
for(User USList: [select id from User where ContactId in:contactID]){
  ComUserList.add(USList.id);
  system.debug('ids'+ ComUserList);
}

return ComUserList;

}
}