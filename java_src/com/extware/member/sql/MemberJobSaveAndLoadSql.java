package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberClient;
import com.extware.member.MemberJob;

import com.extware.utils.BooleanUtils;
import com.extware.utils.DatabaseUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PropertyFile;

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
public class MemberJobSaveAndLoadSql
{

  private static String JOB_SEARCH_SQL =
      "SELECT DISTINCT " +
      "mj.memberJobId, mj.referenceNo, mj.title, mj.salary, mj.typeOfWorkRef, mj.countryRef ,mj.ukRegionRef, " +
      "mj.telephone, mj.email, mj.contactName, mj.countyRef, mj.city, " +
      "mj.description " +
      "FROM memberJobs mj " +
      "INNER JOIN members m ON ( mj.memberId = m.memberId ) ";

  private static String INSERT_MEMBERJOB_SQL =
      "INSERT INTO MEMBERJOBS ( " +
      "referenceNo ,title, mainCategoryRef, disciplineRef, typeOfWorkRef, " +
      "salary, countryRef, ukRegionRef, countyRef, city, telephone, email, contactName, " +
      "description, forModeration, moderatedJobId, memberId, memberJobId " +
      ") VALUES " +
      "( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

  private static String UPDATE_MEMBERJOB_SQL =
      "UPDATE MEMBERJOBS SET " +
      "lastUpdatedDate = CURRENT_TIMESTAMP, referenceNo = ?,title = ?, mainCategoryRef = ?, disciplineRef = ?, typeOfWorkRef = ?, " +
      "salary = ?, countryRef = ?, ukRegionRef = ?, countyRef = ?, city = ?, telephone = ?, email = ?, contactName  = ?, " +
      "description = ?, forModeration = ?, moderatedJobId = ? " +
      "WHERE memberId = ? AND memberJobId = ? ";
  // memberid is just a check that user is updating their own job

  private static String MEMBERJOB_COLS_SQL =
      "mj.memberJobId mj_memberJobId, mj.memberId mj_memberId, mj.creationDate mj_creationDate, mj.lastUpdatedDate mj_lastUpdatedDate, " +
      "mj.referenceNo mj_referenceNo, mj.title mj_title, mj.mainCategoryRef mj_mainCategoryRef, mj.disciplineRef mj_disciplineRef, mj.typeOfWorkRef mj_typeOfWorkRef, " +
      "mj.salary mj_salary, mj.countryRef mj_countryRef, mj.ukRegionRef mj_ukRegionRef, mj.countyRef mj_countyRef, mj.city mj_city, mj.telephone mj_telephone, mj.email mj_email, mj.contactName mj_contactName, " +
      "mj.description mj_description, mj.forModeration mj_forModeration, mj.moderatedJobId mj_moderatedJobId ";

