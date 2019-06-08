# mgsql

An SQL engine for **YottaDB** and other **M-like** databases.

Chris Munt <cmunt@mgateway.com>  
7 June 2019, M/Gateway Developments Ltd [http://www.mgateway.com](http://www.mgateway.com)

* Current Release: Version: 1.0; Revision 6 (7 June 2019)

## Overview

**mgsql** is an Open Source SQL engine developed primarily for the **YottaDB** database.  It will also work with the **GT.M** database and other **M-like** databases.

SQL access is provided via the following routes:

* Embedded SQL statements in M code.
* REST.
* ODBC.

Note that the **mgsql** project is very much 'work in progress'.  Use cautiously! 

## Pre-requisites

The **YottaDB** database (or similar M database):

       https://yottadb.com/

## Installing mgsql

### YottaDB

The instructions given here assume a standard 'out of the box' installation of **YottaDB** deployed in the following location:

       /usr/local/lib/yottadb/r122

The primary default location for routines:

       /root/.yottadb/r1.22_x86_64/r

Copy all the routines (i.e. all files with an 'm' extension) held in the GitHub **/yottadb** directory to:

       /root/.yottadb/r1.22_x86_64/r

Change directory to the following location and start a **YottaDB** command shell:

       cd /usr/local/lib/yottadb/r122
       ./ydb

Link all the **mgsql** routines and check the installation:

       do ylink^%mgsql

       do ^%mgsql

       MGSQL by M/Gateway Developments Ltd.
       Version: 1.0; Revision 6 (7 June 2019) %mgsql


Note that the version of **mgsql** is successfully displayed.

### Other M systems

Log in to the Manager UCI and, using the %RI utility (or similar) load the **mgsql** routines held in **/m/mgsql.ro**.  Change to your development UCI and check the installation:

       do ^%mgsql

       MGSQL by M/Gateway Developments Ltd.
       Version: 1.0; Revision 6 (7 June 2019) %mgsql

## Executing SQL statements from the YottaDB/M command line

Before executing SQL statements do familiarise yourself with the M system resources (i.e. globals) used by **mgsql**.  Refer to the *Resources used by mgsql* section.

The general form for executing SQL statements from within M code (or from the M command line) is as follows:

       set status=$$exec^%mgsql(<schema>,<sql statement>,.%zi,.%zo)

Where:

* %zi is an M array representing data that needs to be input to the script.
* %zo is an M array representing parameters controlling output from the script.

The top level routine **%mgsql** (physical file _mgsql.m) contains a number of sample SQL scripts.  These work to a simple database representing hospital patients and their associated admissions.  View the embedded scripts in this routine.

Create the test schema:

       do create^%mgsql

Insert a few test records:

       do insert^%mgsql

Run the various SQL retrieval scripts:

       do sel1^%mgsql

A number of SQL scripts are available at line labels sel1 to sel8.

## Setting up the network service

So far we have covered the basics of executing SQL statements from M code.  In order to execute SQL queries over REST or ODBC the **mgsql** installation must be accessible over the network.  The service described here will concurrently support access to **mgsql** via REST and ODBC.  The default TCP server port for **mgsql** is **7041**.  If you wish to use an alternative port then modify the following instructions accordingly.

### YottaDB

Network connectivity to **YottaDB** is managed via the **xinetd** service.  First create the following launch script (called **mgsql_ydb** here):

       /usr/local/lib/yottadb/r122/mgsql_ydb

Content:

       #!/bin/bash
       cd /usr/local/lib/yottadb/r122
       export ydb_dir=/root/.yottadb
       export ydb_dist=/usr/local/lib/yottadb/r122
       export ydb_routines="/root/.yottadb/r1.22_x86_64/o*(/root/.yottadb/r1.22_x86_64/r /root/.yottadb/r) /usr/local/lib/yottadb/r122/libyottadbutil.so"
       export ydb_gbldir="/root/.yottadb/r1.22_x86_64/g/yottadb.gld"
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
            server          = /usr/local/lib/yottadb/r122/mgsql_ydb
       }

* Note: sample copies of **mgsql_xinetd** and **mgsql_ydb** are included in the **/unix** directory.

Edit the services file:

       /etc/services

Add the following line to this file:

       mgsql_xinetd          7041/tcp                        # MGSQL

Finally restart the **xinetd** service:

       /etc/init.d/xinetd restart

### Other M systems

Start the M-hosted concurrent TCP service in the Manager UCI:

       do start^%mgsql(0) 

To use a server TCP port other than 7041, specify it in the start-up command (as opposed to using zero to indicate the default port of 7041).

## Access to mgsql using REST

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

## Access to mgsql using ODBC

*Check back soon! ...*

## Resources used by mgsql

**mgsql** will write to the following globals

* **^mgsqld**: The catalogue or schema. 
* **^mgsqls**: The spool file for SQL output.
* **^mgsqlx**: The cache of compiled queries.
* **^mglog**: The event Log.
* **^mgtmp**: A temporary file used by the SQL compiler.
* **^mgtemp**: A temporary sort file used when executing SQL queries.

## License

Copyright (c) 2018-2019 M/Gateway Developments Ltd,
Surrey UK.                                                      
All rights reserved.
 
http://www.mgateway.com                                                  
Email: cmunt@mgateway.com
 
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.      

