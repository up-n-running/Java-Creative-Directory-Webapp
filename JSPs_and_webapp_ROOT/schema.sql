CREATE TABLE dual
(
  id INTEGER NOT NULL,
  lastCronTime TIMESTAMP
);

GRANT SELECT, UPDATE, REFERENCES ON dual TO EXTWARE;

ALTER TABLE dual ADD CONSTRAINT dualOneRowChk CHECK ( id = 1 );
ALTER TABLE dual ADD CONSTRAINT dualOneRowUniq UNIQUE( id );

INSERT INTO DUAL ( id ) VALUES ( 1 );

CREATE UNIQUE INDEX DUAL_IDX ON DUAL (id);



CREATE TABLE MEMBERCONTACTS
(
  memberContactId         INTEGER NOT NULL,
  lastUpdatedDate         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  name                    VARCHAR(200) NOT NULL,
  nameFirstLetter         VARCHAR(1) NOT NULL,
  statusRef               INTEGER NOT NULL,
  statusOther             VARCHAR(200),
  primaryCategoryRef      INTEGER NOT NULL,
  primaryDisciplineRef    INTEGER NOT NULL,
  secondaryCategoryRef    INTEGER,
  secondaryDisciplineRef  INTEGER,
  tertiaryCategoryRef     INTEGER,
  tertiaryDisciplineRef   INTEGER,
  sizeRef                 INTEGER NOT NULL,
  countryRef              INTEGER NOT NULL,
  regionRef               INTEGER,
  address1                VARCHAR(200) NOT NULL,
  address2                VARCHAR(200),
  city			  VARCHAR(200) NOT NULL,
  postcode                VARCHAR(200) NOT NULL,
  countyRef               INTEGER,
  contactTitleRef         INTEGER NOT NULL,
  contactFirstName        VARCHAR(200) NOT NULL,
  contactSurname          VARCHAR(200) NOT NULL,
  telephone               VARCHAR(200) NOT NULL,
  mobile                  VARCHAR(200),
  fax                     VARCHAR(200),
  webaddress              VARCHAR(200),
  whereDidYouHearRef      INTEGER NOT NULL,
  whereDidYouHearOther    VARCHAR(200),
  whereDidYouHearMagazine VARCHAR(200),
CONSTRAINT MEMBERCONTACTS_PK PRIMARY KEY ( memberContactId )
);

CREATE ASCENDING INDEX MEMBERCONTACTS_LASTUPDATE_IDX ON MEMBERCONTACTS ( lastUpdatedDate );
CREATE ASCENDING INDEX MEMBERCONTACTS_STATUS_IDX ON MEMBERCONTACTS ( statusRef );
CREATE ASCENDING INDEX MEMBERCONTACTS_CATDIS1_IDX ON MEMBERCONTACTS ( primaryCategoryRef, primaryCategoryRef );
CREATE ASCENDING INDEX MEMBERCONTACTS_CATDIS2_IDX ON MEMBERCONTACTS ( secondaryCategoryRef, secondaryDisciplineRef );
CREATE ASCENDING INDEX MEMBERCONTACTS_CATDIS3_IDX ON MEMBERCONTACTS ( tertiaryCategoryRef, tertiaryDisciplineRef );
CREATE ASCENDING INDEX MEMBERCONTACTS_SIZEREF_IDX ON MEMBERCONTACTS ( sizeRef );
CREATE ASCENDING INDEX MEMBERCONTACTS_COUNTRY_IDX ON MEMBERCONTACTS ( countryRef );
CREATE ASCENDING INDEX MEMBERCONTACTS_REIGCOUNT_IDX ON MEMBERCONTACTS ( regionRef, countyRef );
CREATE INDEX MEMBERCONTACTS_FSTLETTER_IDX ON MEMBERCONTACTS ( nameFirstLetter );


GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERCONTACTS TO EXTWARE;

CREATE GENERATOR MEMBERCONTACTS_PKGEN;
SET TERM ^ ;
CREATE TRIGGER MEMBERCONTACTS_PKTRG FOR MEMBERCONTACTS
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberContactId IS NULL )THEN
      NEW.memberContactId = GEN_ID( MEMBERCONTACTS_PKGEN, 1 );
  END
 ^
SET TERM ; ^




