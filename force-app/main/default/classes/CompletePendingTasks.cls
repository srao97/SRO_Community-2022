global without sharing class CompletePendingTasks implements vlocity_ins.VlocityOpenInterface2 {
    
    global Object invokeMethod (
        String methodName, Map<String, Object> input, Map<String, object> output, Map<String, Object> options
    ) {
        try {
            Boolean status = false;
            if('finishPendingTasks'.equals(methodName)) {
                finishPendingTasks(input, output, options);
                status = true;
            }
            return status;
        } catch(TypeException te) {
            output.put('error', 'Bad Request');
            output.put('errorCode', 'INVOKE-400');
            return false;
        }
    }
    
    private void finishPendingTasks(Map<String, Object> input, Map<String, object> output, Map<String, Object> options) {
        
        Object dataObject = input.get('data');
        
        List<Object> data = new List<Object>();
        
        if(dataObject instanceof List<Object>) {
            data.addAll((List<Object>) dataObject);
        } else if(dataObject instanceof Map<String, Object>) {
            data.add((Map<String, Object>) dataObject);
        }
        
        if(data.isEmpty()) 
       {
            output.put('error', 'Input(s) blank or missing');
            output.put('errorCode', 'INVOKE-500');
            return;
        }

        
       // List<Account> accountList = new List<Account>();
       Map<String, Object> eachApplicant = (Map<String, Object>) dataObject;
        String medicares = String.valueOf(eachApplicant.get('WhoId'));
        String currentMedicare = '';
        String emailAddressList = '';
        Integer Medicarefound;
        Integer duplicateEmailFound;
        
        List<Task> taskList = [SELECT Id FROM Task WHERE WhoId = :medicares AND Status = 'Open' AND Subject = 'Annual Review Verification'];
        
        for(Task taskRec: taskList) {
            taskRec.Status = 'Completed';
        }
        update taskList;
        
      //  output.put('data', new Map<String, Object> {'existingApplications' => duplicateList}); 
    }
 




}