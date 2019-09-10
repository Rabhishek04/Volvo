public /*with sharing*/ class  Truckactivity   {
    public class TruckActivityWrapper{
        @auraEnabled
        public TruckActivityDateHeader TruckActivityDateHeader{get;set;}
        @auraEnabled
        public list<TruckActivities> TruckActivities{get;set;}
        @auraEnabled
        public boolean regionFlag{get;set;}
        @auraEnabled
        public boolean salesTeamFlag{get;set;}

        @auraEnabled
        public boolean salesRepFlag{get;set;}
        @auraEnabled
        public Id currentUserRoleId{get;set;}
        @auraEnabled
        public Id currentUserId{get;set;}
    }
    @auraEnabled
    public static TruckActivityWrapper truckActivityData(Date ccpd, Date ccd, boolean useCDDFlag, String region, String salesTeam, String salesRep){
        set<Id> owners = new set<Id>();
        if(!string.isEmpty(salesRep)){
            owners.add(salesRep);
        }else if(!string.isEmpty(salesTeam)){
            owners = RoleUtils.GetSubordinateUsers(salesTeam, false);
        }else if(!string.isEmpty(region)){
            owners = RoleUtils.GetSubordinateUsers(region, true);
        }else{
        }
        string vehicleActivityCondition='';
        string orderWhereCondition='';
        if(!string.isEmpty(salesRep)||!string.isEmpty(salesTeam)||!string.isEmpty(region)){
            if(owners.size()==0){
                owners=new set<Id>();
            }
            vehicleActivityCondition +=' and Order__r.ownerId in: owners';
            orderWhereCondition += ' and  ownerId in: owners ';
        }
        // For Start date condition
        list<Vehicle_Activity__c> forStartHeaderTruckActivity = new list<Vehicle_Activity__c>(); 
        String query ='select Plan_Start_Date__c from Vehicle_Activity__c where Plan_Start_Date__c!= null and Plan_End_Date__c!=null and ';
        
        //Order__r.CPDD__c!=null and Order__r.CDD__c!=null and Order__r.CPDD__c <=: ccd AND Order__r.CDD__c >=: ccpd ';
        if(useCDDFlag)
            query +=' Order__r.CDD__c!=null and Order__r.CDD__c <=: ccd AND Order__r.CDD__c >=: ccpd ';
        else{
            query +=' Order__r.CPDD__c!=null and Order__r.CPDD__c <=: ccd AND Order__r.CPDD__c >=: ccpd ';
        }
        query +=vehicleActivityCondition;
        query +=' order by Plan_Start_Date__c asc';
        for(Vehicle_Activity__c temp:    database.query(query)){
            forStartHeaderTruckActivity.add(temp);
            break;
        }
        // For End date condition
        list<Vehicle_Activity__c> forEndHeaderTruckActivity = new list<Vehicle_Activity__c>();
        query =' select Plan_End_Date__c from Vehicle_Activity__c where Plan_Start_Date__c!= null and Plan_End_Date__c!=null and ';
        //Order__r.CPDD__c!=null and Order__r.CDD__c!=null and Order__r.CPDD__c <=: ccd AND Order__r.CDD__c >=: ccpd ';
        if(useCDDFlag)
            query +=' Order__r.CDD__c!=null and Order__r.CDD__c <=: ccd AND Order__r.CDD__c >=: ccpd ';
        else{
            query +=' Order__r.CPDD__c!=null and Order__r.CPDD__c <=: ccd AND Order__r.CPDD__c >=: ccpd ';
        }
        query +=vehicleActivityCondition;
        query +=' order by Plan_End_Date__c desc';
        for(Vehicle_Activity__c temp:    database.query(query)){
            forEndHeaderTruckActivity.add(temp);
        }
        date startHeaderDate =forStartHeaderTruckActivity.size()!=0?forStartHeaderTruckActivity[0].Plan_Start_Date__c:ccpd;
        date endHeaderDate = forEndHeaderTruckActivity.size()!=0?forEndHeaderTruckActivity[0].Plan_End_Date__c:ccd;
        
        // Order functionality
        List <TruckActivities> returnList = new List <TruckActivities> ();
        query ='SELECT Id ,CPDD__c,CDD__c,End_Customer__c, Name, (SELECT Prepared__c,Plan_Start_Date__c,Result_Start_Date__c,UICode__c, Plan_End_Date__c,Result_End_Date__c FROM Vehicle_Activity__r where Plan_Start_Date__c!=null and Plan_End_Date__c!=null order by Plan_Start_Date__c asc) FROM order__c WHERE';
        //query +='CPDD__c!=null and cdd__c!=null and CPDD__c <=: ccd AND CPDD__c >=: ccpd ';
		if(useCDDFlag)
            query +=' CDD__c!=null and CDD__c <=: ccd AND CDD__c >=: ccpd ';
        else{
            query +=' CPDD__c!=null and CPDD__c <=: ccd AND CPDD__c >=: ccpd ';
        }
        query +=orderWhereCondition;
        if(useCDDFlag){
            query +=' order by CDD__c desc';
            //query +=' CDD__c!=null and CDD__c <=: ccd AND CDD__c >=: ccpd ';
        }else{
            query +=' order by CPDD__c desc';
            //query +=' CPDD__c!=null and CPDD__c <=: ccd AND CPDD__c >=: ccpd ';
        }
        //query +=' order by CPDD__c desc';
        for (Order__c ord: database.query(query)) {
            returnList.add(new TruckActivities( ccpd,ord, startHeaderDate, endHeaderDate));
        }
        
        // Date functionality
        list<Date> datelist = new list<Date>();
        for(integer i=0; ccpd<=endHeaderDate;i++){
            datelist.add(ccpd);
            ccpd = ccpd.addDays(1);
        }
        TruckActivityWrapper TruckActivityWrapperObj=new TruckActivityWrapper();
        TruckActivityWrapperObj.TruckActivities=returnList;
        TruckActivityWrapperObj.TruckActivityDateHeader=new TruckActivityDateHeader(datelist, startHeaderDate,endHeaderDate);
        filterUtility(TruckActivityWrapperObj);



        return TruckActivityWrapperObj;
    }
    @auraEnabled
    public static Map<Id, UserRole> GetRegions(){
        if(UserInfo.getUserRoleId()==null)
            return new Map<Id, UserRole>();
        return RoleUtils.GetRegions(userinfo.getUserId());
    }
    @auraEnabled
    public static Map<Id, User> GetSalesManagers(Id roleId){
        
        return RoleUtils.GetSalesManagers(roleId);
    }
    @auraEnabled
   public static Map<Id,User> GetSalesDepartment(Id userId)
   {
        
        return RoleUtils.GetSalesDepartment(userId);
    }
    public  static void filterUtility(TruckActivityWrapper TruckActivityWrapperObj){
        /*TruckActivityWrapperObj.currentUserRoleId = UserInfo.getUserRoleId();
                TruckActivityWrapperObj.regionFlag=false;
                TruckActivityWrapperObj.salesTeamFlag=true;
                TruckActivityWrapperObj.salesRepFlag=true;

                return;*/
        if(UserInfo.getUserRoleId()==null){
            TruckActivityWrapperObj.regionFlag=false;
            TruckActivityWrapperObj.salesTeamFlag=false;
            TruckActivityWrapperObj.salesRepFlag=false;
        }else {
            
            userrole ur=[Select DeveloperName,ParentRoleId From UserRole Where Id =: UserInfo.getUserRoleId() limit 1];//[0]
            if(ur.ParentRoleId==null){
                TruckActivityWrapperObj.regionFlag=true;
                TruckActivityWrapperObj.salesTeamFlag=true;
                TruckActivityWrapperObj.salesRepFlag=true;
            }else if(ur.DeveloperName.contains('Region')){
                TruckActivityWrapperObj.currentUserRoleId = UserInfo.getUserRoleId();
                TruckActivityWrapperObj.regionFlag=false;
                TruckActivityWrapperObj.salesTeamFlag=true;
                TruckActivityWrapperObj.salesRepFlag=true;
            }else if(ur.DeveloperName.contains('SalesManager')){
                TruckActivityWrapperObj.currentUserRoleId = UserInfo.getUserRoleId();
                TruckActivityWrapperObj.currentUserId=UserInfo.getUserId();
                TruckActivityWrapperObj.regionFlag=false;
                TruckActivityWrapperObj.salesTeamFlag=false;
                TruckActivityWrapperObj.salesRepFlag=true;
            }else if(ur.DeveloperName.contains('SalesDepartment')){
                TruckActivityWrapperObj.regionFlag=false;
                TruckActivityWrapperObj.salesTeamFlag=false;
                TruckActivityWrapperObj.salesRepFlag=false;
            }
        }
    }
}