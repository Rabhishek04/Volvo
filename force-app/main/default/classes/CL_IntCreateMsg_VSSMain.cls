/********************************************************************************
 * VSSMainメッセージを作成するクラス
 ********************************************************************************/
public class CL_IntCreateMsg_VSSMain extends CL_IntCreateMsg {

/********************************************************************************
 * Constructor
 ********************************************************************************/
 
    /**
     * 初期化処理
     *
     * @param argOldRecMap 更新前レコードMAP
     * @param argNewRecMap 更新後レコードMAP
     */
    public CL_IntCreateMsg_VSSMain(Map<Id,sObject> argOldRecMap, Map<Id,sObject> argNewRecMap){
        super(argOldRecMap, argNewRecMap);
        endPoint = CL_IntConst.VSS_MAIN_ENDPOINT;
        msgTypeId = CL_IntConst.VSS_MAIN_MSG_TYPE_ID;
        this.createMsg();
    }
    
/********************************************************************************
 * Private Method
 ********************************************************************************/
     
    /**
     * @override
     */
    private Boolean chkSndFlg(sObject newRec){
    
        // 複数件同時更新の場合は、全送信処理を行わない
        if((Boolean)newRec.get('EmergencyFlg__c') && newRecMap.size() == 1){
            return true;
        }
        if(oldRecMap.containsKey(newRec.Id)){
            sObject oldRec = oldRecMap.get(newRec.Id);
            if((String)newRec.get('Opportunity__c') != (String)oldRec.get('Opportunity__c')){
                return true;
            }
        }
        return false;
    }
    
    /**
     * @override
     */
    private void createBodyMsg(){
        for(Id id : idSet){
            sObject rec = newRecMap.get(id);
            JSONGenerator json = JSON.createGenerator(false);
            
            json.writeStartObject();
            json.writeStringField('VSSQuoteId', chgNullToBlank((String)rec.get('VSS_QUOTE_ID__c')));
            json.writeStringField('VSSDealId', chgNullToBlank((String)rec.get('VSS_DEAL_ID__c')));
            json.writeStringField('OpportunityId', chgNullToBlank((String)rec.get('OpportunityID__c')));
            json.writeStringField('OpportunityName', chgNullToBlank((String)rec.get('OpportunityName__c')));
            json.writeStringField('PartyId', chgNullToBlank((String)rec.get('AccountPartyID__c')));
            json.writeStringField('DealerPartyId', chgNullToBlank((String)rec.get('AccountOwnerDealerPartyID__c')));
            json.writeEndObject();
            
            reqMap.put(rec.Id ,json.getAsString());
        }
    }
}