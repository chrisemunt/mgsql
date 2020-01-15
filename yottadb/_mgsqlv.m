 
%mqsqlv ;(CM) sql - validate query ; 14 aug 2002  6:23 pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2020 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqlv") q
 ;
main(dbid,line,error) ; verify query
 k ^mgtmp($j)
 k %link,%delrec,union,adhoc,txp,error
 s error=""
 s qnummax=$$main^%mgsqlp(.sql,.line,.error) i $l(error) g exit
 i '$d(sql(0,1)),$d(sql("txp",0)) s unique=1 g exit
 i '$d(sql(0,1)) s error="no sql script !!!",error(5)="HY000" g exit
 d upd(dbid,.sql,.error) i $l(error) g exit
 ;i $d(^mgtmp($j,"upd","delete")),hilev g exit
 i $p(sql(0,1)," ",1)="call" d sp(dbid,.sql,.error) g exit
 f qnum=1:1:qnummax d verify(dbid,.sql,qnum,.error) i $l(error) q
 i $l(error) g exit
 f qnum=1:1:qnummax s ^mgtmp($j,"subq",qnum)=qnummax-(qnum-1)
 i $d(%zq("drec",0)) d delrec i $l(error) g exit
 d unique
 s i="" f  s i=$o(^mgtmp($j,"where",i)) q:i=""  f j=1:1 q:'$d(^mgtmp($j,"where",i,j))  s x=^mgtmp($j,"where",i,j) i x[%z("dq") d sqidx
 i '$d(^mgtmp($j,"upd","insert")),'$d(^mgtmp($j,"from",1,1)) s error="no table to select 'from'",error(5)="HY000" g exit
 i '$d(^mgtmp($j,"upd","insert")),'$d(^mgtmp($j,"sel",1,1)) s error="no 'select' items",error(5)="HY000" g exit
 ;
exit i $l(error) d error
 k ans,arg,bkt,cmnd,cod,com,cond,d,done,dx,dy,f,tname,alias,fr,fun,funk,i,ii,j,k,l,l1,l2,lc,lf,lin,num,os,p,rf,selarg,selct,ss1,ss2,to,typ,whct,x,y,z
 q
 ;
sqidx ; index subqueries against parents
 s subq=$p(x,%z("dq"),2),x=^mgtmp($j,"where",i,j-1)
 s ^mgtmp($j,"sqcom",subq)=x
 i x="exists" s ^mgtmp($j,"ktmp",subq)="" q
 i x="not exists" s ^mgtmp($j,"ktmp",subq)="" q
 i x="in" s v=^mgtmp($j,"where",i,j-2),^mgtmp($j,"ktmp",subq)="",^mgtmp($j,"notnull",i,v)="",^mgtmp($j,"sqin",v)=subq q
 i x="not in" s v=^mgtmp($j,"where",i,j-2),^mgtmp($j,"ktmp",subq)="",^mgtmp($j,"notnull",i,v)="" q
 i $d(^mgtmp($j,"unique",subq)),'^mgtmp($j,"unique",subq) s ^mgtmp($j,"ktmp",subq)="" q
 q
 ;
unique ; determine whether unique result is to be returned
 n outsel,agno,i,x,y
 i qnum=1,$d(update) s ^mgtmp($j,"unique",1)=1 q
 f i=1:1:qnum d
 . s outsel=$g(^mgtmp($j,"outsel",i))+0,agno=0
 . s x="" f  s x=$o(^mgtmp($j,"sqag",i,x)) q:x=""  s y="" f  s y=$o(^mgtmp($j,"sqag",i,x,y)) q:y=""  s agno=agno+1
 . i outsel=agno s ^mgtmp($j,"unique",i)=1
 . q
 i $d(^mgtmp($j,"group",1)) k ^mgtmp($j,"unique",1) q
 q
 ;
error ; format error message
 n cmnd,qnum,ln
 s ln="",qnum=""
 i $d(error(1)) s cmnd=error(0),qnum=error(1) d error1
 i ln'="" s error("l")=ln
 q
 ;
error1 ; look for line number
 n i,x
 i $d(^mgtmp($j,"cmnd",qnum,cmnd)) s ln=^(cmnd) q
 i $d(^mgtmp($j,"cmnd",0,cmnd,qnum)) s ln=^(qnum) q
 f i=1:1:$l(qnum,",") s x=$p(qnum,",",i) i $l(x),$d(^mgtmp($j,"cmnd",0,cmnd,x)) s ln=^(x) q
 q
 ;
upd(dbid,sql,error) ; validate update directive
 n qnum,ln
 s qnum=0,ln=1
 i $p(sql(qnum,ln)," ",1)="update" d update^%mgsqlv3 i $l(error) q
 i $p(sql(qnum,ln)," ",1)="delete" d delete^%mgsqlv3 i $l(error) q
 i $p(sql(qnum,ln)," ",1)="insert" d insert^%mgsqlv4 i $l(error) q
 i $p(sql(qnum,ln)," ",1)="create" d create^%mgsqlv4(dbid,.sql,.error) q
 i $p(sql(qnum,ln)," ",1)="drop" d drop^%mgsqlv4(dbid,.sql,.error) q
 q
 ;