CREATE TABLE MEMBERPROFILES
(
  memberProfileId 		INTEGER NOT NULL,
  lastUpdatedDate		TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  personalStatement		VARCHAR(2000) NOT NULL,
  specialisations		VARCHAR(2000) NOT NULL,
  keywords			VARCHAR(2000) NOT NULL,
CONSTRAINT MEMBERPROFILES_PK PRIMARY KEY ( memberProfileId )
);

CREATE ASCENDING INDEX MEMBERPROFILES_LASTUPDATE_IDX ON MEMBERPROFILES (lastUpdatedDate);

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERPROFILES TO EXTWARE;

CREATE GENERATOR MEMBERPROFILES_PKGEN;
SET TERM ^ ;
CREATE TRIGGER MEMBERPROFILES_PKTRG FOR MEMBERPROFILES
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberProfileId IS NULL )THEN
      NEW.memberProfileId = GEN_ID( MEMBERPROFILES_PKGEN, 1 );
  END
 ^
SET TERM ; ^


CREATE TABLE MEMBERS
(
  memberId                   INTEGER NOT NULL,
  memberContactId            INTEGER,
  memberProfileId	     INTEGER,
  moderationMemberContactId  INTEGER,
  moderationMemberProfileId  INTEGER,
  placedAdvert               VARCHAR(1) DEFAULT 'f' NOT NULL ,
  email                      VARCHAR(200) NOT NULL,
  passwd                     VARCHAR(200) NOT NULL,
  profileURL                 VARCHAR(200) NOT NULL,
  regDate                    TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  lastPaymentDate            TIMESTAMP,
  goLiveDate                 TIMESTAMP,
  expiryDate                 TIMESTAMP,
  onModerationHold           VARCHAR(1) DEFAULT 'f' NOT NULL,
  wentOnHoldDate             TIMESTAMP,
  emailValidated             VARCHAR(1) DEFAULT 'f' NOT NULL,
  validationKey              INTEGER NOT NULL,
CONSTRAINT MEMBERS_PK PRIMARY KEY ( memberId )
);

CREATE UNIQUE INDEX MEMBERS_EMAIL_IDX ON MEMBERS ( email );
CREATE INDEX MEMBERS_EXPIRYDATE_IDX ON MEMBERS ( expiryDate );


ALTER TABLE MEMBERS ADD CONSTRAINT MEMBERS_MEMBERCONTACTS_FK FOREIGN KEY (memberContactId) REFERENCES MEMBERCONTACTS (memberContactId) ON DELETE SET NULL;
ALTER TABLE MEMBERS ADD CONSTRAINT MEMBERS_MEMBERPROFILES_FK FOREIGN KEY (memberProfileId) REFERENCES MEMBERPROFILES (memberProfileId) ON DELETE SET NULL;
ALTER TABLE MEMBERS ADD CONSTRAINT MEMBERS_MODMEMBERCONTACTS_FK FOREIGN KEY (moderationMemberContactId) REFERENCES MEMBERCONTACTS (memberContactId) ON DELETE SET NULL;
ALTER TABLE MEMBERS ADD CONSTRAINT MEMBERS_MODMEMBERPROFILES_FK FOREIGN KEY (moderationMemberProfileId) REFERENCES MEMBERPROFILES (memberProfileId) ON DELETE SET NULL;

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERS TO EXTWARE;

CREATE GENERATOR MEMBERS_PKGEN;
SET TERM ^ ;

CREATE TRIGGER MEMBERS_PKTRG FOR MEMBERS
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberId IS NULL )THEN
      NEW.memberId = GEN_ID( MEMBERS_PKGEN, 1 );
  END
 ^

CREATE TRIGGER MEMBERS_HOLDDATE FOR MEMBERS
ACTIVE BEFORE UPDATE POSITION 1
AS BEGIN
    IF( OLD.onModerationHold='t' AND NEW.onModerationHold='f' )THEN
      NEW.wentOnHoldDate = NULL;
    IF( OLD.onModerationHold='f' AND NEW.onModerationHold='t' )THEN
      NEW.wentOnHoldDate = CURRENT_TIMESTAMP;
  END
 ^

