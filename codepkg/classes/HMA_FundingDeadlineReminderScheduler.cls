public without sharing class HMA_FundingDeadlineReminderScheduler implements Schedulable {
    public static String cronExp = '0 0 22 * * ? *'; 
    /*public static String scheduleMe() {
        HMA_FundingDeadlineReminderScheduler SC = new HMA_FundingDeadlineReminderScheduler(); 
        return System.schedule('HMA_FundingDeadlineReminder Job', cronExp, SC);
    }*/
    public void execute(SchedulableContext SC) {
        HMA_FundingDeadlineReminderBatch batch = new HMA_FundingDeadlineReminderBatch(15);
        database.executeBatch(batch);
        HMA_FundingDeadlineReminderBatch batch1 = new HMA_FundingDeadlineReminderBatch(30);
        database.executeBatch(batch1);
        HMA_FundingDeadlineReminderBatch batch2 = new HMA_FundingDeadlineReminderBatch(60);
        database.executeBatch(batch2);
    }
}