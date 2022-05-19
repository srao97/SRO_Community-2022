({
	callInit : function(component, event, helper) {
		var action = component.get('c.calculateExpDate');
        var recId = component.get("v.recordId");
        action.setParams({
            provAppId:recId
        });
        action.setCallback(this, function (response)
        {
         var res = response.getReturnValue();
            console.log('res : '+res);
            component.set('v.extendedDate',res);
            if(res.includes($A.get("$Label.c.Extend_Expiry_Date_Error_Message"))){
               component.set('v.extendTRUE',false); 
            }
            else{
                component.set('v.extendTRUE',true); 
            }
        });
        $A.enqueueAction(action);
	},
    handleSave : function(component, event, helper){
        var action = component.get('c.saveNewExpiryDate');
        var newDate = component.get("v.extendedDate");
        var recId = component.get("v.recordId");
        console.log('**recID**'+recId);
        action.setParams({
            extendedDate:newDate,
            recordID:recId
        });
        action.setCallback(this, function (response)
       {
       	console.log('response'+res);
       var toastEvent = $A.get("e.force:showToast");
       var res = response.getReturnValue();
       var successMsg = $A.get("$Label.c.ExtendExpiryDateSuccessMessage");
       console.log('response'+res);
       console.log('status'+response.status);
       if(res.includes(successMsg))
       {
           toastEvent.setParams({
               "type" : "success",
               "message": res
           });
           $A.get("e.force:closeQuickAction").fire();
           toastEvent.fire();
           $A.get("e.force:refreshView").fire();
       }
       else
       {
           toastEvent.setParams({
               "type" : "error",
               "message": res
           });
           $A.get("e.force:closeQuickAction").fire();
           toastEvent.fire();
       }
       });
        $A.enqueueAction(action);
    }
})