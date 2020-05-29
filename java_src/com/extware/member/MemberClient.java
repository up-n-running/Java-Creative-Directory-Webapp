package com.extware.member;

import com.extware.member.sql.MemberAdminSql;
import com.extware.member.sql.MemberFileModerationSql;
import com.extware.member.sql.MemberFileSaveAndLoadSql;
import com.extware.member.sql.MemberJobModerationSql;
import com.extware.member.sql.MemberJobSaveAndLoadSql;
import com.extware.member.sql.MemberKeywordsSql;
import com.extware.member.sql.MemberModerationSql;
import com.extware.member.sql.MemberOfWeekSql;
import com.extware.member.sql.MemberSaveAndLoadSql;

import com.extware.utils.PropertyFile;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Date;

import javax.servlet.ServletException;

/**
 * SQL client class for Member Object and it's sub-objects
 *
 * @author   John Milner
 */
public class MemberClient
{

/**
 * Constructor for the MemberClient object
 */
  public MemberClient()
  {
  }

/**
 * sets member as having paid on object and in database. if member is already moderated then set go live and expiry dates
 *
 * @param memberId              id of member to update
 * @param loggedInMember        member object to update
 * @exception ServletException  thrown if database exception
 */
  public static void setMemberAsPaid( int memberId, Member loggedInMember ) throws ServletException
  {
    MemberAdminSql.setMemberAsPaid( memberId, loggedInMember );
  }

/**
 * Sets the member file to be the main file and ensures all the other files attached ot that member are set as not main file. makes changes in both database and on object
 *
 * @param member                member object to update
 * @param mainFileId            id of member file to set as main
 * @exception ServletException  thrown if database exception
 */
  public static void setMainFile( Member member, int mainFileId ) throws ServletException
  {
    MemberFileSaveAndLoadSql.setMainFile( member, mainFileId );
  }

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
    MemberOfWeekSql.setMemberOfWeek( memberWeek, memberId, description );
  }

/**
 * Utility method to set member values taken from member object onto a prepared statement.
 *
 * @param ps                the prepared statement onto which we are setting the values
 * @param member            member whose values we are setting
 * @exception SQLException  thrown if database exception
 */
  public static void setMemberOnlyValues( PreparedStatement ps, Member member ) throws SQLException
  {
    MemberAdminSql.setMemberOnlyValues( ps, member );
  }

/**
 * Utility method to set Member Contact values taken from MemberContact object onto a prepared statement.
 *
 * @param ps                the prepared statement onto which we are setting the values
 * @param memberContact     MemberContact whose values we are setting
 * @exception SQLException  thrown if database exception
 */
  public static void setMemberContactValues( PreparedStatement ps, MemberContact memberContact ) throws SQLException
  {
    MemberAdminSql.setMemberContactValues( ps, memberContact );
  }


/**
 * Utility method to set Member Profile values taken from MemberProfile object onto a prepared statement.
 *
 * @param ps                the prepared statement onto which we are setting the values
 * @param memberProfile     MemberProfile whose values we are setting
 * @exception SQLException  thrown if database exception
 */
  public static void setMemberProfileValues( PreparedStatement ps, MemberProfile memberProfile ) throws SQLException
  {
    MemberAdminSql.setMemberProfileValues( ps, memberProfile );
  }

/**
 * Utility method to set Member File values taken from MemberFile object onto a prepared statement.
 *
 * @param ps                the prepared statement onto which we are setting the values
 * @param memberFile        MemberFile whose values we are setting
 * @exception SQLException  thrown if database exception
 */
  public static void setMemberFileValues( PreparedStatement ps, MemberFile memberFile ) throws SQLException
  {
    MemberAdminSql.setMemberFileValues( ps, memberFile );
  }

/**
 * Utility method to set Member Job values taken from MemberJob object onto a prepared statement.
 *
 * @param ps                the prepared statement onto which we are setting the values
 * @param memberJob         MemberJob whose values we are setting
 * @exception SQLException  thrown if database exception
 */
  public static void setMemberJobValues( PreparedStatement ps, MemberJob memberJob ) throws SQLException
  {
    MemberAdminSql.setMemberJobValues( ps, memberJob );
  }

