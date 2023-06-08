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


/* Perform a Prepare on the SQL statement */
SQLRETURN SQL_API SQLPrepare(
   SQLHSTMT    StatementHandle,
   SQLCHAR *   StatementText,
   SQLINTEGER  TextLength)
{
   short phase;
   int n, len;
   //char in_string, *pos;
   RECHEAD rhead;
   DBLK *p_block;
   ENV * env;
   DBC * dbc;
   STMT *stmt = (STMT *) StatementHandle;

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
      sprintf(buffer, "SQLPrepare: stmt_no=%d;", stmt->stmt_no);
      mg_log_event((char *) stmt->query + MG_HEAD_SIZE, buffer, 0, (void *) stmt, MG_DBT_STMT);
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "SQLPrepare: stmt_no=%d; param_count=%d;", stmt->stmt_no, stmt->ipd->param_count);
      mg_log_event((char *) buffer, "SQLPrepare", 0, (void *) stmt, MG_DBT_STMT);
   }

   phase = 1;

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;
   len = stmt->query_len;

   rhead.cmnd = 'b';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   phase = 2;

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
      mg_set_error(&stmt->error, "HY000", 0, "No response block", "SQLExecDirect");
      return SQL_ERROR;
   }

   phase = 53;
   if (!p_block->pdata) {
      phase = 52;
      mg_set_error(&stmt->error, "HY000", 0, "No response data", "SQLExecDirect");
      return SQL_ERROR;
   }

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLExecDirect");
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
      sprintf(buffer, "Exception caught in SQLPrepare(): %x:%d", code, phase);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


/* Bind parameters on a statement handle */
/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLSetParam(SQLHSTMT StatementHandle, SQLUSMALLINT ParameterNumber, SQLSMALLINT ValueType, SQLSMALLINT ParameterType, SQLUINTEGER LengthPrecision, SQLSMALLINT ParameterScale, SQLPOINTER ParameterValue, SQLINTEGER *StrLen_or_Ind)
{
#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLSetParam", 0, NULL, 0);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetParam(): %x", code);
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


SQLRETURN SQL_API SQLBindParameter(SQLHSTMT StatementHandle, SQLUSMALLINT ParameterNumber, SQLSMALLINT InputOutputType, SQLSMALLINT ValueType, SQLSMALLINT ParameterType, SQLULEN ColumnSize, SQLSMALLINT DecimalDigits, SQLPOINTER ParameterValuePtr, SQLLEN BufferLength, SQLLEN * StrLen_or_IndPtr)
{
   int pno;
   STMT *stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "ParameterNumber=%d; InputOutputType=%d (%s); ValueType=%d (%s); ParameterType=%d (%s); ColumnSize=%d; DecimalDigits=%d; ParameterValuePtr=%p (%s); BufferLength=%d; *StrLen_or_IndPtr=%p (%d)",
                  (int) ParameterNumber, (int) InputOutputType, mg_iotype_str((int) InputOutputType),
                  (int) ValueType, mg_ctype_str((int) ValueType),
                  (int) ParameterType, mg_sqltype_str((int) ParameterType),
                  (int) ColumnSize, (int) DecimalDigits, (void *) ParameterValuePtr, (ParameterType == SQL_C_CHAR) ?  (char *) ParameterValuePtr : "",
                  (int) BufferLength, (void *) StrLen_or_IndPtr, StrLen_or_IndPtr ? (int) *StrLen_or_IndPtr : 0);
      mg_log_event(buffer, "SQLBindParamter", 0, (void *) stmt, MG_DBT_STMT);
   }

   pno = (int) ParameterNumber - 1;
   stmt->ipd->params[pno].input_output_type = InputOutputType;
   stmt->ipd->params[pno].value_type = ValueType; 
   stmt->ipd->params[pno].parameter_type = ParameterType;
   stmt->ipd->params[pno].column_size = ColumnSize;
   stmt->ipd->params[pno].decimal_digits = DecimalDigits; 
   stmt->ipd->params[pno].parameter_value_ptr = ParameterValuePtr; 
   stmt->ipd->params[pno].buffer_length = BufferLength; 
   stmt->ipd->params[pno].strLen_or_indptr = StrLen_or_IndPtr;

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLBindParameter(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


/* Returns the description of a parameter marker */
SQLRETURN SQL_API SQLDescribeParam(
   SQLHSTMT       StatementHandle,
   SQLUSMALLINT   ParameterNumber,
   SQLSMALLINT *  DataTypePtr,
   SQLULEN *      ParameterSizePtr,
   SQLSMALLINT *  DecimalDigitsPtr,
   SQLSMALLINT *  NullablePtr)
{
   STMT *stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "ParameterNumber=%d;", ParameterNumber);
      mg_log_event(buffer, "SQLDescribeParam", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLDescribeParam(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


/* Sets multiple values (arrays) for the set of parameter markers. */
/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLParamOptions(HSTMT hstmt, UDWORD crow, UDWORD *pirow)
{
#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLParamOptions", 0, NULL, 0);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLParamOptions(): %x", code);
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


/* Returns the number of parameter markers. */
SQLRETURN SQL_API SQLNumParams(SQLHSTMT StatementHandle, SQLSMALLINT * ParameterCountPtr)
{
   STMT *stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLNumParams", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (ParameterCountPtr) {
      *ParameterCountPtr = stmt->param_count;
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLNumParams(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


/* Sets options that control the behavior of cursors. */
/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLSetScrollOptions(HSTMT hstmt, UWORD fConcurrency, SDWORD crowKeyset, UWORD crowRowset)
{
#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLSetScrollOptions", 0, NULL, 0);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetScrollOptions(): %x", code);
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


/* Set the cursor name on a statement handle. */
SQLRETURN SQL_API SQLSetCursorName(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CursorName,
   SQLSMALLINT    NameLength)
{
   STMT *stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLSetCursorName", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetCursorName(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


/* Return the cursor name for a statement handle. */
SQLRETURN SQL_API SQLGetCursorName(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CursorName,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  NameLengthPtr)
{
   STMT *stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLGetCursorName", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;


#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetCursorName(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLCloseCursor(SQLHSTMT StatementHandle)
{
   STMT *stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLCloseCursor", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLCloseCursor(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}

