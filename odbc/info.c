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
#include <string.h>

#define MG_NAME_LEN                 256
#define MG_USERNAME_LENGTH          256
#define MG_FLAG_DYNAMIC_CURSOR	   32                   /* Enables the dynamic cursor */
#define MG_SQL_MAX_CURSOR_LEN       18                   /* Max cursor name length */
#define MG_FLAG_NO_DEFAULT_CURSOR   128                  /* No default cursor */
#define MG_FLAG_SAFE                131072L              /* Try to be as safe as possible */
#define MG_FLAG_NO_CATALOG          32768                /* No catalog support */
#define MG_FLAG_NO_TRANSACTIONS     (MG_FLAG_SAFE << 1)  /* Disable transactions */
#define MG_FLAG_FORWARD_CURSOR      (MG_FLAG_SAFE << 4)  /* Force use of forward-only cursors */


/*
  List of functions supported in the driver.
*/
SQLUSMALLINT mgodbc3_functions[]=
{
   SQL_API_SQLALLOCCONNECT,
   SQL_API_SQLALLOCENV,
   SQL_API_SQLALLOCHANDLE,
   SQL_API_SQLALLOCSTMT,
   SQL_API_SQLBINDCOL,
   SQL_API_SQLBINDPARAM,
   SQL_API_SQLCANCEL,
   SQL_API_SQLCLOSECURSOR,
   SQL_API_SQLCOLATTRIBUTE,
   SQL_API_SQLCOLUMNS,
   SQL_API_SQLCONNECT,
   SQL_API_SQLCOPYDESC,
   SQL_API_SQLDATASOURCES,
   SQL_API_SQLDESCRIBECOL,
   SQL_API_SQLDISCONNECT,
   SQL_API_SQLENDTRAN,
   SQL_API_SQLERROR,
   SQL_API_SQLEXECDIRECT,
   SQL_API_SQLEXECUTE,
   SQL_API_SQLFETCH,
   SQL_API_SQLFETCHSCROLL,
   SQL_API_SQLFREECONNECT,
   SQL_API_SQLFREEENV,
   SQL_API_SQLFREEHANDLE,
   SQL_API_SQLFREESTMT,
   SQL_API_SQLGETCONNECTATTR,
   SQL_API_SQLGETCONNECTOPTION,
   SQL_API_SQLGETCURSORNAME,
   SQL_API_SQLGETDATA,
   SQL_API_SQLGETDESCFIELD,
   SQL_API_SQLGETDESCREC,
   SQL_API_SQLGETDIAGFIELD,
   SQL_API_SQLGETDIAGREC,
   SQL_API_SQLGETENVATTR,
   SQL_API_SQLGETFUNCTIONS,
   SQL_API_SQLGETINFO,
   SQL_API_SQLGETSTMTATTR,
   SQL_API_SQLGETSTMTOPTION,
   SQL_API_SQLGETTYPEINFO,
   SQL_API_SQLNUMRESULTCOLS,
   SQL_API_SQLPARAMDATA,
   SQL_API_SQLPREPARE,
   SQL_API_SQLPUTDATA,
   SQL_API_SQLROWCOUNT,
   SQL_API_SQLSETCONNECTATTR,
   SQL_API_SQLSETCONNECTOPTION,
   SQL_API_SQLSETCURSORNAME,
   SQL_API_SQLSETDESCFIELD,
   SQL_API_SQLSETDESCREC,
   SQL_API_SQLSETENVATTR,
   SQL_API_SQLSETPARAM,
   SQL_API_SQLSETSTMTATTR,
   SQL_API_SQLSETSTMTOPTION,
   SQL_API_SQLSPECIALCOLUMNS,
   SQL_API_SQLSTATISTICS,
   SQL_API_SQLTABLES,
   SQL_API_SQLTRANSACT,
   SQL_API_SQLALLOCHANDLESTD,
   SQL_API_SQLBULKOPERATIONS,
   SQL_API_SQLBINDPARAMETER,
   SQL_API_SQLBROWSECONNECT,
   SQL_API_SQLCOLATTRIBUTES,
   SQL_API_SQLCOLUMNPRIVILEGES ,
   SQL_API_SQLDESCRIBEPARAM,
   SQL_API_SQLDRIVERCONNECT,
   SQL_API_SQLDRIVERS,
   SQL_API_SQLEXTENDEDFETCH,
   SQL_API_SQLFOREIGNKEYS,
   SQL_API_SQLMORERESULTS,
   SQL_API_SQLNATIVESQL,
   SQL_API_SQLNUMPARAMS,
   SQL_API_SQLPARAMOPTIONS,
   SQL_API_SQLPRIMARYKEYS,
   SQL_API_SQLPROCEDURECOLUMNS,
   SQL_API_SQLPROCEDURES,
   SQL_API_SQLSETPOS,
   SQL_API_SQLSETSCROLLOPTIONS,
   SQL_API_SQLTABLEPRIVILEGES
};

int mg_is_odbc3_subclass(char *sqlstate);


