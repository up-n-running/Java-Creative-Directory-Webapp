package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberClient;
import com.extware.member.MemberJob;

import com.extware.utils.DatabaseUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.StringUtils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;

import javax.naming.NamingException;

import javax.servlet.ServletException;

/**
 * SQL class for Member Object and it's sub-objects
 *
 * @author   John Milner
 */
public class MemberJobModerationSql
{

  private static String MEMBERJOB_COLS_SQL =
      "mj.memberJobId mj_memberJobId, mj.memberId mj_memberId, mj.creationDate mj_creationDate, mj.lastUpdatedDate mj_lastUpdatedDate, " +
      "mj.referenceNo mj_referenceNo, mj.title mj_title, mj.mainCategoryRef mj_mainCategoryRef, mj.disciplineRef mj_disciplineRef, mj.typeOfWorkRef mj_typeOfWorkRef, " +
      "mj.salary mj_salary, mj.countryRef mj_countryRef, mj.ukRegionRef mj_ukRegionRef, mj.countyRef mj_countyRef, mj.city mj_city, mj.telephone mj_telephone, mj.email mj_email, mj.contactName mj_contactName, " +
      "mj.description mj_description, mj.forModeration mj_forModeration, mj.moderatedJobId mj_moderatedJobId ";

  private static String SELECT_ONLY_MEMBER_ONLY_SQL =
      "SELECT " +
      "m.memberId, m.memberContactId, m.memberProfileId, m.moderationMemberContactId, m.moderationMemberProfileId, m.placedAdvert, " +
      "m.email, m.passwd, m.profileURL, m.regDate, m.lastPaymentDate, m.goLiveDate, m.expiryDate, m.onModerationHold, m.wentOnHoldDate, m.emailValidated, m.validationKey ";

/**
 * Gets the Jobs For Moderation Ordered roughly correctly to be displayed on the job moderation report
 *
 * @return                      nearly sorted list of members, with each member having a sorted list of jobs, for all non-moderated memebr jobs
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList getJobsForModeration() throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql =
          SELECT_ONLY_MEMBER_ONLY_SQL + ", " +
          StringUtils.replace( StringUtils.replace( MEMBERJOB_COLS_SQL, "mj\\.", "mmj." ), "mj_", "mmj_" ) + ", " +
          MEMBERJOB_COLS_SQL +
          "FROM MEMBERS m " +
          "INNER JOIN MEMBERJOBS mmj ON ( m.memberId = mmj.memberId AND mmj.forModeration = 't' ) " +
          "LEFT OUTER JOIN MEMBERJOBS mj ON ( mmj.moderatedJobId = mj.memberJobId ) " +
          "ORDER BY m.onModerationHold ASC, m.lastPaymentDate DESC, m.memberId ASC, mmj.lastUpdatedDate DESC";
      //order by the members first, then get the jobs in order, we split them into new and existing in the java code below

      ps = conn.prepareStatement( sql );

      ResultSet rs = ps.executeQuery();

      Member member = null;
      ArrayList members = new ArrayList();
      ArrayList jobsNotLive = null;
      ArrayList jobsLive = null;
      MemberJob[] tmpJobArray = null;

      while( rs.next() )
      {
        if( member != null && member.memberId != rs.getInt( "memberId" ) )
        {
          jobsNotLive.addAll( jobsLive );
          member.memberJobs = jobsNotLive;
        }

        if( member == null || member.memberId != rs.getInt( "memberId" ) )
        {
          //new pointer gets created here.
          member = MemberClient.createMember( rs );
          members.add( member );
          jobsNotLive = new ArrayList();
          jobsLive = new ArrayList();
        }

        //now add jobs to jobs array
        tmpJobArray = new MemberJob[2];
        tmpJobArray[1] = MemberClient.createMemberJob( rs, "mmj_" );

        if( rs.getString( "mj_memberJobId" ) != null )
        {
          tmpJobArray[0] = MemberClient.createMemberJob( rs, "mj_" );
          jobsLive.add( tmpJobArray );
        }
        else
        {
          tmpJobArray[0] = null;
          jobsNotLive.add( tmpJobArray );
        }
      }

      if( member != null )
      {
        //complete last member object if there was one
        jobsNotLive.addAll( jobsLive );
        member.memberJobs = jobsNotLive;
      }

      //return nearly sorted list of members, with each member having a sorted list of jobs, phew!
      return members;
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
 * updates database to reflect the fact that a MemberJob has passed moderation
 *
 * @param memberJobId           id of member job to pass.
 * @exception ServletException  thrown if database exception
 */
  public static void moderatePassMemberJob( int memberJobId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //find one to delete
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql = "SELECT moderatedJobId FROM MEMBERJOBS WHERE memberJobId = ?";
      ps = conn.prepareStatement( sql );

      ps.setInt( 1, memberJobId );

      ResultSet rs = ps.executeQuery();

      int moderatedJobId = -1;

      if( rs.next() )
      {
        moderatedJobId = NumberUtils.parseInt( rs.getString( "moderatedJobId" ), -1 );
      }

      //change status of moderated one we're about to delete to protect unique contraint from gettin all arsey
      sql = "UPDATE MEMBERJOBS SET forModeration='D' WHERE memberJobId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, moderatedJobId );
      ps.executeUpdate();

      //change status of unmoderated one to set it as moderated
      sql = "UPDATE MEMBERJOBS SET forModeration='f' WHERE memberJobId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberJobId );
      ps.executeUpdate();

      //now kill the original
      sql = "DELETE FROM MEMBERJOBS WHERE memberJobId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, moderatedJobId );
      ps.executeUpdate();

      MemberClient.updateMemberJobSearchKeywords( memberJobId );
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
 * updates database to reflect the fact that a MemberJob has failed moderation
 *
 * @param memberJobId           id of member job to fail.
 * @exception ServletException  thrown if database exception
 */
  public static void moderateFailMemberJob( int memberJobId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //find one to delete
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = null;
      String sql = "DELETE FROM MEMBERJOBS WHERE forModeration='t' AND memberJobId = ?";
      //the formoderation bit is just a security check and could be taken out in theory without changing the apps functionality
      ps = conn.prepareStatement( sql );

      ps.setInt( 1, memberJobId );

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

}