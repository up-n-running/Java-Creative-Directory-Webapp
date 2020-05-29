package com.extware.advert.sql;

import com.extware.advert.Advert;

import com.extware.member.MemberClient;

import com.extware.utils.BooleanUtils;
import com.extware.utils.DatabaseUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PreparedStatementUtils;
import com.extware.utils.PropertyFile;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

import java.util.ArrayList;
import java.util.Date;

import javax.naming.NamingException;

import javax.servlet.ServletException;

/**
 * Class containing all the sql methods used on Adverts
 *
 * @author   John Milner
 */
public class AdvertSql
{

  private static String INSERT_ADVERT_SQL =
      "INSERT INTO ADVERTS ( " +
      "paymentDate, moderatedDate, goLiveDate, expiryDate, assetId, dueLiveDate, " +
      "name, statusRef, statusOther, countryRef, regionRef, address1, address2, city, " +
      "postcode, countyRef, telephone, fax, email, webAddress, whereDidYouHearRef, " +
      "whereDidYouHearOther, whereDidYouHearMagazine, premierePosition, durationMonths, onModerationHold, wentOnHoldDate, advertId " +
      ") VALUES " +
      "( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

  private static String SELECT_ADVERT_SQL =
      "SELECT " +
      "advertId, creationDate, paymentDate, moderatedDate, goLiveDate, expiryDate, assetId, dueLiveDate, " +
      "name, statusRef, statusOther, countryRef, regionRef, address1, address2, city, " +
      "postcode, countyRef, telephone, fax, email, webAddress, whereDidYouHearRef, " +
      "whereDidYouHearOther, whereDidYouHearMagazine, premierePosition, durationMonths, onModerationHold, wentOnHoldDate " +
      "FROM ADVERTS a ";

/**
 * Default Constructor for the AdvertSql object
 */
  public AdvertSql()
  {
  }

/**
 * Sets the advert as paid in the database. If the advert has already been moderated - it will also set go live and expiry dates
 *
 * @param advertId              advertId of advert to set as paid
 * @param adOptionNumber        this enables the method to find the duration of the advert in order to set expiry date if already been moderated.
 * @exception ServletException  thrown if there's a database error
 */
  public static void setAdvertAsPaid( int advertId, String adOptionNumber ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //find if it has been moderated
      String[] fieldNames = new String[2];
      fieldNames[0] = "moderatedDate";
      fieldNames[1] = "CURRENT_TIMESTAMP";
      Date[] dates = getDates( conn, ps, advertId, fieldNames );
      Date[] setDates;
      String[] setFields;

      if( dates[0] == null )
      {
        //set paymentDate, go live date and expiry date will be set once moderated and it's due live.
        setDates = new Date[1];
        setFields = new String[1];
      }
      else
      {
        //set payment, go live AND expiry date as already been moderated
        setDates = new Date[3];
        setFields = new String[3];
        setFields[1] = "expiryDate";
        setFields[2] = "goLiveDate";

        //set go live date and expiry date  - if slot available, go love now, otherwise, go live at next available slot
        Date nextSlot = getAdvertAvailability( advertId );

        //we pass in the advertId so we know if we're checking standard or premiere availability
        if( nextSlot == null )
        {
          setDates[2] = null;
          setDates[1] = new java.sql.Timestamp( dates[1].getTime() + getAdDurationInMillis( conn, advertId ) );
        }
        else
        {
          setDates[2] = new java.sql.Timestamp( nextSlot.getTime() );
          setDates[1] = new java.sql.Timestamp( nextSlot.getTime() + getAdDurationInMillis( conn, advertId ) );
        }
      }

      setDates[0] = null;
      setFields[0] = "PaymentDate";

      setDates( conn, ps, advertId, setFields, setDates );
      conn.close();

      //finally, update list of live adverts, just in case
      Advert.updateLiveAdvertsList();
    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * When we want to save or update an advert, we use this method to set the values on the prepared statement
 *
 * @param ps                The prepared statement
 * @param advert            the advert whose values we are going to use
 * @exception SQLException  thrown if any of the values are invalid for the database insert / update
 */
  public static void setAdvertValues( PreparedStatement ps, Advert advert ) throws SQLException
  {
    PreparedStatementUtils.setDate(    ps, 1, advert.paymentDate );
    PreparedStatementUtils.setDate(    ps, 2, advert.moderatedDate );
    PreparedStatementUtils.setDate(    ps, 3, advert.goLiveDate );
    PreparedStatementUtils.setDate(    ps, 4, advert.expiryDate );
    PreparedStatementUtils.setInt(     ps, 5, advert.assetId );
    PreparedStatementUtils.setDate(    ps, 6, advert.dueLiveDate );
    PreparedStatementUtils.setString(  ps, 7, advert.name, 200 );
    PreparedStatementUtils.setInt(     ps, 8, advert.statusRef );
    PreparedStatementUtils.setString(  ps, 9, advert.statusOther, 200 );
    PreparedStatementUtils.setInt(     ps, 10, advert.countryRef );
    PreparedStatementUtils.setInt(     ps, 11, advert.regionRef );
    PreparedStatementUtils.setString(  ps, 12, advert.address1, 200 );
    PreparedStatementUtils.setString(  ps, 13, advert.address2, 200 );
    PreparedStatementUtils.setString(  ps, 14, advert.city, 200 );
    PreparedStatementUtils.setString(  ps, 15, advert.postcode, 200 );
    PreparedStatementUtils.setInt(     ps, 16, advert.countyRef );
    PreparedStatementUtils.setString(  ps, 17, advert.telephone, 200 );
    PreparedStatementUtils.setString(  ps, 18, advert.fax, 200 );
    PreparedStatementUtils.setString(  ps, 19, advert.email, 200 );
    PreparedStatementUtils.setString(  ps, 20, advert.webAddress, 200 );
    PreparedStatementUtils.setInt(     ps, 21, advert.whereDidYouHearRef );
    PreparedStatementUtils.setString(  ps, 22, advert.whereDidYouHearOther, 200 );
    PreparedStatementUtils.setString(  ps, 23, advert.whereDidYouHearMagazine, 200 );
    PreparedStatementUtils.setString( ps, 24, advert.premierePosition );
    PreparedStatementUtils.setInt(     ps, 25, advert.durationMonths );
    PreparedStatementUtils.setString( ps, 26, advert.onModerationHold );
    PreparedStatementUtils.setDate(    ps, 27, advert.wentOnHoldDate );
    PreparedStatementUtils.setInt(     ps, 28, advert.advertId );
  }

/**
 * there are only so many adverts allowed at any one time on the nextface site. If loads of people place adverts, the people
 * Who placed them last may have to wait for a slot to become free. This returns the exact date and time that a slot becomes free.
 *
 * @param advertId              The id of the advert (in the database) we want to find next availability for
 * @return                      The exact date and time it can go on the site
 * @exception ServletException  thrown if there's a database error
 */
  public static Date getAdvertAvailability( int advertId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = conn.prepareStatement( "SELECT premierePosition FROM ADVERTS WHERE advertId = ? " );
      ps.setInt( 1, advertId );

      ResultSet rs = ps.executeQuery();
      rs.next();

      boolean premierePosition = BooleanUtils.parseBoolean( rs.getString( "premierePosition" ) );

      rs.close();
      ps.close();

      conn.close();

      return getAdvertAvailability()[premierePosition ? 0 : 1];
    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * there are only so many adverts allowed at any one time on the nextface site. If loads of people place adverts, the people
 * Who placed them last may have to wait for a slot to become free. This returns the exact date and time that a premiere slot becomes free in the first index of the array,
 * and the exact date of availability for a standard advert in the second index of the array
 *
 * @return                      The AdvertAvailability value
 * @exception ServletException  thrown if database access error
 */
  public static Date[] getAdvertAvailability() throws ServletException
  {
    Connection conn = null;

    try
    {
      //create sql statement
      String liveDatesSql = "SELECT 'L' dateType, a.premierePosition premiere, a.goLiveDate theDate FROM adverts a WHERE a.goLiveDate IS NOT NULL AND a.goLiveDate > CURRENT_TIMESTAMP " +
          "UNION ALL " +
          "SELECT 'E' dateType, a.premierePosition premiere, a.expiryDate theDate FROM adverts a WHERE a.expiryDate IS NOT NULL AND a.expiryDate > CURRENT_TIMESTAMP " +
          "ORDER BY 3 ASC, 1 DESC";

      //update LiveAdverts list to find out exactly how many std and prem ads there are currently live.
      Advert.updateLiveAdvertsList();

      PropertyFile dataDictionary = PropertyFile.getDataDictionary();
      int noOfPremAdsLeft = dataDictionary.getInt( "advertising.maxPremiereLeft" ) + dataDictionary.getInt( "advertising.maxPremiereRight" ) - Advert.getPremiereLiveAds().size();
      int noOfStndAdsLeft = dataDictionary.getInt( "advertising.maxStandardLeft" ) + dataDictionary.getInt( "advertising.maxStandardRight" ) - Advert.getStandardLiveAds().size();

      //initialise date array to store next available dates
      Date[] nextAvailableDates = new Date[2];
      nextAvailableDates[0] = null;
      nextAvailableDates[1] = null;

      Date lastDate = null;
      Date thisDate = null;

      boolean thisPremiere;
      boolean thisIsExpiry;
      boolean premiereFinishedLooking = noOfPremAdsLeft > 0;
      boolean standardFinishedLooking = noOfStndAdsLeft > 0;

      //initialise result set
      PreparedStatement ps = null;
      ResultSet rs = null;

      if( !premiereFinishedLooking || !standardFinishedLooking )
      {
        conn = DatabaseUtils.getDatabaseConnection();
        ps = conn.prepareStatement( liveDatesSql );
        rs = ps.executeQuery();
      }

      //loop through list
      while( !( premiereFinishedLooking && standardFinishedLooking ) && rs.next() )
      {
        thisDate = rs.getTimestamp( "theDate" );
        thisPremiere = BooleanUtils.parseBoolean( rs.getString( "premiere" ) );
        thisIsExpiry = rs.getString( "dateType" ).equals( "E" );

        if( lastDate == null )
        {
          lastDate = thisDate;
        }

        if( !thisDate.equals( lastDate ) )
        {
          if( !premiereFinishedLooking && noOfPremAdsLeft > 0 )
          {
            nextAvailableDates[0] = lastDate;
            premiereFinishedLooking = true;
          }

          if( !standardFinishedLooking && noOfStndAdsLeft > 0 )
          {
            nextAvailableDates[1] = lastDate;
            standardFinishedLooking = true;
          }

          lastDate = thisDate;
        }

        if( !premiereFinishedLooking && thisPremiere )
        {
          noOfPremAdsLeft += ( thisIsExpiry ? 1 : -1 );
        }

        if( !standardFinishedLooking && !thisPremiere )
        {
          noOfStndAdsLeft += ( thisIsExpiry ? 1 : -1 );
        }
      }
      //one last final update to take care of last set of similar dates
      if( thisDate != null && lastDate != null && !thisDate.equals( lastDate ) )
      {
        //the not null checks ensure that while loop has been gone through at least once.
        if( !premiereFinishedLooking && noOfPremAdsLeft > 0 )
        {
          nextAvailableDates[0] = lastDate;
          premiereFinishedLooking = true;
        }

        if( !standardFinishedLooking && noOfStndAdsLeft > 0 )
        {
          nextAvailableDates[1] = lastDate;
          standardFinishedLooking = true;
        }
      }

      if( noOfPremAdsLeft <= 0 || noOfStndAdsLeft <= 0 )
      {
        rs.close();
        ps.close();
        conn.close();
      }

      if( !premiereFinishedLooking || !standardFinishedLooking )
      {
        System.out.println( "NEXTFACE: com.extware.advert.sql.AdvertSql.getAdvertAvailability() SOMETHING IS WRONG WITH ADVERTS, COULD NOT FIND NEXT AVAILABLE ADVERT SLOT, THIS IS A SERIOUS ERROR" );
      }

      return nextAvailableDates;
    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * Finds the duration in milliseconds of an advert stored in the database
 *
 * @param conn              a connection object on which to run queries
 * @param advertId          id of the advert in database.
 * @return                  The Ads Duration In Millis value
 * @exception SQLException  thrown if exceptions with database access
 */
  public static long getAdDurationInMillis( Connection conn, int advertId ) throws SQLException
  {
    //add or update the record in the database
    PreparedStatement ps = conn.prepareStatement( "SELECT durationMonths FROM adverts WHERE advertId = ?" );
    ps.setInt( 1, advertId );

    ResultSet rs = ps.executeQuery();

    int durationMonths = 0;

    if( rs.next() )
    {
      durationMonths = rs.getInt( "durationMonths" );
    }

    rs.close();
    ps.close();

    long durationInMonths = (long)( durationMonths );

    return 1000L * 60L * 60L * 24L * 365L * durationInMonths / 12L;
  }

/**
 * Returns Advert from database given advertId
 *
 * @param advertId              id of advert to get
 * @return                      the Advert Object, or null if it doesn't exist
 * @exception ServletException  If exception with database access
 */
  public static Advert loadAdvert( int advertId ) throws ServletException
  {
    ArrayList adverts = loadAdverts( advertId, false, false, null, null, false );

    if( adverts == null || adverts.size() == 0 )
    {
      return null;
    }
    else
    {
      return (Advert)( adverts.get( 0 ) );
    }
  }

/**
 * returs Arraylist of all adverts requiring moderation. Ordered roughly correctly for displaying in adverts moderation report
 *
 * @return                      Arraylist of all adverts requiring moderation. Ordered roughly correctly for displaying in adverts moderation report
 * @exception ServletException  thrown if database access error
 */
  public static ArrayList loadAdvertsForModeration() throws ServletException
  {
    return loadAdverts( -1, true, false, null, null, false );
  }

/**
 * returns arraylist of all the live adverts - premire position first, then ordered by go live date ascending
 *
 * @return                      returns arraylist of all the live adverts - premire position first, then ordered by go live date ascending
 * @exception ServletException  thrown if database access error
 */
  public static ArrayList loadLiveAdverts() throws ServletException
  {
    return loadAdverts( -1, false, true, null, null, false );
  }

/**
 * returns a list fo all the adverts that have not been paid for that were created in a certain range
 *
 * @param createdAfter          Start of date range for created date
 * @param createdBefore         Description of Parameter
 * @return                      a list fo all the adverts that have not been paid for that were created in a certain range
 * @exception ServletException  thrown if database access error
 */
  public static ArrayList loadUnusedAdverts( Date createdAfter, Date createdBefore ) throws ServletException
  {
    return loadAdverts( -1, false, false, createdAfter, createdBefore, true );
  }

/**
 * deletes an advert
 *
 * @param advertId              id of advert to delete
 * @exception ServletException  thrown if database access error
 */
  public static void moderateFailAdvert( int advertId ) throws ServletException
  {
    Connection conn = null;
    try
    {
      //create sql statement
      conn = DatabaseUtils.getDatabaseConnection();
      String sql = "DELETE FROM ADVERTS WHERE advertId = ?";

      PreparedStatement ps = conn.prepareStatement( sql );
      ps.setInt( 1, advertId );
      ps.executeUpdate();
      ps.close();

    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * adds an advert row to advert table
 *
 * @param advert                Description of Parameter
 * @exception ServletException  thrown if database access error
 */
  public static void saveAdvertForModeraion( Advert advert ) throws ServletException
  {
    Connection conn = null;
    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      if( advert.advertId == -1 )
      {

        //generate unique id and date stamp for object.
        ps = conn.prepareStatement( "SELECT id FROM genAdvertId" );
        ResultSet rs = ps.executeQuery();

        if( rs.next() )
        {
          advert.advertId = rs.getInt( "id" );
        }

        advert.creationDate = new Date();

        //save
        ps = conn.prepareStatement( INSERT_ADVERT_SQL );
        setAdvertValues( ps, advert );
        ps.executeUpdate();
      }
    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * Finds the total size in Mb of all of the unpaid adverts that have been uploaded and not yet deleted.
 *
 * @return                      the total size in Mb of all of the unpaid adverts that have been uploaded and not yet deleted.
 * @exception ServletException  thrown if database access error
 */
  public static int findUnpaidAdvertFileSpaceMB() throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //generate unique id for object.
      ps = conn.prepareStatement( "select sum( filebytesize ) / ( 1024 * 1024 ) from adverts ad INNER JOIN assets ass ON ( ad.assetid = ass.assetId ) WHERE ad.PAYMENTDATE IS NULL" );
      ResultSet rs = ps.executeQuery();
      rs.next();
      return rs.getInt( 1 );
    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * Marks an advert as havin passed moderation. If the advert has also been paid for it will set go live and expiry date on advert too
 *
 * @param advertId              id of advert to be updated
 * @exception ServletException  thrown if database access error
 */
  public static void moderatePassAdvert( int advertId ) throws ServletException
  {
    Connection conn = null;
    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //find if it has been paid for
      String[] fieldNames = new String[2];
      fieldNames[0] = "paymentDate";
      fieldNames[1] = "CURRENT_TIMESTAMP";

      Date[] dates = getDates( conn, ps, advertId, fieldNames );

      Date[] setDates;
      String[] setFields;

      if( dates[0] == null )
      {
        //set moderated date, go live date and expiry date will be set once paid for
        setDates = new Date[1];
        setFields = new String[1];
      }
      else
      {
        //set moderated AND go live AND expiry date as already been paid for
        setDates = new Date[3];

        setFields = new String[3];
        setFields[1] = "expiryDate";
        setFields[2] = "goLiveDate";

        //set go live date and expiry date  - if slot available, go love now, otherwise, go live at next available slot
        Date nextSlot = getAdvertAvailability( advertId );

        //we pass in the advertId so we know if we're checking standard or premiere availability
        if( nextSlot == null )
        {
          setDates[2] = null;
          setDates[1] = new java.sql.Timestamp( dates[1].getTime() + getAdDurationInMillis( conn, advertId ) );
        }
        else
        {
          setDates[2] = new java.sql.Timestamp( nextSlot.getTime() );
          setDates[1] = new java.sql.Timestamp( nextSlot.getTime() + getAdDurationInMillis( conn, advertId ) );
        }
      }

      setDates[0] = null;
      setFields[0] = "moderatedDate";

      setDates( conn, ps, advertId, setFields, setDates );

      String sql = "UPDATE ADVERTS SET onModerationHold = 'f'";
      ps = conn.prepareStatement( sql );
      ps.executeUpdate();
      ps.close();
      conn.close();

      //finally, update list of live adverts, just in case.
      Advert.updateLiveAdvertsList();

    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * updates a series of date fields at once on one row of advert table (row determined by id parameter)
 *
 * @param conn              Connection object to use
 * @param ps                PreparedStatement  object to use
 * @param advertId          id of row to update
 * @param fieldNames        A list of field names to update
 * @param dates             the corresponding values to set the fields to
 * @exception SQLException  thrown if database access error
 */
  private static void setDates( Connection conn, PreparedStatement ps, int advertId, String[] fieldNames, Date[] dates ) throws SQLException
  {
    String sql = "UPDATE ADVERTS SET ";

    for( int i = 0; i < fieldNames.length; i++ )
    {
      sql += ( i > 0 ? ", " : "" ) + fieldNames[i] + " = " + ( ( dates.length >= i && dates[i] != null ) ? "?" : "CURRENT_TIMESTAMP" );
    }

    sql += " WHERE advertId = ?";

    ps = conn.prepareStatement( sql );

    int colNum = 1;

    for( int i = 0; i < fieldNames.length; i++ )
    {
      if( dates.length >= i && dates[i] != null )
      {
        PreparedStatementUtils.setDate( ps, colNum++, dates[i] );
      }
    }

    ps.setInt( colNum++, advertId );
    ps.executeUpdate();
    ps.close();
  }

/**
 * fetches a series of date fields at once on one row of advert table (row determined by id parameter)
 *
 * @param conn              Connection object to use
 * @param ps                PreparedStatement  object to use
 * @param advertId          id of row to update
 * @param fieldNames        A list of field names to update
 * @return                  the corresponding date values - corresponds to fieldNames array
 * @exception SQLException  thrown if database access error
 */
  private static Date[] getDates( Connection conn, PreparedStatement ps, int advertId, String[] fieldNames ) throws SQLException
  {
    Date[] replyDates = new Date[fieldNames.length];

    String sql = "SELECT ";

    for( int i = 0; i < fieldNames.length; i++ )
    {
      sql += ( i > 0 ? ", " : "" ) + fieldNames[i] + " date" + i;
    }

    sql += " FROM ADVERTS WHERE advertId = ?";

    ps = conn.prepareStatement( sql );
    ps.setInt( 1, advertId );

    ResultSet rs = ps.executeQuery();

    if( rs.next() )
    {
      for( int i = 0; i < fieldNames.length; i++ )
      {
        replyDates[i] = rs.getTimestamp( "date" + i );
      }
    }

    rs.close();
    ps.close();

    return replyDates;
  }

/**
 * General method for loading a list of adverts from the adverts table and placing them in an arraylist of Advert objects
 *
 * @param advertId              -1 if no advert filter to be applied, else apply filter to list can only contain this advert
 * @param moderationFilter      false if no advert filter to be applied, else only allow ads requiring moderation into list
 * @param liveFilter            false if no advert filter to be applied, else only allow live ads into list
 * @param createdAfter          false if no advert filter to be applied, else only allow ads created after this date into list
 * @param createdBefore         false if no advert filter to be applied, else only allow ads created before this date into list
 * @param unpaidFilter          false if no advert filter to be applied, else only allow unpaid ads into list
 * @return                      list af ads corresponding to input parameters
 * @exception ServletException  thrown if database access error
 */
  private static ArrayList loadAdverts( int advertId, boolean moderationFilter, boolean liveFilter, Date createdAfter, Date createdBefore, boolean unpaidFilter ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //create sql statement
      ArrayList adverts = new ArrayList();
      Advert advert = null;

      conn = DatabaseUtils.getDatabaseConnection();

      String sqlSelect = SELECT_ADVERT_SQL;
      String sqlFilter = "";
      String sqlOrder = "";
      String filterPrefix = "WHERE ";
      String orderPrefix = "ORDER BY ";

      if( advertId != -1 )
      {
        sqlFilter += filterPrefix + "a.advertId = ? ";
        filterPrefix = "AND ";
      }

      if( moderationFilter )
      {
        sqlFilter += filterPrefix + "a.moderatedDate IS NULL ";
        sqlOrder += orderPrefix + " a.onModerationHold ASC, a.paymentDate DESC";
        filterPrefix = "AND ";
        orderPrefix = ", ";
      }

      if( liveFilter )
      {
        sqlFilter += filterPrefix + "a.goLiveDate IS NOT NULL AND a.expiryDate IS NOT NULL AND a.goLiveDate <= CURRENT_TIMESTAMP AND a.expiryDate >= CURRENT_TIMESTAMP ";
        sqlOrder += orderPrefix + " a.premierePosition DESC, a.goLiveDate ASC, a.expiryDate DESC";
        filterPrefix = "AND ";
        orderPrefix = ", ";
      }

      if( unpaidFilter )
      {
        sqlFilter += filterPrefix + "a.paymentDate IS NULL ";
        filterPrefix = "AND ";
      }

      if( createdAfter != null )
      {
        sqlFilter += filterPrefix + "a.creationDate > ? ";
        filterPrefix = "AND ";
      }

      if( createdBefore != null )
      {
        sqlFilter += filterPrefix + "a.creationDate < ? ";
        filterPrefix = "AND ";
      }

      PreparedStatement ps = conn.prepareStatement( sqlSelect + " " + sqlFilter + " " + sqlOrder );

      int qtnMarkno = 1;

      if( advertId != -1 )
      {
        ps.setInt( qtnMarkno++, advertId );
      }

      if( createdAfter != null )
      {
        PreparedStatementUtils.setDate( ps, qtnMarkno++, createdAfter );
      }

      if( createdBefore != null )
      {
        PreparedStatementUtils.setDate( ps, qtnMarkno++, createdBefore );
      }

      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      while( rs.next() )
      {
        advert = createAdvert( rs );
        adverts.add( advert );
      }
      rs.close();
      ps.close();
      conn.close();

      return adverts;
    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      throw new ServletException( sex.toString() );
    }
    catch( NamingException nex )
    {
      nex.printStackTrace();
      throw new ServletException( nex.toString() );
    }
    finally
    {
      if( conn != null )
      {
        try
        {
          conn.close();
        }
        catch( SQLException sex )
        {
          throw new ServletException( sex.toString() );
        }
      }
    }
  }

/**
 * creates an Advert using a result set row containing a row from the advert table
 *
 * @param rs                result set currently at appropriate row
 * @return                  the Advert corresponding to this result set row
 * @exception SQLException  thrown if database access error
 */
  private static Advert createAdvert( ResultSet rs ) throws SQLException
  {
    Advert advert = new Advert(
        rs.getInt( "advertId" ),
        rs.getTimestamp( "creationDate" ),
        rs.getTimestamp( "paymentDate" ),
        rs.getTimestamp( "moderatedDate" ),
        rs.getTimestamp( "goLiveDate" ),
        rs.getTimestamp( "expiryDate" ),
        null,  //asset
        NumberUtils.parseInt( rs.getString( "assetId" ), -1 ),
        rs.getTimestamp( "dueLiveDate" ),
        rs.getString( "name" ),
        NumberUtils.parseInt( rs.getString( "statusRef" ), -1 ),
        rs.getString( "statusOther" ),
        NumberUtils.parseInt( rs.getString( "countryRef" ), -1 ),
        NumberUtils.parseInt( rs.getString( "regionRef" ), -1 ),
        rs.getString( "address1" ),
        rs.getString( "address2" ),
        rs.getString( "city" ),
        rs.getString( "postcode" ),
        NumberUtils.parseInt( rs.getString( "countyRef" ), -1 ),
        rs.getString( "telephone" ),
        rs.getString( "fax" ),
        rs.getString( "email" ),
        rs.getString( "webaddress" ),
        NumberUtils.parseInt( rs.getString( "whereDidYouHearRef" ), -1 ),
        rs.getString( "whereDidYouHearOther" ),
        rs.getString( "whereDidYouHearMagazine" ),
        BooleanUtils.parseBoolean( rs.getString( "premierePosition" ) ),
        rs.getInt( "durationMonths" ),
        BooleanUtils.parseBoolean( rs.getString( "onModerationHold" ) ),
        rs.getTimestamp( "wentOnHoldDate" )
         );
    return advert;
  }

/**
 * Updates database only to reflect the advert being on hold
 *                                                                          }
 * @param advertId              id of advert to put on hold
 * @exception ServletException  thrown if database exception
 */
  public static void putAdvertOnHold( int advertId ) throws ServletException
  {
    MemberClient.putOnHold( "ADVERTS", "advertId", advertId, true );
  }

}                                                                   