  private static String SELECT_MEMBERJOB_SQL =
      "SELECT " +
      MEMBERJOB_COLS_SQL +
      "FROM MEMBERJOBS mj ";

/**
 * Checks whether a job ref no has already been used when registering
 *
 * @param memberId              id of member whose job we are adding
 * @param referenceNo           ref no to test
 * @return                      true if already exists
 * @exception ServletException  thrown if database exception
 */
  public static boolean checkUniqueJobReference( int memberId, String referenceNo ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = conn.prepareStatement( "SELECT memberJobId FROM MEMBERJOBS WHERE memberId = ? AND UPPER( referenceNo ) = ?" );
      ps.setInt( 1, memberId );
      ps.setString( 2, referenceNo.trim().toUpperCase() );
      ResultSet rs = ps.executeQuery();

      if( rs.next() )
      {
        rs.close();
        ps.close();
        return false;
      }

      rs.close();
      ps.close();

      return true;
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
 * Adds member job object to member as 'for-moderation' and also saves in database as 'for-moderation'
 *
 * @param member                the member object to add to.
 * @param memberJob         the MemberJob object to add
 * @exception ServletException  thrown if database exception
 */
  public static int addAndSaveMemberJobForModeraion( Member member, MemberJob memberJob ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //find existing job data
      MemberJob[] jobArray = null;

      if( memberJob.memberJobId != -1 )
      {
        int jobIdx = member.getJobIndexByJobId( memberJob.memberJobId );
        jobArray = (MemberJob[])( member.memberJobs.get( jobIdx ) );
      }

      if( memberJob.memberJobId == -1 || jobArray[1] == null )
      {
        //adding

        //generate unique id and date stamp for object.
        ps = conn.prepareStatement( "SELECT id FROM genMemberJobId" );
        ResultSet rs = ps.executeQuery();

        if( rs.next() )
        {
          if( memberJob.memberJobId == -1 )
          {
            memberJob.creationDate = new Date();
          }
          else
          {
            memberJob.creationDate = jobArray[0].creationDate;
          }
          memberJob.moderatedJobId = memberJob.memberJobId;
          memberJob.memberJobId = rs.getInt( "id" );
          memberJob.lastUpdatedDate = new Date();
        }

        rs.close();

        //save
        ps = conn.prepareStatement( INSERT_MEMBERJOB_SQL );
        MemberClient.setMemberJobValues( ps, memberJob );
        ps.setInt( 17, member.memberId );
        ps.setInt( 18, memberJob.memberJobId );
        ps.executeUpdate();

        //now add to original member
        MemberJob[] job = new MemberJob[2];
        job[1] = memberJob;
        member.memberJobs.add( job );

        ps.close();
      }
      else
      {
        //update pointer to the moderated record if there is one
        if( jobArray[0] != null )
        {
          memberJob.moderatedJobId = jobArray[0].memberJobId;
        }

        ps = conn.prepareStatement( UPDATE_MEMBERJOB_SQL );
        MemberClient.setMemberJobValues( ps, memberJob );
        ps.setInt( 17, member.memberId );
        ps.setInt( 18, memberJob.memberJobId );
        ps.executeUpdate();

        //update object
        jobArray[1] = memberJob;
      }

      return memberJob.memberJobId;
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
 * Deletes a member job from member object and removes from database
 *
 * @param member                member holding member job object
 * @param memberJobId           id of job to delete
 * @exception ServletException  thrown if database exception
 */
  public static void deleteMemberJob( Member member, int memberJobId ) throws ServletException
  {
    Connection conn = null;
    try
    {
      //find member job on member (both moderated and not)
      int jobIdx = member.getJobIndexByJobId( memberJobId );

      //if job found (this can be not found if refreshing page after delete etc)
      if( jobIdx != -1 )
      {
        MemberJob[] jobArray = (MemberJob[])( member.memberJobs.get( jobIdx ) );

        //add or update the record in the database
        conn = DatabaseUtils.getDatabaseConnection();
        PreparedStatement ps = null;

        //delete both jobs
        String sql = "DELETE FROM MEMBERJOBS ";
        String filterPrefix = "WHERE ";

        if( jobArray[1] != null )
        {
          sql += filterPrefix + "memberJobId = ? ";
          filterPrefix = "OR ";
        }

        if( jobArray[0] != null )
        {
          sql += filterPrefix + "memberJobId = ? ";
          filterPrefix = "OR ";
        }

        //generate unique id and date stamp for object.
        ps = conn.prepareStatement( sql );
        int qnMarkNo = 1;

        if( jobArray[1] != null )
        {
          ps.setInt( qnMarkNo++, jobArray[1].memberJobId );
        }

        if( jobArray[0] != null )
        {
          ps.setInt( qnMarkNo++, jobArray[0].memberJobId );
        }

        ps.executeUpdate();

        //now delete from member object
        member.memberJobs.remove( jobIdx );

        ps.close();

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
 * gets fields from resultset to create a MemberJob object
 *
 * @param rs                result set containing member job values
 * @param prefix            if there is a prefix to all the columns (including primary key) (like mc_lastUpdatedDate ) put the prefix (eg "mc_" ) here. else put "" here
 * @return                  fuly populated MemberJob object
 * @exception SQLException  thrown if database exception
 */
  public static MemberJob createMemberJob( ResultSet rs, String prefix ) throws SQLException
  {
    MemberJob memberJob = new MemberJob(
        rs.getInt( prefix + "memberJobId" ),
        rs.getTimestamp( prefix + "creationDate" ),
        rs.getTimestamp( prefix + "lastUpdatedDate" ),
        rs.getString( prefix + "referenceNo" ),
        rs.getString( prefix + "title" ),
        NumberUtils.parseInt( rs.getString( prefix + "mainCategoryRef" ), -1 ),
        NumberUtils.parseInt( rs.getString( prefix + "disciplineRef" ), -1 ),
        NumberUtils.parseInt( rs.getString( prefix + "typeOfWorkRef" ), -1 ),
        rs.getString( prefix + "salary" ),
        NumberUtils.parseInt( rs.getString( prefix + "countryRef" ), -1 ),
        NumberUtils.parseInt( rs.getString( prefix + "ukRegionRef" ), -1 ),
        NumberUtils.parseInt( rs.getString( prefix + "countyRef" ), -1 ),
        rs.getString( prefix + "city" ),
        rs.getString( prefix + "telephone" ),
        rs.getString( prefix + "email" ),
        rs.getString( prefix + "contactName" ),
        rs.getString( prefix + "description" ),
        BooleanUtils.parseBoolean( rs.getString( prefix + "forModeration" ) ),
        NumberUtils.parseInt( rs.getString( prefix + "moderatedJobId" ), -1 )
         );
    return memberJob;
  }

/**
 * Returns a list of MemberJob objects matching search criteria.
 *
 * @param jobTypeVal            if >-1 will filter on this jobTypeVal
 * @param categoryVal           if >-1 will filter on this categoryVal
 * @param disciplineVal         if >-1 will filter on this disciplineVal
 * @param countryVal            if >-1 will filter on this countryVal
 * @param regionVal             if >-1 will filter on this regionVal
 * @param countyVal             if >-1 will filter on this countyVal
 * @param keyword               if supplied, will filter on this keyword
 * @return                      ArrayList of members matching criteria
 * @exception ServletException  thrown if database exception
 */

  public static ArrayList memberJobSearch( int jobTypeVal, int categoryVal, int disciplineVal, int countryVal, int regionVal, int countyVal, String keyword ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //create sql statement
      conn = DatabaseUtils.getDatabaseConnection();
      String sqlSelect = JOB_SEARCH_SQL;

      if( keyword.length() != 0 )
      {
        sqlSelect += "INNER JOIN MEMBERJOBSEARCHWORDS mjsw ON ( mj.memberJobId = mjsw.memberJobId ) ";
      }

      sqlSelect += "AND mj.forModeration = ? ";
      sqlSelect += "AND m.expiryDate IS NOT NULL AND m.expiryDate > CURRENT_TIMESTAMP ";

      ArrayList parameterVals = new ArrayList();

      if( jobTypeVal != -1 )
      {
        sqlSelect += "AND mj.typeOfWorkRef = ? ";
        parameterVals.add( new Integer( jobTypeVal ) );
      }

      if( categoryVal != -1 )
      {
        sqlSelect += "AND mj.mainCategoryRef = ? ";
        parameterVals.add( new Integer( categoryVal ) );

        if( disciplineVal != -1 )
        {
          sqlSelect += "AND mj.disciplineRef = ? ";
          parameterVals.add( new Integer( disciplineVal ) );
        }
      }

      if( countryVal != -1 )
      {
        sqlSelect += "AND mj.countryRef = ? ";
        parameterVals.add( new Integer( countryVal ) );
      }

      if( regionVal != -1 )
      {
        sqlSelect += "AND mj.ukRegionRef = ? ";
        parameterVals.add( new Integer( regionVal ) );

        if( countyVal != -1 )
        {
          sqlSelect += "AND mj.countyRef = ? ";
          parameterVals.add( new Integer( countyVal ) );
        }
      }

      if( keyword.length() != 0 )
      {
        sqlSelect += "AND mjsw.searchword = ? ";
      }

      sqlSelect += " ORDER BY mj.title ASC, mj.memberJobId DESC ";
      //, mf.portraitImage DESC, mf.mainFile DESC, mf.isImage DESC, mf.uploadDate DESC";
      PreparedStatement ps = conn.prepareStatement( sqlSelect );
      ps.setString( 1, "f" );
      //for moderation
      int colNum = 2;

      for( int i = 0; i < parameterVals.size(); i++ )
      {
        ps.setInt( colNum++, ( (Integer)parameterVals.get( i ) ).intValue() );
      }

      if( keyword.length() != 0 )
      {
        ps.setString( colNum++, keyword );
      }

      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      PropertyFile dataDictionary = PropertyFile.getDataDictionary();
      int maxNoOfSearchResults = NumberUtils.parseInt( dataDictionary.getString( "search.jobs.maxNoOfResults" ), -1 );
      ArrayList memberJobs = new ArrayList();
      MemberJob memberJob = null;

      while( rs.next() )
      {
        memberJob = new MemberJob(
            rs.getInt( "memberJobId" ),
            rs.getString( "referenceNo" ),
            rs.getString( "title" ),
            NumberUtils.parseInt( rs.getString( "typeOfWorkRef" ), -1 ),
            rs.getString( "salary" ),
            NumberUtils.parseInt( rs.getString( "countryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "ukRegionRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "countyRef" ), -1 ),
            rs.getString( "city" ),
            rs.getString( "telephone" ),
            rs.getString( "email" ),
            rs.getString( "contactName" ),
            rs.getString( "description" )
             );

        memberJobs.add( memberJob );

        if( memberJobs.size() >= maxNoOfSearchResults )
        {
          break;
        }
      }

      rs.close();
      ps.close();

      return memberJobs;
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
 * Creates a MemberJob Object form a memberjob table row
 *
 * @param memberJobId           id of row
 * @return                      MemberJob Object representing row
 * @exception ServletException  thrown if database exception
 */
  public static MemberJob getMemberJob( int memberJobId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql = SELECT_MEMBERJOB_SQL + "WHERE memberJobId = ?";

      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberJobId );

      ResultSet rs = ps.executeQuery();

      MemberJob memberJob = null;

      if( rs.next() )
      {
        memberJob = MemberClient.createMemberJob( rs, "mj_" );
      }

      memberJob.memberId = rs.getInt( "mj_memberId" );

      rs.close();
      ps.close();

      return memberJob;
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