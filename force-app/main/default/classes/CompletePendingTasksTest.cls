@IsTest
public class CompletePendingTasksTest {
    @IsTest
    private static void testfinishPendingTasks() {
        Test.startTest();
        CompletePendingTasks completeTasks = new CompletePendingTasks();
        map<string, object> taskMap = new map<string, object>();
        
        contact newCon = new contact(lastname='testnewcon');
        insert newCon;
        task newTask = new task(status='Open', whoId=newCon.id, Subject='Annual Review Verification');
        insert newTask;

        for(task tTask : [select id, status, whoId from Task]){
            taskMap.put('WhoId', tTask.whoId);
        }
        
        Map<String, Object> inputMap = new Map<String, Object>{'data' => taskMap};
        Map<String, Object> outputMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();

        completeTasks.invokeMethod(
            'finishPendingTasks', inputMap, outputMap, options
        );
        system.assertEquals(0, [select id from Task where status = 'Open'].size());
        
        Map<String, Object> inputMap2 = new Map<String, Object>();
        completeTasks.invokeMethod(
            'finishPendingTasks', inputMap2, outputMap, options
        );
        Test.stopTest();
    }    
}