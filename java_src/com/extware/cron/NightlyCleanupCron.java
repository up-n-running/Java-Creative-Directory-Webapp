package com.extware.cron;

import com.extware.advert.Advert;

import com.extware.advert.sql.AdvertSql;

import com.extware.cron.sql.CronSql;

import com.extware.emailSender.EmailSender;

import com.extware.member.Member;

import com.extware.member.MemberClient;

import com.extware.utils.PropertyFile;

import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Date;

import javax.servlet.ServletException;

/**
 * Description of the Class
 *
 * @author   John Milner
 */
public class NightlyCleanupCron
{
  private static boolean cronRunning = false;

  private static final long MILLIS_IN_DAY = 1000L * 60L * 60L * 24L;

/**
 * The main program for the NightlyCleanupCron class, goe sthrough and sends reminder emails, and deletes old memebrs and deletes old adverts
 * This method simply calls the cron methos if it's not already running
 *
 * @param args  The command line arguments - not used
 */
  public static void main( String[] args )
  {
    try
    {
      if( cronRunning )
      {
        System.out.println( new Date() + " Already Running!" );
      }
      else
      {
        cleanup();
      }
    }
    catch( Throwable tb )
    {
      tb.printStackTrace();
    }

    System.exit( 0 );
  }

/**
 * The main program for the NightlyCleanupCron class, goe sthrough and sends reminder emails, and deletes old memebrs and deletes old adverts
 *
 * @exception ServletException  thrown if dataabse or filesystem expectipn
 */
  private static void cleanup() throws ServletException
  {
    System.out.println( new Date() + " Starting" );
    cronRunning = true;

    Date thisRunDate = new Date();
    Date lastRunDate = CronSql.getLastCronRunDate( true );

    System.out.println( new Date() + " thisRunDate: " + thisRunDate + " lastRunDate: " + lastRunDate );

    PropertyFile dataDictionary = PropertyFile.getDataDictionary();

// Gentle reminder email
    System.out.println( new Date() + " Gentle reminder email" );
    long gentleReminderMillis = (long)( dataDictionary.getInt( "cron.gentleReminder.daysAfterRegistering" ) ) * MILLIS_IN_DAY;
    ArrayList memberList = MemberClient.loadUpdaidMembersForCron( new Date( lastRunDate.getTime() - gentleReminderMillis ), new Date( thisRunDate.getTime() - gentleReminderMillis ) );
    System.out.println( new Date() + " Found " + memberList.size() + " members" );
    sendThemAllAnEmail( "emailcronremind1", "Reminder: Your Nextface account details", memberList );
    System.out.println( new Date() + " Emails sent" );

// Final reminder email
    System.out.println( new Date() + " Final reminder email" );
    long finalReminderMillis = (long)( dataDictionary.getInt( "cron.finalReminder.daysAfterRegistering" ) ) * MILLIS_IN_DAY;
    memberList = MemberClient.loadUpdaidMembersForCron( new Date( lastRunDate.getTime() - finalReminderMillis ), new Date( thisRunDate.getTime() - finalReminderMillis ) );
    System.out.println( new Date() + " Found " + memberList.size() + " members" );
    sendThemAllAnEmail( "emailcronremind2", "Final Reminder: Your Nextface account details are marked for deletion", memberList );
    System.out.println( new Date() + " Emails sent" );

// Delete old unpaid members
    System.out.println( new Date() + " Delete old unpaid members" );
    long deletionHoldMillis = (long)( dataDictionary.getInt( "cron.deleteMember.daysAfterRegistering" ) ) * MILLIS_IN_DAY;
    memberList = MemberClient.loadUpdaidMembersForCron( null, new Date( thisRunDate.getTime() - deletionHoldMillis ) );
    System.out.println( new Date() + " Found " + memberList.size() + " members" );
    sendThemAllAnEmail( "emailcrondelunpd", "Your Nextface account has been deleted", memberList );
    System.out.println( new Date() + " Emails sent" );

    for( int i = 0; i < memberList.size(); i++ )
    {
      ( (Member)memberList.get( i ) ).deleteMe();
    }

    System.out.println( new Date() + " Deleted" );

// Members about to expire
    System.out.println( new Date() + " Members about to expire" );
    long expiryReminder = (long)( dataDictionary.getInt( "cron.expiryReminder.daysBeforeExpiry" ) ) * MILLIS_IN_DAY;
    memberList = MemberClient.loadAboutToExpireMembersForCron( new Date( lastRunDate.getTime() + expiryReminder ), new Date( thisRunDate.getTime() + expiryReminder ) );
    System.out.println( new Date() + " Found " + memberList.size() + " members" );
    sendThemAllAnEmail( "emailcronexpiry1", "Your Nextface account renewal notice", memberList );
    System.out.println( new Date() + " Emails sent" );

// Members just expired
    System.out.println( new Date() + " Members just expired" );
    memberList = MemberClient.loadAboutToExpireMembersForCron( lastRunDate, thisRunDate );
    System.out.println( new Date() + " Found " + memberList.size() + " members" );
    sendThemAllAnEmail( "emailcronexpiry2", "Your Nextface has just expired", memberList );
    System.out.println( new Date() + " Emails sent" );

// Members long expired
    System.out.println( new Date() + " Members long expired" );
    long expiryDeleteTime = (long)( dataDictionary.getInt( "cron.deleteMember.daysAfterExpiry" ) ) * MILLIS_IN_DAY;
    memberList = MemberClient.loadAboutToExpireMembersForCron( null, new Date( thisRunDate.getTime() - expiryDeleteTime ) );
    System.out.println( new Date() + " Found " + memberList.size() + " members" );
    sendThemAllAnEmail( "emailcronexpiry3", "Your Nextface account has been deleted", memberList );
    System.out.println( new Date() + " Emails sent" );

    for( int i = 0; i < memberList.size(); i++ )
    {
      ( (Member)memberList.get( i ) ).deleteMe();
    }

    System.out.println( new Date() + " Deleted" );

// Now clean up unused adverts
    System.out.println( new Date() + " Clean up unused adverts" );
    long advertMaxDormantTime = (long)( dataDictionary.getInt( "cron.deleteAdvert.maxUnpaidDormantHours" ) ) * MILLIS_IN_DAY / 24L;
    ArrayList advertList = AdvertSql.loadUnusedAdverts( null, new Date( thisRunDate.getTime() - advertMaxDormantTime ) );
    System.out.println( new Date() + " Found " + memberList + " adverts" );

    for( int i = 0; i < advertList.size(); i++ )
    {
      ( (Advert)advertList.get( i ) ).deleteMe();
    }

    System.out.println( new Date() + " Deleted" );

// Cron end admin
    CronSql.setLastCronRunDate( thisRunDate );
    cronRunning = false;

    System.out.println( new Date() + " Done" );
  }

/**
 * Send an email to a whole arraylist of members
 *
 * @param textPageName   text page handle of text page describing email content
 * @param subject        subject heading of email (can contain replacers)
 * @param listOfMembers  list of Member objects who we're going to send an email to
 */
  private static void sendThemAllAnEmail( String textPageName, String subject, ArrayList listOfMembers )
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();

    long deletionHoldMillis = (long)( dataDictionary.getInt( "cron.deleteMember.daysAfterRegistering" ) ) * MILLIS_IN_DAY;

    SimpleDateFormat sdf = new SimpleDateFormat( "EEEE, dd MMMM, yyyy" );

    Member member;

    for( int i = 0; i < listOfMembers.size(); i++ )
    {
      member = (Member)listOfMembers.get( i );

      ArrayList replacerKeys = new ArrayList();
      ArrayList replacerVals = new ArrayList();
      replacerKeys.add( "&lt;USERDELETIONDATE&gt;" );
      replacerVals.add( sdf.format( new Date( member.regDate.getTime() + deletionHoldMillis ) ) );

      if( member.expiryDate != null )
      {
        replacerKeys.add( "&lt;USEREXPIRYDATE&gt;" );
        replacerVals.add( sdf.format( member.expiryDate ) );
      }

      try
      {
        EmailSender.sendMail( textPageName, subject, member, replacerKeys, replacerVals );
      }
      catch( ServletException ex )
      {
        System.out.println( new Date() + " Mail send exception " + ex.toString() );
      }
    }
  }

}
