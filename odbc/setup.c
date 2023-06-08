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

#include  "mgodbc.h"
#include <WinUser.h>
#include  <odbcinst.h>
#include  <string.h>
#include  <stdlib.h>
#include "resource.h"


#define MAXDSNAME       256
#define MAXPATHLEN      256
#define MAXKEYLEN       16

/* Attribute key indexes (into an array of Attr structs, see below) */
#define KEY_DSN         0
#define KEY_DESC        1
#define KEY_SERVER      2
#define KEY_PORT        3
#define KEY_UCI         4
#define KEY_ELF         5
#define KEY_ELL         6
#define NUMOFKEYS       8  /* Number of keys supported */


/* Attribute string look-up table (maps keys to associated indexes) */
static struct {
  char   key_name[MAXKEYLEN];
  int    kn;
  int    idc;
} mg_keys[]   = { "DSN",            KEY_DSN,    IDC_EDIT_NAME,
                  "Description",    KEY_DESC,   IDC_EDIT_DESC,
                  "Server",         KEY_SERVER, IDC_EDIT_SERVER,
                  "Port",           KEY_PORT,   IDC_EDIT_PORT,
                  "NameSpace",      KEY_UCI,    IDC_EDIT_UCI,
                  "EventLogFile",   KEY_ELF,    IDC_EDIT_ELF,
                  "EventLogLevel",  KEY_ELL,    IDC_EDIT_ELL,
                  "",               0,          0
                };

typedef struct tagATTR {
	BOOL  supplied;
	char  value[MAXPATHLEN];
} ATTR, * LPATTR;


typedef struct tagSETUPDLG {
   short save;
	HWND	hwndParent;             /* Parent window handle */
   char  driver[MAXDSNAME];
	ATTR	value[NUMOFKEYS];       /* Attribute array */
	char	dsn_orig[MAXDSNAME];    /* Original data source name */
	BOOL	new_dsn;                /* New data source flag */
	BOOL	default_dsn;            /* Default data source flag */
} SETUPDLG, *LPSETUPDLG;


typedef struct tagMGDLG {
   HWND hdlg;
} MGDLG, *LPMGDLG;


void INTFUNC      CenterDialog        (HWND hdlg);
INT_PTR INTFUNC   ConfigDlgProc       (HWND hdlg, WORD wMsg, WPARAM wParam, LPARAM lParam);
void INTFUNC      ParseAttributes     (LPCSTR lpszAttributes, LPSETUPDLG lpsetupdlg);
BOOL INTFUNC      SetDSNAttributes    (HWND hwnd, LPSETUPDLG lpsetupdlg);
BOOL INTFUNC      GetDSNAttributes    (HWND hwndParent, LPSETUPDLG lpsetupdlg);
INT_PTR INTFUNC   AboutProc           (HWND hdlg, WORD wMsg, WPARAM wParam, LPARAM lParam);


DWORD ShowAboutDlg(LPVOID pdata)
{
   MGDLG *pmgdlg;

   pmgdlg = (MGDLG *) pdata;

   DialogBoxParam(CoreData.ghInstance, MAKEINTRESOURCE(IDD_ABOUT), pmgdlg->hdlg, (DLGPROC) AboutProc, (LPARAM) NULL);

   Sleep(3000);
   return 0;
}