CREATE TRIGGER MEMBERS_ONDELETE FOR MEMBERS
ACTIVE AFTER DELETE POSITION 2
AS BEGIN
    IF( OLD.memberContactId IS NOT NULL )THEN
      DELETE FROM MEMBERCONTACTS WHERE memberContactId = OLD.memberContactId;
    IF( OLD.moderationMemberContactId IS NOT NULL )THEN
      DELETE FROM MEMBERCONTACTS WHERE memberContactId = OLD.moderationMemberContactId;
    IF( OLD.memberProfileId IS NOT NULL )THEN
      DELETE FROM MEMBERPROFILES WHERE memberProfileId = OLD.memberProfileId;
    IF( OLD.moderationMemberProfileId IS NOT NULL )THEN
      DELETE FROM MEMBERPROFILES WHERE memberProfileId = OLD.moderationMemberProfileId;
  END
 ^

 SET TERM ^ ;



CREATE TABLE MEMBERSEARCHWORDS
(
  memberSearchWordId INTEGER NOT NULL,
  memberId           INTEGER NOT NULL,
  searchWord         VARCHAR(190) NOT NULL,
CONSTRAINT MEMBERSEARCHWORDS_PK PRIMARY KEY ( memberSearchWordId )
);

ALTER TABLE MEMBERSEARCHWORDS ADD CONSTRAINT MEMBERSEARCHWORDS_UNIQ UNIQUE ( searchWord, memberId );

CREATE INDEX MEMBERS_SRCH_IDX ON MEMBERSEARCHWORDS ( searchWord );

ALTER TABLE MEMBERSEARCHWORDS ADD CONSTRAINT MEMBERSEARCHWORDS_MEMBERS_FK FOREIGN KEY (memberId) REFERENCES MEMBERS ( memberId ) ON DELETE CASCADE;

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERSEARCHWORDS TO EXTWARE;

CREATE GENERATOR MEMBERSEARCHWORDS_PKGEN;
SET TERM ^ ;

CREATE TRIGGER MEMBERSEARCHWORDS_PKTRG FOR MEMBERSEARCHWORDS
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberSearchWordId IS NULL )THEN
      NEW.memberSearchWordId = GEN_ID( MEMBERSEARCHWORDS_PKGEN, 1 );
  END
 ^
SET TERM ; ^



CREATE TABLE MEMBERFILES
(
  memberFileId    INTEGER NOT NULL,
  memberId        INTEGER NOT NULL,
  assetId         INTEGER NOT NULL,
  description     VARCHAR(200) NOT NULL,
  keywords        VARCHAR(200) NOT NULL,
  displayFileName VARCHAR(200) NOT NULL,
  mimeType        VARCHAR(200) NOT NULL,
  fileByteSize    INTEGER NOT NULL,
  isImage         VARCHAR(1) NOT NULL,
  mainFile        VARCHAR(1) NOT NULL,
  portraitImage   VARCHAR(1) NOT NULL,
  forModeration   VARCHAR(1) NOT NULL,
  uploadDate      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
CONSTRAINT MEMBERFILES_PK PRIMARY KEY ( memberFileId ),
CONSTRAINT MEMBERFILES_UNIQ UNIQUE ( memberId, assetId )
);

CREATE ASCENDING INDEX MEMBERFILES_FORMOD_IDX ON MEMBERFILES ( forModeration );
CREATE DESCENDING INDEX MEMBERFILES_FORMOD_IDX2 ON MEMBERFILES ( forModeration );
CREATE DESCENDING INDEX MEMBERFILES_MAINFLE_IDX ON MEMBERFILES ( mainFile );
CREATE DESCENDING INDEX MEMBERFILES_LOGO_IDX ON MEMBERFILES ( portraitImage );
CREATE DESCENDING INDEX MEMBERFILES_ISIMAGE_IDX ON MEMBERFILES ( isImage );
CREATE DESCENDING INDEX MEMBERFILES_MEMBERID_IDX ON MEMBERFILES ( memberId );

ALTER TABLE MEMBERFILES ADD CONSTRAINT MEMBERFILES_MEMBERS_FK FOREIGN KEY (memberId) REFERENCES MEMBERS (memberId) ON DELETE CASCADE;
ALTER TABLE MEMBERFILES ADD CONSTRAINT MEMBERFILES_ASSETS_FK FOREIGN KEY (assetId) REFERENCES ASSETS (assetId) ON DELETE CASCADE;

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERFILES TO EXTWARE;

CREATE GENERATOR MEMBERFILES_PKGEN;
SET TERM ^ ;
CREATE TRIGGER MEMBERFILES_PKTRG FOR MEMBERFILES
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberFileId IS NULL )THEN
      NEW.memberFileId = GEN_ID( MEMBERFILES_PKGEN, 1 );
  END
 ^

