({
	
  onControllerFieldChange:function(component,event,helper){
      // var controllerVal = event.getSource().get("v.value");
      var controllerVal = component.get("v.regionId");//event.getSource().get("v.value");
        //debugger;
        //component.get('v.salesTeamId')
        component.set("v.regionId",controllerVal);
        var action = component.get("c.GetSalesManagers");
        //component.set("v.salesTeamId","");
        action.setParams({"roleId": controllerVal});
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
              debugger;
                var result = response.getReturnValue();
                component.set("v.regionDependent", Object.values(result));
                //component.set("v.salesTeamId","");
                
                //debugger;
                if(!component.get("v.regionId"))
                component.set("v.regionDependent", []);
            }//else{
            if(!component.get("v.regionId")){
            	component.set("v.regionDependent", []);
                component.set("v.roleDependent", []);    
            }    
            component.find("select2").set("v.value","");
            component.find("select3").set("v.value","");
            
            //}
        });
        $A.enqueueAction(action);
    },
    onRoleFieldChange:function(component,event,helper){
      //var controllerVal = event.getSource().get("v.value");
      var controllerVal =component.get("v.salesTeamId");
        console.log(controllerVal);
        component.set("v.salesTeamId",controllerVal);
        var action = component.get("c.GetSalesDepartment");
        action.setParams({"userId": controllerVal});
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.roleDependent", Object.values(result));
            }
            if(!component.get("v.salesTeamId")){
            component.set("v.roleDependent", []); 
                  
            }    
            
            component.find("select3").set("v.value","");
        });
        $A.enqueueAction(action);
    },
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        
        columnDivider = ',';
        lineDivider =  '\n';
        
        keys = ['CPDD__c','CDD__c','End_Customer__c','Name'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
    
})