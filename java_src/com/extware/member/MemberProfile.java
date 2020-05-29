package com.extware.member;

import com.extware.utils.StringUtils;

import java.util.Date;

/**
 * Holds the details entered on registerProfileDetails.jsp
 *
 * @author   John Milner
 */
public class MemberProfile
{

  public int    memberProfileId   = -1;
  public Date   lastUpdatedDate   = null;
  public String personalStatement = null;
  public String specialisations   = null;
  public String keywords          = null;

/**
 * Constructor for the MemberProfile object
 */
  public MemberProfile()
  {
  }

/**
 * Constructor for the MemberProfile object
 *
 * @param memberProfileId    Direct from memberProfiles Database table
 * @param lastUpdatedDate    Direct from memberProfiles Database table
 * @param personalStatement  Direct from memberProfiles Database table
 * @param specialisations    Direct from memberProfiles Database table (comma sep list of keywords)
 * @param keywords           Direct from memberProfiles Database table (comma sep list of keywords)
 */
  public MemberProfile( int    memberProfileId,
                        Date   lastUpdatedDate,
                        String personalStatement,
                        String specialisations,
                        String keywords )
  {
    this.memberProfileId   = memberProfileId;
    this.lastUpdatedDate   = lastUpdatedDate;
    this.personalStatement = personalStatement;
    this.specialisations   = specialisations;
    this.keywords          = keywords;
  }

/**
 * Gets the Keyword List and splits on comma and trims each split into array
 *
 * @return   Array of keywords
 */
  public String[] getKeywordList()
  {
    return StringUtils.split( keywords, "\\s*,\\s*" );
  }

/**
 * Gets the Specialisation List and splits on comma and trims each split into array
 *
 * @return   Array of Specialisations
 */
  public String[] getSpecialisationList()
  {
    return StringUtils.split( specialisations, "\\s*,\\s*" );
  }

/**
 * compares two MemberProfile objects - similar to equals, but does not check memberProfileId or lastUpdatedDate - used to see if someone has changed their details or left them untouched when submitting the member profile details form
 *
 * @param that  object to make the comparison on
 * @return      true if details remain unchanged, false otherwise
 */
  public boolean hasSameDetailsAs( MemberProfile that )
  {
    //NOTE the two strings will only ever be == if they are both null
    return (
        ( this.personalStatement == that.personalStatement || this.personalStatement.equals( that.personalStatement ) ) &&
        ( this.specialisations   == that.specialisations   || this.specialisations.equals(   that.specialisations   ) ) &&
        ( this.keywords          == that.keywords          || this.keywords.equals(          that.keywords          ) )
    );
  }

}
