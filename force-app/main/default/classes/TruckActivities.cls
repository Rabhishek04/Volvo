public  class TruckActivities {
    @auraEnabled
        public Order__c orderObj{get;set;}
        @auraEnabled
        public list<list<activitiesWrapper2>> activitiesList {get;set;}
        public list<list<Vehicle_Activity__c>> truckList{get;set;}
        public TruckActivities(Date ccpd,Order__c orderObj, date startHeaderDate, date endHeaderDate ){

                this.orderObj=orderObj;
                activitiesList = new list<list<activitiesWrapper2>>();
          	 
                truckList = new list<list<Vehicle_Activity__c>>();
                TruckDataConsolidation(orderObj.Vehicle_Activity__r);

              for(list<Vehicle_Activity__c> truckActivityList:truckList){
                ccpd=startHeaderDate;
                
                map<Date,Date> datelist = new map<Date,Date>();
                for(integer i=1; ccpd<=endHeaderDate;i++){
                    datelist.put(ccpd,ccpd);
                    ccpd = ccpd.addDays(1);
                }
                
                Map<Date, Vehicle_Activity__c> tempDate_TA = new map<date,Vehicle_Activity__c>();
            	for(Vehicle_Activity__c truckActivity:truckActivityList){
                	tempDate_TA.put(truckActivity.Plan_Start_Date__c,truckActivity);
                    for(date d=truckActivity.Plan_Start_Date__c.adddays(1);d<=truckActivity.Plan_End_Date__c;d=d.addDays(1)){
                       datelist.remove(d); 
                    }
            	}
                list<activitiesWrapper2> activitiesWrapper2List = new list<activitiesWrapper2>();
                for(Date datetemp:datelist.values()){
                    Vehicle_Activity__c Truck_Activity = new Vehicle_Activity__c();
                    if(tempDate_TA.get(datetemp)!=null){
                        Truck_Activity =tempDate_TA.get(datetemp);
                    }
                    activitiesWrapper2List.add(new activitiesWrapper2(Truck_Activity,datetemp));
                }
                activitiesList.add(activitiesWrapper2List);
        	}  
        }
        public  void TruckDataConsolidation(list<Vehicle_Activity__c> truckActivityList){
            list<Vehicle_Activity__c> skipTruckActivityList = new list<Vehicle_Activity__c>();
            list<Vehicle_Activity__c> needTruckActivityList = new list<Vehicle_Activity__c>();
            Integer idx=0;
            Vehicle_Activity__c firstTruckActivity=null;
            Vehicle_Activity__c secondTruckActivity = null;
            for(Vehicle_Activity__c truckActivity:truckActivityList){
                if(idx==0){
                    firstTruckActivity = truckActivity;
                    needTruckActivityList.add(firstTruckActivity);
                    idx++;
                    continue;
                }
                secondTruckActivity = truckActivity;
                if(firstTruckActivity.Plan_End_Date__c<secondTruckActivity.Plan_Start_Date__c){
                    firstTruckActivity = truckActivity;    
                    needTruckActivityList.add(secondTruckActivity);
                }else{
                    skipTruckActivityList.add(secondTruckActivity);
                }
                
            }
            truckList.add(needTruckActivityList);
            if(skipTruckActivityList.size()!=0){
                TruckDataConsolidation(skipTruckActivityList);
            }    
        }
    public class activitiesWrapper2{
        @auraEnabled
        public Vehicle_Activity__c truck{get;set;}
        @auraEnabled
        public date d{get;set;}
        @auraEnabled
        public Integer numofdays {get;set;}
        @auraEnabled
        public String color{get;set;}
        public activitiesWrapper2(Vehicle_Activity__c truck,date d){
            this.d =d;
            this.truck = truck;  
            
            if(this.truck.Plan_Start_Date__c < this.truck.Result_Start_Date__c|| this.truck.Plan_End_Date__c < this.truck.Result_End_Date__c){
                this.color='cornersRed';
            }else if(truck.Result_Start_Date__c!=null && truck.Result_End_Date__c!=null && truck.Plan_Start_Date__c!=null && truck.Plan_End_Date__c!=null){
                this.color='cornersDarkGreen';                    
            }else if(this.truck.Prepared__c){
                this.color='cornersBlue';
            }else if(truck.Plan_Start_Date__c!=null && truck.Plan_End_Date__c!=null){
                this.color='cornersLightGreen';
            }  
            
            this.numofdays=truck.Plan_Start_Date__c!=null&&truck.Plan_End_Date__c!=null?(truck.Plan_Start_Date__c.daysBetween(truck.Plan_End_Date__c))+1:0;
        }
    }
    
   
}