/* ConfigDSN ---------------------------------------------------------------
  Description:  ODBC Setup entry point
                This entry point is called by the ODBC Installer
                (see file header for more details)
  Input      :  hwnd ----------- Parent window handle
                fRequest ------- Request type (i.e., add, config, or remove)
                lpszDriver ----- Driver name
                lpszAttributes - data source attribute string
  Output     :  TRUE success, FALSE otherwise
--------------------------------------------------------------------------*/
BOOL INSTAPI ConfigDSN(HWND hwnd, WORD fRequest, LPCSTR lpszDriver, LPCSTR lpszAttributes)
{
   BOOL  fSuccess;
   GLOBALHANDLE hglbAttr;
   LPSETUPDLG lpsetupdlg;


/*
{
   char buffer[256], dll[256];

   SQLGetPrivateProfileString(lpszDriver, "Driver", "", dll, 256, ODBCINST_INI);
   sprintf(buffer, "fRequest=%d; lpszDriver=%s; lpszAttributes=%s; dll=%s", fRequest, lpszDriver, lpszAttributes, dll);
   mg_log_event(buffer, "MGSQL: ConfigDSN", 0, NULL, 0);
}
*/

   /* Allocate attribute array */
   hglbAttr = GlobalAlloc(GMEM_MOVEABLE | GMEM_ZEROINIT, sizeof(SETUPDLG));
   if (!hglbAttr)
      return FALSE;
   lpsetupdlg = (LPSETUPDLG) GlobalLock(hglbAttr);

	/* Parse attribute string */
   if (lpszAttributes)
      ParseAttributes(lpszAttributes, lpsetupdlg);

   /* Save original data source name */
   if (lpsetupdlg->value[KEY_DSN].supplied)
      lstrcpy(lpsetupdlg->dsn_orig, lpsetupdlg->value[KEY_DSN].value);
   else
      lpsetupdlg->dsn_orig[0] = '\0';

   GetDSNAttributes(hwnd, lpsetupdlg);

   /* Remove data source */
   if (fRequest == ODBC_REMOVE_DSN) {
      /* Fail if no data source name was supplied */
      if (!lpsetupdlg->value[KEY_DSN].supplied)
         fSuccess = FALSE;

      /* Otherwise remove data source from ODBC.INI */
      else
         fSuccess = SQLRemoveDSNFromIni(lpsetupdlg->value[KEY_DSN].value);
   }

   /* Add or Configure data source */
   else {
      /* Save passed variables for global access (e.g., dialog access) */
      lpsetupdlg->hwndParent = hwnd;
      strcpy(lpsetupdlg->driver, lpszDriver);
      lpsetupdlg->new_dsn = (ODBC_ADD_DSN == fRequest);

      /* Display the appropriate dialog (if parent window handle supplied) */
      if (hwnd) {
         /* Display dialog(s) */

         if (DialogBoxParam(CoreData.ghInstance, MAKEINTRESOURCE(IDD_CONFIGDSN), hwnd, (DLGPROC) ConfigDlgProc, (LPARAM) lpsetupdlg) == IDOK)
            fSuccess = TRUE;
         else
            fSuccess = FALSE;

      }
      if (lpsetupdlg->save && lpsetupdlg->value[KEY_DSN].supplied)
         fSuccess = SetDSNAttributes(hwnd, lpsetupdlg);
      else
         fSuccess = FALSE;
   }

   GlobalUnlock(hglbAttr);
   GlobalFree(hglbAttr);

   return fSuccess;
}


BOOL INSTAPI ConfigDriver(HWND hwndParent, WORD fRequest, LPCSTR lpszDriver, LPCSTR lpszArgs, LPSTR lpszMsg, WORD cbMsgMax, WORD * pcbMsgOut)
{
   return TRUE;
}


BOOL INSTAPI ConfigTranslator(HWND hwndParent, DWORD * pvOption)
{
   return TRUE;
}



/*
   CenterDialog
   Description :  Center the dialog over the frame window
   Input       :  hdlg -- Dialog window handle
   Output      :  None
*/

void INTFUNC CenterDialog(HWND hdlg)
{
   HWND hwndFrame;
   RECT rcDlg, rcScr, rcFrame;
   int cx, cy;

   hwndFrame = GetParent(hdlg);

   GetWindowRect(hdlg, &rcDlg);
   cx = rcDlg.right  - rcDlg.left;
   cy = rcDlg.bottom - rcDlg.top;

   GetClientRect(hwndFrame, &rcFrame);
   ClientToScreen(hwndFrame, (LPPOINT)(&rcFrame.left));
   ClientToScreen(hwndFrame, (LPPOINT)(&rcFrame.right));
   rcDlg.top    = rcFrame.top  + (((rcFrame.bottom - rcFrame.top) - cy) >> 1);
   rcDlg.left   = rcFrame.left + (((rcFrame.right - rcFrame.left) - cx) >> 1);
   rcDlg.bottom = rcDlg.top  + cy;
   rcDlg.right  = rcDlg.left + cx;

   GetWindowRect(GetDesktopWindow(), &rcScr);
   if (rcDlg.bottom > rcScr.bottom) {
      rcDlg.bottom = rcScr.bottom;
      rcDlg.top    = rcDlg.bottom - cy;
   }
   if (rcDlg.right  > rcScr.right) {
      rcDlg.right = rcScr.right;
      rcDlg.left  = rcDlg.right - cx;
   }

   if (rcDlg.left < 0)
      rcDlg.left = 0;
   if (rcDlg.top  < 0)
      rcDlg.top  = 0;

   MoveWindow(hdlg, rcDlg.left, rcDlg.top, cx, cy, TRUE);
   return;
}


