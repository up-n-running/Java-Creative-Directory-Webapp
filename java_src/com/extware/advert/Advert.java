package com.extware.advert;

import com.extware.advert.sql.AdvertSql;

import com.extware.asset.Asset;

import com.extware.utils.PropertyFile;
import com.extware.utils.SiteUtils;

import java.awt.Dimension;

import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Date;

import javax.servlet.ServletException;

/**
 * Object to hold advert details
 *
 * @author   John Milner
 */
public class Advert
{

  public int    advertId                = -1;
  public Date   creationDate            = null;
  public Date   paymentDate             = null;
  public Date   moderatedDate           = null;
  public Date   goLiveDate              = null;
  public Date   expiryDate              = null;
  public Asset  asset                   = null;
  public int    assetId                 = -1;
  public Date   dueLiveDate             = null;   //null = now
  public String name                    = null;
  public int    statusRef               = -1;
  public String statusOther             = null;
  public int    countryRef              = -1;
  public int    regionRef               = -1;
  public String address1                = null;
  public String address2                = null;
  public String city                    = null;
  public String postcode                = null;
  public int    countyRef               = -1;
  public String telephone               = null;
  public String fax                     = null;
  public String email                   = null;
  public String webAddress              = null;
  public int    whereDidYouHearRef      = -1;
  public String whereDidYouHearOther    = null;
  public String whereDidYouHearMagazine = null;
  public boolean premierePosition       = false;
  public int     durationMonths         = -1;
  public boolean onModerationHold       = false;
  public Date    wentOnHoldDate         = null;

  public  static int lowestStandardMonthlyCost = findLowestMonthlyCost( "standard" );  //used in pageHead.jsp when displaying advert placeholders
  public  static int lowestPremierMonthlyCost  = findLowestMonthlyCost( "permiere" );  // i know i've misspelt premiere throughtout the app, sorry

