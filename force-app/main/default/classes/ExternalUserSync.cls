/*******************************************************************************************
* @Name         ExternalUserSync
* @Author       Lawrence Tang
* @Date         10/11/2021
* @Description  This Queueable is used by PersonAccountUserSyncHandler or ContactUserSyncHandler
*				to sync external user with person account or contact records 
*******************************************************************************************/
public class ExternalUserSync implements Queueable {
    
    private List<Account> personAccount;
    private List<Contact> contact;
    
    public ExternalUserSync(List<Account> record){
        this.personAccount = record;
    }
    
    public ExternalUserSync(List<Contact> record){
        this.contact = record;
    }
    public void execute(QueueableContext context) {
        if (personaccount != null){
 			update personAccount;
        }
        else if (contact != null){
 			update contact;
        }
    }
}