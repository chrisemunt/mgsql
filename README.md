# mgsql

An SQL engine for **YottaDB** and other **M-like** databases.

Chris Munt <cmunt@mgateway.com>  
8 June 2023, MGateway Ltd [http://www.mgateway.com](http://www.mgateway.com)

* Current Release: Version: 1.4; Revision 23
* [Release Notes](#RelNotes) can be found at the end of this document.

Contents

* [Overview](#Overview") 
* [Pre-requisites](#PreReq") 
* [Installing mg-dbx](#Install)
* [Embedding SQL statements in M code](#ExecuteM)
* [Starting the mgsql network Superserver](#Network)
* [Access to mgsql using REST](#REST)
* [Access to mgsql using ODBC](#ODBC)
* [Transaction Processing](#TProcessing)
* [SQL Query Optimisation](#Optimisation)
* [Resources used by mgsql](#Resources)
* [License](#License)


## <a name="Overview"></a> Overview

**mgsql** is an Open Source SQL engine developed primarily for the **YottaDB** database.  It will also work with the **GT.M** database and other **M-like** databases.

SQL access is provided via the following routes:

* Embedded SQL statements in M code.
* REST.
* ODBC.


## <a name="PreReq"></a> Pre-requisites

The **YottaDB** database (or similar M database):

       https://yottadb.com/


## <a name="Install"></a> Installing mgsql

### YottaDB

The instructions given here assume a standard 'out of the box' installation of **YottaDB** deployed in the following location:

       /usr/local/lib/yottadb/r130

The primary default location for routines:

       /root/.yottadb/r1.30_x86_64/r

Copy all the routines (i.e. all files with an 'm' extension) held in the GitHub **/yottadb** directory to:

       /root/.yottadb/r1.30_x86_64/r

Change directory to the following location and start a **YottaDB** command shell:

       cd /usr/local/lib/yottadb/r130
       ./ydb

Link all the **mgsql** routines and check the installation:

       do ylink^%mgsql

       do ^%mgsql

       MGSQL by MGateway Ltd.
       Version: 1.4; Revision 23 (8 June 2023) %mgsql

Note that the version of **mgsql** is successfully displayed.

### InterSystems Cache/IRIS

Log in to the %SYS Namespace and install the **mgsql** routines held in **/isc/mgsql\_isc.ro**.

       do $system.OBJ.Load("/isc/mgsql_isc.ro","ck")

Change to your development Namespace and check the installation:

       do ^%mgsql

       MGSQL by MGateway Ltd.
       Version: 1.4; Revision 23 (8 June 2023) %mgsql

### Other M systems

All routines are held in **/m/mgsql.ro**, use an appropriate utility to install them in the Manager UCI then change to your development UCI and check the installation:

       do ^%mgsql

       MGSQL by MGateway Ltd.
       Version: 1.4; Revision 23 (8 June 2023) %mgsql


## <a name="ExecuteM"></a> Embedding SQL statements in M code

Before executing SQL statements do familiarise yourself with the M system resources (i.e. globals) used by **mgsql**.  Refer to the *Resources used by mgsql* section.

The general form for executing SQL statements from within M code (or from the M command line) is as follows:

       set status=$$exec^%mgsql(<schema>,<sql statement>,.%zi,.%zo)

Where:

* **%zi** is an M array representing data that needs to be input to the script.
* **%zo** is an M array representing parameters controlling output from the script.

In the simplest case, the query output will be written to the primary device (for example, a terminal window), line by line with columns returned as a comma-separated list.


### Examples

The top level routine **%mgsql** (physical file _mgsql.m) contains a number of sample SQL scripts.  These work to a simple database representing hospital patients and their associated admissions.  View the embedded scripts in this routine.

Create the test schema:

       do create^%mgsql

Insert a few test records:

       do insert^%mgsql

Run the various SQL retrieval scripts:

       do sel1^%mgsql

A number of SQL scripts are available at line labels sel1, sel2, sel3 ... to *sel[n]*.


### Supplying variable inputs to a query

You can supply variable inputs to the query via the inputs array - **%zi** in the examples.  The rationale for doing this, as opposed to embedding values directly in the scripts, is that it reduces the amount of compilation time needed.  Once the query is compiled the same generated code can be used for all sets of input variables.  

Example:

       new %zi,%zo
       set %zi("number")=100000
       set status=$$exec^%mgsql("","select * from patient where num = :number",.%zi,.%zo)


### Using the SQL output spool file

Rather than dumping query output to the current device, it is possible to mandate that output is directed to the spool file, which is a global called **mgsqls**.  To do this, specify a query statement ID in the input array.

Example:

       new %zi,%zo
       set %zi(0,"stmt")="all patients"
       set status=$$exec^%mgsql("","select * from patient",.%zi,.%zo)

The query will execute silently and write the output to the spool file, the structure of which is as follows:

       ^mgsqls($Job, <statement_ID>, 0, <row_no>, <column_no>)=<value> 

Where **$Job** is the current process ID.

 
### Using an SQL output callback

Finally, it is possible to mandate that query output is directed to a callback – an M function defined in the application.  To do this, specify the name of the callback function (including the routine name) in the input array.

The callback function must be defined as follows:

       callback(%zi, %zo, rn)

Where:

* **%zi** is the query input array.
* **%zo** is the query output array.
* **rn** is the current row number.

Example:

                   new %zi,%zo
                   set %zi(0,"callback")="allpatients^thisroutine"
                   set status=$$exec^%mgsql("","select * from patient",.%zi,.%zo)
                   quit
                   ;
       allpatients(%zi,%zo,rn) ; query callback
                   new stop
                   set stop=0
                   ; process the row of output here
                   Kill %zo(rn) ; we don’t want to keep the current row
                   quit stop

Where **rn** is the current row number and **stop** is a stop flag.  Set the stop flag to 1 in the callback function to force the early termination of the query.  The data for the row is held in the output array (**%zo**), the structure of which is as follows:

       %zo(<row_no>, <column_no>)=<value>
 

## <a name="Network"></a> Starting the mgsql network Superserver

So far we have covered the basics of executing SQL statements from M code.  In order to execute SQL queries over REST or ODBC the **mgsql** installation must be accessible over the network.  The Superserver service described here will concurrently support access to **mgsql** via REST and ODBC.  The default TCP server port for **mgsql** is **7041**.  If you wish to use an alternative port then modify the following instructions accordingly.

For most M systems, the **mgsql** Superserver can be started from the M command prompt.  For YottaDB there is the option of starting Superserver child processes via the **xinetd** service.

* Note that if you are using the generic MGateway Superserver (**%zmgsi**) then no action is required here as the generic Superserver is able to serve **mgsql**.


### Starting the mgsql Superserver

Start the M-hosted concurrent TCP service in the Manager UCI:

       do start^%mgsql(0) 

To use a server TCP port other than 7041, specify it in the start-up command (as opposed to using zero to indicate the default port of 7041).


### Starting YottaDB Superserver child processes via xinetd

Network connectivity to **YottaDB** is managed via the **xinetd** service.  First create the following launch script (called **mgsql_ydb** here):

       /usr/local/lib/yottadb/r130/mgsql_ydb

Content:

       #!/bin/bash
       cd /usr/local/lib/yottadb/r130
       export ydb_dir=/root/.yottadb
       export ydb_dist=/usr/local/lib/yottadb/r130
       export ydb_routines="/root/.yottadb/r1.30_x86_64/o*(/root/.yottadb/r1.30_x86_64/r /root/.yottadb/r) /usr/local/lib/yottadb/r130/libyottadbutil.so"
       export ydb_gbldir="/root/.yottadb/r1.30_x86_64/g/yottadb.gld"
       $ydb_dist/ydb -r xinetd^%mgsql

Create the **xinetd** script (called **mgsql_xinetd** here): 

       /etc/xinetd.d/mgsql_xinetd

Content:

       service mgsql_xinetd
       {
            disable         = no
            type            = UNLISTED
            port            = 7041
            socket_type     = stream
            wait            = no
            user            = root
            server          = /usr/local/lib/yottadb/r130/mgsql_ydb
       }

* Note: sample copies of **mgsql_xinetd** and **mgsql_ydb** are included in the **/unix** directory.

Edit the services file:

       /etc/services

Add the following line to this file:

       mgsql_xinetd          7041/tcp                        # MGSQL

Finally restart the **xinetd** service:

       /etc/init.d/xinetd restart


## <a name="REST"></a> Access to mgsql using REST

Now that the network service has been configured and deployed it is possible to execute SQL scripts via REST calls. Results are returned formatted as JSON.

For example, using the **curl** utility from the UNIX command line:

       curl -d "select * from patient" -H "Content-Type: text/sql" http://localhost:7041/mg.sql/execute

Assuming that the simple test database described previously has been created the above request will generate the following output: 

       {"sqlcode": 0, "sqlstate": "00000", "error": "", "result": [{"num": "1","name": "Chris Munt","address": "Banstead"},{"num": "2","name": "Rob Tweed","address": "Redhill"},{"num": "3","name": "John Smith","address": "London"},{"num": "4","name": "Jane Doe","address": "Oxford"}]}

Simple invocation from a browser (Hint: Firefox does a good job of rendering JSON):

       http://127.0.0.1:7041/mgsql/mg.sql?sql=select * from patient

Alternatively, enter an SQL statement in the form generated by:

       http://127.0.0.1:7041/mgsql/mg.sql

In a live environment a production-grade web server should be used.  For example, using the Apache server the **mod_proxy** module can be used to *front* the **mgsql** service.


## <a name="ODBC"></a> Access to mgsql using ODBC


The ODBC driver is in the **/odbc** directory.  Pre-built drivers for 32 and 64-bit Windows are in the **/odbc/x86** and **/odbc/x64** directories respectively.  To install both drivers copy the contents of **/odbc/x86** to:

       C:\Program Files (x86)\mgsql\

And copy the contents of **/odbc/x64** to:

       C:\Program Files\mgsql\

You will have to create the **/mgsql** sub-directory if it doesn't already exist.  To register both drivers, using Windows Explorer, double click on each of the following Registry files:

       C:\Program Files (x86)\mgsql\mgodbc32.reg
       C:\Program Files\mgsql\mgodbc64.reg

You can now configure an ODBC Data Source using the Windows Administrative tools for ODBC Data sources (accessed via the Windows Control Panel:

       Control Panel\System and Security\Administrative Tools\ODBC Data Sources

Under the **System DSN** tab. select **Add...** and choose one of the **mgsql** drivers as appropriate:

       MGSQL ODBC x86
       MGSQL ODBC x64

Complete the **mgodbc** configuration dialogue box and save:

* **Name:** Your Data Source Name (DSN).
* **Description:** An optional description.
* **Server:** IP Address of your M server.
* **TCP Port:** TCP Port (the default is 7041).
* **Directory or UCI:** M UCI (leave blank for YottaDB).
* **Event Log File:** Log file (including full path).
* **Event Log Level:** Log level (a comma separated list of log directives).

Log Level Directives:

* **e:** Log Errors.
* **ft:** Log ODBC function call trace.
* **nt:** Log all network buffers sent and received.

The data source created can now be used in Windows applications.


## <a name="TProcessing"></a> Transaction Processing

**mgsql** supports the standard SQL Transaction Processing commands:

       START TRANSACTION
       COMMIT
       ROLLBACK

The implementation of these commands is based on the underlying M commands: **tstart**, **tcommit** and **trollback**.  SQL Transactions can be implemented in M code or via an external program connecting to **mgsql** via the ODBC driver.

The M Transaction Processing commands can be used directly in M code.  For example:

       new %zi,%zo
       tstart
       set status=$$exec^%mgsql("",<sql update statement>,.%zi,.%zo)
       ; further update statements …
       tcommit

Alternatively, the corresponding SQL Transaction Processing commands can be used in SQL statements.  For example:

       new %zi,%zo
       set status=$$exec^%mgsql("","transaction start",.%zi,.%zo)
       set status=$$exec^%mgsql("",<sql update statement>,.%zi,.%zo)
       ; further update statements …
       set status=$$exec^%mgsql("","commit",.%zi,.%zo)

It is also possible to implement transactions in M callback functions.  This method is mandatory for YottaDB.

The transaction callback function must be defined as follows:

       callback(%zi, %zo)

Where:

* **%zi** is the query input array.
* **%zo** is the query output array.
 

For example:

       tp   ; transaction implemented in a callback function
            new %zi,%zo
            set %zi(0,"callback")="tpcb"
            set status=$$exec^%mgsql("","transaction start",.%zi,.%zo)
            quit
            ;
       tpcb(%zi,%zo) ; callback function
            set status=$$exec^%mgsql("",<sql update statement>,.%zi,.%zo)
            ; further update statements …
            set status=$$exec^%mgsql("","commit",.%zi,.%zo)
            quit status


## <a name="Optimisation"></a> SQL Query Optimisation

**mgsql** will attempt to find the most optimal route through the set of tables queried in accordance with the information that the optimiser can extract from the **WHERE** predicate together with any **JOIN** constraints specified.

In cases where **mgsql** does not come up with an optimal route through the tables it is possible to provide hints in the form of explicitly defining the indices to use.  If an index is defined in the **FROM** statement, **mgsql** will attempt to process the tables in the order specified in the **FROM** statement.

The general form for explicitly optimising queries is as follows:

       select [columns] from table1:index1, table2 where [predicate]

Or if aliases are used:

       select [columns] from table1 a:index1, table2 b where [predicate]

In the above example, **mgsql** will attempt to parse **table1** first using **index1**, followed by **table2**.

As a convenience, the primary key may be defined as index ‘0’:

       select [columns] from table1 a:0, table2 b:idx2 where [predicate]

In the above example, **mgsql** will attempt to parse **table1** first using the **primary key**, followed by **table2** using index **idx2**.


## <a name="Resources"></a> Resources used by mgsql

**mgsql** will write to the following globals

* **^mgsqld**: The catalogue or schema. 
* **^mgsqls**: The spool file for SQL output.
* **^mgsqlx**: The cache of compiled queries.
* **^mglog**: The event Log.
* **^mgtmp**: A temporary file used by the SQL compiler.
* **^mgtemp**: A temporary sort file used when executing SQL queries.

* **mgsql** will generate M Routines prefixed by 'x'.


## <a name="License"></a> License

Copyright (c) 2018-2023 MGateway Ltd,
Surrey UK.                                                      
All rights reserved.
 
http://www.mgateway.com                                                  
Email: cmunt@mgateway.com
 
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.      

## <a name="RelNotes"></a>Release Notes

### v1.0.7 (13 June 2019)

* Initial Release

### v1.0.8 (1 November 2019)

* Greater flexibility in mapping **mgsql** tables to existing M global structures.  The facility for specifying trailing M global subscripts is extended (see the 'separate' keyword in table creation).
* A fault in the processing of outer join queries qualified with an 'on' clause has been corrected.

### v1.1.9 (15 January 2020)

* Introduce support for alternative date separators in the decode date function (**ddate^%mgsqls**).  For example, although the separator is '/' in the US locale, it is is "." in the Czech locale.
* Introduce support for _Derived Fields_.  A _Derived Field_ is defined in the schema as an M extrinsic function and can take any number of values from the same row as input parameters.  For example, the calculation of a person's age from the stored 'date of birth' field can be implemented as a _Derived Field_ - the value of 'age' being dependant on the time of data retrieval.
* The embedded functions **lower** and **upper** have been implemented (Convert string to lower or upper-case, respectively.
* A fault that led to some SQL queries of the form '_update ... set ... where_' crashing has been corrected.
* A fault that led to some secondary index names not being recognised has been corrected.
* A fault that led to an error status (-1) being returned for some SQL DDL scripts even though the script completed successfully has been corrected.

### v1.2.10 (14 April 2020)

* Introduce support for the SQL TOP clause.
	* **select top columns..., from table...** (return just the first row of data).
	* **select top 3 columns..., from table...** (return just the first 3 rows of data).
* The embedded functions **trim**, **rtrim** and **ltrim** have been implemented.
	* **trim((string) input[, (string) characters])** (remove listed characters from the beginning and end of the supplied string).
	* **rtrim((string) input[, (string) characters])** (remove listed characters from the end of the supplied string).
	* **ltrim((string) input[, (string) characters])** (remove listed characters from the beginning of the supplied). string.
	* In all cases the default value for **characters** (if this argument is not supplied) is white space - ' '.
* Correct a fault in the compilation of the SQL LIKE operator.
* Finally, run the **upgrade** procedure.  This will clean-up any temporary files previously used by **mgsql** and force the recompilation of all queries.
	* **set status=$$upgrade^%mgsql(0)**

### v1.2.11 (28 May 2020)

* Improve the parsing of expressions embedded in SQL scripts - notably the SQL **WHERE** predicate.
* Remove the need to fully qualify column names with table names (or table name aliases) in SQL scripts except in cases where ambiguities would otherwise occur.

### v1.2.12 (3 January 2021)

* Correct a number of faults in the compilation of 'Select distinct ...' queries.

### v1.2.13 (5 January 2021)

* Correct a fault that led to duplicate values being erroneously returned for 'Select distinct ...' queries.
* For this update, run the **upgrade** procedure after installation.  This will clean-up any temporary files previously used by **mgsql** and force the recompilation of all queries.
	* **set status=$$upgrade^%mgsql(0)**

### v1.2.14 (8 January 2021)

* Introduce further options for embedding SQL queries in M code. Including:
	* The use of the spool file.
	* The use of callback functions.
* Update the documentation.
* Miscellaneous bug fixes.

### v1.2.15 (10 January 2021)

* Correct a regression in the processing of SQL queries containing **'in'** or **'or'** in the **WHERE** predicate.

### v1.2.16 (13 January 2021)

* Correct a fault in the compilation of **INSERT** queries for tables having secondary indices defined.

### v1.2.17 (14 January 2021)

* Correct a fault in the compilation of **SELECT DISTINCT ...** queries.

### v1.2.18 (22 January 2021)

* Correct a fault in the compilation of **SELECT COUNT(DISTINCT ...** queries.

### v1.3.19 (22 February 2021)

* Introduce SQL commands to support M Transaction Processing.
	* SQL Commands: **START TRANSACTION**, **COMMIT** and **ROLLBACK**
* Introduce a native concurrent TCP server for YottaDB.
	* The Superserver can be started from the M command prompt using **d start^%mgsql(<tcp port>)**.
	* Invocation of Superserver child processes from the **xinetd** daemon is still supported. 

### v1.3.20 (25 June 2021)

* Correct a fault that led to queries being recompiled on every call instead of reusing the code previously generated.
	* To force the recompilation of a particular query, set the **recompile** property - for example:
	* set %zi(0,"recompile")=1,status=$$exec^%mgsql("",[query],.%zi,.%zo)

### v1.3.21 (30 September 2021)

* Correct a fault that led to some queries containing an OUTER JOIN crashing with an 'undefined variable' error.  Particularly affected were OUTER JOINs qualified with an ON condition.

### v1.4.22 (3 February 2022)

* Correct a fault that led to **CREATE TABLE** statements crashing if a SQL reserved word was used as a column name.
* Correct a regression in the processing of the following operators in **WHERE** statements: OR, >, <.
* Improved query optimisation together with a means through which queries can be explicitly optimised by specifying hints in the query text.
	* See the section on **SQL Query Optimisation**.
	* Run the upgrade procedure to force the recompilation (and re-optimisation) of all queries: **set status=$$upgrade^%mgsql(0)**

### v1.4.23 (8 June 2023)

* Documentation update,