  private static ArrayList premiereLiveAdvertsList     = null;
  private static ArrayList standardLiveAdvertsList     = null;
  private static Date      updateCachedLiveAdvertsDate = null;

/**
 * Constructor for the Advert object
 */
  public Advert()
  {
  }

/**
 * Constructor for the Advert object
 *
 * @param advertId                 Direct from adverts table
 * @param creationDate             Direct from adverts table
 * @param paymentDate              Direct from adverts table
 * @param moderatedDate            Direct from adverts table
 * @param goLiveDate               Direct from adverts table
 * @param expiryDate               Direct from adverts table
 * @param asset                    Direct from adverts table
 * @param assetId                  Direct from adverts table
 * @param dueLiveDate              Direct from adverts table
 * @param name                     Direct from adverts table
 * @param statusRef                Direct from adverts table
 * @param statusOther              Direct from adverts table
 * @param countryRef               Direct from adverts table
 * @param regionRef                Direct from adverts table
 * @param address1                 Direct from adverts table
 * @param address2                 Direct from adverts table
 * @param city                     Direct from adverts table
 * @param postcode                 Direct from adverts table
 * @param countyRef                Direct from adverts table
 * @param telephone                Direct from adverts table
 * @param fax                      Direct from adverts table
 * @param email                    Direct from adverts table
 * @param webAddress               Direct from adverts table
 * @param whereDidYouHearRef       Direct from adverts table
 * @param whereDidYouHearOther     Direct from adverts table
 * @param whereDidYouHearMagazine  Direct from adverts table
 * @param premierePosition         Direct from adverts table
 * @param durationMonths           Direct from adverts table
 * @param onModerationHold         Direct from adverts table
 * @param wentOnHoldDate           Direct from adverts table
 */
  public Advert( int    advertId,
                 Date   creationDate,
                 Date   paymentDate,
                 Date   moderatedDate,
                 Date   goLiveDate,
                 Date   expiryDate,
                 Asset  asset,
                 int    assetId,
                 Date   dueLiveDate,
                 String name,
                 int    statusRef,
                 String statusOther,
                 int    countryRef,
                 int    regionRef,
                 String address1,
                 String address2,
                 String city,
                 String postcode,
                 int    countyRef,
                 String telephone,
                 String fax,
                 String email,
                 String webAddress,
                 int    whereDidYouHearRef,
                 String whereDidYouHearOther,
                 String whereDidYouHearMagazine,
                 boolean premierePosition,
                 int     durationMonths,
                 boolean onModerationHold,
                 Date    wentOnHoldDate )
  {
    this.advertId                = advertId               ;
    this.creationDate            = creationDate           ;
    this.paymentDate             = paymentDate            ;
    this.moderatedDate           = moderatedDate          ;
    this.goLiveDate              = goLiveDate             ;
    this.expiryDate              = expiryDate             ;
    this.asset                   = asset                  ;
    this.assetId                 = assetId                ;
    this.dueLiveDate             = dueLiveDate            ;
    this.name                    = name                   ;
    this.statusRef               = statusRef              ;
    this.statusOther             = statusOther            ;
    this.countryRef              = countryRef             ;
    this.regionRef               = regionRef              ;
    this.address1                = address1               ;
    this.address2                = address2               ;
    this.city                    = city                   ;
    this.postcode                = postcode               ;
    this.countyRef               = countyRef              ;
    this.telephone               = telephone              ;
    this.fax                     = fax                    ;
    this.email                   = email                  ;
    this.webAddress              = webAddress             ;
    this.whereDidYouHearRef      = whereDidYouHearRef     ;
    this.whereDidYouHearOther    = whereDidYouHearOther   ;
    this.whereDidYouHearMagazine = whereDidYouHearMagazine;
    this.premierePosition        = premierePosition       ;
    this.durationMonths          = durationMonths         ;
    this.onModerationHold        = onModerationHold       ;
    this.wentOnHoldDate          = wentOnHoldDate         ;
  }

/**
 * Gets the HtmlFileName of the file (ie src value for img tag or href value for anchor tag)
 *
 * @return                 the original / post processed file name and path relative to the webapp root
 */
  public String getHtmlFileName()
  {
    return getHtmlFileName( null );
  }

/**
 * Gets the HtmlFileName of the file (ie src value for img tag or href value for anchor tag)
 *
 * @param postProcessName  name of post process if it's an image and you don't just want the original asset
 * @return                 the original / post processed file name and path relative to the webapp root
 */
  public String getHtmlFileName( String postProcessName )
  {
    if( asset == null && assetId != -1 )
    {
      try
      {
        asset = new Asset( assetId );
      }
      catch( SQLException sex )
      {
      }
    }

    if( postProcessName != null )
    {
      return getDirSep() + asset.getImageBaseDir( postProcessName ) + getDirSep() + asset.getImagePath( postProcessName );
    }
    else
    {
      return getDirSep() + asset.getFileBaseDir() + getDirSep() + asset.getFilePath();
    }
  }

/**
 * for images - it returns an image tag declaration for resized image corresponding to passed in Post Process name. tag has src, width and height attributes already set.
 *
 * @param postProcessName  name of post process
 * @return                 the image tag, as a string
 */
  public String getPostProcessAssetHtml( String postProcessName )
  {
    if( asset == null && assetId != -1 )
    {
      try
      {
        asset = new Asset( assetId );
      }
      catch( SQLException sex )
      {
      }
    }

    return "<a href=\"" + webAddress + "\" target=\"_blank\"><img border=\"1\" style=\"border-width: 1px; border-color: #717171\" width=\"" + 150 + "\" height=\"" + 46 + "\" src=\"" + getHtmlFileName( postProcessName ) + "\" /></a>";
  }

/**
 * deletes advert and asset rows from database and also deletes files from filesystem
 *
 * @exception ServletException  thrown if filesystem or database error.
 */
  public void deleteMe() throws ServletException
  {
    try
    {
      if( this.asset == null && this.assetId != -1 )
      {
        this.asset = new Asset( this.assetId );
      }
      if( this.asset != null )
      {
        this.asset.deleteFiles();
        this.asset.deleteRow();  //due to ingegrity constraints advert table row will be deleted too, magic.
      }
    }
    catch( Exception ex )
    {
      throw new ServletException( ex.toString() );
    }
  }

/**
 * finds webapp relative path to assets folder
 *
 * @return   asset.getFileBaseDir();
 */
  private String getAssetsFolderPath()
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    return dataDictionary.getString( "dirsep" ) + asset.getFileBaseDir();
  }

/**
 * finds path relative to webapp root
 *
 * @return   asset.getImageBaseDir( null );
 */
  private String getWebassetsFolderPath()
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    return dataDictionary.getString( "dirsep" ) + asset.getImageBaseDir( null );
  }

/**
 * finds filesystem path to assets folder
 *
 * @return   The AssetsFolder value
 */
  private String getAssetsFolder()
  {
    return getWebappBaseDir() + getAssetsFolderPath();
  }

/**
 * Gets the Web assets Folder
 *
 * @return   the Web assets Folder
 */
  private String getWebassetsFolder()
  {
    return getWebappBaseDir() + getWebassetsFolderPath();
  }

