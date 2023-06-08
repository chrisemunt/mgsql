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


#define DESC_UNKNOWN  0
#define DESC_APP 1
#define DESC_IMP 2
#define DESC_ROW 3
#define DESC_PARAM 4


DESC *desc_alloc(STMT *stmt, SQLSMALLINT alloc_type, short ref_type, short desc_type)
{
   DESC *desc;

#ifdef _WIN32
__try {
#endif

   desc = (DESC *) malloc(sizeof(DESC));

   if (!desc) {
      return NULL;
   }

   desc->desc_type= desc_type;
   desc->alloc_type = alloc_type;
   desc->ref_type = ref_type;
   desc->bind_type = SQL_BIND_BY_COLUMN;

   desc->stmt = stmt;
   desc->dbc = NULL;

   desc->p_rows_fetched = NULL;
   desc->p_row_array_status = NULL;
   desc->p_row_array = NULL;
   desc->row_array_element_size = 0;
   desc->row_array_size = 0;

   desc->p_param_array_status = NULL;
   desc->p_param_array = NULL;

#if 0
   desc->array_size= 1;
   desc->array_status_ptr= NULL;
   desc->bind_offset_ptr= NULL;
   desc->bind_type= SQL_BIND_BY_COLUMN;
   desc->count= 0;
   desc->rows_processed_ptr= NULL;
   desc->exp.stmts= NULL;
#endif

  return desc;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in desc_alloc(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return NULL;
}
#endif

}


/* Allocate an environment (ENV) block. */
/* *** Deprecated *** */
RETCODE SQL_API SQLAllocEnv(SQLHENV *phenv)
{
   HGLOBAL henv;
   ENV * penv;

#ifdef _WIN32
__try {
#endif

   henv = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, sizeof (ENV));
   if (!henv || (*phenv = (HENV) GlobalLock(henv)) == SQL_NULL_HENV) {
      GlobalFree(henv); /* Free it if lock fails */
      return SQL_ERROR;
   }

   penv = (ENV *) *phenv;
   penv->error.status = 0;

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLAllocEnv(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Allocate a DBC block */
/* *** Deprecated *** */
RETCODE SQL_API SQLAllocConnect(SQLHENV henv, SQLHDBC * phdbc)
{
   HGLOBAL hdbc;
   ENV * env;
   DBC * pdbc;

#ifdef _WIN32
__try {
#endif

   env = (ENV *) henv;

   hdbc = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, sizeof (DBC));
   if (!hdbc || (*phdbc = (HDBC) GlobalLock(hdbc)) == SQL_NULL_HDBC) {
      GlobalFree(hdbc); /* Free it if lock fails */
      return SQL_ERROR;
   }

   pdbc = (DBC *) *phdbc;
   pdbc->henv = henv;

   pdbc->error.status = 0;

   pdbc->mlock = mg_mutex_create(NULL);

   pdbc->login_timeout = MG_DEF_LOGIN_TIMEOUT;
   pdbc->req_timeout = MG_DEF_REQ_TIMEOUT;

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLAllocConnect(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Allocate memory for processing a SQL statement */
/* *** Deprecated *** */
RETCODE SQL_API SQLAllocStmt(SQLHDBC hdbc, SQLHSTMT *phstmt)
{
   HGLOBAL hstmt;
   ENV * env;
   DBC * dbc;
   STMT * pstmt;

#ifdef _WIN32
__try {
#endif

   env = NULL;
   dbc = (DBC *) hdbc;
   if (dbc) {
      env = (ENV *) dbc->henv;
   }

   hstmt = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, sizeof(STMT));
   if (!hstmt || (*phstmt = (HSTMT) GlobalLock(hstmt)) == SQL_NULL_HSTMT) {
      GlobalFree(hstmt); /* Free it if lock fails */
      return SQL_ERROR;
   }

   pstmt = (STMT *) *phstmt;
   pstmt->hdbc = hdbc;

   pstmt->ard = desc_alloc(pstmt, SQL_DESC_ALLOC_AUTO, DESC_APP, DESC_ROW);
   pstmt->ird = desc_alloc(pstmt, SQL_DESC_ALLOC_AUTO, DESC_IMP, DESC_ROW);
   pstmt->apd = desc_alloc(pstmt, SQL_DESC_ALLOC_AUTO, DESC_APP, DESC_PARAM);
   pstmt->ipd = desc_alloc(pstmt, SQL_DESC_ALLOC_AUTO, DESC_IMP, DESC_PARAM);

   mg_reset_stmt(pstmt, 0);

   pstmt->stmt_no = mg_get_next_stmt_no();

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLAllocStmt(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/*
  Explicitly allocate a descriptor.
*/
SQLRETURN SQLAllocDesc(SQLHDBC hdbc, SQLHANDLE * pdesc)
{
   DBC *dbc= (DBC *) hdbc;

#ifdef _WIN32
__try {
#endif

   DESC *desc = desc_alloc(NULL, SQL_DESC_ALLOC_USER, DESC_APP, DESC_UNKNOWN);

   desc->dbc = dbc;
   desc->error.status = 0;

   *pdesc = desc;

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLAllocDesc(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


SQLRETURN SQL_API SQLAllocHandle(SQLSMALLINT HandleType, SQLHANDLE InputHandle, SQLHANDLE * OutputHandlePtr)
{
   char *pattr;
   SQLRETURN error = SQL_ERROR;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;

   switch (HandleType) {
      case SQL_HANDLE_ENV:
         pattr = "SQL_HANDLE_ENV";
         error = SQLAllocEnv(OutputHandlePtr);
         break;
      case SQL_HANDLE_DBC:
         pattr = "SQL_HANDLE_DBC";
         error = SQLAllocConnect((SQLHENV) InputHandle, (SQLHDBC *) OutputHandlePtr);
         break;
      case SQL_HANDLE_STMT:
         pattr = "SQL_HANDLE_STMT";
         error = SQLAllocStmt((SQLHDBC) InputHandle, (SQLHSTMT *) OutputHandlePtr);
         break;
      case SQL_HANDLE_DESC:
         pattr = "SQL_HANDLE_DESC";
         error = SQLAllocDesc((SQLHDBC) InputHandle, (SQLHANDLE *) OutputHandlePtr);
         break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "HandleType=%d (%s); OutputHandlePtr=%p; result=%d;", HandleType, pattr ? pattr : "null", OutputHandlePtr, (int) error);
      mg_log_event(buffer, "SQLAllocHandle", 0, NULL, 0);
   }

   return error;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLAllocHandle(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* *** Deprecated *** */
RETCODE SQL_API SQLFreeEnv(SQLHENV henv)
{
#ifdef _WIN32
__try {
#endif

   GlobalUnlock (GlobalPtrHandle(henv));
   GlobalFree (GlobalPtrHandle(henv));
   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFreeEnv(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* *** Deprecated *** */
RETCODE SQL_API SQLFreeConnect(SQLHDBC hdbc)
{
   DBC * dbc;

#ifdef _WIN32
__try {
#endif

   dbc = (DBC *) hdbc;
   if (dbc) {
      mg_mutex_destroy(dbc->mlock);
   }

   GlobalUnlock (GlobalPtrHandle(hdbc));
   GlobalFree (GlobalPtrHandle(hdbc));
   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFreeConnect(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


SQLRETURN SQL_API SQLFreeStmt(SQLHSTMT hstmt, SQLUSMALLINT Option)
{
   char * pattr;
   STMT * stmt = (STMT *) hstmt;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;
   switch (Option) {
      case SQL_CLOSE:
         pattr = "SQL_CLOSE";
         mg_reset_stmt(stmt, 1);
         break;
      case SQL_DROP:
         pattr = "SQL_CLOSE";
         mg_reset_stmt(stmt, 1);
         break;
      case SQL_UNBIND:
         pattr = "SQL_CLOSE";
         mg_reset_stmt(stmt, 1);
         break;
      case SQL_RESET_PARAMS:
         pattr = "SQL_CLOSE";
         mg_reset_stmt(stmt, 1);
         break;
      default:
         pattr = "<UNKOWN>";
         break;
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Option=%d (%s); stmt=%p;", Option, pattr ? pattr : "null", stmt);
      mg_log_event(buffer, "SQLFreeStmt", 0, NULL, 0);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFreeStmt(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


SQLRETURN SQLFreeDesc(SQLHANDLE desc)
{
#ifdef _WIN32
__try {
#endif

   GlobalUnlock (GlobalPtrHandle(desc));
   GlobalFree (GlobalPtrHandle(desc));

   return SQL_SUCCESS;


#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFreeDesc(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


SQLRETURN SQL_API SQLFreeHandle(SQLSMALLINT HandleType, SQLHANDLE Handle)
{
   char *pattr;
   SQLRETURN error = SQL_SUCCESS;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;

   switch (HandleType) {
      case SQL_HANDLE_ENV:
         pattr = "SQL_HANDLE_ENV";
         error = SQLFreeEnv((SQLHENV) Handle);
         break;
      case SQL_HANDLE_DBC:
         pattr = "SQL_HANDLE_DBC";
         error = SQLFreeConnect((SQLHDBC) Handle);
         break;
      case SQL_HANDLE_STMT:
         pattr = "SQL_HANDLE_STMT";
         error = SQLFreeStmt((SQLHSTMT) Handle, SQL_DROP);
         break;
      case SQL_HANDLE_DESC:
         pattr = "SQL_HANDLE_DESC";
         error = SQLFreeDesc((SQLHANDLE) Handle);
         break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "HandleType=%d (%s); Handle=%p; result=%d;", HandleType, pattr ? pattr : "null", Handle, (int) error);
      mg_log_event(buffer, "SQLFreeHandle", 0, NULL, 0);
   }

   return error;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFreeHandle(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


