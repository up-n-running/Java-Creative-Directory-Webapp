package com.extware.member;

import com.extware.member.Member;

import java.util.Calendar;
import java.util.Comparator;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * Comparator class used when doing a Collection.Sort() on an ArrayList of Members to sort them ready for a member moderation report
 *
 * @author   John Milner
 */
public class MemberModerationComparator implements Comparator
{

  public Date     now;
  public Calendar nowCal;
  public char     type;

/**
 * Constructor for the MemberModerationComparator object
 *
 * @param now  the current date to be used in comparisons with go live and
 *      expiry dates so the comparator knows whether the member is live or
 *      expired etc.
 */
  public MemberModerationComparator( Date now )
  {
    this.now = now;
    nowCal = new GregorianCalendar();
    nowCal.setTime( now );
  }

/**
 * Constructor for the MemberModerationComparator object
 */
  public MemberModerationComparator()
  {
    this.now = new Date();
    nowCal = new GregorianCalendar();
    nowCal.setTime( now );
    type = 'd';
  }

/**
 * Constructor for the MemberModerationComparator object
 *
 * @param type  which moderation report are we sorting for: d=memberdetails,
 *      j=jobs, f=files.
 */
  public MemberModerationComparator( char type )
  {
    this.now = new Date();
    nowCal = new GregorianCalendar();
    nowCal.setTime( now );
    this.type = type;
  }

/**
 * Compare two Objects. Callback for sort. effectively returns a-b;
 *here's the ordering sequence...<br />
 *not on hold<br />
 *#paid<br />
 *##not live yet<br />
 *###least recently updated<br />
 *###most recently updated<br />
 *##live currently<br />
 *###least recently updated<br />
 *###most recently updated<br />
 *##expired<br />
 *###least recently updated<br />
 *###most recently updated<br />
 *#unpaid<br />
 *##least recently updated<br />
 *##most recently updated<br />
 *on hold<br />
 *#paid<br />
 *##not live yet<br />
 *###least recently updated<br />
 *###most recently updated<br />
 *##live currently<br />
 *###least recently updated<br />
 *###most recently updated<br />
 *##expired<br />
 *###least recently updated<br />
 *###most recently updated<br />
 *#unpaid<br />
 *##least recently updated<br />
 *##most recently updated<br />
 *<br />
 * @param a  Member Object to compare (labelled A in documentation)
 * @param b  Member Object to compare (labelled B in documentation)
 * @return   returns +1 (or any +ve number) if a > b, 0 if a == b, -1 (or
 *      any -ve number) if a < b
 */
  public final int compare( Object a, Object b )
  {
    Member aM = (Member)a;
    Member bM = (Member)b;

    //if on hold values are different
    if( aM.onModerationHold != bM.onModerationHold )
    {
      if( aM.onModerationHold )
      {
        return 1;
      }  //b comes first
      else
      {
        return -1;
      }  //a comes first
    }

    //if both are hold
    if( aM.onModerationHold && bM.onModerationHold )
    {
      //find if they are new hold or old holds
      Calendar aMWentOnHoldCal = new GregorianCalendar();
      aMWentOnHoldCal.setTime( aM.wentOnHoldDate );
      Calendar bMWentOnHoldCal = new GregorianCalendar();
      bMWentOnHoldCal.setTime( bM.wentOnHoldDate );

      int aHoldStatus = ( aMWentOnHoldCal.get( Calendar.YEAR ) == nowCal.get( Calendar.YEAR ) && aMWentOnHoldCal.get( Calendar.DAY_OF_YEAR ) == nowCal.get( Calendar.DAY_OF_YEAR ) ) ? 1 : 2;
      int bHoldStatus = ( bMWentOnHoldCal.get( Calendar.YEAR ) == nowCal.get( Calendar.YEAR ) && bMWentOnHoldCal.get( Calendar.DAY_OF_YEAR ) == nowCal.get( Calendar.DAY_OF_YEAR ) ) ? 1 : 2;

      if( aHoldStatus < bHoldStatus )
      {
        return -1;
      } //a comes first

      if( bHoldStatus < aHoldStatus )
      {
        return 1;
      } //b comes first
    }

    //on hold statuses are same, so has one paid and the other not.
    if( aM.lastPaymentDate == null && bM.lastPaymentDate != null )
    {
      return 1;
    }  //b comes first

    if( bM.lastPaymentDate == null && aM.lastPaymentDate != null )
    {
      return -1;
    }  //a comes first

    if( bM.lastPaymentDate != null )
    {
      //if they've both paid, go on how live they are
      int aLiveStatus = aM.goLiveDate == null ? 1 : ( aM.expiryDate.before( now ) ? 2 : 3 );
      int bLiveStatus = bM.goLiveDate == null ? 1 : ( bM.expiryDate.before( now ) ? 2 : 3 );

      if( aLiveStatus < bLiveStatus )
      {
        return -1;
      }  //a comes first

      if( bLiveStatus < aLiveStatus )
      {
        return 1;
      }  //b comes first

      //both paid, and same live statuses, so go on updated date now.
      Date aMLastUpdated = getUpdateDate( aM );
      Date bMLastUpdated = getUpdateDate( bM );

      if( aMLastUpdated.after( bMLastUpdated ) )
      {
        return 1;
      }  //b comes first
      else
      {
        return -1;
      }  //a comes first

    }
    else
    {
      //if they're both undaid, go on updated date
      //both paid, and same live statuses, so go on updated date now.
      Date aMLastUpdated = getUpdateDate( aM );
      Date bMLastUpdated = getUpdateDate( bM );

      if( aMLastUpdated.after( bMLastUpdated ) )
      {
        return 1;
      }  //b comes first
      else
      {
        return -1;
      }  //a comes first
    }

    //this line will never be reached
  }

/**
 * Gets the UpdateDate attribute of the MemberModerationComparator object
 *
 * @param m  Description of Parameter
 * @return   The UpdateDate value
 */
  private Date getUpdateDate( Member m )
  {
    Date lastUpdated = null;

    if( type == 'd' )
    {
      //member details
      lastUpdated = m.moderationMemberContact != null ? m.moderationMemberContact.lastUpdatedDate : m.moderationMemberProfile.lastUpdatedDate;
      //at least one of membercontact and memberprofile will be set

      if( m.moderationMemberContact != null && m.moderationMemberProfile != null && m.moderationMemberProfile.lastUpdatedDate.before( m.moderationMemberContact.lastUpdatedDate ) )
      {
        lastUpdated = m.moderationMemberProfile.lastUpdatedDate;
      }
    }
    else if( type == 'j' )
    {
      //member jobs
      Date temp = null;

      for( int i = 0; i < m.memberJobs.size(); i++ )
      {
        //fins lowest updated date on all those that need moderation
        temp = ( (MemberJob[])m.memberJobs.get( i ) )[1].lastUpdatedDate;

        if( lastUpdated == null || lastUpdated.after( temp ) )
        {
          lastUpdated = temp;
        }
      }
    }
    else if( type == 'f' )
    {
      //member files
      Date temp = null;

      for( int i = 0; i < m.moderationMemberFiles.size(); i++ )
      {
        //fins lowest updated date on all those that need moderation
        temp = ( (MemberFile)m.moderationMemberFiles.get( i ) ).uploadDate;

        if( lastUpdated == null || lastUpdated.after( temp ) )
        {
          lastUpdated = temp;
        }
      }
    }

    return lastUpdated;
  }

}
