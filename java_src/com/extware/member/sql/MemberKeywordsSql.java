package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberContact;
import com.extware.member.MemberFile;
import com.extware.member.MemberJob;

import com.extware.utils.DatabaseUtils;
import com.extware.utils.EncodeUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PreparedStatementUtils;
import com.extware.utils.StringUtils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.naming.NamingException;

import javax.servlet.ServletException;

/**
 * SQL class for Member Object and it's sub-objects
 *
 * @author   John Milner
 */
public class MemberKeywordsSql
{

/**
 * this refreshed all of the MEMBER's searck kaywords in database
 *
 * @param memberId              id of member to refresh
 * @exception ServletException  thrown if database exception
 */
  public static void updateMemberSearchKeywords( int memberId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql = "SELECT mc.name, mc.city, mc.primaryCategoryRef, mc.primaryDisciplineRef, mc.secondaryCategoryRef, mc.secondaryDisciplineRef, mc.tertiaryCategoryRef, mc.tertiaryDisciplineRef, mc.countryRef, mc.regionRef, mc.countyRef, mp.keywords, mp.specialisations FROM members m LEFT OUTER JOIN memberContacts mc ON ( m.memberContactId = mc.memberContactId ) LEFT OUTER JOIN memberProfiles mp ON ( m.memberProfileId = mp.memberProfileId ) WHERE memberId = ?";

      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberId );
      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      MemberContact memberContact = null;
      String keywords = "";
      String specialisations = "";