/**
 * Gets the Membership Duration In Millis from property file
 *
 * @return   the Membership Duration In Millis from property file
 */
  public static long getMembershipDurationInMillis()
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    long durationInMonths = (long)( dataDictionary.getInt( "membership.durationInMonths" ) );
    return 1000l * 60l * 60l * 24l * 365l * durationInMonths / 12l;
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
    return MemberJobSaveAndLoadSql.getMemberJob( memberJobId );
  }

/**
 * Gets the Jobs For Moderation Ordered roughly correctly to be displayed on the job moderation report
 *
 * @return                      nearly sorted list of members, with each member having a sorted list of jobs, for all non-moderated memebr jobs
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList getJobsForModeration() throws ServletException
  {
    return MemberJobModerationSql.getJobsForModeration();
  }

/**
 * Gets the files For Moderation Ordered roughly correctly to be displayed on the file moderation report
 *
 * @return                      nearly sorted list of members, with each member having a sorted list of files, for all non-moderated memebr files
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList getFilesForModeration() throws ServletException
  {
    return MemberFileModerationSql.getFilesForModeration();
  }

/**
 * Gets the id of the current member of the week
 *
 * @return                      id of the current member of the week
 * @exception ServletException  thrown if database exception
 */
  public static int getMemberOfWeekId() throws ServletException
  {
    return getMemberOfWeekId( new Date() );
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
    return MemberOfWeekSql.getMemberOfWeekId( now );
  }

/**
 * if validation Key is valid for specified member, it will mark their email address ad haveing been validated on object and in database
 *
 * @param memberId              member to validate
 * @param validationKey         validation key
 * @return                      true if validated sucesfully, flase if incorrect key
 * @exception ServletException  thrown if database exception
 */
  public static boolean validateEmailAddress( int memberId, int validationKey ) throws ServletException
  {
    return MemberAdminSql.validateEmailAddress( memberId, validationKey );
  }

/**
 * Checks database to see if email address has been validated yet. if so will update member object
 *
 * @param member                member to check
 * @exception ServletException  thrown if database exception
 */
  public static void checkIfValidatedYet( Member member ) throws ServletException
  {
    MemberAdminSql.checkIfValidatedYet( member );
  }

/**
 * Deleted a Member row and all referenced rows, plus uses triggers to do cleanup (ie memberContact & memberProfile). Does not remove files.
 *
 * @param memberId              id of member to delete
 * @exception ServletException  thrown if database exception
 */
  public static void deleteMember( int memberId ) throws ServletException
  {
    MemberAdminSql.deleteMember( memberId );
  }

/**
 * checks whether new user has unique email and profileurl when registering
 *
 * @param email                 email address to check
 * @param profileURL            profileURL to check
 * @return                      bool array, 1st index is true if email is unique, 2nd if profileURL is unique
 * @exception ServletException  thrown if database exception
 */
  public static boolean[] checkUniqueFields( String email, String profileURL ) throws ServletException
  {
    return MemberAdminSql.checkUniqueFields( email, profileURL );
  }

/**
 * Sets a member as having placed an advert. if they're still logged having come back from worldpay, they are set as an advertiser ar a rough indicator of who has advertised and who has not. Also updates member object
 *
 * @param member                member to set as advsertiser
 * @param isAdvertiser          true to set as advertiser, false to set as non advertiser
 * @exception ServletException  thrown if database exception
 */
  public static void markMemberAsAdvertiser( Member markMemberAsAdvertiser, boolean isAdvertiser ) throws ServletException
  {
    MemberAdminSql.markMemberAsAdvertiser( markMemberAsAdvertiser, isAdvertiser );
  }

/**
 * Chnages the three fields on the member object and member table for given member. These are dealt with seperately to others cos they're handled differently due to uique constraints and the like. this makes no validity checks
 *
 * @param member                member to change
 * @param passwd                new passwd
 * @param profileUrl            new profileUrl
 * @param email                 new email
 * @param resetEmailValidated   true here meand mark the email validated field as false to user has to validate email again
 * @exception ServletException  thrown if database exception
 */
  public static void changePasswordAndEmailAndProfileUrl( Member member, String passwd, String profileUrl, String email, boolean resetEmailValidated ) throws ServletException
  {
    MemberAdminSql.changePasswordAndEmailAndProfileUrl( member, passwd, profileUrl, email, resetEmailValidated );
  }

