package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberClient;
import com.extware.member.MemberContact;
import com.extware.member.MemberFile;
import com.extware.member.MemberJob;
import com.extware.member.MemberProfile;

import com.extware.utils.BooleanUtils;
import com.extware.utils.DatabaseUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PreparedStatementUtils;
import com.extware.utils.PropertyFile;
import com.extware.utils.StringUtils;

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
public class MemberSaveAndLoadSql
{
  private static String INSERT_MEMBERCONTACT_SQL =
      "INSERT INTO MEMBERCONTACTS ( " +
      "name, nameFirstLetter, statusRef ,statusOther ,primaryCategoryRef ,primaryDisciplineRef, secondaryCategoryRef, " +
      "secondaryDisciplineRef,  tertiaryCategoryRef, tertiaryDisciplineRef ,sizeRef ,countryRef ,regionRef, " +
      "address1 ,address2 ,city ,postcode ,countyRef ,contactTitleRef ,contactFirstName, " +
      "contactSurname ,telephone ,mobile ,fax ,webaddress ,whereDidYouHearRef, " +
      "whereDidYouHearOther ,whereDidYouHearMagazine, memberContactId " +
      ") VALUES " +
      "( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

  private static String UPDATE_MEMBERCONTACT_SQL =
      "UPDATE MEMBERCONTACTS SET " +
      "lastUpdatedDate=CURRENT_TIMESTAMP, name=?, nameFirstLetter=?, statusRef=?, statusOther=?, primaryCategoryRef=?, primaryDisciplineRef=?, secondaryCategoryRef=?, " +
      "secondaryDisciplineRef=?, tertiaryCategoryRef=?, tertiaryDisciplineRef=?, sizeRef=?, countryRef=?, regionRef=?, " +
      "address1=?, address2=?, city=?, postcode=?, countyRef=?, contactTitleRef=?, contactFirstName=?, " +
      "contactSurname=?, telephone=?, mobile=?, fax=?, webaddress=?, whereDidYouHearRef=?, " +
      "whereDidYouHearOther=?, whereDidYouHearMagazine=? " +
      "WHERE memberContactId=? ";

  private static String INSERT_MEMBERPROFILE_SQL =
      "INSERT INTO MEMBERPROFILES ( " +
      "personalStatement ,specialisations ,keywords, memberProfileId " +
      ") VALUES " +
      "( ?, ?, ?, ? )";

  private static String UPDATE_MEMBERPROFILE_SQL =
      "UPDATE MEMBERPROFILES SET " +
      "lastUpdatedDate=CURRENT_TIMESTAMP, personalStatement=?, specialisations=?, keywords=? " +
      "WHERE memberProfileId=? ";

  private static String INSERT_MEMBER_SQL =
      "INSERT INTO MEMBERS ( " +
      "memberContactId, memberProfileID, moderationMemberContactId, moderationMemberProfileId, " +
      "email, passwd, profileURL, lastPaymentDate, goLiveDate, expiryDate, onModerationHold, emailValidated, validationKey " +
      ") VALUES " +
      "( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

  private static String SELECT_ONLY_MEMBER_ONLY_SQL =
      "SELECT " +
      "m.memberId, m.memberContactId, m.memberProfileId, m.moderationMemberContactId, m.moderationMemberProfileId, m.placedAdvert, " +
      "m.email, m.passwd, m.profileURL, m.regDate, m.lastPaymentDate, m.goLiveDate, m.expiryDate, m.onModerationHold, m.wentOnHoldDate, m.emailValidated, m.validationKey ";

