({
	init : function(component, event, helper) {
        var oppId = component.get("v.recordId");
        var action = component.get("c.getOpportunity");
        action.setParams({
        	"oppId": oppId
        });
        action.setCallback(this, function(data) {
        	component.set("v.oppCtrl", data.getReturnValue());
        });
        $A.enqueueAction(action);
	},
	send : function(component, event, helper) {
        var oppCtrl = component.get("v.oppCtrl");
        window.open(oppCtrl.urlToVSS);
        $A.get("e.force:closeQuickAction").fire();
	}
})