%mgsqlx ;(CM) sql - MGSQL as a server ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlx") q
 ;
main(dbid,line,info,error) ; compile query
 ;n ddl,rou,qid,sql
 n (%z,dbid,line,info,error)
 new $ztrap set $ztrap="zgoto "_$zlevel_":maine^%mgsqlx"
 s rou="",error=""
 d gvars(.%z)
 s ddl=$$verify(dbid,.line,.sql,.error) i ddl=1 g exit
 m info("tp")=sql("txp")
 i $d(info("tp")),'$d(sql(0,1)) g exit
 s qid=$$hash(dbid,.rou,.line)
 d gcvars(dbid,qid,.%zq)
 s info("qid")=qid
 i ddl=2 s info("sp")=rou g main1
 ; Force recompilation
 k ^mgsqlx(1,dbid,qid,"m")
 ; Don't recompile if already compiled
 i $d(^mgsqlx(1,dbid,qid,"m")) g exit
 d comp(dbid,qid,rou,.sql,.line,.error)
main1 d save
 g exit
maine ; error
 s error="System Exception: "_$$error^%mgsqls(),error(5)="HY000"
exit ;k ^mgtmp($j)
 q rou
 ;
et2 ; test
 w !,"in et2^%mgsqlx"
 s x=ttt
 q
 ;
n36(n10) ; generate 3 character base-36 node number 000 -> zzz
 n alpha,char,n36,rem
 s alpha="0123456789abcdefghijklmnopqrstuvwxyz"
 s n36="" f char=1:1:3 s rem=n10#36,n10=n10\36,n36=$e(alpha,rem+1)_n36
 q n36
 ;
hash(dbid,sqrou,line) ; apply hashing algorithm to query
 n lin,ln,chng,n10,n36,i,mxi,hash
 s sqrou=""
 s ln=0 f i=1:1 q:'$d(line(i))  s lin=line(i),ln=ln+1,lin(ln)=lin
 s mxi=i-1
 s hash="" f i=1:1:3 s n10=$s($d(lin(i)):$l(lin(i)),1:0) s n36=$$n36(n10) s hash=hash_$e(n36,2,3)
 s n10=mxi,n36=$$n36(n10),hash=hash_$e(n36,2,3)
 ; try and find existing query
 s chng=1,qid="" f  s qid=$o(^mgsqlx(2,dbid,hash,qid)) q:qid=""  i '$$hash1(dbid,qid,.line) q
 i '$l(qid) s qid=$$prfx()
 s sqrou="x"_qid_1 i $d(^mgtmp($j,"sp")) s sqrou=$g(^mgtmp($j,"sp")),^mgsqlx(1,dbid,qid,"sp")=sqrou
 s ^mgsqlx(1,dbid,qid,"hash")=hash,^("rou")=sqrou,^mgsqlx(2,dbid,hash,qid)=""
 f i=1:1 q:'$d(line(i))  s ^mgsqlx(1,dbid,qid,"sql",i)=line(i)
 q qid
 ;
hash1(dbid,qid,line) ; compare individual query
 n chng,i
 s chng=0
 f i=1:1 q:'$d(^mgsqlx(1,dbid,qid,"sql",i))  s:'$d(line(i)) chng=1 q:chng  i ^(i)'=line(i) s chng=1 q
 i $d(line(i)) s chng=1
 q chng
 ;
