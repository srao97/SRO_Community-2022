public class sroPartnerCommunityCustomLogo {
    @AuraEnabled
    public static string getDocumentLogoUrl()
    {
        string strDocUrl;
        try{
            id userId = UserInfo.getUserId();
            User u = [select id, contactId,Contact.Account.document_ID__c from User where id = : userId];
            string strOrgId = UserInfo.getOrganizationId();
            if(u.Contact.Account.document_ID__c != null) {
                strDocUrl = URL.getOrgDomainUrl().toExternalForm() + '/servlet/servlet.ImageServer?id='+u.Contact.Account.document_ID__c+'&oid=' + strOrgId;
            }
        }
        catch(exception ex){
            //
        }
        return strDocUrl; 
    }
}