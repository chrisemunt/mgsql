%mgsqlcu ;(CM) sql compiler update ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlcu") q
 ;
main ; start
 n inop
 s inop=$$pkey^%mgsqld(dbid,tname)
 s %tagz=%zq("tag",1)
 s tname=^mgtmp($j,"upd","update"),alias=$p(tname," ",2),tname=$p(tname," ",1)
 k dtyp d xfid^%mgsqlct
 s line=" "_"k"_" %do,%dn,%dx" d addline^%mgsqlc(grp,.line)
 s %kupd=0,cname="" f  s cname=$o(xfidx(cname)) q:cname=""  i $d(^mgtmp($j,"upd","set",cname)) s %kupd=1
 f i=1:1 q:'$d(xfid(inop,i))  s cname=xfid(inop,i,1) i cname?1a.e d key
 s cname="" f  s cname=$o(^mgtmp($j,"upd","set",cname)) q:cname=""  i cname?1a.e,'$d(xfidx(cname)) d dat
 s %refile=0 d set^%mgsqlci
 s line=" "_"g"_" "_%tagz d addline^%mgsqlc(grp,.line)
exit ; exit
 k upd,key,nkey,nkeyt,okey,okeyt,pkey,pref,idx,apc,cde,z
 q
 ;
key ; determine values for keys in update
 d dtyp^%mgsqlct
 s key("o",cname)="%do("_dtyp(cname)_")"
 s line=" "_"s"_" "_key("o",cname)_"="_%z("dsv")_alias_"."_cname_%z("dsv") d addline^%mgsqlc(grp,.line)
 i '$d(^mgtmp($j,"upd","set",cname)) s line=" "_"s"_" "_"%dn("_dtyp(cname)_")="_key("o",cname) d addline^%mgsqlc(grp,.line)
 i '%kupd q
 s key("n",cname)="%dn("_dtyp(cname)_")"
 s var=key("n",cname) d setto
 q
 ;
dat ; determine values for update and set r.i. interface
 d dtyp^%mgsqlct
 s dat("o",cname)="%do("_dtyp(cname)_")"
 s line=" "_"s"_" "_dat("o",cname)_"="_%z("dsv")_alias_"."_cname_%z("dsv") d addline^%mgsqlc(grp,.line)
 s dat("n",cname)="%dn("_dtyp(cname)_")"
 s var=dat("n",cname) d setto
 q
 ;
setto ; reconstruct set-to statement
 n i
 i '$d(^mgtmp($j,"upd","set",cname)) s line=" "_"s"_" "_var_"="_"%do("_dtyp(cname)_")" d addline^%mgsqlc(grp,.line) q
 f i=1:1 q:'$d(^mgtmp($j,"upd","set",cname,"zcode",i))  s line=^mgtmp($j,"upd","set",cname,"zcode",i) d setto1
 q
 ;
setto1 ; add to line
 n i
 s pn=0 i line[%z("dsv") f  s pn=pn+2,x=$p(line,%z("dsv"),pn) q:x=""  i x["**set**" s line=$p(line,%z("dsv"),1,pn-1)_var_$p(line,%z("dsv"),pn+1,999) s pn=pn-2
 d addline^%mgsqlc(grp,.line)
 q
 ;
 
