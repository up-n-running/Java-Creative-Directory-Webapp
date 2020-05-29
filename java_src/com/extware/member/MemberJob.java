package com.extware.member;

import com.extware.utils.PropertyFile;

import java.util.Date;

/**
 * Description of the Class
 *
 * @author   John Milner
 */
public class MemberJob
{

  public int     memberJobId = -1;
  public Date    creationDate = null;
  public Date    lastUpdatedDate = null;
  public String  referenceNo = null;  //unique
  public String  title = null;
  public int     mainCategoryRef = -1;
  public int     disciplineRef = -1;
  public int     typeOfWorkRef = -1;
  public String  salary = null;
  public int     countryRef = -1;
  public int     ukRegionRef = -1;
  public int     countyRef = -1;
  public String  city = null;
  public String  telephone = null;
  public String  email = null;
  public String  contactName = null;
  public String  description = null;
  public boolean forModeration = true;
  public int     moderatedJobId = -1;

  public int     memberId = -1;  //this is only used when jobDetails.jsp calls MemberClient.getMemberJob. at all other times it's null

/**
 * Constructor for the MemberJob object
 */
  public MemberJob()
  {
  }

/**
 * subset constructor for holding search results
 *
 * @param memberJobId    Direct from memberJobs database table
 * @param referenceNo    Direct from memberJobs database table
 * @param title          Direct from memberJobs database table
 * @param typeOfWorkRef  Direct from memberJobs database table
 * @param salary         Direct from memberJobs database table
 * @param countryRef     Direct from memberJobs database table
 * @param ukRegionRef    Direct from memberJobs database table
 * @param countyRef      Direct from memberJobs database table
 * @param city           Direct from memberJobs database table
 * @param telephone      Direct from memberJobs database table
 * @param email          Direct from memberJobs database table
 * @param contactName    Direct from memberJobs database table
 * @param description    Direct from memberJobs database table
 */
  public MemberJob( int    memberJobId,
                    String referenceNo,
                    String title,
                    int    typeOfWorkRef,
                    String salary,
                    int    countryRef,
                    int    ukRegionRef,
                    int    countyRef,
                    String city,
                    String telephone,
                    String email,
                    String contactName,
                    String description
                  )
  {
    this.memberJobId     = memberJobId     ;
    this.referenceNo     = referenceNo     ;
    this.title           = title           ;
    this.typeOfWorkRef   = typeOfWorkRef   ;
    this.salary          = salary          ;
    this.countryRef      = countryRef      ;
    this.ukRegionRef     = ukRegionRef     ;
    this.countyRef       = countyRef       ;
    this.city            = city            ;
    this.telephone       = telephone       ;
    this.email           = email           ;
    this.contactName     = contactName     ;
    this.description     = description     ;
  }

/**
 * subset constructor for holding search key word information
 *
 * @param memberJobId      Direct from memberJobs database table
 * @param referenceNo      Direct from memberJobs database table
 * @param title            Direct from memberJobs database table
 * @param mainCategoryRef  Direct from memberJobs database table
 * @param disciplineRef    Direct from memberJobs database table
 * @param typeOfWorkRef    Direct from memberJobs database table
 * @param countryRef       Direct from memberJobs database table
 * @param ukRegionRef      Direct from memberJobs database table
 * @param countyRef        Direct from memberJobs database table
 * @param city             Direct from memberJobs database table
 */
  public MemberJob( int    memberJobId,
                    String referenceNo,
                    String title,
                    int    mainCategoryRef,
                    int    disciplineRef,
                    int    typeOfWorkRef,
                    int    countryRef,
                    int    ukRegionRef,
                    int    countyRef,
                    String city )
  {
    this.memberJobId     = memberJobId     ;
    this.referenceNo     = referenceNo     ;
    this.title           = title           ;
    this.mainCategoryRef = mainCategoryRef ;
    this.disciplineRef   = disciplineRef   ;
    this.typeOfWorkRef   = typeOfWorkRef   ;
    this.countryRef      = countryRef      ;
    this.ukRegionRef     = ukRegionRef     ;
    this.countyRef       = countyRef       ;
    this.city            = city            ;
  }

/**
 * Constructor for the MemberJob object
 *
 * @param memberJobId      Direct from memberJobs database table
 * @param creationDate     Direct from memberJobs database table
 * @param lastUpdatedDate  Direct from memberJobs database table
 * @param referenceNo      Direct from memberJobs database table
 * @param title            Direct from memberJobs database table
 * @param mainCategoryRef  Direct from memberJobs database table
 * @param disciplineRef    Direct from memberJobs database table
 * @param typeOfWorkRef    Direct from memberJobs database table
 * @param salary           Direct from memberJobs database table
 * @param countryRef       Direct from memberJobs database table
 * @param ukRegionRef      Direct from memberJobs database table
 * @param countyRef        Direct from memberJobs database table
 * @param city             Direct from memberJobs database table
 * @param telephone        Direct from memberJobs database table
 * @param email            Direct from memberJobs database table
 * @param contactName      Direct from memberJobs database table
 * @param description      Direct from memberJobs database table
 * @param forModeration    Direct from memberJobs database table
 * @param moderatedJobId   Direct from memberJobs database table
 */
  public MemberJob( int     memberJobId,
                    Date    creationDate,
                    Date    lastUpdatedDate,
                    String  referenceNo,
                    String  title,
                    int     mainCategoryRef,
                    int     disciplineRef,
                    int     typeOfWorkRef,
                    String  salary,
                    int     countryRef,
                    int     ukRegionRef,
                    int     countyRef,
                    String  city,
                    String  telephone,
                    String  email,
                    String  contactName,
                    String  description,
                    boolean forModeration,
                    int     moderatedJobId )
  {
    this.memberJobId     = memberJobId     ;
    this.creationDate    = creationDate    ;
    this.lastUpdatedDate = lastUpdatedDate ;
    this.referenceNo     = referenceNo     ;
    this.title           = title           ;
    this.mainCategoryRef = mainCategoryRef ;
    this.disciplineRef   = disciplineRef   ;
    this.typeOfWorkRef   = typeOfWorkRef   ;
    this.salary          = salary          ;
    this.countryRef      = countryRef      ;
    this.ukRegionRef     = ukRegionRef     ;
    this.countyRef       = countyRef       ;
    this.city            = city            ;
    this.telephone       = telephone       ;
    this.email           = email           ;
    this.contactName     = contactName     ;
    this.description     = description     ;
    this.forModeration   = forModeration   ;
    this.moderatedJobId  = moderatedJobId  ;
  }

/**
 * Gets the Main Category Description from dropDowns.properties
 *
 * @return   The Main Category Description
 */
  public String getMainCategoryDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
    return ddProps.getString( "categoryref." + mainCategoryRef );
  }

