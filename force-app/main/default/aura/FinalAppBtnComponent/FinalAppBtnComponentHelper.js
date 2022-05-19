({
    callInitForExpDateExtension : function(component,event,helper) {
       
        var action = component.get('c.displayButtonForExpiry');
        var recId = component.get("v.recordId");
        action.setParams({
            appId:recId
        });
        
        action.setCallback(this, function (response)
         {
           var res = response.getReturnValue();
           component.set('v.showExtendExpButton',res);
           if( res == true){
                let innerStyle = '';
                
                innerStyle+='<style type="text/css">';
                
                innerStyle+="a[title='Extend Expiry Date']";
                innerStyle+='{display:block !important;color: rgb(0, 82, 194) !important;padding: 2px 20px;padding-top: 2.5px;padding-bottom: 2.5px;border-radius: 4px;}';
                
                innerStyle+="a[title='Extend Expiry Date']:hover";
                
                innerStyle+='{color: rgb(0, 82, 194) !important;padding: 2px 20px;}';
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
         }); 
        
        $A.enqueueAction(action);
     
    }
    
})