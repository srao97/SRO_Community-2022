/**
 * Class Name  : LenderLogoUploadController
 * Summary     : Controller class for 'LenderLogoUpload' component  
 * Methods     : uploadFile
 * @author       Sourabh Singh
   @Description: This class has methods to process lender logo image and save to documents

 * @version      $Revision: 1.0 $, $Date: 18/May/2021
 */
public without sharing class LenderLogoUploadController {
    @AuraEnabled
    public static String uploadFile(String fileName, String base64Data, String contentType, String accountId) 
    { 
        system.debug('fileName='+fileName);
        system.debug('base64Data='+base64Data);
        system.debug('contentType='+contentType);
        system.debug('accountId='+accountId);
        
        Folder folder = [select id from Folder where name='Lender Logos' LIMIT 1];
        
        Document document = new Document();    
        document.name=fileName;
        document.AuthorId = UserInfo.getUserId();//Current User Id
        document.FolderId = folder.id;  //UserInfo.getUserId();//Add Folder Id
        document.Body = EncodingUtil.base64Decode(base64Data);
        //document.type = contentType;
        document.IsPublic = true;
        
        try 
        {
            insert document;
            Account currentAccount = [select Id,Name,Document_ID__c from Account where Id = :accountId];  
            if(currentAccount != null)  
            {
                currentAccount.Document_ID__c = document.Id;
                update currentAccount;  
            }
        } 
        catch (Exception e) 
        {
            system.debug('error '+e);
        } 
        finally 
        {
            document.body = null;//Clear the State
            document = new Document();
        }
        
        return 'Success';
    }          
}