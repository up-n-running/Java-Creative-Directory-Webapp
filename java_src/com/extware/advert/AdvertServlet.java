package com.extware.advert;

import com.extware.advert.sql.AdvertSql;

import com.extware.asset.Asset;
import com.extware.asset.AssetManager;
import com.extware.asset.ProcessResults;

import com.extware.framework.SuperServlet;

import com.extware.member.Member;

import com.extware.member.MemberClient;
import com.extware.utils.BooleanUtils;
import com.extware.utils.EncodeUtils;

import com.extware.utils.EmailAddressUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PropertyFile;
import com.extware.utils.SiteUtils;
import com.extware.utils.UploadUtils;
import java.io.IOException;

import java.sql.SQLException;

import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servet used when passing from / to advertsEdit.jsp
 * Also used then from data has errors, it passes the faulty object back to the source jsp with an arraylist of error messages
 *
 * @author   John Milner
 */
public class AdvertServlet extends SuperServlet
{

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
 * Servet used when passing from / to advertsEdit.jsp
 * Also used then from data has errors, it passes the faulty object back to the source jsp with an arraylist of error messages
 * @param request               request
 * @param response              response
 * @exception IOException       IOException
 * @exception ServletException  ServletException
 */
  public void doPost( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
  {
    Member loggedInMember = (Member)( request.getSession().getAttribute( "member" ) );
    String redirectTo = request.getParameter( "redirectto" ) == null ? "/pages/advertsPayment.jsp" : request.getParameter( "redirectto" );
    Advert formAdvert = null;
System.out.println( "AD SERVLET redirectTo" );
    UploadUtils req = null;
    if( request.getContentType() != null && request.getContentType().toLowerCase().indexOf( "multipart/form-data" ) == 0 )
    {
      req = new UploadUtils( getServletConfig(), request, response );
    }

    //create member job object
    formAdvert = createAdvert( req );

    //check form (not file input) for validity..
    ArrayList errors = checkAdvertDetails( formAdvert, req );
    errors.addAll( checkJustTermsCheck( req ) );

    //adtypecheck
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    int noOfOptions = dataDictionary.getInt( "advertising.noOfOptions" );
    boolean adTypePremiere = false;
    int optionNumber = -1;

    for( int i = 1; i <= noOfOptions; i++ )
    {
      if( BooleanUtils.isTrue( ( req ).getParameter( "premiereposition" + i ) ) )
      {
        adTypePremiere = true;
        optionNumber = i;
        break;
      }
      if( BooleanUtils.isTrue( req.getParameter( "standardposition" + i ) ) )
      {
        adTypePremiere = false;
        optionNumber = i;
        break;
      }
    }

    if( optionNumber == -1 )
    {
      errors.add( "Please select whether you would like The Premiere or Standard position advert" );
    }

    request.setAttribute( "optionnumber", String.valueOf( optionNumber ) );

    if( errors.size() > 0 )
    {
      returnWithErrorMessages( request, response, errors, formAdvert, "/pages/advertsEdit.jsp" );
      return;
    }

    int fileNumber = req.getFileNumber( "advertfile" );
    boolean fileExists = !req.isFileMissing( fileNumber );

    //check File size against max limit
    long fileByteSize = req.getFileSize( fileNumber );

    //fail if file does not exist
    if( !fileExists || fileByteSize == 0 )
    {
      errors.add( "Please select a file to be uploaded." );
    }

    if( fileByteSize > dataDictionary.getInt( "advertFile.maxStorageBytes" ) )
    {
      errors.add( "Your file could not be uploaded as it was larger than " + (int)( dataDictionary.getInt( "advertFile.advertFile.maxStorageBytes" ) / ( 1024 * 1024 ) ) + "mb. Try using a gif or jpeg, or try resizing the image to make it smaller before upload." );
    }

    //find mime type and set image/not image specific properties
    String mimeType = req.getFileMimeType( fileNumber );

    //if it's an image - set file type Id
    int assetTypeId = dataDictionary.getInt( "advertFile.image.assetTypeId" );
    if( !mimeType.toUpperCase().startsWith( "IMAGE" ) )
    {
      errors.add( "Your file is not an image and so cannot be processed to be displayed as an advert, please select an image file to upload." );
    }

    if( errors.size() > 0 )
    {
      returnWithErrorMessages( request, response, errors, formAdvert, "/pages/advertsEdit.jsp" );
      return;
    }

    //upload image
    ProcessResults processResults = AssetManager.processUpload( assetTypeId, req, "advertfile", formAdvert.name + "_AD", false );

    //create asset
    Asset asset;
    if( processResults != null && processResults.assets != null && processResults.assets.size() == 1 )
    {
      asset = (Asset)processResults.assets.get( 0 );
    }
    else
    {
      throw new IOException( "FILE upload: " + processResults == null ? "processResults = null" : ( processResults.assets == null ? "processResults.assets = null" : "processResults.assets.size() = " + processResults.assets.size() ) );
    }

    //check size contstraints
    int adHeight = dataDictionary.getInt( "advertising.advertHeightInPixels" );
    int adWidth = dataDictionary.getInt( "advertising.advertWidthInPixels" );
    float aspectRatio = (float)asset.assetWidth / (float)asset.assetHeight;
    float idealAspectRatio = (float)adWidth / (float)adHeight;

    if( errors.size() > 0 )
    {
      //delete the file
      String webappBaseDir = SiteUtils.getWebappRoot() + dataDictionary.getString( "dirsep" );
      String assetsFolder = webappBaseDir + dataDictionary.getString( "asset.dir.original." + asset.assetTypeId );
      String webassetsFolder = webappBaseDir + dataDictionary.getString( "asset.dir.proccessed." + asset.assetTypeId );

      asset.deleteFiles();

      try
      {
        asset.deleteRow();
      }
      catch( SQLException sex )
      {
        throw new ServletException( sex.toString() );
      }

      returnWithErrorMessages( request, response, errors, formAdvert, "/pages/advertsEdit.jsp" );
      return;
    }

    //add asset to object and save in database
    formAdvert.asset = asset;
    formAdvert.assetId = asset.assetId;

    AdvertSql.saveAdvertForModeraion( formAdvert );  //this does not update mainFile and portFolioFile pointers

    request.setAttribute( "paymentadvert", formAdvert );

    redirectJsp( request, response, redirectTo );
    return;
  }

/**
 * Looks at paramater values on request from advertEdit.jsp to create an Advert object
 *
 * @param request  Description of Parameter
 * @return         Description of the Returned Value
 */
  public Advert createAdvert( UploadUtils request )
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();
    int noOfOptions = dataDictionary.getInt( "advertising.noOfOptions" );
    boolean adTypePremiere = false;
    int optionNumber = -1;

    for( int i = 1; i <= noOfOptions; i++ )
    {
      if( BooleanUtils.isTrue( request.getParameter( "premiereposition" + i ) ) )
      {
        adTypePremiere = true;
        optionNumber = i;
        break;
      }
      if( BooleanUtils.isTrue( request.getParameter( "standardposition" + i ) ) )
      {
        adTypePremiere = false;
        optionNumber = i;
        break;
      }
    }

    Advert advert = new Advert(
        NumberUtils.parseInt( ( (UploadUtils)request ).getParameter( "advertid" ), -1 ),
        null,  //creationDate,
        null,  //paymentDate,
        null,  //moderatedDate,
        null,  //goLiveDate,
        null,  //expiryDate
        null,  //asset,
        -1,    //assetId,
        null,  //DUELIVEDATE SORT THIS OUT
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "name" ).trim() ),
        NumberUtils.parseInt( ( (UploadUtils)request ).getParameter( "advertstatusref" ), -1 ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "statusother" ) ),
        NumberUtils.parseInt( ( (UploadUtils)request ).getParameter( "countryref" ), -1 ),
        NumberUtils.parseInt( ( (UploadUtils)request ).getParameter( "ukregionref" ), -1 ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "address1" ) ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "address2" ) ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "city" ) ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "postcode" ) ),
        NumberUtils.parseInt( ( (UploadUtils)request ).getParameter( "countyref" ), -1 ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "telephone" ) ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "fax" ) ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "email" ).trim() ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "webaddress" ).trim() ),
        NumberUtils.parseInt( ( (UploadUtils)request ).getParameter( "wheredidyouhearref" ), -1 ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "wheredidyouhearother" ) ),
        EncodeUtils.HTMLEncode( ( (UploadUtils)request ).getParameter( "wheredidyouhearmagazine" ) ),
        adTypePremiere,
        ( optionNumber == -1 ? -1 : dataDictionary.getInt( "advertising.option." + optionNumber + ".durationInMonths" ) ),
        false,
        null
    );

    return advert;
  }

