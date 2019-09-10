/********************************************************************************
 * 概要 ： 目標・受注レコード登録、更新バッチのスケジューラ
 ********************************************************************************/
public class CL_UpdMokuhyoJyuchuBatch_Sch implements Schedulable{
    /**
     * Schedulableインターフェースのexecuteメソッド
     */
    public void execute(SchedulableContext sc) {
        //バッチ実行
        CL_UpdMokuhyoJyuchuBatch batch = new CL_UpdMokuhyoJyuchuBatch();

        //集計関数を多数使用する為、バッチサイズは小さくした方が良い
        Database.executeBatch(batch, Integer.valueOf(System.Label.AP01_DEF_0003));
    }

}