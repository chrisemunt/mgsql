/*
   ----------------------------------------------------------------------------
   | MGODBC: ODBC Driver for MGSQL                                            |
   | Author: Chris Munt cmunt@mgateway.com                                    |
   |                    chris.e.munt@gmail.com                                |
   | Copyright (c) 2016-2023 MGateway Ltd                                     |
   | Surrey UK.                                                               |
   | All rights reserved.                                                     |
   |                                                                          |
   | http://www.mgateway.com                                                  |
   |                                                                          |
   | Licensed under the Apache License, Version 2.0 (the "License"); you may  |
   | not use this file except in compliance with the License.                 |
   | You may obtain a copy of the License at                                  |
   |                                                                          |
   | http://www.apache.org/licenses/LICENSE-2.0                               |
   |                                                                          |
   | Unless required by applicable law or agreed to in writing, software      |
   | distributed under the License is distributed on an "AS IS" BASIS,        |
   | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. |
   | See the License for the specific language governing permissions and      |
   | limitations under the License.                                           |
   ----------------------------------------------------------------------------
*/

#include "mgodbc.h"
#include  <odbcinst.h>


/* SQL Connect */

SQLRETURN SQL_API SQLConnect(
   SQLHDBC        ConnectionHandle,
   SQLCHAR *      ServerName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      UserName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      Authentication,
   SQLSMALLINT    NameLength3)
{
   int port, n;
   DWORD size;
   unsigned char server_name[64], user_name[64], authentication[256], driver[256], server[64], uci[64], buffer[256], comp[256];
   RECHEAD rhead;
   DBLK *p_block;
   DBC * dbc = (DBC *) ConnectionHandle;

   mg_cbuffer(server_name, 256, ServerName, NameLength1);
   mg_cbuffer(user_name, 64, UserName, NameLength2);
   mg_cbuffer(authentication, 256, Authentication, NameLength3);

   SQLGetPrivateProfileString((char *) server_name, "Driver", "", (char *) driver, 255, ODBC_INI);
   SQLGetPrivateProfileString((char *) server_name, "Server", "", (char *) server, 255, ODBC_INI);
   SQLGetPrivateProfileString((char *) server_name, "Port", "", (char *) buffer, 255, ODBC_INI);
   SQLGetPrivateProfileString((char *) server_name, "NameSpace", "", (char *) uci, 255, ODBC_INI);
   SQLGetPrivateProfileString((char *) server_name, "EventLogFile", "", CoreData.log_file, 255, ODBC_INI);
   SQLGetPrivateProfileString((char *) server_name, "EventLogLevel", "", CoreData.log_level, 30, ODBC_INI);
   mg_log_level(CoreData.log_file, sizeof(CoreData.log_file), CoreData.log_level);

   port = (int) strtol((char *) buffer, NULL, 10);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "ServerName=%s; UserName=%s; Authentication=%s; Driver=%s; Server=%s; Port=%d; UCI=%s;", server_name, user_name, authentication, driver, server, port, uci);
      mg_log_event(buffer, "SQLConnect", 0, (void *) dbc, MG_DBT_DBC);
   }

   strcpy(dbc->driver, (char *) driver);
   strcpy(dbc->uci, (char *) uci);
   strcpy(dbc->server, (char *) server);
   dbc->port = port;

   dbc->flag = 0;
   strcpy(dbc->dsn, (char *) server_name);
   strcpy(dbc->user, (char *) user_name);
   strcpy(dbc->mgsql.server_version, MG_VERSION);
   strcpy(dbc->mgsql.charset, "ISO 8859-1");
   strcpy(dbc->mgsql.host_info, MG_DB_NAME);

   strcpy(dbc->error.text, "");

   size = 255;
   GetComputerName((LPTSTR) buffer, (LPDWORD) &size);
   strncpy((char *) comp, (char *) buffer, 60);
   comp[60] = '\0';
   size = 255;
   GetUserName((LPTSTR) buffer, (LPDWORD) &size);
   strncpy((char *) user_name, (char *) buffer, 60);
   user_name[60] = '\0';

   if (!strlen(dbc->user)) {
      strcpy(dbc->user, (char *) user_name);
   }

   n = mg_connect(dbc);
   if (n != 1) {
      mg_set_error(&dbc->error, "08001", 0, "Client unable to establish connection", "SQLConnect");
      return SQL_ERROR;
   }

   strcpy((char *) buffer, "xDBC\n");
   n = mg_send(dbc, (char *) buffer, 5);
   if (n < 1) {
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLConnect");
      return SQL_ERROR;
   }
   n = mg_get_block(dbc, &p_block, 0);
   if (n < 1) {
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLConnect");
      return SQL_ERROR;
   }
   if (p_block && p_block->type == 'e') {
      mg_set_error(&dbc->error, "HY000", 0, p_block->pdata, "SQLConnect");
      return SQL_ERROR;
   }

   sprintf((char *) buffer + MG_HEAD_SIZE, "UCI=%s\r\nUser=%s\r\nComputer=%s\r\n\r\n", dbc->uci, user_name, comp);
   rhead.cmnd = 'i';
   rhead.stmt_no = 0;
   rhead.size = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   strcpy(rhead.desc, "");
   mg_set_record_head(&rhead, (char *) buffer);
   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);
   if (n < 1) {
      mg_mutex_lock(dbc->mlock);
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLConnect");
      return SQL_ERROR;
   }
   n = mg_get_block(dbc, &p_block, 0);
   if (n < 1) {
      mg_mutex_lock(dbc->mlock);
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLConnect");
      return SQL_ERROR;
   }
   if (p_block && p_block->type == 'e') {
      mg_mutex_lock(dbc->mlock);
      mg_set_error(&dbc->error, "HY000", 0, p_block->pdata, "SQLConnect");
      return SQL_ERROR;
   }
   mg_mutex_release(dbc->mlock);

   mg_get_nvp("$zv", (char *) buffer, 256, p_block->pdata);

   mg_parse_zv((char *) buffer, &(dbc->mgsql.zv));

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "SQLConnect: sys_type=%d; majorversion=%d; minorversion=%d; build=%d;", dbc->mgsql.zv.sys_type, dbc->mgsql.zv.majorversion, dbc->mgsql.zv.minorversion, dbc->mgsql.zv.sys_build);
      mg_log_event(dbc->mgsql.zv.zv, buffer, 0, (void *) dbc, MG_DBT_DBC);
   }

   return SQL_SUCCESS;
}


