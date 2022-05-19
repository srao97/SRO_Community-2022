/*******************************************************************************************
* @Name         ContactUserSyncHandler
* @Author       Lawrence Tang
* @Date         10/11/2021
* @Description  This class is used by Update Person Account or Contact from User Record flow
*				to sync external user with contact records 
*******************************************************************************************/
public class ContactUserSyncHandler {

    @invocablemethod(label='Update Contact' description='Update contact record of external user')
    public static void SyncContact(List<Contact> contact){  
		
        ExternalUserSync updateContact = new ExternalUserSync(contact);
        ID jobID = System.enqueueJob(updateContact);
        
    }
}