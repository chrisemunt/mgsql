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

COREDATA CoreData = {0, 0, 0, 0};

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD dwreason, LPVOID lpreserved)
{

   CoreData.ghInstance = hinst;

   switch (dwreason) {
      case DLL_PROCESS_ATTACH:
         CoreData.ftrace = 0;
         CoreData.ntrace = 0;
         CoreData.log_errors = 0;
/*
         CoreData.ftrace = 1;
         CoreData.ntrace = 1;
         strcpy(CoreData.log_file, "c:\\odbc\\odbc.log");
         strcpy(CoreData.log_filep, "c:\\odbc\\odbcp.log");
*/
         GetModuleFileName((HMODULE) hinst, CoreData.mod_path, 255);
         if (CoreData.ftrace == 1) {
            mg_log_event("DLL_PROCESS_ATTACH", "DllMain", 0, NULL, 0);
            mg_log_event(CoreData.mod_path, "DllMain", 0, NULL, 0);
         }
         break;
      case DLL_THREAD_ATTACH:
         if (CoreData.ftrace == 1) {
            mg_log_event("DLL_THREAD_ATTACH", "DllMain", 0, NULL, 0);
         }
         break;
      case DLL_PROCESS_DETACH:
         if (CoreData.ftrace == 1) {
            mg_log_event("DLL_PROCESS_DETACH", "DllMain", 0, NULL, 0);
         }
         break;
      case DLL_THREAD_DETACH:
         if (CoreData.ftrace == 1) {
            mg_log_event("DLL_THREAD_DETACH", "DllMain", 0, NULL, 0);
         }
         break;
   }
   return TRUE;
}


int mg_cbuffer(unsigned char *buffer, int buffer_len, SQLCHAR *sqlbuffer, SQLSMALLINT sqlbuffer_len)
{
   int len;

   if (sqlbuffer_len == SQL_NTS) {
      len = (int) strlen((char *) sqlbuffer);
   }
   else {
      len = (int) sqlbuffer_len;
   }

   if (len >= buffer_len) {
      len = buffer_len - 1;
   }
   if (len) {
      strncpy((char *) buffer, (char *) sqlbuffer, len);
   }
   buffer[len] = '\0';
   return len;
}


int mg_qbuffer(STMT *stmt, SQLCHAR *sqlbuffer, SQLSMALLINT sqlbuffer_len)
{
   int n, n1, param_count, len, len1;
   char in_string, *query;
   char ivar[8];

   if (sqlbuffer_len == SQL_NTS) {
      len = (int) strlen((char *) sqlbuffer);
   }
   else {
      len = (int) sqlbuffer_len;
   }

   query = stmt->query + MG_HEAD_SIZE;

   param_count = 0;
   in_string = 0;
   for (n = 0, n1 = 0; n < len; n ++) {

      query[n1 ++] = (char) sqlbuffer[n];
 
      /* in a string? */
      if ((char) sqlbuffer[n] == in_string) {
         if (sqlbuffer[n + 1] == in_string) /* Two quotes is ok */
            n ++;
         else
            in_string = 0;
         continue;
      }

      /* parameter marker? */
      if (!in_string) {
         if ((char) sqlbuffer[n] == '\'' || (char) sqlbuffer[n] == '"' || (char) sqlbuffer[n] == '`') { /* start of string? */
            in_string = (char) sqlbuffer[n];
            continue;
         }
         if ((char) sqlbuffer[n] == '?') {
            param_count ++;
            sprintf(ivar, ":iv%d", param_count);
            len1 = (int) strlen(ivar);
            n1 --;
            strncpy(query + n1, ivar, len1);
            n1 += (len1);
         }
      }
   }

   query[n1] = '\0';

   stmt->query_len = n1;
   stmt->query_len_with_params = n1;
   stmt->param_count = param_count;
   stmt->ipd->param_count = param_count;

   return n1;
}


int mg_qaddparams(STMT *stmt, SQLUINTEGER array_no, short context)
{
   int n, len;
   char buffer[256];
   char *p;

   if (context == 0) {
      p = stmt->query + MG_HEAD_SIZE + stmt->query_len;
      stmt->query_len_with_params = stmt->query_len;
      for (n = 0; n < stmt->ipd->param_count; n ++) {
         sprintf(buffer, "\r\n$:iv%d:%d:%d:%s\r\n", n + 1, (int) stmt->ipd->params[n].value_type, (int) stmt->ipd->params[n].parameter_type, (char *) stmt->ipd->params[n].parameter_value_ptr);
         len = (int) strlen(buffer);
         strcpy(stmt->query + MG_HEAD_SIZE + stmt->query_len_with_params, buffer);
         stmt->query_len_with_params += len;
      }
   }
   else {
      p = stmt->query + MG_HEAD_SIZE + stmt->query_len;
      stmt->query_len_with_params = stmt->query_len;
      for (n = 0; n < stmt->ipd->param_count; n ++) {
         stmt->ipd->coldat[n].bound = 1;
         stmt->ipd->params[n].parameter_value_ptr = ((char *) stmt->ipd->coldat0[n].pdata) + (array_no * stmt->ipd->row_array_element_size);
         stmt->ipd->params[n].strLen_or_indptr = (SQLLEN *) ((char *) stmt->ipd->coldat0[n].pactlen + (array_no * stmt->ipd->row_array_element_size));
/*
         {
            char buffer[256];
            sprintf(buffer, "mg_qaddparams: stmt_no=%d; array_no=%d; n=%d; stmt->ipd->coldat0[n].pdata=%p; stmt->ipd->params[n].parameter_value_ptr=%p; stmt->ipd->params[n].strLen_or_indptr=%p;", stmt->stmt_no, array_no, n, stmt->ipd->coldat0[n].pdata, stmt->ipd->params[n].parameter_value_ptr, stmt->ipd->params[n].strLen_or_indptr);
            mg_log_event(buffer, "mg_qaddparams : Parameter", 0, (void *) stmt, MG_DBT_STMT);
         }
*/
         sprintf(buffer, "\r\n$:iv%d:%d:%d:%s\r\n", n + 1, (int) stmt->ipd->params[n].value_type, (int) stmt->ipd->params[n].parameter_type, (char *) stmt->ipd->params[n].parameter_value_ptr);
         len = (int) strlen(buffer);
         strcpy(stmt->query + MG_HEAD_SIZE + stmt->query_len_with_params, buffer);
         stmt->query_len_with_params += len;
      }
   }

   return stmt->query_len;
}


