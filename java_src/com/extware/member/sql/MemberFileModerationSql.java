package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberClient;
import com.extware.member.MemberFile;

import com.extware.utils.DatabaseUtils;

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
public class MemberFileModerationSql
{

  private static String MEMBERFILE_COLS_SQL =
      "mf.memberFileId, mf.memberId, mf.assetId, mf.description, mf.keywords, mf.displayFileName, " +
      "mf.mimeType, mf.fileByteSize, mf.isImage, mf.mainFile, mf.portraitImage, mf.forModeration, mf.uploadDate ";

  private static String SELECT_ONLY_MEMBER_ONLY_SQL =
      "SELECT " +
      "m.memberId, m.memberContactId, m.memberProfileId, m.moderationMemberContactId, m.moderationMemberProfileId, m.placedAdvert, " +
      "m.email, m.passwd, m.profileURL, m.regDate, m.lastPaymentDate, m.goLiveDate, m.expiryDate, m.onModerationHold, m.wentOnHoldDate, m.emailValidated, m.validationKey ";

/**
 * Gets the files For Moderation Ordered roughly correctly to be displayed on the file moderation report
 *
 * @return                      nearly sorted list of members, with each member having a sorted list of files, for all non-moderated memebr files
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList getFilesForModeration() throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql =
          SELECT_ONLY_MEMBER_ONLY_SQL + ", " +
          MEMBERFILE_COLS_SQL +
          "FROM MEMBERS m " +
          "INNER JOIN MEMBERFILES mf ON ( m.memberId = mf.memberId AND mf.forModeration = 't' ) " +
          "ORDER BY m.onModerationHold ASC, m.lastPaymentDate DESC, m.memberId ASC, mf.uploadDate DESC";
      //order by the members first, then get the files in order

      ps = conn.prepareStatement( sql );

      ResultSet rs = ps.executeQuery();

      Member member = null;
      ArrayList members = new ArrayList();
      ArrayList modMemberFiles = new ArrayList();

      while( rs.next() )
      {
        if( member != null && member.memberId != rs.getInt( "memberId" ) )
        {
          member.moderationMemberFiles = modMemberFiles;
        }

        if( member == null || member.memberId != rs.getInt( "memberId" ) )
        {
          //new pointer gets created here.
          member = MemberClient.createMember( rs );
          members.add( member );
          modMemberFiles = new ArrayList();
        }

        modMemberFiles.add( MemberClient.createMemberFile( rs ) );
      }

      //complete last member object (if there were any)
      if( member != null )
      {
        member.moderationMemberFiles = modMemberFiles;
      }

      //return nearly sorted list of members, with each member having a sorted list of files, phew!

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
 * updates database to reflect the fact that a MemberFile has passed moderation
 *
 * @param memberFileId          if of member file
 * @exception ServletException  thrown if database exception
 */
  public static void moderatePassMemberFile( int memberFileId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //setup
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //change status of unmoderated one to set it as moderated
      String sql = "UPDATE MEMBERFILES SET forModeration='f' WHERE memberFileId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberFileId );
      ps.executeUpdate();

      MemberClient.updateMemberFileSearchKeywords( memberFileId );
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