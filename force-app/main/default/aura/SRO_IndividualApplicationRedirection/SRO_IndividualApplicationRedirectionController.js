({    invoke : function(component, event, helper) {
    var congaUrl = component.get("v.congaUrl");
    if(congaUrl != '' && congaUrl != null){
       console.log('congaUrl - ' +congaUrl);
       var redirect = $A.get("e.force:navigateToURL");
       redirect.setParams({
          "url": congaUrl
       });
       redirect.fire();
    
    }
    else{
        var record = component.get("v.recordId");
       //console.log('---'+record);
       var redirect = $A.get("e.force:navigateToSObject");
       redirect.setParams({
          "recordId": record
       });
       redirect.fire();
    }
   
}})