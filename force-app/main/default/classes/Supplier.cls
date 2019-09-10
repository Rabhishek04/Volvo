public class Supplier {
   

    @auraEnabled    
    public static Date startHeaderDate{ get;set;}
    @auraEnabled
    public static Date endHeaderDate{get;set;}

    @auraEnabled
    public static list<Vehicle_Activity__c> SearchTruckActivities(Date cpdd,Date ccd,string supplierName){
        list<Vehicle_Activity__c> truckActList=new list<Vehicle_Activity__c>();
        truckActList=[SELECT Id,Plan_End_Date__c,Plan_Start_Date__c,Supplier__r.Name,Order__r.CPDD__c,Order__r.End_Customer__c,Order__r.CDD__c FROM Vehicle_Activity__c where Order__r.CPDD__c>=:cpdd and Order__r.CDD__c <=:ccd and Supplier__r.Name=:supplierName];
        if(truckActList.size()>0){
          return truckActList; 
        }
        return null;  
    }
    public static void findStartEndHeaderDates(Date ccpd, Date ccd,string supplierName ){
        //startHeaderDate = null;
        list<Vehicle_Activity__c> forStartHeaderTruckActivity = new list<Vehicle_Activity__c>(); 
        for(Vehicle_Activity__c temp:    [select Plan_Start_Date__c from Vehicle_Activity__c where 
                Plan_Start_Date__c!= null and Plan_End_Date__c!=null and Supplier__c=:supplierName and
                Order__r.CPDD__c!=null and Order__r.CDD__c!=null and Order__r.CPDD__c <=: ccd AND 
                Order__r.CDD__c >=: ccpd order by Plan_Start_Date__c asc]){
            forStartHeaderTruckActivity.add(temp);
            break;
        }
        list<Vehicle_Activity__c> forEndHeaderTruckActivity = new list<Vehicle_Activity__c>();
        for(Vehicle_Activity__c temp:    [select Plan_End_Date__c from Vehicle_Activity__c where 
                Plan_Start_Date__c!= null and Plan_End_Date__c!=null and Supplier__c=:supplierName and
                Order__r.CPDD__c!=null     and Order__r.CDD__c!=null and Order__r.CPDD__c <=: ccd AND 
                Order__r.CDD__c >=: ccpd order by Plan_End_Date__c desc]){
            forEndHeaderTruckActivity.add(temp);
        }
        startHeaderDate =ccpd;//forStartHeaderTruckActivity.size()!=0?forStartHeaderTruckActivity[0].Plan_Start_Date__c:ccpd;
        endHeaderDate = ccd;//forEndHeaderTruckActivity.size()!=0?forEndHeaderTruckActivity[0].Plan_End_Date__c:ccd;
    }

    @auraEnabled
    public static list<TruckActivities> orderList(Date ccpd, Date ccd,string supplierName){
        findStartEndHeaderDates(ccpd, ccd,supplierName);
        //if(this.truck. >= this.truck.|| this.truck. <= this.truck.){
        List <TruckActivities> returnList = new List <TruckActivities> ();
        List <Order__c> lstOfOrder = [SELECT Id , User_Role__c, CPDD__c,CDD__c,End_Customer__c,Name,Sales_Person__c,(SELECT UICode__c,Prepared__c, Plan_Start_Date__c,Result_Start_Date__c, Plan_End_Date__c,Result_End_Date__c,Supplier__r.Name FROM Vehicle_Activity__r 
                    where Plan_Start_Date__c!=null and Plan_End_Date__c!=null and Supplier__c=:supplierName order by Plan_Start_Date__c asc) FROM order__c WHERE CPDD__c!=null and cdd__c!=null and 
                    CPDD__c <=: ccd AND CDD__c >=: ccpd];
        for (Order__c ord: lstOfOrder) {
            //break;
            //returnList.add(new TruckActivities( ccpd,ord, startHeaderDate, endHeaderDate));
            if(ord.Vehicle_Activity__r.size()>0)
            returnList.add(new TruckActivities( ccpd,ord, startHeaderDate, endHeaderDate));
        } 
        
        if(returnList.size()>0)
        return returnList;
        else return null;
            
            
        
    }
     
    @auraEnabled
    public  static TruckActivityDateHeader dateListMethod(date ccpd,date ccd,string supplierName){
        findStartEndHeaderDates(ccpd, ccd,supplierName);
        // Date list for to show in Date Header from user Entered date to End of the task activity date
        list<Date> datelist = new list<Date>();
        for(integer i=0; ccpd<=endHeaderDate;i++){
            datelist.add(ccpd);
            ccpd = ccpd.addDays(1);
        }
        return new TruckActivityDateHeader(datelist, startHeaderDate,endHeaderDate);
    }
}