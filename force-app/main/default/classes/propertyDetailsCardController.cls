public with sharing class propertyDetailsCardController {
    
    @AuraEnabled
    public static ResponseWrapper getPropertyDetails( string field1, string field2, string field3, string objectApiName, string filter){
        try {
            
            User currentUser = [SELECT Id, AccountId, ContactId, Name, Account.Parent_Account__c from User where Id =: UserInfo.getUserId()];

            string soqlString = 'Select ';
            if(field1 != null || field1 == ' ')
            {
                soqlString = soqlString + field1;
            }
            if(field2 != null || field2 == ' ')
            {
                soqlString = soqlString + ', ' + field2;
            }
            if(field3 != null || field3 == ' ')
            {
                soqlString = soqlString + ', ' + field3;
            }
            
            soqlString = soqlString +  ' from ' + objectApiName;

            if(filter != null && currentUser.Account.Parent_Account__c != null)
            {
                soqlString = soqlString  + ' where ' + filter + ' = \'' + currentUser.Account.Parent_Account__c + '\' ';
            }
            
            soqlString = soqlString + ' LIMIT 1';
            
            System.debug('whats the soql string' + soqlString);

            Order propertyRecord = Database.query(soqlString);

            System.debug('property record=' + propertyRecord);

            ResponseWrapper newWrapper = new ResponseWrapper();

            if(propertyRecord != null)
            {
                if(field1 != null || field1 == ' ')
                {
                    newWrapper.column1Value = getDataType(objectApiName, String.valueOf(propertyRecord.get(field1)), field1);
                }
                if(field2 != null || field2 == ' ')
                {
                    newWrapper.column2Value = getDataType(objectApiName, String.valueOf(propertyRecord.get(field2)), field2);
                }
                if(field3 != null || field3 == ' ')
                {
                    newWrapper.column3Value = getDataType(objectApiName, String.valueOf(propertyRecord.get(field3)), field3);
                }
            }

            System.debug('wrapper record=' + newWrapper);

            //String returnJson = JSON.serialize(propertyRecord);

            return newWrapper;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ResponseWrapper {
        @AuraEnabled
        public string column1Value {get;set;}
        @AuraEnabled 
        public string column2Value {get;set;}
        @AuraEnabled 
        public string column3Value {get;set;}

    }

    public static string getDataType(String objectName, String value, String fieldApiName)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for(string fieldName: fieldMap.keySet())
        {
            if(fieldName == fieldApiName)
            {
                Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                System.debug('field type='+ fielddataType);
                if(fielddataType == Schema.DisplayType.PERCENT)
                {
                    value = value + '%';
                }
                if(fielddataType == Schema.DisplayType.CURRENCY)
                {
                    if(value == null || value == ' ')
                    {
                        value = '$0';
                    }
                    else 
                    {
                        value = '$'+ value;
                    }
                }

            } 
        }

        return value;
    }
}