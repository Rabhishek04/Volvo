public class TruckActivityDateHeader {
    
    @auraEnabled
    public list<DateHeaderWrapper> DateHeaderWrapperList{get;set;}
    @auraEnabled
    public List<Date> datelist{get;set;}
    @auraEnabled
    public date startHeaderDate{get;set;}
    @AuraEnabled
    public date endHeaderDate{get;set;}

    public TruckActivityDateHeader(list<Date> datelist, date startHeaderDate, date endHeaderDate){
        this.datelist = datelist;
        this.startHeaderDate = startHeaderDate;
        this.endHeaderDate = endHeaderDate;

        DateHeaderWrapperList = new list<DateHeaderWrapper>();
        date tempStartHeaderDate = startHeaderDate;
        for(integer i=0; tempStartHeaderDate<=endHeaderDate;i++){
            DateHeaderWrapper temp=new DateHeaderWrapper(tempStartHeaderDate);
            DateHeaderWrapperList.add(new DateHeaderWrapper(tempStartHeaderDate));
            tempStartHeaderDate = tempStartHeaderDate.addDays(temp.numofdays+1);
        }
        try{
            DateHeaderWrapper temp =DateHeaderWrapperList[DateHeaderWrapperList.size()-1];
            Date startDate = date.newInstance(temp.dateHeader.year(), temp.dateHeader.month(), 01);
            date endDate = endHeaderDate;
            temp.numofdays =startDate.daysBetween(endDate);
            temp.numofdays = temp.numofdays+1;
            DateHeaderWrapperList[DateHeaderWrapperList.size()-1] = temp;
        }catch(Exception e){

        }

    }
    
    public class DateHeaderWrapper{
        @auraEnabled
        public Date dateHeader{get;set;}
        @auraEnabled        
        public Integer numofdays{get;set;}
        public DateHeaderWrapper(Date dateHeader){
            this.dateHeader = dateHeader;
            this.numofdays=dateHeader.daysBetween(date.newInstance(dateHeader.year(), dateHeader.month(), Date.daysInMonth(dateHeader.year(), dateHeader.month())))+1;
        }
    }
}