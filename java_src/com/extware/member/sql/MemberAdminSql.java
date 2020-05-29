package com.extware.member.sql;

import com.extware.member.Member;
import com.extware.member.MemberClient;
import com.extware.member.MemberContact;
import com.extware.member.MemberFile;
import com.extware.member.MemberJob;
import com.extware.member.MemberProfile;

import com.extware.utils.BooleanUtils;
import com.extware.utils.DatabaseUtils;
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
public class MemberAdminSql
{

  private static String UPDATE_MEMBER_SQL =
      "UPDATE MEMBERS SET " +
      "passwd=?, profileURL=?, email=? ";
  //none of the other fields are allowed to change.

/**
 * sets member as having paid on object and in database. if member is already moderated then set go live and expiry dates
 *
 * @param memberId              id of member to update
 * @param loggedInMember        member object to update
 * @exception ServletException  thrown if database exception
 */
  public static void setMemberAsPaid( int memberId, Member loggedInMember ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = null;

      //get the full member object with all of it's stuff populated - this will most probably have been passed in but if the user's login expires while they're paying then we still want to let their payment count so we get it all again from the database (likewise if - somehow, someone else is logged in now)
      Member member = null;
      member = MemberClient.loadFullMember( memberId );

      //find current timestamp
      java.sql.Timestamp now = new java.sql.Timestamp( new Date().getTime() );

      //set payment date (and maybe go live and expiry if necessary)
      Date[] setDates = null;
      String[] setFields = null;

      if( member.goLiveDate == null && member.memberContact != null && member.memberProfile != null )
      {
        //paying for the first time, and going straight live
        setDates = new Date[3];
        setFields = new String[3];
        setDates[1] = new java.sql.Timestamp( now.getTime() + MemberClient.getMembershipDurationInMillis() );
        setFields[1] = "expiryDate";
        member.expiryDate = setDates[1];
        setDates[2] = now;
        setFields[2] = "goLiveDate";
        member.goLiveDate = now;

        if( loggedInMember != null )
        {
          loggedInMember.goLiveDate = now;
        }
      }

      if( member.goLiveDate != null )
      {
        //setting expiry date to a year from now (or a year from when it's currently due to expire)
        setDates = new Date[2];
        setFields = new String[2];

        if( member.expiryDate == null || member.expiryDate.before( now ) )
        {
          setDates[1] = new java.sql.Timestamp( now.getTime() + MemberClient.getMembershipDurationInMillis() );
        }
        else
        {
          setDates[1] = new java.sql.Timestamp( member.expiryDate.getTime() + MemberClient.getMembershipDurationInMillis() );
        }

        setFields[1] = "expiryDate";
        member.expiryDate = setDates[1];

        if( loggedInMember != null )
        {
          loggedInMember.expiryDate = setDates[1];
        }
      }

      //initialise if not already
      if( setDates == null && setFields == null )
      {
        setDates = new Date[1];
        setFields = new String[1];
      }

      setDates[0] = now;
      setFields[0] = "lastPaymentDate";
      member.lastPaymentDate = now;

      if( loggedInMember != null )
      {
        loggedInMember.lastPaymentDate = now;
      }

      //set dates in database
      setDates( conn, ps, member.memberId, setFields, setDates );
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
 * Utility method to set member values taken from member object onto a prepared statement.
 *
 * @param ps                the prepared statement onto which we are setting the values
 * @param member            member whose values we are setting
 * @exception SQLException  thrown if database exception
 */
  public static void setMemberOnlyValues( PreparedStatement ps, Member member ) throws SQLException
  {
    PreparedStatementUtils.setInt( ps, 1, ( member.memberContact == null ) ? -1 : member.memberContact.memberContactId );
    PreparedStatementUtils.setInt( ps, 2, ( member.memberProfile == null ) ? -1 : member.memberProfile.memberProfileId );
    PreparedStatementUtils.setInt( ps, 3, ( member.moderationMemberContact == null ) ? -1 : member.moderationMemberContact.memberContactId );
    PreparedStatementUtils.setInt( ps, 4, ( member.moderationMemberProfile == null ) ? -1 : member.moderationMemberProfile.memberProfileId );
    PreparedStatementUtils.setString( ps, 5, member.email.trim(), 200 );
    PreparedStatementUtils.setString( ps, 6, member.passwd.trim(), 200 );
    PreparedStatementUtils.setString( ps, 7, member.profileURL.trim(), 200 );
    PreparedStatementUtils.setDate( ps, 8, member.lastPaymentDate );
    PreparedStatementUtils.setDate( ps, 9, member.goLiveDate );
    PreparedStatementUtils.setDate( ps, 10, member.expiryDate );
    PreparedStatementUtils.setString( ps, 11, member.onModerationHold );
    PreparedStatementUtils.setString( ps, 12, member.emailValidated );
    PreparedStatementUtils.setInt( ps, 13, member.validationKey );
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
    PreparedStatementUtils.setString( ps, 1, memberContact.name, 200 );
    char nameFirstLetterChar = memberContact.name.toUpperCase().charAt( 0 );
    String nameFirstLetterString;

    if( nameFirstLetterChar >= 'A' && nameFirstLetterChar <= 'Z' )
    {
      nameFirstLetterString = String.valueOf( nameFirstLetterChar );
    }
    else if( nameFirstLetterChar >= '0' && nameFirstLetterChar <= '9' )
    {
      nameFirstLetterString = "0";
    }
    else
    {
      nameFirstLetterString = "_";
    }

    PreparedStatementUtils.setString( ps, 2, nameFirstLetterString, 200 );
    PreparedStatementUtils.setInt( ps, 3, memberContact.statusRef );
    PreparedStatementUtils.setString( ps, 4, memberContact.statusOther, 200 );
    PreparedStatementUtils.setInt( ps, 5, memberContact.primaryCategoryRef );
    PreparedStatementUtils.setInt( ps, 6, memberContact.primaryDisciplineRef );
    PreparedStatementUtils.setInt( ps, 7, memberContact.secondaryCategoryRef );
    PreparedStatementUtils.setInt( ps, 8, memberContact.secondaryDisciplineRef );
    PreparedStatementUtils.setInt( ps, 9, memberContact.tertiaryCategoryRef );
    PreparedStatementUtils.setInt( ps, 10, memberContact.tertiaryDisciplineRef );
    PreparedStatementUtils.setInt( ps, 11, memberContact.sizeRef );
    PreparedStatementUtils.setInt( ps, 12, memberContact.countryRef );
    PreparedStatementUtils.setInt( ps, 13, memberContact.regionRef );
    PreparedStatementUtils.setString( ps, 14, memberContact.address1, 200 );
    PreparedStatementUtils.setString( ps, 15, memberContact.address2, 200 );
    PreparedStatementUtils.setString( ps, 16, memberContact.city, 200 );
    PreparedStatementUtils.setString( ps, 17, memberContact.postcode, 200 );
    PreparedStatementUtils.setInt( ps, 18, memberContact.countyRef );
    PreparedStatementUtils.setInt( ps, 19, memberContact.contactTitleRef );
    PreparedStatementUtils.setString( ps, 20, memberContact.contactFirstName, 200 );
    PreparedStatementUtils.setString( ps, 21, memberContact.contactSurname, 200 );
    PreparedStatementUtils.setString( ps, 22, memberContact.telephone, 200 );
    PreparedStatementUtils.setString( ps, 23, memberContact.mobile, 200 );
    PreparedStatementUtils.setString( ps, 24, memberContact.fax, 200 );
    PreparedStatementUtils.setString( ps, 25, memberContact.webAddress, 200 );
    PreparedStatementUtils.setInt( ps, 26, memberContact.whereDidYouHearRef );
    PreparedStatementUtils.setString( ps, 27, memberContact.whereDidYouHearOther, 200 );
    PreparedStatementUtils.setString( ps, 28, memberContact.whereDidYouHearMagazine, 200 );
    PreparedStatementUtils.setInt( ps, 29, memberContact.memberContactId );
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
    PreparedStatementUtils.setString( ps, 1, memberProfile.personalStatement, 2000 );
    PreparedStatementUtils.setString( ps, 2, memberProfile.specialisations, 2000 );
    PreparedStatementUtils.setString( ps, 3, memberProfile.keywords, 2000 );
    PreparedStatementUtils.setInt( ps, 4, memberProfile.memberProfileId );
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
    PreparedStatementUtils.setInt( ps, 1, memberFile.assetId );
    PreparedStatementUtils.setString( ps, 2, memberFile.description, 200 );
    PreparedStatementUtils.setString( ps, 3, memberFile.keywords, 200 );
    PreparedStatementUtils.setString( ps, 4, memberFile.displayFileName, 200 );
    PreparedStatementUtils.setString( ps, 5, memberFile.mimeType, 200 );
    PreparedStatementUtils.setLong( ps, 6, memberFile.fileByteSize );
    PreparedStatementUtils.setString( ps, 7, memberFile.isImage );
    PreparedStatementUtils.setString( ps, 8, memberFile.mainFile );
    PreparedStatementUtils.setString( ps, 9, memberFile.portraitImage );
    PreparedStatementUtils.setString( ps, 10, memberFile.forModeration );
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
    PreparedStatementUtils.setString( ps, 1, memberJob.referenceNo, 100 );
    PreparedStatementUtils.setString( ps, 2, memberJob.title, 200 );
    PreparedStatementUtils.setInt( ps, 3, memberJob.mainCategoryRef );
    PreparedStatementUtils.setInt( ps, 4, memberJob.disciplineRef );
    PreparedStatementUtils.setInt( ps, 5, memberJob.typeOfWorkRef );
    PreparedStatementUtils.setString( ps, 6, memberJob.salary, 200 );
    PreparedStatementUtils.setInt( ps, 7, memberJob.countryRef );
    PreparedStatementUtils.setInt( ps, 8, memberJob.ukRegionRef );
    PreparedStatementUtils.setInt( ps, 9, memberJob.countyRef );
    PreparedStatementUtils.setString( ps, 10, memberJob.city, 200 );
    PreparedStatementUtils.setString( ps, 11, memberJob.telephone, 200 );
    PreparedStatementUtils.setString( ps, 12, memberJob.email, 200 );
    PreparedStatementUtils.setString( ps, 13, memberJob.contactName, 200 );
    PreparedStatementUtils.setString( ps, 14, memberJob.description, 2000 );
    PreparedStatementUtils.setString( ps, 15, memberJob.forModeration );
    PreparedStatementUtils.setInt( ps, 16, memberJob.moderatedJobId );
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
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = conn.prepareStatement( "UPDATE MEMBERS SET emailValidated = ? WHERE memberId = ? AND validationKey = ? " );

      PreparedStatementUtils.setString( ps, 1, true );
      PreparedStatementUtils.setInt( ps, 2, memberId );
      PreparedStatementUtils.setInt( ps, 3, validationKey );

      int rows = ps.executeUpdate();

      ps.close();

      return rows == 1;
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
 * Checks database to see if email address has been validated yet. if so will update member object
 *
 * @param member                member to check
 * @exception ServletException  thrown if database exception
 */
  public static void checkIfValidatedYet( Member member ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();
      PreparedStatement ps = conn.prepareStatement( "SELECT emailValidated FROM MEMBERS WHERE memberId = ?" );

      PreparedStatementUtils.setInt( ps, 1, member.memberId );

      ResultSet rs = ps.executeQuery();

      if( rs.next() && BooleanUtils.isTrue( rs.getString( "emailValidated" ) ) )
      {
        member.emailValidated = true;
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
 * Deleted a Member row and all referenced rows, plus uses triggers to do cleanup (ie memberContact & memberProfile). Does not remove files.
 *
 * @param memberId              id of member to delete
 * @exception ServletException  thrown if database exception
 */
  public static void deleteMember( int memberId ) throws ServletException
  {
    Connection conn = null;

    try
    {
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = conn.prepareStatement( "DELETE FROM MEMBERS WHERE memberId = ?" );
      PreparedStatementUtils.setInt( ps, 1, memberId );

      ps.executeUpdate();  //all stuff hanging off members are deleted by referential constraints, all stuff that members are hanging off (ie membercontacts and memberprofiles) are deleted by triggers, good eh?

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
 * checks whether new user has unique email and profileurl when registering
 *
 * @param email                 email address to check
 * @param profileURL            profileURL to check
 * @return                      bool array, 1st index is true if email is unique, 2nd if profileURL is unique
 * @exception ServletException  thrown if database exception
 */
  public static boolean[] checkUniqueFields( String email, String profileURL ) throws ServletException
  {
    Connection conn = null;

    try
    {
      boolean[] uniqueResults = new boolean[2];
      uniqueResults[0] = true;
      uniqueResults[1] = true;

      email = email.trim().toUpperCase();
      profileURL = profileURL.trim().toUpperCase();

      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = conn.prepareStatement( "SELECT UPPER( email ) email, UPPER( profileURL ) profileURL FROM MEMBERS WHERE UPPER( email ) = ? OR UPPER( profileURL ) = ?" );
      ps.setString( 1, email );
      ps.setString( 2, profileURL );

      ResultSet rs = ps.executeQuery();

      while( rs.next() )
      {
        if( email.equals( rs.getString( "email" ) ) )
        {
          uniqueResults[0] = false;
        }

        if( profileURL.equals( rs.getString( "profileURL" ) ) )
        {
          uniqueResults[1] = false;
        }
      }

      rs.close();
      ps.close();

      return uniqueResults;
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
 * Sets a member as having placed an advert. if they're still logged having come back from worldpay, they are set as an advertiser ar a rough indicator of who has advertised and who has not. Also updates member object
 *
 * @param member                member to set as advsertiser
 * @param isAdvertiser          true to set as advertiser, false to set as non advertiser
 * @exception ServletException  thrown if database exception
 */
  public static void markMemberAsAdvertiser( Member member, boolean isAdvertiser ) throws ServletException
  {
    Connection conn = null;

    try
    {
      //add or update the record in the database
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = null;
      ps = conn.prepareStatement( "UPDATE MEMBERS SET placedAdvert=? WHERE memberId=?" );

      PreparedStatementUtils.setString( ps, 1, isAdvertiser );
      PreparedStatementUtils.setInt( ps, 2, member.memberId );

      ps.executeUpdate();

      member.placedAdvert = isAdvertiser;

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
    Connection conn = null;

    try
    {
      //update password in database
      conn = DatabaseUtils.getDatabaseConnection();

      PreparedStatement ps = null;
      ps = conn.prepareStatement( UPDATE_MEMBER_SQL + ( resetEmailValidated ? ", emailValidated = 'f' " : " " ) + "WHERE memberId=? " );

      ps.setString( 1, passwd );
      ps.setString( 2, profileUrl );
      ps.setString( 3, email );
      ps.setInt( 4, member.memberId );

      ps.executeUpdate();

      ps.close();

      //now change password of member object
      member.passwd = passwd;
      member.profileURL = profileUrl;
      member.email = email;

      if( resetEmailValidated )
      {
        member.emailValidated = false;
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
    String sql = "UPDATE MEMBERS SET ";

    for( int i = 0; i < fieldNames.length; i++ )
    {
      sql += ( i > 0 ? ", " : "" ) + fieldNames[i] + " = " + ( ( dates.length >= i && dates[i] != null ) ? "?" : "CURRENT_TIMESTAMP" );
    }

    sql += " WHERE memberId = ?";
    ps = conn.prepareStatement( sql );

    int colNum = 1;

    for( int i = 0; i < fieldNames.length; i++ )
    {
      if( dates.length >= i && dates[i] != null )
      {
        PreparedStatementUtils.setDate( ps, colNum++, dates[i] );
      }
    }

    ps.setInt( colNum++, memberId );
    ps.executeUpdate();
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
    ps = conn.prepareStatement( "UPDATE MEMBERS SET " + fieldName + "=? WHERE memberId=?" );
    ps.setInt( 1, id );
    ps.setInt( 2, memberId );
    ps.executeUpdate();
  }

}