CREATE TRIGGER MEMBERFILES_ASSETDELETE FOR MEMBERFILES
ACTIVE AFTER DELETE POSITION 1
AS BEGIN
    IF( OLD.assetId IS NOT NULL )THEN
      DELETE FROM ASSETS WHERE assetId = OLD.assetId;
  END
 ^

SET TERM ; ^



CREATE TABLE MEMBERFILESEARCHWORDS
(
  memberFileSearchWordId INTEGER NOT NULL,
  memberFileId           INTEGER NOT NULL,
  searchWord             VARCHAR(190) NOT NULL,
CONSTRAINT MEMBERFILESEARCHWORDS_PK PRIMARY KEY ( memberFileSearchWordId )
);

ALTER TABLE MEMBERFILESEARCHWORDS ADD CONSTRAINT FILESEARCHWORDS_UNIQ UNIQUE ( searchWord, memberFileId );
ALTER TABLE MEMBERFILESEARCHWORDS ADD CONSTRAINT FILESEARCHWORDS_MEMBERFILES_FK FOREIGN KEY (memberFileId) REFERENCES MEMBERFILES ( memberFileId ) ON DELETE CASCADE;

CREATE INDEX FILES_SRCH_IDX ON MEMBERFILESEARCHWORDS ( searchWord );

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERFILESEARCHWORDS TO EXTWARE;

CREATE GENERATOR MEMBERFILESEARCHWORDS_PKGEN;
SET TERM ^ ;

CREATE TRIGGER MEMBERFILESEARCHWORDS_PKTRG FOR MEMBERFILESEARCHWORDS
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberFileSearchWordId IS NULL )THEN
      NEW.memberFileSearchWordId = GEN_ID( MEMBERFILESEARCHWORDS_PKGEN, 1 );
  END
 ^
SET TERM ; ^




CREATE TABLE MEMBERJOBS
(
  memberJobId      INTEGER NOT NULL,
  memberId         INTEGER NOT NULL,
  creationDate     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  lastUpdatedDate  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  referenceNo      VARCHAR(100) NOT NULL,
  title            VARCHAR(200) NOT NULL,
  mainCategoryRef  INTEGER NOT NULL,
  disciplineRef    INTEGER NOT NULL,
  typeOfWorkRef    INTEGER NOT NULL,
  salary           VARCHAR(200) NOT NULL,
  countryRef       INTEGER NOT NULL,
  ukRegionRef      INTEGER,
  countyRef        INTEGER,
  city             VARCHAR(200),
  telephone        VARCHAR(200) NOT NULL,
  email            VARCHAR(200) NOT NULL,
  contactName      VARCHAR(200) NOT NULL,
  description      VARCHAR(2000) NOT NULL,
  forModeration    VARCHAR(1) NOT NULL,
  moderatedJobId   INTEGER,
CONSTRAINT MEMBERJOBS_PK PRIMARY KEY ( memberJobId ),
CONSTRAINT MEMBERJOBS_UNIQ UNIQUE ( memberId, referenceNo, forModeration )
);

ALTER TABLE MEMBERJOBS ADD CONSTRAINT MEMBERJOBS_MEMBERS_FK FOREIGN KEY (memberId) REFERENCES MEMBERS (memberId) ON DELETE CASCADE;
ALTER TABLE MEMBERJOBS ADD CONSTRAINT MEMBERJOBS_MEMBERJOBS_FK FOREIGN KEY (moderatedJobId) REFERENCES MEMBERJOBS (memberJobId) ON DELETE SET NULL;

CREATE ASCENDING INDEX MEMBERJOBS_WORKTYPE_IDX ON MEMBERJOBS ( typeOfWorkRef );
CREATE ASCENDING INDEX MEMBERJOBS_CATDIS_IDX ON MEMBERJOBS ( mainCategoryRef, disciplineRef );
CREATE ASCENDING INDEX MEMBERJOBS_COUNTRY_IDX ON MEMBERJOBS ( countryRef );
CREATE ASCENDING INDEX MEMBERJOBS_REIGCOUNTY_IDX ON MEMBERJOBS ( ukRegionRef, countyRef );


GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERJOBS TO EXTWARE;