save ; allocate query id and save query
 n type,i,l,to,fr,rou
 m ^mgsqlx(1,dbid,qid,"in")=^mgtmp($j,"in")
 m ^mgsqlx(1,dbid,qid,"t")=^mgtmp($j,"sqlupd")
 f i=1:1 q:'$d(^mgtmp($j,"outsel",1,i))  s var=$g(^(i)) d
 . s tname="",cname=var
 . i var[%z("dsv") s var=$p(var,%z("dsv"),2)
 . s alias=$p(var,".",1),cname=$p(var,".",2)
 . i alias'="" s tno=$g(^mgtmp($j,"from","x",1,alias)) i tno'="" s tname=$p($g(^mgtmp($j,"from",1,tno)),"~",1)
 . s ^mgsqlx(1,dbid,qid,"out",i)=var_"~"_tname_"~"_cname_"~"_$$dtype^%mgsqld(dbid,tname,cname)
 . q
 i '$d(^mgsqlx(1,dbid,qid,"sp")) s code="^mgsqlx(1,dbid,qid,""m"",i)",mxi=$g(^mgsqlx(1,dbid,qid,"m")),rou="x"_qid_"1",ok=$$zs^%mgsqlr(rou,code,mxi)
 q
 ;
del(dbid,qid) ; delete script from file
 n hash,rou,ok
 s (hash,rou)=""
 i $d(^mgsqlx(1,dbid,qid,"hash"))#10 s hash=^("hash")
 i $d(^mgsqlx(1,dbid,qid,"rou"))#10 s rou=^("rou")
 i $l(rou) s ok=$$zr^%mgsqlr(rou)
 i $l(hash) k ^mgsqlx(1,dbid,hash,qid)
 d delcalls(dbid,qid)
 d delupd(dbid,qid)
 k ^mgsqlx(1,dbid,qid)
 q
 ;
delcalls(dbid,qid) ; delete calls index
 k ^mgsqlx(1,dbid,qid,"calls")
 q
 ;
delupd(dbid,qid) ; delete update index
 k ^mgsqlx(1,dbid,qid,"squpd")
 q
 ;
newfid ; file updated - wipe out affected code
 n (%z,dbid,tname)
 q
newfide ; error
 q
 ;
prfx() ; assign new prefix
 n n10,qid
 l ^mgsqlx(0)
 i '$d(^mgsqlx(0)) s ^(0)=0
 s n10=^(0)+1,^(0)=n10
 l
 s qid=$$n36(n10)
 q qid
 ;
verify(dbid,line,sql,error) ; verify query and execute any DDL commands
 n ddl
 s ddl=0
 d main^%mgsqlv(dbid,.line,.sql,.error)
 i $e(error,1,5)="\ddl\" s ddl=1,error=$e(error,6,999)
 i $e(error,1,4)="\sp\" s ddl=2,error=$e(error,5,999)
 q ddl
 ;
comp(dbid,qid,rou,sql,line,error) ; compile query
 n i,ok,var
 k ^mgsqlx(1,dbid,qid,"var")
 d delcalls(dbid,qid)
 d delupd(dbid,qid)
 d main^%mgsqlo i $l(error) g compx
 d main^%mgsqlc i $l(error) g compx
compx ; exit compilation process
 i $l(error) s ^mgsqlx(1,dbid,qid,"error")=error d del(dbid,qid)
 q
 ;
upd() ; see if updates are allowed
 s upd=0
 q upd
 ;
acc(user,model,entity,context,error,info) ; see if access is allowed
 s error=""
 q 1
 i user="s3992\muntc" q 1
 i 'result,error="" s error="you ("_user_") may not access "_entity_" (app="_$g(info("app"))_"; ip="_$g(info("ip"))_")",error(5)="42000"
 q result
 ;
gvars(vars) ; initialize global variables
 k vars
 s vars("pv")="sq"
 s vars("pt")="sq"
 s vars("dsv")="{s}"
 s vars("dev")="{v}"
 s vars("df")="{f}"
 s vars("de")="{e}"
 s vars("dq")="{q}"
 s vars("dl")="{l}"
 s vars("ds")="{$}"
 s vars("dc")="{z}"
 s vars("vok")=vars("dsv")_"__status"_vars("dsv")
 s vars("vdata")=vars("dsv")_"__data"_vars("dsv")
 s vars("vdatax")=vars("dsv")_"__datax"_vars("dsv")
 s vars("vrc")=vars("dsv")_"__rowcount"_vars("dsv")
 s vars("vn")=vars("dsv")_"__count"_vars("dsv")
 s vars("vnx")=vars("dsv")_"__count_d"_vars("dsv")
 s vars("vdef")=vars("dsv")_"__defined"_vars("dsv")
 s vars("vck")=vars("dsv")_"__compound_key"_vars("dsv")
 s vars("vckcrc")=vars("dsv")_"__compound_key_crc"_vars("dsv")
 s vars("vckcrcdef")=vars("dsv")_"__compound_key_crc_defined"_vars("dsv")
 s vars("ctg")="^mgtemp"
 s vars("cts")="$j"
 q
 ;
gcvars(dbid,qid,vars) ; initialize global variables
 s vars("ccode")="^mgsqlx(1,"""_dbid_""","""_qid_""",""m"""
 s vars("ccoder")="^mgsqlx(1,"""_dbid_""","""_qid_""",""mr"""
 q
 ;
