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


#if defined(_MSC_VER)
#if (_MSC_VER >= 1400)
#define _CRT_SECURE_NO_DEPRECATE    1
#define _CRT_NONSTDC_NO_DEPRECATE   1
#endif
#endif
#define _WINSOCK_DEPRECATED_NO_WARNINGS 1

#pragma warning(suppress : 4311)

#define ODBCVER 0x0351

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
#include <time.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#include <windows.h>
#include <windowsx.h>
#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>

#define MG_STR_HELPER(x)      #x
#define MG_STR(x)             MG_STR_HELPER(x)

#define MG_LOG_FILE           "mgodbc.log"
#define MG_LOG_FILEP          "mgodbcp.log"

#define MG_VERSION_MAJOR      1
#define MG_VERSION_MINOR      0
#define MG_VERSION_BUILD      1
#define MG_VERSION_PN         1
#define MG_DB_NAME            "MGSQL"
#define MG_COMP_NAME          "mgodbc"
#define MG_MANU_NAME          "M/Gateway Developments Ltd."
#define MG_TARG_OS            "Windows"
#define MG_TARG_OS_REV        "5.0"
#define MG_DATE_INSTALLED     "11 Jun 2019"

#define MG_VERSION            MG_STR(MG_VERSION_MAJOR) "." MG_STR(MG_VERSION_MINOR) "." MG_STR(MG_VERSION_BUILD)

#define MG_MAX_COLS           256
#define MG_SIZE_BASE          10

#define MG_SYS_YDB            1
#define MG_SYS_IDB            2
#define MG_SYS_MSM            3
#define MG_SYS_DSM            4
#define MG_SYS_M21            5

#define MG_DBT_NONE           0
#define MG_DBT_STMT           1
#define MG_DBT_DESC           2
#define MG_DBT_DBC            3
#define MG_DBT_ENV            4

#define MG_HEAD_SIZE          14
#define MG_NBASE              256

#define MG_DEF_LOGIN_TIMEOUT  10
#define MG_DEF_REQ_TIMEOUT    30

#define ODBC_INI              "ODBC.INI"
#define ODBCINST_INI          "ODBCINST.INI"


/*
   Definitions to be used in function prototypes.
      The SQL_API is to be used only for those functions exported for driver
         manager use.
      The EXPFUNC is to be used only for those functions exported but used
         internally, ie, dialog procs.
      The INTFUNC is to be used for all other functions.
*/

#define INTFUNC  __stdcall
#define EXPFUNC  __stdcall

#ifdef _WIN64
typedef INT64 SQLLEN;
typedef UINT64 SQLULEN;
#else
#define SQLLEN SQLINTEGER
#define SQLULEN SQLUINTEGER
#endif

#define SOCK_ERROR(n)   (n == SOCKET_ERROR)
#define INVALID_SOCK(n) (n == INVALID_SOCKET)
#define NOT_BLOCKING(n) (n != WSAEWOULDBLOCK)

#if defined(_WIN32)
#define _mgso(a)                _countof(a)
#else
#define _mgso(a)                sizeof(a)
#endif

/* #define T_STRCPY(a, b, c)        _tcscpy_s(a, b, c) */
/* #define T_STRNCPY(a, b, c, d)    _tcsncpy_s(a, b, c, d) */
#define T_STRCPY(a, b, c)        strcpy_s(a, b, c)
#define T_STRNCPY(a, b, c, d)    memcpy_s(a, b, c, d)

#define T_STRCAT(a, b, c)        strcat_s(a, b, c)
#define T_STRNCAT(a, b, c, d)    strncat_s(a, b, c, d)
#define T_SPRINTF(a, b, c, ...)  sprintf_s(a, b, c, __VA_ARGS__)
#if defined(LINUX)
#define T_MEMCPY(a,b,c)          memmove(a,b,c)
#else
#define T_MEMCPY(a,b,c)          memcpy(a,b,c)
#endif

typedef	struct tagMGERROR {
   short status;
   int retcode;
   int natcode;
   char sqlstate[32];
   char text[256];
   char fun[32];
}	MGERROR, * LPMGERROR;


