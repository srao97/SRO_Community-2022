/**
 * Class Name  : LenderLogoUploadControllerTest
 * Summary     : Test class for 'LenderLogoUploadControllet'  
 * Methods     : logoUploadTest
 * @author       Sourabh Singh
   @Description: This class tests the lender logo upload controller

 * @version      $Revision: 1.0 $, $Date: 18/May/2021
 */

@isTest
public class LenderLogoUploadControllerTest 
{
    @isTest
    static void logoUploadTest() 
    {
        String result = ''; 
        Id RecordTypeIdBusiness = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account lenderAccount =  new Account(Name='test lender',RecordTypeId = RecordTypeIdBusiness);
        insert lenderAccount ;
        String base64Data = '/9j/4QAYRXhpZgAASUkqAAgAAAAAAAAAAAAAAP/sABFEdWNreQABAAQAAAA/AAD/4QRLaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA1LjAtYzA2MCA2MS4xMzQ3NzcsIDIwMTAvMDIvMTItMTc6MzI6MDAgICAgICAgICI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYm';
        String accIdString = String.valueOf(lenderAccount.Id);
        Test.startTest();
        try 
        {
            result = LenderLogoUploadController.uploadFile('Test.jpg', base64Data, 'image/jpg', lenderAccount.id);
        } catch (Exception ex) 
        {
            system.debug(ex.getMessage());
        }
        Test.stopTest();
        system.assert(result != NULL);
    }
}