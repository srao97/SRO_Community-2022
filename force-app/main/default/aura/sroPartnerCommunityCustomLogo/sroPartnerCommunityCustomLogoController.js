({

    handleAfterScriptsLoaded: function(component, event, helper) {
        jQuery(document).ready(function() {
            var action = component.get("c.getDocumentLogoUrl");
            action.setCallback(this, function(action) {
                var state = action.getState();
                if (state === "SUCCESS") {
                    var customLogoURL = action.getReturnValue();
                    if (customLogoURL != null) {
                        component.set("v.documentLink", customLogoURL);
                        var accountLogo = component.get('v.documentLink');
                        jQuery('head').append('<style type="text/css"> .slds-avatar img {display:none;}.slds-avatar {display:block; height:32px; width:32px; background-size: contain !important; background:url(' + accountLogo + ') no-repeat;}</style>');
                    }
                } else {
                    //do nothing
                }
            });
            $A.enqueueAction(action);
        });
    }
})