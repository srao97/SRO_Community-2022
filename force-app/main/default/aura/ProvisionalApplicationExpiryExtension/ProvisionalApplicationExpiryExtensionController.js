({
    init : function(component, event, helper) {
        helper.callInit(component, event, helper);
    },
    handleCancel: function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSave :  function(component,event,helper){
        console.log('**SAVE**');
        helper.handleSave(component,event,helper);
    }
})