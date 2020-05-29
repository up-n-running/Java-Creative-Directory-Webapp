package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberClient;
import com.extware.member.MemberContact;
import com.extware.member.MemberFile;

import com.extware.utils.BooleanUtils;
import com.extware.utils.DatabaseUtils;
import com.extware.utils.EncodeUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PropertyFile;
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
public class MemberFileSaveAndLoadSql
{

  private static String FILE_SEARCH_SQL =
      "SELECT DISTINCT " +
      "m.memberId, mc.name , mf.memberFileId, mf.assetId, mf.description, mf.isImage, mf.fileByteSize, mf.mimeType " +
      "FROM members m " +
      "INNER JOIN memberContacts mc ON ( m.memberContactId = mc.memberContactId ) " +
      "INNER JOIN memberFiles    mf ON ( m.memberId = mf.memberId ) ";

  private static String INSERT_MEMBERFILE_SQL =
      "INSERT INTO MEMBERFILES ( " +
      "assetId ,description ,keywords, displayFileName, mimeType, fileByteSize, " +
      "isImage, mainFile, portraitImage, forModeration, memberId, memberFileId " +
      ") VALUES " +
      "( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

/**
 * Sets the member file to be the main file and ensures all the other files attached ot that member are set as not main file. makes changes in both database and on object
 *
 * @param member                member object to update
 * @param mainFileId            id of member file to set as main
 * @exception ServletException  thrown if database exception
 */
  public static void setMainFile( Member member, int mainFileId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      ps = conn.prepareStatement( "UPDATE MEMBERFILES SET mainFile='f' WHERE memberId = ?" );
      ps.setInt( 1, member.memberId );
      ps.executeUpdate();
      ps.close();

      ps = conn.prepareStatement( "UPDATE MEMBERFILES SET mainFile='t' WHERE memberFileId = ? AND memberId = ?" );
      ps.setInt( 1, mainFileId );
      ps.setInt( 2, member.memberId );
      //not needed but acts as an extra security feature!!
      ps.executeUpdate();
      ps.close();

      //now update mainFile info on member

      if( member.mainFile != null )
      {
        member.mainFile.mainFile = false;
      }

      member.mainFile = member.getMemberFileById( mainFileId );
      member.mainFile.mainFile = true;
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
 * Returns an arraylist of member objects whose files match search criteria, only those files matching criteria are added to member objects. only required fields are populated
 *
 * @param isImage               "t" returns only images, "f" returns only non-images, null = no filter
 * @param categoryVal           if >-1 will filter on this categoryVal
 * @param disciplineVal         if >-1 will filter on this disciplineVal
 * @param keyword               matches IMAGE keywords, no filter is not set
 * @param noToReturn            max number of members to return - if <= 0 this maximum is taken from the datadictionary.
 * @param onlyMainFile          all non-main files (and members with no main files) will be filtered out.
 * @return                      an arraylist of member objects whose files match search criteria, only those files matching criteria are added to member objects. only required fields are populated
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList memberFileSearch( String isImage, int categoryVal, int disciplineVal, String keyword, int noToReturn, boolean onlyMainFile ) throws ServletException
  {
    Connection conn = null;
    try
    {
      //create sql statement
      conn = DatabaseUtils.getDatabaseConnection();
      String sqlSelect = FILE_SEARCH_SQL;

      if( keyword.length() != 0 )
      {
        sqlSelect += "INNER JOIN MEMBERFILESEARCHWORDS mfsw ON ( mf.memberFileId = mfsw.memberFileId ) ";
      }

      sqlSelect += "WHERE mf.forModeration = ? ";
      sqlSelect += "AND m.expiryDate IS NOT NULL AND m.expiryDate > CURRENT_TIMESTAMP ";

      ArrayList parameterVals = new ArrayList();

      if( categoryVal != -1 )
      {
        sqlSelect += "AND ( ( mc.primaryCategoryRef = ? ";
        parameterVals.add( new Integer( categoryVal ) );

        if( disciplineVal != -1 )
        {
          sqlSelect += "AND mc.primaryDisciplineRef = ? ";
          parameterVals.add( new Integer( disciplineVal ) );
        }

        sqlSelect += ") ";
        sqlSelect += "OR ( mc.secondaryCategoryRef = ? ";
        parameterVals.add( new Integer( categoryVal ) );

        if( disciplineVal != -1 )
        {
          sqlSelect += "AND mc.secondaryDisciplineRef = ? ";
          parameterVals.add( new Integer( disciplineVal ) );
        }

        sqlSelect += ") ";
        sqlSelect += "OR ( mc.tertiaryCategoryRef = ? ";
        parameterVals.add( new Integer( categoryVal ) );

        if( disciplineVal != -1 )
        {
          sqlSelect += "AND mc.tertiaryDisciplineRef = ? ";
          parameterVals.add( new Integer( disciplineVal ) );
        }

        sqlSelect += ") ) ";
      }

      if( isImage != null )
      {
        sqlSelect += "AND mf.isImage = ? ";
      }

      if( onlyMainFile )
      {
        sqlSelect += "AND mf.mainFile = ? ";
      }

      if( keyword.length() != 0 )
      {
        sqlSelect += "AND mfsw.searchword = ? ";
      }

      sqlSelect += " ORDER BY mf.description ASC, mf.memberFileId DESC ";

      PreparedStatement ps = conn.prepareStatement( sqlSelect );
      ps.setMaxRows( 10 );
      ps.setString( 1, "f" );
      //for moderation
      int colNum = 2;

      for( int i = 0; i < parameterVals.size(); i++ )
      {
        ps.setInt( colNum++, ( (Integer)parameterVals.get( i ) ).intValue() );
      }

      if( isImage != null )
      {
        ps.setString( colNum++, isImage );
      }

      if( onlyMainFile )
      {
        ps.setString( colNum++, "t" );
      }

      if( keyword.length() != 0 )
      {
        ps.setString( colNum++, keyword );
      }

      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      PropertyFile dataDictionary = PropertyFile.getDataDictionary();
      int maxNoOfSearchResults = ( noToReturn >0 ) ? noToReturn : NumberUtils.parseInt( dataDictionary.getString( "search.maxNoOfResults" ), -1 );
      ArrayList members = new ArrayList();
      Member member = null;
      MemberFile memberFile = null;

      while( rs.next() )
      {
        member = new Member( rs.getInt( "memberId" ) );
        member.memberContact = new MemberContact();
        member.memberContact.name = StringUtils.nullString( rs.getString( "name" ) );
        memberFile = new MemberFile(
            rs.getInt( "memberFileId" ),
            rs.getInt( "assetId" ),
            BooleanUtils.parseBoolean( rs.getString( "isImage" ) ),
            false,
            false,
            StringUtils.nullString( rs.getString( "mimeType" ) )
        );

        memberFile.fileByteSize = (long)rs.getLong( "fileByteSize" );
        memberFile.description = StringUtils.nullString( rs.getString( "description" ) );
        member.memberFiles.add( memberFile );
        members.add( member );

        if( members.size() >= maxNoOfSearchResults )
        {
          break;
        }
      }

      rs.close();
      ps.close();

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
 * Adds member file object to member as 'for-moderation' and also saves in database as 'for-moderation'
 *
 * @param member                the member object to add to.
 * @param memberFile            the MemberFile object to add
 * @exception ServletException  thrown if database exception
 */
  public static int addAndSaveMemberFileForModeraion( Member member, MemberFile memberFile ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //if it's a company logo - make sure no others are set to company logo
      if( memberFile.portraitImage )
      {
        ps = conn.prepareStatement( "UPDATE memberFiles SET portraitImage = 'f' WHERE memberid = ? " );
        ps.setInt( 1, member.memberId );
        ps.executeUpdate();
      }

      //generate unique id for object.
      ps = conn.prepareStatement( "SELECT id FROM genMemberFileId" );
      ResultSet rs = ps.executeQuery();
      if( rs.next() )
      {
        memberFile.memberFileId = rs.getInt( "id" );
      }

      //save
      ps = conn.prepareStatement( INSERT_MEMBERFILE_SQL );
      MemberClient.setMemberFileValues( ps, memberFile );
      ps.setInt( 11, member.memberId );
      ps.setInt( 12, memberFile.memberFileId );
      ps.executeUpdate();

      //now add to original member
      member.moderationMemberFiles.add( memberFile );

      return memberFile.memberFileId;
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
 * finds total no of megabyte file space used across all files for unpaid members
 *
 * @return                      total no of megabyte file space used across all files for unpaid members
 * @exception ServletException  thrown if database exception
 */
  public static int findUnpaidPortfolioFileSpaceMB() throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //generate unique id for object.
      ps = conn.prepareStatement( "SELECT SUM( mf.filebytesize ) / ( 1024 * 1024 ) FROM members M INNER JOIN memberfiles MF ON( MF.memberid = m.memberid ) WHERE m.lastpaymentdate IS NULL" );
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
 * gets fields from resultset to create a MemberFile object
 *
 * @param rs                result set containing member file values
 * @return                  fuly populated MemberFile object
 * @exception SQLException  thrown if database exception
 */
  public static MemberFile createMemberFile( ResultSet rs ) throws SQLException
  {
    MemberFile memberFile = new MemberFile(
        rs.getInt( "memberFileId" ),
        null,
    //asset
        NumberUtils.parseInt( rs.getString( "assetId" ), -1 ),
        rs.getString( "description" ),
        rs.getString( "keywords" ),
        rs.getString( "displayFileName" ),
        rs.getString( "mimeType" ),
        rs.getLong( "fileByteSize" ),
        BooleanUtils.parseBoolean( rs.getString( "isImage" ) ),
        BooleanUtils.parseBoolean( rs.getString( "mainFile" ) ),
        BooleanUtils.parseBoolean( rs.getString( "portraitImage" ) ),
        BooleanUtils.parseBoolean( rs.getString( "forModeration" ) ),
        rs.getTimestamp( "uploadDate" )
         );
    return memberFile;
  }

}