CREATE GENERATOR MEMBERJOBS_PKGEN;
SET TERM ^ ;
CREATE TRIGGER MEMBERJOBS_PKTRG FOR MEMBERJOBS
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberJobId IS NULL )THEN
      NEW.memberJobId = GEN_ID( MEMBERJOBS_PKGEN, 1 );
  END
 ^
SET TERM ; ^



CREATE TABLE MEMBERJOBSEARCHWORDS
(
  memberJobSearchWordId INTEGER NOT NULL,
  memberJobId           INTEGER NOT NULL,
  searchWord             VARCHAR(190) NOT NULL,
CONSTRAINT MEMBERJOBSEARCHWORDS_PK PRIMARY KEY ( memberJobSearchWordId )
);

ALTER TABLE MEMBERJOBSEARCHWORDS ADD CONSTRAINT JOBSEARCHWORDS_UNIQ UNIQUE ( searchWord, memberJobId );
ALTER TABLE MEMBERJOBSEARCHWORDS ADD CONSTRAINT JOBSEARCHWORDS_MEMBERJOB_FK FOREIGN KEY (memberJobId) REFERENCES MEMBERJOBS ( memberJobId ) ON DELETE CASCADE;

CREATE INDEX JOBS_SRCH_IDX ON MEMBERJOBSEARCHWORDS ( searchWord );

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBERJOBSEARCHWORDS TO EXTWARE;

CREATE GENERATOR MEMBERJOBSEARCHWORDS_PKGEN;
SET TERM ^ ;

CREATE TRIGGER MEMBERJOBSEARCHWORDS_PKTRG FOR MEMBERJOBSEARCHWORDS
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.memberJobSearchWordId IS NULL )THEN
      NEW.memberJobSearchWordId = GEN_ID( MEMBERJOBSEARCHWORDS_PKGEN, 1 );
  END
 ^
SET TERM ; ^




CREATE TABLE ADVERTS
(
  advertId                INTEGER NOT NULL,
  creationDate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  paymentDate             TIMESTAMP,
  moderatedDate           TIMESTAMP,
  goLiveDate              TIMESTAMP,
  expiryDate              TIMESTAMP,
  assetId                 INTEGER NOT NULL,
  dueLiveDate             TIMESTAMP,
  name                    VARCHAR(200) NOT NULL,
  statusRef               INTEGER NOT NULL,
  statusOther             VARCHAR(200),
  countryRef              INTEGER NOT NULL,
  regionRef               INTEGER,
  address1                VARCHAR(200) NOT NULL,
  address2                VARCHAR(200),
  city                    VARCHAR(200) NOT NULL,
  postcode                VARCHAR(200) NOT NULL,
  countyRef               INTEGER,
  telephone               VARCHAR(200) NOT NULL,
  fax                     VARCHAR(200),
  email                   VARCHAR(200) NOT NULL,
  webAddress              VARCHAR(200) NOT NULL,
  whereDidYouHearRef      INTEGER NOT NULL,
  whereDidYouHearOther    VARCHAR(200),
  whereDidYouHearMagazine VARCHAR(200),
  premierePosition        VARCHAR(1) NOT NULL,
  durationMonths          INTEGER NOT NULL,
  onModerationHold        VARCHAR(1) NOT NULL,
  wentOnHoldDate          TIMESTAMP,
CONSTRAINT ADVERTS_PK PRIMARY KEY ( advertId )
);

CREATE DESCENDING INDEX ADS_paymentDate_IDX ON ADVERTS ( paymentDate );
CREATE ASCENDING INDEX ADS_goLiveDate_IDX ON ADVERTS ( goLiveDate );
CREATE DESCENDING INDEX ADS_expiryDate_IDX ON ADVERTS ( expiryDate );

ALTER TABLE ADVERTS ADD CONSTRAINT ADVERTS_ASSETS_FK FOREIGN KEY (assetId) REFERENCES ASSETS (assetId) ON DELETE CASCADE;

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON ADVERTS TO EXTWARE;

CREATE GENERATOR ADVERTS_PKGEN;

SET TERM ^ ;

CREATE TRIGGER ADVERTS_PKTRG FOR ADVERTS
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.advertId IS NULL )THEN
      NEW.advertId = GEN_ID( ADVERTS_PKGEN, 1 );
  END
 ^

