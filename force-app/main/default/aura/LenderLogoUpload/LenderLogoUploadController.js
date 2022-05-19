({
    onSaveFile:function(component,event){
        var files = component.find("file-input").get("v.files");
        if (files && files.length > 0) 
        {
            var file = files[0];
            var reader = new FileReader();
            var accId = component.get("v.recordId");
            
            reader.onload = $A.getCallback(function(){
                var dataURL = reader.result;
                var base64Data = dataURL.match(/,(.*)$/)[1];                
                var action = component.get("c.uploadFile");
                console.log('type: ' + file.type);
                action.setParams({  
                    fileName: file.name,
                    base64Data: base64Data,
                    contentType: file.type,
                    accountId:accId
                });
                action.setCallback(this, function(a) {
                    var state = a.getState();
                    if (state === "SUCCESS") {
                        // var docid = a.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type":"success",
                            "message": "File uploaded successfully!"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else{
                        toastEvent.setParams({
                            "title": "Error!",
                            "type":"Warning",
                            "message": "Error in uploading file..."
                        });
                    }
                });
                $A.enqueueAction(action);    
            });
            
            reader.readAsDataURL(file);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type":"Warning",
                "message": "Please select a file..."
            });
            toastEvent.fire();
        }
        
    },
    
    onFileUploaded:function(component,event){
        var files = component.find("file-input").get("v.files");
        if (files && files.length > 0) 
        {
            var file = files[0];
            var fname = file.name;
            console.log('name='+fname);
            component.set("v.filename",fname);
        }
    },
    
    handleCancel: function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    }
})