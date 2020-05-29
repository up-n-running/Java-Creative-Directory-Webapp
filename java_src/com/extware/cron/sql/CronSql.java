package com.extware.cron.sql;

import com.extware.utils.DatabaseUtils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.Date;

import javax.naming.NamingException;

import javax.servlet.ServletException;

/**
 * Contains just methods for saving and loading last cron run date
 *
 * @author   John Milner
 */
public class CronSql
{

/**
 * Sets the Last Cron Run Date in db if there's only 1 cron
 *
 * @param cronDate              date to set in database
 * @exception ServletException  thrown if there's a database error
 */
  public static void setLastCronRunDate( Date cronDate ) throws ServletException
  {
    setLastCronRunDate( "", cronDate );
  }

/**
 * Sets the Last Cron Run Date in db for the cron specified by cronNameAppend
 *
 * @param cronNameAppend        the unique handle for this cron in the database - appended to "lastCronTime" to find column name in database
 * @param cronDate              date to set in database
 * @exception ServletException  thrown if there's a database error
 */
  public static void setLastCronRunDate( String cronNameAppend, Date cronDate ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = conn.prepareStatement( "UPDATE GLOBALDATABASEVARIABLES SET lastCronTime" + ( cronNameAppend == null ? "" : cronNameAppend ) + " = ?" );
      ps.setTimestamp( 1, new java.sql.Timestamp( cronDate.getTime() ) );

      ps.executeUpdate();

      ps.close();
      conn.close();

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
 * Gets the LastCronRunDate if app only has one cron, if it's first time cron has been run - it will default to a date very much in the past
 *
 * @return                      The Last Cron Run Date value. Or a date far in the past if cron never been run
 * @exception ServletException  thrown if there's a database error
 */
  public static Date getLastCronRunDate() throws ServletException
  {
    return getLastCronRunDate( null, true );
  }

/**
 * Gets the LastCronRunDate if app only has one cron
 *
 * @param defaultToAgesAgo      true means return a date way in the past if the cron has never been run before. false means return null if the cron has never been run before
 * @return                      The last cron run date
 * @exception ServletException  thrown if there's a database error
 */
  public static Date getLastCronRunDate( boolean defaultToAgesAgo ) throws ServletException
  {
    return getLastCronRunDate( null, defaultToAgesAgo );
  }

/**
 * Gets the LastCronRunDate for specified cron
 *
 * @param cronNameAppend        the unique handle for this cron in the database - appended to "lastCronTime" to find column name in database
 * @param defaultToAgesAgo      true means return a date way in the past if the cron has never been run before. false means return null if the cron has never been run before
 * @return                      The last cron run date
 * @exception ServletException  thrown if there's a database error
 */
  public static Date getLastCronRunDate( String cronNameAppend, boolean defaultToAgesAgo ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = conn.prepareStatement( "SELECT lastCronTime FROM GLOBALDATABASEVARIABLES" );

      ResultSet rs = ps.executeQuery();

      try
      {
        rs.next();
      }
      catch( Exception ex )
      {
        throw new ServletException( "TABLE GLOBALDATABASEVARIABLES MUST HAVE EXACTLY ONE ROW IN, WITH ID OF 1\n" + ex.toString() );
      }

      Date lastCronTime = rs.getTimestamp( "lastCronTime" + ( cronNameAppend == null ? "" : cronNameAppend ) );
      rs.close();
      ps.close();
      conn.close();

      if( lastCronTime == null )
      {
        long agesAgoMillis = 1000l * 60l * 60l * 24l * 365l * 100l;
        //100 years in millis
        lastCronTime = new Date( ( new Date() ).getTime() - agesAgoMillis );
      }

      return lastCronTime;
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

}