sp(dbid,sql,error) ; stored procedure
 n qnum,ln,pname,r,ord,type,rou
 s qnum=0,ln=1
 s pname=$p(sql(qnum,ln)," ",2)
 s r=$$prc^%mgsqld(dbid,pname)
 s rou=$p(r,"\",2)
 s rc=$$pdata^%mgsqld(dbid,pname,.%data)
 s qnum=1
 s cname="" f  s cname=$o(%data(cname)) q:cname=""  d
 . s ord=$p(%data(cname),"\",1)+0
 . s type=$p(%data(cname),"\",2)
 . s ^mgtmp($j,"outsel",qnum,ord)=cname
 . q
 s ^mgtmp($j,"sp")=rou
 s error="\sp\"
 q
 ;
verify(dbid,sql,qnum,error) ; verify current line
 n ln,cmnd,arg
 f ln=1:1 q:'$d(sql(qnum,ln))  i $p(sql(qnum,ln)," ",1)="from" q
 i '$d(sql(qnum,ln)) s error="missing/misplaced 'from' statement in (sub) query "_qnum,error(5)="HY000",error(0)="select",error(1)=qnum g verifyx
 s cmnd=$p(sql(qnum,ln)," ",1),arg=$p(sql(qnum,ln)," ",2,9999)
 i cmnd="from" d from^%mgsqlv5(dbid,.sql,qnum,arg,.error) i $l(error) g verifyx
 s ln=0
verify1 s ln=ln+1 i '$d(sql(qnum,ln)) g verifyx
 s cmnd=$p(sql(qnum,ln)," ",1),arg=$p(sql(qnum,ln)," ",2,9999)
 i ln=1,cmnd'="select" s error="missing/misplaced 'select' statement in (sub) query "_qnum,error(5)="HY000",error(0)=cmnd,error(1)=qnum g verifyx
 i cmnd="order",$p(arg," ",1)="by" s arg=$p(arg," ",2,9999)
 i cmnd="group",$p(arg," ",1)="by"  s arg=$p(arg," ",2,9999)
 i cmnd="select" d select^%mgsqlv2(dbid,.sql,qnum,.arg,.error) i $l(error) g verifyx
 i cmnd="where" d where^%mgsqlv1(dbid,.sql,qnum,.arg,.error) i $l(error) g verifyx
 i cmnd="order" d order^%mgsqlv2(dbid,.sql,qnum,.arg,.error) i $l(error) g verifyx
 i cmnd="group" d group^%mgsqlv2(dbid,.sql,qnum,.arg,.error) i $l(error) g verifyx
 i cmnd="having" d having^%mgsqlv2(dbid,.sql,qnum,.arg,.error) i $l(error) g verifyx
 g verify1
verifyx i '$l(error),qnum=1,$d(sql("union",qnum)) s ^mgtmp($j,"sel",qnum)="distinct"
 q
 ;
grp ; look for auto-group situation in outer query
 n x,y,z,com,agrp,ok,ln
 i qnum'=1 q
 i sql(qnum,1)["select *" q
 s ok=0 f ln=1:1 q:'$d(sql(qnum,ln))  i $p(sql(qnum,ln)," ",1)="group" s ok=1 q
 i ok q
 s z="",com="",agrp=0 f i=1:1 q:'$d(^mgtmp($j,"outsel",qnum,i))  s x=^mgtmp($j,"sel",1,i) i x[%z("dsv") s x=$p(x,%z("dsv"),2) s:x'?.1"."1a.e agrp=0 q:x'?.1"."1a.e  s:x'["(" z=z_com_x,com="," s:x["(" agrp=1
 i 'agrp!'$l(z) q
 s z="group by "_z
 s sql(qnum,ln)=z
 q
 ;
delrec ; validate the delete records declaration
 n alias,qnum
 s alias=$p(%zq("drec",0),":",1)
 f qnum=1:1 q:'$d(^mgtmp($j,"from","x",qnum))  i $d(^mgtmp($j,"from","x",qnum,alias)) s %zq("drec",0,alias)="" q
 i '$l($o(%zq("drec",0,""))) s error="alias '"_%zq("drec",0)_"' in 'delete_records' is not defined in the query",error(5)="HY000" q
 q
 ;
trx(wrd) ; data translation 
 n i,ii,arg,arg1,pre,post,type,cn,sqv
 s cn=$i(^mgtmp($j,"trx")),sqv="__evar"_cn
 s type="" f i=1:1 s type=$e(wrd,i) i type?1a q
 f i=2:1 s chr=$e(wrd,i) i chr=":"!(chr?1"""")!(chr?1"{")!(chr?1n)!(chr="") q
 f ii=$l(wrd)-1:-1:1 s chr=$e(wrd,ii) i chr?1""""!(chr?1"}")!(chr?1an)!(chr="") q
 s arg=$e(wrd,i,ii),pre=$e(wrd,1,i-1),post=$e(wrd,ii+1,9999)
 i arg?1":"1a.e s arg1=$e(arg,2,999) i arg1'="" s ^mgtmp($j,"in",arg1)=""
 s ^mgtmp($j,"trx",sqv)=chr
 s ^mgtmp($j,"trx",sqv,1)=arg
 q %z("dsv")_sqv_%z("dsv")
 ;
 
 
