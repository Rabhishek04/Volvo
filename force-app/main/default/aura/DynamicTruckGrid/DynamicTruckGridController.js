({
    doinit:function(component, event, helper) {
        var curr = new Date(); // get current date
        var first = (curr.getDate() - curr.getMonth(),1); // First day is the day of the month - the day of the week
        var last = first + 29; // last day is the first day + 30
        var firstday = new Date(curr.setDate(first)).toISOString().slice(0,10);
        var lastday = new Date(curr.setDate(last)).toISOString().slice(0,10);
        // debugger;
        var curYear = curr.getFullYear();
        component.set("v.ccpdDateFrom",firstday);// (new Date(2019,06,28)).toISOString().slice(0,10));
        component.set("v.ccpdDateTo",lastday);//(new Date(2019,07,13)).toISOString().slice(0,10));
        var date1 = component.get('v.ccpdDateFrom');
        var date2 = component.get('v.ccpdDateTo');
        var action = component.get("c.truckActivityData");
        action.setParams({
            'ccpd': date1,
            'ccd': date2,
            'useCDDFlag':component.find("useCDDFlag").get("v.value"),
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('aasas--->',JSON.stringify(storeResponse));
                //debugger;
                var orderList=[];
                var orderList1;
                
                for(var i=0;i<storeResponse.TruckActivities.length;i++){
                   // console.log(storeResponse.TruckActivities[i].orderObj);
                   orderList.push(storeResponse.TruckActivities[i].orderObj)
                   var orderList2 = orderList.reduce(function(obj){
                       if(obj!=undefined){
                       console.log('obj--',obj);
                       console.log('vehicleActivity--',obj.Vehicle_Activity__r);
                       }
                   })                   
                       
                  
                   
                }
                component.set("v.orderList",orderList);
                component.set("v.searchResult", storeResponse.TruckActivities); 
                component.set("v.result",curYear);
                component.set("v.DateList", storeResponse.TruckActivityDateHeader.datelist);
                component.set("v.DateHeaderList", storeResponse.TruckActivityDateHeader.DateHeaderWrapperList);
                component.set("v.startHeaderDate", storeResponse.TruckActivityDateHeader.startHeaderDate);

                 component.set("v.endHeaderDate", storeResponse.TruckActivityDateHeader.endHeaderDate);
                 /*<aura:attribute name="regionFlag" type="boolean" default="false"/>
                 <aura:attribute name="salesTeamFlag" type="boolean" default="false"/>
                 <aura:attribute name="salesRepFlag" type="boolean" default="false"/>*/
                 component.set("v.regionFlag", storeResponse.regionFlag);
                 component.set("v.salesTeamFlag", storeResponse.salesTeamFlag);
                 component.set("v.salesRepFlag", storeResponse.salesRepFlag);
                // debugger;
                 if(!storeResponse.regionFlag&&storeResponse.salesTeamFlag){
                    component.set("v.regionId",storeResponse.currentUserRoleId);
                    helper.onControllerFieldChange(component,event);
                 }
                 if(!storeResponse.salesTeamFlag){
                    component.set("v.salesTeamId",storeResponse.currentUserId);
                    helper.onRoleFieldChange(component,event);
                 }
                 
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
        /*var action1 = component.get("c.dateListMethod");
        action1.setParams({
            'ccpd': date1,
            'ccd': date2,
            'salesRep' : null
        });
        //
            //'salesRep' : component.get('v.salesRepId')
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
                 //helper.dateHeader(component, storeResponse.startHeaderDate, storeResponse.endHeaderDate)
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
    */
        var action2 = component.get("c.GetRegions");
        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // debugger;
                console.log('@@@@@--->',JSON.stringify(storeResponse));
                component.set("v.roleList", storeResponse==null?[]:Object.values(storeResponse));
                //component.set("v.DateHeaderList", storeResponse.DateHeaderWrapperList);
                //component.set("v.startHeaderDate", storeResponse.startHeaderDate);

                 //component.set("v.endHeaderDate", storeResponse.endHeaderDate);
                 //helper.dateHeader(component, storeResponse.startHeaderDate, storeResponse.endHeaderDate)
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
        $A.enqueueAction(action2);
    },
    
        
    //},
    
    
    
    Search : function(component, event, helper) {
        if(component.find("useCDDFlag").get("v.value")&&(
            !component.find("StartDateField_cdd").get("v.value")||
            !component.find("EndDateField_cdd").get("v.value")
        )){
            var sMsg = 'Please Enter CDD Dates';
        
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            mode: 'pester',
            message: sMsg,
            duration:'4000',
            type : 'error'
        });
        toastEvent.fire();
            return;
        }else if(
            !component.find("useCDDFlag").get("v.value")&&
            (!component.find("StartDateField_cpdd").get("v.value")||
            !component.find("EndDateField_cpdd").get("v.value"))

        ){
           var sMsg = 'Please Enter CPDD Dates';
        
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            mode: 'pester',
            message: sMsg,
            duration:'4000',
            type : 'error'
        });
        toastEvent.fire();
            return;
        }


        var date1 = component.get('v.ccpdDateFrom');
        var date2 = component.get('v.ccpdDateTo');
        if(component.find("useCDDFlag").get("v.value")){
          date1 = component.get('v.ccdDateFrom');
          date2 = component.get('v.ccdDateTo');  
        }


        var action = component.get("c.truckActivityData");
        var temp =component.get('v.salesRepId');
       // debugger;
        let region = component.get('v.regionId')=='--None--'?null:component.get('v.regionId');
        let salesTeamId=component.get('v.salesTeamId')=='--None--'?"":component.get('v.salesTeamId');
        let salesRep =component.get('v.salesRepId')=='--None--'?"":component.get('v.salesRepId');
        console.log(region,salesTeamId,salesRep );
        
        //debugger;
        action.setParams({
            'ccpd': date1,
            'ccd': date2,
            'useCDDFlag':component.find("useCDDFlag").get("v.value"),
            'region' : !component.get("v.regionFlag")?null:component.get('v.regionId'),//component.get('v.regionId'),
            'salesTeam' : !component.get("v.salesTeamFlag")?null:component.get('v.salesTeamId'),//component.get('v.salesTeamId')?component.get('v.salesTeamId'):null,
            'salesRep' : component.get('v.salesRepId')//component.get('v.salesRepId')?component.get('v.salesRepId'):null
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse.TruckActivities.length === 0) {
                    document.getElementsByTagName("THEAD")[0].setAttribute("style", "display: none");
                      var NoRecord=component.find('NoRecord');
       
                    $A.util.addClass(NoRecord, 'slds-show');
                    $A.util.removeClass(NoRecord, 'slds-hide');}
                    else {document.getElementsByTagName("THEAD")[0].setAttribute("style", "display: revert");}
                //console.log('aasas--->',JSON.stringify(storeResponse));
                //debugger;
               // component.set("v.searchResult", storeResponse); 
                // component.set("v.result",curYear);
                component.set("v.searchResult", storeResponse.TruckActivities); 
                //component.set("v.result",curYear);
                component.set("v.DateList", storeResponse.TruckActivityDateHeader.datelist);
                component.set("v.DateHeaderList", storeResponse.TruckActivityDateHeader.DateHeaderWrapperList);
                component.set("v.startHeaderDate", storeResponse.TruckActivityDateHeader.startHeaderDate);

                 component.set("v.endHeaderDate", storeResponse.TruckActivityDateHeader.endHeaderDate);
                
                 /*component.find("StartDateField_cpdd").set("v.value","");
                 component.find("EndDateField_cpdd").set("v.value","");
                 component.find("StartDateField_cdd").set("v.value","");
            component.find("EndDateField_cdd").set("v.value","");*/
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
        /*var action1 = component.get("c.dateListMethod");
        action1.setParams({
            'ccpd': date1,
            'ccd': date2,
            
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                 console.log('@@@@@--->',JSON.stringify(storeResponse));
                 component.set("v.DateList", storeResponse.TruckActivityDateHeader.datelist);
                 component.set("v.DateHeaderList", storeResponse.TruckActivityDateHeader.DateHeaderWrapperList);
                 component.set("v.startHeaderDate", storeResponse.TruckActivityDateHeader.startHeaderDate);

                 component.set("v.endHeaderDate", storeResponse.TruckActivityDateHeader.endHeaderDate);

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
        $A.enqueueAction(action1);*/
    },
    //this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    
    onControllerFieldChange: function(component,event,helper){
    
        helper.onControllerFieldChange(component,event);
    },
    
    onRoleFieldChange: function(component,event,helper){
        helper.onRoleFieldChange(component,event);
    },
    
    salesRep : function(component,event,helper){
        component.set("v.salesRepId",event.getSource().get("v.value"));
    },

    useCDD:function(component, event, helper){
        /*console.log('Hi');
        console.log(component.get("v.useCdd"));
        if(component.set("v.useCdd")){
            component.find("StartDateField_cpdd").set("v.value","");
            component.find("EndDateField_cpdd").set("v.value","");
        }else{
            component.find("StartDateField_cdd").set("v.value","");
            component.find("EndDateField_cdd").set("v.value","");
        }*/
        if(component.find("useCDDFlag").get("v.value")){
            component.find("StartDateField_cpdd").set("v.value","");
            component.find("EndDateField_cpdd").set("v.value","");
        }else{
            component.find("StartDateField_cdd").set("v.value","");
            component.find("EndDateField_cdd").set("v.value","");
        }
        console.log(component.find("useCDDFlag").get("v.value"));
    },
    exportToExcel: function(component,event,helper){
        var csv=helper.convertArrayOfObjectsToCSV(component,component.get("v.orderList"));
        console.log(component.get("v.orderList"));
        if (csv == null){return;} 
        
        var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click();
    },
    openMapComponent:function(component,event,helper){
        //var evt = $A.get("e.force:navigateToComponent");
        var location=[
            {
                location: {
                    Street: '1600 Pennsylvania Ave NW',
                    City: 'Washington',
                    State: 'DC'
                },

                title: 'The White House',
                description: 'Landmark, historic home & office of the United States president, with tours for visitors.'
            }
        ];
        /*evt.setParams({
            componentDef : "c:displayMap",
        componentAttributes: {
            mapMarkers : location
        }
        });
        evt.fire();*/
        component.set("v.mapMarkers",location);
        component.set("v.openMap",true)
    },
    closeMapModel :function(component,event){
        component.set("v.openMap",false);
    },
    displayTooltip: function(component,event){
        console.log('onmouseover')
        component.get("v.showDates",true);
        
    },
    hideTooltip:function(component,event){
        console.log('onmouseout')
    }
})