/**
 * Gets the DirSep from data dictionary - done like this cos i wanted to use / even on windows
 *
 * @return   The DirSep value
 */
  private String getDirSep()
  {
    return ( PropertyFile.getDataDictionary() ).getString( "dirsep" );
  }

/**
 * Gets the webapp root
 *
 * @return   The webapp root
 */
  private static String getWebappBaseDir()
  {
    return SiteUtils.getWebappRoot();
  }

/**
 * Sets the premiereLiveAdvertsList attribute of the Advert class
 *
 * @param ads  The new premiereLiveAdvertsList ArrayList
 */
  public static synchronized void setPremiereLiveAds( ArrayList ads )
  {
    premiereLiveAdvertsList = ads;
  }

/**
 * Sets the standardLiveAdvertsList attribute of the Advert class
 *
 * @param ads  The new standardLiveAdvertsList value
 */
  public static synchronized void setStandardLiveAds( ArrayList ads )
  {
    standardLiveAdvertsList = ads;
  }

/**
 * Gets the premiereLiveAdvertsList attribute of the Advert class. this variable is cached so if it's been a while before list was last updated, we refresh the list first.
 *
 * @return                      The cached premiereLiveAdvertsList value
 * @exception ServletException  thrown if there's a database exception updating ads list
 */
  public static synchronized ArrayList getPremiereLiveAds() throws ServletException
  {
    if( premiereLiveAdvertsList == null || updateCachedLiveAdvertsDate == null || updateCachedLiveAdvertsDate.before( new Date() ) )
    {
      updateLiveAdvertsList();
      updateCachedLiveAdvertsDate = new Date( new Date().getTime() + 1000L * 60L * 60L * 4L );
    }

    return premiereLiveAdvertsList;
  }

/**
 * Gets the standardLiveAdvertsList attribute of the Advert class. this variable is cached so if it's been a while before list was last updated, we refresh the list first.
 *
 * @return                      The cached standardLiveAdvertsList value
 * @exception ServletException  thrown if there's a database exception updating ads list
 */
  public static synchronized ArrayList getStandardLiveAds() throws ServletException
  {
    if( standardLiveAdvertsList == null || updateCachedLiveAdvertsDate == null || updateCachedLiveAdvertsDate.before( new Date() ) )
    {
      updateLiveAdvertsList();
      updateCachedLiveAdvertsDate = new Date( new Date().getTime() + 1000L * 60L * 60L * 4L );
    }

    return standardLiveAdvertsList;
  }

/**
 * Updates the static standardLiveAdvertsList and premiereLiveAdvertsList attributes of the class to reflect the current live adverts. IE it refreshes the cache
 *
 * @exception ServletException  thrown if there's a database exception updating ads list
 */
  public static void updateLiveAdvertsList() throws ServletException
  {
    ArrayList allLiveAdverts = AdvertSql.loadLiveAdverts();
    ArrayList stdAds = new ArrayList();
    ArrayList premAds = new ArrayList();
    Advert tempAd;

    for( int i = 0; i < allLiveAdverts.size(); i++ )
    {
      tempAd = (Advert)allLiveAdverts.get( i );

      if( tempAd.asset == null && tempAd.assetId != -1 )
      {
        try
        {
          tempAd.asset = new Asset( tempAd.assetId );
        }
        catch( SQLException ex )
        {
          throw new ServletException( ex.toString() );
        }
      }

      if( tempAd.premierePosition )
      {
        premAds.add( tempAd );
      }
      else
      {
        stdAds.add( tempAd );
      }
    }

    setPremiereLiveAds( premAds );
    setStandardLiveAds( stdAds );
  }

/**
 * called on app initialisation - finds lowest standard and premiere pricing options's monthly price
 *
 * @param type  "standard" for standard, "permiere" for premiere //misspelt - sorry
 * @return      Description of the Returned Value
 */
  private static int findLowestMonthlyCost( String type )
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    int noOfOptions = dataDictionary.getInt( "advertising.noOfOptions" );
    int lowestPrice = 9999999;
    int tempPrice;

    for( int i = 1; i <= noOfOptions; i++ )
    {
      tempPrice = (int)Math.ceil( (double)( dataDictionary.getInt( "advertising.option." + i + "." + type + "CostPounds" ) ) / (double)( dataDictionary.getInt( "advertising.option." + i + ".durationInMonths" ) ) );
      lowestPrice = lowestPrice <= tempPrice ? lowestPrice : tempPrice;
    }

    return lowestPrice;
  }

}

