/**************************************************************************************************************
* Macro_Name:   files_in_dir_with_search
*
* Purpose: Retrieves all file names in a directory and stores the names in a sas data set.
*          Optionally searches for a specified search string and returns the file names of those files containing it.
*
*          Works in both Windows and Unix.
*
* Usage: %files_in_dir_with_search(dir=, subDirectories=No, searchForFilename=*, outputDataset=, searchFor=, ignoreCase=Yes, ignoreWildCard=Yes);
*
* Input_parameters: dir
*                    Name of directory to search.
*                   subDirectories
*                    Yes/No. Specify Yes to search all sub-directories.
*                    Default: No
*                   outputDataset
*                    Name of the sas data set to contain the results.
*
*                   The rest of the parameters are optional.
*
*                   searchForFilename
*                    Optional filename to look for. Can contain wild cards.
*                   searchFor
*                    Optional text to search for in files. Only files having the search string are returned.
*                    IMPORTANT: Search string must be enclosed in double quotes.
*                    See note below about using wild cards.
*                   ignoreCase
*                    Yes/No. For searchFor above.
*                    Default: Yes
*                   ignoreWildCard
*                    Yes/No. For searchFor above. Yes treats any wild card characters as regular characters.
*                    Default: Yes
*
* Outputs:  sas data set containing search results.
*
* Returns:  filesFound (global)
*            Number of files found
*           filesWithSearchString (global)
*            Number of files found with search string
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/15/2012  | Michael Gilman| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

/********************************************************************************/
/* Wild Cards                                                                   */
/*                                                                              */
/* ? any 1 character                                                            */
/* ! any 1 character except a blank                                             */
/* * 0 or more characters                                                       */
/* \ 1 or more blanks                                                           */
/* @ any 1 digit                                                                */
/* - 0 or more digits                                                           */
/* + 1 or more digits                                                           */
/* # a number, integer or floating point                                        */
/********************************************************************************/

%macro files_in_dir_with_search(
                    dir=,
                    subDirectories=No,
                    searchForFilename=*,
                    outputDataset=,
                    searchFor=,
                    ignoreCase=Yes,
                    ignoreWildCard=Yes
);