      if( rs.next() )
      {
        memberContact = new MemberContact(
            StringUtils.nullString( rs.getString( "name" ) ),
            NumberUtils.parseInt( rs.getString( "primaryCategoryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "primaryDisciplineRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "secondaryCategoryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "secondaryDisciplineRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "tertiaryCategoryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "tertiaryDisciplineRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "countryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "regionRef" ), -1 ),
            StringUtils.nullString( rs.getString( "city" ) ),
            NumberUtils.parseInt( rs.getString( "countyRef" ), -1 )
             );

        keywords = StringUtils.nullString( rs.getString( "keywords" ) );
        specialisations = StringUtils.nullString( rs.getString( "specialisations" ) );
      }
      else
      {
        return;
      }

      rs.close();
      ps.close();

      ArrayList keywordsLst = getNormalTextFieldKeywords( EncodeUtils.HTMLUnEncode( memberContact.name ) );
      keywordsLst.addAll( getNormalTextFieldKeywords( EncodeUtils.HTMLUnEncode( memberContact.city ) ) );
      keywordsLst.addAll( getCommaSepTextFieldKeywords( EncodeUtils.HTMLUnEncode( keywords ) ) );
      keywordsLst.addAll( getCommaSepTextFieldKeywords( EncodeUtils.HTMLUnEncode( specialisations ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberContact.getPrimaryDisciplineDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberContact.getSecondaryDisciplineDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberContact.getTertiaryDisciplineDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberContact.getCountryDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberContact.getRegionDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberContact.getCountyDesc() ) ) );
      removeDuplicates( keywordsLst );

      sql = "DELETE FROM MEMBERSEARCHWORDS WHERE memberId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberId );
      ps.executeUpdate();

      sql = "INSERT INTO MEMBERSEARCHWORDS ( memberId, searchWord ) VALUES ( ?, ? )";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberId );

      for( int i = 0; i < keywordsLst.size(); i++ )
      {
        PreparedStatementUtils.setString( ps, 2, (String)keywordsLst.get( i ), 190 );
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
 * Some of the drop down values (like category and discipline0 are searched through for wach member on a keyword search. This splits a drop down description on '/' if multiple desriptions are used on one option
 *
 * @param data  drop down option description
 * @return      ArrayList of split descriptions
 */
  public static ArrayList splitComboOption( String data )
  {
    if( data == null || data.length() == 0 )
    {
      return new ArrayList();
    }

    if( data.startsWith( "*CG" ) )
    {
      data = data.substring( 3 );
    }

    String[] reply = StringUtils.split( data, "/" );
    ArrayList replyList = new ArrayList();

    for( int i = 0; i < reply.length; i++ )
    {
      replyList.add( reply[i].toUpperCase().trim() );
    }

    return replyList;
  }

/**
 * this refreshed all of the MEMBERJOB's search keywords in database
 *
 * @param memberJobId           id of memberJob whose keywords we are to update
 * @exception ServletException  thrown if database exception
 */
  public static void updateMemberJobSearchKeywords( int memberJobId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql = "SELECT mj.memberJobId, mj.referenceNo, mj.title, mj.mainCategoryRef, mj.disciplineRef, mj.typeOfWorkRef, mj.countryRef, mj.ukRegionRef, mj.countyRef, mj.city FROM memberJobs mj WHERE mj.memberJobId = ?";

      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberJobId );
      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      MemberJob memberJob = null;

      if( rs.next() )
      {
        memberJob = new MemberJob(
            rs.getInt( "memberJobId" ),
            StringUtils.nullString( rs.getString( "referenceNo" ) ),
            StringUtils.nullString( rs.getString( "title" ) ),
            NumberUtils.parseInt( rs.getString( "mainCategoryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "disciplineRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "typeOfWorkRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "countryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "ukRegionRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "countyRef" ), -1 ),
            StringUtils.nullString( rs.getString( "city" ) )
             );
      }
      else
      {
        return;
      }

      rs.close();
      ps.close();

      ArrayList keywordsLst = new ArrayList();
      keywordsLst.add( EncodeUtils.HTMLUnEncode( memberJob.referenceNo ).toUpperCase().trim() );
      keywordsLst.addAll( getNormalTextFieldKeywords( EncodeUtils.HTMLUnEncode( memberJob.title ) ) );
      keywordsLst.addAll( getNormalTextFieldKeywords( EncodeUtils.HTMLUnEncode( memberJob.city ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberJob.getMainCategoryDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberJob.getDisciplineDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberJob.getTypeOfWorkDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberJob.getCountryDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberJob.getRegionDesc() ) ) );
      keywordsLst.addAll( splitComboOption( EncodeUtils.HTMLUnEncode( memberJob.getCountyDesc() ) ) );
      removeDuplicates( keywordsLst );

      sql = "DELETE FROM MEMBERJOBSEARCHWORDS WHERE memberJobId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberJobId );
      ps.executeUpdate();

      sql = "INSERT INTO MEMBERJOBSEARCHWORDS ( memberJobId, searchWord ) VALUES ( ?, ? )";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberJobId );

      for( int i = 0; i < keywordsLst.size(); i++ )
      {
        PreparedStatementUtils.setString( ps, 2, (String)keywordsLst.get( i ), 190 );
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
 * this refreshes all of the MEMBERFILE's search keywords in database
 *
 * @param memberFileId          id of MemberFile to refresh
 * @exception ServletException  thrown if database exception
 */
  public static void updateMemberFileSearchKeywords( int memberFileId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql = "SELECT mf.keywords, mf.description, mf.displayFileName FROM memberFiles mf WHERE mf.memberFileId = ?";

      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberFileId );
      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      String keywords = null;
      String description = null;
      String displayFileName = null;

      if( rs.next() )
      {
        keywords = StringUtils.nullString( rs.getString( "keywords" ) );
        description = StringUtils.nullString( rs.getString( "description" ) );
        displayFileName = StringUtils.nullString( rs.getString( "displayFileName" ) );
      }
      else
      {
        return;
      }

      rs.close();
      ps.close();

      ArrayList keywordsLst = getCommaSepTextFieldKeywords( EncodeUtils.HTMLUnEncode( keywords ) );
      keywordsLst.addAll( getNormalTextFieldKeywords( EncodeUtils.HTMLUnEncode( description ) ) );
      keywordsLst.addAll( getNormalTextFieldKeywords( EncodeUtils.HTMLUnEncode( displayFileName ) ) );
      removeDuplicates( keywordsLst );

      sql = "DELETE FROM MEMBERFILESEARCHWORDS WHERE memberFileId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberFileId );
      ps.executeUpdate();

      sql = "INSERT INTO MEMBERFILESEARCHWORDS ( memberFileId, searchWord ) VALUES ( ?, ? )";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberFileId );

      for( int i = 0; i < keywordsLst.size(); i++ )
      {
        PreparedStatementUtils.setString( ps, 2, (String)keywordsLst.get( i ), 190 );
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
 * Creates a set of keywords for use when searching from a normal text field. A search can match the whole entered text or any of the individual words
 *
 * @param fieldVal  text field value
 * @return          arraylist or applicable field values
 */
  private static ArrayList getNormalTextFieldKeywords( String fieldVal )
  {
    ArrayList keywords = new ArrayList();
    keywords.add( formatKeyword( fieldVal ) );

    char[] fieldValArray = fieldVal.toCharArray();
    String tempKeyWd = "";

    for( int i = 0; i < fieldValArray.length; i++ )
    {
      if( Character.isLetterOrDigit( fieldValArray[i] ) || fieldValArray[i] == '-' || fieldValArray[i] == '\'' )
      {
        tempKeyWd += fieldValArray[i];
      }
      else if( tempKeyWd.length() != 0 )
      {
        keywords.add( formatKeyword( tempKeyWd ) );
        tempKeyWd = "";
      }
    }

    if( tempKeyWd.length() != 0 )
    {
      keywords.add( formatKeyword( tempKeyWd ) );
    }

    return keywords;
  }

/**
 * Object fields like keywords and specialisations are a comma seperated list of keywords. this method returns an arraylist of keyowrds for use in keyword search for this object
 *
 * @param fieldVal  comma seperated list
 * @return          an arraylist of keyowrds for use in keyword search for this object
 */
  private static ArrayList getCommaSepTextFieldKeywords( String fieldVal )
  {
    ArrayList keywords = new ArrayList();
    String[] keywordArr = StringUtils.split( fieldVal , "\\s*,\\s*" );

    for( int i = 0; i < keywordArr.length; i++ )
    {
      keywords.add( formatKeyword( keywordArr[i] ) );
    }

    return keywords;
  }

/**
 * Description of the Method
 *
 * @param fieldVal  simply formats a keyword ready to be stored in database - it makes sure it's not too long and upper cases it.
 * @return          Description of the Returned Value
 */
  private static String formatKeyword( String fieldVal )
  {
    return ( fieldVal.length() > 190 ) ? fieldVal.substring( 0, 189 ).toUpperCase() : fieldVal.toUpperCase();
  }

/**
 * Method to remove duplicates from an arraylist - no matter what object is stores in the arraylist ( i assume the object must have an equals method )
 *
 * @param arlList  arraylist of objects to de-dupe
 */
  private static void removeDuplicates( ArrayList arlList )
  {
    Set set = new HashSet();
    List newList = new ArrayList();

    for( Iterator iter = arlList.iterator(); iter.hasNext();  )
    {
      Object element = iter.next();
      if( set.add( element ) )
      {
        newList.add( element );
      }
    }

    arlList.clear();
    arlList.addAll( newList );
  }

}