/**
 * Gets the Discipline Description from dropDowns.properties
 *
 * @return   The Discipline Description
 */
  public String getDisciplineDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
    return ddProps.getString( "disciplineref." + mainCategoryRef + "." + disciplineRef );
  }

/**
 * Gets the Type Of Work Description from dropDowns.properties
 *
 * @return   The Type Of Work Description
 */
  public String getTypeOfWorkDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
    return ddProps.getString( "typeofworkref." + typeOfWorkRef );
  }

/**
 * Gets the Country Description from dropDowns.properties
 *
 * @return   The Country Description
 */
  public String getCountryDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
    return ddProps.getString( "countryref." + countryRef );
  }

/**
 * Gets the Region Description from dropDowns.properties
 *
 * @return   The Region Description
 */
  public String getRegionDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
    return ddProps.getString( "ukregionref." + ukRegionRef );
  }

/**
 * Gets the County Description from dropDowns.properties
 *
 * @return   The County Description
 */
  public String getCountyDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
    return ddProps.getString( "countyref." + ukRegionRef + "." + countyRef );
  }

/**
 * compares two MemberJob objects - similar to equals, but does not check memberJobId, creationDate or lastUpdatedDate - used to see if someone has changed their details or left them untouched when submitting the job details form in edit mode
 *
 * @param that  object to make the comparison on
 * @return      true if details remain unchanged, false otherwise
 */
  public boolean hasSameDetailsAs( MemberJob that )
  {
    //NOTE the two strings will only ever be == if they are both null
    return (
      ( this.referenceNo       == that.referenceNo       || this.referenceNo.equals(  that.referenceNo       ) ) &&
      ( this.title             == that.title             || this.title.equals(        that.title             ) ) &&
      ( this.mainCategoryRef   == that.mainCategoryRef   ) &&
      ( this.disciplineRef     == that.disciplineRef     ) &&
      ( this.typeOfWorkRef     == that.typeOfWorkRef     ) &&
      ( this.salary            == that.salary            || this.salary.equals(       that.salary            ) ) &&
      ( this.countryRef        == that.countryRef        ) &&
      ( this.ukRegionRef       == that.ukRegionRef       ) &&
      ( this.countyRef         == that.countyRef         ) &&
      ( this.city              == that.city              || this.city.equals(        that.city              ) ) &&
      ( this.telephone         == that.telephone         || this.telephone.equals(   that.telephone         ) ) &&
      ( this.email             == that.email             || this.email.equals(       that.email             ) ) &&
      ( this.contactName       == that.contactName       || this.contactName.equals( that.contactName       ) ) &&
      ( this.description       == that.description       || this.description.equals( that.description       ) )
    );
  }

}
