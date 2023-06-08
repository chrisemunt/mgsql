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


SQLRETURN SQL_API SQLExecuteEx(STMT * stmt, DBC * dbc, ENV * env, SQLUINTEGER array_no, short context);


/* Execute a prepared SQL statement */

SQLRETURN SQL_API SQLExecute(SQLHSTMT StatementHandle)
{
   short phase;
   SQLUINTEGER array_no;
   SQLRETURN ret;
   ENV * env;
   DBC * dbc;
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   env = NULL;
   dbc = (DBC *) stmt->hdbc;
   if (dbc)
      env = (ENV *) dbc->henv;

   if (CoreData.ftrace == 1) {
      mg_log_event(stmt->query + MG_HEAD_SIZE, "SQLExecute", 0, (void *) stmt, MG_DBT_STMT);
   }

   phase = 1;
/*
   {
      char buffer[256];
      sprintf(buffer, "SQLExecute: stmt_no=%d; stmt->query_len=%d; stmt->ipd=%p; stmt->ipd->row_array_size=%d; *stmt->ird->p_rows_fetched=%d; stmt->ird->col_count=%d;", stmt->stmt_no, stmt->query_len, stmt->ipd, stmt->ipd->row_array_size, stmt->ipd->p_rows_fetched ? *(stmt->ipd->p_rows_fetched) : 0, stmt->ird->col_count);
      mg_log_event(buffer, "SQLExecute : START", 0, (void *) stmt, MG_DBT_STMT);
   }
*/

   if (stmt->ipd->row_array_size && stmt->ipd->p_rows_fetched && *(stmt->ipd->p_rows_fetched) > 0) {
      for (array_no = 0; array_no < *(stmt->ipd->p_rows_fetched); array_no ++) {
         ret = SQLExecuteEx(stmt, dbc, env, array_no, 1);
         if (ret == SQL_ERROR) {
            break;
         }
      }
   }
   else {
      ret = SQLExecuteEx(stmt, dbc, env, 0, 0);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLExecute(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Performs the equivalent of SQLPrepare, followed by SQLExecute. */

SQLRETURN SQL_API SQLExecDirect(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      StatementText,
   SQLINTEGER     TextLength)
{
   short phase;
   SQLUINTEGER array_no;
   SQLRETURN ret;
   ENV * env;
   DBC * dbc;
   STMT * stmt = (STMT *) StatementHandle;

   phase = 0;

#ifdef _WIN32
__try {
#endif

   env = NULL;
   dbc = (DBC *) stmt->hdbc;
   if (dbc)
      env = (ENV *) dbc->henv;

   mg_qbuffer(stmt, StatementText, (SQLSMALLINT) TextLength);

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "SQLExecDirect: stmt_no=%d;", stmt->stmt_no);
      mg_log_event((char *) stmt->query + MG_HEAD_SIZE, buffer, 0, (void *) stmt, MG_DBT_STMT);
   }
/*
   {
      char buffer[256];
      sprintf(buffer, "SQLExecDirect: stmt_no=%d; stmt->ipd=%p; stmt->ipd->row_array_size=%d; *stmt->ird->p_rows_fetched=%d; stmt->ird->col_count=%d;", stmt->stmt_no, stmt->ipd, stmt->ipd->row_array_size, stmt->ipd->p_rows_fetched ? *(stmt->ipd->p_rows_fetched) : 0, stmt->ird->col_count);
      mg_log_event(buffer, "SQLExecDirect : START", 0, (void *) stmt, MG_DBT_STMT);
   }
*/
   if (stmt->ipd->row_array_size && stmt->ipd->p_rows_fetched && *(stmt->ipd->p_rows_fetched) > 0) {
      for (array_no = 0; array_no < *(stmt->ipd->p_rows_fetched); array_no ++) {
         ret = SQLExecuteEx(stmt, dbc, env, array_no, 1);
         if (ret == SQL_ERROR) {
            break;
         }
      }
   }
   else {
      ret = SQLExecuteEx(stmt, dbc, env, 0, 0);
   }

   return ret;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLExecEx(): %x:%d", code, phase);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
      mg_set_error(&stmt->error, "HY000", 0, buffer, "SQLExecEx");
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


SQLRETURN SQL_API SQLExecuteEx(STMT * stmt, DBC * dbc, ENV * env, SQLUINTEGER array_no, short context)
{
   short phase;
   int n, len;
   RECHEAD rhead;
   DBLK *p_block;
   phase = 0;

#ifdef _WIN32
__try {
#endif

   phase = 1;

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;
   len = stmt->query_len;

   rhead.cmnd = 's';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   phase = 2;

   mg_qaddparams(stmt, array_no, context);

   rhead.size = stmt->query_len_with_params;

   mg_set_record_head(&rhead, stmt->query);
   phase = 3;
   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, stmt->query, MG_HEAD_SIZE + rhead.size);
   phase = 4;
   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   phase = 5;
   if (!p_block) {
      phase = 51;
      mg_set_error(&stmt->error, "HY000", 0, "No response block", "SQLExecEx");
      return SQL_ERROR;
   }

   phase = 53;
   if (!p_block->pdata) {
      phase = 52;
      mg_set_error(&stmt->error, "HY000", 0, "No response data", "SQLExecEx");
      return SQL_ERROR;
   }

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLExecEx");
      return SQL_ERROR;
   }

   phase = 6;

   n = mg_get_cols(stmt, p_block->pdata);

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLExecEx(): %x:%d", code, phase);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
      mg_set_error(&stmt->error, "HY000", 0, buffer, "SQLExecEx");
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif
}


/* Returns the SQL string as modified by the driver. */
SQLRETURN SQL_API SQLNativeSql(
   SQLHDBC        ConnectionHandle,
   SQLCHAR *      InStatementText,
   SQLINTEGER     TextLength1,
   SQLCHAR *      OutStatementText,
   SQLINTEGER     BufferLength,
   SQLINTEGER *   TextLength2Ptr)
{
   DBC * dbc = (DBC *) ConnectionHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLNativeSQL", 0, (void *) dbc, MG_DBT_DBC);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLNativeSql(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Supplies parameter data at execution time. Used in conjuction with SQLPutData. */
SQLRETURN SQL_API SQLParamData(SQLHSTMT StatementHandle, SQLPOINTER * ValuePtrPtr)
{
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLParamData", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLParamData(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Supplies parameter data at execution time. Used in conjunction with SQLParamData. */
SQLRETURN SQL_API SQLPutData(SQLHSTMT StatementHandle, SQLPOINTER DataPtr, SQLLEN StrLen_or_Ind)
{
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLPutData", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLPutData(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Cancel Statement */
SQLRETURN SQL_API SQLCancel(SQLHSTMT StatementHandle)
{
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLCancel", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLCancel(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


SQLRETURN SQL_API SQLBulkOperations(SQLHSTMT StatementHandle, SQLSMALLINT Operation)
{
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLBulkOperations", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLBulkOperations(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