CREATE TRIGGER ADVERTS_HOLDDATE FOR ADVERTS
ACTIVE BEFORE UPDATE POSITION 1
AS BEGIN
    IF( OLD.onModerationHold='t' AND NEW.onModerationHold='f' )THEN
      NEW.wentOnHoldDate = NULL;
    IF( OLD.onModerationHold='f' AND NEW.onModerationHold='t' )THEN
      NEW.wentOnHoldDate = CURRENT_TIMESTAMP;
  END
 ^

SET TERM ; ^



CREATE TABLE WORLDPAYRESPONSES
(
  wpResponseId    INTEGER NOT NULL,
  advertId        INTEGER,
  memberId        INTEGER,
  transId         VARCHAR(25),
  cartId          VARCHAR(25) NOT NULL,
  instId          VARCHAR(25),
  responseDate    TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  transTime       VARCHAR(25),
  name            VARCHAR(300),
  tel             VARCHAR(300),
  email           VARCHAR(300),
  amount          VARCHAR(25) NOT NULL,
  currency        VARCHAR(25) NOT NULL,
  description     VARCHAR(300),
  transStatus     VARCHAR(10) NOT NULL,
  rawAuthMessage  VARCHAR(300),
  rawAuthCode     VARCHAR(10),
  avs             VARCHAR(10),
  authCurrency    VARCHAR(10) NOT NULL,
  authAmmount     VARCHAR(25) NOT NULL,
  cardType        VARCHAR(100),
CONSTRAINT WORLDPAYRESPONSES_PK PRIMARY KEY ( wpresponseid )
);


ALTER TABLE WORLDPAYRESPONSES ADD CONSTRAINT WORLDPAYRESPONSES_MEMBERS_FK FOREIGN KEY (memberId) REFERENCES MEMBERS (memberId) ON DELETE SET NULL;
ALTER TABLE WORLDPAYRESPONSES ADD CONSTRAINT WORLDPAYRESPONSES_ADVERTS_FK FOREIGN KEY (advertId) REFERENCES ADVERTS (advertId) ON DELETE SET NULL;

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON WORLDPAYRESPONSES TO EXTWARE;

CREATE GENERATOR WORLDPAYRESPONSES_PKGEN;
SET TERM ^ ;
CREATE TRIGGER WORLDPAYRESPONSES_PKTRG FOR WORLDPAYRESPONSES
ACTIVE BEFORE INSERT POSITION 0
AS BEGIN
    IF( NEW.wpResponseId IS NULL )THEN
      NEW.wpResponseId = GEN_ID( WORLDPAYRESPONSES_PKGEN, 1 );
  END
 ^
SET TERM ; ^





COMMIT WORK;



INSERT INTO imagepostprocesses (POSTPROCESSID , 	PROCESSNAME , 	LANDSCAPEX , 	LANDSCAPEY , 	SQUARE , 	SQUAREASPECTTOLERANCE , 	PORTRAITX , 	PORTRAITY,  	FILEEXTENSION , 	BACKFILL , 	QUALITY ) VALUES ( 1 , 	'Thumbnail'  	          ,    80 , 	80  ,	80  ,0.1   ,80  	 , 80  ,	'jpg'  	,null  	,96   );
INSERT INTO imagepostprocesses (POSTPROCESSID , 	PROCESSNAME , 	LANDSCAPEX , 	LANDSCAPEY , 	SQUARE , 	SQUAREASPECTTOLERANCE , 	PORTRAITX , 	PORTRAITY,  	FILEEXTENSION , 	BACKFILL , 	QUALITY ) VALUES ( 2 , 	'Portfolio Main'         ,    307,  	209 , 209 ,0.0001, 307 , 	209  	,'jpg'  	,null  	,86   );
INSERT INTO imagepostprocesses (POSTPROCESSID , 	PROCESSNAME , 	LANDSCAPEX , 	LANDSCAPEY , 	SQUARE , 	SQUAREASPECTTOLERANCE , 	PORTRAITX , 	PORTRAITY,  	FILEEXTENSION , 	BACKFILL , 	QUALITY ) VALUES ( 12,  	'Large Image'  	      ,    200,  	140 , 170 ,0.176 , 	140,  	200 , 	'jpg' , null  ,	76  );
INSERT INTO imagepostprocesses (POSTPROCESSID , 	PROCESSNAME , 	LANDSCAPEX , 	LANDSCAPEY , 	SQUARE , 	SQUAREASPECTTOLERANCE , 	PORTRAITX , 	PORTRAITY,  	FILEEXTENSION , 	BACKFILL , 	QUALITY ) VALUES ( 13,  	'Advert'  	          ,    150,  	46  ,	46  ,0.0   ,150   ,   46,  	'gif' , 	null  ,	256 );
INSERT INTO imagepostprocesses (POSTPROCESSID , 	PROCESSNAME , 	LANDSCAPEX , 	LANDSCAPEY , 	SQUARE , 	SQUAREASPECTTOLERANCE , 	PORTRAITX , 	PORTRAITY,  	FILEEXTENSION , 	BACKFILL , 	QUALITY ) VALUES ( 14,  	'SrchResults'  	      ,    54 , 	54  ,	54  ,0.01  	,54  	 , 54  ,	'gif'  	,null  	,32   );
INSERT INTO imagepostprocesses (POSTPROCESSID , 	PROCESSNAME , 	LANDSCAPEX , 	LANDSCAPEY , 	SQUARE , 	SQUAREASPECTTOLERANCE , 	PORTRAITX , 	PORTRAITY,  	FILEEXTENSION , 	BACKFILL , 	QUALITY ) VALUES ( 15,  	'ProfilePageLogoImage',  	150 , 	148 ,148  ,0.0  , 150 , 	148  	,'gif'  	,null  	,128  );

