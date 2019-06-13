/*
   ----------------------------------------------------------------------------
   | MGODBC: ODBC Driver for MGSQL                                            |
   | Author: Chris Munt cmunt@mgateway.com                                    |
   |                    chris.e.munt@gmail.com                                |
   | Copyright (c) 2016-2019 M/Gateway Developments Ltd,                      |
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

#pragma warning(suppress : 4311)

/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLSetConnectOption(HDBC hdbc, UWORD fOption, UDWORD vParam)
{
#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLSetConnectOption", 0, NULL, 0);
   }
   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetConnectOption(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}
#endif


SQLRETURN SQL_API SQLSetConnectAttr(
   SQLHDBC        ConnectionHandle,
   SQLINTEGER     Attribute,
   SQLPOINTER     ValuePtr,
   SQLINTEGER     StringLength)
{
   char *pattr;
   SQLRETURN retcode;
   DBC *dbc = (DBC *) ConnectionHandle;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;
   retcode = SQL_SUCCESS;

   switch (Attribute) {
      case SQL_ATTR_ACCESS_MODE:
         pattr = "SQL_ATTR_ACCESS_MODE";
         break;
      case SQL_ATTR_AUTOCOMMIT:
         pattr = "SQL_ATTR_AUTOCOMMIT";
         break;
      case SQL_ATTR_LOGIN_TIMEOUT:
         pattr = "SQL_ATTR_LOGIN_TIMEOUT";
         //dbc->login_timeout = *((SQLUINTEGER *) ValuePtr);
         dbc->login_timeout = (int) ValuePtr;
         break;
      case SQL_ATTR_CONNECTION_TIMEOUT:
         pattr = "SQL_ATTR_CONNECTION_TIMEOUT";
         //dbc->req_timeout = *((SQLUINTEGER *) ValuePtr);
         dbc->req_timeout = (int) ValuePtr;
         break;
      case SQL_ATTR_CURRENT_CATALOG:
         pattr = "SQL_ATTR_CURRENT_CATALOG";
         strcpy(dbc->dbid, (char *) ValuePtr);
         break;
      case SQL_ATTR_ODBC_CURSORS:
         pattr = "SQL_ATTR_ODBC_CURSORS";
         break;
      case SQL_OPT_TRACE:
         pattr = "SQL_OPT_TRACE";
      case SQL_OPT_TRACEFILE:
         pattr = "SQL_OPT_TRACEFILE";
      case SQL_QUIET_MODE:
         pattr = "SQL_QUIET_MODE";
      case SQL_TRANSLATE_DLL:
         pattr = "SQL_TRANSLATE_DLL";
      case SQL_TRANSLATE_OPTION:
         pattr = "SQL_TRANSLATE_OPTION";
      case SQL_ATTR_PACKET_SIZE:
         pattr = "SQL_ATTR_PACKET_SIZE";
         break;
      case SQL_ATTR_TXN_ISOLATION:
         pattr = "SQL_ATTR_TXN_ISOLATION";
         break;
/*
      case SQL_ATTR_RESET_CONNECTION:
         pattr = "SQL_ATTR_RESET_CONNECTION";
*/
      case SQL_ATTR_ENLIST_IN_DTC:
         pattr = "SQL_ATTR_ENLIST_IN_DTC";
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Attribute: %d (%s); StringLength=%d; ValuePtr=%p; result=%d;", Attribute, pattr ? pattr : "null", StringLength, ValuePtr, (int) retcode);
      mg_log_event( buffer, "SQLSetConnectAttr", 0, (void *) dbc, MG_DBT_DBC);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetConnectAttr(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


SQLRETURN SQL_API SQLGetConnectAttr(
   SQLHDBC        ConnectionHandle,
   SQLINTEGER     Attribute,
   SQLPOINTER     ValuePtr,
   SQLINTEGER     BufferLength,
   SQLINTEGER *   StringLengthPtr)
{
   char *pattr;
   SQLRETURN retcode;
   DBC *dbc = (DBC *) ConnectionHandle;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;
   retcode = SQL_SUCCESS;

   switch (Attribute) {
      case SQL_ATTR_ACCESS_MODE:
         *((SQLUINTEGER *) ValuePtr) = SQL_MODE_READ_WRITE;
         pattr = "SQL_ATTR_ACCESS_MODE";
         break;
#if 0
      case SQL_ATTR_ASYNC_DBC_EVENT:
         pattr = "SQL_ATTR_ASYNC_DBC_EVENT";
         break;
      case SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE:
         pattr = "SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE";
         break;
      case SQL_ATTR_ASYNC_DBC_PCALLBACK:
         pattr = "SQL_ATTR_ASYNC_DBC_PCALLBACK";
         break;
      case SQL_ATTR_ASYNC_DBC_PCONTEXT:
         pattr = "SQL_ATTR_ASYNC_DBC_PCONTEXT";
         break;
#endif
      case SQL_ATTR_ASYNC_ENABLE:
         pattr = "SQL_ATTR_ASYNC_ENABLE";
         break;
      case SQL_ATTR_AUTO_IPD:
         pattr = "SQL_ATTR_AUTO_IPD";
         break;
      case SQL_ATTR_AUTOCOMMIT:
         pattr = "SQL_ATTR_AUTOCOMMIT";
         break;
      case SQL_ATTR_CONNECTION_DEAD:
         pattr = "SQL_ATTR_CONNECTION_DEAD";
         break;
      case SQL_ATTR_CONNECTION_TIMEOUT:
         pattr = "SQL_ATTR_CONNECTION_TIMEOUT";
         *((SQLUINTEGER *) ValuePtr) = dbc->req_timeout;
         break;
      case SQL_ATTR_CURRENT_CATALOG:
         pattr = "SQL_ATTR_CURRENT_CATALOG";
         strcpy((char *) ValuePtr, dbc->dbid);
         *StringLengthPtr = (SQLINTEGER) strlen(dbc->dbid);
         break;
#if 0
      case SQL_ATTR_DBC_INFO_TOKEN:
         pattr = "SQL_ATTR_DBC_INFO_TOKEN";
         break;
#endif
      case SQL_ATTR_ENLIST_IN_DTC:
         pattr = "SQL_ATTR_ENLIST_IN_DTC";
         break;
      case SQL_ATTR_LOGIN_TIMEOUT:
         *((SQLUINTEGER *) ValuePtr) = dbc->login_timeout;
         pattr = "SQL_ATTR_LOGIN_TIMEOUT";
         break;
      case SQL_ATTR_METADATA_ID:
         pattr = "SQL_ATTR_METADATA_ID";
         break;
      case SQL_ATTR_PACKET_SIZE:
         pattr = "SQL_ATTR_PACKET_SIZE";
         break;
      case SQL_ATTR_QUIET_MODE:
         pattr = "SQL_ATTR_QUIET_MODE";
         break;
      case SQL_ATTR_TRACE:
         pattr = "SQL_ATTR_TRACE";
         break;
      case SQL_ATTR_TRACEFILE:
         pattr = "SQL_ATTR_TRACEFILE";
         break;
      case SQL_ATTR_TRANSLATE_LIB:
         pattr = "SQL_ATTR_TRANSLATE_LIB";
         break;
      case SQL_ATTR_TRANSLATE_OPTION:
         pattr = "SQL_ATTR_TRANSLATE_OPTION";
         break;
      case SQL_ATTR_TXN_ISOLATION:
         pattr = "SQL_ATTR_TXN_ISOLATION";
         break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Attribute: %d (%s); BufferLength=%d; ValuePtr=%p; result=%d;", Attribute, pattr ? pattr : "null", BufferLength, ValuePtr, (int) retcode);
      mg_log_event( buffer, "SQLGetConnectAttr", 0, (void *) dbc, MG_DBT_DBC);
   }

   return retcode;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetConnectAttr(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLSetEnvAttr(
   SQLHENV        EnvironmentHandle,
   SQLINTEGER     Attribute,
   SQLPOINTER     ValuePtr,
   SQLINTEGER     StringLength)
{
   SQLRETURN result = SQL_SUCCESS;
   char *pattr;
   ENV * henv;
   static int ver;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;
   henv = (ENV *) EnvironmentHandle;

   if (henv->connections) {
      result = SQL_ERROR;
      //set_env_error(henv, MYERR_S1010, NULL, 0);
      goto SQLSetEnvAttrExit;
   }

   switch (Attribute) {
      case SQL_ATTR_ODBC_VERSION:
         pattr = "SQL_ATTR_ODBC_VERSION";
         ((ENV *) henv)->odbc_ver = (SQLINTEGER) (SQLLEN) ValuePtr;
         break;
      case SQL_ATTR_OUTPUT_NTS:
         pattr = "SQL_ATTR_OUTPUT_NTS";
         if (ValuePtr == (SQLPOINTER) SQL_TRUE)
            break;
      default:
         pattr = "<UNKNOWN>";
    }

SQLSetEnvAttrExit:

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Attribute: %d (%s); StringLength=%d; ValuePtr=%p", Attribute, pattr ? pattr : "null", StringLength, ValuePtr);
      mg_log_event( buffer, "SQLSetEnvAttr", 0, (void *) henv, MG_DBT_ENV);
   }

   return SQL_SUCCESS;


#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetEnvAttr(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLGetEnvAttr(
   SQLHENV        EnvironmentHandle,
   SQLINTEGER     Attribute,
   SQLPOINTER     ValuePtr,
   SQLINTEGER     BufferLength,
   SQLINTEGER *   StringLengthPtr)
{
   char *pattr;
   ENV * henv;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;
   henv = (ENV *) EnvironmentHandle;

   switch (Attribute) {
      case SQL_ATTR_CONNECTION_POOLING:
         pattr = "SQL_ATTR_CONNECTION_POOLING";
         *(SQLINTEGER *) ValuePtr = SQL_CP_OFF;
         break;
      case SQL_ATTR_ODBC_VERSION:
         pattr = "SQL_ATTR_ODBC_VERSION";
          *(SQLINTEGER *) ValuePtr = ((ENV *) henv)->odbc_ver;
          break;
      case SQL_ATTR_OUTPUT_NTS:
          *((SQLINTEGER *) ValuePtr) = SQL_TRUE;
          break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Attribute: %d (%s); BufferLength=%d; ValuePtr=%p", Attribute, pattr ? pattr : "null", BufferLength, ValuePtr);
      mg_log_event( buffer, "SQLGetEnvAttr", 0, (void *) henv, MG_DBT_ENV);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetEnvAttr(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}



SQLRETURN SQL_API SQLSetStmtAttr(
   SQLHSTMT     StatementHandle,
   SQLINTEGER   Attribute,
   SQLPOINTER   ValuePtr,
   SQLINTEGER   StringLength)
{
   char *pattr;
   STMT *stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;

   switch (Attribute) {
      case SQL_ATTR_CURSOR_SCROLLABLE:
         pattr = "SQL_ATTR_CURSOR_SCROLLABLE";
         *(SQLUINTEGER*) ValuePtr = SQL_NONSCROLLABLE;
         break;
      case SQL_ATTR_AUTO_IPD:
         pattr = "SQL_ATTR_AUTO_IPD";
         *(SQLUINTEGER *) ValuePtr = SQL_FALSE;
         break;
      case SQL_ATTR_PARAM_BIND_OFFSET_PTR:
         pattr = "SQL_ATTR_PARAM_BIND_OFFSET_PTR";
         stmt->apd->p_bind_offset = (SQLPOINTER) ValuePtr;
         stmt->ipd->p_bind_offset = (SQLPOINTER) ValuePtr;
         break;
      case SQL_ATTR_PARAM_BIND_TYPE:
         pattr = "SQL_ATTR_PARAM_BIND_TYPE";
         stmt->apd->bind_type = (SQLINTEGER) ValuePtr;
         stmt->ipd->bind_type = (SQLINTEGER) ValuePtr;
         break;
      case SQL_ATTR_PARAM_OPERATION_PTR:
         pattr = "SQL_ATTR_PARAM_OPERATION_PTR";
         stmt->apd->p_param_array_status = (SQLUSMALLINT *) ValuePtr;
         stmt->ipd->p_param_array_status = (SQLUSMALLINT *) ValuePtr;
         break;
      case SQL_ATTR_PARAM_STATUS_PTR:
         pattr = "SQL_ATTR_PARAM_STATUS_PTR";
         stmt->apd->p_param_array_status = (SQLUSMALLINT *) ValuePtr;
         stmt->ipd->p_param_array_status = (SQLUSMALLINT *) ValuePtr;
         break;
      case SQL_ATTR_PARAMS_PROCESSED_PTR:
         pattr = "SQL_ATTR_PARAMS_PROCESSED_PTR";
         stmt->apd->p_param_array = (SQLUSMALLINT *) ValuePtr;
         stmt->ipd->p_param_array = (SQLUSMALLINT *) ValuePtr;
         break;
      case SQL_ATTR_PARAMSET_SIZE:
         pattr = "SQL_ATTR_PARAMSET_SIZE";
         stmt->apd->param_array_size = (SQLUINTEGER) ValuePtr;
         stmt->ipd->param_array_size = (SQLUINTEGER) ValuePtr;
         break;
      case SQL_ATTR_ROW_ARRAY_SIZE:
         pattr = "SQL_ATTR_ROW_ARRAY_SIZE";
         stmt->ard->row_array_size = (SQLUINTEGER) ValuePtr;
         stmt->ird->row_array_size = (SQLUINTEGER) ValuePtr;
      case SQL_ROWSET_SIZE:
         pattr = "SQL_ROWSET_SIZE";
         stmt->ard->row_array_size = (int) ValuePtr;
         stmt->ird->row_array_size = (int) ValuePtr;
         break;
      case SQL_ATTR_ROW_BIND_OFFSET_PTR:
         pattr = "SQL_ATTR_ROW_BIND_OFFSET_PTR";
         stmt->ard->p_bind_offset = (SQLPOINTER) ValuePtr;
         stmt->ird->p_bind_offset = (SQLPOINTER) ValuePtr;
         break;
      case SQL_ATTR_ROW_BIND_TYPE:
         pattr = "SQL_ATTR_ROW_BIND_TYPE";
         stmt->ard->bind_type = (SQLINTEGER) ValuePtr;
         stmt->ard->row_array_element_size = (size_t) stmt->ard->bind_type;
         stmt->ird->bind_type = (SQLINTEGER) ValuePtr;
         stmt->ird->row_array_element_size = (size_t) stmt->ard->bind_type;
         break;
      case SQL_ATTR_ROW_NUMBER:
         pattr = "SQL_ATTR_ROW_NUMBER";
         stmt->current_row = (int) ValuePtr;
          break;
      case SQL_ATTR_ROW_OPERATION_PTR:
         pattr = "SQL_ATTR_ROW_OPERATION_PTR";
         stmt->ard->p_row_array = (SQLUSMALLINT *) ValuePtr;
         stmt->ird->p_row_array = (SQLUSMALLINT *) ValuePtr;
         break;
      case SQL_ATTR_ROW_STATUS_PTR:
         pattr = "SQL_ATTR_ROW_STATUS_PTR";
         stmt->ard->p_row_array_status = (SQLUSMALLINT *) ValuePtr;
         stmt->ird->p_row_array_status = (SQLUSMALLINT *) ValuePtr;
         break;
      case SQL_ATTR_ROWS_FETCHED_PTR:
         pattr = "SQL_ATTR_ROWS_FETCHED_PTR";
         stmt->ard->p_rows_fetched = (SQLUINTEGER *) ValuePtr;
         stmt->ird->p_rows_fetched = (SQLUINTEGER *) ValuePtr;
         break;
      case SQL_ATTR_SIMULATE_CURSOR:
         pattr = "SQL_ATTR_SIMULATE_CURSOR";
         stmt->ard->simulate_cursor = (SQLLEN) SQL_SC_UNIQUE;
         stmt->ird->simulate_cursor = (SQLLEN) SQL_SC_UNIQUE;
         break;
      case SQL_ATTR_APP_ROW_DESC:
         pattr = "SQL_ATTR_APP_ROW_DESC";
         stmt->ard = (DESC *) ValuePtr;
         break;
      case SQL_ATTR_IMP_ROW_DESC:
         pattr = "SQL_ATTR_IMP_ROW_DESC";
         stmt->ird = (DESC *) ValuePtr;
         break;
      case SQL_ATTR_APP_PARAM_DESC:
         pattr = "SQL_ATTR_APP_PARAM_DESC";
         stmt->apd = (DESC *) ValuePtr;
         break;
      case SQL_ATTR_IMP_PARAM_DESC:
         pattr = "SQL_ATTR_IMP_PARAM_DESC";
         stmt->ipd = (DESC *) ValuePtr;
         break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Attribute: %d (%s); StringLength=%d; ValuePtr=%p", Attribute, pattr ? pattr : "null", StringLength, ValuePtr);
      mg_log_event( buffer, "SQLSetStmtAttr", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetStmtAttr(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLGetStmtAttr(
   SQLHSTMT       StatementHandle,
   SQLINTEGER     Attribute,
   SQLPOINTER     ValuePtr,
   SQLINTEGER     BufferLength,
   SQLINTEGER *   StringLengthPtr)
{
   char *pattr;
   SQLRETURN result = SQL_SUCCESS;
   STMT *stmt = (STMT *) StatementHandle;
   SQLINTEGER vparam = 0;
   SQLINTEGER len;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;

   if (!ValuePtr)
      ValuePtr = &vparam;

   if (!StringLengthPtr)
      StringLengthPtr = &len;

   switch (Attribute) {
      case SQL_ATTR_CURSOR_SCROLLABLE:
         pattr = "SQL_ATTR_CURSOR_SCROLLABLE";
            *(SQLUINTEGER*) ValuePtr = SQL_NONSCROLLABLE;
         break;
      case SQL_ATTR_AUTO_IPD:
         pattr = "SQL_ATTR_AUTO_IPD";
         *(SQLUINTEGER *) ValuePtr = SQL_FALSE;
         break;
      case SQL_ATTR_PARAM_BIND_OFFSET_PTR:
         pattr = "SQL_ATTR_PARAM_BIND_OFFSET_PTR";
         *(SQLPOINTER *) ValuePtr = stmt->apd->p_bind_offset;
         break;
      case SQL_ATTR_PARAM_BIND_TYPE:
         pattr = "SQL_ATTR_PARAM_BIND_TYPE";
         *(SQLINTEGER *) ValuePtr = stmt->apd->bind_type;
         break;
      case SQL_ATTR_PARAM_OPERATION_PTR:
         pattr = "SQL_ATTR_PARAM_OPERATION_PTR";
         *(SQLPOINTER *) ValuePtr = stmt->ird->p_param_array_status;
         break;
      case SQL_ATTR_PARAM_STATUS_PTR:
         pattr = "SQL_ATTR_PARAM_STATUS_PTR";
         *(SQLPOINTER *) ValuePtr = stmt->ipd->p_row_array_status;
         break;
      case SQL_ATTR_PARAMS_PROCESSED_PTR:
         pattr = "SQL_ATTR_PARAMS_PROCESSED_PTR";
         *(SQLPOINTER *) ValuePtr = stmt->ipd->p_row_array;
         break;
      case SQL_ATTR_PARAMSET_SIZE:
         pattr = "SQL_ATTR_PARAMSET_SIZE";
         *(SQLUINTEGER *) ValuePtr = stmt->apd->row_array_size;
         break;
      case SQL_ATTR_ROW_ARRAY_SIZE:
         pattr = "SQL_ATTR_ROW_ARRAY_SIZE";
         *((SQLUINTEGER *) ValuePtr) = stmt->ard->row_array_size;
         break;
      case SQL_ROWSET_SIZE:
         pattr = "SQL_ROWSET_SIZE";
         *(SQLUINTEGER *) ValuePtr = stmt->ard->row_array_size;
         break;
      case SQL_ATTR_ROW_BIND_OFFSET_PTR:
         pattr = "SQL_ATTR_ROW_BIND_OFFSET_PTR";
         *((SQLPOINTER *) ValuePtr) = stmt->ard->p_bind_offset;
         break;
      case SQL_ATTR_ROW_BIND_TYPE:
         pattr = "SQL_ATTR_ROW_BIND_TYPE";
         *((SQLINTEGER *) ValuePtr) = stmt->ard->bind_type;
         break;
      case SQL_ATTR_ROW_NUMBER:
         pattr = "SQL_ATTR_ROW_NUMBER";
         *(SQLUINTEGER *) stmt->current_row;
          break;
      case SQL_ATTR_ROW_OPERATION_PTR:
         pattr = "SQL_ATTR_ROW_OPERATION_PTR";
         *(SQLPOINTER *) ValuePtr = stmt->ird->p_row_array;
         break;
      case SQL_ATTR_ROW_STATUS_PTR:
         pattr = "SQL_ATTR_ROW_STATUS_PTR";
         *(SQLPOINTER *) ValuePtr = stmt->ird->p_row_array_status;
         break;
      case SQL_ATTR_ROWS_FETCHED_PTR:
         pattr = "SQL_ATTR_ROWS_FETCHED_PTR";
         *(SQLPOINTER *) ValuePtr = stmt->ird->p_rows_fetched;
         break;
      case SQL_ATTR_SIMULATE_CURSOR:
         pattr = "SQL_ATTR_SIMULATE_CURSOR";
         *(SQLLEN *) ValuePtr = stmt->ird->simulate_cursor;
         break;
      case SQL_ATTR_APP_ROW_DESC:
         pattr = "SQL_ATTR_APP_ROW_DESC";
         *(SQLPOINTER *) ValuePtr = stmt->ard;
         *StringLengthPtr = sizeof(SQLPOINTER);
         break;
      case SQL_ATTR_IMP_ROW_DESC:
         pattr = "SQL_ATTR_IMP_ROW_DESC";
         *(SQLPOINTER *) ValuePtr = stmt->ird;
         *StringLengthPtr = sizeof(SQLPOINTER);
         break;
      case SQL_ATTR_APP_PARAM_DESC:
         pattr = "SQL_ATTR_APP_PARAM_DESC";
         *(SQLPOINTER *) ValuePtr = stmt->apd;
         *StringLengthPtr = sizeof(SQLPOINTER);
         break;
      case SQL_ATTR_IMP_PARAM_DESC:
         pattr = "SQL_ATTR_IMP_PARAM_DESC";
         *(SQLPOINTER *) ValuePtr = stmt->ipd;
         *StringLengthPtr = sizeof(SQLPOINTER);
         break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Attribute: %d (%s); BufferLength=%d; ValuePtr=%p", Attribute, pattr ? pattr : "null", BufferLength, ValuePtr);
      mg_log_event( buffer, "SQLGetStmtAttr", 0, (void *) stmt, MG_DBT_STMT);
   }
    return result;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetStmtAttr(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLSetStmtOption(HSTMT hstmt, UWORD fOption, UDWORD vParam)
{
#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLGetStmtAttr", 0, NULL, 0);
   }
   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetStmtOption(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif
}
#endif


/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLGetConnectOption(HDBC hdbc, UWORD fOption, PTR pvParam)
{
#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLGetConnectOption", 0, NULL, 0);
   }
   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetConnectOption(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif
}
#endif


/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLGetStmtOption(HSTMT hstmt, UWORD fOption, PTR pvParam)
{
#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLGetStmtOption", 0, NULL, 0);
   }
   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetStmtOption(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif
}
#endif