  private static String SELECT_FULLMEMBER_SQL =
      SELECT_ONLY_MEMBER_ONLY_SQL +
      ", " +
      "mc.lastUpdatedDate mc_lastUpdatedDate, mc.name mc_name, mc.statusRef mc_statusRef, mc.statusOther mc_statusOther, mc.primaryCategoryRef mc_primaryCategoryRef, mc.primaryDisciplineRef mc_primaryDisciplineRef, mc.secondaryCategoryRef mc_secondaryCategoryRef, " +
      "mc.secondaryDisciplineRef mc_secondaryDisciplineRef, mc.tertiaryCategoryRef mc_tertiaryCategoryRef, mc.tertiaryDisciplineRef mc_tertiaryDisciplineRef, mc.sizeRef mc_sizeRef, mc.countryRef mc_countryRef, mc.regionRef mc_regionRef, " +
      "mc.address1 mc_address1, mc.address2 mc_address2, mc.city mc_city, mc.postcode mc_postcode, mc.countyRef mc_countyRef, mc.contactTitleRef mc_contactTitleRef, mc.contactFirstName mc_contactFirstName, " +
      "mc.contactSurname mc_contactSurname, mc.telephone mc_telephone, mc.mobile mc_mobile, mc.fax mc_fax,mc.webaddress mc_webaddress, mc.whereDidYouHearRef mc_whereDidYouHearRef, " +
      "mc.whereDidYouHearOther mc_whereDidYouHearOther, mc.whereDidYouHearMagazine mc_whereDidYouHearMagazine " +
      ", " +
      "mmc.lastUpdatedDate mmc_lastUpdatedDate, mmc.name mmc_name, mmc.statusRef mmc_statusRef, mmc.statusOther mmc_statusOther, mmc.primaryCategoryRef mmc_primaryCategoryRef, mmc.primaryDisciplineRef mmc_primaryDisciplineRef, mmc.secondaryCategoryRef mmc_secondaryCategoryRef, " +
      "mmc.secondaryDisciplineRef mmc_secondaryDisciplineRef, mmc.tertiaryCategoryRef mmc_tertiaryCategoryRef, mmc.tertiaryDisciplineRef mmc_tertiaryDisciplineRef, mmc.sizeRef mmc_sizeRef, mmc.countryRef mmc_countryRef, mmc.regionRef mmc_regionRef, " +
      "mmc.address1 mmc_address1, mmc.address2 mmc_address2, mmc.city mmc_city, mmc.postcode mmc_postcode, mmc.countyRef mmc_countyRef, mmc.contactTitleRef mmc_contactTitleRef, mmc.contactFirstName mmc_contactFirstName, " +
      "mmc.contactSurname mmc_contactSurname, mmc.telephone mmc_telephone, mmc.mobile mmc_mobile, mmc.fax mmc_fax,mmc.webaddress mmc_webaddress, mmc.whereDidYouHearRef mmc_whereDidYouHearRef, " +
      "mmc.whereDidYouHearOther mmc_whereDidYouHearOther, mmc.whereDidYouHearMagazine mmc_whereDidYouHearMagazine " +
      ", " +
      "mp.lastUpdatedDate mp_lastUpdatedDate, mp.personalStatement mp_personalStatement, mp.specialisations mp_specialisations, mp.keywords mp_keywords " +
      ", " +
      "mmp.lastUpdatedDate mmp_lastUpdatedDate, mmp.personalStatement mmp_personalStatement, mmp.specialisations mmp_specialisations, mmp.keywords mmp_keywords " +
      "FROM MEMBERS m " +
      "LEFT OUTER JOIN MEMBERCONTACTS mc ON ( m.memberContactId = mc.memberContactId ) " +
      "LEFT OUTER JOIN MEMBERCONTACTS mmc ON ( m.moderationMemberContactId = mmc.memberContactId ) " +
      "LEFT OUTER JOIN MEMBERPROFILES mp ON ( m.memberProfileId = mp.memberProfileId ) " +
      "LEFT OUTER JOIN MEMBERPROFILES mmp ON ( m.moderationMemberProfileId = mmp.memberProfileId ) ";

