package com.extware.emailSender;

import com.extware.extsite.text.TextPage;

import com.extware.member.Member;
import com.extware.member.MemberContact;

import com.extware.utils.MailUtils;
import com.extware.utils.PropertyFile;
import com.extware.utils.StringUtils;

import java.net.URLEncoder;

import java.sql.SQLException;

import java.util.ArrayList;

import javax.mail.MessagingException;

import javax.mail.internet.AddressException;

import javax.servlet.ServletException;

/**
 * Simple utility method for sending an email - pass in the name of a text block (text page) and and email address and it'll send the email whose contents are defined in the text page/block
 *
 * @author   John Milner
 */
public class EmailSender
{

/**
 * Simple utility method for sending an email - pass in the name of a text block (text page) and and email address and it'll send the email whose contents are defined in the text page/block. Email can contain replacer keys, which will be replaced by member details.
 *
 * @param textPageName          text page handle used for email content
 * @param subject               Subject for email, can contain replacer keys
 * @param member                member object whose values we can use in replacers
 * @param extraReplacerNames    any non standard replacer keys can be passed in here as arraylist of strings
 * @param extraReplacerValues   any corresponding non standard replacer values can be passed in here as arraylist of strings
 * @return                      true if and  only if successful
 * @exception ServletException  thrown if error sending email
 */
  public static boolean sendMail( String textPageName, String subject, Member member, ArrayList extraReplacerNames, ArrayList extraReplacerValues ) throws ServletException
  {
    return sendMail( textPageName, subject, member, extraReplacerNames, extraReplacerValues, null, null );
  }

/**
 * Simple utility method for sending an email - pass in the name of a text block (text page) and and email address and it'll send the email whose contents are defined in the text page/block
 *
 * @param textPageName          text page handle used for email content
 * @param subject               Subject for email, can contain replacer keys
 * @param member                member object whose values we can use in replacers
 * @param extraReplacerNames    any non standard replacer keys can be passed in here as arraylist of strings
 * @param extraReplacerValues   any corresponding non standard replacer values can be passed in here as arraylist of strings
 * @param fromAddress           from address
 * @param toAddress             to address
 * @return                      true if and  only if successful
 * @exception ServletException  thrown if error sending email
 */
  public static boolean sendMail( String textPageName, String subject, Member member, ArrayList extraReplacerNames, ArrayList extraReplacerValues, String fromAddress, String toAddress ) throws ServletException
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();

    if( fromAddress == null )
    {
      fromAddress = "do_not_reply@nextface.net";
    }

    if( toAddress == null )
    {
      toAddress = member.email;
    }

    TextPage emailContentPage = null;  // get email body

    try
    {
      emailContentPage = TextPage.getTextPage( textPageName );
    }
    catch( SQLException sex )
    {
      throw new ServletException( sex.toString() );
    }

    // add header and footer
    String emailBody = dataDictionary.getString( "email.html.header" ) + emailContentPage.pageContent + dataDictionary.getString( "email.html.footer" );

    // replace replacers
    emailBody = replaceReplacers( emailBody, member, extraReplacerNames, extraReplacerValues, dataDictionary );
    subject = replaceReplacers( subject, member, extraReplacerNames, extraReplacerValues, dataDictionary );

    try
    {
      MailUtils.sendMail( fromAddress, toAddress, null, null, subject, emailBody, "text/html" );
    }
    catch( AddressException aex )
    {
      return false;
    }
    catch( MessagingException mex )
    {
      return false;
    }

    return true;
  }

/**
 * Description of the Method
 *
 * @param emailBody            email body text before replacements are made
 * @param member               member object holding details to replace
 * @param extraReplacerNames   any non standard replacer keys
 * @param extraReplacerValues  corresponding non-standard replacer values
 * @param dataDictionary       An ininstance of the data dictionary for this app
 * @return                     email body text after replacements are made
 */
  private static String replaceReplacers( String emailBody, Member member, ArrayList extraReplacerNames, ArrayList extraReplacerValues, PropertyFile dataDictionary )
  {
    for( int i = 0; i < extraReplacerNames.size(); i++ )
    {
      // extra fields first, cos you can replace a replacer with a replacer!!!!
      emailBody = StringUtils.replace( emailBody, (String)extraReplacerNames.get( i ), (String)extraReplacerValues.get( i ) );
    }

    if( member != null )
    {
      MemberContact memberContact = member.memberContact == null ? member.moderationMemberContact : member.memberContact;

      if( memberContact != null && memberContact.contactFirstName != null && memberContact.contactSurname != null )
      {
        emailBody = StringUtils.replace( emailBody, "&lt;USERNAME&gt;", memberContact.contactFirstName + " " + memberContact.contactSurname );
      }

      if( member.passwd != null )
      {
        emailBody = StringUtils.replace( emailBody, "&lt;USERPASSWORD&gt;", member.passwd );
      }

      String hostUrl = dataDictionary.getString( "hostUrl" );
      emailBody = StringUtils.replace( emailBody, "&lt;HOSTURL&gt;", "http:// " + hostUrl );

      if( member.email != null && member.passwd != null )
      {
        String loginLink = "http:// " + hostUrl + "/login.jsp?redirectto=/pages/accountManager.jsp&email=" + URLEncoder.encode( member.email ) + "&passwd=" + URLEncoder.encode( member.passwd );
        String loginLinkDesc = hostUrl + "/login.jsp?redirectto=/pages/accountManager.jsp<br />&email=" + URLEncoder.encode( member.email ) + "&passwd=" + URLEncoder.encode( member.passwd );
        emailBody = StringUtils.replace( emailBody, "&lt;USERLOGINLINK&gt;", "<a target=\"_blank\" href=\"" + loginLink + "\">" + loginLinkDesc + "</a>" );
      }

      // validate email link
      String validateLink = "http:// " + hostUrl + "/validate.jsp?memberId=" + member.memberId + "&validationKey=" + member.validationKey;
      String validateLinkDesc = hostUrl + "/validate.jsp?memberId=" + member.memberId + "&validationKey=" + member.validationKey;
      emailBody = StringUtils.replace( emailBody, "&lt;VALIDATEEMAILADDRESSLINK&gt;", "<a target=\"_blank\" href=\"" + validateLink + "\">" + validateLinkDesc + "</a>" );
    }

    return emailBody;
  }

}
