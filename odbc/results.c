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

SQLRETURN SQL_API SQLFetchEx(STMT *stmt, DBC *dbc, ENV *env, SQLSMALLINT FetchOrientation, SQLLEN FetchOffset, SQLUINTEGER array_no);
SQLRETURN SQL_API SQLFetchExResetCols(STMT *stmt, DBC *dbc, ENV *env, SQLSMALLINT FetchOrientation, SQLLEN FetchOffset, SQLUINTEGER array_no);

/* This returns the number of columns associated with the database attached to "hstmt". */
SQLRETURN SQL_API SQLNumResultCols(SQLHSTMT StatementHandle,SQLSMALLINT * ColumnCountPtr)
{
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
      char buffer[256];
      sprintf(buffer, "stmt_no=%d; col_count=%d;", stmt->stmt_no, stmt->ird->col_count);
      mg_log_event(buffer, "SQLNumResultCols", 0, (void *) stmt, MG_DBT_STMT);
   }
   *ColumnCountPtr = stmt->ird->col_count;

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLNumResultCols(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Return information about the database column the user wants information about. */
SQLRETURN SQL_API SQLDescribeCol(
   SQLHSTMT       StatementHandle,
   SQLUSMALLINT   ColumnNumber,
   SQLCHAR *      ColumnName,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  NameLengthPtr,
   SQLSMALLINT *  DataTypePtr,
   SQLULEN *      ColumnSizePtr,
   SQLSMALLINT *  DecimalDigitsPtr,
   SQLSMALLINT *  NullablePtr
)
{
   STMT * stmt = (STMT *) StatementHandle;
   char m_buffer[124];

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      sprintf(m_buffer, "Column number %d", ColumnNumber);
      mg_log_event( m_buffer, "SQLDescribeCol", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (ColumnNumber <= stmt->ird->col_count) {
      strcpy((char *) ColumnName, stmt->ird->cols[ColumnNumber - 1].cname);

      *NameLengthPtr = (SQLSMALLINT) strlen((char *) ColumnName);
      *DataTypePtr = SQL_VARCHAR;
      *NullablePtr = SQL_NULLABLE;
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLDescribeCol(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}



SQLRETURN SQL_API SQLColAttribute(
   SQLHSTMT       StatementHandle,
   SQLUSMALLINT   ColumnNumber,
   SQLUSMALLINT   FieldIdentifier,
   SQLPOINTER     CharacterAttributePtr,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  StringLengthPtr,
   SQLLEN *       NumericAttributePtr
)
{
   int len;
   char *pattr;
   char atext[1024];
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   pattr = NULL;
   len = -1;
   *atext = '\0';

   switch (FieldIdentifier) {
      case SQL_DESC_AUTO_UNIQUE_VALUE:
         pattr = "SQL_DESC_AUTO_UNIQUE_VALUE";
         break;
      case SQL_DESC_CASE_SENSITIVE:
         pattr = "SQL_DESC_CASE_SENSITIVE";
         break;
      case SQL_DESC_FIXED_PREC_SCALE:
         pattr = "SQL_DESC_FIXED_PREC_SCALE";
         break;
      case SQL_DESC_NULLABLE:
         pattr = "SQL_DESC_NULLABLE";
         break;
      case SQL_DESC_NUM_PREC_RADIX:
         pattr = "SQL_DESC_NUM_PREC_RADIX";
         break;
      case SQL_DESC_PRECISION:
         pattr = "SQL_DESC_PRECISION";
         break;
      case SQL_DESC_SCALE:
         pattr = "SQL_DESC_SCALE";
         break;
      case SQL_DESC_SEARCHABLE:
         pattr = "SQL_DESC_SEARCHABLE";
         break;
      case SQL_DESC_TYPE:
         pattr = "SQL_DESC_TYPE";
         break;
      case SQL_DESC_CONCISE_TYPE:
         *NumericAttributePtr = (SQLINTEGER) stmt->ird->cols[ColumnNumber - 1].type_id;
         pattr = "SQL_DESC_CONCISE_TYPE";
         break;
      case SQL_DESC_UNNAMED:
         pattr = "SQL_DESC_UNNAMED";
         break;
      case SQL_DESC_UNSIGNED:
         pattr = "SQL_DESC_UNSIGNED";
         break;
      case SQL_DESC_UPDATABLE:
         pattr = "SQL_DESC_UPDATABLE";
         /* SQL_ATTR_READONLY SQL_ATTR_WRITE SQL_ATTR_READWRITE_UNKNOWN */
         *NumericAttributePtr = (SQLINTEGER) SQL_ATTR_WRITE;
         break;
      case SQL_DESC_DISPLAY_SIZE:
         pattr = "SQL_DESC_DISPLAY_SIZE";
         break;
      case SQL_DESC_LENGTH:
         pattr = "SQL_DESC_LENGTH";
         break;
      case SQL_DESC_OCTET_LENGTH:
         *NumericAttributePtr = (SQLINTEGER) stmt->ird->cols[ColumnNumber - 1].type_len;
         pattr = "SQL_DESC_OCTET_LENGTH";
         break;
      case SQL_DESC_BASE_COLUMN_NAME:
         strcpy(atext, (char *) stmt->ird->cols[ColumnNumber - 1].cname);
         len = (int) strlen((char *) atext);
         pattr = "SQL_DESC_BASE_COLUMN_NAME";
         break;
      case SQL_DESC_LABEL:
         pattr = "SQL_DESC_LABEL";
         break;
      case SQL_DESC_NAME:
         pattr = "SQL_DESC_NAME";
         strcpy(atext, (char *) stmt->ird->cols[ColumnNumber - 1].cname);
         len = (int) strlen((char *) atext);
         break;
      case SQL_DESC_BASE_TABLE_NAME:
         pattr = "SQL_DESC_BASE_TABLE_NAME";
         strcpy(atext, (char *) stmt->ird->cols[ColumnNumber - 1].cname);
         len = (int) strlen((char *) atext);
         break;
      case SQL_DESC_TABLE_NAME:
         pattr = "SQL_DESC_TABLE_NAME";
         strcpy(atext, (char *) stmt->ird->cols[ColumnNumber - 1].cname);
         len = (int) strlen((char *) atext);
         break;
      case SQL_DESC_CATALOG_NAME:
         pattr = "SQL_DESC_CATALOG_NAME";
         strcpy(atext, (char *) stmt->ird->cols[ColumnNumber - 1].cname);
         len = (int) strlen((char *) atext);
         break;
      case SQL_DESC_LITERAL_PREFIX:
         pattr = "SQL_DESC_LITERAL_PREFIX";
         strcpy(atext, "");
         len = 0;
         break;
      case SQL_DESC_LITERAL_SUFFIX:
         pattr = "SQL_DESC_LITERAL_SUFFIX";
         strcpy(atext, "");
         len = 0;
         break;
      case SQL_DESC_SCHEMA_NAME:
         pattr = "SQL_DESC_SCHEMA_NAME";
         strcpy(atext, (char *) stmt->ird->cols[ColumnNumber - 1].dbid);
         len = (int) strlen((char *) atext);
         break;
      case SQL_DESC_TYPE_NAME:
         pattr = "SQL_DESC_TYPE_NAME";
         strcpy(atext, (char *) stmt->ird->cols[ColumnNumber - 1].type);
         len = (int) strlen((char *) atext);
         break;
      default:
         pattr = "<UNKOWN>";
   }

   if (len >= 0) {
      if (StringLengthPtr) {
         *StringLengthPtr = len;
      }
      if (CharacterAttributePtr) {
         strncpy((char *) CharacterAttributePtr, atext, (int) BufferLength);
         ((char *) CharacterAttributePtr)[BufferLength - 1] = '\0';
      }
   }


   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "stmt_no=%d; FieldIdentifier=%d (%s); col_count=%d; ColumnNumber=%d; text_length=%d; text=%s;", stmt->stmt_no, FieldIdentifier, pattr ? pattr : "null", stmt->ird->col_count, (int) ColumnNumber, len, atext);
      mg_log_event(buffer, "SQLColAttribute", 0, (void *) stmt, MG_DBT_STMT);
   }


   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLColAttribute(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Returns result column descriptor information for a result set. */
/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLColAttributes(HSTMT hstmt, UWORD icol, UWORD fDescType, PTR rgbDesc, SWORD cbDescMax, SWORD *pcbDesc, SDWORD *pfDesc)
{
#ifdef _WIN32
__try {
#endif
   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLColAttributes", 0, NULL, 0);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLColAttributes(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}
#endif


/* Associate a user-supplied buffer with a database column. */
SQLRETURN SQL_API SQLBindCol(
   SQLHSTMT       StatementHandle,
   SQLUSMALLINT   ColumnNumber,
   SQLSMALLINT    TargetType,
   SQLPOINTER     TargetValuePtr,
   SQLLEN         BufferLength,
   SQLLEN *       StrLen
)
{
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "ColumnNumber=%d; TargetType=%d; TargetValuePtr=%p; BufferLength=%d;", (int) ColumnNumber, TargetType, TargetValuePtr, (int) BufferLength);
      mg_log_event(buffer, "SQLBindCol", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (ColumnNumber > 0 && ColumnNumber < MG_MAX_COLS) {
      stmt->ird->coldat[ColumnNumber - 1].bound = 1;
      stmt->ird->coldat[ColumnNumber - 1].type = TargetType;
      stmt->ird->coldat[ColumnNumber - 1].pdata = TargetValuePtr;
      stmt->ird->coldat[ColumnNumber - 1].maxlen = (int) BufferLength;
      stmt->ird->coldat[ColumnNumber - 1].pactlen = (int *) StrLen;
      stmt->ird->coldat[ColumnNumber - 1].actlen = 0;
      memcpy((void *) &(stmt->ird->coldat0[ColumnNumber - 1]), (void *) &(stmt->ird->coldat[ColumnNumber - 1]), sizeof(MGCOLDAT));
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLBindCol(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Returns data for bound columns in the current row ("hstmt->iCursor"), advances the cursor. */
SQLRETURN SQL_API SQLFetch(SQLHSTMT StatementHandle)
{
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

   array_no = 0;

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "SQLFetch: stmt_no=%d; stmt->status=%d; stmt->eod=%d; stmt->ird->row_array_size=%d;", stmt->stmt_no, stmt->status, stmt->eod, stmt->ird->row_array_size);
      mg_log_event(buffer, "SQLFetch", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (stmt->status == 0 || stmt->eod)
      return SQL_NO_DATA_FOUND;

   if (stmt->ird->row_array_size) {
      for (array_no = 0; array_no < stmt->ird->row_array_size; array_no ++) {
         ret = SQLFetchEx(stmt, dbc, env, SQL_FETCH_NEXT, 0, array_no);
         if (ret == SQL_ERROR) {
            break;
         }
      }
   }
   else {
      ret = SQLFetchEx(stmt, dbc, env, SQL_FETCH_NEXT, 0, 0);
   }

   if (array_no > 0 && ret == SQL_NO_DATA) {
      ret = SQL_SUCCESS;
   }

   return ret;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFetch(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif
}


SQLRETURN SQL_API SQLFetchScroll(SQLHSTMT StatementHandle, SQLSMALLINT FetchOrientation, SQLLEN FetchOffset)
{
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
      char buffer[256];
      sprintf(buffer, "stmt_no=%d; FetchOrientation=%d; FetchOffset=%d;", stmt->stmt_no, (int) FetchOrientation, (int) FetchOffset);
      mg_log_event(buffer, "SQLFetchScroll", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (stmt->status == 0 || stmt->eod) {
      return SQL_NO_DATA_FOUND;
   }

   if (stmt->ird->row_array_size) {
      for (array_no = 0; array_no < stmt->ird->row_array_size; array_no ++) {
         ret = SQLFetchEx(stmt, dbc, env, FetchOrientation, FetchOffset, array_no);
         if (ret == SQL_ERROR) {
            break;
         }
      }
   }
   else {
      ret = SQLFetchEx(stmt, dbc, env, SQL_FETCH_NEXT, 0, 0);
   }

   if (array_no > 0 && ret == SQL_NO_DATA) {
      ret = SQL_SUCCESS;
   }

   return ret;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFetchScroll(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


SQLRETURN SQL_API SQLFetchEx(STMT *stmt, DBC *dbc, ENV *env, SQLSMALLINT FetchOrientation, SQLLEN FetchOffset, SQLUINTEGER array_no)
{
   short phase;
   SQLRETURN ret;
   int n, len;
   char buffer[1024];
   char *p;
   RECHEAD rhead;
   DBLK *p_block;

   phase = 0;

#ifdef _WIN32
__try {
#endif

   ret = SQL_SUCCESS;

   if (stmt->status == 0 || stmt->eod) {
      return SQL_NO_DATA_FOUND;
   }

   phase = 1;
/*
   {
      char buffer[256];
      sprintf(buffer, "SQLFetchEx: stmt_no=%d; array_no=%d; stmt->ird->array_size=%d; stmt->col_count=%d;", stmt->stmt_no, array_no, stmt->ird->row_array_size, stmt->ird->col_count);
      mg_log_event(buffer, "SQLFetchSEx : START", 0, (void *) stmt, MG_DBT_STMT);
   }
*/

   if (array_no > 0) {
      for (n = 0; n < stmt->col_count; n ++) {
         stmt->ird->coldat[n].bound = 1;
         stmt->ird->coldat[n].pdata = ((char *) stmt->ird->coldat0[n].pdata) + (array_no * stmt->ird->row_array_element_size);
         stmt->ird->coldat[n].pactlen = (int *) ((char *) stmt->ird->coldat0[n].pactlen + (array_no * stmt->ird->row_array_element_size));
/*
         {
            char buffer[256];
            sprintf(buffer, "SQLFetchEx: stmt_no=%d; array_no=%d; n=%d; stmt->ird->coldat0[n].pdata=%p; stmt->coldat[n].pdata=%p; stmt->coldat[n].pactlen=%p;", stmt->stmt_no, array_no, n, stmt->ird->coldat0[n].pdata, stmt->ird->coldat[n].pdata, stmt->ird->coldat[n].pactlen);
            mg_log_event(buffer, "SQLFetchSEx : Column", 0, (void *) stmt, MG_DBT_STMT);
         }
*/
      }
   }

   phase = 2;

   rhead.cmnd = 'f';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = 0;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLFetchScroll");
      return SQL_ERROR;
   }

   phase = 3;

   if (p_block->eod) {
      stmt->eod = 1;
      SQLFetchExResetCols(stmt, dbc, env, FetchOrientation, FetchOffset, array_no);
      ret = SQL_NO_DATA_FOUND;
      return ret;
   }

   if (stmt->ird->row_array_size) {
      *(stmt->ird->p_rows_fetched) = (SQLUINTEGER) array_no + 1;
      stmt->ird->p_row_array_status[array_no] = (SQLUSMALLINT) 0;
   }

   phase = 4;

   p = p_block->pdata;
   for (n = 0; n < stmt->ird->col_count; n ++) {

      phase = 5;
      len = mg_dsize(p, 4, MG_SIZE_BASE);
{
   char buffer[256];
   sprintf(buffer, "SQLFetchEx: eod=%d; n=%d; stmt->ird->col_count=%d; len=%d; type=%d; bound=%d;", p_block->eod, n, stmt->ird->col_count, len, stmt->ird->coldat[n].type, stmt->ird->coldat[n].bound);
   mg_log_buffer(p, (len + 4), buffer, 0, (void *) stmt, MG_DBT_STMT);
}

      p += 4;

      if (len >= stmt->ird->coldat[n].rdata_size) {
         stmt->ird->coldat[n].rdata_size = len + 32;
         if (stmt->ird->coldat[n].rdata_size < 256) {
            stmt->ird->coldat[n].rdata_size = 256;
         }
         stmt->ird->coldat[n].rdata = (char *) malloc(sizeof(char) * (stmt->ird->coldat[n].rdata_size + 2));
      }

      if (!stmt->ird->coldat[n].type) {
         stmt->ird->coldat[n].type = SQL_C_CHAR;
      }

      strncpy(stmt->ird->coldat[n].rdata, p, len);
      stmt->ird->coldat[n].rdata[len] = '\0';

      if (stmt->ird->coldat[n].type == SQL_C_CHAR) {
         phase = 6;
         if (stmt->ird->coldat[n].bound) {
            phase = 61;
            strcpy((char *) stmt->ird->coldat[n].pdata, (char *) stmt->ird->coldat[n].rdata);
            phase = 62;
            *(stmt->ird->coldat[n].pactlen) = len;
         }
         else {
            phase = 63;
            stmt->ird->coldat[n].data.str = (char *) stmt->ird->coldat[n].rdata;
            phase = 64;
            stmt->ird->coldat[n].pactlen = &(stmt->ird->coldat[n].actlen);
            phase = 65;
            *(stmt->ird->coldat[n].pactlen) = len;
         }
      }
      else { /* SQL_C_SHORT SQL_C_LONG */
         phase = 7;
         if (stmt->ird->coldat[n].bound) {
            *(DWORD *) (stmt->ird->coldat[n].pdata) = (int) strtol(stmt->ird->coldat[n].rdata, NULL, 10);
            *(stmt->ird->coldat[n].pactlen) = sizeof(SQLUINTEGER);
         }
         else {
            stmt->ird->coldat[n].data.sint = (int) strtol(stmt->ird->coldat[n].rdata, NULL, 10);
            stmt->ird->coldat[n].actlen = sizeof(SQLUINTEGER);
         }
      }

      p += len;

      phase = 8;
   }

   phase = 99;

   return ret;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFetchEx(): %x:%d", code, phase);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


SQLRETURN SQL_API SQLFetchExResetCols(STMT *stmt, DBC *dbc, ENV *env, SQLSMALLINT FetchOrientation, SQLLEN FetchOffset, SQLUINTEGER array_no)
{
   short phase;
   SQLRETURN ret;
   int n, len;

   phase = 0;

#ifdef _WIN32
__try {
#endif

   ret = SQL_SUCCESS;

   for (n = 0; n < stmt->ird->col_count; n ++) {

      len = 0;

      if (len >= stmt->ird->coldat[n].rdata_size) {
         stmt->ird->coldat[n].rdata_size = len + 32;
         if (stmt->ird->coldat[n].rdata_size < 256) {
            stmt->ird->coldat[n].rdata_size = 256;
         }
         stmt->ird->coldat[n].rdata = (char *) malloc(sizeof(char) * (stmt->ird->coldat[n].rdata_size + 2));
         strcpy(stmt->ird->coldat[n].rdata, "");
      }

      if (!stmt->ird->coldat[n].type) {
         stmt->ird->coldat[n].type = SQL_C_CHAR;
      }

      strcpy(stmt->ird->coldat[n].rdata, "");

      if (stmt->ird->coldat[n].type == SQL_C_CHAR) {
         phase = 6;
         if (stmt->ird->coldat[n].bound) {
            phase = 61;
            strcpy((char *) stmt->ird->coldat[n].pdata, (char *) "");
            phase = 62;
            *(stmt->ird->coldat[n].pactlen) = len;
         }
         else {
            phase = 63;
            stmt->ird->coldat[n].data.str = (char *) stmt->ird->coldat[n].rdata;
            phase = 64;
            stmt->ird->coldat[n].pactlen = &(stmt->ird->coldat[n].actlen);
            phase = 65;
            *(stmt->ird->coldat[n].pactlen) = len;
         }
      }
      else { /* SQL_C_SHORT SQL_C_LONG */
         phase = 7;
         if (stmt->ird->coldat[n].bound) {
            *(DWORD *) (stmt->ird->coldat[n].pdata) = (int) strtol(stmt->ird->coldat[n].rdata, NULL, 10);
            *(stmt->ird->coldat[n].pactlen) = sizeof(SQLUINTEGER);
         }
         else {
            stmt->ird->coldat[n].data.sint = (int) strtol(stmt->ird->coldat[n].rdata, NULL, 10);
            stmt->ird->coldat[n].actlen = sizeof(SQLUINTEGER);
         }
      }

      phase = 8;
   }

   return ret;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLFetchExResetCols(): %x:%d", code, phase);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}



/* This fetchs a block of data (rowset). */
/* *** Deprecated *** */
#if 0
SQLRETURN SQL_API SQLExtendedFetch(SQLHSTMT StatementHandle, SQLUSMALLINT FetchOrientation, SQLINTEGER FetchOffset, SQLULEN * RowCountPtr, SQLUSMALLINT * RowStatusArray)
{

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLExtendedFetch", 0, NULL, 0);
   }

   return SQL_SUCCESS;
#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLExtendedFetch(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif
}
#endif


/* Returns result data for a single column in the current row. */
SQLRETURN SQL_API SQLGetData(SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLSMALLINT TargetType, SQLPOINTER TargetValuePtr, SQLLEN BufferLength, SQLLEN * StrLen)
{
   int n;
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "ColumnNumber=%d; TargetType=%d (%s); BufferLength=%d; bound=%d; %d %s", (int) ColumnNumber, (int) TargetType, mg_ctype_str((int) TargetType), (int) BufferLength, stmt->ird->coldat[ColumnNumber - 1].bound, stmt->ird->coldat[ColumnNumber - 1].actlen, stmt->ird->coldat[ColumnNumber - 1].rdata);
      mg_log_event(buffer, "SQLGetData", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (ColumnNumber <= stmt->ird->col_count) {
      n = (ColumnNumber - 1);
      stmt->ird->coldat[n].type = (int) TargetType;

      if (stmt->ird->coldat[n].type == SQL_C_CHAR) {
         int *plen;
         char *pstr;

         if (stmt->ird->coldat[n].bound) {
            pstr = (char *) stmt->ird->coldat[n].pdata;
            plen = stmt->ird->coldat[n].pactlen;
         }
         else {
            pstr = (char *) stmt->ird->coldat[n].rdata;
            plen = &(stmt->ird->coldat[n].actlen);
         }

         strcpy((char *) TargetValuePtr, pstr);
         *StrLen = *plen;
      }
      else { /* SQL_C_SHORT SQL_C_LONG */
         if (stmt->ird->coldat[n].bound) {
            *(DWORD *) (TargetValuePtr) = *(DWORD *) (stmt->ird->coldat[n].pdata);
         }
         else {
            *(DWORD *) (TargetValuePtr) = (int) strtol(stmt->ird->coldat[n].rdata, NULL, 10);
         }
      }
   }


/*
   sprintf((char *) TargetValuePtr, "rc=%d;col=%d", stmt->row_count, ColumnNumber);
   *StrLen = strlen((char *) TargetValuePtr);
   TargetType = SQL_C_CHAR;
*/

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetData(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* This determines whether there are more results sets available for the "hstmt". */
SQLRETURN SQL_API SQLMoreResults(SQLHSTMT StatementHandle)
{
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event( "", "SQLMoreResults", 0, (void *) stmt, MG_DBT_STMT);
   }

/*
   if (stmt->row_count > 3)
      return SQL_NO_DATA_FOUND;
   else
      return SQL_SUCCESS;
*/

return SQL_NO_DATA_FOUND;

   if (stmt->status == 0)
      return SQL_NO_DATA_FOUND;

   if (stmt->eod)
      return SQL_NO_DATA_FOUND;
   else
      return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLMoreResults(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif


}


/* This returns the number of rows associated with the database attached to "hstmt". */
SQLRETURN SQL_API SQLRowCount(SQLHSTMT StatementHandle, SQLLEN * RowCountPtr)
{
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
      char buffer[256];
      sprintf(buffer, "stmt_no=%d; col_count=%d;", stmt->stmt_no, stmt->ird->col_count);
      mg_log_event(buffer, "SQLRowCount", 0, (void *) stmt, MG_DBT_STMT);
   }

   *RowCountPtr = (SQLLEN) stmt->ird->col_count;

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLRowCount(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* This positions the cursor within a block of data. */
SQLRETURN SQL_API SQLSetPos(SQLHSTMT StatementHandle, SQLSETPOSIROW  RowNumber, SQLUSMALLINT Operation, SQLUSMALLINT LockType)
{
   STMT * stmt = (STMT *) StatementHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLSetPos", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetPos(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Returns the next SQL error information. */
/* *** Deprecated *** */
#if 0
RETCODE SQL_API SQLError(HENV henv, HDBC hdbc, HSTMT hstmt, UCHAR * szSqlState, SDWORD * pfNativeError, UCHAR  * szErrorMsg, SWORD cbErrorMsgMax, SWORD    *pcbErrorMsg)
{
   //int elen;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLError", 0, NULL, 0);
   }

   *pfNativeError = (SDWORD) 0;
   szErrorMsg[0] = '\0';
   *pcbErrorMsg = 0;
   return SQL_NO_DATA_FOUND;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLError(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif
}
#endif