  private static String MEMBER_SEARCH_SQL =
      "SELECT DISTINCT m.memberId, m.profileURL " +
      ", " +
      "mc.name ,mc.statusRef, mc.primaryCategoryRef ,mc.primaryDisciplineRef, mc.secondaryCategoryRef, " +
      "mc.secondaryDisciplineRef,  mc.tertiaryCategoryRef, mc.tertiaryDisciplineRef ,mc.sizeRef ,mc.countryRef ,mc.regionRef, " +
      "mc.city, mc.countyRef ,mc.contactTitleRef ,mc.contactFirstName, mc.contactSurname " +
      "FROM members m " +
      "INNER JOIN      memberContacts mc ON ( m.memberContactId = mc.memberContactId ) ";

  private static String MEMBERFILE_COLS_SQL =
      "mf.memberFileId, mf.memberId, mf.assetId, mf.description, mf.keywords, mf.displayFileName, " +
      "mf.mimeType, mf.fileByteSize, mf.isImage, mf.mainFile, mf.portraitImage, mf.forModeration, mf.uploadDate ";

  private static String SELECT_MEMBERFILE_SQL =
      "SELECT " +
      MEMBERFILE_COLS_SQL +
      "FROM MEMBERFILES mf ";

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
 * Create a new member row from member object, and assign new id to member object
 *
 * @param member                member to save
 * @exception ServletException  thrown if database exception
 */
  public static void saveNewMemberOnlyDetails( Member member ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = conn.prepareStatement( INSERT_MEMBER_SQL );
      MemberClient.setMemberOnlyValues( ps, member );

      int rows = ps.executeUpdate();

      //now retrieve info generated on save
      ps = conn.prepareStatement( "SELECT memberId, regDate FROM MEMBERS WHERE UPPER( email ) = ? AND UPPER( profileURL ) = ?" );
      ps.setString( 1, member.email.trim().toUpperCase() );
      ps.setString( 2, member.profileURL.trim().toUpperCase() );
      ResultSet rs = ps.executeQuery();

      if( rs.next() )
      {
        member.memberId = rs.getInt( "memberId" );
        member.regDate = rs.getTimestamp( "regDate" );
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

/**
 * Given an arraylist of members, this populates the memberFile ArrayList for certain members within the arrayList. The members to be populated are the members between index startIdx and index endIdx in the members arraylist.
 *
 * @param members               ArrayList of members
 * @param startIdx              start of range of index on ArrayList
 * @param endIdx                end   of range of index on ArrayList
 * @exception ServletException  thrown if database exception
 */
  public static void populateMemberFiles( ArrayList members, int startIdx, int endIdx ) throws ServletException
  {
    Connection conn = null;
    String sql = "";
    try
    {
      if( members == null || members.size() == 0 )
      {
        return;
      }

      String inList = "( ";
      Member tempMember;
      boolean firstMemberId = true;

      for( int i = startIdx; i < members.size() && i < endIdx; i++ )
      {
        tempMember = (Member)members.get( i );

        if( tempMember.memberFiles == null || tempMember.memberFiles.size() == ( 0 ) )
        {
          inList += ( firstMemberId ? "" : ", " ) + ( (Member)members.get( i ) ).memberId;
          firstMemberId = false;
        }
      }

      inList += " )";

      if( inList.equals( "(  )" ) )
      {
        return;
      }

      //create sql statement
      conn = DatabaseUtils.getDatabaseConnection();
      sql = "SELECT memberFileId, memberId, assetId, isImage, mainFile, portraitImage, mimeType FROM MEMBERFILES WHERE memberId IN " + inList + " AND forModeration='f' ORDER BY memberId ASC, portraitImage DESC, mainFile DESC, isImage DESC";
      System.out.println( sql );
      PreparedStatement ps = conn.prepareStatement( sql );
      ResultSet rs = ps.executeQuery();

      Member currentMember = null;
      int lastMemberId = -1;
      int currentMemberId;
      MemberFile tempFile;

      while( rs.next() )
      {
        currentMemberId = rs.getInt( "memberId" );

        if( currentMemberId != lastMemberId )
        {
          for( int i = startIdx; i < members.size() && i < endIdx; i++ )
          {
            if( currentMemberId == ( (Member)members.get( i ) ).memberId )
            {
              currentMember = ( (Member)members.get( i ) );
              break;
            }
          }

          lastMemberId = currentMember.memberId;
        }

        tempFile = new MemberFile( rs.getInt( "memberFileId" ), rs.getInt( "assetId" ), BooleanUtils.parseBoolean( rs.getString( "isImage" ) ), BooleanUtils.parseBoolean( rs.getString( "mainFile" ) ), BooleanUtils.parseBoolean( rs.getString( "portraitImage" ) ), rs.getString( "mimeType" ) );
        currentMember.memberFiles.add( tempFile );

        if( tempFile.mainFile )
        {
          currentMember.mainFile = tempFile;
        }

        if( tempFile.portraitImage )
        {
          currentMember.portraitImage = tempFile;
        }
      }
    }
    catch( SQLException sex )
    {
      sex.printStackTrace();
      System.out.println( sql );
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
 * Returns a list of members matching search criteria. Members are not fully populoated, just enough info to show search results is fetched
 *
 * @param statusRefIds          comma sep list of statusRefIds allowed in filter
 * @param compSizeVal           if >-1 will filter on this compSizeVal
 * @param categoryVal           if >-1 will filter on this categoryVal
 * @param disciplineVal         if >-1 will filter on this disciplineVal
 * @param countryVal            if >-1 will filter on this countryVal
 * @param regionVal             if >-1 will filter on this regionVal
 * @param countyVal             if >-1 will filter on this countyVal
 * @param keyword               if supplied, will filter on this keyword
 * @param nameFirstLetter       if supplied, will filter on this first letter of organisation name
 * @param returnAllResults      false means cut off results at 200ish( set in datadictionary), true means return up to 5000 results
 * @return                      ArrayList of members matching criteria
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList memberSearch( String statusRefIds,
      int compSizeVal, int categoryVal, int disciplineVal, int countryVal, int regionVal, int countyVal,
      String keyword, String nameFirstLetter, boolean returnAllResults ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //create sql statement
      conn = DatabaseUtils.getDatabaseConnection();
      String sqlSelect = MEMBER_SEARCH_SQL;

      if( keyword.length() != 0 )
      {
        sqlSelect += "INNER JOIN MEMBERSEARCHWORDS msw ON ( m.memberId = msw.memberId ) ";
      }

      sqlSelect += "WHERE m.expiryDate IS NOT NULL AND m.expiryDate > CURRENT_TIMESTAMP ";

      if( statusRefIds != null )
      {
        sqlSelect += "AND mc.statusRef IN ( " + statusRefIds + ") ";
      }

      ArrayList parameterVals = new ArrayList();

      if( compSizeVal != -1 )
      {
        sqlSelect += "AND mc.sizeRef = ? ";
        parameterVals.add( new Integer( compSizeVal ) );
      }

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

      if( countryVal != -1 )
      {
        sqlSelect += "AND mc.countryRef = ? ";
        parameterVals.add( new Integer( countryVal ) );
      }

      if( regionVal != -1 )
      {
        sqlSelect += "AND mc.regionRef = ? ";
        parameterVals.add( new Integer( regionVal ) );
        if( countyVal != -1 )
        {
          sqlSelect += "AND mc.countyRef = ? ";
          parameterVals.add( new Integer( countyVal ) );
        }
      }

      if( keyword.length() != 0 )
      {
        sqlSelect += "AND msw.searchword = ? ";
      }

      if( nameFirstLetter.length() != 0 )
      {
        sqlSelect += "AND mc.nameFirstLetter = ? ";
      }

      sqlSelect += " ORDER BY mc.name ASC, m.memberId DESC ";

      PreparedStatement ps = conn.prepareStatement( sqlSelect );

      int colNum = 1;

      for( int i = 0; i < parameterVals.size(); i++ )
      {
        ps.setInt( colNum++, ( (Integer)parameterVals.get( i ) ).intValue() );
      }

      if( keyword.length() != 0 )
      {
        ps.setString( colNum++, keyword );
      }

      if( nameFirstLetter.length() != 0 )
      {
        ps.setString( colNum++, nameFirstLetter );
      }

      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      PropertyFile dataDictionary = PropertyFile.getDataDictionary();
      int maxNoOfSearchResults = NumberUtils.parseInt( dataDictionary.getString( "search.maxNoOfResults" ), -1 );

      if( returnAllResults )
      {
        maxNoOfSearchResults = 5000;
      }

      ArrayList members = new ArrayList();
      Member member = null;
      int noOfFiles = 0;

      while( rs.next() )
      {
        member = new Member( rs.getInt( "memberId" ) );
        member.profileURL = StringUtils.nullString( rs.getString( "profileUrl" ) );
        noOfFiles = 0;

        member.memberContact = new MemberContact(
            rs.getString( "name" ),
            NumberUtils.parseInt( rs.getString( "statusRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "primaryCategoryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "primaryDisciplineRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "secondaryCategoryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "secondaryDisciplineRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "tertiaryCategoryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "tertiaryDisciplineRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "sizeRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "countryRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "regionRef" ), -1 ),
            rs.getString( "city" ),
            NumberUtils.parseInt( rs.getString( "countyRef" ), -1 ),
            NumberUtils.parseInt( rs.getString( "contactTitleRef" ), -1 ),
            rs.getString( "contactFirstName" ),
            rs.getString( "contactSurname" )
        );

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
 * Adds member contact object to member as 'for-moderation' and also saves in database as 'for-moderation'
 *
 * @param member                the member object to add to.
 * @param memberContact         the MemberContact object to add
 * @exception ServletException  thrown if database exception
 */
  public static void addAndSaveMemberContactForModeraion( Member member, MemberContact memberContact ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      if( member.moderationMemberContact == null )
      {
        //generate unique id and timestamp for object.
        ps = conn.prepareStatement( "SELECT id FROM genMemberContactId" );
        ResultSet rs = ps.executeQuery();

        if( rs.next() )
        {
          memberContact.memberContactId = rs.getInt( "id" );
        }

        memberContact.lastUpdatedDate = new Date();

        //save
        ps = conn.prepareStatement( INSERT_MEMBERCONTACT_SQL );
        MemberClient.setMemberContactValues( ps, memberContact );
        ps.executeUpdate();
      }
      else
      {
        ps = conn.prepareStatement( UPDATE_MEMBERCONTACT_SQL );
        MemberClient.setMemberContactValues( ps, memberContact );
        ps.executeUpdate();
      }

      //now add to original member and set the id on the member record in database
      member.moderationMemberContact = memberContact;
      MemberClient.setMemberFieldId( conn, ps, "moderationMemberContactId", member.memberId, memberContact.memberContactId );
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
 * Adds member profile object to member as 'for-moderation' and also saves in database as 'for-moderation'
 *
 * @param member                the member object to add to.
 * @param memberProfile         the MemberProfile object to add
 * @exception ServletException  thrown if database exception
 */
  public static void addAndSaveMemberProfileForModeraion( Member member, MemberProfile memberProfile ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      if( member.moderationMemberProfile == null )
      {
        //generate unique id and timestamp for object.
        ps = conn.prepareStatement( "SELECT id FROM genMemberProfileId" );
        ResultSet rs = ps.executeQuery();

        if( rs.next() )
        {
          memberProfile.memberProfileId = rs.getInt( "id" );
        }

        memberProfile.lastUpdatedDate = new Date();

        //save
        ps = conn.prepareStatement( INSERT_MEMBERPROFILE_SQL );
        MemberClient.setMemberProfileValues( ps, memberProfile );
        ps.executeUpdate();
      }
      else
      {
        ps = conn.prepareStatement( UPDATE_MEMBERPROFILE_SQL );
        MemberClient.setMemberProfileValues( ps, memberProfile );
        ps.executeUpdate();
      }

      //now add to original member and set the id on the member record in database
      member.moderationMemberProfile = memberProfile;
      MemberClient.setMemberFieldId( conn, ps, "moderationMemberProfileId", member.memberId, memberProfile.memberProfileId );
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
 * loads a series of member objects based on a set of filters and a set of things to populate onto the memebr mobject
 *
 * @param email                 email address filter
 * @param passwd                password filter
 * @param memberId              memberid filter
 * @param profileURL            profileURL filter
 * @param moderationFilter      true = for moderation members only, false = no moderation filter
 * @param registeredAfter       filter so only members registered after this date are included, null = no filter
 * @param registeredBefore      filter so only members registered before this date are included, null = no filter
 * @param expiresAfter          filter so only members who expire after this date are included, null = no filter
 * @param expiresBefore         filter so only members who expire before this date are included, null = no filter
 * @param unpaidFilter          true = only thise members who have never paid, false = no filter
 * @param addFiles              true = populate the member files arraylist
 * @param addJobs               true = populate the 2 jobs arraylists (NOTE: if addJobs and addFiles are true, then FULLY populated members will be returned)
 * @return                      arraylist of members
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList loadFullMembers( String email, String passwd, int memberId, String profileURL, boolean moderationFilter, Date registeredAfter, Date registeredBefore, Date expiresAfter, Date expiresBefore, boolean unpaidFilter, boolean addFiles, boolean addJobs ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //create sql statement
      ArrayList members = new ArrayList();
      Member member = null;
      conn = DatabaseUtils.getDatabaseConnection();
      String sqlSelect = SELECT_FULLMEMBER_SQL;
      String sqlFilter = "";
      String sqlOrder = "";
      String filterPrefix = "WHERE ";
      String orderPrefix = "ORDER BY ";

      if( email != null )
      {
        sqlFilter += filterPrefix + "UPPER(m.email)=? ";
        filterPrefix = "AND ";
      }

      if( passwd != null )
      {
        sqlFilter += filterPrefix + "UPPER(m.passwd)=? ";
        filterPrefix = "AND ";
      }

      if( memberId != -1 )
      {
        sqlFilter += filterPrefix + "m.memberId=? ";
        filterPrefix = "AND ";
      }

      if( profileURL != null )
      {
        sqlFilter += filterPrefix + "UPPER(m.profileURL)=?";
        filterPrefix = "AND ";
      }

      if( moderationFilter )
      {
        sqlFilter += filterPrefix + "( m.moderationMemberContactId IS NOT NULL OR m.moderationMemberProfileId IS NOT NULL ) ";
        sqlOrder += orderPrefix + " m.onModerationHold ASC, m.lastPaymentDate DESC";
        filterPrefix = "AND ";
        orderPrefix = ", ";
      }

      if( registeredAfter != null )
      {
        sqlFilter += filterPrefix + "regDate >= ? ";
        filterPrefix = "AND ";
      }

      if( registeredBefore != null )
      {
        sqlFilter += filterPrefix + "regDate < ? ";
        filterPrefix = "AND ";
      }

      if( unpaidFilter )
      {
        sqlFilter += filterPrefix + "lastPaymentDate IS NULL ";
        filterPrefix = "AND ";
      }

      if( expiresAfter != null )
      {
        sqlFilter += filterPrefix + "expiryDate IS NOT NULL AND expiryDate >= ? ";
        filterPrefix = "AND ";
      }

      if( expiresBefore != null )
      {
        sqlFilter += filterPrefix + "expiryDate IS NOT NULL AND expiryDate < ? ";
        filterPrefix = "AND ";
      }

      //make sure at least one filter has been applied
      if( filterPrefix.equals( "WHERE " ) )
      {
        return new ArrayList();
      }

      PreparedStatement ps = conn.prepareStatement( sqlSelect + " " + sqlFilter + " " + sqlOrder );

      int qtnMarkno = 1;

      if( email != null )
      {
        ps.setString( qtnMarkno++, email.trim().toUpperCase() );
      }

      if( passwd != null )
      {
        ps.setString( qtnMarkno++, passwd.trim().toUpperCase() );
      }

      if( memberId != -1 )
      {
        ps.setInt( qtnMarkno++, memberId );
      }

      if( profileURL != null )
      {
        ps.setString( qtnMarkno++, profileURL.trim().toUpperCase() );
      }

      if( registeredAfter != null )
      {
        PreparedStatementUtils.setDate( ps, qtnMarkno++, registeredAfter );
      }

      if( registeredBefore != null )
      {
        PreparedStatementUtils.setDate( ps, qtnMarkno++, registeredBefore );
      }

      if( expiresAfter != null )
      {
        PreparedStatementUtils.setDate( ps, qtnMarkno++, expiresAfter );
      }

      if( expiresBefore != null )
      {
        PreparedStatementUtils.setDate( ps, qtnMarkno++, expiresBefore );
      }

      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      while( rs.next() )
      {
        member = createMember( rs );

        member.memberContact = createMemberContact( rs, "memberContactId", "mc_" );
        member.moderationMemberContact = createMemberContact( rs, "moderationMemberContactId", "mmc_" );
        member.memberProfile = createMemberProfile( rs, "memberProfileId", "mp_" );
        member.moderationMemberProfile = createMemberProfile( rs, "moderationMemberProfileId", "mmp_" );

        members.add( member );
      }

      rs.close();
      ps.close();

      //now populate portfolio files
      if( addFiles && members.size() > 0 )
      {
        ps = conn.prepareStatement( SELECT_MEMBERFILE_SQL + "WHERE mf.memberId=?" );
        MemberFile temp;

        for( int i = 0; i < members.size(); i++ )
        {
          member = (Member)members.get( i );
          ps.setInt( 1, member.memberId );
          rs = ps.executeQuery();

          while( rs.next() )
          {
            temp = MemberClient.createMemberFile( rs );

            if( temp.mainFile )
            {
              member.mainFile = temp;
            }

            if( temp.portraitImage )
            {
              member.portraitImage = temp;
            }

            if( temp.forModeration )
            {
              member.moderationMemberFiles.add( temp );
            }
            else
            {
              member.memberFiles.add( temp );
            }
          }

          rs.close();
        }

        ps.close();
      }

      if( addJobs && members.size() > 0 )
      {
        //now populate jobs
        ps = conn.prepareStatement( SELECT_MEMBERJOB_SQL + "WHERE mj.memberId=? ORDER BY mj.forModeration ASC" );
        MemberJob tmpJob;
        MemberJob[] jobArray;

        for( int i = 0; i < members.size(); i++ )
        {
          member = (Member)members.get( i );

          ps.setInt( 1, member.memberId );
          rs = ps.executeQuery();

          while( rs.next() )
          {
            tmpJob = MemberClient.createMemberJob( rs, "mj_" );

            if( !tmpJob.forModeration )
            {
              // tackle all moderated jobs first

              jobArray = new MemberJob[2];
              jobArray[0] = tmpJob;
              member.memberJobs.add( jobArray );
            }
            else
            {
              if( tmpJob.moderatedJobId == -1 )
              {
                // jobs needing moderation where no moderated version exists

                jobArray = new MemberJob[2];
                jobArray[1] = tmpJob;
                member.memberJobs.add( jobArray );
              }
              else
              {
                // jobs requiring moderation where there already is a moderated version

                int jobIdx = member.getJobIndexByJobId( tmpJob.moderatedJobId );
                jobArray = (MemberJob[])member.memberJobs.get( jobIdx );
                jobArray[1] = tmpJob;
              }
            }
          }

          rs.close();
        }

        ps.close();
      }

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
 * gets fields from resultset to create a member object
 *
 * @param rs                result set containing member values
 * @return                  a member object, populates except for its sub-objects
 * @exception SQLException  thrown if database exception
 */
  public static Member createMember( ResultSet rs ) throws SQLException
  {
    Member member = new Member(
        rs.getInt( "memberid" ),
        rs.getString( "email" ),
        rs.getString( "passwd" ),
        rs.getString( "profileUrl" ),
        rs.getTimestamp( "regDate" ),
        rs.getTimestamp( "lastPaymentDate" ),
        rs.getTimestamp( "goLiveDate" ),
        rs.getTimestamp( "expiryDate" ),
        BooleanUtils.parseBoolean( rs.getString( "placedAdvert" ) ),
        BooleanUtils.parseBoolean( rs.getString( "onModerationHold" ) ),
        rs.getTimestamp( "wentOnHoldDate" ),
        BooleanUtils.parseBoolean( rs.getString( "emailValidated" ) ),
        rs.getInt( "validationKey" )
         );
    return member;
  }

/**
 * gets fields from resultset to create a MemberContact object
 *
 * @param rs                result set containing member contact values
 * @param idColumnName      the column mane of the primary key column in the result set
 * @param prefix            if there is a prefix to all the columns (apart from primary key) (like mc_lastUpdatedDate ) put the prefix (eg "mc_" ) here
 * @return                  fuly populated MemberContact object
 * @exception SQLException  thrown if database exception
 */
  public static MemberContact createMemberContact( ResultSet rs, String idColumnName, String prefix ) throws SQLException
  {
    if( rs.getString( idColumnName ) == null )
    {
      return null;
    }
    else
    {
      MemberContact memberContact = new MemberContact(
          rs.getInt( idColumnName ),
          rs.getTimestamp( prefix + "lastUpdatedDate" ),
          rs.getString( prefix + "name" ),
          NumberUtils.parseInt( rs.getString( prefix + "statusRef" ), -1 ),
          rs.getString( prefix + "statusOther" ),
          NumberUtils.parseInt( rs.getString( prefix + "primaryCategoryRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "primaryDisciplineRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "secondaryCategoryRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "secondaryDisciplineRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "tertiaryCategoryRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "tertiaryDisciplineRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "sizeRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "countryRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "regionRef" ), -1 ),
          rs.getString( prefix + "address1" ),
          rs.getString( prefix + "address2" ),
          rs.getString( prefix + "city" ),
          rs.getString( prefix + "postcode" ),
          NumberUtils.parseInt( rs.getString( prefix + "countyRef" ), -1 ),
          NumberUtils.parseInt( rs.getString( prefix + "contactTitleRef" ), -1 ),
          rs.getString( prefix + "contactFirstName" ),
          rs.getString( prefix + "contactSurname" ),
          rs.getString( prefix + "telephone" ),
          rs.getString( prefix + "mobile" ),
          rs.getString( prefix + "fax" ),
          rs.getString( prefix + "webaddress" ),
          NumberUtils.parseInt( rs.getString( prefix + "whereDidYouHearRef" ), -1 ),
          rs.getString( prefix + "whereDidYouHearOther" ),
          rs.getString( prefix + "whereDidYouHearMagazine" )
           );
      return memberContact;
    }
  }

/**
 * gets fields from resultset to create a MemberProfile object
 *
 * @param rs                result set containing member profile values
 * @param idColumnName      the column mane of the primary key column in the result set
 * @param prefix            if there is a prefix to all the columns (apart from primary key) (like mc_lastUpdatedDate ) put the prefix (eg "mc_" ) here
 * @return                  fuly populated MemberProfile object
 * @exception SQLException  thrown if database exception
 */
  public static MemberProfile createMemberProfile( ResultSet rs, String idColumnName, String prefix ) throws SQLException
  {
    if( rs.getString( idColumnName ) == null )
    {
      return null;
    }
    else
    {
      MemberProfile memberProfile = new MemberProfile(
          rs.getInt( idColumnName ),
          rs.getTimestamp( prefix + "lastUpdatedDate" ),
          rs.getString( prefix + "personalstatement" ),
          rs.getString( prefix + "specialisations" ),
          rs.getString( prefix + "keywords" )
           );
      return memberProfile;
    }
  }

}