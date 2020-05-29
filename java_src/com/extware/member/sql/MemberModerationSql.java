package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberClient;

import com.extware.utils.DatabaseUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PreparedStatementUtils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.Date;

import javax.naming.NamingException;

import javax.servlet.ServletException;

/**
 * SQL class for Member Object and it's sub-objects
 *
 * @author   John Milner
 */
public class MemberModerationSql
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

  private static String UPDATE_MEMBER_SQL =
      "UPDATE MEMBERS SET " +
      "passwd=?, profileURL=?, email=? ";
  //none of the other fields are allowed to change.

  private static String SELECT_ONLY_MEMBER_ONLY_SQL =
      "SELECT " +
      "m.memberId, m.memberContactId, m.memberProfileId, m.moderationMemberContactId, m.moderationMemberProfileId, m.placedAdvert, " +
      "m.email, m.passwd, m.profileURL, m.regDate, m.lastPaymentDate, m.goLiveDate, m.expiryDate, m.onModerationHold, m.wentOnHoldDate, m.emailValidated, m.validationKey ";

  private static String FROM_ONLY_MEMBER_ONLY_SQL =
      "FROM MEMBERS m ";

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

  private static String JOB_SEARCH_SQL =
      "SELECT DISTINCT " +
      "mj.memberJobId, mj.referenceNo, mj.title, mj.salary, mj.typeOfWorkRef, mj.countryRef ,mj.ukRegionRef, " +
      "mj.telephone, mj.email, mj.contactName, mj.countyRef, mj.city, " +
      "mj.description " +
      "FROM memberJobs mj " +
      "INNER JOIN members m ON ( mj.memberId = m.memberId ) ";

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

  private static String MEMBERFILE_COLS_SQL =
      "mf.memberFileId, mf.memberId, mf.assetId, mf.description, mf.keywords, mf.displayFileName, " +
      "mf.mimeType, mf.fileByteSize, mf.isImage, mf.mainFile, mf.portraitImage, mf.forModeration, mf.uploadDate ";

  private static String SELECT_MEMBERFILE_SQL =
      "SELECT " +
      MEMBERFILE_COLS_SQL +
      "FROM MEMBERFILES mf ";

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
 * Updates database only to reflect an object being on hold being on hold
 *
 * @param tableName             name of table containg object to put on hold
 * @param idFieldName           mane of primary key column on that table
 * @param id                    id of row to update
 * @param onHold                true = mark as on hold, false = take off hold (onholddate gets set by a trigger)
 * @exception ServletException  thrown if database exception
 */
  public static void putOnHold( String tableName, String idFieldName, int id, boolean onHold ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = null;
      String sql = "UPDATE " + tableName + " SET onModerationHold = '" + ( onHold ? "t" : "f" ) + "' WHERE " + idFieldName + " = " + id;
      ps = conn.prepareStatement( sql );

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
 * updates database to reflect the fact that a member has failed moderation (if this member is unpaid and has never passed moderation before - all of his details will be deleted)
 *
 * @param memberId              id of member to fail.
 * @exception ServletException  thrown if database exception
 */
  public static void moderateFailMemberDetails( int memberId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //fetch member details
      String sql = "SELECT memberContactId, memberProfileId, moderationMemberContactId, moderationMemberProfileId, lastPaymentDate FROM MEMBERS WHERE memberId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberId );

      ResultSet rs = ps.executeQuery();

      int oldModerationMemberContactId = -1;
      int oldModerationMemberProfileId = -1;
      int oldMemberContactId = -1;
      int oldMemberProfileId = -1;
      Date lastPaymentDate = null;

      if( rs.next() )
      {
        oldMemberContactId = NumberUtils.parseInt( rs.getString( "memberContactId" ), -1 );
        oldModerationMemberContactId = NumberUtils.parseInt( rs.getString( "moderationMemberContactId" ), -1 );
        oldMemberProfileId = NumberUtils.parseInt( rs.getString( "memberProfileId" ), -1 );
        oldModerationMemberProfileId = NumberUtils.parseInt( rs.getString( "moderationMemberProfileId" ), -1 );
        lastPaymentDate = rs.getTimestamp( "lastPaymentDate" );
      }
      else
      {
        return;
      }

      //if the user has never been moderated and had not paid, then failing this user will result in their demise

      if( lastPaymentDate == null && oldMemberContactId == -1 && oldMemberProfileId == -1 )
      {
        sql = "DELETE FROM MEMBERS WHERE memberId = ?";
        ps = conn.prepareStatement( sql );
        PreparedStatementUtils.setInt( ps, 1, memberId );
      }
      else
      {
        //now we must stamp on the moderated data
        sql = "UPDATE MEMBERS SET moderationMemberContactId = ?, moderationMemberProfileId = ?, " +
            " onModerationHold = ? WHERE memberId = ?";

        ps = conn.prepareStatement( sql );
        PreparedStatementUtils.setInt( ps, 1, -1 );
        PreparedStatementUtils.setInt( ps, 2, -1 );
        PreparedStatementUtils.setString( ps, 3, false );
        PreparedStatementUtils.setInt( ps, 4, memberId );
      }

      ps.executeUpdate();
      ps.close();

      //now clean up and stray member contacts and member profiles now that are no longer linked to
      if( oldModerationMemberContactId != -1 )
      {
        ps = conn.prepareStatement( "DELETE FROM MEMBERCONTACTS WHERE memberContactId = ?" );
        ps.setInt( 1, oldModerationMemberContactId );
        ps.executeUpdate();
        ps.close();
      }

      if( oldModerationMemberProfileId != -1 )
      {
        ps = conn.prepareStatement( "DELETE FROM MEMBERPROFILES WHERE memberProfileId = ?" );
        ps.setInt( 1, oldModerationMemberProfileId );
        ps.executeUpdate();
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
 * updates database to reflect the fact that a member has passed moderation
 *
 * @param memberId              id of member to pass.
 * @exception ServletException  thrown if database exception
 */
  public static void moderatePassMemberDetails( int memberId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;
      String sql = SELECT_ONLY_MEMBER_ONLY_SQL + ", CURRENT_TIMESTAMP now " + FROM_ONLY_MEMBER_ONLY_SQL + "WHERE memberId = ?";
      ps = conn.prepareStatement( sql );
      ps.setInt( 1, memberId );
      ResultSet rs = ps.executeQuery();

      //now retrieve member object/s
      Member member = null;
      int oldMemberContactId = -1;
      int oldModerationMemberContactId = -1;
      int oldMemberProfileId = -1;
      int oldModerationMemberProfileId = -1;
      Date now = null;

      if( rs.next() )
      {
        member = MemberClient.createMember( rs );
        oldMemberContactId = NumberUtils.parseInt( rs.getString( "memberContactId" ), -1 );
        oldModerationMemberContactId = NumberUtils.parseInt( rs.getString( "moderationMemberContactId" ), -1 );
        oldMemberProfileId = NumberUtils.parseInt( rs.getString( "memberProfileId" ), -1 );
        oldModerationMemberProfileId = NumberUtils.parseInt( rs.getString( "moderationMemberProfileId" ), -1 );
        now = rs.getTimestamp( "now" );
      }
      else
      {
        return;
      }

      rs.close();
      ps.close();

      //set new ids
      int newMemberContactId = oldMemberContactId;
      int newModerationMemberContactId = oldModerationMemberContactId;
      int newMemberProfileId = oldMemberProfileId;
      int newModerationMemberProfileId = oldModerationMemberProfileId;

      if( oldModerationMemberContactId != -1 )
      {
        newMemberContactId = oldModerationMemberContactId;
        newModerationMemberContactId = -1;
      }

      if( oldModerationMemberProfileId != -1 )
      {
        newMemberProfileId = oldModerationMemberProfileId;
        newModerationMemberProfileId = -1;
      }

      //if the user had paid and this is the first moderation, then they should go live!
      if( member.lastPaymentDate != null && member.goLiveDate == null && newMemberContactId != -1 && newMemberProfileId != -1 )
      {
        member.expiryDate = new java.sql.Timestamp( now.getTime() + MemberClient.getMembershipDurationInMillis() );
        member.goLiveDate = now;
      }

      //now we must set all of the new values
      sql = "UPDATE MEMBERS SET memberContactId = ?, moderationMemberContactId = ?, memberProfileId = ?, moderationMemberProfileId = ?, " +
          " goLiveDate = ?, expiryDate = ?, onModerationHold = ? WHERE memberId = ?";
      ps = conn.prepareStatement( sql );
      PreparedStatementUtils.setInt( ps, 1, newMemberContactId );
      PreparedStatementUtils.setInt( ps, 2, newModerationMemberContactId );
      PreparedStatementUtils.setInt( ps, 3, newMemberProfileId );
      PreparedStatementUtils.setInt( ps, 4, newModerationMemberProfileId );
      PreparedStatementUtils.setDate( ps, 5, member.goLiveDate );
      PreparedStatementUtils.setDate( ps, 6, member.expiryDate );
      PreparedStatementUtils.setString( ps, 7, false );
      PreparedStatementUtils.setInt( ps, 8, memberId );
      ps.executeUpdate();
      ps.close();

      //now clean up and stray member contacts and member profiles that are no longer linked to
      if( oldMemberContactId != -1 && oldMemberContactId != newMemberContactId )
      {
        ps = conn.prepareStatement( "DELETE FROM MEMBERCONTACTS WHERE memberContactId = ?" );
        ps.setInt( 1, oldMemberContactId );
        ps.executeUpdate();
        ps.close();
      }

      if( oldMemberProfileId != -1 && oldMemberProfileId != newMemberProfileId )
      {
        ps = conn.prepareStatement( "DELETE FROM MEMBERPROFILES WHERE memberProfileId = ?" );
        ps.setInt( 1, oldMemberProfileId );
        ps.executeUpdate();
        ps.close();
      }

      MemberClient.updateMemberSearchKeywords( memberId );
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