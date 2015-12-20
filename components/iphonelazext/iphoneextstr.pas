{
 *****************************************************************************
 *                                                                           *
 *  This file is part of the iPhone Laz Extension                            *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit iPhoneExtStr;

{$mode objfpc}{$H+}

interface

resourcestring
  striPhoneProject = 'iPhone Project';
  strStartAtXcode  = 'Update Xcode project';
  strRunSimulator  = 'Run iPhone Simulator';

  strPrjOptTitle    = 'iPhone specific';
  strPrjOptIsiPhone = 'is iPhone application project';
  strPrjOptSDKver   = 'SDK version:';
  strPrjOptCheckSDK = 'Check available SDKs';
  strPtrOptAppID     = 'Application ID';
  strPtrOptAppIDHint = 'It''s recommended by Apple to use domain-structured identifier i.e. "com.mycompany.myApplication"';

  strXcodeUpdated   = 'Xcode project updated (%s)';

  strWNoSDKSelected = 'Warning: SDK is not selected using %s';
  strWNoSDK         = 'Warning: No SDK available. Linking might fail.';


  strOpenXibAtIB    = 'Open "%s" at Interface Builder';
  strOpenAtIB       = 'Open at Interface Builder';

implementation

end.