set generator IMAGEPOSTPROCESSES_PKGEN to 16;

INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (1 , 	  'Inline Image'      );
INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (2 , 	  'Downloadable File' );
INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (3 , 	  'Banner'            );
INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (4 , 	  'Rich Text Image'   );
INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (9 , 	  'Portfolio Image'   );
INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (10,  	'Portfolio File'    );
INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (11,  	'Profile Image'     );
INSERT INTO assettypes (ASSETTYPEID, 	ASSETTYPENAME ) VALUES (12,  	'Advert'            );

set generator ASSETTYPES_PKGEN to 13;

INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 1 , 	1   );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 2 , 	1   );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 1 , 	4   );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 2 , 	4   );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 12,  	4   );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 2 , 	9   );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 1 , 	9   );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 13,  	12  );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 14,  	10  );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 14,  	11  );
INSERT INTO assettypepostprocesses ( POSTPROCESSID, 	ASSETTYPEID ) VALUES ( 15,  	11  );


INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 5  , 	'Register - Join Up: 1) Para After Step 4',   	                  'regjoinup1'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 8  ,	'Register - Contact Details: 2) Beneath Form',    	              'regcontact2' , ''  );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 6  ,	'Register - Join Up: 2) Example Directory entry',  	              'regjoinup2'  , ''  );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 4  ,	'Homepage: 1) Intro Paragraph',                    	              'homepage1'  	, '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 9  ,	'Register - Profile Details: 1) Intro Para',  	                  'regprofile1' , ''  );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 7  ,	'Register - Contact Details: 1) Intro Para',  	                  'regcontact1' , ''  );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 10 , 	'Register - Profile Details: 2) Personal Statement Intro',  	    'regprofile2' , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 13 , 	'Register - Portfolio Files: 1) Intro Para',  	                  'regfile1'  	, '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 11 , 	'Register - Profile Details: 3) Specialisations Intro',  	        'regprofile3' , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 12 , 	'Register - Profile Details: 4) Keywords Intro',        	        'regprofile4' , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 14 , 	'Account Manager 1) Intro Para',  	                              'accman1'  	  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 15 , 	'Jobs Add/Edit Page (add): 1) Intro Para',  	                    'jobsadd1'  	, '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 16 , 	'Jobs Add/Edit Page (edit): 1) Intro Para',  	                    'jobsedit1'  	, '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 17 , 	'Advertising Setup Page: 1) Intro Para',  	                      'advert1'  	  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 18 , 	'Advertising Setup Page: 2) This is outstanding value',           'advert2'     , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 19 , 	'Advertising Pre-Payment Page: 1) Intro Para',  	                'advertpay1'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 20 , 	'Membership pre-payment page: 1) Intro Para',  	                  'memberpay1'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 21 , 	'Register - Join Up: 3) Final sentence',  	                      'regjoinup3'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 23 , 	'Membership post-payment page-Y: 1) Payment successful',  	      'memPayYes1'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 22 , 	'Membership pre-payment page: 2) Moseration Procedure para',	    'memberpay2'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 24 , 	'Membership post-payment page-N: 1) Payment Unsuccessful',  	    'memPayNo1'  	, '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 26 , 	'Membership post-payment page-Y: 2) Welcome to Nextface',         'memPayYes2'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 25 , 	'Membership post-payment page-N: 2) 7 days to pay',  	            'memPayNo2'  	, '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 27 , 	'Login Failure Page: 1) Your details were invalid',  	            'login1'  	  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 28 , 	'Jobs Add/Edit Page: 2) Allow for Moderation',              	    'jobsadd2'  	, '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 29 , 	'Login Expired Page: 1) Please login again',  	                  'loggedout1'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 31 , 	'Forgotten Password (before email): 1) Enter your email here',  	'forgotpass1' , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 33 , 	'Forgotten Password (after failure): 1) Email address not found', 'forgotpass2N', '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 30 , 	'Advertising Pre-Payment Page: 2) Moderation Procedure Para',    	'advertpay2'  , '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 32 , 	'Forgotten Password (after email): 1) Email has been sent',      	'forgotpass2Y', '' );
INSERT INTO textpages (textpageid, pagename, pagehandle, pagecontent ) VALUES ( 34 , 	'BUGS/CHANGES',                                                  	'bugschanges' , '' );

