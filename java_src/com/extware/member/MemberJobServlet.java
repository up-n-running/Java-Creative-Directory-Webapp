package com.extware.member;

import com.extware.framework.SuperServlet;

import com.extware.member.MemberClient;

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
 * Servet used when passing from / to jobsEdit.jsp
 * Also used when from data has errors, it passes the faulty object back to the source jsp with an arraylist of error messages
 *
 * @author   John Milner
 */

public class MemberJobServlet extends SuperServlet
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
 * Servet used when passing from / to jobsEdit.jsp
 * Also used when from data has errors, it passes the faulty object back to the source jsp with an arraylist of error messages
 *
 * @param request               request
 * @param response              response
 * @exception IOException       IOException
 * @exception ServletException  ServletException
 */
  public void doPost( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
  {
    Member loggedInMember = (Member)( request.getSession().getAttribute( "member" ) );

    //you must be logged in!!!
    if( loggedInMember == null )
    {
      redirectJsp( request, response, "/loggedOut.jsp" );
      return;
    }

    String mode = StringUtils.nullString( request.getParameter( "mode" ) );
    String form = StringUtils.nullString( request.getParameter( "form" ) );
    String redirectTo = request.getParameter( "redirectto" ) == null ? "/pages/accountManager.jsp" : request.getParameter( "redirectto" );
    MemberJob formMemberJob = null;

    if( mode.equals( "add" ) && form.equals( "jobedit" ) )
    {
      //create member job object
      formMemberJob = createMemberJob( request );

      //check for validity..
      ArrayList errors = checkMemberJobDetails( formMemberJob, loggedInMember, "", request );
      errors.addAll( checkTasteAndTermsChecks( request ) );

      if( errors.size() > 0 )
      {
        returnWithErrorMessages( request, response, errors, formMemberJob, "/pages/jobsEdit.jsp" );
        return;
      }

      //save in database and complete member object
      MemberClient.addAndSaveMemberJobForModeraion( loggedInMember, formMemberJob );  //this also popuates membercontactid and updated date, and adds memberContact to member

      redirectJsp( request, response, redirectTo );
      return;
    }

    if( mode.equals( "edit" ) && form.equals( "jobedit" ) )
    {
      //happens to be ALMOST exactly the same code as if mode is add, but i'll keep it seperate anyway

      //create member object
      formMemberJob = createMemberJob( request );

      //check for validity..
      //find existing job to use ref no.
      MemberJob existingJob = loggedInMember.getJobForAccountManager( loggedInMember.getJobIndexByJobId( formMemberJob.memberJobId ) );

      ArrayList errors = checkMemberJobDetails( formMemberJob, loggedInMember, existingJob.referenceNo, request );
      errors.addAll( checkTasteAndTermsChecks( request ) );

      if( errors.size() > 0 )
      {
        request.setAttribute( "memberjobtoedit", formMemberJob );
        returnWithErrorMessages( request, response, errors, formMemberJob, "/pages/jobsEdit.jsp" );
        return;
      }

      //save in database and complete member object
      if( !( !existingJob.forModeration && existingJob.hasSameDetailsAs( formMemberJob ) ) )
      {
        MemberClient.addAndSaveMemberJobForModeraion( loggedInMember, formMemberJob );  //this also popuates membercontactid and updated date, and adds memberContact to member
      }

      redirectJsp( request, response, redirectTo );
      return;
    }

    if( mode.equals( "edit" ) && form.equals( "jobsearch" ) )
    {
      //we're going cancel editing without saving or populate the form with the selected job, simple as.
      int memberJobId = NumberUtils.parseInt( request.getParameter( "jobselect" ), -1 );

      if( memberJobId == -1 && request.getParameter( "jobselect" ) != null && request.getParameter( "jobselect" ).equals( "add" ) )
      {
        redirectJsp( request, response, "/pages/jobsEdit.jsp" );
        return;
      }

      MemberJob job = loggedInMember.getJobForAccountManager( loggedInMember.getJobIndexByJobId( memberJobId ) );

      request.setAttribute( "memberjobtoedit", job );

      redirectJsp( request, response, "/pages/jobsEdit.jsp" );

      return;
    }

    if( mode.equals( "delete" ) && form.equals( "jobsearch" ) )
    {
      //we're going cancel editing without saving or populate the form with the selected job, simple as.
      int memberJobId = NumberUtils.parseInt( request.getParameter( "jobselect" ), -1 );

      MemberClient.deleteMemberJob( loggedInMember, memberJobId );

      redirectJsp( request, response, "/pages/jobsEdit.jsp" );

      return;
    }

    redirectJsp( request, response, "/index.jsp" );

    return;
  }

/**
 * takes form paramaters of the request from sorrce jsp to create a new MemberJob object
 *
 * @param request  request from source jsp
 * @return         the new MemberJob object
 */
  public MemberJob createMemberJob( HttpServletRequest request )
  {
    MemberJob memberJob = new MemberJob(
        NumberUtils.parseInt( request.getParameter( "memberjobid" ), -1 ),
        null,  //creationDate,
        null,  //lastUpdatedDate,
        EncodeUtils.HTMLEncode( request.getParameter( "referencenumber" ).trim() ),
        EncodeUtils.HTMLEncode( request.getParameter( "title" ).trim() ),
        NumberUtils.parseInt( request.getParameter( "maincategoryref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "disciplineref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "typeofworkref" ), -1 ),
        EncodeUtils.HTMLEncode( request.getParameter( "salary" ).trim() ),
        NumberUtils.parseInt( request.getParameter( "countryref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "ukregionref" ), -1 ),
        NumberUtils.parseInt( request.getParameter( "countyref" ), -1 ),
        EncodeUtils.HTMLEncode( request.getParameter( "city" ).trim() ),
        EncodeUtils.HTMLEncode( request.getParameter( "telephone" ).trim() ),
        EncodeUtils.HTMLEncode( request.getParameter( "email" ).trim() ),
        EncodeUtils.HTMLEncode( request.getParameter( "contactname" ).trim() ),
        EncodeUtils.HTMLEncode( request.getParameter( "description" ).trim() ),
        true,
        -1
    );

    return memberJob;
  }

/**
 * Checks that taste and terms checkbox has been checked on source jsp
 *
 * @param request               request from source jsp
 * @return                      true if cjeckbox has been chacked
 */
  public ArrayList checkTasteAndTermsChecks( HttpServletRequest request ) throws ServletException
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

/**
 * Checks that form input is valid
 *
 * @param memberJob             job created form form
 * @param member                logged in member whise job it is
 * @param existingRefNo         original reference number (it may have changed)
 * @param request               request from source jsp
 * @return                      empty arraylist if user in put is valid - otherwise an arraylist of string errors
 * @exception ServletException  thrown if database exception whilst checking uniqueness of rederence number
 */
  public ArrayList checkMemberJobDetails( MemberJob memberJob, Member member, String existingRefNo, HttpServletRequest request ) throws ServletException
  {
    PropertyFile dropDownProps = new PropertyFile( "com.extware.properties.DropDowns" );
    ArrayList errors = new ArrayList();

    if( memberJob.title.length() == 0 )
    {
      errors.add( "You must enter a job title" );
    }

    if( memberJob.referenceNo.length() == 0 )
    {
      errors.add( "You must enter a job reference number" );
    }
    else if( !( memberJob.referenceNo.toUpperCase().trim() ).equals( existingRefNo.toUpperCase().trim() ) && !MemberClient.checkUniqueJobReference( member.memberId, memberJob.referenceNo ) )
    {
      errors.add( "You have already entered a job with that reference number, if you are trying to change the details of this job, please use the drop down box below" );
    }

    if( memberJob.mainCategoryRef == -1 )
    {
      errors.add( "You must enter a job category" );
    }
    else if( memberJob.disciplineRef == -1 )
    {
      errors.add( "You must enter a job discipline" );
    }

    if( memberJob.typeOfWorkRef == -1 )
    {
      errors.add( "You must enter the type of work being offered" );
    }

    if( memberJob.salary.length() == 0 )
    {
      errors.add( "You must enter salary details" );
    }

    if( memberJob.countryRef == -1 )
    {
      errors.add( "You must enter the job's country of operation" );
    }

    if( memberJob.countryRef == 1 )
    {
      if( memberJob.ukRegionRef == -1 )
      {
        errors.add( "If you are in the UK you must select the job's region" );
      }
      else if( memberJob.countyRef == -1 )
      {
        errors.add( "If you are in the UK you must select the job's county" );
      }
    }

    if( memberJob.telephone.length() == 0 )
    {
      errors.add( "You must enter a contact telephone number" );
    }

    if( memberJob.email.length() == 0 )
    {
      errors.add( "You must enter a contact email address" );
    }

    if( memberJob.email.length() < 5 || memberJob.email.indexOf( "@" ) == -1 || memberJob.email.indexOf( "." ) == -1 )
    {
      errors.add( "The email address entered is not a valid email address" );
    }

    if( memberJob.contactName.length() == 0 )
    {
      errors.add( "You must enter a contact name" );
    }

    if( memberJob.description.length() == 0 )
    {
      errors.add( "You must enter a job description" );
    }

    if( memberJob.description.length() > 2000 )
    {
      errors.add( "Please keep your job description to less than 2000 characters." );
    }

    return errors;
  }

/**
 * Used to put the offending object/objects, and the arrayList of errors onto the request as attributes, then redirect to the source jsp for this servlet.
 *
 * @param request               request object
 * @param response              response object
 * @param errors                ArrayList of string error messagedto display
 * @param formMemberJob         offending job object containing error
 * @param redirect              source servlet name
 * @exception IOException       if error finding jsp
 * @exception ServletException  servletexception
 */
  private void returnWithErrorMessages( HttpServletRequest request, HttpServletResponse response, ArrayList errors, MemberJob formMemberJob, String redirect ) throws IOException, ServletException
  {
    request.setAttribute( "errors", errors );
    request.setAttribute( "formmemberjob", formMemberJob );
    redirectJsp( request, response, redirect );
  }

}