/**
 * Checks that all the fields have been filled in correctly on advertEdit.jsp Form, any errors it adds to an arraylist of string error messages to return to user
 *
 * @param advert                Description of Parameter
 * @param request               Description of Parameter
 * @return                      Description of the Returned Value
 * @exception ServletException  Description of Exception
 */
  public ArrayList checkAdvertDetails( Advert advert, UploadUtils request ) throws ServletException
  {
    PropertyFile dropDownProps = new PropertyFile( "com.extware.properties.DropDowns" );
    ArrayList errors = new ArrayList();

    if( advert.name.length() == 0 )
    {
      errors.add( "You must enter a name" );
    }

    if( advert.statusRef == -1 )
    {
      errors.add( "You must enter a status" );
    }
    else if( advert.statusRef == dropDownProps.getInt( "statusref.othersHandle.1" ) && advert.statusOther.length() == 0 )
    {
      //there seems to be a problem with this
      errors.add( "You selected a status of 'Other' please give details" );
    }

    if( advert.countryRef == -1 )
    {
      errors.add( "You must enter your country of operation" );
    }

    if( advert.countryRef == PropertyFile.getDataDictionary().getInt( "dropdowns.countryCode.UK" ) )
    {
      if( advert.regionRef == -1 )
      {
        errors.add( "If you are in the UK you must select your region" );
      }
      else if( advert.countyRef == -1 )
      {
        errors.add( "If you are in the UK you must select your county" );
      }
    }

    if( advert.address1.length() == 0 )
    {
      errors.add( "You must enter your address line 1" );
    }

    if( advert.city.length() == 0 )
    {
      errors.add( "You must enter your city" );
    }

    if( advert.postcode.length() == 0 )
    {
      errors.add( "You must enter your postcode" );
    }

    if( advert.telephone.length() == 0 )
    {
      errors.add( "You must enter a contact telephone number" );
    }

    if( !EmailAddressUtils.isValidEmailAddress( advert.email ) )
    {
      errors.add( "The email address entered is not a valid email address" );
    }
    else if( !advert.email.equals( request.getParameter( "confirmemail" ).trim() ) )
    {
      errors.add( "Your email and confirm email entries did not match" );
      request.setAttribute( "confirmemail", request.getParameter( "confirmemail" ).trim() );
    }

    if( advert.webAddress.length() < 5 || !advert.webAddress.toUpperCase().startsWith( "HTTP://" ) || advert.webAddress.indexOf( "." ) == -1 )
    {
      errors.add( "Please begin your web address with 'http://' and make sure it is a valid url ( eg http://www.nextface.net ), this way the link is guaranteed to work on all browsers" );
    }
    else if( !advert.webAddress.equals( request.getParameter( "confirmwebaddress" ).trim() ) )
    {
      errors.add( "Your web address and confirm web address entries did not match" );
      request.setAttribute( "confirmwebaddress", request.getParameter( "confirmwebaddress" ).trim() );
    }

    if( advert.whereDidYouHearRef == -1 )
    {
      errors.add( "Please tell us where you heard about us" );
    }
    else if( advert.whereDidYouHearRef == dropDownProps.getInt( "wheredidyouhearref.othersHandle.1" ) && advert.whereDidYouHearOther.length() == 0 )
    {
      errors.add( "Under 'Where did you hear about us' you selected 'Other', please give details" );
    }
    else if( advert.whereDidYouHearRef == dropDownProps.getInt( "wheredidyouhearref.othersHandle.2" ) && advert.whereDidYouHearMagazine.length() == 0 )
    {
      errors.add( "Please tell us in which magazine you heard about us" );
    }

    return errors;
  }

/**
 * checks request to see whether taste and terms checkbox was checked of source form
 *
 * @param request               request from source jsp
 * @return                      Empty arraylist of checked, ArrayList witrh one string error message if not
 * @exception ServletException  Description of Exception
 */
  public ArrayList checkJustTermsCheck( UploadUtils request )
  {
    ArrayList errors = new ArrayList();

    if( ( (UploadUtils)request ).getParameter( "termscheck" ) == null )
    {
      errors.add( "You have not declared that your submission meets the Nextface Terms And Conditions" );
    }

    return errors;
  }

/**
 * Description of the Method
 *
 * @param request               request object
 * @param response              response object
 * @param errors                ArrayList of string error messagedto display
 * @param formMember            the advert (with potentially incorrect details) we are trying to edit
 * @param redirect              source servlet name
 * @exception IOException       if error finding jsp
 * @exception ServletException  servletexception
 */
  private void returnWithErrorMessages( HttpServletRequest request, HttpServletResponse response, ArrayList errors, Advert advert, String redirect ) throws IOException, ServletException
  {
    request.setAttribute( "errors", errors );
    request.setAttribute( "formadvert", advert );

    redirectJsp( request, response, redirect );
  }

}
