%mgsqlcd ;(CM) sql compiler - delete ; 12 feb 2002  02:10pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2019 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqlcd") q
 ;
main ; start
 s %tagz=tag(1),%tagi=%z("pt")_"i",%tdlm=%z("dl")
 s tname=update("delete"),alias=$p($p(tname," ",2),":",1),tname=$p(tname," ",1)
 k dtyp d xfid^%mgsqlct
 s line=" "_"k"_" %do,%dn,%dx" d addline^%mgsqlc(grp,.line)
 s inop=$$pkey^%mgsqld(dbid,tname)
 f i=1:1 q:'$d(xfid(inop,i))  s cname=xfid(inop,i,1) i cname?1a.e d data
 s %refile=0 d kill^%mgsqlci
 s line=" "_"g"_" "_%tagz d addline^%mgsqlc(grp,.line)
exit ; exit
 k upd,key,nkey,nkeyt,okey,okeyt,pkey,pref,idx,apc,cde,z
 q
 ;
data ; determine values for delete and set r.i. interface
 d dtyp^%mgsqlct
 s key("o",cname)="%do("_dtyp(cname)_")"
 s line=" "_"s"_" "_key("o",cname)_"="_%z("dsv")_alias_"."_cname_%z("dsv") d addline^%mgsqlc(grp,.line)
 q
 ;
hilev ; kill file off at high level
 n n,alias
 s tname=$p(update("delete")," ",1),alias=$p(update("delete")," ",2) i alias="" s alias=tname
 s ^mgtmp($j,"sqlupd",tname)="~1"
 d xfid^%mgsqlct
 s ino="" f i=0:0 s ino=$o(xfid(ino)) q:ino=""  d hilev1
hilev3 ; link
 s line=" "_"k"_" %do" d addline^%mgsqlc(grp,.line)
 s ino=$$pkey^%mgsqld(dbid,tname) f i=1:1 q:'$d(xfid(ino,i))  s cname=xfid(ino,i,1) i cname?1a.e q:'$d(update("attx",cname))  s val=update("attx",cname),key=key_com_val,com="," i val[%z("dev") s n=$p($$col^%mgsqld(dbid,tname,cname),"\",5) i $l(n) s line=" "_"s"_" %do("_n_")="_val d addline^%mgsqlc(grp,.line)
 q
 ;
hilev1 ; kill off single index
 s (line,key,keyt,com,comt)=""
 i ino=$$pkey^%mgsqld(dbid,tname) f i=1:1 q:'$d(xfid(ino,i))  s cname=$g(xfid(ino,i,1)) i cname?1a.e s ^mgtmp($j,"get",alias_"."_cname)=""
 f i=1:1 q:'$d(xfid(ino,i))  s cname=xfid(ino,i,1) s:cname'?1a.e key=key_com_cname,com="," i cname?1a.e q:'$d(update("attx",cname))  s val=update("attx",cname),key=key_com_val,com="," i val[%z("dev") s keyt=keyt_comt_"$l"_"("_val_")",comt=","
 i $l(keyt) s line=" "_"i"_" "_keyt
 i $l(key) s key="("_key_")"
 s line=line_" "_"k"_" "_xfid(ino)_key d addline^%mgsqlc(grp,.line)
 q
 ;
 
