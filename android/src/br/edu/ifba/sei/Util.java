package br.edu.ifba.sei;

import android.app.job.JobInfo;
import android.app.job.JobScheduler;
import android.content.ComponentName;
import android.content.Context;

public class Util {

    // schedule the start of the service every 10 - 30 seconds
    public static void scheduleJob(Context context) {
        ComponentName serviceComponent = new ComponentName(context, SEICheckerJobService.class);

        JobInfo.Builder builder = new JobInfo.Builder(0, serviceComponent);
        //builder.setPeriodic(15 * 60 * 1000L); // 15 minutes (minimum value)
        builder.setMinimumLatency(5 * 1000); // wait at least
        builder.setOverrideDeadline(10 * 1000); // maximum delay
        builder.setPersisted(true);
        //builder.setRequiredNetworkType(JobInfo.NETWORK_TYPE_UNMETERED); // require unmetered network
        //builder.setRequiresDeviceIdle(true); // device should be idle
        //builder.setRequiresCharging(false); // we don't care if the device is charging or not

        final JobScheduler jobScheduler = (JobScheduler) context.getSystemService(Context.JOB_SCHEDULER_SERVICE);
        jobScheduler.schedule(builder.build());
    }

    public static boolean isScheduled(Context context) {
        final JobScheduler jobScheduler = (JobScheduler) context.getSystemService(Context.JOB_SCHEDULER_SERVICE);
        return jobScheduler.getAllPendingJobs().size() > 0;
    }
}
