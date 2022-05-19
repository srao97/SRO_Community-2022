({
    doInit : function (component, event, helper) 
    {     
        var rid = component.get("v.recordId");
        var action = component.get("c.getBtnVisibile");
        action.setParams({appId : rid});  
        action.setCallback(this, function(response) 
         {
            var state = response.getState();
            if (state === "SUCCESS")  
            {
             component.set("v.showBtn", response.getReturnValue());
             console.log(response.getReturnValue());
            }
            else if (state === "ERROR") 
              {
                var errors = response.getError();
                if (errors) 
               	{
                   if (errors[0] && errors[0].message) 
                    {
                       console.log("Error message: " + errors[0].message);
                    }
                   } 
                 else 
                   {
                     console.log("Unknown Error");
                   }      
			}                     
         });                  
        $A.enqueueAction(action);
    },
    
    handleAfterScriptsLoaded: function(component, event, helper) {
        helper.callInitForExpDateExtension(component,event,helper);
                
        if( component.get('v.showExtendExpButton') == true){
            let innerStyle = '';
            
            innerStyle+='<style type="text/css">';
            
            innerStyle+="a[title='Extend Expiry Date']";
            innerStyle+='{display:block !important;color: rgb(0, 82, 194) !important;padding: 2px 20px;padding-top: 2.5px;padding-bottom: 2.5px;border-radius: 4px;}';
            
            innerStyle+="a[title='Extend Expiry Date']:hover";
            
            innerStyle+='color: rgb(0, 82, 194)!important;padding: 2px 20px;}';
            innerStyle+='</style>;';
            
            $('head').append(innerStyle);
        }
        else{
            let innerStyle = '';
            
            innerStyle+='<style type="text/css">';
            
            innerStyle+="a[title='Extend Expiry Date']";
            innerStyle+='{display:none !important;}';
            innerStyle+='</style>;';
            
            $('head').append(innerStyle);
        }
      
    },
    navigateToForm : function (component, event, helper) 
    {
        var rid = component.get("v.recordId"); 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/submit-application?c__ContextId="+rid
        });
        urlEvent.fire();
    }
    
})