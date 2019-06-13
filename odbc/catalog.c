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

/* Have DBMS set up result set of Tables. */
SQLRETURN SQL_API SQLTables(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      TableName,
   SQLSMALLINT    NameLength3,
   SQLCHAR *      TableType,
   SQLSMALLINT    NameLength4)
{
   int n, len;
   unsigned char cat_name[256], schema_name[256], table_name[256], table_type[256], buffer[1024];
   RECHEAD rhead;
   DBLK *p_block;
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(table_name, 256, TableName, NameLength3);
   mg_cbuffer(table_type, 256, TableType, NameLength4);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf((char *) buffer, "CatalogName=%s(%d); SchemaName=%s(%d); TableName=%s(%d); TableType=%s(%d);", cat_name, NameLength1, schema_name, NameLength2, table_name, NameLength3, table_type, NameLength4);
      mg_log_event((char *) buffer, "SQLTables", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (cat_name[0] == '%') {
      mg_set_error(&stmt->error, "HYC00", 0, "Driver not capable", "SQLTables");
      return SQL_ERROR;
   }

/*
   if (cat_name[0] == '%') {
      mg_set_error(&stmt->error, "S1C00", 0, "Driver not capable", "SQLTables");
      return SQL_ERROR;
   }
   if (schema_name[0] == '%') {
      mg_set_error(&stmt->error, "S1C00", 0, "Driver not capable", "SQLTables");
      return SQL_ERROR;
   }
*/
   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf((char *) buffer + MG_HEAD_SIZE, "CatalogName=%s\r\nSchemaName=%s\r\nTableName=%s\r\nTableType=%s\r\n\r\n", cat_name, schema_name, table_name, table_type);
   len = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 't';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, (char *) buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLTables");
      return SQL_ERROR;
   }

   n = mg_get_cols(stmt, p_block->pdata);

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLTables(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of Columns. */
SQLRETURN SQL_API SQLColumns(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      TableName,
   SQLSMALLINT    NameLength3,
   SQLCHAR *      ColumnName,
   SQLSMALLINT    NameLength4)
{
   int n, len;
   unsigned char cat_name[256], schema_name[256], table_name[256], col_name[256], buffer[1024];
   RECHEAD rhead;
   DBLK *p_block;
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(table_name, 256, TableName, NameLength3);
   mg_cbuffer(col_name, 256, ColumnName, NameLength4);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf((char *) buffer, "CatalogName=%s; SchemaName=%s; TableName=%s; ColumnName=%s;", cat_name, schema_name, table_name, col_name);
      mg_log_event((char *) buffer, "SQLColumns", 0, (void *) stmt, MG_DBT_STMT);
   }

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf((char *) buffer + MG_HEAD_SIZE, "CatalogName=%s\r\nSchemaName=%s\r\nTableName=%s\r\nColumnName=%s\r\n\r\n", cat_name, schema_name, table_name, col_name);
   len = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 'h';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, (char *) buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLColumns");
      return SQL_ERROR;
   }

   n = mg_get_cols(stmt, p_block->pdata);

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLColumns(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of Statistics. */
SQLRETURN SQL_API SQLStatistics(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      TableName,
   SQLSMALLINT    NameLength3,
   SQLUSMALLINT   Unique,
   SQLUSMALLINT   Reserved)
{

   int n, len;
   unsigned char cat_name[256], schema_name[256], table_name[256], buffer[1024];
   RECHEAD rhead;
   DBLK *p_block;
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(table_name, 256, TableName, NameLength3);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "CatalogName=%s; SchemaName=%s; TableName=%s; Unique=%d", cat_name, schema_name, table_name, Unique);
      mg_log_event(buffer, "SQLStatistics", 0, (void *) stmt, MG_DBT_STMT);
   }

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf((char *) buffer + MG_HEAD_SIZE, "CatalogName=%s\r\nSchemaName=%s\r\nTableName=%s\r\nUnique=%d\r\n\r\n", cat_name, schema_name, table_name, Unique);
   len = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 'n';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, (char *) buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLStatistics");
      return SQL_ERROR;
   }

   n = mg_get_cols(stmt, p_block->pdata);

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLStatistics(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of TablePrivileges. */
SQLRETURN SQL_API SQLTablePrivileges(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      TableName,
   SQLSMALLINT    NameLength3)
{
   unsigned char cat_name[256], schema_name[256], table_name[256]; //, buffer[1024];
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(table_name, 256, TableName, NameLength3);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "CatalogName=%s; SchemaName=%s; TableName=%s;", cat_name, schema_name, table_name);
      mg_log_event(buffer, "SQLTablePrivileges", 0, (void *) stmt, MG_DBT_STMT);
   }
   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLTablePrivileges(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of ColumnPrivileges. */
SQLRETURN SQL_API SQLColumnPrivileges(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      TableName,
   SQLSMALLINT    NameLength3,
   SQLCHAR *      ColumnName,
   SQLSMALLINT    NameLength4)
{
   unsigned char cat_name[256], schema_name[256], table_name[256], col_name[256]; //, buffer[1024];
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(table_name, 256, TableName, NameLength3);
   mg_cbuffer(col_name, 256, ColumnName, NameLength4);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "CatalogName=%s; SchemaName=%s; TableName=%s; ColumnName=%s;", cat_name, schema_name, table_name, col_name);
      mg_log_event(buffer, "SQLColumnPrivileges", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLColumnPrivileges(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of SpecialColumns. */

SQLRETURN SQL_API SQLSpecialColumns(
   SQLHSTMT       StatementHandle,
   SQLUSMALLINT   IdentifierType,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      TableName,
   SQLSMALLINT    NameLength3,
   SQLUSMALLINT   Scope,
   SQLUSMALLINT   Nullable)
{

   unsigned char cat_name[256], schema_name[256], table_name[256]; //, buffer[1024];
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(table_name, 256, TableName, NameLength3);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "CatalogName=%s; SchemaName=%s; TableName=%s;", cat_name, schema_name, table_name);
      mg_log_event(buffer, "SQLSpecialColumns", 0, (void *) stmt, MG_DBT_STMT);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSpecialColumns(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of PrimaryKeys. */
SQLRETURN SQL_API SQLPrimaryKeys(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      TableName,
   SQLSMALLINT    NameLength3)
{
   int n, len;
   unsigned char cat_name[256], schema_name[256], table_name[256], buffer[1024];
   RECHEAD rhead;
   DBLK *p_block;
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(table_name, 256, TableName, NameLength3);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "CatalogName=%s; SchemaName=%s; TableName=%s;", cat_name, schema_name, table_name);
      mg_log_event(buffer, "SQLPrimaryKeys", 0, (void *) stmt, MG_DBT_STMT);
   }

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf((char *) buffer + MG_HEAD_SIZE, "CatalogName=%s\r\nSchemaName=%s\r\nTableName=%s\r\n\r\n", cat_name, schema_name, table_name);
   len = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 'k';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, (char *) buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLPrimaryKeys");
      return SQL_ERROR;
   }

   n = mg_get_cols(stmt, p_block->pdata);

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLPrimaryKeys(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of ForeignKeys. */
SQLRETURN SQL_API SQLForeignKeys(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      PKCatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      PKSchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      PKTableName,
   SQLSMALLINT    NameLength3,
   SQLCHAR *      FKCatalogName,
   SQLSMALLINT    NameLength4,
   SQLCHAR *      FKSchemaName,
   SQLSMALLINT    NameLength5,
   SQLCHAR *      FKTableName,
   SQLSMALLINT    NameLength6)
{
   int n, len;
   unsigned char pk_cat_name[256], pk_schema_name[256], pk_table_name[256], fk_cat_name[256], fk_schema_name[256], fk_table_name[256], buffer[1024];
   RECHEAD rhead;
   DBLK *p_block;
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

   mg_cbuffer(pk_cat_name, 256, PKCatalogName, NameLength1);
   mg_cbuffer(pk_schema_name, 256, PKSchemaName, NameLength2);
   mg_cbuffer(pk_table_name, 256, PKTableName, NameLength3);
   mg_cbuffer(fk_cat_name, 256, FKCatalogName, NameLength4);
   mg_cbuffer(fk_schema_name, 256, FKSchemaName, NameLength5);
   mg_cbuffer(fk_table_name, 256, FKTableName, NameLength6);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "PKCatalogName=%s; PKSchemaName=%s; PKTableName=%s; FKCatalogName=%s; FKSchemaName=%s; FKTableName=%s;", pk_cat_name, pk_schema_name, pk_table_name, fk_cat_name, fk_schema_name, fk_table_name);
      mg_log_event(buffer, "SQLForeignKeys", 0, (void *) stmt, MG_DBT_STMT);
   }

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf((char *) buffer + MG_HEAD_SIZE, "PKCatalogName=%s\r\nPKSchemaName=%s\r\nPKTableName=%s\r\nFKCatalogName=%s\r\nFKSchemaName=%s\r\nFKTableName=%s\r\n", pk_cat_name, pk_schema_name, pk_table_name, fk_cat_name, fk_schema_name, fk_table_name);
   len = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 'm';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, (char *) buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLForeignKeys");
      return SQL_ERROR;
   }

   n = mg_get_cols(stmt, p_block->pdata);


   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLForeignKeys(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of Procedures. */

SQLRETURN SQL_API SQLProcedures(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      ProcName,
   SQLSMALLINT    NameLength3)
{
   int n, len;
   unsigned char cat_name[256], schema_name[256], proc_name[256], buffer[1024];
   RECHEAD rhead;
   DBLK *p_block;
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(proc_name, 256, ProcName, NameLength3);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "CatalogName=%s; SchemaName=%s; ProcName=%s;", cat_name, schema_name, proc_name);
      mg_log_event(buffer, "SQLProcedures", 0, (void *) stmt, MG_DBT_STMT);
   }

   if (cat_name[0] == '%') {
      mg_set_error(&stmt->error, "HYC00", 0, "Driver not capable", "SQLProcedures");
      return SQL_ERROR;
   }

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf((char *) buffer + MG_HEAD_SIZE, "CatalogName=%s\r\nSchemaName=%s\r\nProcName=%s\r\n\r\n", cat_name, schema_name, proc_name);
   len = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 'p';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, (char *) buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLProcedures");
      return SQL_ERROR;
   }

   n = mg_get_cols(stmt, p_block->pdata);

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLProcedures(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}