int mg_set_record_head(RECHEAD *rhead, char *buffer)
{
   int n;

#ifdef _WIN32
__try {
#endif

   strncpy(buffer, "00000000000000000000", MG_HEAD_SIZE);

   mg_esize(buffer, rhead->size, MG_NBASE);

   n = (int) strlen(rhead->desc);
   if (n) {
      strncpy(buffer + 4, rhead->desc, 5);
   }

   mg_esize(buffer + 9, rhead->stmt_no, MG_NBASE);

   buffer[13] = rhead->cmnd;
/*
{
   char buf[256];
   sprintf(buf, "mg_set_record_head; rhead->size(%d): %x:%x:%x:%x rhead->stmt_no(%d): %x:%x:%x:%x", rhead->size, (unsigned char) buffer[0], (unsigned char) buffer[1], (unsigned char) buffer[2], (unsigned char) buffer[3], rhead->stmt_no, (unsigned char) buffer[9], (unsigned char) buffer[10], (unsigned char) buffer[11], (unsigned char) buffer[12]);
   mg_log_buffer((unsigned char *) buffer, MG_HEAD_SIZE, buf, 0, NULL, 0);
}
*/

   n = 1;

   return n;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_set_record_head(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_get_record_head(RECHEAD *rhead, char *buffer)
{
   int n;
   char buf[256];

#ifdef _WIN32
__try {
#endif

   strncpy(buf, buffer, 4);
   rhead->size = (int) strtol(buf, NULL, 10);

   strncpy(rhead->desc, buffer + 4, 5);
   rhead->desc[4 + 5] = '\0';
   rhead->cmnd = buffer[13];

   n = 1;

   return n;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_get_record_head(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_get_next_stmt_no(void)
{
   int stmt_no;

#ifdef _WIN32
__try {
#endif

   CoreData.stmt_no ++;
   stmt_no = CoreData.stmt_no;

   return stmt_no;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_get_next_stmt_no(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_reset_stmt(STMT * pstmt, short context)
{
   int n;

#ifdef _WIN32
__try {
#endif

   pstmt->row_count = 0;
   pstmt->status = 0;
   pstmt->eod = 0;
   pstmt->error.status = 0;

   for (n = 0; n < MG_MAX_COLS; n ++) {
      pstmt->ird->coldat[n].bound = 0;
      pstmt->ird->coldat[n].type = 0;
      pstmt->ird->coldat[n].pdata = NULL;
      pstmt->ird->coldat[n].pactlen = NULL;
      pstmt->ird->coldat[n].actlen = 0;
      pstmt->ird->coldat[n].maxlen = 0;

      pstmt->ird->coldat[n].rdata_size = 0;
      pstmt->ird->coldat[n].rdata = NULL;

      pstmt->ird->coldat[n].data.str = NULL;
   }

   return 0;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_get_next_stmt_no(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_connect(DBC *pdbc)
{
   short physical_ip, ipv6, getaddrinfo_ok;
   int n, connected, errorno;
   unsigned long inetaddr, spin_count;
   static struct sockaddr_in cli_addr, srv_addr;
   struct sockaddr_in sa, ca;
   struct hostent *hp;
   struct in_addr **pptr;
   char ip_address[64];
#ifdef _WIN32
   WORD VersionRequested;
#endif

#ifdef _WIN32
__try {
#endif

   ipv6 = 1;
   connected = 0;
   pdbc->pb_error = 0;
   strcpy(pdbc->error.text, "");

#ifdef _WIN32
   /* VersionRequested = 0x101; */
   VersionRequested = MAKEWORD(2, 2);
   n = WSAStartup(VersionRequested, &(pdbc->wsadata));
   if (n != 0) {
      strcpy(pdbc->error.text, "Microsoft WSAStartup Failed");
      return 0;
   }
#endif

   strcpy(ip_address, pdbc->server);

   if (ipv6) {
      short mode;
      struct addrinfo hints, *res;
      struct addrinfo *ai;
      char port_str[32];
/*
	   int off = 0;
	   int ipv6_v6only = 27;
*/
      res = NULL;
      sprintf(port_str, "%d", pdbc->port);
      connected = 0;
      pdbc->pb_error = 0;

      for (mode = 0; mode < 3; mode ++) {

         if (res) {
            freeaddrinfo(res);
            res = NULL;
         }

         memset(&hints, 0, sizeof hints);
         hints.ai_family = AF_UNSPEC;     /* Use IPv4 or IPv6 */
         hints.ai_socktype = SOCK_STREAM;
         /* hints.ai_flags = AI_PASSIVE; */
         if (mode == 0)
            hints.ai_flags = AI_NUMERICHOST | AI_CANONNAME;
         else if (mode == 1)
            hints.ai_flags = AI_CANONNAME;
         else if (mode == 2) {
            /* Apparently an error can occur with AF_UNSPEC (See RJW1564) */
            /* This iteration will return IPV6 addresses if any */
            hints.ai_flags = AI_CANONNAME;
            hints.ai_family = AF_INET6;
         }
         else
            break;

         n = getaddrinfo(ip_address, port_str, &hints, &res);
         if (n != 0) {
            continue;
         }

         getaddrinfo_ok = 1;
         spin_count = 0;
         for (ai = res; ai != NULL; ai = ai->ai_next) {

            spin_count ++;

            if (spin_count > 10000) {
               mg_log_event((char *) "Possible infinite loop encountered while resetting the connection", (char *) "Diagnostic: sys_tcp_connect(): 1", 0, NULL, 0);
            }


	         if (ai->ai_family != AF_INET && ai->ai_family != AF_INET6) {
               continue;
            }

	         /* Open a socket with the correct address family for this address. */
	         pdbc->sockfd = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
            /* bind(pdbc->sockfd, ai->ai_addr, (int) (ai->ai_addrlen)); */
            /* connect(pdbc->sockfd, ai->ai_addr, (int) (ai->ai_addrlen)); */

            if (0) {

               int flag = 1;
               int result;

               result = setsockopt(pdbc->sockfd, IPPROTO_TCP, TCP_NODELAY, (const char *) &flag, sizeof(int));
               if (result < 0) {
                  mg_log_event((char *) "Unable to disable the Nagle Algorithm", (char *) "Connection Error", 0, NULL, 0);
               }
/*
               else {
                  mg_log_event((char *) "Nagle Algorithm disabled", (char *) "Connection Information", 0, NULL, 0);
               }
*/
            }

            pdbc->pb_error = 0;
            n = mg_tcp_connect_ex(pdbc->sockfd, (LPSOCKADDR) ai->ai_addr, (int) (ai->ai_addrlen), pdbc->login_timeout);

            if (n == -2) {
               pdbc->pb_error = n;
               n = -737;
               continue;
            }
            if (SOCK_ERROR(n)) {
               errorno = (int) mg_get_last_error(0);
               pdbc->pb_error = errorno;
               mg_tcp_disconnect(pdbc, 0);
               continue;
            }
            else {
               connected = 1;
               break;
            }
         }
         if (connected)
            break;
      }

      if (pdbc->pb_error) {
         char message[256];

         mg_get_error_message(pdbc->pb_error, message, 250, 0);
         T_SPRINTF(pdbc->error.text, _mgso(pdbc->error.text), "Cannot Connect to Server (%s:%d): Error Code: %d (%s)", (char *) pdbc->server, pdbc->port, pdbc->pb_error, message);
         n = -5;
         if (1)
            mg_log_event(pdbc->error.text, (char *) "Connection Error", -1, NULL, 0);
      }

      if (res) {
         freeaddrinfo(res);
         res = NULL;
      }

      if (connected) {
         return 1;
      }
      else {
         if (getaddrinfo_ok) {
            mg_tcp_disconnect(pdbc, 0);
            return -5;
         }
         else {
            char message[256];

            strcpy(message, "Cannot identify Server");
            mg_log_event(message, (char *) "Connection Error", 0, NULL, 0);
            mg_tcp_disconnect(pdbc, 0);
            return -5;
         }
      }
   }

   inetaddr = inet_addr(ip_address);

   physical_ip = 0;
   if (isdigit(ip_address[0])) {
      char *p;

      if (p = strstr(ip_address, ".")) {
         if (isdigit(*(++ p))) {
            if (p = strstr(p, ".")) {
               if (isdigit(*(++ p))) {
                  if (p = strstr(p, ".")) {
                     if (isdigit(*(++ p))) {
                        physical_ip = 1;
                     }
                  }
               }
            }
         }
      }
   }


   if (inetaddr == INADDR_NONE || !physical_ip) {

      if ((hp = gethostbyname((const char *) ip_address)) == NULL) {
         n = -2;
         strcpy(pdbc->error.text, "Invalid Host Name");
         return 0;
      }

      pptr = (struct in_addr **) hp->h_addr_list;

      connected = 0;

      for (; *pptr != NULL; pptr ++) {

         pdbc->sockfd = socket(AF_INET, SOCK_STREAM, 0);
         if (pdbc->sockfd < 0) {
            n = -2;
            strcpy(pdbc->error.text, "Invalid Socket");
            connected = -1;
            break;
         }

#if defined(CSP_UNIX) || defined(CSP_VMS)
         bzero((char *) &ca, sizeof(ca));
         bzero((char *) &sa, sizeof(sa));
#endif

         ca.sin_family = AF_INET;
         sa.sin_port = htons((unsigned short) pdbc->port);

         ca.sin_addr.s_addr = htonl(INADDR_ANY);
         ca.sin_port = htons(0);
         n = bind(pdbc->sockfd, (const struct sockaddr *) &ca, sizeof(ca));
         if (n < 0) {
            n = -3;
            strcpy(pdbc->error.text, "Cannot bind to Socket");
            connected = -1;
            break;

         }

         sa.sin_family = AF_INET;
         sa.sin_port = htons((unsigned short) pdbc->port);

         memcpy(&sa.sin_addr, *pptr, sizeof(struct in_addr));

         n = mg_tcp_connect_ex(pdbc->sockfd, (LPSOCKADDR) &srv_addr, sizeof(srv_addr), pdbc->login_timeout);

         if (n == -2) {
            pdbc->pb_error = n;
            n = -737;
            continue;
         }

         if (SOCK_ERROR(n)) {
            char message[256];

            errorno = (int) mg_get_last_error(0);
            mg_get_error_message(errorno, message, 250, 0);

            pdbc->pb_error = errorno;

            T_SPRINTF(pdbc->error.text, _mgso(pdbc->error.text), "Cannot Connect to Server (%s:%d): Error Code: %d (%s)", (char *) pdbc->server, pdbc->port, errorno, message);
            n = -5;
            if (1)
               mg_log_event(pdbc->error.text, (char *) "Connection Error", -1, NULL, 0);
            mg_tcp_disconnect(pdbc, 0);
            continue;
         }
         else {
            connected = 1;
            break;
         }
      }

      if (connected == -1)
         return 0;
   }
   else {

#ifndef _WIN32
      bzero((char *) &srv_addr, sizeof(srv_addr));
#endif

      srv_addr.sin_port = htons((unsigned short) pdbc->port);
      srv_addr.sin_family = AF_INET;
      srv_addr.sin_addr.s_addr = inet_addr(pdbc->server);

      pdbc->sockfd = socket(AF_INET, SOCK_STREAM, 0);
      if (pdbc->sockfd < 0) {
         strcpy(pdbc->error.text, "Can't open a stream-socket to the Web Service Integrator");

#ifdef _WIN32
         WSACleanup();
#endif

         return 0;
      }

#ifndef _WIN32
      bzero((char *) &cli_addr, sizeof(cli_addr));
#endif

      cli_addr.sin_family = AF_INET;
      cli_addr.sin_addr.s_addr = htonl(INADDR_ANY);
      cli_addr.sin_port = htons(0);

      n = bind(pdbc->sockfd, (struct sockaddr *) &cli_addr, sizeof(cli_addr));

#ifdef _WIN32
      if (n < 0) {
         strcpy(pdbc->error.text, "Can't bind to local address for access to the Web Service Integrator");
         mg_disconnect(pdbc);
         return 0;
      }
#endif
      n = mg_tcp_connect_ex(pdbc->sockfd, (LPSOCKADDR) &srv_addr, sizeof(srv_addr), pdbc->login_timeout);

      if (n < 0) {
         strcpy(pdbc->error.text, "Can't connect to the Web Service Integrator");
         mg_disconnect(pdbc);
         return 0;
      }
   }
   return 1;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_connect(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_tcp_connect_ex(SOCKET sockfd, LPSOCKADDR p_srv_addr, int srv_addr_len, int timeout)
{
#ifdef _WIN32
   int n;
#else
   int flags, n, error;
   int len;
   fd_set rset, wset;
   struct timeval tval;
#endif

#if defined(SOLARIS) && BIT64PLAT
   timeout = 0;
#endif

   /* It seems that BIT64PLAT is set to 0 for 64-bit Solaris:  So, to be safe .... */

#if defined(SOLARIS)
   timeout = 0;
#endif

   if (timeout != 0) {

#if defined(_WIN32)

      n = connect(sockfd, (LPSOCKADDR) p_srv_addr, srv_addr_len);

      return n;

#else
      flags = fcntl(sockfd, F_GETFL, 0);
      fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

      error = 0;

      n = connect(sockfd, (LPSOCKADDR) p_srv_addr, srv_addr_len);

      if (n < 0) {

         if (errno != EINPROGRESS) {
            return -1;
         }
      }

      if (n != 0) {

         FD_ZERO(&rset);
         FD_SET(sockfd, &rset);

         wset = rset;
         tval.tv_sec = timeout;
         tval.tv_usec = timeout;

         n = select((int) (sockfd + 1), &rset, &wset, NULL, &tval);

         if (n == 0) {
            close(sockfd);
            errno = ETIMEDOUT;
            return (-2);
         }
         if (FD_ISSET(sockfd, &rset) || FD_ISSET(sockfd, &wset)) {

            len = sizeof(error);
            if (getsockopt(sockfd, SOL_SOCKET, SO_ERROR, (void *) &error, &len) < 0) {
               return (-1);
            }
         }
         else {
            ;
         }
      }

      fcntl(sockfd, F_SETFL, flags); /* Restore file status flags */

      if (error) {
         close(sockfd);
         errno = error;
         return (-1);
      }

      return 1;

#endif

   }
   else {

      n = connect(sockfd, (LPSOCKADDR) p_srv_addr, srv_addr_len);

      return n;
   }

}


int mg_tcp_disconnect(DBC *pdbc, int context)
{
   int n;

   if (!pdbc) {
      return 0;
   }

   if (pdbc->sockfd != (SOCKET) 0) {

#ifdef _WIN32
      n = closesocket(pdbc->sockfd);
/*
      WSACleanup();
*/
#else /* UNIX */
      n = close(pdbc->cli_socket);
#endif

   }

   return 0;

}


int mg_disconnect(DBC *pdbc)
{
#ifdef _WIN32
__try {
#endif

#ifdef _WIN32
   closesocket(pdbc->sockfd);
   WSACleanup();
#else

   {
      int n;
      struct linger ling;
      ling.l_onoff = 1;
      ling.l_linger = 0;

      n = setsockopt(pdbc->sockfd, SOL_SOCKET, SO_LINGER, (void *) &ling, sizeof(ling));
   }

   close(pdbc->sockfd);
#endif

   return 1;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_disconnect(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}



int mg_send(DBC *pdbc, char * buffer, int len)
{
   int n, sent;

#ifdef _WIN32
__try {
#endif

   sent = 0;
   for (;;) {
      n = send(pdbc->sockfd, buffer + sent, len - sent, 0);
      if (n < 1)
         break;
      sent += n;
      if (sent >= len)
         break;
   }

   if (CoreData.ntrace) {
      char buf[1024];
      buffer[sent] = '\0';
      sprintf(buf, "mg_send: bytes sent=%d;", sent);
      mg_log_buffer(buffer, len, buf, 0, NULL, 0);
   }

   return sent;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_send(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_recv(DBC *pdbc, char * buffer, int len, int timeout, short context)
{
   int n, got;

#ifdef _WIN32
__try {
#endif

   if (len < 1)
      return 0;
/*
{
   char buffer[1024];
   sprintf(buffer, "len=%d; context=%d", len, context);
   mg_log_event(buffer, "mg_recv get some data", 0, NULL, 0);
}
*/

   if (context) {

      got = 0;
      while (got < len) {
         n = recv(pdbc->sockfd, buffer + got, len - got, 0);
         if (n < 1)
            break;
         got += n;
         if (got == len) {
            n = len;
         }
      }
   }
   else {
      n = recv(pdbc->sockfd, buffer, len, 0);
   }

   if (CoreData.ntrace) {
      char buf[1024];
      if (n > 0) {
         buffer[n] = '\0';
         sprintf(buf, "mg_recv: n=%d; bytes received=%d; context=%d", n, len, context);
         mg_log_buffer(buffer, n, buf, 0, NULL, 0);
      }
      else {
         sprintf(buf, "mg_recv: n=%d; bytes received=%d; context=%d", n, len, context);
         mg_log_event("No Data", buf, 0, NULL, 0);
      }
   }

   return n;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_recv(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_get_last_error(int context)
{
   int error_code;

#if defined(_WIN32)
   if (context)
      error_code = (int) GetLastError();
   else
      error_code = (int) WSAGetLastError();
#else
   error_code = (int) errno;
#endif

   return error_code;
}


int mg_get_error_message(int error_code, char *message, int size, int context)
{
   *message = '\0';

#if defined(_WIN32)

   if (context == 0) {
      short ok;
      int len;
      char *p;
      LPVOID lpMsgBuf;

      ok = 0;
      lpMsgBuf = NULL;
      len = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                           NULL,
                           error_code,
                           /* MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), */
                           MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
                           (LPTSTR) &lpMsgBuf,
                           0,
                           NULL 
                           );
      if (len && lpMsgBuf) {
         strncpy(message, (const char *) lpMsgBuf, size);
         p = strstr(message, "\r\n");
         if (p)
            *p = '\0';
         ok = 1;
      }
      if (lpMsgBuf)
         LocalFree(lpMsgBuf);

      if (!ok) {
         switch (error_code) {
            case EXCEPTION_ACCESS_VIOLATION:
               T_STRNCPY(message, size, "The thread attempted to read from or write to a virtual address for which it does not have the appropriate access.", size);
               break;
            case EXCEPTION_BREAKPOINT:
               T_STRNCPY(message, size, "A breakpoint was encountered.", size); 
               break;
            case EXCEPTION_DATATYPE_MISALIGNMENT:
               T_STRNCPY(message, size, "The thread attempted to read or write data that is misaligned on hardware that does not provide alignment. For example, 16-bit values must be aligned on 2-byte boundaries, 32-bit values on 4-byte boundaries, and so on.", size);
               break;
            case EXCEPTION_SINGLE_STEP:
               T_STRNCPY(message, size, "A trace trap or other single-instruction mechanism signaled that one instruction has been executed.", size);
               break;
            case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
               T_STRNCPY(message, size, "The thread attempted to access an array element that is out of bounds, and the underlying hardware supports bounds checking.", size);
               break;
            case EXCEPTION_FLT_DENORMAL_OPERAND:
               T_STRNCPY(message, size, "One of the operands in a floating-point operation is denormal. A denormal value is one that is too small to represent as a standard floating-point value.", size);
               break;
            case EXCEPTION_FLT_DIVIDE_BY_ZERO:
               T_STRNCPY(message, size, "The thread attempted to divide a floating-point value by a floating-point divisor of zero.", size);
               break;
            case EXCEPTION_FLT_INEXACT_RESULT:
               T_STRNCPY(message, size, "The result of a floating-point operation cannot be represented exactly as a decimal fraction.", size);
               break;
            case EXCEPTION_FLT_INVALID_OPERATION:
               T_STRNCPY(message, size, "This exception represents any floating-point exception not included in this list.", size);
               break;
            case EXCEPTION_FLT_OVERFLOW:
               T_STRNCPY(message, size, "The exponent of a floating-point operation is greater than the magnitude allowed by the corresponding type.", size);
               break;
            case EXCEPTION_FLT_STACK_CHECK:
               T_STRNCPY(message, size, "The stack overflowed or underflowed as the result of a floating-point operation.", size);
               break;
            case EXCEPTION_FLT_UNDERFLOW:
               T_STRNCPY(message, size, "The exponent of a floating-point operation is less than the magnitude allowed by the corresponding type.", size);
               break;
            case EXCEPTION_INT_DIVIDE_BY_ZERO:
               T_STRNCPY(message, size, "The thread attempted to divide an integer value by an integer divisor of zero.", size);
               break;
            case EXCEPTION_INT_OVERFLOW:
               T_STRNCPY(message, size, "The result of an integer operation caused a carry out of the most significant bit of the result.", size);
               break;
            case EXCEPTION_PRIV_INSTRUCTION:
               T_STRNCPY(message, size, "The thread attempted to execute an instruction whose operation is not allowed in the current machine mode.", size);
               break;
            case EXCEPTION_NONCONTINUABLE_EXCEPTION:
               T_STRNCPY(message, size, "The thread attempted to continue execution after a noncontinuable exception occurred.", size);
               break;
            default:
               T_STRNCPY(message, size, "Unrecognised system or hardware error.", size);
            break;
         }
      }
   }

#endif

   message[size - 1] = '\0';

   return (int) strlen(message);
}


int mg_get_block(DBC *pdbc, DBLK ** pp_block, int timeout)
{
   int n, len, result;
   char *p;
   char buffer[256];

#ifdef _WIN32
__try {
#endif

   *pp_block = NULL;

   n = mg_recv(pdbc, buffer, MG_HEAD_SIZE, 0, 1);
/*
if (strstr(buffer, "/usr/local/lib")) {
   n = mg_recv(pdbc, buffer + MG_HEAD_SIZE, 80, 0, 1);
}
*/

   if (n != MG_HEAD_SIZE) {
      return 0;
   }


   len = mg_dsize(buffer, 4, MG_NBASE);
/*
{
   char buf[256];
   sprintf(buf, "mg_get_block:mg_dsize; n=%d; data_size=%d %x:%x:%x:%x", n, len, (unsigned char) buffer[0], (unsigned char) buffer[1], (unsigned char) buffer[2], (unsigned char) buffer[3]);
   mg_log_buffer((unsigned char *) buffer, MG_HEAD_SIZE, buf, 0, NULL, 0);
}
*/
   *pp_block = (DBLK *) malloc(sizeof(DBLK) + (sizeof(char) * (len + 4)));
   if (!(*pp_block)) {
      return 0;
   }

   p = (char *) (*pp_block);
   p += sizeof(DBLK);
   (*pp_block)->pdata = p;
   (*pp_block)->pdata[0] = '\0';

   (*pp_block)->dsize = len;
   (*pp_block)->type = buffer[13];
   if (buffer[12] == '1')
      (*pp_block)->eod = 1;
   else
      (*pp_block)->eod = 0;

   n = mg_recv(pdbc, (*pp_block)->pdata, len, 0, 1);

   (*pp_block)->pdata[len] = '\0';
   result = len;
/*
{
   char buf[256];
   sprintf(buf, "mg_get_block:mg_dsize:data; n=%d; len=%d", n, len);
   mg_log_buffer((unsigned char *) (*pp_block)->pdata, n, buf, 0, NULL, 0);
}
*/

   if (n != len) {
      free((void *) *pp_block);
      *pp_block = NULL;
      result = 0;
   }

   return result;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_get_block(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_get_cols(STMT *pstmt, char *coldata)
{
   int no, len, pn;
   char *p, *pz, *p1, *p2, *pt;

#ifdef _WIN32
__try {
#endif

   pstmt->ird->col_count = 0;
   pstmt->col_count = 0;
   no = 0;
   p = coldata;
   for (;;) {
      pz = strstr(p, "\r\n");
      *pz = '\0';
      len = (int) strlen(p);
      if (!len) {
         break;
      }
      pn = 0;
      p1 = p;

      strcpy(pstmt->ird->cols[no].type, "VARCHAR");
      pstmt->ird->cols[no].type_len = 256;
      pstmt->ird->cols[no].type_id = mg_sqltype(pstmt->ird->cols[no].type);

      while ((p2 = strstr(p1,"~"))) {
         *p2 = '\0';
         if (pn == 0) {
            pstmt->ird->col_count = (int) strtol(p1, NULL, 10);
         }
         else if (pn == 1) {
            strcpy(pstmt->ird->cols[no].cname, p1);
         }
         else if (pn == 2) {
            strcpy(pstmt->ird->cols[no].tname, p1);
         }
         else if (pn == 3) {
            strcpy(pstmt->ird->cols[no].type, p1);
            pt = strstr(pstmt->ird->cols[no].type, "(");
            if (pt) {
               pstmt->ird->cols[no].type_len = (int) strtol(p + 1, NULL, 10);
               *pt = '\0';
            }
            mg_ucase(pstmt->ird->cols[no].type);
            pstmt->ird->cols[no].type_id = mg_sqltype(pstmt->ird->cols[no].type);
         }
         pn ++;
         *p2 = '\0';
         p1 = p2 + 1;
      }
      strcpy(pstmt->ird->cols[no].dbid, "mgsql");
      no ++;
      *pz = '\r';
      p = pz + 2;
   }

   pstmt->col_count = pstmt->ird->col_count;

   return no;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_get_cols(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}



int mg_get_nvp(char *name, char *value, int valuelen, char *nvpdata)
{
   int result, len;
   char *p, *p1;
   char token[256];

#ifdef _WIN32
__try {
#endif

   result = 0;
   *value = '\0';
   strcpy(token, name);
   strcat(token, "=");

   p = strstr(nvpdata, token);
   if (p) {
      p += strlen(token);
      p1 = strstr(p, "\r\n");
      if (p1) {
         len = (int) (p1 - p);
         strncpy(value, p, len);
         value[len] = '\0';
         result = len;
      }
   }
   return result;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_get_nvp(): %x", code);
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
   block->buf_addr[offset + 0] = (unsigned char) (data_len >> 0);
   block->buf_addr[offset + 1] = (unsigned char) (data_len >> 8);
   block->buf_addr[offset + 2] = (unsigned char) (data_len >> 16);
   block->buf_addr[offset + 3] = (unsigned char) (data_len >> 24);
*/
/*
   size = ((unsigned char) str[0]) | (((unsigned char) str[1]) << 8) | (((unsigned char) str[2]) << 16) | (((unsigned char) str[3]) << 24);
*/
int mg_esize(char *esize, unsigned long dsize, short base)
{
#ifdef _WIN32
__try {
#endif

#if 1
   esize[0] = (unsigned char) (dsize & 0xff);
   esize[1] = (unsigned char) ((dsize & 0xff00) >> 8);
   esize[2] = (unsigned char) ((dsize & 0xff0000) >> 16);
   esize[3] = (unsigned char) ((dsize & 0xff000000) >> 24);

   return 1;

#else

   {
      int n;
      char buffer[32];

      for (n = 0; n < 4; n ++) {
         esize[n] = '0';
      }

      sprintf(buffer, "%d", dsize);
      n = (int) strlen(buffer);
      strncpy(esize + (4 - n), buffer, n);

      return 1;
   }
#endif

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_esize(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}

unsigned long mg_dsize(char *esize, int len, short base)
{
#ifdef _WIN32
__try {
#endif

#if 1
   unsigned long dsize;
/*
{
   char buffer[256];
   sprintf(buffer, "%x:%x:%x:%x",  (unsigned char) esize[0],  (unsigned char) esize[1],  (unsigned char) esize[2],  (unsigned char) esize[3]);
   mg_log_event(buffer, "mg_dsize", 0, (void *) NULL, 0);
}
*/
   dsize = 0;
   dsize = ((unsigned char) esize[0])
            | (((unsigned char) esize[1]) << 8)
            | (((unsigned char) esize[2]) << 16)
            | (((unsigned char) esize[3]) << 24);

   return dsize;

#else
{
   unsigned long dsize;
   char buffer[32];

   strncpy(buffer, esize, len);
   buffer[len] = '\0';
   dsize = (int) strtol(buffer, NULL, 10);
   return dsize;
}
#endif

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_dsize(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}



int mg_set_error(MGERROR *error, char *sqlstate, int natcode, char *text, char *fun)
{
   int offs;

   offs = 0;
   error->status = 1;
   strcpy(error->sqlstate, sqlstate);
   if (text[0] == ':' && text[6] == ':') {
      strncpy(error->sqlstate, text + 1, 5);
      error->sqlstate[6] = '\0';
      offs = 7;
   }
   strcpy(error->text, text + offs);
   strcpy(error->fun, fun);
   error->natcode = natcode;

   return 1;
}




HANDLE mg_mutex_create(char * name)
{
   HANDLE mutex;

#ifdef _WIN32
__try {
#endif

   mutex = CreateMutex(NULL, FALSE, name);

   return mutex;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_mutex_create(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return (HANDLE) 0;
}
#endif

}


int mg_mutex_lock(HANDLE mutex)
{
   int result;
   DWORD dwWaitResult;

#ifdef _WIN32
__try {
#endif

   result = 0;

   dwWaitResult = WaitForSingleObject(mutex, 60000L);
   if (dwWaitResult == WAIT_OBJECT_0 || dwWaitResult != 999)
      result = 1;
   else {
      result = 0;
   }

   return result;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_mutex_lock(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_mutex_release(HANDLE mutex)
{
   int result;

#ifdef _WIN32
__try {
#endif

   result = 0;
   if (!ReleaseMutex(mutex)) {
      result = -1;
   }

   return result;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_mutex_release(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_mutex_destroy(HANDLE mutex)
{
#ifdef _WIN32
__try {
#endif

   return 1;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_mutex_destroy(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_ucase(char * string)
{
  int n, chr;

#ifdef _WIN32
__try {
#endif

   n = 0;
   while (string[n] != '\0') {
      chr = (int) string[n];
      if (chr >= 97 && chr <= 122)
         string[n] = (char) (chr - 32);
      n ++;
   }
   return 1;

#ifdef _WIN32
}
#if defined(CSP_WINDUMP)
__except ((CoreData.dump_status == CSP_WINDUMP_ON) ? EXCEPTION_CONTINUE_SEARCH : EXCEPTION_EXECUTE_HANDLER) {
#else
__except (EXCEPTION_EXECUTE_HANDLER) {
#endif

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_ucase(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_lcase(char * string)
{
   int n, chr;

#ifdef _WIN32
__try {
#endif

   n = 0;
   while (string[n] != '\0') {
      chr = (int) string[n];
      if (chr >= 65 && chr <= 90)
         string[n] = (char) (chr + 32);
      n ++;
   }
   return 1;

#ifdef _WIN32
}
#if defined(CSP_WINDUMP)
__except ((CoreData.dump_status == CSP_WINDUMP_ON) ? EXCEPTION_CONTINUE_SEARCH : EXCEPTION_EXECUTE_HANDLER) {
#else
__except (EXCEPTION_EXECUTE_HANDLER) {
#endif

   DWORD code;
   char buffer[256];

   __try {
      code = GetExceptionCode();
      sprintf(buffer, "Exception caught in mg_lcase(): %x", code);
      mg_log_event(buffer, "Error Condition", 0, NULL, 0);
   }
   __except (EXCEPTION_EXECUTE_HANDLER) {
      ;
   }

   return 0;
}
#endif

}


int mg_parse_zv(char *zv, MGZV * pmgzv)
{
   int result;
   double sys_version;
   char *p, *p1, *p2;

   /*
      GT.M V6.3-004 Linux x86_64
      Cache for Windows (x86-64) 2018.1 (Build 238U) Wed Jun 21 2017 01:23:03 EDT
   */

   pmgzv->sys_type = 0;
   pmgzv->sys_version = 0;
   pmgzv->majorversion = 0;
   pmgzv->minorversion = 0;
   pmgzv->sys_build = 0;

   strcpy(pmgzv->zv, zv);

   result = 0;
   p = zv;
   sys_version = 0;

   if (strstr(zv, "GT.M")) {
      pmgzv->sys_type = MG_SYS_YDB;
      strcpy(pmgzv->short_name, "YottaDB");
      p = strstr(zv, "V");
      if (p) {
         pmgzv->sys_version = strtod(p + 1, NULL);
         pmgzv->majorversion = (int) strtol(p + 1, NULL, 10);
         p1 = strstr(p, ".");
         if (p1) {
            pmgzv->minorversion = (int) strtol(p1 + 1, NULL, 10);
         }
         p1 = strstr(p, "-");
         if (p1) {
            pmgzv->sys_build = (int) strtol(p1 + 1, NULL, 10);
         }
      }
   }
   else if (strstr(zv, "Cache") || strstr(zv, "IRIS")) {
      pmgzv->sys_type = MG_SYS_IDB;
      if (strstr(zv, "IRIS"))
         strcpy(pmgzv->short_name, "InterSystems IRIS");
      else
         strcpy(pmgzv->short_name, "InterSystems Cache");

      while (*(++ p)) {
         if (*(p - 1) == ' ' && isdigit((int) (*p))) {
            sys_version = strtod(p, NULL);
            if (*(p + 1) == '.' && sys_version >= 1.0 && sys_version <= 5.2)
               break;
            else if (*(p + 4) == '.' && sys_version >= 2000.0)
               break;
            sys_version = 0;
         }
      }

      if (sys_version > 0) {
         pmgzv->sys_version = sys_version;
         pmgzv->majorversion = (int) strtol(p, NULL, 10);
         p1 = strstr(p, ".");
         if (p1) {
            pmgzv->minorversion = (int) strtol(p1 + 1, NULL, 10);
         }
         p2 = strstr(p, "Build ");
         if (p2) {
            pmgzv->sys_build = (int) strtol(p2 + 6, NULL, 10);
         }

         result = 1;
      }
   }
   else if (strstr(zv, "MSM")) {
      pmgzv->sys_type = MG_SYS_MSM;
      strcpy(pmgzv->short_name, "MSM");
   }
   else if (strstr(zv, "DSM")) {
      pmgzv->sys_type = MG_SYS_DSM;
      strcpy(pmgzv->short_name, "DSM");
   }
   else if (strstr(zv, "M21")) {
      pmgzv->sys_type = MG_SYS_M21;
      strcpy(pmgzv->short_name, "M21");
   }

   return result;
}


int mg_log_level(char *elfile, int len, char *log_level)
{
   int len1;
   char *p;

   len1 = (int) strlen(elfile);
   if (!len1) {
      mg_log_file(elfile, len);
   }

   strcpy(CoreData.log_filep, elfile);
   p = strstr(CoreData.log_filep, MG_LOG_FILE);
   if (p) {
      strcpy(p, MG_LOG_FILEP);
   }
   else {
      strcpy(CoreData.log_filep, MG_LOG_FILEP);
   }

   CoreData.ftrace = 0;
   CoreData.ntrace = 0;
   CoreData.log_errors = 0;

   mg_lcase(CoreData.log_level);
   p = strstr(CoreData.log_level, "e");
   if (p)
      CoreData.log_errors = 1;
   p = strstr(CoreData.log_level, "ft");
   if (p)
      CoreData.ftrace = 1;
   p = strstr(CoreData.log_level, "nt");
   if (p)
      CoreData.ntrace = 1;

   return 0;
}


int mg_log_file(char *elfile, int len)
{
   int n1, len1;

   strcpy(elfile, CoreData.mod_path);
   len1 = (int) strlen(elfile);
   if (len1) {
      for (n1 = len1; n1 > 0; n1 --) {
         if (elfile[n1] == '/' || elfile[n1] == '\\') {
            elfile[n1 + 1] = '\0';
            strcat(elfile, MG_LOG_FILE);
            break;
         }
      }
   }
   len1 = (int) strlen(elfile);
   if (len1 == 0) {
      strcpy(elfile, MG_LOG_FILE);
   }

   return 0;
}


int mg_log_event(char *event, char *title, int context, void *pdb, int dbtype)
{
   int len, n;
   FILE *fp = NULL;
   char timestr[64], heading[256], buffer[2048];
   char *p_buffer;
   time_t now = 0;
   HANDLE hLogfile = 0;
   DWORD dwPos = 0, dwBytesWritten = 0;
   DWORD tid, pid;

#ifdef _WIN32
__try {
#endif

   now = time(NULL);
   sprintf(timestr, "%s", ctime(&now));
   for (n = 0; timestr[n] != '\0'; n ++) {
      if ((unsigned int) timestr[n] < 32) {
         timestr[n] = '\0';
         break;
      }
   }

   pid = GetCurrentProcessId();
   tid = GetCurrentThreadId();

   sprintf(heading, ">>> Time: %s; Build: %s; pid=%ld; tid=%ld", timestr, MG_VERSION, pid, tid);

   len = (int) (strlen(heading) + strlen(title) + strlen(event) + 20);

   if (len < 2000)
      p_buffer = buffer;
   else
      p_buffer = (char *) malloc(sizeof(char) * len);

   if (p_buffer == NULL)
      return 0;

   p_buffer[0] = '\0';
   strcpy(p_buffer, heading);
   strcat(p_buffer, "\r\n    ");
   strcat(p_buffer, title);
   strcat(p_buffer, "\r\n    ");
   strcat(p_buffer, event);
   len = (int) strlen(p_buffer) * sizeof(char);


   strcat(p_buffer, "\r\n");
   len = len + (2 * sizeof(char));
   if (context == 1) {
      hLogfile = CreateFile((LPTSTR) CoreData.log_filep, GENERIC_WRITE, FILE_SHARE_WRITE, (LPSECURITY_ATTRIBUTES) NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, (HANDLE) NULL);
   }
   else {
      hLogfile = CreateFile((LPTSTR) CoreData.log_file, GENERIC_WRITE, FILE_SHARE_WRITE, (LPSECURITY_ATTRIBUTES) NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, (HANDLE) NULL);
   }
   dwPos = SetFilePointer(hLogfile, 0, (LPLONG) NULL, FILE_END);
   LockFile(hLogfile, dwPos, 0, dwPos + len, 0);
   WriteFile(hLogfile, (LPTSTR) p_buffer, len, &dwBytesWritten, NULL);
   UnlockFile(hLogfile, dwPos, 0, dwPos + len, 0);
   CloseHandle(hLogfile);

   if (p_buffer != buffer)
      free((void *) p_buffer);

   return 1;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   return 0;
}
#endif
}


int mg_log_buffer(unsigned char *buffer, unsigned int len, char *title, int context, void *pdb, int dbtype)
{
   unsigned int n;
   unsigned char *p;
   unsigned short c;
   char bufx[1024], buf[32];

#ifdef _WIN32
__try {
#endif

   p = NULL;
   strcpy(bufx, "");
   for (n = 0; n < len; n ++) {
      c = (unsigned short) buffer[n];

      if ((c < 32) || (c > 126)) {
         sprintf(buf, "\\x%02x", c);
      }
      else {
         sprintf(buf, "%c", (char) c);
      }
      strcat(bufx, buf);
   }

   mg_log_event(bufx, title, context, pdb, dbtype);

   return 1;

#ifdef _WIN32
}
__except (EXCEPTION_EXECUTE_HANDLER) {

   return 0;
}
#endif

}


/*
   C type identifier    ODBC C typedef       C type
   =================    ==============       ======
   SQL_C_CHAR           SQLCHAR *            unsigned char *
   SQL_C_WCHAR          SQLWCHAR *           wchar_t *
   SQL_C_SSHORT         SQLSMALLINT          short int
   SQL_C_USHORT         SQLUSMALLINT         unsigned short int
   SQL_C_SLONG          SQLINTEGER           long int
   SQL_C_ULONG          SQLUINTEGER          unsigned long int
   SQL_C_FLOAT          SQLREAL              float
   SQL_C_DOUBLE         SQLDOUBLE, SQLFLOAT  double
   SQL_C_BIT            SQLCHAR              unsigned char
   SQL_C_STINYINT       SQLSCHAR             signed char
   SQL_C_UTINYINT       SQLCHAR              unsigned char
   SQL_C_SBIGINT        SQLBIGINT            _int64
   SQL_C_UBIGINT        SQLUBIGINT           unsigned _int64
   SQL_C_BINARY         SQLCHAR *            unsigned char *
   SQL_C_BOOKMARK       BOOKMARK             unsigned long int
   SQL_C_VARBOOKMARK    SQLCHAR *            unsigned char *
   SQL_C_TYPE_DATE      SQL_DATE_STRUCT
   SQL_C_TYPE_TIME      SQL_TIME_STRUCT
   SQL_C_TYPE_TIMESTAMP SQL_TIMESTAMP_STRUCT
   SQL_C_NUMERIC        SQL_NUMERIC_STRUCT
   SQL_C_GUID           SQLGUID
*/


char * mg_ctype_str(int type)
{
   char *pstr;

   pstr = NULL;
   switch (type) {
      case SQL_C_CHAR:
         pstr = "SQL_C_CHAR";
         break;
      case SQL_C_WCHAR:
         pstr = "SQL_C_WCHAR";
         break;
      case SQL_C_SSHORT:
         pstr = "SQL_C_SSHORT";
         break;
      case SQL_C_USHORT:
         pstr = "SQL_C_USHORT";
         break;
      case SQL_C_SLONG:
         pstr = "SQL_C_SLONG";
         break;
      case SQL_C_ULONG:
         pstr = "SQL_C_ULONG";
         break;
      case SQL_C_FLOAT:
         pstr = "SQL_C_FLOAT";
         break;
      case SQL_C_DOUBLE:
         pstr = "SQL_C_DOUBLE";
         break;
      case SQL_C_BIT:
         pstr = "SQL_C_BIT";
         break;
      case SQL_C_STINYINT:
         pstr = "SQL_C_STINYINT";
         break;
      case SQL_C_UTINYINT:
         pstr = "SQL_C_UTINYINT";
         break;
      case SQL_C_SBIGINT:
         pstr = "SQL_C_SBIGINT";
         break;
      case SQL_C_UBIGINT:
         pstr = "SQL_C_UBIGINT";
         break;
      case SQL_C_BINARY:
         pstr = "SQL_C_BINARY";
         break;
/*
      case SQL_C_BOOKMARK:
         pstr = "SQL_C_BOOKMARK";
         break;
      case SQL_C_VARBOOKMARK:
         pstr = "SQL_C_VARBOOKMARK";
         break;
*/
      case SQL_C_TYPE_DATE:
         pstr = "SQL_C_TYPE_DATE";
         break;
      case SQL_C_TYPE_TIME:
         pstr = "SQL_C_TYPE_TIME";
         break;
      case SQL_C_TYPE_TIMESTAMP:
         pstr = "SQL_C_TYPE_TIMESTAMP";
         break;
      case SQL_C_NUMERIC:
         pstr = "SQL_C_NUMERIC";
         break;
      case SQL_C_GUID:
         pstr = "SQL_C_GUID";
         break;
      default:
         pstr = "<UNKNOWN>";
         break;
   }
   return pstr;
}


int mg_ctype(char *typestr)
{
   int id;

   id = 0;
   if (!strcmp(typestr, "SQL_C_CHAR"))
      id = SQL_C_CHAR;
   else if (!strcmp(typestr, "SQL_C_WCHAR"))
      id = SQL_C_WCHAR;
   else if (!strcmp(typestr, "SQL_C_SSHORT"))
      id = SQL_C_SSHORT;
   else if (!strcmp(typestr, "SQL_C_USHORT"))
      id = SQL_C_USHORT;
   else if (!strcmp(typestr, "SQL_C_SLONG"))
      id = SQL_C_SLONG;
   else if (!strcmp(typestr, "SQL_C_ULONG"))
      id = SQL_C_ULONG;
   else if (!strcmp(typestr, "SQL_C_FLOAT"))
      id = SQL_C_FLOAT;
   else if (!strcmp(typestr, "SQL_C_DOUBLE"))
      id = SQL_C_DOUBLE;
   else if (!strcmp(typestr, "SQL_C_BIT"))
      id = SQL_C_BIT;
   else if (!strcmp(typestr, "SQL_C_STINYINT"))
      id = SQL_C_STINYINT;
   else if (!strcmp(typestr, "SQL_C_UTINYINT"))
      id = SQL_C_UTINYINT;
   else if (!strcmp(typestr, "SQL_C_SBIGINT"))
      id = SQL_C_SBIGINT;
   else if (!strcmp(typestr, "SQL_C_UBIGINT"))
      id = SQL_C_UBIGINT;
   else if (!strcmp(typestr, "SQL_C_BINARY"))
      id = SQL_C_BINARY;
   else if (!strcmp(typestr, "SQL_C_BOOKMARK"))
      id = SQL_C_BOOKMARK;
   else if (!strcmp(typestr, "SQL_C_VARBOOKMARK"))
      id = SQL_C_VARBOOKMARK;
   else if (!strcmp(typestr, "SQL_C_TYPE_DATE"))
      id = SQL_C_TYPE_DATE;
   else if (!strcmp(typestr, "SQL_C_TYPE_TIME"))
      id = SQL_C_TYPE_TIME;
   else if (!strcmp(typestr, "SQL_C_TYPE_TIMESTAMP"))
      id = SQL_C_TYPE_TIMESTAMP;
   else if (!strcmp(typestr, "SQL_C_NUMERIC"))
      id = SQL_C_NUMERIC;
   else if (!strcmp(typestr, "SQL_C_GUID"))
      id = SQL_C_GUID;

   return id;
}


char * mg_sqltype_str(int type)
{
   char *pstr;

   pstr = NULL;
   switch (type) {
      case SQL_BIT:
         pstr = "SQL_BIT";
         break;
      case SQL_TINYINT:
         pstr = "SQL_TINYINT";
         break;
      case SQL_BIGINT:
         pstr = "SQL_BIGINT";
         break;
      case SQL_LONGVARBINARY:
         pstr = "SQL_LONGVARBINARY";
         break;
      case SQL_VARBINARY:
         pstr = "SQL_VARBINARY";
         break;
      case SQL_LONGVARCHAR:
         pstr = "SQL_LONGVARCHAR";
         break;
      case SQL_NUMERIC:
         pstr = "SQL_NUMERIC";
         break;
      case SQL_INTEGER:
         pstr = "SQL_INTEGER";
         break;
      case SQL_SMALLINT:
         pstr = "SQL_SMALLINT";
         break;
      case SQL_DOUBLE:
         pstr = "SQL_DOUBLE";
         break;
      case SQL_DATE:
         pstr = "SQL_DATE";
         break;
      case SQL_TIME:
         pstr = "SQL_TIME";
         break;
      case SQL_TIMESTAMP:
         pstr = "SQL_TIMESTAMP";
         break;
      case SQL_CHAR:
         pstr = "SQL_CHAR";
         break;
      case SQL_VARCHAR:
         pstr = "SQL_VARCHAR";
         break;
      default:
         pstr = "<UNKNOWN>";
         break;
   }
   return pstr;
}


int mg_sqltype(char *typestr)
{
   int id;
   char *p;

   p = typestr;
   if (!strncmp(p, "SQL_", 4)) {
      p += 4;
   }

   id = 0;
   if (!strcmp(p, "BIT"))
      id = SQL_BIT;
   else if (!strcmp(p, "TINYINT"))
      id = SQL_TINYINT;
   else if (!strcmp(p, "BIGINT"))
      id = SQL_BIGINT;
   else if (!strcmp(p, "LONGVARBINARY"))
      id = SQL_LONGVARBINARY;
   else if (!strcmp(p, "VARBINARY"))
      id = SQL_VARBINARY;
   else if (!strcmp(p, "LONGVARCHAR"))
      id = SQL_LONGVARCHAR;
   else if (!strcmp(p, "NUMERIC"))
      id = SQL_NUMERIC;
   else if (!strcmp(p, "INTEGER"))
      id = SQL_INTEGER;
   else if (!strcmp(p, "SMALLINT"))
      id = SQL_SMALLINT;
   else if (!strcmp(p, "DOUBLE"))
      id = SQL_DOUBLE;
   else if (!strcmp(p, "DATE"))
      id = SQL_DATE;
   else if (!strcmp(p, "TIME"))
      id = SQL_TIME;
   else if (!strcmp(p, "TIMESTAMP"))
      id = SQL_TIMESTAMP;
   else if (!strcmp(p, "VARCHAR"))
      id = SQL_VARCHAR;

   return id;
}


char * mg_iotype_str(int type)
{
   char *pstr;

   pstr = NULL;
   switch (type) {
      case SQL_PARAM_INPUT:
         pstr = "SQL_PARAM_INPUT";
         break;
      case SQL_PARAM_OUTPUT:
         pstr = "SQL_PARAM_OUTPUT";
         break;
/*
      case SQL_PARAM_OUTPUT_STREAM:
         pstr = "SQL_PARAM_OUTPUT_STREAM";
         break;
*/
      case SQL_PARAM_INPUT_OUTPUT:
         pstr = "SQL_PARAM_INPUT_OUTPUT";
         break;
/*
      case SQL_PARAM_INPUT_OUTPUT_STREAM:
         pstr = "SQL_PARAM_INPUT_OUTPUT_STREAM";
         break;
*/
      default:
         pstr = "<UNKNOWN>";
         break;
   }

   return pstr;
}