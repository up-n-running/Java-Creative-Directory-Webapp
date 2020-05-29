package com.extware.utils;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

/**
 * Admin functions for email addresses
 *
 * @author   John Milner
 */
public class EmailAddressUtils
{

/**
 * For deciphering if an email address is valid
 *
 * @param string  email address to check
 * @return        true if it's valid, false otherwise
 */
  public static boolean isValidEmailAddress( String email )
  {
    try
    {
      InternetAddress.parse( email, true );
    }
    catch( AddressException ex )
    {
      return false;
    }

    if( email.indexOf( "@" ) == -1 )
    {
      return false;
    }

    return true;
  }

}