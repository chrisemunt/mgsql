%mqsqlr ;(CM) MGSQL routine management ; 11 feb 2002  2:40 pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2021 M/Gateway Developments Ltd,                      |
 ;  | Surrey UK.                                                               |
 ;  | All rights reserved.                                                     |
 ;  |                                                                          |
 ;  | http://www.mgateway.com                                                  |
 ;  |                                                                          |
 ;  | Licensed under the Apache License, Version 2.0 (the "License"); you may  |
 ;  | not use this file except in compliance with the License.                 |
 ;  | You may obtain a copy of the License at                                  |
 ;  |                                                                          |
 ;  | http://www.apache.org/licenses/LICENSE-2.0                               |
 ;  |                                                                          |
 ;  | Unless required by applicable law or agreed to in writing, software      |
 ;  | distributed under the License is distributed on an "AS IS" BASIS,        |
 ;  | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. |
 ;  | See the License for the specific language governing permissions and      |
 ;  | limitations under the License.                                           |
 ;  ----------------------------------------------------------------------------
 ;
a d vers^%mgsql("%mgsqlr") q
 ;
zname(var) ; get routine name
 i $$isydb^%mgsqls() q "s "_var_"=$p($zposition,""^"",2)"
 q "s "_var_"=$zn"
 ;
zd(rou) ; routine defined
 new $ztrap set $ztrap="zgoto "_$zlevel_":zde^%mgsqlr"
 i $$isydb^%mgsqls() g zdydb
 x "zr  zl @rou"
 q 1
zde ; error
 q 0
zdydb ; yottadb
 n dev
 s dev=$zd_rou_".m"
 o dev:(readonly) s ok=$t
 c dev
 q ok
 ;
zn(rou) ; get next routine
 q ""
 ;
zr(rou) ; delete routine
 i $$isydb^%mgsqls() g zrydb
 x "zr  zs @rou"
 q 1
zrydb ; yottadb
 n dev
 s dev=$zd_rou_".m"
 o dev:(truncate)
 c dev:(delete)
 q 1
 ;
zs(rou,code,mxi) ; save routine
 i $$isydb^%mgsqls() g zsydb
 x "zr  f i=1:1:mxi zi @code zs:i=mxi @rou"
 q 1
zsydb ; yottadb
 n i,dev
 s dev=$zd_rou_".m"
 o dev:(truncate)
 u dev f i=1:1:mxi w @code_$c(10)
 c dev
 zlink dev
 q 1
 ;
