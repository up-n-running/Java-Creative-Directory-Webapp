package com.extware.member;

import com.extware.asset.Asset;
import com.extware.asset.AssetManager;
import com.extware.asset.ProcessResults;

import com.extware.framework.SuperServlet;

import com.extware.member.MemberClient;

import com.extware.utils.EncodeUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PropertyFile;
import com.extware.utils.StringUtils;
import com.extware.utils.UploadUtils;

import java.io.IOException;

import java.util.ArrayList;

import javax.servlet.ServletException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servet used when passing from / to registerPortfolioFiles.jsp
 * Also used then from data has errors, it passes the faulty object back to the source jsp with an arraylist of error messages
 *
 * @author   John Milner
 */
public class MemberFilesServlet extends SuperServlet
{

  public static String hiddenListInputDelimiter = "\\t~~\\t";

/**
 * Description of the Method
 *
 * @param request               request
 * @param response              response
 * @exception IOException       IOException
 * @exception ServletException  ServletException
 */
  public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
  {
    this.doPost( request, response );
  }

/**
 * Servet used when passing from / to registerPortfolioFiles.jsp
 * Also used then from data has errors, it passes the faulty object back to the source jsp with an arraylist of error messages
 *
 * @param request               request
 * @param response              response
 * @exception IOException       IOException
 * @exception ServletException  ServletException
 */
  public void doPost( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
  {
    Member loggedInMember = (Member)( request.getSession().getAttribute( "member" ) );
    String redirectTo = StringUtils.nullReplace( request.getParameter( "redirectto" ), "/pages/accountManager.jsp" );

    if( loggedInMember == null )
    {
      // You must be logged in!!!
      redirectJsp( request, response, "/loggedOut.jsp" );
      return;
    }

    UploadUtils req = null;

    if( request.getContentType() != null && request.getContentType().toLowerCase().indexOf( "multipart/form-data" ) == 0 )
    {
      req = new UploadUtils( getServletConfig(), request, response );
    }

    //delete files marked for deletion
    String[] deleteIds = StringUtils.split( req.getParameter( "deleteids" ), hiddenListInputDelimiter );  //must be non null

    int deleteMemberFileId;

    for( int i = 0; i < deleteIds.length; i++ )
    {
      deleteMemberFileId = NumberUtils.parseInt( deleteIds[i], -1 );
      deleteAsset( deleteMemberFileId, loggedInMember );
      loggedInMember.removeMemberFile( deleteMemberFileId );
    }

    //create arraylist to keep track of file upload errors
    ArrayList errors = new ArrayList();

    //upload portrait image if one to upload.
    String newPortraitImageFile = StringUtils.nullString( req.getParameter( "portraitimage" ) );  //must be non null

    int memberFileIdTmp = -1;

    memberFileIdTmp = processFile(
        req,
        errors,
        "companylogo", newPortraitImageFile, "Company Logo", "Company Logo",
        true, loggedInMember
    );

    if( memberFileIdTmp == -2 || newPortraitImageFile == null || newPortraitImageFile.length() == 0 )
    {
      // there never really was a file to upload
      errors.remove( errors.size() - 1 );  //remove error message
    }

    if( memberFileIdTmp > -1 && loggedInMember.portraitImage != null )
    {
      if( loggedInMember.portraitImage != null )
      {
        deleteAsset( loggedInMember.portraitImage.memberFileId, loggedInMember );
        loggedInMember.removeMemberFile( loggedInMember.portraitImage.memberFileId );
      }

      loggedInMember.setNewPortraitImage( memberFileIdTmp );
    }

    //fetch new upload files parameters from jsp
    String[] files = StringUtils.split( req.getParameter( "files" ), hiddenListInputDelimiter );  //must be non null
    String[] fileDescriptions = StringUtils.split( req.getParameter( "filedescriptions" ), hiddenListInputDelimiter );  //must be non null
    String[] fileKeywords = StringUtils.split( req.getParameter( "filekeywords" ), hiddenListInputDelimiter );  //must be non null

    //find the id of the main file - if it is yet to be uploaded it will start with 'i_' and be the index in the upload array.
    String mainFileId_String = req.getParameter( "mainfileid" );   //must be non null
    int mainFileId = -1;
    int mainFileIdx = -1;

    if( mainFileId_String.startsWith( "i_" ) )
    {
      mainFileIdx = NumberUtils.parseInt( mainFileId_String.substring( 2 ), -1 );
    }
    else
    {
      mainFileId = NumberUtils.parseInt( mainFileId_String, -1 );
    }

    //add new files
    for( int i = 0; i < files.length; i++ )
    {
      if( !files[i].equals( "*" ) )
      {
        memberFileIdTmp = processFile(
            req,
            errors,
            "pfo" + i, files[i], fileDescriptions[i], fileKeywords[i],
            false, loggedInMember
        );

        if( i == mainFileIdx )
        {
          mainFileId = memberFileIdTmp;
        }
      }
    }

    if( mainFileId < 0 && mainFileIdx == -1 && files.length > 0 )
    {
      errors.add( "You did not specify which file to set as your main portfolio file." );
    }
    else if( mainFileId < 0 && mainFileIdx != -1 )
    {
      errors.add( "The file you choose as your main file could not be uploaded, currently no file is set to your main file." );
    }
    else
    {
      MemberClient.setMainFile( loggedInMember, mainFileId );  //also sets the same on member object.
    }

  /*
   *  then set it and faff arround with member object mainFile flags
   *  also change memeberSQL login to set mainFile and portFolioFile flags
   *  give memberfiles an assetId so deletion( below ) doesn't require getAssetIdFromDb method - and nor does profile details page
   */
    if( errors.size() > 0 )
    {
      returnWithErrorMessages( request, response, errors, "/pages/registerPortfolioFiles.jsp" );
      return;
    }

    redirectJsp( request, response, redirectTo );
    return;
  }

/**
 * Used to put the offending object/objects, and the arrayList of errors onto the request as attributes, then redirect to the source jsp for this servlet.
 *
 * @param request               request object
 * @param response              response object
 * @param errors                ArrayList of string error messagedto display
 * @param redirect              source servlet name
 * @exception IOException       if error finding jsp
 * @exception ServletException  servletexception
 */
  private void returnWithErrorMessages( HttpServletRequest request, HttpServletResponse response, ArrayList errors, String redirect ) throws IOException, ServletException
  {
    request.setAttribute( "errors", errors );
    redirectJsp( request, response, redirect );
  }

/**
 * given the id of the file to delete and the member from whom we are removing it, this will remove a file from filesystem and remove the relevant memberfile table row and asset table row. Also it will remove it form member object
 *
 * @param memberFileId          id of MemberFile to delete
 * @param member                member from whom we are removing the file
 * @exception ServletException  thrown if database or file system exception
 */
  private void deleteAsset( int memberFileId, Member member ) throws ServletException
  {
    MemberFile tempMemFile = member.getMemberFileById( memberFileId );
    tempMemFile.deleteMe();
  }

/**
 * Description of the Method
 *
 * @param request               request from registerPortfolioFiles.jsp
 * @param errors                response
 * @param fieldName             name of input tag in jsp for file we are to upload and process
 * @param fileName              filename for uploaded file
 * @param description           description of file to save in memberFiles table
 * @param keywords              a string of comma sep keywords to save in memberFiles table
 * @param portraitImage         true if this is to be saved as the portrait image
 * @param member                member object that we're going to add this file object to
 * @return                      the id of the returned file
 * @exception IOException       thriwn if filesystem error
 * @exception ServletException  thrown if database error
 */
  private int processFile( UploadUtils request, ArrayList errors,
      String fieldName, String fileName, String description, String keywords,
      boolean portraitImage, Member member ) throws IOException, ServletException
  {
    int fileNumber = ( (UploadUtils)request ).getFileNumber( fieldName );
    boolean fileExists = !( (UploadUtils)request ).isFileMissing( fileNumber );

    String[] splitFName = StringUtils.split( fileName, "\\\\" );
    // generate display File Name by removing path.
    String fName;

    if( splitFName == null || splitFName.length == 0 )
    {
      fName = "UNKNOWN";
    }
    else
    {
      String[] splitFName2 = StringUtils.split( splitFName[splitFName.length - 1], "/" );

      if( splitFName2 == null || splitFName2.length == 0 )
      {
        fName = "UNKNOWN";
      }

      fName = splitFName2[splitFName2.length - 1];
    }

    //check File size against tally
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    long fileByteSize = request.getFileSize( fileNumber );

    if( fileByteSize + member.getTotalFileByteSize() - ( portraitImage ? member.getPortraitImageFileByteSize() : 0 ) > dataDictionary.getInt( "portfolioFile.maxStorageBytes" ) )
    {
      errors.add( ( portraitImage ? "Portrait / Company Logo " : "" ) + "File: \"" + fileName + "\" could not be uploaded as it would take you over your storage limit." );
      return -2;
    }

    if( !fileExists || fileByteSize == 0 )
    {
      // fail if file does not exist

      errors.add( ( portraitImage ? "Portrait / Company Logo " : "" ) + "File: \"" + fileName + "\" could not be found on your compiter." );
      return -1;
    }

    //find mime type , check if mime type valid, and set image/not image specific properties
    String mimeType = request.getFileMimeType( fileNumber );
    boolean validMimeType = false;
    int dataDicMimeIterator = 1;
    String allowedMimePrefix = dataDictionary.getString( "portfolioFile.upload.mimeFilter.allow." + ( dataDicMimeIterator++ ) );

    while( !validMimeType && allowedMimePrefix != null )
    {
      if( mimeType.toUpperCase().startsWith( allowedMimePrefix.toUpperCase() ) )
      {
        validMimeType = true;
      }

      allowedMimePrefix = dataDictionary.getString( "portfolioFile.upload.mimeFilter.allow." + ( dataDicMimeIterator++ ) );
    }

    if( !validMimeType )
    {
      errors.add( "We're sorry, your Portrait / Company Logo file: \"" + fileName + "\" is an invalid file type to be displayed on the Nextface directory. If you feel files of type " + mimeType + " should be included, please contact us using the contact us section of the site." );
      return -1;
    }

    //if it's an image - set file type Id
    int assetTypeId = -1;
    boolean isImage;

    if( mimeType.toUpperCase().startsWith( "IMAGE" ) )
    {
      assetTypeId = dataDictionary.getInt( "portfolioFile.image.assetTypeId" );
      isImage = true;
    }
    else
    {
      assetTypeId = dataDictionary.getInt( "portfolioFile.nonImage.assetTypeId" );
      isImage = false;
    }

    if( portraitImage )
    {
      if( isImage )
      {
        assetTypeId = dataDictionary.getInt( "portfolioFile.portraitImage.assetTypeId" );
      }
      else
      {
        errors.add( "Your Portrait / Company Logo file: \"" + fileName + "\" is not an image." );
        return -1;
      }
    }

    ProcessResults processResults = AssetManager.processUpload( assetTypeId, (UploadUtils)request, fieldName, fName, false );

    //create asset
    Asset asset;

    if( processResults != null && processResults.assets != null && processResults.assets.size() == 1 )
    {
      asset = (Asset)processResults.assets.get( 0 );
    }
    else
    {
      throw new IOException( ( portraitImage ? "Portrait / Company Logo " : "" ) + "FILE: " + fileName + " " + processResults == null ? "processResults = null" : ( processResults.assets == null ? "processResults.assets = null" : "processResults.assets.size() = " + processResults.assets.size() ) );
    }

    //generate object
    MemberFile memberFile = new MemberFile(
        -1, //memberFileId
        asset,
        asset.assetId,
        EncodeUtils.HTMLEncode( description ),
        EncodeUtils.HTMLEncode( keywords ),
        EncodeUtils.HTMLEncode( fName ),
        mimeType,
        asset.fileByteSize,
        isImage,
        false, //mainFile - this is always set to false cos the main file is set at the end of this servlet
        portraitImage,
        true, //forModeration
        null//upload date
    );

    return MemberClient.addAndSaveMemberFileForModeraion( member, memberFile );
    //this does not update mainFile and portFolioFile point-ers
  }

}
