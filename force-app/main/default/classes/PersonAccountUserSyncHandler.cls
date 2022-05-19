/*******************************************************************************************
* @Name         PersonAccountUserSyncHandler
* @Author       Lawrence Tang
* @Date         10/11/2021
* @Description  This class is used by Update Person Account or Contact from User Record flow
*				to sync participant user with person account records 
*******************************************************************************************/
public class PersonAccountUserSyncHandler {
    
    @invocablemethod(label='Update Person Account' description='Update person account record of external user')
    public static void SyncExternalUser(List<Account> personAccount){

        ExternalUserSync updatePersonAccount = new ExternalUserSync(personAccount);
        ID jobID = System.enqueueJob(updatePersonAccount);
        
    }
    
}