/* Have DBMS set up result set of ProcedureColumns. */
SQLRETURN SQL_API SQLProcedureColumns(
   SQLHSTMT       StatementHandle,
   SQLCHAR *      CatalogName,
   SQLSMALLINT    NameLength1,
   SQLCHAR *      SchemaName,
   SQLSMALLINT    NameLength2,
   SQLCHAR *      ProcName,
   SQLSMALLINT    NameLength3,
   SQLCHAR *      ColumnName,
   SQLSMALLINT    NameLength4)
{
   int n, len;
   unsigned char cat_name[256], schema_name[256], proc_name[256], col_name[256], buffer[1024];
   RECHEAD rhead;
   DBLK *p_block;
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

   mg_cbuffer(cat_name, 256, CatalogName, NameLength1);
   mg_cbuffer(schema_name, 256, SchemaName, NameLength2);
   mg_cbuffer(proc_name, 256, ProcName, NameLength3);
   mg_cbuffer(col_name, 256, ColumnName, NameLength4);

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "CatalogName=%s; SchemaName=%s; ProcName=%s; ColumnName=%s;", cat_name, schema_name, proc_name, col_name);
      mg_log_event(buffer, "SQLProcedureColumns", 0, (void *) stmt, MG_DBT_STMT);
   }

  if (cat_name[0] == '%') {
      mg_set_error(&stmt->error, "HYC00", 0, "Driver not capable", "SQLProcedureColumns");
      return SQL_ERROR;
   }

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf((char *) buffer + MG_HEAD_SIZE, "CatalogName=%s\r\nSchemaName=%s\r\nProcName=%s\r\nColumnName=%s\r\n\r\n", cat_name, schema_name, proc_name, col_name);
   len = (int) strlen((char *) buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 'q';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, (char *) buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, (char *) buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLProcedureColumns");
      return SQL_ERROR;
   }

   n = mg_get_cols(stmt, p_block->pdata);

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLProcedureColumns(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return SQL_ERROR;
}
#endif

}
