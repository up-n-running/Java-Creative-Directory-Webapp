package com.extware.member;

import com.extware.framework.DropDownOption;

import com.extware.member.MemberClient;

import com.extware.utils.PropertyFile;

import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Hashtable;

import javax.servlet.ServletException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

/**
 * Holds all of the admin and unique fields of the member, plus all of the other stuff as pointers to objects
 *
 * @author   John Milner
 */
public class Member implements HttpSessionBindingListener
{

  public int              memberId                = -1;
  public MemberContact    memberContact           = null;
  public MemberProfile    memberProfile           = null;
  public MemberContact    moderationMemberContact = null;
  public MemberProfile    moderationMemberProfile = null;
  public MemberFile       portraitImage           = null;
  public MemberFile       mainFile                = null;
  public ArrayList        memberFiles             = null;
  public ArrayList        moderationMemberFiles   = null;
  public ArrayList        memberJobs              = null;  //arraylist of arrays of length 2 - moderated and unmoderated pairs!
  public boolean          placedAdvert            = false;
  public String           email                   = null;
  public String           passwd                  = null;
  public String           profileURL              = null;
  public Date             regDate                 = null;
  public Date             lastPaymentDate         = null;
  public Date             goLiveDate              = null;
  public Date             expiryDate              = null;
  public boolean          onModerationHold        = false;
  public Date             wentOnHoldDate          = null;
  public boolean          emailValidated          = false;
  public int              validationKey           = -1;
  public static Hashtable loggedInMembers         = new Hashtable();

/**
 * Constructor for the Member object
 */
  public Member()
  {
  }

/**
 * Constructor for the Member object - subset for search resuls
 *
 * @param memberId Direct from database table
 */
  public Member( int memberId )
  {
    this.memberId = memberId;
    this.memberFiles = new ArrayList();
  }

/**
 * Constructor for the Member object
 *
 * @param memberId          Direct from member database table
 * @param email             Direct from member database table
 * @param passwd            Direct from member database table
 * @param profileURL        Direct from member database table
 * @param regDate           Direct from member database table
 * @param lastPaymentDate   Direct from member database table
 * @param goLiveDate        Direct from member database table
 * @param expiryDate        Direct from member database table
 * @param placedAdvert      Direct from member database table
 * @param onModerationHold  Direct from member database table
 * @param wentOnHoldDate    Direct from member database table
 * @param emailValidated    Direct from member database table
 * @param validationKey     Direct from member database table
 */
  public Member( int     memberId,
                 String  email,
                 String  passwd,
                 String  profileURL,
                 Date    regDate,
                 Date    lastPaymentDate,
                 Date    goLiveDate,
                 Date    expiryDate,
                 boolean placedAdvert,
                 boolean onModerationHold,
                 Date    wentOnHoldDate,
                 boolean emailValidated,
                 int     validationKey )
  {
    this.memberId         = memberId;
    this.email            = email;
    this.passwd           = passwd;
    this.profileURL       = profileURL;
    this.regDate          = regDate;
    this.lastPaymentDate  = lastPaymentDate;
    this.goLiveDate       = goLiveDate;
    this.expiryDate       = expiryDate;
    this.placedAdvert     = placedAdvert;
    memberFiles           = new ArrayList();
    moderationMemberFiles = new ArrayList();
    memberJobs            = new ArrayList();  //both moderated and non-moderated go here.
    this.onModerationHold = onModerationHold;
    this.wentOnHoldDate   = wentOnHoldDate;
    this.emailValidated   = emailValidated;

    if( validationKey == -1 )
    {
      validationKey = (int)( Math.random() * 99999999 );
    }

    this.validationKey    = validationKey;
  }

/**
 * Sets the portraitImage attribute of the Member object to the file object passed in
 *
 * @param portraitMemberFileId  id of file to set as portraitImage
 */
  public void setNewPortraitImage( int portraitMemberFileId )
  {
    this.portraitImage = getMemberFileById( portraitMemberFileId );
  }

/**
 * Gets the total bizes of storage for member files already uploaded
 *
 * @return   The TotalFileByteSize total bizes of storage for member files already uploaded
 */
  public int getTotalFileByteSize()
  {
    int total = 0;

    for( int i = 0; memberFiles != null && i < memberFiles.size(); i++ )
    {
      total += ( (MemberFile)memberFiles.get( i ) ).fileByteSize;
    }

    for( int i = 0; moderationMemberFiles != null && i < moderationMemberFiles.size(); i++ )
    {
      total += ( (MemberFile)moderationMemberFiles.get( i ) ).fileByteSize;
    }

    return total;
  }

/**
 * Gets the MemberFile object from the Member object corresponding to the file id passed in
 *
 * @param memberFileId  database id of MemberFile object to get
 * @return              The MemberFile object
 */
  public MemberFile getMemberFileById( int memberFileId )
  {
    for( int i = 0; memberFiles != null && i < memberFiles.size(); i++ )
    {
      if( ( (MemberFile)memberFiles.get( i ) ).memberFileId == memberFileId )
      {
        return (MemberFile)memberFiles.get( i );
      }
    }
    for( int i = 0; moderationMemberFiles != null && i < moderationMemberFiles.size(); i++ )
    {
      if( ( (MemberFile)moderationMemberFiles.get( i ) ).memberFileId == memberFileId )
      {
        return (MemberFile)moderationMemberFiles.get( i );
      }
    }
    return null;
  }

/**
 * same as getMemberFileById but this time returns index in File arraylist - will only search through moderated files
 *
 * @param memberFileId  database id of MemberFile object to find index of
 * @return              index in MemberFiles Arraylist, or -1 if not found
 */
  public int getModeratedMemberFileIndexById( int memberFileId )
  {
    for( int i = 0; memberFiles != null && i < memberFiles.size(); i++ )
    {
      if( ( (MemberFile)memberFiles.get( i ) ).memberFileId == memberFileId )
      {
        return i;
      }
    }
    return -1;
  }

/**
 * Gets the Image File Byte Size of the file set as portraitImage - if there is one
 *
 * @return   bytes in file, or 0 of no file is set as portrait image.
 */
  public long getPortraitImageFileByteSize()
  {
    if( portraitImage != null )
    {
      return portraitImage.fileByteSize;
    }
    else
    {
      return 0;
    }
  }

/**
 * Given the index in the job arraylist, this will return the job object to show to the logged in user. That is the unmoderated job (if there is one), else the moderated job
 *
 * @param i  the index of the job in the member job arraylist
 * @return   The JobForAccountManager value
 */
  public MemberJob getJobForAccountManager( int idx )
  {
    MemberJob[] jobArray = (MemberJob[])( this.memberJobs.get( idx ) );

    if( jobArray[1] != null )
    {
      return jobArray[1];
    }
    else
    {
      return jobArray[0];
    }
  }

/**
 * Gets the the index in the job arraylist of the job whose database id matches passed in parameter. searches both moderated and unmoderated jobs.
 *
 * @param memberJobId  jobs database id we want to find index for
 * @return             index of the job found. -1 if none found
 */
  public int getJobIndexByJobId( int memberJobId )
  {
    MemberJob[] tmpJobArray;

    for( int i = 0; memberJobs != null && i < memberJobs.size(); i++ )
    {
      tmpJobArray = (MemberJob[])memberJobs.get( i );

      if( tmpJobArray[0] != null && tmpJobArray[0].memberJobId == memberJobId )
      {
        return i;
      }

      if( tmpJobArray[1] != null && tmpJobArray[1].memberJobId == memberJobId )
      {
        return i;
      }
    }

    return -1;
  }

////////////////// LOGIN/OUT STUFF///////////////////////

/**
 * Adds member to session
 *
 * @param request  request object holding current session
 */
  public void login( HttpServletRequest request )
  {
    request.getSession().removeAttribute( "member" );
    request.getSession().setAttribute( "member", this );
  }

/**
 * Removes member from this session
 *
 * @param request  request object holding current session
 */
  public void logout( HttpServletRequest request )
  {
    request.getSession().removeAttribute( "member" );
  }

/**
 * Binding Event Callback Method to record in a static hashtable an instance of this user being logged in.
 * Since this class implements HttpSessionBindingListener, then any time an instance of this class (ie a member) is added to the
 * session, this method is called
 *
 * @param event  contains the session in question
 */
  public void valueBound( HttpSessionBindingEvent event )
  {
    String memberIdAsString = String.valueOf( this.memberId );
    ArrayList instancesOfThisBemberBeingLoggedIn = null;

    if( loggedInMembers.containsKey( memberIdAsString ) )
    {
      instancesOfThisBemberBeingLoggedIn = (ArrayList)loggedInMembers.get( memberIdAsString );
    }
    else
    {
      instancesOfThisBemberBeingLoggedIn = new ArrayList();
    }

    instancesOfThisBemberBeingLoggedIn.add( event );
    loggedInMembers.put( memberIdAsString, instancesOfThisBemberBeingLoggedIn );
  }

/**
 * Unbinding Event Callback Method to remove from a static hashtable an instance of this user being logged in.
 * Since this class implements HttpSessionBindingListener, then any time an instance of this class (ie a member) is removed from the
 * session, this method is called
 *
 * @param event  contains the session in question
 */
  public void valueUnbound( HttpSessionBindingEvent event )
  {
    String memberIdAsString = String.valueOf( this.memberId );
    ArrayList instances = (ArrayList)loggedInMembers.get( memberIdAsString );

    for( int i = 0; i < instances.size(); i++ )
    {
      HttpSessionBindingEvent e = (HttpSessionBindingEvent)instances.get( i );

      if( e.getSession().getId() == event.getSession().getId() )
      {
        instances.remove( i );

        if( instances.size() == 0 )
        {
          loggedInMembers.remove( memberIdAsString );
        }
        else
        {
          loggedInMembers.put( memberIdAsString, instances );
        }
      }
    }
  }

////////////////// END OF LOGIN/OUT STUFF//////////////////

/**
 * Method toDelete this user from database, and his files from filesystem. simply calls deleteMe( null );
 *
 * @exception ServletException  thrown if a database error or a file system error
 */
  public void deleteMe() throws ServletException
  {
    deleteMe( null );
  }

/**
 * Method toDelete this user from database, and his files from filesystem, and log him out if logged in
 *
 * @param request               request object holding current session containing logged in member
 * @exception ServletException  thrown if a database error or a file system error
 */
  public void deleteMe( HttpServletRequest request ) throws ServletException
  {
    //first we must delete all member files
    MemberFile memberFileTemp;

    for( int i = 0; i < memberFiles.size(); i++ )
    {
      memberFileTemp = (MemberFile)memberFiles.get( i );
      memberFileTemp.deleteMe();
      //this also deletes files from filesystem
    }

    for( int i = 0; i < moderationMemberFiles.size(); i++ )
    {
      memberFileTemp = (MemberFile)moderationMemberFiles.get( i );
      memberFileTemp.deleteMe();
      //this also deletes files from filesystem
    }

    //now we delete object from database
    MemberClient.deleteMember( memberId );  //all stuff handing off this member will be removed. the member actuallt hangs off the mombercontacts and memberprofiles, so these are deleted by triggers, good eh?

    //now we log this member out.
    if( request != null )
    {
      logout( request );
    }

    //if logged in elsewhere then kill all instances.
    if( isLoggedIn( memberId ) )
    {
      String memberIdAsString = String.valueOf( memberId );
      ArrayList instancesOfThisBemberBeingLoggedIn = (ArrayList)loggedInMembers.get( memberIdAsString );

      for( int i = 0; i < instancesOfThisBemberBeingLoggedIn.size(); i++ )
      {
        HttpSessionBindingEvent e = (HttpSessionBindingEvent)instancesOfThisBemberBeingLoggedIn.get( i );
        e.getSession().removeAttribute( "member" );
      }
    }

    //our work here is done
  }

/**
 * Checks if profileURL will conflict with a url that's already valid as an existing page of nextface app
 *
 * @return   true if valid, false otherwise
 */
  public boolean hasValidProfileURL()
  {
    return isValidProfileURL( this.profileURL );
  }

/**
 * will remove from member object (not database) a member file with a particular id
 *
 * @param memberFileId  database id of member file to find, then remove
 */
  public void removeMemberFile( int memberFileId )
  {
    MemberFile memberFileTemp;

    for( int i = 0; i < memberFiles.size(); i++ )
    {
      memberFileTemp = (MemberFile)memberFiles.get( i );

      if( memberFileTemp.memberFileId == memberFileId )
      {
        if( memberFileTemp.portraitImage )
        {
          this.portraitImage = null;
        }
        if( memberFileTemp.mainFile )
        {
          this.mainFile = null;
        }

        memberFiles.remove( i );

        return;  //there will be no instance of this file in moderation member files list as you can not change a moderated file
      }
    }
    for( int i = 0; i < moderationMemberFiles.size(); i++ )
    {
      memberFileTemp = (MemberFile)moderationMemberFiles.get( i );

      if( memberFileTemp.memberFileId == memberFileId )
      {
        if( memberFileTemp.portraitImage )
        {
          this.portraitImage = null;
        }
        if( memberFileTemp.mainFile )
        {
          this.mainFile = null;
        }

        moderationMemberFiles.remove( i );

        return;
      }
    }
  }

/**
 * checks to see if this member has any jobs requiring moderation, if this member is on moderation hold, any unmoderated jobs still count.
 *
 * @return   true if there are jobs requiring moderation, else false
 */
  public boolean areThereJobsAwaitingModeration()
  {
    MemberJob[] tmpJobArray;

    for( int i = 0; memberJobs != null && i < memberJobs.size(); i++ )
    {
      tmpJobArray = (MemberJob[])memberJobs.get( i );

      if( tmpJobArray[1] != null )
      {
        return true;
      }
    }

    return false;
  }

/**
 * checks to see if there is at least one instance of this member being bound to a session
 *
 * @param memberId  memberid of member to check
 * @return          true if logged in at least once
 */
  public static boolean isLoggedIn( int memberId )
  {
    return loggedInMembers.containsKey( String.valueOf( memberId ) );
  }

/**
 * Checks if profileURL contains invalid characters and if it will conflict with a url that's already valid as an existing page of nextface app
 *
 * @param profileURL  url to check
 * @return            true if valid, false otherwise
 */
  public static boolean isValidProfileURL( String profileURL )
  {
    if( profileURL == null || profileURL.equals( "" ) )
    {
      return false;
    }

    //check that all digits are alphanumeric or '_' or '-'
    char[] urlArray = profileURL.toCharArray();

    for( int i = 0; i < profileURL.length(); i++ )
    {
      if( !Character.isLetterOrDigit( urlArray[i] ) && urlArray[i] != '_' && urlArray[i] != '-' )
      {
        return false;
      }
    }

    //check url against list of invalid ones from property file
    profileURL = profileURL.toUpperCase();
    String[] invalidUrls = PropertyFile.getDataDictionary().getStringArray( "invalidprofileurl.list.uppercase" );

    java.util.Arrays.sort( invalidUrls );
    return ( java.util.Arrays.binarySearch( invalidUrls, profileURL ) < 0 );
  }

/**
 * Gets the creates an arraylist of dropDronOption objects representing the next 10 weeks' member of the week members
 *
 * @param memberId              the member profiles page to display the drop down box on.
 * @return                      The Member Of Week Dropdown options for next 10 weeks, ascending order.
 * @exception ServletException  thrown if there's a problem with the database access
 */
  public static ArrayList getMemberOfWeekDropDown( int memberId ) throws ServletException
  {
    Date now = new Date();
    Date endOfWeek = getWeekEnd( now );
    long millisInWeek = 1000L * 60L * 60L * 24L * 7L;
    ArrayList dropDownOptions = new ArrayList();
    SimpleDateFormat sdf = new SimpleDateFormat( "MMM d ''yy" );
    int noOfWeeksToShow = PropertyFile.getDataDictionary().getInt( "memberOfWeekDropdown.noOfWeeksToShow" );

    for( int i = 0; i < noOfWeeksToShow ; i++ )
    {
      dropDownOptions.add( new DropDownOption( getDateDescriptor( endOfWeek ), "Wk Ending " + sdf.format( endOfWeek ) + " - " ) );
      endOfWeek = new Date( endOfWeek.getTime() + millisInWeek );
    }

    MemberClient.populateMemberOfWeekDropDown( dropDownOptions, memberId );

    return dropDownOptions;
  }

/**
 * Gets the DateDescriptor matching the database column memberOfWeek.weekDescripor for a given date
 *
 * @param date  date to convert to descriptor
 * @return      the descriptor
 */
  public static String getDateDescriptor( Date date )
  {
    SimpleDateFormat sdf = new SimpleDateFormat( "yyyyMMdd" );
    return sdf.format( date );
  }

/**
 * converts a date (X) to date representing last day of the week in which day X falls.
 *
 * @param date  date for which to find next week end.
 * @return      The Week End value
 */
  public static Date getWeekEnd( Date date )
  {
    long millisInDay = 1000L * 60L * 60L * 24L;

    Calendar cal = new GregorianCalendar();
    cal.setTime( date );
    int dayOfWeek = cal.get( Calendar.DAY_OF_WEEK );

    switch( dayOfWeek )
    {
      case Calendar.SUNDAY:
      {
        date = new Date( date.getTime() + millisInDay * 0 );
        break;
      }
      case Calendar.MONDAY:
      {
        date = new Date( date.getTime() + millisInDay * 6 );
        break;
      }
      case Calendar.TUESDAY:
      {
        date = new Date( date.getTime() + millisInDay * 5 );
        break;
      }
      case Calendar.WEDNESDAY:
      {
        date = new Date( date.getTime() + millisInDay * 4 );
        break;
      }
      case Calendar.THURSDAY:
      {
        date = new Date( date.getTime() + millisInDay * 3 );
        break;
      }
      case Calendar.FRIDAY:
      {
        date = new Date( date.getTime() + millisInDay * 2 );
        break;
      }
      case Calendar.SATURDAY:
      {
        date = new Date( date.getTime() + millisInDay * 1 );
        break;
      }
    }

    return date;
  }

/**
 * Converts to a String representation of the object.
 *
 * @return   A string representation of the object.
 */
  public String toString()
  {
    String desc = "MEMBER\n, id=" + memberId +
        ", email = '" + email + "'" +
        ", passwd = '" + passwd + "'" +
        ", profileURL = '" + profileURL + "'" +
        ", regDate = '" + regDate + "'" +
        ", lastPaymentDate = '" + lastPaymentDate + "'" +
        ", goLiveDate = '" + goLiveDate + "'" +
        ", expiryDate = '" + expiryDate + "'\n" +
        ", memberContact = '" + memberContact + "'\n" +
        ", moderationMemberContact = '" + moderationMemberContact + "'\n" +
        ", memberProfile = '" + memberProfile + "'\n" +
        ", moderationMemberProfile = '" + moderationMemberProfile + "'\n";
    if( portraitImage != null )
    {
      desc += "portraitImage  = " + portraitImage.displayFileName + ", portrait=" + portraitImage.portraitImage + ", main=" + portraitImage.mainFile + "\n";
    }
    else
    {
      desc += "portraitImage  = null\n";
    }
    if( mainFile != null )
    {
      desc += "mainFile  = " + mainFile.displayFileName + ", portrait=" + mainFile.portraitImage + ", main=" + mainFile.mainFile + "\n";
    }
    else
    {
      desc += "mainFile = null\n";
    }
    for( int i = 0; i < memberFiles.size(); i++ )
    {
      desc += "moderated portfilio file " + i + ": id= " + ( (MemberFile)memberFiles.get( i ) ).memberFileId + ",name= " + ( (MemberFile)memberFiles.get( i ) ).displayFileName + ", portrait=" + ( (MemberFile)memberFiles.get( i ) ).portraitImage + ", main=" + ( (MemberFile)memberFiles.get( i ) ).mainFile + "\n";
    }
    for( int i = 0; i < moderationMemberFiles.size(); i++ )
    {
      desc += "non moderated portfilio file " + i + ": id= " + ( (MemberFile)moderationMemberFiles.get( i ) ).memberFileId + ",name= " + ( (MemberFile)moderationMemberFiles.get( i ) ).displayFileName + ", portrait=" + ( (MemberFile)moderationMemberFiles.get( i ) ).portraitImage + ", main=" + ( (MemberFile)moderationMemberFiles.get( i ) ).mainFile + "\n";
    }
    desc += "END OF MEMBER DESCRIPTION";
    return desc;
  }

}