%put Start macro files_in_dir_with_search;

 %local fid fref found did dirid rc outputRef out len i c c2 outputFile dirCount doLoopn
        dirLevel slash
 ;

 %global filesFound maxDirLevel filesWithSearchString;

 %let ignoreCase=%lowcase(&ignoreCase);
 %let ignoreWildCard=%lowcase(&ignoreWildCard);

 %let dirLevel=0;
 %let filesFound=0;
 %let filesWithSearchString=0;

 %if %substr(&sysscp,1,3)=WIN %then %let slash=\;
 %else %let slash=/;

 %if %superq(searchForFilename)=%str() %then %let searchForFilename=*;

 %let subDirectories=%lowcase(&subDirectories);

 %let outputFile=%sysfunc(pathname(work))/files_in_dir.txt;

 %let fref=;

 %let rc=%sysfunc(filename(fref,&outputFile,DISK,LRECL=4000));

 %let fid=%sysfunc(fopen(&fref,O));

 %let outputRef=&fref;

 %let filesOpened=0;

 %let rxParse=0;
 %let rxParseString=;

 %if %sysfunc(indexc(%superq(searchForFilename),%str(.))) %then
 %do;

    %let extension=%sysfunc(lowcase(%scan(%superq(searchForFilename),-1,%str(.))));

 %end;
 %else %let extension=;

 %if %sysfunc(indexc(%bquote(&searchForFilename),%bquote(?!\*@-+#))) %then
 %do; /* Wild card used */

    %let rxParse=1;

    %let findString=&searchForFilename;

    %let findString=%sysfunc(quote(%sysfunc(lowcase(&findString))));

    data _null_;

     length rxParseString $200;

     retain findString &findString;

     len=length(findString);

     rxParseString='';

     do i=1 to len;

        char=substr(findString,i,1);

        if char not in ('?' '!' '\' '*' '@' '+' '#' '-') then rxParseString=trim(rxParseString)!!" "!!char;
        else
        do;

           if char='?' then rxParseString=trim(rxParseString)!!' ?';
           else
           if char='!' then rxParseString=trim(rxParseString)!!' ^" "';
           else
           if char='\' then rxParseString=trim(rxParseString)!!' " "+';
           else
           if char='*' then rxParseString=trim(rxParseString)!!' :';
           else
           if char='@' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''';
           else
           if char='-' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''*';
           else
           if char='+' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''+';
           else
           if char='#' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''+' !!' .*' !!' $''0-9''*';

        end;

     end;

     rxParseString=trim(rxParseString)!!" @0";

     rxParse=rxparse(rxParseString);

     call symputx('rxParseString',rxParseString);

    run;

 %end;/* Wild card used */

%NEXTDIR:

 %let dirLevel=%eval(&dirLevel+1);

 %let fref=;

 %let rc=%sysfunc(filename(fref,%bquote(&dir)));

 %let dirid=%sysfunc(dopen(&fref));

 %let dir&dirLevel=&dir;

 %let dnum&dirLevel=&dirid;

 %let doLoopn=1;

%AGAIN:

 %do dirCount=&doLoopn %to %sysfunc(dnum(&dirid));

    %let entry=%qsysfunc(dread(&dirid,&dirCount));

    %let fref=;

    %let rc=%qsysfunc(filename(fref,%bquote(&dir&slash&entry)));

    %let did=%sysfunc(dopen(&fref));

    %if &did>0 %then %let rc=%sysfunc(dclose(&did));

    %if &did=0 %then
    %do;

       %let filesOpened=%eval(&filesOpened+1);

       %let found=0;

       %if %superq(extension) ne %str() and &rxParse=0 %then
       %do;

          %let entry_r=%qsysfunc(reverse(&entry));

          %let c=%qlowcase(%qscan(%bquote(&entry_r),1,%str(.)));

          %let c2=%qscan(%bquote(&entry_r),2,%str(.));

          %if %bquote(&c2) ne %str() %then
          %do;

             %let c=%sysfunc(reverse(&c));

             %if %sysfunc(indexw(%bquote(&extension),&c)) %then %let found=1;

          %end;

       %end;
       %else
       %do;

           %if &rxParse %then
           %do;

              %let pos=0;

              %let pos=%sysfunc(rxmatch(%sysfunc(rxparse(&rxParseString)),%sysfunc(lowcase(&entry))));

              %if &pos %then %let found=1;

           %end;
           %else %let found=1;

       %end;

       %if &found=1 %then
       %do;

          %let filesFound=%eval(&filesFound+1);

          %let rc=%qsysfunc(fput(&fid,%bquote(%bquote(&dir&slash&entry`&entry`&dirLevel))));

          %let rc=%sysfunc(fwrite(&fid));

       %end;

    %end;
    %else
    %if &subDirectories=yes %then
    %do;

       %let doLoopn&dirLevel=&dirCount;

       %let dir=&dir&slash&entry;

       %goto NEXTDIR;

    %end;

%CONTINUE:

 %end;

 %let dirLevel=%eval(&dirLevel-1);

 %if &dirLevel>0 %then
 %do;

       %let doLoopn=%eval(&&doLoopn&dirLevel+1);

       %let dirid=&&dnum&dirLevel;

       %let dir=&&dir&dirLevel;

       %goto AGAIN;

 %end;

 %do i=1 %to &dirLevel;

    %let rc=%sysfunc(dclose(&&dnum&dirLevel));

 %end;

 %let rc=%sysfunc(fclose(&fid));

 %if &filesFound=0 %then %goto FINISH;

 %if &outputDataset ne %str() %then %let out=&outputDataset;
 %else %let out=_null_;

 %if &outputDataset ne %str() %then
 %do;

    data _null_;
     length folder fullPathname $4000 filename $1000;
     retain maxLenDirfile maxLenFile;
     infile &outputRef truncover end=e;
     input line $4000.;

     fullPathname =scan(line,1,'`');
     filename =scan(line,2,'`');

     if length(fullPathname )>maxLenDirfile then maxLenDirfile=length(fullPathname );
     if length(filename)>maxLenFile then maxLenFile=length(filename);

     if e then
     do;

        call symputx('maxLenDirfile',maxLenDirfile);
        call symputx('maxLenFile',maxLenFile);

     end;

    run;

    data &out;

     length filename $&maxLenFile extension $20  folder fullPathname $&maxLenDirfile dirLevel 4 dirfileq $1000 p $1000;

     retain maxDirLevel;

     infile &outputRef truncover end=e;
     input line $4000.;

     fullPathname =scan(line,1,'`');
     filename =scan(line,2,'`');
     dirLevel=input(scan(line,3,'`'),best.);

     if dirLevel>maxDirLevel then maxDirLevel=dirLevel;

     folder =substr(fullPathname ,1,length(fullPathname )-length(filename )-1);

     pos=indexc(left(reverse(filename )),'.');

     if pos then extension=substr(filename ,length(filename )-pos+2);
     else extension='';

     if e then call symputx('maxDirLevel',maxDirLevel);

     keep folder fullPathname filename extension dirLevel;

    run;

 %end;

 %if %bquote(&searchFor)=%str() %then %goto FINISH;

%LookForTextInFiles:

 %let rxParse=0;
 %let rxParseString=;

 %if %sysfunc(indexc(%bquote(&searchFor),%bquote(?!\*@-+#))) and &ignoreWildCard=no %then
 %do;

    %let rxParse=1;

    %let findString=&searchFor;

    %if &ignoreCase=yes %then %let findString=%sysfunc(lowcase(&findString));

    data _null_;

     length rxParseString $200;

     retain findString &findString;

     len=length(findString);

     rxParseString='';

     do i=1 to len;

        char=substr(findString,i,1);

        if char not in ('?' '!' '\' '*' '@' '+' '#' '-') then rxParseString=trim(rxParseString)!!" "!!char;
        else
        do;

           if char='?' then rxParseString=trim(rxParseString)!!' ?';
           else
           if char='!' then rxParseString=trim(rxParseString)!!' ^" "';
           else
           if char='\' then rxParseString=trim(rxParseString)!!' " "+';
           else
           if char='*' then rxParseString=trim(rxParseString)!!' :';
           else
           if char='@' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''';
           else
           if char='-' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''*';
           else
           if char='+' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''+';
           else
           if char='#' then rxParseString=trim(rxParseString)!!' '!!'$''0-9''+' !!' .*' !!' $''0-9''*';

        end;

     end;

     rxParse=rxparse(rxParseString);

     rxParseString=quote(trim(rxParseString));

     call symputx('rxParseString',rxParseString);

    run;

 %end;

 options nonotes;

 data &outputDataset(keep=folder fullPathname filename extension dirLevel linenum);

  %if &rxParse %then
  %do;

     retain rxParse pos 1;

     if _N_=1 then rxParse=rxparse(&rxParseString);

  %end;

  retain searchFor &searchFor;

  set &outputDataset(rename=(fullPathname=dirFileTemp));

  fullPathname=dirFileTemp;

  infile in filevar=dirFileTemp end=eof truncover;

  found=0;

  linenum=0;

  do while(not eof);

     input line $200.;

     linenum+1;

     if line='' then continue;

     %if &rxParse %then
     %do;

        if "&ignoreCase"='yes' then
        do;

           call rxsubstr(rxParse,lowcase(line),pos,len);

        end;
        else
        do;

           call rxsubstr(rxParse,line,pos,len);

        end;

        if len then found+1;

     %end;
     %else
     %do;

        if "&ignoreCase"='yes' then
        do;

           if index(lowcase(line),lowcase(searchfor)) then found+1;

        end;
        else
        do;

           if index(line,searchfor) then found+1;

        end;

     %end;

     if found then output;

     found=0;

  end;

 run;

 options notes;

 %let dsid=%sysfunc(open(&outputDataset));

 %let filesWithSearchString=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

%FINISH:

 %if &filesFound %then
 %do;

    proc sort;
    by dirlevel folder filename;
    run;

 %end;

 %put Maximum number of nested directories searched: &maxDirLevel;
 %put Number of files accessed: &filesOpened;
 %put Number of files found: &filesFound;

 %if &searchFor ne %str() %then
 %do;

    %put Number of files with search string &searchFor: &filesWithSearchString;

 %end;

%EXIT:

%put End macro files_in_dir_with_search;
%mend files_in_dir_with_search;
