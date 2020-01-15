%mgsqln ;(CM) MGSQL odbc ; 17 dec 2003  3:15 pm
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
a d vers^%mgsql("%mgsqln") q
 ;
main ; start
 new $ztrap set $ztrap="zgoto "_$zlevel_":loope^%mgsqln"
 k ^mgtmp($j)
 d logevent^%mgsqls("Process: "_$j,"Initialize Connection","ODBC")
 s data=$$v^%mgsql()
 d send(data,$l(data),0,"c",1)
loop ; next command
 new $ztrap set $ztrap="zgoto "_$zlevel_":loope^%mgsqln"
 s dbid=$$schema^%mgsql("")
 s stmt=$$read(.head,.cmnd,.size,.data)
 ;d logevent^%mgsqls("stmt="_stmt_"; cmnd="_cmnd_"; data="_data,"start","ODBC")
 i cmnd="i" d info g loop
 i cmnd="a" d typ^%mgsqln2  g loop
 i cmnd="s" d sql g loop
 i cmnd="b" d prp g loop
 i cmnd="t" d tab^%mgsqln1 g loop
 i cmnd="h" d col^%mgsqln1 g loop
 i cmnd="n" d stt^%mgsqln1 g loop
 i cmnd="k" d pky^%mgsqln1 g loop
 i cmnd="m" d fky^%mgsqln1 g loop
 i cmnd="p" d prc^%mgsqln1 g loop
 i cmnd="q" d pcc^%mgsqln1 g loop
 i cmnd="f" d fetch g loop
 d logerror^%mgsqls("MGSQL: bad message: "_cmnd,"ODBC Error")
 g loop
loope ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:loop: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q
 ;
acc(user,dbid,tname,context,error,info) ; see if access is allowed
 s error=""
 q 1
 ;
base() ; get base for chunk headers
 q 10
 q
 ;
info ; information
 n nv
 new $ztrap set $ztrap="zgoto "_$zlevel_":infoee^%mgsqln"
 d logevent^%mgsqls(data,"Information","ODBC")
 d nv(data,.nv)
 s uci=$g(nv("UCI"))
 s %user=$g(nv("User"))
 i uci'="" s rc=$$cuci^%mgsqls(uci)
 s data=""
 s data=data_"mgv="_$$v^%mgsql()_$c(13,10)
 s data=data_"$zv="_$zv_$c(13,10)
 s data=data_$c(13,10)
 d send(data,$l(data),0,"i",1) ; send data
 q
infoe ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:info: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q
 ;
prp ; prepare sql
 n at,tname,r,sn,dtyp,i,x,line
 new $ztrap set $ztrap="zgoto "_$zlevel_":prpe^%mgsqln"
 k ^mgsqls($j,stmt)
 d sqline(data,.line)
 d logarray^%mgsqls(.line,"prp() array","ODBC")
 s error=""
 d sql1 i $l(error) g sqlerror
 d send(line,$l(line),0,"b",0) ; send data
 q
prperror ; prepare sql error
 d logerror^%mgsqls(error,"SQL Error")
 d send(error,$l(error),0,"e",0)
 q
prpe ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:prp: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q
 q
 ;
sql ; sql
 n %zi,%zo,at,tname,r,sn,dtyp,i,x,line,param
 new $ztrap set $ztrap="zgoto "_$zlevel_":sqle^%mgsqln"
 d sqline(data,.line,.param)
 ;d logarray^%mgsqls(.line,"sql()","ODBC")
 s error=""
 d sql1 i $l(error) g sqlerror
 i $d(info("sp")) d  g sql2
 . s ok=-1
 . s %zo("routine")=rou
 . s %zi("stmt")=stmt
 . s rc=$$so^%mgsqlz()
 . s @("ok=$$"_rou_"(.%zi,.%zo)")
 . s rc=$$sc^%mgsqlz()
 . q
 m %zi=param("i")
 s %zo("routine")=rou,%zi("stmt")=stmt,@("ok=$$exec^"_rou_"(.%zi,.%zo)")
 i $d(%zo("error")) s error=$g(%zo("error")),error(5)="HY000" g sqlerror
sql2 ; 
 d send(line,$l(line),0,"s",0) ; send data
 q
sqlerror ; sql error
 d logerror^%mgsqls(error,"SQL Error")
 i $g(error(5))="" s error(5)="HY000"
 d send(":"_$g(error(5))_":"_error,$l(error),0,"e",0)
 q
sqle ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:sql: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q
 ;
