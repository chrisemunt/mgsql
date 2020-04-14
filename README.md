# mgsi

M/Gateway Service Integration Gateway (**SIG**) for InterSystems **Cache/IRIS** and **YottaDB**.

Chris Munt <cmunt@mgateway.com>  
13 March 2020, M/Gateway Developments Ltd [http://www.mgateway.com](http://www.mgateway.com)

* Current Release: Version: 3.1; Revision 102.
* [Release Notes](#RelNotes) can be found at the end of this document.

## Overview

The M/Gateway Service Integration Gateway (**SIG**) is an Open Source network-based service developed for InterSystems **Cache/IRIS** and the **YottaDB** Database Servers.  It will also work with the **GT.M** database and other **M-like** Databases Servers.  Its core function is to manage connectivity, process and resource pooling for **M-like** DB Servers.  The pooled resources can be used by any of the client-facing technologies in this product series (for example **mg\_php** and **mg\_go** etc ...).


## Pre-requisites

InterSystems **Cache/IRIS** or **YottaDB** (or similar M DB Server):

       https://www.intersystems.com/
       https://yottadb.com/

## Installing the SIG

There are three parts to the **SIG** installation and configuration.

* The **SIG** executable (a UNIX Daemon or Windows Service) (**mgsi** or **mgsi.exe**).
* The database (or server) side code: **zmgsi**
* A network configuration to bind the former two elements together.

### Building the SIG executable

The **SIG** (**mgsi** or **mgsi.exe**) is written in standard C.  The GNU C compiler (gcc) can be used for Linux systems:

Ubuntu:

       apt-get install gcc

Red Hat and CentOS:

       yum install gcc

Apple OS X can use the freely available **Xcode** development environment.

Windows can use the free "Microsoft Visual Studio Community" edition of Visual Studio for building the **SIG**:

* Microsoft Visual Studio Community: [https://www.visualstudio.com/vs/community/](https://www.visualstudio.com/vs/community/)

There are built Windows x64 binaries available from:

* [https://github.com/chrisemunt/mgsi/blob/master/bin/winx64](https://github.com/chrisemunt/mgsi/blob/master/bin/winx64)

Having created a suitable development environment, **Makefiles** are provided to build the **SIG** for UNIX and Windows.

#### UNIX

Invoke the build procedure from the /src directory (i.e. the directory containing the **Makefile** file).

       make

#### Windows

Invoke the build procedure from the /src directory (i.e. the directory containing the **Makefile.win** file).

       nmake /f Makefile.win

### InterSystems Cache/IRIS

Log in to the Manager UCI and install the **zmgsi** routines held in either **/m/zmgsi\_cache.xml** or **/m/zmgsi\_iris.xml** as appropriate.

       do $system.OBJ.Load("/m/zmgsi_cache.xml","ck")

Change to your development UCI and check the installation:

       do ^%zmgsi

       M/Gateway Developments Ltd - Service Integration Gateway
       Version: 3.2; Revision 6 (3 February 2020)

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

Link all the **zmgsi** routines and check the installation:

       do ylink^%zmgsi

       do ^%zmgsi

       M/Gateway Developments Ltd - Service Integration Gateway
       Version: 3.2; Revision 6 (3 February 2020)


Note that the version of **zmgsi** is successfully displayed.


## Setting up the network service

The default TCP server port for **zmgsi** is **7041**.  If you wish to use an alternative port then modify the following instructions accordingly.

### InterSystems Cache/IRIS

Start the Cache/IRIS-hosted concurrent TCP service in the Manager UCI:

       do start^%zmgsi(0) 

To use a server TCP port other than 7041, specify it in the start-up command (as opposed to using zero to indicate the default port of 7041).

### YottaDB

Network connectivity to **YottaDB** is managed via the **xinetd** service.  First create the following launch script (called **zmgsi\_ydb** here):

       /usr/local/lib/yottadb/r122/zmgsi_ydb

Content:

       #!/bin/bash
       cd /usr/local/lib/yottadb/r122
       export ydb_dir=/root/.yottadb
       export ydb_dist=/usr/local/lib/yottadb/r122
       export ydb_routines="/root/.yottadb/r1.22_x86_64/o*(/root/.yottadb/r1.22_x86_64/r /root/.yottadb/r) /usr/local/lib/yottadb/r122/libyottadbutil.so"
       export ydb_gbldir="/root/.yottadb/r1.22_x86_64/g/yottadb.gld"
       $ydb_dist/ydb -r xinetd^%zmgsi

Create the **xinetd** script (called **zmgsi\_xinetd** here): 

       /etc/xinetd.d/zmgsi_xinetd

Content:

       service zmgsi_xinetd
       {
            disable         = no
            type            = UNLISTED
            port            = 7041
            socket_type     = stream
            wait            = no
            user            = root
            server          = /usr/local/lib/yottadb/r122/zmgsi_ydb
       }

* Note: sample copies of **zmgsi\_xinetd** and **zmgsi\_ydb** are included in the **/unix** directory.

Edit the services file:

       /etc/services

Add the following line to this file:

       zmgsi_xinetd          7041/tcp                        # zmgsi

Finally restart the **xinetd** service:

       /etc/init.d/xinetd restart

## Starting the SIG

The **SIG** executable can be installed in a directory of your choice.  When started, it will create a configuration file called **mgsi.ini**.  The event log file will be called **mgsi.log**.

### UNIX

Starting the **SIG**:

       ./mgsi

Stopping the **SIG**:

       ./mgsi -stop

### Windows

Starting the **SIG**:

       mgsi -start

Stopping the **SIG**:

       mgsi -stop

When the **SIG** is started for the first time it will register itself as a Windows Service.  Thereafter it can be managed from the Windows Services Control Panel if desired.

## Using the SIG

When the **SIG** is up and running its services are immediately available to participating clients.  The **SIG** provides a web-based user interface for the purpose of maintaining the configuration and service management.  By default the **SIG** listens on TCP port 7040.  The web-based management suite may be accessed as follows.

       http://[server]:7040/mgsi/mgsisys.mgw

## Resources used by zmgsi

The **zmgsi** server-side code will write to the following global:

* **^zmgsi**: The event Log. 

## License

Copyright (c) 2018-2020 M/Gateway Developments Ltd,
Surrey UK.                                                      
All rights reserved.
 
http://www.mgateway.com                                                  
Email: cmunt@mgateway.com
 
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.      

## <a name="RelNotes"></a>Release Notes

### v3.1.102 (13 March 2020)

* Initial Release
