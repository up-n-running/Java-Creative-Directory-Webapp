package com.extware.member;

import com.extware.utils.PropertyFile;

import java.util.Date;

/**
 * This can hold all of the members contact details, each member will have 2 of these objects one for moderated results and one for unmoderated results
 *
 * @author   John Milner
 */
public class MemberContact
{

  public int    memberContactId         = -1;
  public Date   lastUpdatedDate         = null;
  public String name                    = null;
  public int    statusRef               = -1;
  public String statusOther             = null;  //this is not actually used any more but was removed from form last minute and i did not have time to remove it from all of the java code - it will always be null
  public int    primaryCategoryRef      = -1;
  public int    primaryDisciplineRef    = -1;
  public int    secondaryCategoryRef    = -1;
  public int    secondaryDisciplineRef  = -1;
  public int    tertiaryCategoryRef     = -1;
  public int    tertiaryDisciplineRef   = -1;
  public int    sizeRef                 = -1;
  public int    countryRef              = -1;
  public int    regionRef               = -1;
  public String address1                = null;
  public String address2                = null;
  public String city                    = null;
  public String postcode                = null;
  public int    countyRef               = -1;
  public int    contactTitleRef         = -1;
  public String contactFirstName        = null;
  public String contactSurname          = null;
  public String telephone               = null;
  public String mobile                  = null;
  public String fax                     = null;
  public String webAddress              = null;
  public int    whereDidYouHearRef      = -1;
  public String whereDidYouHearOther    = null;
  public String whereDidYouHearMagazine = null;

/**
 * Constructor for the MemberContact object
 */
  public MemberContact()
  {
  }

/**
 * subset constructor to hold keyword information
 *
 * @param name                    Direct from memberContact database table
 * @param primaryCategoryRef      Direct from memberContact database table
 * @param primaryDisciplineRef    Direct from memberContact database table
 * @param secondaryCategoryRef    Direct from memberContact database table
 * @param secondaryDisciplineRef  Direct from memberContact database table
 * @param tertiaryCategoryRef     Direct from memberContact database table
 * @param tertiaryDisciplineRef   Direct from memberContact database table
 * @param countryRef              Direct from memberContact database table
 * @param regionRef               Direct from memberContact database table
 * @param city                    Direct from memberContact database table
 * @param countyRef               Direct from memberContact database table
 */
  public MemberContact( String name,
                        int    primaryCategoryRef,
                        int    primaryDisciplineRef,
                        int    secondaryCategoryRef,
                        int    secondaryDisciplineRef,
                        int    tertiaryCategoryRef,
                        int    tertiaryDisciplineRef,
                        int    countryRef,
                        int    regionRef,
                        String city,
                        int    countyRef )
  {
    this.name                    = name;
    this.primaryCategoryRef      = primaryCategoryRef;
    this.primaryDisciplineRef    = primaryDisciplineRef;
    this.secondaryCategoryRef    = secondaryCategoryRef;
    this.secondaryDisciplineRef  = secondaryDisciplineRef;
    this.tertiaryCategoryRef     = tertiaryCategoryRef;
    this.tertiaryDisciplineRef   = tertiaryDisciplineRef;
    this.countryRef              = countryRef;
    this.regionRef               = regionRef;
    this.city                    = city;
    this.countyRef               = countyRef;
  }

/**
 * subset constructor to hold search results
 *
 * @param name                    Direct from memberContact database table
 * @param statusRef               Direct from memberContact database table
 * @param primaryCategoryRef      Direct from memberContact database table
 * @param primaryDisciplineRef    Direct from memberContact database table
 * @param secondaryCategoryRef    Direct from memberContact database table
 * @param secondaryDisciplineRef  Direct from memberContact database table
 * @param tertiaryCategoryRef     Direct from memberContact database table
 * @param tertiaryDisciplineRef   Direct from memberContact database table
 * @param sizeRef                 Direct from memberContact database table
 * @param countryRef              Direct from memberContact database table
 * @param regionRef               Direct from memberContact database table
 * @param city                    Direct from memberContact database table
 * @param countyRef               Direct from memberContact database table
 * @param contactTitleRef         Direct from memberContact database table
 * @param contactFirstName        Direct from memberContact database table
 * @param contactSurname          Direct from memberContact database table
 */
  public MemberContact( String name,
                        int    statusRef,
                        int    primaryCategoryRef,
                        int    primaryDisciplineRef,
                        int    secondaryCategoryRef,
                        int    secondaryDisciplineRef,
                        int    tertiaryCategoryRef,
                        int    tertiaryDisciplineRef,
                        int    sizeRef,
                        int    countryRef,
                        int    regionRef,
                        String city,
                        int    countyRef,
                        int    contactTitleRef,
                        String contactFirstName,
                        String contactSurname )
  {
    this.name                    = name;
    this.statusRef               = statusRef;
    this.primaryCategoryRef      = primaryCategoryRef;
    this.primaryDisciplineRef    = primaryDisciplineRef;
    this.secondaryCategoryRef    = secondaryCategoryRef;
    this.secondaryDisciplineRef  = secondaryDisciplineRef;
    this.tertiaryCategoryRef     = tertiaryCategoryRef;
    this.tertiaryDisciplineRef   = tertiaryDisciplineRef;
    this.sizeRef                 = sizeRef;
    this.countryRef              = countryRef;
    this.regionRef               = regionRef;
    this.city                    = city;
    this.countyRef               = countyRef;
    this.contactTitleRef         = contactTitleRef;
    this.contactFirstName        = contactFirstName;
    this.contactSurname          = contactSurname;
  }

/**
 * Constructor for the MemberContact object
 *
 * @param memberContactId          Direct from memberContact database table
 * @param lastUpdatedDate          Direct from memberContact database table
 * @param name                     Direct from memberContact database table
 * @param statusRef                Direct from memberContact database table
 * @param statusOther              this is not actually used but may well be re-introduced into code - it will always be null
 * @param primaryCategoryRef       Direct from memberContact database table
 * @param primaryDisciplineRef     Direct from memberContact database table
 * @param secondaryCategoryRef     Direct from memberContact database table
 * @param secondaryDisciplineRef   Direct from memberContact database table
 * @param tertiaryCategoryRef      Direct from memberContact database table
 * @param tertiaryDisciplineRef    Direct from memberContact database table
 * @param sizeRef                  Direct from memberContact database table
 * @param countryRef               Direct from memberContact database table
 * @param regionRef                Direct from memberContact database table
 * @param address1                 Direct from memberContact database table
 * @param address2                 Direct from memberContact database table
 * @param city                     Direct from memberContact database table
 * @param postcode                 Direct from memberContact database table
 * @param countyRef                Direct from memberContact database table
 * @param contactTitleRef          Direct from memberContact database table
 * @param contactFirstName         Direct from memberContact database table
 * @param contactSurname           Direct from memberContact database table
 * @param telephone                Direct from memberContact database table
 * @param mobile                   Direct from memberContact database table
 * @param fax                      Direct from memberContact database table
 * @param webAddress               Direct from memberContact database table
 * @param whereDidYouHearRef       Direct from memberContact database table
 * @param whereDidYouHearOther     Direct from memberContact database table
 * @param whereDidYouHearMagazine  Direct from memberContact database table
 */
  public MemberContact( int    memberContactId,
                        Date   lastUpdatedDate,
                        String name,
                        int    statusRef,
                        String statusOther,     //this is not actually used but may well be re-introduced into code - it will always be null
                        int    primaryCategoryRef,
                        int    primaryDisciplineRef,
                        int    secondaryCategoryRef,
                        int    secondaryDisciplineRef,
                        int    tertiaryCategoryRef,
                        int    tertiaryDisciplineRef,
                        int    sizeRef,
                        int    countryRef,
                        int    regionRef,
                        String address1,
                        String address2,
                        String city,
                        String postcode,
                        int    countyRef,
                        int    contactTitleRef,
                        String contactFirstName,
                        String contactSurname,
                        String telephone,
                        String mobile,
                        String fax,
                        String webAddress,
                        int    whereDidYouHearRef,
                        String whereDidYouHearOther,
                        String whereDidYouHearMagazine )
  {
    this.memberContactId         = memberContactId;
    this.lastUpdatedDate         = lastUpdatedDate;
    this.name                    = name;
    this.statusRef               = statusRef;
    this.statusOther             = statusOther;    //this is not actually used any more but may well be put back in, as it is it's always null
    this.primaryCategoryRef      = primaryCategoryRef;
    this.primaryDisciplineRef    = primaryDisciplineRef;
    this.secondaryCategoryRef    = secondaryCategoryRef;
    this.secondaryDisciplineRef  = secondaryDisciplineRef;
    this.tertiaryCategoryRef     = tertiaryCategoryRef;
    this.tertiaryDisciplineRef   = tertiaryDisciplineRef;
    this.sizeRef                 = sizeRef;
    this.countryRef              = countryRef;
    this.regionRef               = regionRef;
    this.address1                = address1;
    this.address2                = address2;
    this.city                    = city;
    this.postcode                = postcode;
    this.countyRef               = countyRef;
    this.contactTitleRef         = contactTitleRef;
    this.contactFirstName        = contactFirstName;
    this.contactSurname          = contactSurname;
    this.telephone               = telephone;
    this.mobile                  = mobile;
    this.fax                     = fax;
    this.webAddress              = webAddress;
    this.whereDidYouHearRef      = whereDidYouHearRef;
    this.whereDidYouHearOther    = whereDidYouHearOther;
    this.whereDidYouHearMagazine = whereDidYouHearMagazine;
  }

/**
 * Gets the Primary Category Description looked up from DropDowns.properties
 *
 * @return   Primary Category Description
 */
  public String getPrimaryCategoryDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "categoryref." + primaryCategoryRef );
  }