typedef struct _tagMGZV {
   short    sys_type;
   double   sys_version;
   int      majorversion;
   int      minorversion;
   int      sys_build;
   char     zv[256];
   char     short_name[64];
} MGZV, *LPMGZV;


/* implementation or application descriptor? */
typedef enum { DESC_IMP, DESC_APP } desc_ref_type;

/* parameter or row descriptor? */
typedef enum { DESC_PARAM, DESC_ROW, DESC_UNKNOWN } desc_desc_type;

/* header or record field? (location in descriptor) */
typedef enum { DESC_HDR, DESC_REC } fld_loc;

#define IS_APD(d) ((d)->desc_type == DESC_PARAM && (d)->ref_type == DESC_APP)
#define IS_IPD(d) ((d)->desc_type == DESC_PARAM && (d)->ref_type == DESC_IMP)
#define IS_ARD(d) ((d)->desc_type == DESC_ROW && (d)->ref_type == DESC_APP)
#define IS_IRD(d) ((d)->desc_type == DESC_ROW && (d)->ref_type == DESC_IMP)


typedef struct tagELMNT {
   int len;
   char *data;
}	ELMNT, * LPELMNT;


typedef struct tagMGPARAM {
   SQLUSMALLINT input_output_type;
   SQLSMALLINT value_type;
   SQLSMALLINT parameter_type;
   SQLULEN column_size;
   SQLSMALLINT decimal_digits;
   SQLPOINTER parameter_value_ptr;
   SQLLEN buffer_length;
   SQLLEN * strLen_or_indptr;
}	MGPARAM, * LPMGPARAM;


typedef struct tagMGCOL {
   char dbid[16];
   char tname[128];
   char cname[128];
   char type[32];
   int type_len;
   int type_id;
}	MGCOL, * LPMGCOL;


typedef struct tagMGCOLDAT {
   short bound;
   SQLSMALLINT type;
   SQLPOINTER pdata;
   int maxlen;
   int actlen;
   int *pactlen;
   int rdata_size;
   char *rdata;
   union {
      unsigned char     uchar;
      char              schar;
      unsigned short    ushort;
      short             sshort;
      unsigned int      uint;
      int               sint;
      unsigned long     ulong;
      long              slong;
      long double       real;
      char *            str;
   } data;
}	MGCOLDAT, * LPMGCOLDAT;


/* Environment information. */

typedef struct tagENV {
   SQLINTEGER odbc_ver;
   short connections;
   char MGSQLEnv[32];
   MGERROR error;
}	ENV,* LPENV;

/* Database connection information.  This is allocated by "SQLAllocConnect". */

typedef struct	tagDBCINFO {
   char server_version[32];
   char charset[32];
   char host_info[256];
   MGZV zv;
} DBCINFO, * LPDBCINFO;


typedef struct	tagDBC {
   SQLHENV henv;
      short flag;
#ifdef _WIN32
   WSADATA     wsadata;
   SOCKET      sockfd;
#else
   int         sockfd;
#endif
   int login_timeout;
   int req_timeout;
   char server[256];
   int port;
   char user[256];
   char password[32];
   char dsn[256];
   char uci[256];
   char driver[256];
   char dbid[256];

   DBCINFO mgsql;

   int pb_error;
   MGERROR error;

   HANDLE mlock;

}	DBC, * LPDBC;


/* Descriptor information */

typedef struct tagDESC {
   short  desc_type;
   short  ref_type;
   SQLSMALLINT   alloc_type;
   SQLINTEGER    bind_type;
   SQLLEN simulate_cursor;

   SQLUINTEGER  *p_rows_fetched;
   SQLUSMALLINT *p_row_array_status;
   SQLPOINTER     p_row_array;
   SQLUINTEGER    row_array_size;
   size_t         row_array_element_size;

   SQLUSMALLINT *p_param_array_status;
   SQLPOINTER     p_param_array;
   SQLUINTEGER    param_array_size;
   SQLPOINTER     p_bind_offset;

   int param_count;
   MGPARAM params[MG_MAX_COLS];

   int col_count;
   MGCOLDAT coldat0[MG_MAX_COLS];
   MGCOLDAT coldat[MG_MAX_COLS];
   MGCOL cols[MG_MAX_COLS];

   MGERROR         error;

   struct tagSTMT *stmt;
   struct tagDBC *dbc;

} DESC;

