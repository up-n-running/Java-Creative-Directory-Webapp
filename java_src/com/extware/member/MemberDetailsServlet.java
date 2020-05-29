package com.extware.member;

import com.extware.emailSender.EmailSender;

import com.extware.framework.SuperServlet;

import com.extware.member.MemberClient;

import com.extware.utils.EmailAddressUtils;
import com.extware.utils.EncodeUtils;
import com.extware.utils.NumberUtils;
import com.extware.utils.PropertyFile;
import com.extware.utils.StringUtils;

import java.io.IOException;

import java.util.ArrayList;

import javax.servlet.ServletException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servet used when passing from / to registerContactDetails.jsp and registerProfileDetails.jsp
 * Also used then from data has errors, it passes the faulty object back to the source jsp with an arraylist of error messages
 *
 * @author   John Milner
 */
public class MemberDetailsServlet extends SuperServlet
{

/**
 * doGet
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
 * either get object from database and pass off to jsp, OR read jsp params, create object from parameter then store in database then delete, upload & resize necessary files, alter logged in member object accordingly and redirect
 *
 * @param request               request
 * @param response              response
 * @exception IOException       IOException
 * @exception ServletException  ServletException
 */
  public void doPost( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
  {
    Member loggedInMember = (Member)( request.getSession().getAttribute( "member" ) );
    String mode = StringUtils.nullString( request.getParameter( "mode" ) );
    String form = StringUtils.nullString( request.getParameter( "form" ) );
    String redirectTo = request.getParameter( "redirectto" ) == null ? "/pages/accountManager.jsp" : request.getParameter( "redirectto" );
    Member formMember = null;

    if( mode.equals( "add" ) && form.equals( "registercontactdetails" ) )
    {
      //create member object
      formMember = createMember( request );
      MemberContact memberContact = createMemberContact( request );

      //check for validity..
      ArrayList errors = checkMemberOnlyDetails( formMember, request );
      errors.addAll( checkMemberContactDetails( memberContact, request ) );

      if( errors.size() > 0 )
      {
        returnWithErrorMessages( request, response, errors, formMember, "formmembercontact", (Object)memberContact, "/pages/registerContactDetails.jsp" );
        return;
      }

      //save in database and complete member object and login
      MemberClient.saveNewMemberOnlyDetails( formMember );  //this also popuates userid, and the regdate
      MemberClient.addAndSaveMemberContactForModeraion( formMember, memberContact );  //this also popuates membercontactid and updated date, and adds memberContact to member

      //send validation email address
      boolean addressOk = EmailSender.sendMail( "emailvalidate", "Welcome to Nextface, please validate your email address", formMember, new ArrayList(), new ArrayList() );

      //if there was a problem sending email, return to jsp
      if( !addressOk )
      {
        errors.add( "There was a problem whilst sending your confirmation email, please check both your email address and validate email address fields and try again." );
      }

      if( errors.size() > 0 )
      {
        returnWithErrorMessages( request, response, errors, formMember, "formmembercontact", (Object)memberContact, "/pages/registerContactDetails.jsp" );
        return;
      }

      //added for march only
      MemberClient.setMemberAsPaid( formMember.memberId, formMember );

      //login member
      formMember.login( request );

      //System.out.println( redirectTo );
      redirectJsp( request, response, redirectTo );
      return;
    }

    //now we know you are not adding a user so you must be logged in!!!
    if( loggedInMember == null )
    {
      redirectJsp( request, response, "/loggedOut.jsp" );
      return;
    }

    if( mode.equals( "edit" ) && form.equals( "registercontactdetails" ) )
    {
      //get logged in member and create memberContact object - which we are editing
      formMember = loggedInMember;  //as you have to be logged in to edit, and you can't edit member only details, this must be the object hat corresponds to the member details on the form.
      MemberContact memberContact = createMemberContact( request );

      //now we must set the id of the memberContact object - this is not got from the form obvoiusly as it must be taken from the logged in member and we do not want to display it to the user
      if( loggedInMember.moderationMemberContact != null )
      {
        //if there isn't one we leave id, it will be generated by database, otherwise we must set it so the update updates the right row in db
        memberContact.memberContactId = loggedInMember.moderationMemberContact.memberContactId;
      }

      //check for validity..
      ArrayList errors = checkMemberContactDetails( memberContact, request );

      //check password in case they've changed it
      String passwd = request.getParameter( "passwd" ).trim();

      if( passwd.trim().length() < 5 || passwd.trim().length() > 12 )
      {
        errors.add( "Your password must be between 5 and 12 characters" );
      }

      if( !passwd.equals( request.getParameter( "confirmpasswd" ).trim() ) )
      {
        errors.add( "Your password and confirm password entries did not match, please retype both" );
      }

      //check shortcut in case they've changed it
      String profileURL = request.getParameter( "profileurl" ).trim();

      if( profileURL.length() == 0 )
      {
        errors.add( "You must enter a Nextface web address shortcut, this will form a web address that points straight to your profile page" );
      }

      if( !Member.isValidProfileURL( profileURL ) )
      {
        errors.add( "Your Nextface web address shortcut may only contain letters, numbers and the underscore '_' character." );
      }

      //final checks involve database - so only do if necessary
      if( !profileURL.equals( formMember.profileURL ) )
      {
        boolean[] uniqueCheckResults = MemberClient.checkUniqueFields( formMember.email, profileURL );

        if( !uniqueCheckResults[1] )
        {
          errors.add( "Unfortunately your chosen Nextface web address shortcut is already taken, please choose another" );
        }
      }

      //return errors if there are any
      if( errors.size() > 0 )
      {
        returnWithErrorMessages( request, response, errors, formMember, "formmembercontact", (Object)memberContact, "/pages/registerContactDetails.jsp" );
        return;
      }

      //has password or profile url changed
      if( !passwd.equals( loggedInMember.passwd ) || !profileURL.equals( loggedInMember.profileURL ) )
      {
        MemberClient.changePasswordAndEmailAndProfileUrl( formMember, passwd, profileURL, loggedInMember.email, false );
        //this changes it in db and on object
      }

      //erm, we only save this if it's different to the moderated version, and there is no unmoderated version - if the user just goes into page and clicks save, we don't want to bother the moderator to accept no changes!!!
      //this also means that if the details are moderated since the user logs in, then the user doing this will not overwrite the newly moderated data. Good eh?
      if( !( loggedInMember.moderationMemberContact == null && loggedInMember.memberContact != null && loggedInMember.memberContact.hasSameDetailsAs( memberContact ) ) )
      {
        MemberClient.addAndSaveMemberContactForModeraion( formMember, memberContact );  //this also updates updated date, and re-adds memberContact to member
      }

      //System.out.println( redirectTo );
      redirectJsp( request, response, redirectTo );
      return;
    }

    if( mode.equals( "edit" ) && form.equals( "changeemailaddress" ) )
    {
      //get logged in member
      formMember = loggedInMember;  //as you have to be logged in to edit, and you can't edit member only details, this must be the object hat corresponds to the member details on the form.

      //check for validity..
      String oldEmail;
      String newEmail = request.getParameter( "newemail" ).trim();
      String confirmNewEmail = request.getParameter( "confirmnewemail" ).trim();
      ArrayList errors = new ArrayList();

      if( !newEmail.equals( confirmNewEmail ) )
      {
        errors.add( "Your new email address and confirm new email address fields do not match!" );
      }
      else
      {
        oldEmail = formMember.email;
        formMember.email = newEmail;

        if( !EmailAddressUtils.isValidEmailAddress( formMember.email ) )
        {
          errors.add( "The email address entered is not a valid email address" );
        }

        boolean[] uniqueCheckResults = MemberClient.checkUniqueFields( formMember.email, formMember.profileURL );

        if( !uniqueCheckResults[0] )
        {
          errors.add( "A member already exists with that email address" );
        }

        if( errors.size() > 0 )
        {
          formMember.email = oldEmail;
        }
      }

      //return errors if there are any
      if( errors.size() > 0 )
      {
        returnWithErrorMessages( request, response, errors, formMember, "member", (Object)formMember, "/pages/emailAdmin.jsp" );
        return;
      }

      //erm, we only save this if it's different to the moderated version, and there is no unmoderated version - if the user just goes into page and clicks save, we don't want to bother the moderator to accept no changes!!!
      //this also means that if the details are moderated since the user logs in, then the user doing this will not overwrite the newly moderated data. Good eh?
      MemberClient.changePasswordAndEmailAndProfileUrl( formMember, formMember.passwd, formMember.profileURL, formMember.email, true );
      //this changes it in db and on object

      redirectJsp( request, response, redirectTo );
      return;
    }

    if( mode.equals( "edit" ) && form.equals( "registerprofiledetails" ) )
    {
      //get logged in member and create memberProfile object - which we are editing
      formMember = loggedInMember;  //as you have to be logged in to edit, and you can't edit member only details, this must be the object hat corresponds to the member details on the form.
      MemberProfile memberProfile = createMemberProfile( request );  //now we must set the id of the memberProfile object - this is not got from the form obvoiusly as it must be taken from the logged in member and we do not want to display it to the user
      if( loggedInMember.moderationMemberProfile != null )
      {
        //if there isn't one we leave id, it will be generated by database, otherwise we must set it so the update updates the right row in db
        memberProfile.memberProfileId = loggedInMember.moderationMemberProfile.memberProfileId;
      }

      //check for validity..
      ArrayList errors = checkMemberProfileDetails( memberProfile, request );
      errors.addAll( checkTasteAndTermsChecks( request ) );

      if( errors.size() > 0 )
      {
        returnWithErrorMessages( request, response, errors, formMember, "formmemberprofile", (Object)memberProfile, "/pages/registerProfileDetails.jsp" );
        return;
      }

      //erm, we only save this if it's different to the moderated version, and there is no unmoderated version - if the user just goes into page and clicks save, we don't want to bother the moderator to accept no changes!!!
      //this also means that if the details are moderated since the user logs in, then the user doing this will not overwrite the newly moderated data. Good eh?
      if( !( loggedInMember.moderationMemberProfile == null && loggedInMember.memberProfile != null && loggedInMember.memberProfile.hasSameDetailsAs( memberProfile ) ) )
      {
        //save in database and complete member object, overwrides if one already exists
        MemberClient.addAndSaveMemberProfileForModeraion( formMember, memberProfile );
        //this also popuates memberProfileId and updated date, and adds memberProfile to member
      }

      redirectJsp( request, response, redirectTo );
      return;
    }

    if( mode.equals( "delete" ) && form.equals( "deleteaccount" ) )
    {
      //this just refreshes member object to make sure it is fully up to date - we dont want to miss any files while we're deleting
      loggedInMember = MemberClient.loadFullMember( loggedInMember.memberId );

      loggedInMember.deleteMe( request );  //we pass in request cos method logs you out also

      redirectJsp( request, response, redirectTo );
      return;
    }

    //if invalid params passed in - just return to homepage
    redirectJsp( request, response, "/index.jsp" );
    return;
  }

/**
 * Takes relevant params of the request object in order to create a new member object
 *
 * @param request  request object containing necessary params
 * @return         A new member object with only initial params set (ie no go live date or expiry date, etc)
 */
  public Member createMember( HttpServletRequest request )
  {
    Member member = new Member(
        NumberUtils.parseInt( request.getParameter( "memberid" ), -1 ),
        EncodeUtils.HTMLEncode( request.getParameter( "email" ).trim() ),
        EncodeUtils.HTMLEncode( request.getParameter( "passwd" ).trim() ),
        request.getParameter( "profileurl" ).trim(),
        null,  //regDate
        null,  //lastPaymentDate
        null,  //goLiveDate
        null,  //expiryDate
        false, //placedadvert
        false, //on moderation hold
        null,  //wentOnHoldDate
        false, //validated email
        -1     //validation key.  //this is set in constructor
    );
    return member;
  }

/**
 * Takes relevant params of the request object in order to create a new MemberContact object
 *
 * @param request  request object containing necessary params
 * @return         A fully populated object reflecting values on request
 */
  public MemberContact createMemberContact( HttpServletRequest request )
  {
    MemberContact memberContact = new MemberContact(
        NumberUtils.parseInt( request.getParameter( "membercontactid" ), -1 ),  //will always be null from form
        null,  //lastUpdatedDate
        EncodeUtils.HTMLEncode( request.getParameter( "name" ) ),
        NumberUtils.parseInt( request.getParameter( "statusref" ), -1 ),
        request.getParameter( "statusother" ),
        NumberUtils.parseInt( request.getParameter( "primarycategoryref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "primarydisciplineref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "secondarycategoryref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "secondarydisciplineref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "tertiarycategoryref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "tertiarydisciplineref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "sizeref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "countryref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "ukregionref" ), -1 ),
        EncodeUtils.HTMLEncode( request.getParameter( "address1" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "address2" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "city" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "postcode" ) ),
        NumberUtils.parseInt( request.getParameter( "countyref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "contacttitleref" ), -1 ),
        EncodeUtils.HTMLEncode( request.getParameter( "contactfirstname" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "contactsurname" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "telephone" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "mobile" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "fax" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "webaddress" ) ),
        NumberUtils.parseInt( request.getParameter( "wheredidyouhearref" ), -1 ),
        EncodeUtils.HTMLEncode( request.getParameter( "wheredidyouhearother" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "wheredidyouhearmagazine" ) )
    );
    return memberContact;
  }

/**
 * Takes relevant params of the request object in order to create a new MemberProfile object
 *
 * @param request  request object containing necessary params - from registerProfileDetails.jsp
 * @return         A fully populated object reflecting values on request
 */
  public MemberProfile createMemberProfile( HttpServletRequest request )
  {
    MemberProfile memberProfile = new MemberProfile(
        NumberUtils.parseInt( request.getParameter( "memberprofileid" ), -1 ),  //will always be null from form
        null,  //lastUpdatedDate
        EncodeUtils.HTMLEncode( request.getParameter( "personalstatement" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "specialisations" ) ),
        EncodeUtils.HTMLEncode( request.getParameter( "keywords" ) )
    );
    return memberProfile;
  }

/**
 * Checks that taste and terms checkbox has been checked on source jsp
 *
 * @param request               request from source jsp
 * @return                      true if cjeckbox has been chacked
 */
  public ArrayList checkTasteAndTermsChecks( HttpServletRequest request )
  {
    ArrayList errors = new ArrayList();

    if( request.getParameter( "tastecheck" ) == null )
    {
      errors.add( "You have not declared that your submission meets the Taste and Decency Guidelines" );
    }

    return errors;
  }

/**
 * Checks that all three fields have been filled in on registerProfileDetails.jsp For
 *
 * @param memberProfile         object just created from form
 * @param request               request from form
 * @return                      empty arraylist if user in put is valid - otherwise an arraylist of string errors
 */
  public ArrayList checkMemberProfileDetails( MemberProfile memberProfile, HttpServletRequest request )
  {
    ArrayList errors = new ArrayList();

    if( memberProfile.personalStatement.length() == 0 )
    {
      errors.add( "You have not given a personal statement" );
    }

    if( memberProfile.specialisations.length() == 0 )
    {
      errors.add( "You have not given any specialisations" );
    }

    if( memberProfile.keywords.length() == 0 )
    {
      errors.add( "You have not given any keywords" );
    }

    return errors;
  }

/**
 * Checks that all member contact fields have been filled in correctly registerContactDetails.jsp For
 *
 * @param memberContact         object just created from form
 * @param request               request from form
 * @return                      empty arraylist if user in put is valid - otherwise an arraylist of string errors
 */
  public ArrayList checkMemberContactDetails( MemberContact memberContact, HttpServletRequest request )
  {
    PropertyFile dropDownProps = new PropertyFile( "com.extware.properties.DropDowns" );
    ArrayList errors = new ArrayList();

    if( memberContact.name.length() == 0 )
    {
      errors.add( "You must enter a name" );
    }

    if( memberContact.statusRef == -1 )
    {
      errors.add( "You must enter a status" );
    }
    else if( memberContact.statusRef == dropDownProps.getInt( "statusref.othersHandle.1" ) && memberContact.statusOther.length() == 0 )
    {
      //there seems to be a problem with this
      errors.add( "You selected a status of 'Other' please give details" );
    }

    if( memberContact.primaryCategoryRef == -1 )
    {
      errors.add( "You must enter your primary category" );
    }
    else if( memberContact.primaryDisciplineRef == -1 )
    {
      errors.add( "You must enter your primary discipline" );
    }

    if( memberContact.tertiaryCategoryRef != -1 && memberContact.secondaryCategoryRef == -1 )
    {
      errors.add( "You entered a tertiary category but not a secondary category" );
    }

    if( memberContact.secondaryCategoryRef != -1 && memberContact.secondaryDisciplineRef == -1 )
    {
      errors.add( "You must enter your secondary discipline if you have selected a secondary category" );
    }

    if( memberContact.tertiaryCategoryRef != -1 && memberContact.tertiaryDisciplineRef == -1 )
    {
      errors.add( "You must enter your tertiary discipline if you have selected a tertiary category" );
    }

    if( memberContact.sizeRef == -1 )
    {
      errors.add( "You must enter the number of people in your organisation" );
    }

    if( memberContact.countryRef == -1 )
    {
      errors.add( "You must enter your country of operation" );
    }

    if( memberContact.countryRef == PropertyFile.getDataDictionary().getInt( "dropdowns.countryCode.UK" ) )
    { //UK
      if( memberContact.regionRef == -1 )
      {
        errors.add( "If you are in the UK you must select your region" );
      }
      else if( memberContact.countyRef == -1 )
      {
        errors.add( "If you are in the UK you must select your county" );
      }
    }

    if( memberContact.address1.length() == 0 )
    {
      errors.add( "You must enter your address line 1" );
    }

    if( memberContact.city.length() == 0 )
    {
      errors.add( "You must enter your city" );
    }

    if( memberContact.postcode.length() == 0 )
    {
      errors.add( "You must enter your postcode" );
    }

    if( memberContact.contactTitleRef == -1 )
    {
      errors.add( "You must enter a contact title" );
    }

    if( memberContact.contactFirstName.length() == 0 )
    {
      errors.add( "You must enter a contact first name" );
    }

    if( memberContact.contactSurname.length() == 0 )
    {
      errors.add( "You must enter a contact surname" );
    }

    if( memberContact.telephone.length() == 0 )
    {
      errors.add( "You must enter a contact telephone number" );
    }
    if( memberContact.whereDidYouHearRef == -1 )
    {
      errors.add( "Please tell us where you heard about us" );
    }
    else if( memberContact.whereDidYouHearRef == dropDownProps.getInt( "wheredidyouhearref.othersHandle.1" ) && memberContact.whereDidYouHearOther.length() == 0 )
    {
      errors.add( "Under 'Where did you hear about us' you selected 'Other', please give details" );
    }
    else if( memberContact.whereDidYouHearRef == dropDownProps.getInt( "wheredidyouhearref.othersHandle.2" ) && memberContact.whereDidYouHearMagazine.length() == 0 )
    {
      errors.add( "Please tell us in which magazine you heard about us" );
    }

    return errors;
  }

/**
 * Checks that all member fields have been filled in correctly registerContactDetails.jsp Form, also checks that unique fields are unique
 *
 * @param member                object just created from form
 * @param request               request from form
 * @return                      empty arraylist if user in put is valid - otherwise an arraylist of string errors
 * @exception ServletException  thrown if database access error
 */
  public ArrayList checkMemberOnlyDetails( Member member, HttpServletRequest request ) throws ServletException
  {
    ArrayList errors = new ArrayList();

    if( !EmailAddressUtils.isValidEmailAddress( member.email ) )
    {
      errors.add( "The email address entered is not a valid email address" );
    }

    if( !member.email.equals( request.getParameter( "confirmemail" ).trim() ) )
    {
      errors.add( "Your email and confirm email entries did not match" );
      request.setAttribute( "confirmemail", request.getParameter( "confirmemail" ).trim() );
    }

    if( member.passwd.length() < 5 || member.passwd.length() > 12 )
    {
      errors.add( "Your password must be between 5 and 12 characters" );
    }

    if( !member.passwd.equals( EncodeUtils.HTMLEncode( request.getParameter( "confirmpasswd" ) ).trim() ) )
    {
      errors.add( "Your password and confirm password entries did not match, please retype both" );
      member.passwd = "";
    }

    if( member.profileURL.length() == 0 )
    {
      errors.add( "You must enter a Nextface web address shortcut, this will form a web address that points straight to your profile page" );
    }

    if( !member.hasValidProfileURL() )
    {
      errors.add( "Your Nextface web address shortcut may only contain letters, numbers and the underscore '_' character." );
    }

    //final chacks involve database - so only do if necessary
    if( errors.size() == 0 )
    {
      boolean[] uniqueCheckResults = MemberClient.checkUniqueFields( member.email, member.profileURL );

      if( !uniqueCheckResults[0] )
      {
        errors.add( "The email address entered is already registered" );
      }

      if( !uniqueCheckResults[1] )
      {
        errors.add( "Unfortunately your chosen Nextface web address shortcut is already taken, please choose another" );
      }
    }

    return errors;
  }

/**
 * Used to put the offending object/objects, and the arrayList of errors onto the request as attributes, then redirect to the source jsp for this servlet.
 *
 * @param request               request object
 * @param response              response object
 * @param errors                ArrayList of string error messagedto display
 * @param formMember            the member (with potentially incorrect details) we are trying to edit
 * @param attrObjName           name of second object depends on which of the 2 jsps we are redirecting back to
 * @param memberDetailsObject   2nd object object type depends on which of the 2 jsps we are redirecting back to
 * @param redirect              source servlet name
 * @exception IOException       if error finding jsp
 * @exception ServletException  servletexception
 */
  private void returnWithErrorMessages( HttpServletRequest request, HttpServletResponse response, ArrayList errors, Member formMember, String attrObjName, Object memberDetailsObject, String redirect ) throws IOException, ServletException
  {
    request.setAttribute( "errors", errors );
    request.setAttribute( "formmember", formMember );
    request.setAttribute( attrObjName, memberDetailsObject );

    redirectJsp( request, response, redirect );
  }

}