set generator textpages_PKGEN to 35;

COMMIT WORK;





CREATE TABLE MEMBEROFWEEK
(
  weekDescriptor        VARCHAR(10) NOT NULL,
  memberId              INTEGER NOT NULL,
  description           VARCHAR(100),
CONSTRAINT MEMBEROFWEEK_PK PRIMARY KEY ( weekDescriptor )
);

GRANT DELETE, INSERT, SELECT, UPDATE, REFERENCES ON MEMBEROFWEEK TO EXTWARE;

ALTER TABLE MEMBEROFWEEK ADD CONSTRAINT MEMBEROFWEEK_MEMBERID_FK FOREIGN KEY (memberId) REFERENCES MEMBERS ( memberId ) ON DELETE CASCADE;

CREATE ASCENDING UNIQUE INDEX MEMBEROFWEEK_WEEK_IDX ON MEMBEROFWEEK ( weekDescriptor );
CREATE DESCENDING UNIQUE INDEX MEMBEROFWEEK_WEEK_IDX ON MEMBEROFWEEK ( weekDescriptor );

CREATE INDEX MEMBEROFWEEK_MEMBER_IDX ON MEMBEROFWEEK ( memberId );






--update, to do list

alter table memberjobs alter description type varchar(2000)

check this out:
Error: 500
Location: /pages/emailAdmin.jsp
Internal Servlet Error:
org.apache.jasper.JasperException: Unable to compile class for JSP/home/httpd/tomcat/work/nextface.s.11tth.com_8080/_0002fpages_0002femailAdmin_0002ejspemailAdmin_jsp_0.java:120: Undefined variable or class name: EmailSender boolean addressOk = EmailSender.sendMail( "emailvalidate", "Welcome to Nextface, please validate your Email Address", formMember, new ArrayList(), new ArrayList() ); ^ /home/httpd/tomcat/work/nextface.s.11tth.com_8080/_0002fpages_0002femailAdmin_0002ejspemailAdmin_jsp_0.java:125: Undefined variable: errorsToReport if( errorsToReport != null ) ^ /home/httpd/tomcat/work/nextface.s.11tth.com_8080/_0002fpages_0002femailAdmin_0002ejspemailAdmin_jsp_0.java:133: Undefined variable or class name: errorsToReport for( int i=0; i< pre home>
HIGH
OPEN









--REMEMBER TO REMAKE ALL TABLES DUE TO CHANGES

recompile

copy webapp to another directory

MY REGEXP
<jsp:include page="(.*)"
<jsp:include page="\1" flush="true"

zip and ftp to sigma

ENSURE ELEVENTEENTH HAS CONTROLL OF DOMAINS

worldpay stuff
wp27268184
CHIMPS
cc no 4000 0000 0000 0002
ext 123


ORDERING OF MEMBER thingies
not on hold
  paid
    not live yet
      least recently updated
      most recently updated
    live currently
      least recently updated
      most recently updated
    expired
      least recently updated
      most recently updated
  unpaid
    least recently updated
    most recently updated
on hold
  paid
    not live yet
      least recently updated
      most recently updated
    live currently
      least recently updated
      most recently updated
    expired
      least recently updated
      most recently updated
  unpaid
    least recently updated
    most recently updated