SQLRETURN SQL_API SQLGetInfo(
   SQLHDBC        ConnectionHandle,
   SQLUSMALLINT   InfoType,
   SQLPOINTER     InfoValuePtr,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  StringLengthPtr)
{
   char *ptype;
   char buffer[256];
   DBC * dbc = (DBC *) ConnectionHandle;

#ifdef _WIN32
__try {
#endif

   ptype = NULL;
/*
   if (CoreData.ftrace == 1) {
      sprintf(buffer, "info requested: %d; BufferLength=%d; InfoValuePtr=%p", InfoType, BufferLength, InfoValuePtr);
      mg_log_event( buffer, "SQLGetInfo", 0, (void *) dbc, MG_DBT_DBC);
   }
*/
   switch (InfoType) {
      case SQL_ACTIVE_ENVIRONMENTS:
         ptype = "SQL_ACTIVE_ENVIRONMENTS";
         *(SWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_AGGREGATE_FUNCTIONS:
         ptype = "SQL_AGGREGATE_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_AF_ALL | SQL_AF_AVG | SQL_AF_COUNT | SQL_AF_DISTINCT | SQL_AF_MAX | SQL_AF_MIN | SQL_AF_SUM);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_ALTER_DOMAIN:
         ptype = "SQL_ALTER_DOMAIN";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_ALTER_TABLE:
         ptype = "SQL_ALTER_TABLE";
         /** @todo check if we should report more */
         *(DWORD *) InfoValuePtr = (SQL_AT_ADD_COLUMN | SQL_AT_DROP_COLUMN);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_ASYNC_MODE:
         ptype = "SQL_ASYNC_MODE";
         *(DWORD *) InfoValuePtr = (SQL_AM_NONE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_BATCH_ROW_COUNT:
         ptype = "SQL_BATCH_ROW_COUNT";
         *(DWORD *) InfoValuePtr = (SQL_BRC_EXPLICIT);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_BATCH_SUPPORT:
         ptype = "SQL_BATCH_SUPPORT";
         *(DWORD *) InfoValuePtr = (SQL_BS_SELECT_EXPLICIT | SQL_BS_ROW_COUNT_EXPLICIT | SQL_BS_SELECT_PROC | SQL_BS_ROW_COUNT_PROC);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_BOOKMARK_PERSISTENCE:
         ptype = "SQL_BOOKMARK_PERSISTENCE";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CATALOG_LOCATION:
         ptype = "SQL_CATALOG_LOCATION";
         *(SWORD *) InfoValuePtr = (SQL_CL_START);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_CATALOG_NAME:
         ptype = "SQL_CATALOG_NAME";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ((dbc->flag & MG_FLAG_NO_CATALOG) ? "" : "Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_CATALOG_NAME_SEPARATOR:
         ptype = "SQL_CATALOG_NAME_SEPARATOR";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ((dbc->flag & MG_FLAG_NO_CATALOG) ? "" : "."));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_CATALOG_TERM:
         ptype = "SQL_CATALOG_TERM";
         //lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ((dbc->flag & FLAG_NO_CATALOG) ? "" : "database"));
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("CATALOG"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_CATALOG_USAGE:
         ptype = "SQL_CATALOG_USAGE";
         *(DWORD *) InfoValuePtr = ((dbc->flag & MG_FLAG_NO_CATALOG) ?
                     (SQL_CU_DML_STATEMENTS | SQL_CU_PROCEDURE_INVOCATION |
                      SQL_CU_TABLE_DEFINITION | SQL_CU_INDEX_DEFINITION |
                      SQL_CU_PRIVILEGE_DEFINITION) :
                     0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_COLLATION_SEQ:
         ptype = "SQL_COLLATION_SEQ";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (dbc->mgsql.charset));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_COLUMN_ALIAS:
         ptype = "SQL_COLUMN_ALIAS";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_CONCAT_NULL_BEHAVIOR:
         ptype = "SQL_CONCAT_NULL_BEHAVIOR";
         *(SWORD *) InfoValuePtr = (SQL_CB_NULL);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_CONVERT_BIGINT:
         ptype = "SQL_CONVERT_BIGINT";
      case SQL_CONVERT_BIT:
         ptype = "SQL_CONVERT_BIT";
      case SQL_CONVERT_CHAR:
         ptype = "SQL_CONVERT_CHAR";
      case SQL_CONVERT_DATE:
         ptype = "SQL_CONVERT_DATE";
      case SQL_CONVERT_DECIMAL:
         ptype = "SQL_CONVERT_DECIMAL";
      case SQL_CONVERT_DOUBLE:
         ptype = "SQL_CONVERT_DOUBLE";
      case SQL_CONVERT_FLOAT:
         ptype = "SQL_CONVERT_FLOAT";
      case SQL_CONVERT_INTEGER:
         ptype = "SQL_CONVERT_INTEGER";
      case SQL_CONVERT_LONGVARCHAR:
         ptype = "SQL_CONVERT_LONGVARCHAR";
      case SQL_CONVERT_NUMERIC:
         ptype = "SQL_CONVERT_NUMERIC";
      case SQL_CONVERT_REAL:
         ptype = "SQL_CONVERT_REAL";
      case SQL_CONVERT_SMALLINT:
         ptype = "SQL_CONVERT_SMALLINT";
      case SQL_CONVERT_TIME:
         ptype = "SQL_CONVERT_TIME";
      case SQL_CONVERT_TIMESTAMP:
         ptype = "SQL_CONVERT_TIMESTAMP";
      case SQL_CONVERT_TINYINT:
         ptype = "SQL_CONVERT_TINYINT";
      case SQL_CONVERT_VARCHAR:
         ptype = "SQL_CONVERT_VARCHAR";
      case SQL_CONVERT_WCHAR:
         ptype = "SQL_CONVERT_WCHAR";
      case SQL_CONVERT_WVARCHAR:
         ptype = "SQL_CONVERT_WVARCHAR";
      case SQL_CONVERT_WLONGVARCHAR:
         ptype = "SQL_CONVERT_WLONGVARCHAR";
         *(DWORD *) InfoValuePtr = (SQL_CVT_CHAR | SQL_CVT_NUMERIC | SQL_CVT_DECIMAL |
                     SQL_CVT_INTEGER | SQL_CVT_SMALLINT | SQL_CVT_FLOAT |
                     SQL_CVT_REAL | SQL_CVT_DOUBLE | SQL_CVT_VARCHAR |
                     SQL_CVT_LONGVARCHAR | SQL_CVT_BIT | SQL_CVT_TINYINT |
                     SQL_CVT_BIGINT | SQL_CVT_DATE | SQL_CVT_TIME |
                     SQL_CVT_TIMESTAMP);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CONVERT_BINARY:
         ptype = "SQL_CONVERT_BINARY";
      case SQL_CONVERT_VARBINARY:
         ptype = "SQL_CONVERT_VARBINARY";
      case SQL_CONVERT_LONGVARBINARY:
         ptype = "SQL_CONVERT_LONGVARBINARY";
      case SQL_CONVERT_INTERVAL_DAY_TIME:
         ptype = "SQL_CONVERT_INTERVAL_DAY_TIME";
      case SQL_CONVERT_INTERVAL_YEAR_MONTH:
         ptype = "SQL_CONVERT_INTERVAL_YEAR_MONTH";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CONVERT_FUNCTIONS:
         ptype = "SQL_CONVERT_FUNCTIONS";
         /* MGSQL's CONVERT() and CAST() functions aren't SQL compliant yet. */
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CORRELATION_NAME:
         ptype = "SQL_CORRELATION_NAME";
         *(SWORD *) InfoValuePtr = (SQL_CN_DIFFERENT);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_CREATE_ASSERTION:
         ptype = "SQL_CREATE_ASSERTION";
      case SQL_CREATE_CHARACTER_SET:
         ptype = "SQL_CREATE_CHARACTER_SET";
      case SQL_CREATE_COLLATION:
         ptype = "SQL_CREATE_COLLATION";
      case SQL_CREATE_DOMAIN:
         ptype = "SQL_CREATE_DOMAIN";
      case SQL_CREATE_SCHEMA:
         ptype = "SQL_CREATE_SCHEMA";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CREATE_TABLE:
         ptype = "SQL_CREATE_SCHEMA";
         *(DWORD *) InfoValuePtr = (SQL_CT_CREATE_TABLE | SQL_CT_COMMIT_DELETE |
                     SQL_CT_LOCAL_TEMPORARY | SQL_CT_COLUMN_DEFAULT |
                     SQL_CT_COLUMN_COLLATION);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CREATE_TRANSLATION:
         ptype = "SQL_CREATE_TRANSLATION";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CREATE_VIEW:
         ptype = "SQL_CREATE_VIEW";
         *(DWORD *) InfoValuePtr = (SQL_CV_CREATE_VIEW | SQL_CV_CHECK_OPTION | SQL_CV_CASCADED);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_CURSOR_COMMIT_BEHAVIOR:
         ptype = "SQL_CURSOR_COMMIT_BEHAVIOR";
      case SQL_CURSOR_ROLLBACK_BEHAVIOR:
         ptype = "SQL_CURSOR_ROLLBACK_BEHAVIOR";
         *(SWORD *) InfoValuePtr = (SQL_CB_PRESERVE);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
#ifdef SQL_CURSOR_SENSITIVITY
      case SQL_CURSOR_SENSITIVITY:
         ptype = "SQL_CURSOR_SENSITIVITY";
         *(DWORD *) InfoValuePtr = (SQL_UNSPECIFIED);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
#endif
#ifdef SQL_CURSOR_ROLLBACK_SQL_CURSOR_SENSITIVITY
      case SQL_CURSOR_ROLLBACK_SQL_CURSOR_SENSITIVITY:
         ptype = "SQL_CURSOR_ROLLBACK_SQL_CURSOR_SENSITIVITY";
         *(DWORD *) InfoValuePtr = (SQL_UNSPECIFIED);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
#endif
      case SQL_DATA_SOURCE_NAME:
         ptype = "SQL_DATA_SOURCE_NAME";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (dbc->dsn));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DATA_SOURCE_READ_ONLY:
         ptype = "SQL_DATA_SOURCE_READ_ONLY";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("N"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DATABASE_NAME:
         ptype = "SQL_DATABASE_NAME";
/*
         if (is_connected(dbc) && reget_current_catalog(dbc))
            return set_dbc_error(dbc, "HY000", "SQLGetInfo() failed to return current catalog.",0);
*/
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (dbc->uci));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DATETIME_LITERALS:
         ptype = "SQL_DATETIME_LITERALS";
         *(DWORD *) InfoValuePtr = (SQL_DL_SQL92_DATE | SQL_DL_SQL92_TIME | SQL_DL_SQL92_TIMESTAMP);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_DBMS_NAME:
         ptype = "SQL_DBMS_NAME";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("MGSQL"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DBMS_VER:
         ptype = "SQL_DBMS_VER";
         /* technically this is not right: should be ##.##.#### */
         sprintf(buffer, "%s v%d.%d.%d; MGSQL v%s;", dbc->mgsql.zv.short_name, dbc->mgsql.zv.majorversion, dbc->mgsql.zv.minorversion, dbc->mgsql.zv.sys_build, dbc->mgsql.server_version);
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (buffer));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DDL_INDEX:
         ptype = "SQL_DDL_INDEX";
         *(DWORD *) InfoValuePtr = (SQL_DI_CREATE_INDEX | SQL_DI_DROP_INDEX);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_DEFAULT_TXN_ISOLATION:
         ptype = "SQL_DEFAULT_TXN_ISOLATION";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_DESCRIBE_PARAMETER:
         ptype = "SQL_DESCRIBE_PARAMETER";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("N"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DRIVER_NAME:
         ptype = "SQL_DRIVER_NAME";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (dbc->driver));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DRIVER_ODBC_VER:
         ptype = "SQL_DRIVER_ODBC_VER";
         //lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (SQL_SPEC_STRING));
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("03.51"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DRIVER_VER:
         ptype = "SQL_DRIVER_VER";
         sprintf(buffer, "%02d.%02d.%04d", MG_VERSION_MAJOR, MG_VERSION_MINOR, MG_VERSION_BUILD);
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (buffer));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_DROP_ASSERTION:
         ptype = "SQL_DROP_ASSERTION";
      case SQL_DROP_CHARACTER_SET:
         ptype = "SQL_DROP_CHARACTER_SET";
      case SQL_DROP_COLLATION:
         ptype = "SQL_DROP_COLLATION";
      case SQL_DROP_DOMAIN:
         ptype = "SQL_DROP_DOMAIN";
      case SQL_DROP_SCHEMA:
         ptype = "SQL_DROP_SCHEMA";
      case SQL_DROP_TRANSLATION:
         ptype = "SQL_DROP_TRANSLATION";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_DROP_TABLE:
         ptype = "SQL_DROP_TABLE";
         *(DWORD *) InfoValuePtr = (SQL_DT_DROP_TABLE | SQL_DT_CASCADE | SQL_DT_RESTRICT);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_DROP_VIEW:
         ptype = "SQL_DROP_VIEW";
         *(DWORD *) InfoValuePtr = (SQL_DV_DROP_VIEW | SQL_DV_CASCADE | SQL_DV_RESTRICT);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_DYNAMIC_CURSOR_ATTRIBUTES1:
         ptype = "SQL_DYNAMIC_CURSOR_ATTRIBUTES1";
         *(DWORD *) InfoValuePtr = (SQL_CA1_NEXT | SQL_CA1_ABSOLUTE | SQL_CA1_RELATIVE |
                       SQL_CA1_LOCK_NO_CHANGE | SQL_CA1_POS_POSITION |
                       SQL_CA1_POS_UPDATE | SQL_CA1_POS_DELETE |
                       SQL_CA1_POS_REFRESH | SQL_CA1_POSITIONED_UPDATE |
                       SQL_CA1_POSITIONED_DELETE | SQL_CA1_BULK_ADD);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_DYNAMIC_CURSOR_ATTRIBUTES2:
         ptype = "SQL_DYNAMIC_CURSOR_ATTRIBUTES2";
         *(DWORD *) InfoValuePtr = (SQL_CA2_SENSITIVITY_ADDITIONS |
                       SQL_CA2_SENSITIVITY_DELETIONS |
                       SQL_CA2_SENSITIVITY_UPDATES |
                       SQL_CA2_MAX_ROWS_SELECT | SQL_CA2_MAX_ROWS_INSERT |
                       SQL_CA2_MAX_ROWS_DELETE | SQL_CA2_MAX_ROWS_UPDATE |
                       SQL_CA2_CRC_EXACT | SQL_CA2_SIMULATE_TRY_UNIQUE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_EXPRESSIONS_IN_ORDERBY:
         ptype = "SQL_EXPRESSIONS_IN_ORDERBY";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_FILE_USAGE:
         ptype = "SQL_FILE_USAGE";
         *(SWORD *) InfoValuePtr = (SQL_FILE_NOT_SUPPORTED);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1:
         ptype = "SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1";
         *(DWORD *) InfoValuePtr = ((dbc->flag & MG_FLAG_FORWARD_CURSOR) ?
                     SQL_CA1_NEXT :
                     SQL_CA1_NEXT | SQL_CA1_ABSOLUTE | SQL_CA1_RELATIVE |
                     SQL_CA1_LOCK_NO_CHANGE | SQL_CA1_POS_POSITION |
                     SQL_CA1_POS_UPDATE | SQL_CA1_POS_DELETE |
                     SQL_CA1_POS_REFRESH | SQL_CA1_POSITIONED_UPDATE |
                     SQL_CA1_POSITIONED_DELETE | SQL_CA1_BULK_ADD);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2:
         ptype = "SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2";
         *(DWORD *) InfoValuePtr = (SQL_CA2_MAX_ROWS_SELECT | SQL_CA2_MAX_ROWS_INSERT |
                     SQL_CA2_MAX_ROWS_DELETE | SQL_CA2_MAX_ROWS_UPDATE |
                     ((dbc->flag & MG_FLAG_FORWARD_CURSOR) ?
                      0 : SQL_CA2_CRC_EXACT));
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_GETDATA_EXTENSIONS:
         ptype = "SQL_GETDATA_EXTENSIONS";
         *(DWORD *) InfoValuePtr = (SQL_GD_ANY_COLUMN | SQL_GD_ANY_ORDER | SQL_GD_BLOCK | SQL_GD_BOUND);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_GROUP_BY:
         ptype = "SQL_GROUP_BY";
         *(SWORD *) InfoValuePtr = (SQL_GB_NO_RELATION);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_IDENTIFIER_CASE:
         ptype = "SQL_IDENTIFIER_CASE";
         *(SWORD *) InfoValuePtr = (SQL_IC_MIXED);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_IDENTIFIER_QUOTE_CHAR:
         ptype = "SQL_IDENTIFIER_QUOTE_CHAR";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("`"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_INDEX_KEYWORDS:
         ptype = "SQL_INDEX_KEYWORDS";
         *(DWORD *) InfoValuePtr = (SQL_IK_ALL);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_INFO_SCHEMA_VIEWS:
         *(DWORD *) InfoValuePtr = (SQL_ISV_CHARACTER_SETS | SQL_ISV_COLLATIONS |
                       SQL_ISV_COLUMN_PRIVILEGES | SQL_ISV_COLUMNS |
                       SQL_ISV_KEY_COLUMN_USAGE |
                       SQL_ISV_REFERENTIAL_CONSTRAINTS |
                       /* SQL_ISV_SCHEMATA | */ SQL_ISV_TABLE_CONSTRAINTS |
                       SQL_ISV_TABLE_PRIVILEGES | SQL_ISV_TABLES |
                       SQL_ISV_VIEWS);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_INSERT_STATEMENT:
         ptype = "SQL_INSERT_STATEMENT";
         *(DWORD *) InfoValuePtr = (SQL_IS_INSERT_LITERALS | SQL_IS_INSERT_SEARCHED | SQL_IS_SELECT_INTO);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_INTEGRITY:
         ptype = "SQL_INTEGRITY";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("N"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_KEYSET_CURSOR_ATTRIBUTES1:
         ptype = "SQL_KEYSET_CURSOR_ATTRIBUTES1";
      case SQL_KEYSET_CURSOR_ATTRIBUTES2:
         ptype = "SQL_KEYSET_CURSOR_ATTRIBUTES2";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_KEYWORDS:
         ptype = "SQL_KEYWORDS";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (""));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_LIKE_ESCAPE_CLAUSE:
         ptype = "SQL_LIKE_ESCAPE_CLAUSE";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_MAX_ASYNC_CONCURRENT_STATEMENTS:
         ptype = "SQL_MAX_ASYNC_CONCURRENT_STATEMENTS";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_MAX_BINARY_LITERAL_LEN:
         ptype = "SQL_MAX_BINARY_LITERAL_LEN";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_MAX_CATALOG_NAME_LEN:
         ptype = "SQL_MAX_CATALOG_NAME_LEN";
         *(SWORD *) InfoValuePtr = (MG_NAME_LEN);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_CHAR_LITERAL_LEN:
         ptype = "SQL_MAX_CHAR_LITERAL_LEN";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_MAX_COLUMN_NAME_LEN:
         ptype = "SQL_MAX_COLUMN_NAME_LEN";
         *(SWORD *) InfoValuePtr = (MG_NAME_LEN);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_COLUMNS_IN_GROUP_BY:
         ptype = "SQL_MAX_COLUMNS_IN_GROUP_BY";
         *(SWORD *) InfoValuePtr = (0); /* No specific limit */
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_COLUMNS_IN_INDEX:
         ptype = "SQL_MAX_COLUMNS_IN_INDEX";
         *(SWORD *) InfoValuePtr = (32);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_COLUMNS_IN_ORDER_BY:
         ptype = "SQL_MAX_COLUMNS_IN_ORDER_BY";
         *(SWORD *) InfoValuePtr = (0); /* No specific limit */
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_COLUMNS_IN_SELECT:
         ptype = "SQL_MAX_COLUMNS_IN_SELECT";
         *(SWORD *) InfoValuePtr = (0); /* No specific limit */
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_COLUMNS_IN_TABLE:
         ptype = "SQL_MAX_COLUMNS_IN_TABLE";
         *(SWORD *) InfoValuePtr = (0); /* No specific limit */
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_CONCURRENT_ACTIVITIES:
         ptype = "SQL_MAX_CONCURRENT_ACTIVITIES";
         *(SWORD *) InfoValuePtr = (0); /* No specific limit */
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_CURSOR_NAME_LEN:
         ptype = "SQL_MAX_CURSOR_NAME_LEN";
         *(SWORD *) InfoValuePtr = (MG_SQL_MAX_CURSOR_LEN);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_DRIVER_CONNECTIONS:
         ptype = "SQL_MAX_DRIVER_CONNECTIONS";
         *(SWORD *) InfoValuePtr = (0); /* No specific limit */
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_IDENTIFIER_LEN:
         ptype = "SQL_MAX_IDENTIFIER_LEN";
         *(SWORD *) InfoValuePtr = (MG_NAME_LEN);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_INDEX_SIZE:
         ptype = "SQL_MAX_INDEX_SIZE";
         *(SWORD *) InfoValuePtr = (3072);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_PROCEDURE_NAME_LEN:
         ptype = "SQL_MAX_PROCEDURE_NAME_LEN";
         *(SWORD *) InfoValuePtr = (MG_NAME_LEN);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_ROW_SIZE:
         ptype = "SQL_MAX_ROW_SIZE";
         *(DWORD *) InfoValuePtr = (0); /* No specific limit */
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_MAX_ROW_SIZE_INCLUDES_LONG:
         ptype = "SQL_MAX_ROW_SIZE_INCLUDES_LONG";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_MAX_SCHEMA_NAME_LEN:
         ptype = "SQL_MAX_SCHEMA_NAME_LEN";
         *(SWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_STATEMENT_LEN:
         ptype = "SQL_MAX_STATEMENT_LEN";
         *(DWORD *) InfoValuePtr = (4096);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_MAX_TABLE_NAME_LEN:
         ptype = "SQL_MAX_TABLE_NAME_LEN";
         *(SWORD *) InfoValuePtr = (MG_NAME_LEN);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_TABLES_IN_SELECT:
         ptype = "SQL_MAX_TABLES_IN_SELECT";
         *(SWORD *) InfoValuePtr = (63);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MAX_USER_NAME_LEN:
         ptype = "SQL_MAX_USER_NAME_LEN";
         *(SWORD *) InfoValuePtr = (MG_USERNAME_LENGTH);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_MULT_RESULT_SETS:
         ptype = "SQL_MULT_RESULT_SETS";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_MULTIPLE_ACTIVE_TXN:
         ptype = "SQL_MULTIPLE_ACTIVE_TXN";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_NEED_LONG_DATA_LEN:
         ptype = "SQL_NEED_LONG_DATA_LEN";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("N"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_NON_NULLABLE_COLUMNS:
         ptype = "SQL_NON_NULLABLE_COLUMNS";
         *(SWORD *) InfoValuePtr = (SQL_NNC_NON_NULL);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_NULL_COLLATION:
         ptype = "SQL_NULL_COLLATION";
         *(SWORD *) InfoValuePtr = (SQL_NC_LOW);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_NUMERIC_FUNCTIONS:
         ptype = "SQL_NUMERIC_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_FN_NUM_ABS | SQL_FN_NUM_ACOS | SQL_FN_NUM_ASIN |
                     SQL_FN_NUM_ATAN | SQL_FN_NUM_ATAN2 | SQL_FN_NUM_CEILING |
                     SQL_FN_NUM_COS | SQL_FN_NUM_COT | SQL_FN_NUM_EXP |
                     SQL_FN_NUM_FLOOR | SQL_FN_NUM_LOG | SQL_FN_NUM_MOD |
                     SQL_FN_NUM_SIGN | SQL_FN_NUM_SIN | SQL_FN_NUM_SQRT |
                     SQL_FN_NUM_TAN | SQL_FN_NUM_PI | SQL_FN_NUM_RAND |
                     SQL_FN_NUM_DEGREES | SQL_FN_NUM_LOG10 | SQL_FN_NUM_POWER |
                     SQL_FN_NUM_RADIANS | SQL_FN_NUM_ROUND |
                     SQL_FN_NUM_TRUNCATE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_ODBC_API_CONFORMANCE:
         ptype = "SQL_ODBC_API_CONFORMANCE";
         *(SWORD *) InfoValuePtr = (SQL_OAC_LEVEL1);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_ODBC_INTERFACE_CONFORMANCE:
         ptype = "SQL_ODBC_INTERFACE_CONFORMANCE";
         *(DWORD *) InfoValuePtr = (SQL_OIC_LEVEL1);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_ODBC_SQL_CONFORMANCE:
         ptype = "SQL_ODBC_SQL_CONFORMANCE";
         *(SWORD *) InfoValuePtr = (SQL_OSC_CORE);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_OJ_CAPABILITIES:
         ptype = "SQL_OJ_CAPABILITIES";
         *(DWORD *) InfoValuePtr = (SQL_OJ_LEFT | SQL_OJ_RIGHT | SQL_OJ_NESTED |
                     SQL_OJ_NOT_ORDERED | SQL_OJ_INNER |
                     SQL_OJ_ALL_COMPARISON_OPS);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_ORDER_BY_COLUMNS_IN_SELECT:
         ptype = "SQL_ORDER_BY_COLUMNS_IN_SELECT";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("N"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_PARAM_ARRAY_ROW_COUNTS:
         ptype = "SQL_PARAM_ARRAY_ROW_COUNTS";
         *(DWORD *) InfoValuePtr = (SQL_PARC_NO_BATCH);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_PARAM_ARRAY_SELECTS:
         ptype = "SQL_PARAM_ARRAY_SELECTS";
         *(DWORD *) InfoValuePtr = (SQL_PAS_NO_SELECT);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_PROCEDURE_TERM:
         ptype = "SQL_PROCEDURE_TERM";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("stored procedure"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_PROCEDURES:
         ptype = "SQL_PROCEDURES";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_POS_OPERATIONS:
         ptype = "SQL_POS_OPERATIONS";
         if (dbc->flag & MG_FLAG_FORWARD_CURSOR)
            *(DWORD *) InfoValuePtr = (0);
         else
            *(DWORD *) InfoValuePtr = (SQL_POS_POSITION | SQL_POS_UPDATE | SQL_POS_DELETE | SQL_POS_ADD | SQL_POS_REFRESH);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_QUOTED_IDENTIFIER_CASE:
         ptype = "SQL_QUOTED_IDENTIFIER_CASE";
         *(SWORD *) InfoValuePtr = (SQL_IC_SENSITIVE);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_ROW_UPDATES:
         ptype = "SQL_ROW_UPDATES";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("N"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
/*
      case SQL_OWNER_TERM:
         ptype = "SQL_OWNER_TERM";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("SCHEMA");
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
*/
      case SQL_SCHEMA_TERM:
         ptype = "SQL_SCHEMA_TERM";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("SCHEMA"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_SCHEMA_USAGE:
         ptype = "SQL_SCHEMA_USAGE";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SCROLL_OPTIONS:
         ptype = "SQL_SCROLL_OPTIONS";
         *(DWORD *) InfoValuePtr = (SQL_SO_FORWARD_ONLY |
                     ((dbc->flag & MG_FLAG_FORWARD_CURSOR) ? 0 : SQL_SO_STATIC |
                     ((dbc->flag & MG_FLAG_DYNAMIC_CURSOR) ? SQL_SO_DYNAMIC : 0)));
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SEARCH_PATTERN_ESCAPE:
         ptype = "SQL_SEARCH_PATTERN_ESCAPE";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("\\"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_SERVER_NAME:
         ptype = "SQL_SERVER_NAME";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (dbc->mgsql.host_info));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_SPECIAL_CHARACTERS:
         ptype = "SQL_SPECIAL_CHARACTERS";
         /* We can handle anything but / and \xff. */
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (" !\"#%&'()*+,-.:;<=>?@[\\]^`{|}~"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_SQL_CONFORMANCE:
         ptype = "SQL_SQL_CONFORMANCE";
         *(DWORD *) InfoValuePtr = (SQL_SC_SQL92_INTERMEDIATE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_DATETIME_FUNCTIONS:
         ptype = "SQL_SQL92_DATETIME_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_SDF_CURRENT_DATE | SQL_SDF_CURRENT_TIME | SQL_SDF_CURRENT_TIMESTAMP);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_FOREIGN_KEY_DELETE_RULE:
         ptype = "SQL_SQL92_FOREIGN_KEY_DELETE_RULE";
      case SQL_SQL92_FOREIGN_KEY_UPDATE_RULE:
         ptype = "SQL_SQL92_FOREIGN_KEY_UPDATE_RULE";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_GRANT:
         ptype = "SQL_SQL92_GRANT";
         *(DWORD *) InfoValuePtr = (SQL_SG_DELETE_TABLE | SQL_SG_INSERT_COLUMN |
                     SQL_SG_INSERT_TABLE | SQL_SG_REFERENCES_TABLE |
                     SQL_SG_REFERENCES_COLUMN | SQL_SG_SELECT_TABLE |
                     SQL_SG_UPDATE_COLUMN | SQL_SG_UPDATE_TABLE |
                     SQL_SG_WITH_GRANT_OPTION);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_NUMERIC_VALUE_FUNCTIONS:
         ptype = "SQL_SQL92_NUMERIC_VALUE_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_SNVF_BIT_LENGTH | SQL_SNVF_CHAR_LENGTH |
                     SQL_SNVF_CHARACTER_LENGTH | SQL_SNVF_EXTRACT |
                     SQL_SNVF_OCTET_LENGTH | SQL_SNVF_POSITION);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_PREDICATES:
         ptype = "SQL_SQL92_PREDICATES";
         *(DWORD *) InfoValuePtr = (SQL_SP_BETWEEN | SQL_SP_COMPARISON | SQL_SP_EXISTS |
                     SQL_SP_IN | SQL_SP_ISNOTNULL | SQL_SP_ISNULL |
                     SQL_SP_LIKE /*| SQL_SP_MATCH_FULL  |SQL_SP_MATCH_PARTIAL |
                     SQL_SP_MATCH_UNIQUE_FULL | SQL_SP_MATCH_UNIQUE_PARTIAL |
                     SQL_SP_OVERLAPS */ | SQL_SP_QUANTIFIED_COMPARISON /*|
                     SQL_SP_UNIQUE */);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_RELATIONAL_JOIN_OPERATORS:
         ptype = "SQL_SQL92_RELATIONAL_JOIN_OPERATORS";
         *(DWORD *) InfoValuePtr = (SQL_SRJO_CROSS_JOIN | SQL_SRJO_INNER_JOIN  |
                     SQL_SRJO_LEFT_OUTER_JOIN | SQL_SRJO_NATURAL_JOIN |
                     SQL_SRJO_RIGHT_OUTER_JOIN);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_REVOKE:
         ptype = "SQL_SQL92_REVOKE";
         *(DWORD *) InfoValuePtr = (SQL_SR_DELETE_TABLE | SQL_SR_INSERT_COLUMN |
                     SQL_SR_INSERT_TABLE | SQL_SR_REFERENCES_TABLE |
                     SQL_SR_REFERENCES_COLUMN | SQL_SR_SELECT_TABLE |
                     SQL_SR_UPDATE_COLUMN | SQL_SR_UPDATE_TABLE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_ROW_VALUE_CONSTRUCTOR:
         ptype = "SQL_SQL92_ROW_VALUE_CONSTRUCTOR";
         *(DWORD *) InfoValuePtr = (SQL_SRVC_VALUE_EXPRESSION | SQL_SRVC_NULL |
                     SQL_SRVC_DEFAULT | SQL_SRVC_ROW_SUBQUERY);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;

      case SQL_SQL92_STRING_FUNCTIONS:
         ptype = "SQL_SQL92_STRING_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_SSF_CONVERT | SQL_SSF_LOWER | SQL_SSF_UPPER |
                     SQL_SSF_SUBSTRING | SQL_SSF_TRANSLATE | SQL_SSF_TRIM_BOTH |
                     SQL_SSF_TRIM_LEADING | SQL_SSF_TRIM_TRAILING);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SQL92_VALUE_EXPRESSIONS:
         ptype = "SQL_SQL92_VALUE_EXPRESSIONS";
         *(DWORD *) InfoValuePtr = (SQL_SVE_CASE | SQL_SVE_CAST | SQL_SVE_COALESCE |
                     SQL_SVE_NULLIF);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_STANDARD_CLI_CONFORMANCE:
         ptype = "SQL_STANDARD_CLI_CONFORMANCE";
         *(DWORD *) InfoValuePtr = (SQL_SCC_ISO92_CLI);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_STATIC_CURSOR_ATTRIBUTES1:
         ptype = "SQL_STATIC_CURSOR_ATTRIBUTES1";
         *(DWORD *) InfoValuePtr = (SQL_CA1_NEXT | SQL_CA1_ABSOLUTE | SQL_CA1_RELATIVE |
                     SQL_CA1_LOCK_NO_CHANGE | SQL_CA1_POS_POSITION |
                     SQL_CA1_POS_UPDATE | SQL_CA1_POS_DELETE |
                     SQL_CA1_POS_REFRESH | SQL_CA1_POSITIONED_UPDATE |
                     SQL_CA1_POSITIONED_DELETE | SQL_CA1_BULK_ADD);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_STATIC_CURSOR_ATTRIBUTES2:
         ptype = "SQL_STATIC_CURSOR_ATTRIBUTES2";
         *(DWORD *) InfoValuePtr = (SQL_CA2_MAX_ROWS_SELECT | SQL_CA2_MAX_ROWS_INSERT |
                     SQL_CA2_MAX_ROWS_DELETE | SQL_CA2_MAX_ROWS_UPDATE |
                     SQL_CA2_CRC_EXACT);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_STRING_FUNCTIONS:
         ptype = "SQL_STRING_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_FN_STR_ASCII | SQL_FN_STR_BIT_LENGTH |
                     SQL_FN_STR_CHAR | SQL_FN_STR_CHAR_LENGTH |
                     SQL_FN_STR_CONCAT | SQL_FN_STR_INSERT | SQL_FN_STR_LCASE |
                     SQL_FN_STR_LEFT | SQL_FN_STR_LENGTH | SQL_FN_STR_LOCATE |
                     SQL_FN_STR_LOCATE_2 | SQL_FN_STR_LTRIM |
                     SQL_FN_STR_OCTET_LENGTH | SQL_FN_STR_POSITION |
                     SQL_FN_STR_REPEAT | SQL_FN_STR_REPLACE | SQL_FN_STR_RIGHT |
                     SQL_FN_STR_RTRIM | SQL_FN_STR_SOUNDEX | SQL_FN_STR_SPACE |
                     SQL_FN_STR_SUBSTRING | SQL_FN_STR_UCASE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SUBQUERIES:
         ptype = "SQL_SUBQUERIES";
         *(DWORD *) InfoValuePtr = (SQL_SQ_CORRELATED_SUBQUERIES | SQL_SQ_COMPARISON |
                     SQL_SQ_EXISTS | SQL_SQ_IN | SQL_SQ_QUANTIFIED);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SYSTEM_FUNCTIONS:
         ptype = "SQL_SYSTEM_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_FN_SYS_DBNAME | SQL_FN_SYS_IFNULL |
                     SQL_FN_SYS_USERNAME);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_TABLE_TERM:
         ptype = "SQL_TABLE_TERM";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("table"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_TIMEDATE_ADD_INTERVALS:
         ptype = "SQL_TIMEDATE_ADD_INTERVALS";
      case SQL_TIMEDATE_DIFF_INTERVALS:
         ptype = "SQL_TIMEDATE_DIFF_INTERVALS";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_TIMEDATE_FUNCTIONS:
         ptype = "SQL_TIMEDATE_FUNCTIONS";
         *(DWORD *) InfoValuePtr = (SQL_FN_TD_CURRENT_DATE | SQL_FN_TD_CURRENT_TIME |
                     SQL_FN_TD_CURRENT_TIMESTAMP | SQL_FN_TD_CURDATE |
                     SQL_FN_TD_CURTIME | SQL_FN_TD_DAYNAME |
                     SQL_FN_TD_DAYOFMONTH | SQL_FN_TD_DAYOFWEEK |
                     SQL_FN_TD_DAYOFYEAR | SQL_FN_TD_EXTRACT | SQL_FN_TD_HOUR |
                     /* SQL_FN_TD_JULIAN_DAY | */ SQL_FN_TD_MINUTE |
                     SQL_FN_TD_MONTH | SQL_FN_TD_MONTHNAME | SQL_FN_TD_NOW |
                     SQL_FN_TD_QUARTER | SQL_FN_TD_SECOND |
                     /*SQL_FN_TD_SECONDS_SINCE_MIDNIGHT | */
                     SQL_FN_TD_TIMESTAMPADD | SQL_FN_TD_TIMESTAMPDIFF |
                     SQL_FN_TD_WEEK | SQL_FN_TD_YEAR);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_TXN_CAPABLE:
         ptype = "SQL_TXN_CAPABLE";
         *(SWORD *) InfoValuePtr = (SQL_TC_DDL_COMMIT);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      case SQL_TXN_ISOLATION_OPTION:
         ptype = "SQL_TXN_ISOLATION_OPTION";
         *(DWORD *) InfoValuePtr = (SQL_TXN_READ_COMMITTED | SQL_TXN_READ_UNCOMMITTED | SQL_TXN_REPEATABLE_READ | SQL_TXN_SERIALIZABLE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_UNION:
         ptype = "SQL_UNION";
         *(DWORD *) InfoValuePtr = (SQL_U_UNION | SQL_U_UNION_ALL);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_USER_NAME:
         ptype = "SQL_USER_NAME";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) (dbc->user));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_XOPEN_CLI_YEAR:
         ptype = "SQL_XOPEN_CLI_YEAR";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("1992"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      /* The following aren't listed in the MSDN documentation. */
      case SQL_ACCESSIBLE_PROCEDURES:
         ptype = "SQL_ACCESSIBLE_PROCEDURES";
      case SQL_ACCESSIBLE_TABLES:
         ptype = "SQL_ACCESSIBLE_TABLES";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("N"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_LOCK_TYPES:
         ptype = "SQL_LOCK_TYPES";
         *(DWORD *) InfoValuePtr = (0);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_OUTER_JOINS:
         ptype = "SQL_OUTER_JOINS";
         lstrcpy((LPTSTR) InfoValuePtr, (LPCSTR) ("Y"));
         *StringLengthPtr = (SQLSMALLINT) strlen((const char *) InfoValuePtr);
         break;
      case SQL_POSITIONED_STATEMENTS:
         ptype = "SQL_POSITIONED_STATEMENTS";
         if (dbc->flag & MG_FLAG_FORWARD_CURSOR)
            *(DWORD *) InfoValuePtr = (0);
         else
            *(DWORD *) InfoValuePtr = (SQL_PS_POSITIONED_DELETE | SQL_PS_POSITIONED_UPDATE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_SCROLL_CONCURRENCY:
         ptype = "SQL_SCROLL_CONCURRENCY";
         /** @todo this is wrong. */
         *(DWORD *) InfoValuePtr = (SQL_SS_ADDITIONS | SQL_SS_DELETIONS | SQL_SS_UPDATES);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_STATIC_SENSITIVITY:
         ptype = "SQL_STATIC_SENSITIVITY";
         *(DWORD *) InfoValuePtr = (SQL_SS_ADDITIONS | SQL_SS_DELETIONS | SQL_SS_UPDATES);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_FETCH_DIRECTION:
         ptype = "SQL_FETCH_DIRECTION";
         if (dbc->flag & MG_FLAG_FORWARD_CURSOR)
            *(DWORD *) InfoValuePtr = (SQL_FD_FETCH_NEXT);
         else
            *(DWORD *) InfoValuePtr = (SQL_FD_FETCH_NEXT | SQL_FD_FETCH_FIRST |
                       SQL_FD_FETCH_LAST |
                       ((dbc->flag & MG_FLAG_NO_DEFAULT_CURSOR) ? 0 :
                        SQL_FD_FETCH_PRIOR) |
                       SQL_FD_FETCH_ABSOLUTE | SQL_FD_FETCH_RELATIVE);
         *StringLengthPtr = sizeof(SQLUINTEGER);
         break;
      case SQL_ODBC_SAG_CLI_CONFORMANCE:
         ptype = "SQL_ODBC_SAG_CLI_CONFORMANCE";
         *(SWORD *) InfoValuePtr = (SQL_OSCC_COMPLIANT);
         *StringLengthPtr = sizeof(SQLUSMALLINT);
         break;
      default:
         ptype = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      sprintf(buffer, "Information requested: %d (%s); BufferLength=%d; InfoValuePtr=%p", InfoType, ptype ? ptype : "null", BufferLength, InfoValuePtr);
      mg_log_event( buffer, "SQLGetInfo", 0, (void *) dbc, MG_DBT_DBC);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetInfo(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLGetTypeInfo(SQLHSTMT StatementHandle, SQLSMALLINT DataType)
{
   int n, len;
   char buffer[1024];
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

   if (CoreData.ftrace == 1) {
      char buffer[4096];
      sprintf(buffer, "stmt_no=%d; DataType=%d;", stmt->stmt_no, DataType);
      mg_log_event(buffer, "SQLGetTypeInfo", 0, (void *) stmt, MG_DBT_STMT);
   }

   stmt->eod = 0;
   stmt->row_count = 0;
   stmt->status = 1;

   sprintf(buffer + MG_HEAD_SIZE, "DataType=%d\r\n\r\n", DataType);
   len = (int) strlen(buffer + MG_HEAD_SIZE);
   buffer[len + MG_HEAD_SIZE] = '\0';

   rhead.cmnd = 'a';
   rhead.stmt_no = stmt->stmt_no;
   rhead.size = len;
   strcpy(rhead.desc, "");

   mg_set_record_head(&rhead, buffer);

   mg_mutex_lock(dbc->mlock);
   n = mg_send(dbc, buffer, MG_HEAD_SIZE + rhead.size);

   n = mg_get_block(dbc, &p_block, 0);
   mg_mutex_release(dbc->mlock);

   if (p_block && p_block->type == 'e') {
      mg_set_error(&stmt->error, "HY000", 0, p_block->pdata, "SQLGetTypeInfo");
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
      sprintf(buffer, "Exception caught in SQLGetTypeInfo(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLGetFunctions(SQLHDBC ConnectionHandle, SQLUSMALLINT FunctionId, SQLUSMALLINT * SupportedPtr)
{
   SQLUSMALLINT index, mgodbc_func_size;
   DBC * dbc = (DBC *) ConnectionHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "FunctionId = %d", FunctionId);
      mg_log_event(buffer, "SQLGetFunctions", 0, (void *) dbc, MG_DBT_DBC);
   }

   mgodbc_func_size= sizeof(mgodbc3_functions) / sizeof(mgodbc3_functions[0]);

   if (FunctionId == SQL_API_ODBC3_ALL_FUNCTIONS) {
      /* Clear and set bits in the 4000 bit vector */
      memset(SupportedPtr, 0, sizeof(SQLUSMALLINT) * SQL_API_ODBC3_ALL_FUNCTIONS_SIZE);
      for (index = 0; index < mgodbc_func_size; index ++) {
         SQLUSMALLINT id = mgodbc3_functions[index];
         SupportedPtr[id >> 4]|= (1 << (id & 0x000F));
      }
      return SQL_SUCCESS;
   }

  if (FunctionId == SQL_API_ALL_FUNCTIONS) {
      /* Clear and set elements in the SQLUSMALLINT 100 element array */
      memset(SupportedPtr, 0, sizeof(SQLUSMALLINT) * 100);
      for (index = 0; index < mgodbc_func_size; index ++) {
         if (mgodbc3_functions[index] < 100)
            SupportedPtr[mgodbc3_functions[index]] = SQL_TRUE;
      }
      return SQL_SUCCESS;
   }

   *SupportedPtr = SQL_FALSE;
   for (index = 0; index < mgodbc_func_size; index ++) {
      if (mgodbc3_functions[index] == FunctionId) {
         *SupportedPtr= SQL_TRUE;
         break;
      }
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetFunctions(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif
}


SQLRETURN SQL_API SQLDataSources(
   SQLHENV        EnvironmentHandle,
   SQLUSMALLINT   Direction,
   SQLCHAR *      ServerName,
   SQLSMALLINT    BufferLength1,
   SQLSMALLINT *  NameLength1Ptr,
   SQLCHAR *      Description,
   SQLSMALLINT    BufferLength2,
   SQLSMALLINT *  NameLength2Ptr)
{
   ENV * env = (ENV *) EnvironmentHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLDataSources", 0, (void *) env, MG_DBT_ENV);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLDataSources(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLDrivers(
   SQLHENV        EnvironmentHandle,
   SQLUSMALLINT   Direction,
   SQLCHAR *      DriverDescription,
   SQLSMALLINT    BufferLength1,
   SQLSMALLINT *  DescriptionLengthPtr,
   SQLCHAR *      DriverAttributes,
   SQLSMALLINT    BufferLength2,
   SQLSMALLINT *  AttributesLengthPtr)
{
   ENV * env = (ENV *) EnvironmentHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLDrivers", 0, (void *) env, MG_DBT_ENV);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLDrivers(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}



SQLRETURN SQL_API SQLGetDiagField(
   SQLSMALLINT    HandleType,
   SQLHANDLE      Handle,
   SQLSMALLINT    RecNumber,
   SQLSMALLINT    DiagIdentifier,
   SQLPOINTER     DiagInfoPtr,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  StringLengthPtr)
{
   int len;
   char *htype, *diag, *sqlstate;
   char mtext[1024];
   SQLRETURN retcode;

   /* Handle may not be these types, but this saves lots of casts below. */
   STMT *stmt = (STMT *) Handle;
   DBC *dbc = (DBC *) Handle;
   DESC *desc = (DESC *) Handle;
   MGERROR *error;

#ifdef _WIN32
__try {
#endif

   len = -1;
   diag = NULL;
   error = NULL;
   retcode = SQL_SUCCESS;

   if (StringLengthPtr) {
      *StringLengthPtr = 0;
   }
   if (!Handle) {
      retcode = SQL_ERROR;
      goto SQLGetDiagFieldExit;
   }

   if (HandleType == SQL_HANDLE_DESC) {
      htype = "SQL_HANDLE_DESC";
      error = &(desc->error);
   }
   else if (HandleType == SQL_HANDLE_STMT) {
      htype = "SQL_HANDLE_STMT";
      error = &(stmt->error);
   }
   else if (HandleType == SQL_HANDLE_DBC) {
      htype = "SQL_HANDLE_DBC";
      error = &(dbc->error);
   }
/*
   else if (HandleType == SQL_HANDLE_DBC_INFO_TOKEN) {
      htype = "SQL_HANDLE_DBC_INFO_TOKEN";
      error = &dbc->error;
   }
*/
   else if (HandleType == SQL_HANDLE_ENV) {
      htype = "SQL_HANDLE_ENV";
      error = &((ENV *) Handle)->error;
   }
   else {
      htype = "<UNKNOWN>";
      retcode = SQL_ERROR;
      goto SQLGetDiagFieldExit;

   }

   if (RecNumber > 1) {
      retcode = SQL_NO_DATA_FOUND;
      goto SQLGetDiagFieldExit;
   }

   if (!error) {
      retcode = SQL_ERROR;
      goto SQLGetDiagFieldExit;
   }

   switch (DiagIdentifier) {
      /*  Header fields */
      case SQL_DIAG_CURSOR_ROW_COUNT:
         diag = "SQL_DIAG_CURSOR_ROW_COUNT";
         if (HandleType != SQL_HANDLE_STMT) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (DiagInfoPtr) {
            if (!stmt->result)
               *(SQLLEN *) DiagInfoPtr = 0;
            else
               *(SQLLEN *) DiagInfoPtr = 0;
         }
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_DYNAMIC_FUNCTION:
         diag = "SQL_DIAG_DYNAMIC_FUNCTION";

         if (HandleType != SQL_HANDLE_STMT) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         strcpy(mtext, (char *) "");
         len = 0;
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_DYNAMIC_FUNCTION_CODE:
         diag = "SQL_DIAG_DYNAMIC_FUNCTION_CODE";

         if (HandleType != SQL_HANDLE_STMT) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (DiagInfoPtr) {
            *(SQLINTEGER *) DiagInfoPtr = 0;
         }
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_NUMBER:
         diag = "SQL_DIAG_NUMBER";

         if (DiagInfoPtr) {
            *(SQLINTEGER *) DiagInfoPtr = 1;
         }
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_RETURNCODE:
         diag = "SQL_DIAG_RETURNCODE";

         if (DiagInfoPtr) {
            *(SQLRETURN *) DiagInfoPtr = error->retcode;
         }
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_ROW_COUNT:
         diag = "SQL_DIAG_ROW_COUNT";

         if (HandleType != SQL_HANDLE_STMT) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;

         }
         if (DiagInfoPtr) {
            if (!stmt->result)
               *(SQLLEN *) DiagInfoPtr = 0;
            else
               *(SQLLEN *) DiagInfoPtr = 0; //(SQLLEN)stmt->affected_rows;
         }
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      /* Record fields */
      case SQL_DIAG_CLASS_ORIGIN:
         diag = "SQL_DIAG_CLASS_ORIGIN";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         sqlstate = error->sqlstate;

         if (sqlstate && sqlstate[0] == 'I' && sqlstate[1] == 'M')
            strcpy(mtext, (char *) "ODBC 3.0");
         else
            strcpy(mtext, (char *) "ISO 9075");
         len = (int) strlen(mtext);
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_COLUMN_NUMBER:
         diag = "SQL_DIAG_COLUMN_NUMBER";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (DiagInfoPtr) {
            *(SQLINTEGER *) DiagInfoPtr = SQL_COLUMN_NUMBER_UNKNOWN;
         }
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_CONNECTION_NAME:
         diag = "SQL_DIAG_CONNECTION_NAME";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (HandleType == SQL_HANDLE_DESC && desc)
            strcpy(mtext, (char *) desc->dbc ? desc->dbc->dsn : "");
         else if (HandleType == SQL_HANDLE_STMT && stmt)
            strcpy(mtext, (char *) stmt->hdbc ? ((DBC *) stmt->hdbc)->dsn : "");
         else if (HandleType == SQL_HANDLE_DBC && dbc)
            strcpy(mtext, (char *) dbc->dsn);
         else
            strcpy(mtext, (char *) "");
         len = (int) strlen(mtext);
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_MESSAGE_TEXT:
         diag = "SQL_DIAG_MESSAGE_TEXT";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         strcpy(mtext, (char *) error->text);
         len = (int) strlen(mtext);
         retcode = SQL_SUCCESS;

         goto SQLGetDiagFieldExit;

      case SQL_DIAG_NATIVE:
         diag = "SQL_DIAG_NATIVE";

         if (DiagInfoPtr) {
            *(SQLINTEGER *) DiagInfoPtr = error->natcode;
         }
         retcode = SQL_SUCCESS;

         goto SQLGetDiagFieldExit;

      case SQL_DIAG_ROW_NUMBER:
         diag = "SQL_DIAG_ROW_NUMBER";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (DiagInfoPtr) {
            *(SQLLEN *) DiagInfoPtr = SQL_ROW_NUMBER_UNKNOWN;
         }
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_SERVER_NAME:
         diag = "SQL_DIAG_SERVER_NAME";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (HandleType == SQL_HANDLE_DESC && desc)
            strcpy(mtext, (char *) desc->dbc ? desc->dbc->server : "");
         else if (HandleType == SQL_HANDLE_STMT && stmt)
            strcpy(mtext, (char *) stmt->hdbc ? ((DBC *) stmt->hdbc)->server : "");
         else if (HandleType == SQL_HANDLE_DBC && dbc)
            strcpy(mtext, (char *) dbc->server);
         else
            strcpy(mtext, (char *) "");
         len = (int) strlen(mtext);
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_SQLSTATE:
         diag = "SQL_DIAG_SQLSTATE";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (error && strlen(error->sqlstate) == 5) {
            strcpy((char *) mtext, error->sqlstate);
         }
         else {
            strcpy((char *) mtext, "00000");
         }
         len = (int) strlen(mtext);
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      case SQL_DIAG_SUBCLASS_ORIGIN:
         diag = "SQL_DIAG_SUBCLASS_ORIGIN";

         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         if (RecNumber <= 0) {
            retcode = SQL_ERROR;
            goto SQLGetDiagFieldExit;
         }
         sqlstate = error->sqlstate;

         if (mg_is_odbc3_subclass(sqlstate))
            strcpy((char *) mtext, "ODBC 3.0");
         else
            strcpy((char *) mtext, "ISO 9075");
         len = (int) strlen(mtext);
         retcode = SQL_SUCCESS;
         goto SQLGetDiagFieldExit;

      default:
         diag = "<UNKNOWN>";
         retcode = SQL_ERROR;
         goto SQLGetDiagFieldExit;
   }

SQLGetDiagFieldExit:

   if (len >= 0) {
      if (StringLengthPtr) {
         *StringLengthPtr = len;
      }
      if (DiagInfoPtr) {
         strncpy((char *) DiagInfoPtr, mtext, (int) BufferLength);
         ((char *) DiagInfoPtr)[BufferLength - 1] = '\0';
      }
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "htype=%s; DiagIdentifier=%d (%s); RecNumber=%d; BufferLength=%d; retcode=%d; message_length=%d; message=%s;", htype ? htype : "null", DiagIdentifier, diag ? diag : "null", (int) RecNumber, (int) BufferLength, (int) retcode, len, mtext);
      mg_log_event(buffer, "SQLGetDiagField", 0, NULL, 0);
   }

   return retcode;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetDiagField(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


int mg_is_odbc3_subclass(char *sqlstate)
{
  char *states[]= { "01S00", "01S01", "01S02", "01S06", "01S07", "07S01",
      "08S01", "21S01", "21S02", "25S01", "25S02", "25S03", "42S01", "42S02",
      "42S11", "42S12", "42S21", "42S22", "HY095", "HY097", "HY098", "HY099",
      "HY100", "HY101", "HY105", "HY107", "HY109", "HY110", "HY111", "HYT00",
      "HYT01", "IM001", "IM002", "IM003", "IM004", "IM005", "IM006", "IM007",
      "IM008", "IM010", "IM011", "IM012"};

  size_t i;

#ifdef _WIN32
__try {
#endif

  if (!sqlstate)
    return 0;

  for (i = 0; i < sizeof(states) / sizeof(states[0]); i ++)
    if (memcmp(states[i], sqlstate, 5) == 0)
      return 1;

  return 0;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_is_odbc3_subclass(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}



/*

   htype=SQL_HANDLE_STMT; RecNumber=1; BufferLength=256; TextLength=112; MessageText=[MG: M/Gateway Developments][MGODBC32.DLL][AAA YOTTIE]MG ODBC: SQLGetTypeInfo: <UNDEFINED>typ+7^%mgsqln2 *xxxyyy; NativeError=0; retcode=0;

 [ vendor-identifier ][ ODBC-component-identifier ] component-supplied-text

For errors and warnings that occur in a data source, the diagnostic message must use this format:

[ vendor-identifier ][ ODBC-component-identifier ][ data-source-identifier ] data-source-supplied-text

The following table shows the meaning of each element.
Element 	Meaning

vendor-identifier
=================	

Identifies the vendor of the component in which the error or warning occurred or that received the error or warning directly from the data source.

ODBC-component-identifier
=========================

Identifies the component in which the error or warning occurred or that received the error or warning directly from the data source.

data-source-identifier
======================

Identifies the data source. For file-based drivers, this is typically a file format, such as Xbase[1] For DBMS-based drivers, this is the DBMS product.

component-supplied-text
	

Generated by the ODBC component.
*/

SQLRETURN SQL_API SQLGetDiagRec(
   SQLSMALLINT    HandleType,
   SQLHANDLE      Handle,
   SQLSMALLINT    RecNumber,
   SQLCHAR *      SQLState,
   SQLINTEGER *   NativeErrorPtr,
   SQLCHAR *      MessageText,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  TextLengthPtr)
{
   int len;
   char *htype;
   char *dsn;
   char mtext[511];
   SQLRETURN retcode;
   /* Handle may not be these types, but this saves lots of casts below. */
   STMT *stmt = (STMT *) Handle;
   DBC *dbc = (DBC *) Handle;
   DESC *desc = (DESC *) Handle;
   MGERROR *error;

#ifdef _WIN32
__try {
#endif

   dsn = NULL;
   htype = NULL;
   error = NULL;
   *mtext = '\0';
   len = 0;
   retcode = SQL_SUCCESS;
/*
   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "Handle=%p; RecNumber=%d; SQLState=%p; NativeErrorPtr=%p; MessageText=%p; BufferLength=%d; TextLengthPtr=%p;", Handle, (int) RecNumber, SQLState, NativeErrorPtr, MessageText, (int) BufferLength, TextLengthPtr);
      mg_log_event(buffer, "SQLGetDiagRec", 0, NULL, 0);
   }
*/

   if (NativeErrorPtr) {
      *NativeErrorPtr = 0;
   }
   if (TextLengthPtr) {
      *TextLengthPtr = 0;
   }
   if (SQLState) {
      strcpy((char *) SQLState, "HY000");
   }
   if (MessageText) {
      strcpy((char *) MessageText, "");
   }

   if (!Handle) {
      retcode = SQL_ERROR;
      goto SQLGetDiagRecExit;
   }

   if (HandleType == SQL_HANDLE_DESC) {
      htype = "SQL_HANDLE_DESC";
      error = &desc->error;
   }
   else if (HandleType == SQL_HANDLE_STMT) {
      htype = "SQL_HANDLE_STMT";
      error = &stmt->error;
      dsn = ((DBC *) stmt->hdbc)->dsn;
   }
   else if (HandleType == SQL_HANDLE_DBC) {
      htype = "SQL_HANDLE_DBC";
      error = &dbc->error;
      dsn = dbc->dsn;
   }
/*
   else if (HandleType == SQL_HANDLE_DBC_INFO_TOKEN) {
      htype = "SQL_HANDLE_DBC_INFO_TOKEN";
      error = &dbc->error;
   }
*/
   else if (HandleType == SQL_HANDLE_ENV) {
      htype = "SQL_HANDLE_ENV";
      error = &((ENV *) Handle)->error;
   }
   else {
      htype = "SQL_ERROR";
      retcode = SQL_ERROR;
      goto SQLGetDiagRecExit;
   }

   if (RecNumber > 1) {
      retcode = SQL_NO_DATA_FOUND;
      goto SQLGetDiagRecExit;
   }

   if (!error) {
      retcode = SQL_ERROR;
      goto SQLGetDiagRecExit;
   }

   if (!dsn) {
      dsn = "none";
   }

   if (error->status == 1) {

      strcpy((char *) mtext, "[M/Gateway Developments Ltd][MGODBC32.DLL][");
      strcat((char *) mtext, dsn);
      strcat((char *) mtext, "]MGSQL: ");

      if (strlen(error->fun)) {
         strcat((char *) mtext, error->fun);
         strcat((char *) mtext, ": ");
      }
      strcat((char *) mtext, error->text);
      len = (int) strlen(mtext);

      if (TextLengthPtr) {
         *TextLengthPtr = (SQLSMALLINT) len;
      }
      if (SQLState && strlen(error->sqlstate) == 5) {
         strcpy((char *) SQLState, error->sqlstate);
      }
      if (NativeErrorPtr) {
         *NativeErrorPtr = error->natcode;
      }

      if (MessageText && BufferLength > 0) {
         strncpy((char *) MessageText, mtext, (int) BufferLength);
         MessageText[BufferLength - 1] = '\0';
      }

      retcode = SQL_SUCCESS;
   }

SQLGetDiagRecExit:

   if (CoreData.ftrace == 1) {
      char buffer[1024];
      sprintf(buffer, "htype=%s; RecNumber=%d; BufferLength=%d; retcode=%d; SQLState=%s; message_length=%d; message=%s;", htype ? htype : "null", (int) RecNumber, (int) BufferLength, (int) retcode, SQLState ? (char *) SQLState : "null", len, mtext);
      mg_log_event(buffer, "SQLGetDiagRec", 0, NULL, 0);
   }

   return retcode;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetDiagRec(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}