/**
 * Gets the Secondary Category Description looked up from DropDowns.properties
 *
 * @return   Secondary Category Description
 */
  public String getSecondaryCategoryDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "categoryref." + secondaryCategoryRef );
  }

/**
 * Gets the Tertiary Category Description looked up from DropDowns.properties
 *
 * @return   Tertiary Category Description
 */
  public String getTertiaryCategoryDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "categoryref." + tertiaryCategoryRef );
  }

/**
 * Gets the Primary Discipline Description looked up from DropDowns.properties
 *
 * @return   Primary Discipline Description
 */
  public String getPrimaryDisciplineDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "disciplineref." + primaryCategoryRef + "." + primaryDisciplineRef );
  }

/**
 * Gets the Secondary Discipline Description looked up from DropDowns.properties
 *
 * @return   Secondary Discipline Description
 */
  public String getSecondaryDisciplineDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "disciplineref." + secondaryCategoryRef + "." + secondaryDisciplineRef );
  }

/**
 * Gets the Tertiary Discipline Description looked up from DropDowns.properties
 *
 * @return   Tertiary Discipline Description
 */
  public String getTertiaryDisciplineDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "disciplineref." + tertiaryCategoryRef + "." + tertiaryDisciplineRef );
  }

/**
 * Gets the Country Description looked up from DropDowns.properties
 *
 * @return   Country Description
 */
  public String getCountryDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "countryref." + countryRef );
  }