/*
   ConfigDlgProc
   Description:   Manage add data source name dialog
   Input      :   hdlg --- Dialog window handle
                  wMsg --- Message
                  wParam - Message parameter
                  lParam - Message parameter
   Output     :   TRUE if message processed, FALSE otherwise
*/

INT_PTR CALLBACK ConfigDlgProc(HWND hdlg, WORD wMsg, WPARAM wParam, LPARAM lParam)
{
   int n, kn, idc;
   LPSETUPDLG lpsetupdlg;
   LPCSTR lpszDSN;
   HDC hdcStatic;

/*
{
   char buffer[256];
   sprintf(buffer, "wMsg=%d;  wParam=%d; lParam=%d;", (int) wMsg, (int) wParam, (int) lParam);
   mg_log_event(buffer, "MGSQL:ConfigDlgProc", 0, NULL, 0);
}
*/

   switch (wMsg) {
      /* Initialize the dialog */
      case WM_INITDIALOG:
         lpsetupdlg = (LPSETUPDLG) lParam;
         lpszDSN    = lpsetupdlg->value[KEY_DSN].value;

         SetWindowLongPtr(hdlg, DWLP_USER, lParam);

         CenterDialog(hdlg);

         for (n = 0; *mg_keys[n].key_name; n ++) {
            kn = mg_keys[n].kn;
            idc = mg_keys[n].idc;

            SetDlgItemText(hdlg, idc, lpsetupdlg->value[kn].value);

         }
         SetWindowLongPtr(hdlg, GWL_STYLE, WS_TILEDWINDOW);
         return TRUE;
      case WM_CTLCOLORBTN:
      case WM_CTLCOLORDLG:
      case WM_CTLCOLOREDIT:
         hdcStatic = (HDC) wParam;
         SetTextColor(hdcStatic, RGB(0,0,0)); /* black */
         SetBkColor(hdcStatic, RGB(224,224,224)); /* light grey */
         return (INT_PTR) GetSysColorBrush(COLOR_WINDOW);
      case WM_CTLCOLORLISTBOX:
      case WM_CTLCOLORMSGBOX:
      case WM_CTLCOLORSCROLLBAR:	
      case WM_CTLCOLORSTATIC:
         hdcStatic = (HDC) wParam;
         SetTextColor(hdcStatic, RGB(0,0,0));
         SetBkColor(hdcStatic, RGB(255,255,255));
         return (INT_PTR) GetSysColorBrush(COLOR_WINDOW);
      case WM_SETTEXT:
      case WM_NCPAINT:
      case WM_NCACTIVATE:
      case WM_SYSCOLORCHANGE:
      case WM_COMMAND:
         switch (GET_WM_COMMAND_ID(wParam, lParam)) {
            case IDC_BUTTON_SAVE:
               lpsetupdlg = (LPSETUPDLG) GetWindowLongPtr(hdlg, DWLP_USER);

               for (n = 0; *mg_keys[n].key_name; n ++) {
                  kn = mg_keys[n].kn;
                  idc = mg_keys[n].idc;

			         GetDlgItemText(hdlg, idc, lpsetupdlg->value[kn].value, sizeof(lpsetupdlg->value[kn].value));
                  lpsetupdlg->value[kn].supplied = 1;
               }

               lpsetupdlg->save = 1;

               EndDialog(hdlg, wParam);
               return TRUE;
            case IDC_BUTTON_CANCEL: /* Cancel button */
               EndDialog(hdlg, wParam);
               return TRUE;
               /* return to caller */
            case IDCANCEL: /* Cancel form */
               EndDialog(hdlg, wParam);
               return TRUE;
            case IDC_BUTTON_ABOUT:
               CreateDialogParam(CoreData.ghInstance, MAKEINTRESOURCE(IDD_ABOUT), hdlg, (DLGPROC) AboutProc, (LPARAM) NULL);
               return TRUE;
         }
      break;
   }

   /* Message not processed */
   return FALSE;
}