/**
 * Create a new member row from member object, and assign new id to member object
 *
 * @param member                member to save
 * @exception ServletException  thrown if database exception
 */
  public static void saveNewMemberOnlyDetails( Member member ) throws ServletException
  {
    MemberSaveAndLoadSql.saveNewMemberOnlyDetails( member );
  }

/**
 * Loads full member object (with complete sub-objects too) using email and passowrd filters (login method)
 *
 * @param email                 email address of member
 * @param passwd                password of member
 * @return                      Full member object if correct login details, else null
 * @exception ServletException  thrown if database exception
 */
  public static Member loadFullMember( String email, String passwd ) throws ServletException
  {
    ArrayList mems = loadFullMembers( email, passwd, -1, null, false, null, null, null, null, false, true, true );

    if( mems.size() == 0 )
    {
      return null;
    }

    return (Member)mems.get( 0 );
  }

/**
 * Loads full member object (with complete sub-objects too) using profileURL as filter - used for niceURLs
 *
 * @param profileURL            profileURL of member
 * @return                      Full member object if one found, else null
 * @exception ServletException  thrown if database exception
 */
  public static Member loadFullMember( String profileURL ) throws ServletException
  {
    ArrayList mems = loadFullMembers( null, null, -1, profileURL, false, null, null, null, null, false, true, true );

    if( mems.size() == 0 )
    {
      return null;
    }

    return (Member)mems.get( 0 );
  }

/**
 * Loads full member object (with complete sub-objects too) given memberid
 *
 * @param memberId              id of member to get
 * @return                      Full member object if one found, else null
 * @exception ServletException  thrown if database exception
 */
  public static Member loadFullMember( int memberId ) throws ServletException
  {
    return (Member)loadFullMembers( null, null, memberId, null, false, null, null, null, null, false, true, true ).get( 0 );
  }

/**
 * Loads all members requiring moderation, objects are suitably populated and ordered for passinf in to member moderation reoport
 *
 * @return                      ordered arraylist of members
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList loadMembersRequiringModeration() throws ServletException
  {
    return loadFullMembers( null, null, -1, null, true, null, null, null, null, false, false, false );
  }

/**
 * Returns arraylist of unpaid members with minimal details populated that are unpaid and whom registered in a certain date range. file info is added to object so files can be deleted if necessary
 *
 * @param registeredAfter       Start of allowed range
 * @param registeredBefore      End of allowed range
 * @return                      arraylist of unpaid members with minimal details populated that are unpaid and whom registered in a certain date range. file info is added to object so files can be deleted if necessary
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList loadUpdaidMembersForCron( Date registeredAfter, Date registeredBefore ) throws ServletException
  {
    return loadFullMembers( null, null, -1, null, false, registeredAfter, registeredBefore, null, null, true, ( ( registeredBefore == null ) ? true : false ), false );
    // the conditional true/false is for when we are finding members to delete, so we want to add file info so all files can be deleted
  }

/**
 * returns a list of members( with minimal data populated) registered in a certain period who are about to expire
 *
 * @param expiresAfter          Start of allowed range
 * @param expiresBefore         End of allowed range
 * @return                      Description of the Returned Value
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList loadAboutToExpireMembersForCron( Date expiresAfter, Date expiresBefore ) throws ServletException
  {
    return loadFullMembers( null, null, -1, null, false, null, null, expiresAfter, expiresBefore, false, false, false );
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
    MemberSaveAndLoadSql.populateMemberFiles( members, startIdx, endIdx );
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
 * @return                      ArrayList of members matching criteria
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList memberSearch( String statusRefIds,
      int compSizeVal, int categoryVal, int disciplineVal, int countryVal, int regionVal, int countyVal,
      String keyword, String nameFirstLetter ) throws ServletException
  {
    return memberSearch( statusRefIds,
        compSizeVal, categoryVal, disciplineVal, countryVal, regionVal, countyVal,
        keyword, nameFirstLetter, false );
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
    return MemberSaveAndLoadSql.memberSearch( statusRefIds,
        compSizeVal, categoryVal, disciplineVal, countryVal, regionVal, countyVal,
        keyword, nameFirstLetter, returnAllResults
    );
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
    return MemberJobSaveAndLoadSql.memberJobSearch( jobTypeVal, categoryVal, disciplineVal, countryVal, regionVal, countyVal, keyword );
  }

/**
 * Returns an arraylist of member objects whose files match search criteria, only those files matching criteria are added to member objects. only required fields are populated
 *
 * @param isImage               "t" returns only images, "f" returns only non-images, null = no filter
 * @param categoryVal           if >-1 will filter on this categoryVal
 * @param disciplineVal         if >-1 will filter on this disciplineVal
 * @param keyword               matches IMAGE keywords, no filter is not set
 * @return                      an arraylist of member objects whose files match search criteria, only those files matching criteria are added to member objects. only required fields are populated
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList memberFileSearch( String isImage, int categoryVal, int disciplineVal, String keyword ) throws ServletException
  {
    return MemberFileSaveAndLoadSql.memberFileSearch( isImage, categoryVal, disciplineVal, keyword, -1, false );
  }

/**
 * Returns an arraylist of just a few member objects, each with one memberFile attached. This file is the main member file. This is only the most recent uploaded, moderated, image memberfiles for currently live members
 *
 * @param noToReturn            the max number of members to return
 * @return                      an arraylist of member objects with one main file each
 * @exception ServletException  thrown if database exception
 */
  public static ArrayList getLatestMainImages( int noToReturn ) throws ServletException
  {
    return MemberFileSaveAndLoadSql.memberFileSearch( "t", -1, -1, "", noToReturn, true );
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
    MemberSaveAndLoadSql.addAndSaveMemberContactForModeraion( member, memberContact );
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
    MemberSaveAndLoadSql.addAndSaveMemberProfileForModeraion( member, memberProfile );
  }

