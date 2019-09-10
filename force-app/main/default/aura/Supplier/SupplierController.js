({
    doinit:function(component, event, helper) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
		if( !$A.util.isEmpty(component.get('v.value')) ) {
			helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
        }
        var curr = new Date(); // get current date
       // var first= new Date(curr.getYear(),curr.getMonth(),1);
       // var last=first.setDate(first.getDate()-1);
        var first = (curr.getDate() - curr.getMonth(),1); // First day is the day of the month - the day of the week
        var last = first + 29; // last day is the first day + 30
        var firstday = new Date(curr.setDate(first)).toISOString().slice(0,10);
        var lastday = new Date(curr.setDate(last)).toISOString().slice(0,10);
        // debugger;
        var curYear = curr.getFullYear();
        component.set("v.ccpdDate",firstday);// (new Date(2019,06,28)).toISOString().slice(0,10));
        component.set("v.ccdDate",lastday);//(new Date(2019,07,13)).toISOString().slice(0,10));
        
        
        
    },
    
    
    
    Search : function(component, event, helper) {
        
        var date1 = component.get('v.ccpdDate');
        var date2 = component.get('v.ccdDate');
        var supply=component.get("v.selectedLookUpRecord");
        //alert(supply.Name);
        if(supply.Name!=null){
            document.getElementsByTagName("THEAD")[0].setAttribute("style", "display: revert");
        var action = component.get("c.orderList");
        action.setParams({
            'ccpd': date1,
            'ccd': date2,
            'supplierName':supply.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('aasas--->',JSON.stringify(storeResponse));
                //debugger;
                if(storeResponse!=null){
                    var showtable=component.find('showtable');
                    var NoRecord=component.find('NoRecord');
                    $A.util.addClass(NoRecord, 'slds-hide');
                    $A.util.removeClass(NoRecord, 'slds-show');
                    $A.util.addClass(showtable, 'slds-show');
                    $A.util.removeClass(showtable, 'slds-hide');
                }
                else{
                   var showtable=component.find('showtable');
                   var NoRecord=component.find('NoRecord');
                    $A.util.addClass(showtable, 'slds-hide');
                    $A.util.removeClass(showtable, 'slds-show');
                    $A.util.addClass(NoRecord, 'slds-show');
                    $A.util.removeClass(NoRecord, 'slds-hide');
                }
                component.set("v.searchResult", storeResponse); 
                // component.set("v.result",curYear);
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        var action1 = component.get("c.dateListMethod");
        action1.setParams({
            'ccpd': date1,
            'ccd': date2,
            'supplierName':supply.Id
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                 console.log('@@@@@--->',JSON.stringify(storeResponse));
                 component.set("v.DateList", storeResponse.datelist);
                 component.set("v.DateHeaderList", storeResponse.DateHeaderWrapperList);
                 component.set("v.startHeaderDate", storeResponse.startHeaderDate);

                 component.set("v.endHeaderDate", storeResponse.endHeaderDate);

               // debugger;
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action1);
    }
        else{
            document.getElementsByTagName("THEAD")[0].setAttribute("style", "display: none");
            var showtable=component.find('showtable');
                   var NoRecord=component.find('NoRecord');
                    $A.util.addClass(showtable, 'slds-hide');
                    $A.util.removeClass(showtable, 'slds-show');
                    $A.util.addClass(NoRecord, 'slds-show');
                    $A.util.removeClass(NoRecord, 'slds-hide');
        }
    },
    
    
    
    
})