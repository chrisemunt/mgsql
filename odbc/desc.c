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
#include <string.h>


SQLRETURN SQL_API SQLSetDescField(
   SQLHDESC       DescriptorHandle,
   SQLSMALLINT    RecNumber,
   SQLSMALLINT    FieldIdentifier,
   SQLPOINTER     ValuePtr,
   SQLINTEGER     BufferLength)

{
   char *pattr;
   DESC * desc = (DESC *) DescriptorHandle;

#ifdef _WIN32
__try {
#endif
/*
   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLSetDescField", 0, (void *) desc, MG_DBT_DESC);
   }
*/

   pattr = NULL;

   switch (FieldIdentifier) {
      case SQL_DESC_ALLOC_TYPE:
         pattr = "SQL_DESC_ALLOC_TYPE";
         break;
      case SQL_DESC_ARRAY_SIZE:
         pattr = "SQL_DESC_ARRAY_SIZE";
         break;
      case SQL_DESC_ARRAY_STATUS_PTR:
         pattr = "SQL_DESC_ARRAY_STATUS_PTR";
         break;
      case SQL_DESC_BIND_OFFSET_PTR:
         pattr = "SQL_DESC_BIND_OFFSET_PTR";
         break;
      case SQL_DESC_BIND_TYPE:
         pattr = "SQL_DESC_BIND_TYPE";
         break;
      case SQL_DESC_COUNT:
         pattr = "SQL_DESC_COUNT";
         break;
      case SQL_DESC_ROWS_PROCESSED_PTR:
         pattr = "SQL_DESC_ROWS_PROCESSED_PTR";
         break;
      case SQL_DESC_AUTO_UNIQUE_VALUE:
         pattr = "SQL_DESC_AUTO_UNIQUE_VALUE";
         break;
      case SQL_DESC_BASE_COLUMN_NAME:
         pattr = "SQL_DESC_BASE_COLUMN_NAME";
         break;
      case SQL_DESC_BASE_TABLE_NAME:
         pattr = "SQL_DESC_BASE_TABLE_NAME";
         break;
      case SQL_DESC_CASE_SENSITIVE:
         pattr = "SQL_DESC_CASE_SENSITIVE";
         break;
      case SQL_DESC_CATALOG_NAME:
         pattr = "SQL_DESC_CATALOG_NAME";
         break;
      case SQL_DESC_CONCISE_TYPE:
         pattr = "SQL_DESC_CONCISE_TYPE";
         break;
      case SQL_DESC_DATA_PTR:
         pattr = "SQL_DESC_DATA_PTR";
         break;
      case SQL_DESC_DATETIME_INTERVAL_CODE:
         pattr = "SQL_DESC_DATETIME_INTERVAL_CODE";
         break;
      case SQL_DESC_DATETIME_INTERVAL_PRECISION:
         pattr = "SQL_DESC_DATETIME_INTERVAL_PRECISION";
         break;
      case SQL_DESC_DISPLAY_SIZE:
         pattr = "SQL_DESC_DISPLAY_SIZE";
         break;
      case SQL_DESC_FIXED_PREC_SCALE:
         pattr = "SQL_DESC_FIXED_PREC_SCALE";
         break;
      case SQL_DESC_INDICATOR_PTR:
         pattr = "SQL_DESC_INDICATOR_PTR";
         break;
      case SQL_DESC_LABEL:
         pattr = "SQL_DESC_LABEL";
         break;
      case SQL_DESC_LENGTH:
         pattr = "SQL_DESC_LENGTH";
         break;
      case SQL_DESC_LITERAL_PREFIX:
         pattr = "SQL_DESC_LITERAL_PREFIX";
         break;
      case SQL_DESC_LITERAL_SUFFIX:
         pattr = "SQL_DESC_LITERAL_SUFFIX";
         break;
      case SQL_DESC_LOCAL_TYPE_NAME:
         pattr = "SQL_DESC_LOCAL_TYPE_NAME";
         break;
      case SQL_DESC_NAME:
         pattr = "SQL_DESC_NAME";
         break;
      case SQL_DESC_NULLABLE:
         pattr = "SQL_DESC_NULLABLE";
         break;
      case SQL_DESC_NUM_PREC_RADIX:
         pattr = "SQL_DESC_NUM_PREC_RADIX";
         break;
      case SQL_DESC_OCTET_LENGTH:
         pattr = "SQL_DESC_OCTET_LENGTH";
         break;
      case SQL_DESC_OCTET_LENGTH_PTR:
         pattr = "SQL_DESC_OCTET_LENGTH_PTR";
         break;
      case SQL_DESC_PARAMETER_TYPE:
         pattr = "SQL_DESC_PARAMETER_TYPE";
         break;
      case SQL_DESC_PRECISION:
         pattr = "SQL_DESC_PRECISION";
         break;
      case SQL_DESC_ROWVER:
         pattr = "SQL_DESC_ROWVER";
         break;
      case SQL_DESC_SCALE:
         pattr = "SQL_DESC_SCALE";
         break;
      case SQL_DESC_SCHEMA_NAME:
         pattr = "SQL_DESC_SCHEMA_NAME";
         break;
      case SQL_DESC_SEARCHABLE:
         pattr = "SQL_DESC_SEARCHABLE";
         break;
      case SQL_DESC_TABLE_NAME:
         pattr = "SQL_DESC_TABLE_NAME";
         break;
      case SQL_DESC_TYPE:
         pattr = "SQL_DESC_TYPE";
         break;
      case SQL_DESC_TYPE_NAME:
         pattr = "SQL_DESC_TYPE_NAME";
         break;
      case SQL_DESC_UNNAMED:
         pattr = "SQL_DESC_UNNAMED";
         break;
      case SQL_DESC_UNSIGNED:
         pattr = "SQL_DESC_UNSIGNED";
         break;
      case SQL_DESC_UPDATABLE:
         pattr = "SQL_DESC_UPDATABLE";
         break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "RecNumber=%d; FieldIdentifier=%d (%s); BufferLength=%d;", RecNumber, FieldIdentifier, pattr ? pattr : "null", (int) BufferLength);
      mg_log_event(buffer, "SQLSetDescField", 0, (void *) desc, MG_DBT_DESC);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetDescField(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLGetDescField(
   SQLHDESC       DescriptorHandle,
   SQLSMALLINT    RecNumber,
   SQLSMALLINT    FieldIdentifier,
   SQLPOINTER     ValuePtr,
   SQLINTEGER     BufferLength,
   SQLINTEGER *   StringLengthPtr)
{
   char * pattr;
   DESC * desc = (DESC *) DescriptorHandle;

#ifdef _WIN32
__try {
#endif
/*
   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLGetDescField", 0, (void *) desc, MG_DBT_DESC);
   }
*/

   if (IS_IRD(desc) && desc->stmt->state == 0) {
      mg_set_error(&desc->error, "HY007", 0, "Associated statement is not prepared", "SQLGetDescField");
      return SQL_ERROR;
   }

   pattr = NULL;

   switch (FieldIdentifier) {
      case SQL_DESC_ALLOC_TYPE:
         pattr = "SQL_DESC_ALLOC_TYPE";
         break;
      case SQL_DESC_ARRAY_SIZE:
         pattr = "SQL_DESC_ARRAY_SIZE";
         break;
      case SQL_DESC_ARRAY_STATUS_PTR:
         pattr = "SQL_DESC_ARRAY_STATUS_PTR";
         break;
      case SQL_DESC_BIND_OFFSET_PTR:
         pattr = "SQL_DESC_BIND_OFFSET_PTR";
         break;
      case SQL_DESC_BIND_TYPE:
         pattr = "SQL_DESC_BIND_TYPE";
         break;
      case SQL_DESC_COUNT:
         pattr = "SQL_DESC_COUNT";
         break;
      case SQL_DESC_ROWS_PROCESSED_PTR:
         pattr = "SQL_DESC_ROWS_PROCESSED_PTR";
         break;
      case SQL_DESC_AUTO_UNIQUE_VALUE:
         pattr = "SQL_DESC_AUTO_UNIQUE_VALUE";
         break;
      case SQL_DESC_BASE_COLUMN_NAME:
         pattr = "SQL_DESC_BASE_COLUMN_NAME";
         break;
      case SQL_DESC_BASE_TABLE_NAME:
         pattr = "SQL_DESC_BASE_TABLE_NAME";
         break;
      case SQL_DESC_CASE_SENSITIVE:
         pattr = "SQL_DESC_CASE_SENSITIVE";
         break;
      case SQL_DESC_CATALOG_NAME:
         pattr = "SQL_DESC_CATALOG_NAME";
         break;
      case SQL_DESC_CONCISE_TYPE:
         pattr = "SQL_DESC_CONCISE_TYPE";
         break;
      case SQL_DESC_DATA_PTR:
         pattr = "SQL_DESC_DATA_PTR";
         break;
      case SQL_DESC_DATETIME_INTERVAL_CODE:
         pattr = "SQL_DESC_DATETIME_INTERVAL_CODE";
         break;
      case SQL_DESC_DATETIME_INTERVAL_PRECISION:
         pattr = "SQL_DESC_DATETIME_INTERVAL_PRECISION";
         break;
      case SQL_DESC_DISPLAY_SIZE:
         pattr = "SQL_DESC_DISPLAY_SIZE";
         break;
      case SQL_DESC_FIXED_PREC_SCALE:
         pattr = "SQL_DESC_FIXED_PREC_SCALE";
         break;
      case SQL_DESC_INDICATOR_PTR:
         pattr = "SQL_DESC_INDICATOR_PTR";
         break;
      case SQL_DESC_LABEL:
         pattr = "SQL_DESC_LABEL";
         break;
      case SQL_DESC_LENGTH:
         pattr = "SQL_DESC_LENGTH";
         break;
      case SQL_DESC_LITERAL_PREFIX:
         pattr = "SQL_DESC_LITERAL_PREFIX";
         break;
      case SQL_DESC_LITERAL_SUFFIX:
         pattr = "SQL_DESC_LITERAL_SUFFIX";
         break;
      case SQL_DESC_LOCAL_TYPE_NAME:
         pattr = "SQL_DESC_LOCAL_TYPE_NAME";
         break;
      case SQL_DESC_NAME:
         pattr = "SQL_DESC_NAME";
         break;
      case SQL_DESC_NULLABLE:
         pattr = "SQL_DESC_NULLABLE";
         break;
      case SQL_DESC_NUM_PREC_RADIX:
         pattr = "SQL_DESC_NUM_PREC_RADIX";
         break;
      case SQL_DESC_OCTET_LENGTH:
         pattr = "SQL_DESC_OCTET_LENGTH";
         break;
      case SQL_DESC_OCTET_LENGTH_PTR:
         pattr = "SQL_DESC_OCTET_LENGTH_PTR";
         break;
      case SQL_DESC_PARAMETER_TYPE:
         pattr = "SQL_DESC_PARAMETER_TYPE";
         break;
      case SQL_DESC_PRECISION:
         pattr = "SQL_DESC_PRECISION";
         break;
      case SQL_DESC_ROWVER:
         pattr = "SQL_DESC_ROWVER";
         break;
      case SQL_DESC_SCALE:
         pattr = "SQL_DESC_SCALE";
         break;
      case SQL_DESC_SCHEMA_NAME:
         pattr = "SQL_DESC_SCHEMA_NAME";
         break;
      case SQL_DESC_SEARCHABLE:
         pattr = "SQL_DESC_SEARCHABLE";
         break;
      case SQL_DESC_TABLE_NAME:
         pattr = "SQL_DESC_TABLE_NAME";
         break;
      case SQL_DESC_TYPE:
         pattr = "SQL_DESC_TYPE";
         break;
      case SQL_DESC_TYPE_NAME:
         pattr = "SQL_DESC_TYPE_NAME";
         break;
      case SQL_DESC_UNNAMED:
         pattr = "SQL_DESC_UNNAMED";
         break;
      case SQL_DESC_UNSIGNED:
         pattr = "SQL_DESC_UNSIGNED";
         break;
      case SQL_DESC_UPDATABLE:
         pattr = "SQL_DESC_UPDATABLE";
         break;
      default:
         pattr = "<UNKNOWN>";
   }

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "RecNumber=%d; FieldIdentifier=%d (%s); BufferLength=%d;", RecNumber, FieldIdentifier, pattr ? pattr : "null", (int) BufferLength);
      mg_log_event(buffer, "SQLGetDescField", 0, (void *) desc, MG_DBT_DESC);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetDescField(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLSetDescRec(
   SQLHDESC       DescriptorHandle,
   SQLSMALLINT    RecNumber,
   SQLSMALLINT    Type,
   SQLSMALLINT    SubType,
   SQLLEN         Length,
   SQLSMALLINT    Precision,
   SQLSMALLINT    Scale,
   SQLPOINTER     DataPtr,
   SQLLEN *       StringLengthPtr,
   SQLLEN *       IndicatorPtr)
{
   DESC * desc = (DESC *) DescriptorHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "RecNumber=%d;", RecNumber);
      mg_log_event(buffer, "SQLSetDescRec", 0, (void *) desc, MG_DBT_DESC);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLSetDescRec(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}


SQLRETURN SQL_API SQLGetDescRec(
   SQLHDESC       DescriptorHandle,
   SQLSMALLINT    RecNumber,
   SQLCHAR *      Name,
   SQLSMALLINT    BufferLength,
   SQLSMALLINT *  StringLengthPtr,
   SQLSMALLINT *  TypePtr,
   SQLSMALLINT *  SubTypePtr,
   SQLLEN *       LengthPtr,
   SQLSMALLINT *  PrecisionPtr,
   SQLSMALLINT *  ScalePtr,
   SQLSMALLINT *  NullablePtr)
{
   DESC * desc = (DESC *) DescriptorHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      char buffer[256];
      sprintf(buffer, "RecNumber=%d;", RecNumber);
      mg_log_event(buffer, "SQLGetDescRec", 0, (void *) desc, MG_DBT_DESC);
   }

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLGetDescRec(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}



SQLRETURN SQL_API SQLCopyDesc(SQLHDESC SourceDescHandle, SQLHDESC TargetDescHandle)
{
   DESC *src = (DESC *) SourceDescHandle;
   DESC *dest = (DESC *) TargetDescHandle;

#ifdef _WIN32
__try {
#endif

   if (CoreData.ftrace == 1) {
      mg_log_event("", "SQLCopyDesc", 0, NULL, 0);
   }

   if (IS_IRD(dest)) {
      mg_set_error(&dest->error, "HY016", 0, "Cannot modify an implementation row descriptor", "SQLCopyDesc");
      return SQL_ERROR;
   }

   if (IS_IRD(src) && src->stmt->state == 0) {
      mg_set_error(&dest->error, "HY007", 0, "Associated statement is not prepared", "SQLCopyDesc");
      return SQL_ERROR;
   }

   /* copy the records */
   memcpy((void *) dest, (void *) src, sizeof(DESC));

   return SQL_SUCCESS;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in SQLCopyDesc(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif


}