/* ParseAttributes ---------------------------------------------------------
  Description:  Parse attribute string moving values into the value array
  Input      :  lpszAttributes - Pointer to attribute string
  Output     :  None (global value normally updated)
--------------------------------------------------------------------------*/
void INTFUNC ParseAttributes(LPCSTR lpszAttributes, LPSETUPDLG lpsetupdlg)
{
   LPCSTR lpsz;
   LPCSTR lpszStart;
   char aszKey[MAXKEYLEN];
   int iElement;
   int cbKey;

   for (lpsz = lpszAttributes; *lpsz; lpsz ++) {
      /* Extract key name (e.g., DSN), it must be terminated by an equals */
      lpszStart = lpsz;
      for (;; lpsz ++) {
         if (!*lpsz)
            return;     /* No key was found */
         else if (*lpsz == '=')
            break;      /* Valid key found */
      }
      /* Determine the key's index in the key table (-1 if not found) */
      iElement = -1;
      cbKey	= (int) (lpsz - lpszStart);
      if (cbKey < sizeof(aszKey)) {
         register int j;

         _fmemcpy(aszKey, lpszStart, cbKey);
         aszKey[cbKey] = '\0';
         for (j = 0; *mg_keys[j].key_name; j ++) {
            if (!lstrcmpi(mg_keys[j].key_name, aszKey)) {
               iElement = mg_keys[j].kn;
               break;
            }
         }
      }

      /* Locate end of key value */

      lpszStart = ++ lpsz;

      for (; *lpsz; lpsz ++)
         ;

      /*
         Save value if key is known
         NOTE: This code assumes the szAttr buffers in value have been
         zero initialized
      */
      if (iElement >= 0) {
         lpsetupdlg->value[iElement].supplied = TRUE;

         _fmemcpy(lpsetupdlg->value[iElement].value, lpszStart, MAXKEYLEN);
      }
   }

   return;
}


/* SetDSNAttributes --------------------------------------------------------
  Description:  Write data source attributes to ODBC.INI
  Input      :  hwnd - Parent window handle (plus globals)
  Output     :  TRUE if successful, FALSE otherwise
--------------------------------------------------------------------------*/
BOOL INTFUNC SetDSNAttributes(HWND hwndParent, LPSETUPDLG lpsetupdlg)
{
   int n, kn, idc;
   LPCSTR   lpszDSN; // Pointer to data source name

   lpszDSN = lpsetupdlg->value[KEY_DSN].value;
/*
   mg_log_event((char *) lpszDSN, "MGSQL:SetDSNAttributes", 0, NULL, 0);
*/
   /* Validate arguments */
   if (lpsetupdlg->new_dsn && !*lpsetupdlg->value[KEY_DSN].value)
      return FALSE;

   /* Write the data source name */
   if (!SQLWriteDSNToIni(lpszDSN, lpsetupdlg->driver)) {
      if (hwndParent) {
         char  szBuf[MAXPATHLEN];
         char  szMsg[MAXPATHLEN];

         strcpy(szBuf, "Error Condition");
         wsprintf(szMsg, "Invalid Data Source Name: ", lpszDSN);

         MessageBox(hwndParent, szMsg, szBuf, MB_ICONEXCLAMATION | MB_OK);

      }
      return FALSE;
   }

   /*
      Update ODBC.INI
      Save the value if the data source is new, if it was edited, or if
      it was explicitly supplied
   */

   for (n = 0; *mg_keys[n].key_name; n ++) {
      kn = mg_keys[n].kn;
      idc = mg_keys[n].idc;
/*
{
      char buffer[256];
      sprintf(buffer, "lpszDSN=%s; key_name=%s; value=%s", lpszDSN, mg_keys[n].key_name, lpsetupdlg->value[kn].value);
      mg_log_event(buffer, "MGSQL:SetDSNAttributes:nvp", 0, NULL, 0);
}
*/
		SQLWritePrivateProfileString(lpszDSN, mg_keys[n].key_name, lpsetupdlg->value[kn].value, ODBC_INI);
   }

	/* If the data source name has changed, remove the old name */
   if (lpsetupdlg->value[KEY_DSN].supplied && lstrcmpi(lpsetupdlg->dsn_orig, lpsetupdlg->value[KEY_DSN].value)) {
      SQLRemoveDSNFromIni(lpsetupdlg->dsn_orig);
   }

	return TRUE;
}