/**
 * Updates database only to reflect the member being on hold
 *
 * @param memberId              id of member to put on hold
 * @exception ServletException  thrown if database exception
 */
  public static void putMemberOnHold( int memberId ) throws ServletException
  {
    putOnHold( "MEMBERS", "memberId", memberId, true );
  }

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
    MemberModerationSql.putOnHold( tableName, idFieldName, id, onHold );
  }

/**
 * updates database to reflect the fact that a member has failed moderation (if this member is unpaid and has never passed moderation before - all of his details will be deleted)
 *
 * @param memberId              id of member to fail.
 * @exception ServletException  thrown if database exception
 */
  public static void moderateFailMemberDetails( int memberId ) throws ServletException
  {
    MemberModerationSql.moderateFailMemberDetails( memberId );
  }

/**
 * updates database to reflect the fact that a member has passed moderation
 *
 * @param memberId              id of member to pass.
 * @exception ServletException  thrown if database exception
 */
  public static void moderatePassMemberDetails( int memberId ) throws ServletException
  {
    MemberModerationSql.moderatePassMemberDetails( memberId );
  }

/**
 * this refreshes all of the MEMBER's search keywords in database
 *
 * @param memberId              id of member to refresh
 * @exception ServletException  thrown if database exception
 */
  public static void updateMemberSearchKeywords( int memberId ) throws ServletException
  {
    MemberKeywordsSql.updateMemberSearchKeywords( memberId );
  }

/**
 * updates database to reflect the fact that a MemberJob has passed moderation
 *
 * @param memberJobId           id of member job to pass.
 * @exception ServletException  thrown if database exception
 */
  public static void moderatePassMemberJob( int memberJobId ) throws ServletException
  {
   MemberJobModerationSql.moderatePassMemberJob( memberJobId );
  }

/**
 * this refreshed all of the MEMBERJOB's search keywords in database
 *
 * @param memberJobId           id of memberJob whose keywords we are to update
 * @exception ServletException  thrown if database exception
 */
  public static void updateMemberJobSearchKeywords( int memberJobId ) throws ServletException
  {
    MemberKeywordsSql.updateMemberJobSearchKeywords( memberJobId );
  }

/**
 * updates database to reflect the fact that a MemberJob has failed moderation
 *
 * @param memberJobId           id of member job to fail.
 * @exception ServletException  thrown if database exception
 */
  public static void moderateFailMemberJob( int memberJobId ) throws ServletException
  {
   MemberJobModerationSql.moderateFailMemberJob( memberJobId );
  }

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
    return MemberJobSaveAndLoadSql.checkUniqueJobReference( memberId, referenceNo );
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
    return MemberJobSaveAndLoadSql.addAndSaveMemberJobForModeraion( member, memberJob );
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
    MemberJobSaveAndLoadSql.deleteMemberJob( member, memberJobId );
  }

