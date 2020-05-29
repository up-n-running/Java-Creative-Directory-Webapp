package com.extware.member.sql;

import com.extware.framework.DropDownOption;

import com.extware.member.Member;

import com.extware.utils.DatabaseUtils;
import com.extware.utils.PreparedStatementUtils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Date;

import javax.naming.NamingException;

import javax.servlet.ServletException;

/**
 * SQL class for Member Object and it's sub-objects
 *
 * @author   John Milner
 */
public class MemberOfWeekSql
{

/**
 * Sets the MemberOfWeek for given member on given week with given decription as handle
 *
 * @param memberWeek            the week descriptor
 * @param memberId              member to set
 * @param description           description
 * @exception ServletException  thrown if database exception
 */
  public static void setMemberOfWeek( String memberWeek, int memberId, String description ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //delete any old member week stuff
      ps = conn.prepareStatement( "DELETE FROM memberOfWeek WHERE weekDescriptor = ? " );
      ps.setString( 1, memberWeek );
      ps.executeUpdate();

      //generate unique id for object.
      ps = conn.prepareStatement( "INSERT INTO memberOfWeek ( weekDescriptor, memberId, description ) VALUES ( ?, ?, ? ) " );
      ps.setString( 1, memberWeek );
      ps.setInt( 2, memberId );
      PreparedStatementUtils.setString( ps, 3, description, 100 );
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
 * Gets the id of the current member of the week assuming current date is date passed in
 *
 * @param now                   date to assume as current time
 * @return                      id of the current member of the week
 * @exception ServletException  thrown if database exception
 */
  public static int getMemberOfWeekId( Date now ) throws ServletException
  {
    Connection conn = null;
    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      String weekDescriptor = Member.getDateDescriptor( Member.getWeekEnd( now ) );

      //generate unique id for object.
      ps = conn.prepareStatement( "SELECT memberId FROM memberOfWeek WHERE weekDescriptor <= ? ORDER BY weekDescriptor DESC " );
      ps.setString( 1, weekDescriptor );

      ResultSet rs = ps.executeQuery();

      int memberId = -1;

      if( rs.next() )
      {
        memberId = rs.getInt( "memberId" );
      }

      rs.close();
      ps.close();

      return memberId;
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
 * populates an arraylist of drop down options (with just id currently populated) with member of week entries for next 10 weeks after today
 *
 * @param options               The arraylist of drop down box options to populate
 * @param memberId              the member id of the member whose page drop down box is appearing
 * @exception ServletException  thrown if database exception
 */
  public static void populateMemberOfWeekDropDown( ArrayList options, int memberId ) throws ServletException
  {
    Connection conn = null;
    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //generate unique id for object.
      ps = conn.prepareStatement( "SELECT weekDescriptor, memberId, description FROM memberOfWeek WHERE weekDescriptor >= ? ORDER BY weekDescriptor ASC " );
      ps.setString( 1, ( (DropDownOption)options.get( 0 ) ).id );
      ResultSet rs = ps.executeQuery();
      String curentRowWeekDescriptor = "-1";

      if( rs.next() )
      {
        curentRowWeekDescriptor = rs.getString( "weekDescriptor" );
      }

      for( int i = 0; i < options.size(); i++ )
      {
        DropDownOption option = (DropDownOption)options.get( i );

        if( curentRowWeekDescriptor.equals( option.id ) )
        {
          option.desc += rs.getString( "description" );
          option.selected = ( memberId == rs.getInt( "memberId" ) );

          if( rs.next() )
          {
            curentRowWeekDescriptor = rs.getString( "weekDescriptor" );
          }
        }
        else
        {
          option.desc += "NONE SET";
        }
      }

      rs.close();
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

}