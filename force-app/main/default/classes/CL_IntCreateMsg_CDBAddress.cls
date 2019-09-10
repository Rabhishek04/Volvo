/********************************************************************************
 * CDBAddressメッセージを作成するクラス
 ********************************************************************************/
public class CL_IntCreateMsg_CDBAddress extends CL_IntCreateMsg {

/********************************************************************************
 * Constructor
 ********************************************************************************/
 
    /**
     * 初期化処理
     * 
     * @param argOldRecMap 更新前レコードMAP
     * @param argNewRecMap 更新後レコードMAP
     */
    public CL_IntCreateMsg_CDBAddress(Map<Id,sObject> argOldRecMap, Map<Id,sObject> argNewRecMap){
        super(argOldRecMap, argNewRecMap);
        endPoint =  CL_IntConst.CDB_ADDRESS_ENDPOINT;
        msgTypeId = CL_IntConst.CDB_ADDRESS_MSG_TYPE_ID;
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
         if((Boolean)newRec.get('EmergencyFlg_Upd__c') && newRecMap.size() == 1){
             return true;
         }
         if(oldRecMap.containsKey(newRec.Id)){
             sObject oldRec = oldRecMap.get(newRec.Id);
             if(newRec.get('ShokaiSoshin__c') == True){
                 if((String)newRec.get('BillingStreet') != (String)oldRec.get('BillingStreet')
                     || (String)newRec.get('BillingPostalCode') != (String)oldRec.get('BillingPostalCode')
                     || (String)newRec.get('BillingCountryCode') != (String)oldRec.get('BillingCountryCode')
                     || (String)newRec.get('BillingState') != (String)oldRec.get('BillingState')
                     || (String)newRec.get('BillingCity') != (String)oldRec.get('BillingCity')){
                         return true;
                 }
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
             json.writeStringField('MessageName', msgTypeId);
             json.writeStringField('Action', 'update');
             json.writeStringField('AccountId', chgNullToBlank(rec.Id));
             json.writeStringField('PartyId', chgNullToBlank((String)rec.get('Party_ID__c')));
             json.writeStringField('DealerPartyId', chgNullToBlank((String)rec.get('OwnerDealerPartyID__c')));
             json.writeStringField('BillingStreet', chgNullToBlank((String)rec.get('BillingStreet')));
             json.writeStringField('BillingPostalCode', chgNullToBlank((String)rec.get('BillingPostalCode')));
             json.writeStringField('BillingCountryCode', chgNullToBlank((String)rec.get('BillingCountryCode')));
             json.writeStringField('BillingState', chgNullToBlank((String)rec.get('BillingState')));
             json.writeStringField('BillingCity', chgNullToBlank((String)rec.get('BillingCity')));
             json.writeEndObject();
             
             reqMap.put(rec.Id ,json.getAsString());
         }
     }
}