/**
 * updates database to reflect the fact that a MemberFile has passed moderation
 *
 * @param memberFileId          if of member file
 * @exception ServletException  thrown if database exception
 */
  public static void moderatePassMemberFile( int memberFileId ) throws ServletException
  {
    MemberFileModerationSql.moderatePassMemberFile( memberFileId );
  }

/**
 * this refreshes all of the MEMBERFILE's search keywords in database
 *
 * @param memberFileId          id of MemberFile to refresh
 * @exception ServletException  thrown if database exception
 */
  public static void updateMemberFileSearchKeywords( int memberFileId ) throws ServletException
  {
    MemberKeywordsSql.updateMemberFileSearchKeywords( memberFileId );
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
    return MemberFileSaveAndLoadSql.addAndSaveMemberFileForModeraion( member, memberFile );
  }

/**
 * finds total no of megabyte file space used across all files for unpaid members
 *
 * @return                      total no of megabyte file space used across all files for unpaid members
 * @exception ServletException  thrown if database exception
 */
  public static int findUnpaidPortfolioFileSpaceMB() throws ServletException
  {
    return MemberFileSaveAndLoadSql.findUnpaidPortfolioFileSpaceMB();
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

  }

/**
 * sets a series of date values on a row of the memebr table
 *
 * @param conn              the connection object to use
 * @param ps                The prepared statement object to use
 * @param memberId          id of the row to update
 * @param fieldNames        names of the fields whose values we are going to set
 * @param dates             the corresponding values ot set
 * @exception SQLException  thrown if database exception
 */
  public static void setDates( Connection conn, PreparedStatement ps, int memberId, String[] fieldNames, Date[] dates ) throws SQLException
  {
    MemberAdminSql.setDates( conn, ps, memberId, fieldNames, dates );
  }

/**
 * sets an integer field on a row of the memebr table
 *
 * @param conn              the connection object to use
 * @param ps                The prepared statement object to use
 * @param fieldName         name of the field whose value we are going to set
 * @param memberId          id of the row to update
 * @param id                new value
 * @exception SQLException  thrown if database exception
 */
  public static void setMemberFieldId( Connection conn, PreparedStatement ps, String fieldName, int memberId, int id ) throws SQLException
  {
    MemberAdminSql.setMemberFieldId( conn, ps, fieldName, memberId, id );
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
    return MemberSaveAndLoadSql.loadFullMembers( email, passwd, memberId, profileURL, moderationFilter, registeredAfter, registeredBefore, expiresAfter, expiresBefore, unpaidFilter, addFiles, addJobs );
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
    return MemberSaveAndLoadSql.createMember( rs );
  }

/**
 * gets fields from resultset to create a MemberContact object
 *
 * @param rs                result set containing member contact values
 * @param idColumnName      the column mane of the primary key column in the result set
 * @param prefix            if there is a prefix to all the columns (apart from primary key) (like mc_lastUpdatedDate ) put the prefix (eg "mc_" ) here. else put "" here
 * @return                  fuly populated MemberContact object
 * @exception SQLException  thrown if database exception
 */
  public static MemberContact createMemberContact( ResultSet rs, String idColumnName, String prefix ) throws SQLException
  {
    return MemberSaveAndLoadSql.createMemberContact( rs, idColumnName, prefix );
  }

/**
 * gets fields from resultset to create a MemberProfile object
 *
 * @param rs                result set containing member profile values
 * @param idColumnName      the column mane of the primary key column in the result set
 * @param prefix            if there is a prefix to all the columns (apart from primary key) (like mc_lastUpdatedDate ) put the prefix (eg "mc_" ) here. else put "" here
 * @return                  fuly populated MemberProfile object
 * @exception SQLException  thrown if database exception
 */
  public static MemberProfile createMemberProfile( ResultSet rs, String idColumnName, String prefix ) throws SQLException
  {
    return MemberSaveAndLoadSql.createMemberProfile( rs, idColumnName, prefix );
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
    return MemberFileSaveAndLoadSql.createMemberFile( rs );
  }

/**
 * gets fields from resultset to create a MemberJob object
 *
 * @param rs                result set containing member job values
 * @return                  fuly populated MemberJob object
 * @exception SQLException  thrown if database exception
 */
  public static MemberJob createMemberJob( ResultSet rs ) throws SQLException
  {
    return createMemberJob( rs, "" );
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
    return MemberJobSaveAndLoadSql.createMemberJob( rs, prefix );
  }

}
