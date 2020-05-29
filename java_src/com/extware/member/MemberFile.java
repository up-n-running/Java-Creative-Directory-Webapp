package com.extware.member;
import com.extware.asset.Asset;

import com.extware.utils.PropertyFile;
import com.extware.utils.SiteUtils;
import com.extware.utils.StringUtils;
import java.awt.Dimension;

import java.sql.SQLException;

import java.util.Date;

import javax.servlet.ServletException;

/**
 * Descriptor for Member File Object - related to an uploaded file on registerPortfilioFiles.jsp
 *
 * @author   John Milner
 */
public class MemberFile
{

  public int     memberFileId    = -1;
  public Asset   asset           = null;
  public int     assetId;
  public String  description     = null;
  public String  keywords        = null;
  public String  displayFileName = null;
  public String  mimeType        = null;
  public long    fileByteSize    = -1;
  public boolean isImage         = false;
  public boolean mainFile        = false;
  public boolean portraitImage   = false;
  public boolean forModeration   = true;
  public Date    uploadDate      = null;

/**
 * Constructor for the MemberFile object
 */
  public MemberFile()
  {
  }

/**
 * Subset Constructor for search results
 *
 * @param memberFileId   Direct from memberFile database table
 * @param assetId        Direct from memberFile database table
 * @param isImage        Direct from memberFile database table
 * @param mainFile       Direct from memberFile database table
 * @param portraitImage  Direct from memberFile database table
 * @param mimeType       Direct from memberFile database table
 */
  public MemberFile( int memberFileId, int assetId, boolean isImage, boolean mainFile, boolean portraitImage, String mimeType )
  {
    this.memberFileId  = memberFileId;
    this.assetId       = assetId;
    this.isImage       = isImage;
    this.mainFile      = mainFile;
    this.portraitImage = portraitImage;
    this.mimeType      = mimeType;
  }

/**
 * Constructor for the MemberFile object
 *
 * @param memberFileId     Direct from memberFile database table
 * @param asset            Direct from assets database table( linked to by memberFile table ). often not used and left as null
 * @param assetId          Direct from memberFile database table
 * @param description      Direct from memberFile database table
 * @param keywords         Direct from memberFile database table
 * @param displayFileName  Direct from memberFile database table
 * @param mimeType         Direct from memberFile database table
 * @param fileByteSize     Direct from memberFile database table
 * @param isImage          Direct from memberFile database table
 * @param mainFile         Direct from memberFile database table
 * @param portraitImage    Direct from memberFile database table
 * @param forModeration    Direct from memberFile database table
 * @param uploadDate       Direct from memberFile database table
 */
  public MemberFile( int     memberFileId,
                     Asset   asset,
                     int     assetId,
                     String  description,
                     String  keywords,
                     String  displayFileName,
                     String  mimeType,
                     long    fileByteSize,
                     boolean isImage,
                     boolean mainFile,
                     boolean portraitImage,
                     boolean forModeration,
                     Date    uploadDate )
  {
    this.memberFileId    = memberFileId;
    this.asset           = asset;
    this.assetId         = assetId;
    this.description     = description;
    this.keywords        = keywords;
    this.displayFileName = displayFileName;
    this.mimeType        = mimeType;
    this.fileByteSize    = fileByteSize;
    this.isImage         = isImage;
    this.mainFile        = mainFile;
    this.portraitImage   = portraitImage;
    this.forModeration   = forModeration;
    this.uploadDate      = uploadDate;
  }

/**
 * Gets ans splits the seywords attribute of the MemberFile object
 *
 * @return   string array of keywords for file
 */
  public String[] getKeywordList()
  {
    return StringUtils.split( keywords, "\\s*,\\s*" );
  }

/**
 * Gets the HtmlFileName attribute of the MemberFile object
 *
 * @return   The HtmlFileName value
 */
  public String getHtmlFileName()
  {
    return getHtmlFileName( null );
  }

/**
 * Gets the HtmlFileName of the file (ie src value for img tag or href value for anchor tag)
 *
 * @param postProcessName  name of post process if it's an image, else it's ignored
 * @return                 the original / post processed file name and path relative to the webapp root
 */
  public String getHtmlFileName( String postProcessName )
  {
    //if asset object not already instantiated for this object - do it now.
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

    if( isImage && postProcessName != null )
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
    //if asset object not already instantiated for this object - do it now.
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

    boolean border = false;

    if( postProcessName.equals( "SrchResults" ) )
    {
      border = true;
    }

    if( isImage )
    {
      Dimension imDim = asset.getImageDimensions( postProcessName );

      if( postProcessName.equals( "SrchResults" ) )
      {
        imDim.width = getWidth( postProcessName, true );
        imDim.height = getHeight( postProcessName, true );
      }

      return "<img " + ( border ? "border=\"0\" style=\"border: 1px; border-color: #717171\" " : "" ) + "width=\"" + imDim.width + "\" height=\"" + imDim.height + "\" src=\"" + getHtmlFileName( postProcessName ) + "\" />";
    }
    else if( mimeType.toUpperCase().startsWith( "AUDIO/" ) )
    {
      return "<img " + ( border ? "border=\"0\" style=\"border: 1px; border-color: #717171\" " : "" ) + "width=\"" + getWidth( postProcessName, isImage ) + "\" height=\"" + getHeight( postProcessName, isImage ) + "\" src=\"/art/placeholders/audio" + postProcessName + ".gif\" />";
    }
    else if( mimeType.toUpperCase().startsWith( "VIDEO/" ) )
    {
      return "<img " + ( border ? "border=\"0\" style=\"border: 1px; border-color: #717171\" " : "" ) + "width=\"" + getWidth( postProcessName, isImage ) + "\" height=\"" + getHeight( postProcessName, isImage ) + "\" src=\"/art/placeholders/video" + postProcessName + ".gif\" />";
    }
    else
    {
      return "<img " + ( border ? "border=\"0\" style=\"border: 1px; border-color: #717171\" " : "" ) + "width=\"" + getWidth( postProcessName, isImage ) + "\" height=\"" + getHeight( postProcessName, isImage ) + "\" src=\"/art/placeholders/text" + postProcessName + ".gif\" />";
    }

  }

/**
 * deletes memberfile and asset rows drom database and also deletes file / files from filesystem
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
        this.asset.deleteRow();  //due to ingegrity constraints memberfile row will be deleted too, magic.
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
    return asset.getFileBaseDir();
  }

/**
 * finds path relative to webapp root
 *
 * @return   asset.getImageBaseDir( null );
 */
  private String getWebassetsFolderPath()
  {
    return asset.getImageBaseDir( null );
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
 * Gets the Width of padded post process rules
 *
 * @param postProcessName   Name of padded post process rule
 * @param isImage           Currently not used, but there for future expansion
 * @return                  The Width
 */
  private int getWidth( String postProcessName, boolean isImage )
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    int width = dataDictionary.getInt( "paddedpostprocessrule." + postProcessName + ".width" );

    if( width < 1 )
    {
      return dataDictionary.getInt( "paddedpostprocessrule.default.width" );
    }

    return width;
  }

 /**
 * Gets the Height of padded post process rules
 *
 * @param postProcessName   Name of padded post process rule
 * @param isImage           Currently not used, but there for future expansion
 * @return                  The Height
 */
  private int getHeight( String postProcessName, boolean isImage )
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    int height = dataDictionary.getInt( "paddedpostprocessrule." + postProcessName + ".height" );

    if( height < 1 )
    {
      return dataDictionary.getInt( "paddedpostprocessrule.default.height" );
    }

    return height;
  }

}
