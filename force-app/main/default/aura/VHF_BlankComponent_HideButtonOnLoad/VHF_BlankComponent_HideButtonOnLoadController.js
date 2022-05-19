({
	handleAfterScriptsLoaded: function(component, event, helper) {
            let innerStyle = '';
            
            innerStyle+='<style type="text/css">';
            
            innerStyle+="li a[title='Upload New Version']";
            
            innerStyle+='{display:none !important;}';
            
            innerStyle+='</style>;';
        	$('head').append(innerStyle);
        
        
 }
})