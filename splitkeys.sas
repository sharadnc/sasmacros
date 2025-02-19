/*
Taking an example...


*/

data flags;
set sashelp.flags;
run;

/**
To be called like this...
%splitdsnverticallykey(dsn,varperdsn,keyvars=);
eg. %splitdsnverticallykey(sashelp.vtable,4,keyvars=memname libname);
Where -----------
dsn - libname.datasetname to be split
varperdsn - How many vars per dsn excluding the key variables
keyvars - specify the primary key variables
*/ 



%macro splitdsnverticallykey(dsn,varperdsn,keyvars=);

/* split the keyvars into individual macro var names*/ 
%let num=1;
%let keyvar=%scan(&keyvars,&num,' ');
%let keyvar&num=&keyvar;
%let keyvarstr=%str(%")&keyvar%str(%",);

%do %while(&keyvar ne );
            %let num=%eval(&num + 1);
            %let keyvar=%scan(&keyvars,&num,' ');
            %let keyvar&num=&keyvar;
            %if &keyvar ne  %then %let keyvarstr=&keyvarstr%str(%")&keyvar%str(%",);
%end;

%let numkeyvars=%eval(&num - 1);
%let keyvarstr=%substr(&keyvarstr,1,%length(&keyvarstr)-1);

data _null_;
/*Open the dataset and assign to handler*/  
   dsid=open("&dsn","i"); 

   /*attrn with nvars gives u the count of variables */ 
   numofvars=attrn(dsid,"nvars"); 
   call symput('numofvars',numofvars-&numkeyvars);

   /*identify total number of dsns would it fit excluding the key vars*/ 
   totalnumdsns=ceil((numofvars-&numkeyvars)/&varperdsn);

   call symput('totalnumdsns',totalnumdsns);

   do i=1 to numofvars;

     varname=trim(left(varname(dsid,i)));    
     if varname not in (&keyvarstr) then 
       do;
           k+1;
           /*Get the name of the variables into macro variables*/ 
           call symput(compress('varname'||k),varname); 
       end;
   end;
   rc=close(dsid);
run;

%let totalnumdsns=&totalnumdsns;
%let numofvars=&numofvars;
%put The dataset &dsn with &numofvars of variables excluding variables {&keyvars} is split vertically into &totalnumdsns datasets;

/* name the datasets in sequence */ 

%let start=0;
%let end=0;

%do i=1 %to &totalnumdsns;
	%let start=%eval((&i-1)*&varperdsn + 1);
	%let end=%eval(&start + &varperdsn - 1);
	%if &end ge &numofvars %then %let end=&numofvars;

	%put start=&start end=&end;

     data &dsn.&i; /*Note: There should be a blank after &dsn.&totalnumdsns*/ 
     retain &keyvars;
            set &dsn (keep=&keyvars 
                      %do m=&start %to &end; 
                         &&varname&m.  
                      %end;);
            run;
%end;

%mend splitdsnverticallykey;

options nosource;
%splitdsnverticallykey(flags,4,keyvars=title); 