/* Statment information.  This is allocated by "SQLAllocStmt". */

typedef struct	tagSTMT {
   SQLHDBC hdbc;
   short eod;
   short status;
   int state;
   int row_count;
   int current_row;
   int stmt_no;
   int result;
   int query_len;
   int query_len_with_params;
   char query[2048];
   int param_count;
   int col_count;
   DESC *ard;
   DESC *ird;
   DESC *apd;
   DESC *ipd;
   MGERROR error;
}	STMT, *LPSTMT;


typedef struct	tagDBLK {
   short eod;
   char type;
   int dsize;
   char *pdata;
}	DBLK, *LPDBLK;


typedef struct	tagRECHEAD {
   int size;
   int stmt_no;
   char desc[8];
   char cmnd;
}	RECHEAD, *LPRECHEAD;


typedef struct	tagCOREDATA {
   short ftrace;
   short ntrace;
   short log_errors;
   int stmt_no;
   HINSTANCE ghInstance;
   char mod_path[256];
   char log_file[256];
   char log_filep[256];
   char log_level[32];
}	COREDATA, *LPCOREDATA;


extern COREDATA CoreData;

int            mg_cbuffer                 (unsigned char *buffer, int buffer_len, SQLCHAR *sqlbuffer, SQLSMALLINT sqlbuffer_len);
int            mg_qbuffer                 (STMT *stmt, SQLCHAR *sqlbuffer, SQLSMALLINT sqlbuffer_len);
int            mg_qaddparams              (STMT *stmt, SQLUINTEGER array_no, short context);
int            mg_set_record_head         (RECHEAD *rhead, char *buffer);
int            mg_get_record_head         (RECHEAD *rhead, char *buffer);
int            mg_get_next_stmt_no        (void);
int            mg_reset_stmt              (STMT *pstmt, short context);

int            mg_connect                 (DBC *pdbc);
int            mg_tcp_connect_ex          (SOCKET sockfd, LPSOCKADDR p_srv_addr, int srv_addr_len, int timeout);
int            mg_tcp_disconnect          (DBC *pdbc, int context);
int            mg_disconnect              (DBC *pdbc);

int            mg_log_level               (char *elfile, int len, char *log_level);
int            mg_log_file                (char *elfile, int len);
int            mg_log_event               (char *event, char *title, int context, void *pdb, int dbtype);
int            mg_log_buffer              (unsigned char *buffer, unsigned int len, char *title, int context, void *pdb, int dbtype);
int            mg_send                    (DBC *pdbc, char * buffer, int len);
int            mg_recv                    (DBC *pdbc, char * buffer, int len, int timeout, short context);
int            mg_get_last_error          (int context);
int            mg_get_error_message       (int error_code, char *message, int size, int context);

int            mg_get_block               (DBC *pdbc, DBLK ** pp_block, int timeout);
int            mg_get_cols                (STMT *pstmt, char *coldata);
int            mg_get_nvp                 (char *name, char *value, int valuelen, char *nvpdata);
int            mg_esize                   (char *esize, unsigned long dsize, short base);
unsigned long  mg_dsize                   (char *esize, int len, short base);

HANDLE         mg_mutex_create            (char * name);
int            mg_mutex_lock              (HANDLE mutex);
int            mg_mutex_release           (HANDLE mutex);
int            mg_mutex_destroy           (HANDLE mutex);

int            mg_ucase                   (char * string);
int            mg_lcase                   (char * string);
int            mg_parse_zv                (char *zv, MGZV * pmgzv);

int            mg_set_error               (MGERROR *error, char *sqlstate, int natcode, char *text, char *fun);

char *         mg_ctype_str               (int type);
int            mg_ctype                   (char * typestr);
char *         mg_sqltype_str             (int type);
int            mg_sqltype                 (char * typestr);
char *         mg_iotype_str              (int type);