sql1 ; sql - process/compile and fire off routine
 n %txt,i,cname,dtyp,qid,lvar,res,n,type,qid,x,sqlcnt,sn,com,info
 s error=""
 k ^mgsqls($j,stmt)
 s rou=$$main^%mgsqlx(dbid,.line,.info,.error)
 i $l(error) q
 s qid=$g(info("qid"))
 s x="" f  s x=$o(^mgsqlx(1,dbid,qid,"t",x)) q:x=""  i '$$acc(%user,"0",x,0,.error,.%user) s error="No Permission",error(5)="42000" q
 i $l(error) q
 s line="" f i=1:1 q:'$d(^mgsqlx(1,dbid,qid,"out",i))  d
 . s r=$g(^(i))
 . s cname=$p(r,"~",1)
 . s tname=$p(r,"~",2)
 . s dtyp=$p(r,"~",8)
 . i cname["(" d  q
 . . s ag=$p(cname,"("),cname=$p($p(cname,"(",2,999),")",1)
 . . i cname["." s cname=$p(cname,".",2)
 . . s ag=$$trim^%mgsqln(ag)
 . . s cname=$$trim^%mgsqln(cname)
 . . i cname="" s cname="col_"_i
 . . s cname=ag_"-"_cname
 . . s cname=$tr(cname,":","")
 . . q
 . i cname["." s cname=$p(cname,".",2)
 . i cname="" s cname="xxx"
 . s line=line_i_"~"_cname_"~"_cname_"~"_tname_$c(13,10)
 . q
 s sn=i-1,line=line_$c(13,10)
 q
 ;
fetch ; get data
 n eod,rn,cn,val
 new $ztrap set $ztrap="zgoto "_$zlevel_":fetche^%mgsqln"
 s rn=$i(^mgsqls($j,stmt,0,-10))
 i '$d(^mgsqls($j,stmt,0,rn)) s line="",eod=1 g fetchx
 s line="",eod=0
 f cn=1:1 q:'$d(^mgsqls($j,stmt,0,rn,cn))  d
 . s val=$g(^mgsqls($j,stmt,0,rn,cn))
 . s line=line_$$esize($l(val),4,$$base())_val
 . q
fetchx ; dispatch result
 d send(line,$l(line),stmt,"f",eod) ; send data
 q
fetche ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:fetch: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q
 ;
read(head,cmnd,size,data) ; read
 new $ztrap set $ztrap="zgoto "_$zlevel_":reade^%mgsqln"
 s cmnd="",data="",size=0
 s head=$$recv(14,0)
 i head="" g reade
 s size=$$dsize($e(head,1,4),4,$$base())
 s cmnd=$e(head,14)
 s stmt=$$dsize($e(head,10,13),4,$$base())
 i 'size q stmt
 s data=$$recv(size,0)
 q stmt
reade ; error
 d logerror^%mgsqls($$error^%mgsqls(),"read error")
 q 0
 ;
recv(len,timeout)
 n data,get,got,x,y
 s data="",get=len,got=0
 f  r x#get s y=$l(x),data=data_x,got=got+y,get=get-y i got=len q
 q data
 ;
send(data,len,stmt,type,eod) ; send data
 n head
 s len=$l(data)
 s head=$$esize(len,4,$$base())_"0000"_$$esize(stmt,4,$$base())_eod_type
 i $$isydb^%mgsqls() g sendy
 w head_data d flush^%mgsqls()
 q
sendy ; yottadb
 w head_data
 q
 ;
esize(dsize,len,base)
 q $c(dsize#256)_$c(((dsize\256)#256))_$c(((dsize\(256**2))#256))_$c(((dsize\(256**3))#256))
 n esize
 s esize=+dsize f  q:$l(esize)=4  s esize="0"_esize
 q esize
 ;
dsize(esize,len,base)
 q ($a(esize,4)*(256**3))+($a(esize,3)*(256**2))+($a(esize,2)*256)+$a(esize,1)
 s dsize=+esize
 q dsize
 ;
nv(data,nv) ; name/value pairs
 n i,ii,n,v
 f i=1:1:$l(data,$c(13,10)) s r=$p(data,$c(13,10),i) s n=$p(r,"=",1),v=$p(r,"=",2,9999) i n'="" s nv(n)=v
 q
 ;
sqline(sql,line,param)
 n i,x,y,ln
 s ln=0
 f i=1:1:$l(sql,$c(10))  s x=$p(sql,$c(10),i) s y=$p(x,$c(13),1) d
 . i y="" q
 . i y?1"$:iv"1n.n.e s param("i",$p(y,":",2))=$p(y,":",5) q
 . s ln=ln+1,line(ln)=y
 . q
 q
 ;
oname(cname) ; name
 s cname=$tr(cname,"-","_")
 q at
 ;
op(op,type,val) ; operation
 s res=val ; q res
 new $ztrap set $ztrap="zgoto "_$zlevel_":ope^%mgsqln"
 i '$d(%sql("op",stmt,op,type)) q res
 s in=val x %sql("op",stmt,op,type) s res=$g(out1)
 ; double decode ???
 i res="",in'="" s res=in
 q res
ope ; error
 q res
 ;
test ; test
 k
 s %user="cm"
 s stmt=0
 ;s nv("sql")="select * from patient1 a"
 ;s nv("sql")="create table patient (num int not null, name varchar(255), address varchar(255), constraint pk_patient primary key (num))"
 s nv("sql")="select a.num, a.name from patient a"
 ;s nv("sql")="insert into patient (num, name) values (100003, ""verna hammond"")"
 ;s nv("sql")="update patient a set a.address = ""alvie"" where a.num = 100002"
 s data=$g(nv("sql"))
 ;d sql
 ;s data="tablename=admission"_$c(13,10)_$c(13,10)
 s data="tablename=patient"_$c(13,10)_$c(13,10)
 d col^%mgsqln1
 f i=1:1 q:'$d(^mgsqls($j,i,0))  w !,$g(^(0))
 q
 ;
 ;
m ; test
 n a,p,y,t,i,g
 s a=108
 s p=4
 s y=25
 s t=0
 f i=1:1:25 d
 . s t=t+(a*12)
 . s g=t*(p/100)
 . s t=t+g
 . w !,"Year: ",i," (",(a*12*i)," ===> ",t,")"
 . q
 w !,"total: ",t
 q
 ;