/*
   This function as its "normal" behavior is supposed to bring up a
   dialog box if it isn't given enough information via "szConnStrIn".  If
   it is given enough information, it's supposed to use "szConnStrIn" to
   establish a database connection.  In either case, it returns a
   string to the user that is the string that was eventually used to
   establish the connection.
*/

SQLRETURN SQL_API SQLDriverConnect(
   SQLHDBC        ConnectionHandle,
   SQLHWND        WindowHandle,
   SQLCHAR *      InConnectionString,
   SQLSMALLINT    StringLength1,
   SQLCHAR *      OutConnectionString,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  StringLength2Ptr,
   SQLUSMALLINT   DriverCompletion)
{
   short phase;
   BOOL fPrompt = FALSE;
   int port, n, len;
   DWORD size;
   unsigned char in_connection_string[256];
   char driver[256], server[64], server_name[256], uci[64], user_name[256], pwd[256], comp[256], buffer[1024], name[256], authentication[256];
   char *p, *p1, *p2;
   RECHEAD rhead;
   DBLK *p_block;
   DBC * dbc = (DBC *) ConnectionHandle;

   phase = 0;

#ifdef _WIN32
__try {
#endif
/*
   {
      char buffer[4096];
      sprintf(buffer, "InConnectionString=%s; StringLength1=%d; OutConnectionString=%p; BufferLength=%d", (char *) InConnectionString, (int) StringLength1, OutConnectionString, (int) BufferLength);
      mg_log_event(buffer, "SQLDriverConnect", 0, (void *) dbc, MG_DBT_DBC);
   }
*/
   mg_cbuffer(in_connection_string, 256, InConnectionString, StringLength1);

   if (OutConnectionString && BufferLength > 0) {
      *OutConnectionString = '\0';
   }

   *server_name = '\0';
   *user_name = '\0';
   *pwd = '\0';
   *authentication = '\0';

   phase = 1;

   strcpy(buffer, (char *) in_connection_string);
   p = buffer;
   for (;;) {
      p2 = strstr(p, ";");
      if (p2)
         *p2 = '\0';
      p1 = strstr(p, "=");
      if (p1) {
         *p1 = '\0';
         strcpy(name, p);
         mg_lcase(name);
         if (!strcmp(name, "dsn")) {
            strcpy(server_name, (p1 + 1));
         }
         else if (!strcmp(name, "uid")) {
            strcpy(user_name, (p1 + 1));
         }
         else if (!strcmp(name, "pwd")) {
            strcpy(pwd, (p1 + 1));
         }
      }
      if (!p2)
         break;
      p = (p2 + 1);
   }

   phase = 2;

   len = 0;

   SQLGetPrivateProfileString(server_name, "Driver", "", driver, 255, ODBC_INI);
   SQLGetPrivateProfileString(server_name, "Server", "", server, 255, ODBC_INI);
   SQLGetPrivateProfileString(server_name, "Port", "", buffer, 255, ODBC_INI);
   SQLGetPrivateProfileString(server_name, "NameSpace", "", uci, 255, ODBC_INI);
   SQLGetPrivateProfileString(server_name, "EventLogFile", "", CoreData.log_file, 255, ODBC_INI);
   SQLGetPrivateProfileString(server_name, "EventLogLevel", "", CoreData.log_level, 30, ODBC_INI);
   mg_log_level(CoreData.log_file, sizeof(CoreData.log_file), CoreData.log_level);

   phase = 3;

   port = (int) strtol(buffer, NULL, 10);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "ConnectionString=%s; ServerName=%s; UserName=%s; Authentication=%s; Driver=%s; Server=%s; Port=%d; UCI=%s; BufferLength=%d;", in_connection_string, server_name, user_name, authentication, driver, server, port, uci, BufferLength);
      mg_log_event(buffer, "SQLDriverConnect", 0, (void *) dbc, MG_DBT_DBC);
   }

   strcpy(dbc->driver, driver);
   strcpy(dbc->uci, uci);
   strcpy(dbc->server, server);
   dbc->port = port;

   dbc->flag = 0;
   strcpy(dbc->dsn, server_name);
   strcpy(dbc->user, user_name);
   strcpy(dbc->mgsql.server_version, "07.00.0000");
   strcpy(dbc->mgsql.charset, "ISO 8859-1");
   strcpy(dbc->mgsql.host_info, "Cache");

   strcpy(dbc->error.text, "");

   size = 255;
   GetComputerName((LPTSTR) buffer, (LPDWORD) &size);
   strncpy(comp, buffer, 60);
   comp[60] = '\0';
   size = 255;
   GetUserName((LPTSTR) buffer, (LPDWORD) &size);
   strncpy(user_name, buffer, 60);
   user_name[60] = '\0';

   phase = 4;

   if (!strlen(dbc->user)) {
      strcpy(dbc->user, (char *) user_name);
   }

   n = mg_connect(dbc);
   if (n != 1) {
      mg_set_error(&dbc->error, "08001", 0, "Client unable to establish connection", "SQLDriverConnect");
      return SQL_ERROR;
   }

   phase = 5;

   strcpy(buffer, "xDBC\n");
   n = mg_send(dbc, buffer, 5);
   if (n < 1) {
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLDriverConnect");
      return SQL_ERROR;
   }
   n = mg_get_block(dbc, &p_block, 0);
   if (n < 1) {
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLDriverConnect");
      return SQL_ERROR;
   }
   if (p_block && p_block->type == 'e') {
      mg_set_error(&dbc->error, "HY000", 0, p_block->pdata, "SQLDriverConnect");
      return SQL_ERROR;
   }

   sprintf(buffer + MG_HEAD_SIZE, "UCI=%s\r\nUser=%s\r\nComputer=%s\r\n\r\n", dbc->uci, user_name, comp);
   rhead.cmnd = 'i';
   rhead.stmt_no = 0;
   rhead.size = (int) strlen(buffer + MG_HEAD_SIZE);
   strcpy(rhead.desc, "");
   mg_set_record_head(&rhead, buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, buffer, MG_HEAD_SIZE + rhead.size);
   if (n < 1) {
      mg_mutex_lock(dbc->mlock);
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLDriverConnect");
      return SQL_ERROR;
   }
   n = mg_get_block(dbc, &p_block, 0);
   if (n < 1) {
      mg_mutex_lock(dbc->mlock);
      mg_set_error(&dbc->error, "08S01", 0, "Communication link failure", "SQLDriverConnect");
      return SQL_ERROR;
   }
   if (p_block && p_block->type == 'e') {
      mg_mutex_lock(dbc->mlock);
      mg_set_error(&dbc->error, "HY000", 0, p_block->pdata, "SQLDriverConnect");
      return SQL_ERROR;
   }
   mg_mutex_release(dbc->mlock);

   if (BufferLength > 0) {
      strncpy((char *) OutConnectionString, (char *) in_connection_string, BufferLength - 2);
      OutConnectionString[BufferLength - 1] = '\0';
   }

   phase = 7;

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];
   
   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in: SQLDriverConnect() code: %x:%d;", code, phase);
      mg_log_event( buffer, "SQLDriverConnect", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }
   
   return SQL_ERROR;
}
#endif

}


SQLRETURN SQL_API SQLBrowseConnect(
   SQLHDBC        ConnectionHandle,
   SQLCHAR *      InConnectionString,
   SQLSMALLINT    StringLength1,
   SQLCHAR *      OutConnectionString,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  StringLength2Ptr)

{
   DBC * dbc = (DBC *) ConnectionHandle;

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLBrowseConnect", 0, (void *) dbc, MG_DBT_DBC);
   }

   return SQL_SUCCESS;
}


SQLRETURN SQL_API SQLDisconnect(SQLHDBC ConnectionHandle)
{
   int n;
   DBC * dbc = (DBC *) ConnectionHandle;

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLDisconnect", 0, (void *) dbc, MG_DBT_DBC);
   }

   n = mg_disconnect(dbc);

   return SQL_SUCCESS;
}
