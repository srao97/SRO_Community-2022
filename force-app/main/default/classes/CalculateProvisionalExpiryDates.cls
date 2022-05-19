/* Created By Nayana Rev - 6 Sep 2021
*Modified by Nayana Rev - 5 OCT 2021 - VHF 2239 
*Modified by Aashish Singh Sajwan - 21 Apr 2022 - VHF-6253 - Added Without Sharing Indetifier in apex class
*/  
public without sharing class CalculateProvisionalExpiryDates {
//The below AURA enabled method is called from "ProvisionalApplicationExpiryExtension".  

@AuraEnabled
public static String calculateExpDate(Id provAppId){

//The method calculates 1st & 2nd expiry dates, gets called from "Extend Expiry Date" from Lender Portal.
    IndividualApplication provApp = [SELECT Id,
                                            Expiry_Date1__c,
                                            Hard_Expiry_Date__c,
                                            First_Extension_Requested__c,
                                            Second_Extension_Requested__c
                                     		,status,
                                            Final_Application_In_Progress_c__c 
                                    FROM IndividualApplication 
                                    WHERE Id = :provAppId];
    SYSTEM.DEBUG('provApp : '+provApp);    
    Date requestDate   = System.today();

    Date finalExpDate ;
    
    if(provApp.Final_Application_In_Progress_c__c){
        return Label.NotElibigleProvisionalExpExt;    
    } 
    //First Extension
    else  if(provApp.status =='Provisionally Approved' && provApp.First_Extension_Requested__c != true && provApp.Second_Extension_Requested__c != true){
       finalExpDate =  calculateDateHelper(requestDate,provApp);
       SYSTEM.DEBUG('EXP DATE IS 1st EXT: '+finalExpDate);
       return string.valueOf(finalExpDate);    
    }
    //Second Extension
    else if(provApp.status =='Provisionally Approved' && provApp.First_Extension_Requested__c == true && provApp.Second_Extension_Requested__c != true){
        finalExpDate = provApp.Hard_Expiry_Date__c; 
        SYSTEM.DEBUG('EXP DATE IS 2nd EXT: '+finalExpDate);  
        return string.valueOf(finalExpDate);   
    }

    //Both Extensions are over
    else if(provApp.status =='Provisionally Approved' && provApp.First_Extension_Requested__c == true && provApp.Second_Extension_Requested__c == true){
        return Label.Extend_Expiry_Date_Error_Message +' ' +string.valueOf(provApp.Expiry_Date1__c.format());
    }

    else if(provApp.status !='Provisionally Approved'){
        return Label.NotElibigleProvisionalExpExt;    
    } 
    
    //For all other scenarios
    else{
        return string.valueOf(finalExpDate);
    }
     
} 

//Find latest date
    public static date calculateDateHelper(Date requestDate, IndividualApplication provApp){
    SYSTEM.DEBUG('requestDate : '+requestDate);
        Date expDate;
        Date adjustedDate; 

        //REQ DATE >= SOFT EXP - Calculate 3 months from req date
        if(requestDate >= provApp.Expiry_Date1__c){ 
            expDate  = requestDate.addmonths(3); //VHF 2239
            adjustedDate   = ProvisionalApplication.adjustForHolidays(expDate);
        }

        //REQ DATE < SOFT EXP - Calculate 3 months from SOFT EXP Date
        else{ 
            expDate = provApp.Expiry_Date1__c.addmonths(3); //VHF 2239
            adjustedDate  = ProvisionalApplication.adjustForHolidays(expDate);
        }

        //If the new exp date is always less than Hard Expiry
        if(adjustedDate < provApp.Hard_Expiry_Date__c){
            SYSTEM.DEBUG(' adjustedDate IS : '+adjustedDate);   
           return adjustedDate;
        }

        else{
            SYSTEM.DEBUG('EXP DATE IS : '+provApp.Hard_Expiry_Date__c);    
            return provApp.Hard_Expiry_Date__c;
        }
    }

    //Save the extended exp date
    @AuraEnabled
    public static string saveNewExpiryDate(date extendedDate,Id recordID){
        
        FINAL STRING successMsg = Label.ExtendExpiryDateSuccessMessage+' '+extendedDate.format();
        FINAL STRING errorMsg = Label.ExtendExpiryDateUpdateErrorMessage;
        String message;
        
        SYSTEM.DEBUG('THE DATE THAT WILL BE SAVED IS : '+extendedDate+ ' ID of the record is : '+recordID);
        List<IndividualApplication> lstProvApplication = new List<IndividualApplication>();

        IndividualApplication ProvApplication = [SELECT Id,
                                            Expiry_Date1__c,
                                            First_Extension_Requested__c,
                                            Second_Extension_Requested__c 
                                    FROM IndividualApplication 
                                    WHERE Id = :recordID];

        ProvApplication.Expiry_Date1__c = extendedDate;                            
        if(ProvApplication.First_Extension_Requested__c == false){
            ProvApplication.First_Extension_Requested__c =  true;
        }
        else{
            ProvApplication.Second_Extension_Requested__c =  true;
        }
        lstProvApplication.add(ProvApplication);
        Database.SaveResult[] srList = Database.update(lstProvApplication, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully Updated: ' + sr.getId());
                message =  successMsg;
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
                message =  errorMsg;
            }
        }
        return message;
    }
}