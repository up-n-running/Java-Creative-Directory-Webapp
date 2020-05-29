package com.extware.advert;

import com.extware.advert.Advert;

import java.util.Calendar;
import java.util.Comparator;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * Comparator class used when doing a Collection.Sort() on an ArrayList of Adverts to sort adverts ready for advert moderation report
 *
 * @author   John Milner
 */
public class AdvertModerationComparator implements Comparator
{

  public Date     now;
  public Calendar nowCal;

/**
 * Constructor for the AdvertModerationComparator object
 *
 * @param now  the current date to be used in comparisons with go live and
 *      expiry dates so the comparator knows whether the member is live or
 *      expired etc.
 */
  public AdvertModerationComparator( Date now )
  {
    this.now = now;
    nowCal = new GregorianCalendar();
  }

/**
 * Constructor for the AdvertModerationComparator object
 */
  public AdvertModerationComparator()
  {
    this.now = new Date();
    nowCal = new GregorianCalendar();
    nowCal.setTime( now );
  }

/**
 * Compare two Objects. Callback for sort. effectively returns a-b; here's
 * the ordering sequence... <br />
 * here's the ordering sequence...<br />
 * not on hold<br />
 * #paid<br />
 * ##least recently updated<br />
 * ##most recently updated<br />
 * #unpaid<br />
 * ##least recently updated<br />
 * ##most recently updated<br />
 * on hold<br />
 * #paid<br />
 * ##least recently updated<br />
 * ##most recently updated<br />
 * #unpaid<br />
 * ##least recently updated<br />
 * ##most recently updated<br />
 *
 * @param a  Advert Object to compare (labelled A in documentation)
 * @param b  Advert Object to compare (labelled B in documentation)
 * @return   returns +1 (or any +ve number) if a > b, 0 if a == b, -1 (or
 *      any -ve number) if a < b
 */
  public final int compare( Object a, Object b )
  {
    Advert aA = (Advert)a;
    Advert bA = (Advert)b;

    //if on hold values are different
    if( aA.onModerationHold != bA.onModerationHold )
    {
      if( aA.onModerationHold )
      {
        return 1;
      }
      //b comes first
      else
      {
        return -1;
      }
      //a comes first
    }

    //if both are hold
    if( aA.onModerationHold && bA.onModerationHold )
    {
      //find if they are new hold or old holds
      Calendar aAWentOnHoldCal = new GregorianCalendar();
      aAWentOnHoldCal.setTime( aA.wentOnHoldDate );
      Calendar bAWentOnHoldCal = new GregorianCalendar();
      bAWentOnHoldCal.setTime( bA.wentOnHoldDate );

      int aHoldStatus = ( aAWentOnHoldCal.get( Calendar.YEAR ) == nowCal.get( Calendar.YEAR ) && aAWentOnHoldCal.get( Calendar.DAY_OF_YEAR ) == nowCal.get( Calendar.DAY_OF_YEAR ) ) ? 1 : 2;
      int bHoldStatus = ( bAWentOnHoldCal.get( Calendar.YEAR ) == nowCal.get( Calendar.YEAR ) && bAWentOnHoldCal.get( Calendar.DAY_OF_YEAR ) == nowCal.get( Calendar.DAY_OF_YEAR ) ) ? 1 : 2;

      if( aHoldStatus < bHoldStatus )
      {
        return -1;
      }  //a comes first

      if( bHoldStatus < aHoldStatus )
      {
        return 1;
      }  //b comes first
    }

    //on hold statuses are same, so has one paid and the other not.
    if( aA.paymentDate == null && bA.paymentDate != null )
    {
      return 1;
    }  //b comes first
    if( bA.paymentDate == null && aA.paymentDate != null )
    {
      return -1;
    }  //a comes first

    //final test - which was updated first
    if( aA.creationDate.after( bA.creationDate ) )
    {
      return 1;
    }  //b comes first
    else
    {
      return -1;
    } //a comes first

    //this line will never be reached

  }

}

