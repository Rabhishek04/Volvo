trigger TR_Account on Account (before insert, before update, after insert, after update) {

    if(Trigger.isBefore){
        if(ApexTrgFuncEnable__c.getOrgDefaults().RemoveDashForAccountFlg__c){
            for(Account acc : Trigger.new){
                if(String.isNotBlank(acc.BillingPostalCode)){
                    acc.BillingPostalCode = acc.BillingPostalCode.remove('-');
                }
            }
        }
    }

    if(Trigger.isAfter){
        CL_IntUpdateRecord.trgNum++;    // トリガの起動数をインクリメント
        
        // メッセージ送信
        if(ApexTrgFuncEnable__c.getOrgDefaults().MsgSendTriggerFlgCDB__c && CL_IntUpdateRecord.trgNum == 1){
            List<CL_IntCreateMsg> msgList = new List<CL_IntCreateMsg>();
            msgList.add(new CL_IntCreateMsg_CDBAdd(Trigger.oldMap, Trigger.newMap));
            msgList.add(new CL_IntCreateMsg_CDBMain(Trigger.oldMap, Trigger.newMap));
            msgList.add(new CL_IntCreateMsg_CDBName(Trigger.oldMap, Trigger.newMap));
            msgList.add(new CL_IntCreateMsg_CDBAddress(Trigger.oldMap, Trigger.newMap));
            msgList.add(new CL_IntCreateMsg_CDBPhone(Trigger.oldMap, Trigger.newMap));
            msgList.add(new CL_IntCreateMsg_CDBFax(Trigger.oldMap, Trigger.newMap));
            msgList.add(new CL_IntCreateMsg_CDBWeb(Trigger.oldMap, Trigger.newMap));
            
            CL_IntSendMsg.sendMsg(msgList);
            
            CL_IntUpdateRecord.updateAccount(Trigger.newMap);
        }
        
        CL_IntUpdateRecord.trgNum--;    // トリガの起動数をデクリメント
    }
}