BOOL INTFUNC GetDSNAttributes(HWND hwndParent, LPSETUPDLG lpsetupdlg)
{
   int n, kn, idc, len;
   LPCSTR lpszDSN; /* Pointer to data source name */

   lpszDSN = lpsetupdlg->value[KEY_DSN].value;

   /* Validate arguments */
   if (!*lpsetupdlg->value[KEY_DSN].value)
      return FALSE;

   for (n = 0; *mg_keys[n].key_name; n ++) {
      kn = mg_keys[n].kn;
      idc = mg_keys[n].idc;

		len = SQLGetPrivateProfileString(lpszDSN, mg_keys[n].key_name, "", lpsetupdlg->value[kn].value, 256, ODBC_INI);

      if (mg_keys[n].kn == KEY_ELF && len < 1) {
         mg_log_file((char *) lpsetupdlg->value[kn].value, sizeof(lpsetupdlg->value[kn].value));
      }
/*
{
      char buffer[256];
      sprintf(buffer, "lpszDSN=%s; key_name=%s; value=%s", lpszDSN, mg_keys[n].key_name, lpsetupdlg->value[kn].value);
      mg_log_event(buffer, "MGSQL:GetDSNAttributes:nvp", 0, NULL, 0);
}
*/

   }

	return TRUE;
}


INT_PTR CALLBACK AboutProc(HWND hdlg, WORD wMsg, WPARAM wParam, LPARAM lParam)
{
   LPSETUPDLG lpsetupdlg;
/*
   {
      char buffer[256];
      sprintf(buffer, "wMsg=%d;  wParam=%d; lParam=%d;", (int) wMsg, (int) wParam, (int) lParam);
      mg_log_event(buffer, "MGSQL:AboutProc", 0, NULL, 0);
   }
*/
   switch (wMsg) {
      /* Initialize the dialog */
      case WM_INITDIALOG:
         lpsetupdlg = (LPSETUPDLG) lParam;
         SetWindowLongPtr(hdlg, DWLP_USER, lParam);
         CenterDialog(hdlg);
         SetWindowLongPtr(hdlg, GWL_STYLE, WS_TILEDWINDOW);
         EnableWindow(hdlg, TRUE);
         EnableWindow(GetDlgItem(hdlg, IDOK), TRUE);
         return TRUE;
      case WM_CTLCOLORBTN:
      case WM_CTLCOLORDLG:
      case WM_CTLCOLOREDIT:
      case WM_CTLCOLORLISTBOX:
      case WM_CTLCOLORMSGBOX:
      case WM_CTLCOLORSCROLLBAR:	
      case WM_CTLCOLORSTATIC:
      case WM_SETTEXT:
      case WM_NCPAINT:
      case WM_NCACTIVATE:
      case WM_SYSCOLORCHANGE:
      case WM_COMMAND:
         switch (GET_WM_COMMAND_ID(wParam, lParam)) {
            case IDC_BUTTON_ABOUTOK: /* OK button */
               EndDialog(hdlg, wParam);
               return TRUE;
            default:
               break;
         }
      default:
         break;
   }

   /* Message not processed */
   return FALSE;
}