/**
 * Gets the Region Description looked up from DropDowns.properties
 *
 * @return   Region Description
 */
  public String getRegionDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "ukregionref." + regionRef );
  }

/**
 * Gets the County Description looked up from DropDowns.properties
 *
 * @return   County Description
 */
  public String getCountyDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "countyref." + regionRef + "." + countyRef );
  }

/**
 * Gets the Status Description looked up from DropDowns.properties
 *
 * @return   Status Description
 */
  public String getStatusDesc()
  {
    PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );

    return ddProps.getString( "statusref." + statusRef );
  }

/**
 * compares two MemberContact objects - similar to equals, but does not check memberContactId or lastUpdatedDate - used to see if someone has changed their details or left them untouched when submitting the member contact details form
 *
 * @param that  object to make the comparison on
 * @return      true if details remain unchanged, false otherwise
 */
  public boolean hasSameDetailsAs( MemberContact that )
  {
    //NOTE two strings will only ever be == if they are both null
    return (
      ( this.name                    == that.name                    || this.name.equals(                    that.name )                    ) &&
      ( this.statusRef               == that.statusRef                                                                                      ) &&
      ( this.statusOther             == that.statusOther             || this.statusOther.equals(             that.statusOther )             ) &&
      ( this.primaryCategoryRef      == that.primaryCategoryRef                                                                             ) &&
      ( this.primaryDisciplineRef    == that.primaryDisciplineRef                                                                           ) &&
      ( this.secondaryCategoryRef    == that.secondaryCategoryRef                                                                           ) &&
      ( this.secondaryDisciplineRef  == that.secondaryDisciplineRef                                                                         ) &&
      ( this.tertiaryCategoryRef     == that.tertiaryCategoryRef                                                                            ) &&
      ( this.tertiaryDisciplineRef   == that.tertiaryDisciplineRef                                                                          ) &&
      ( this.sizeRef                 == that.sizeRef                                                                                        ) &&
      ( this.countryRef              == that.countryRef                                                                                     ) &&
      ( this.regionRef               == that.regionRef                                                                                      ) &&
      ( this.address1                == that.address1                || this.address1.equals(                that.address1 )                ) &&
      ( this.address2                == that.address2                || this.address2.equals(                that.address2 )                ) &&
      ( this.city                    == that.city                    || this.city.equals(                    that.city )                    ) &&
      ( this.postcode                == that.postcode                || this.postcode.equals(                that.postcode )                ) &&
      ( this.countyRef               == that.countyRef                                                                                      ) &&
      ( this.contactTitleRef         == that.contactTitleRef                                                                                ) &&
      ( this.contactFirstName        == that.contactFirstName        || this.contactFirstName.equals(        that.contactFirstName )        ) &&
      ( this.contactSurname          == that.contactSurname          || this.contactSurname.equals(          that.contactSurname )          ) &&
      ( this.telephone               == that.telephone               || this.telephone.equals(               that.telephone )               ) &&
      ( this.mobile                  == that.mobile                  || this.mobile.equals(                  that.mobile )                  ) &&
      ( this.fax                     == that.fax                     || this.fax.equals(                     that.fax )                     ) &&
      ( this.webAddress              == that.webAddress              || this.webAddress.equals(              that.webAddress )              ) &&
      ( this.whereDidYouHearRef      == that.whereDidYouHearRef                                                                             ) &&
      ( this.whereDidYouHearOther    == that.whereDidYouHearOther    || this.whereDidYouHearOther.equals(    that.whereDidYouHearOther )    ) &&
      ( this.whereDidYouHearMagazine == that.whereDidYouHearMagazine || this.whereDidYouHearMagazine.equals( that.whereDidYouHearMagazine ) )
    );
  }

}
