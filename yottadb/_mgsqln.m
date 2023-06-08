%mgsqln ;(CM) MGSQL odbc ; 28 Jan 2022  10:01 AM
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2023 MGateway Ltd                                     |
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
main ; start xDBC service
 n %user,%zi,%zo,dbid,data,info,line,status,error,cmnd
 new $ztrap set $ztrap="zgoto "_$zlevel_":loope^%mgsqln"
 k ^mgtmp($j)
 ; d logevent^%mgsqls("Process: "_$j,"Initialize Connection","ODBC")
 s data=$$v^%mgsql()
 d send(data,$l(data),0,"c",1)
loop ; next command
 new $ztrap set $ztrap="zgoto "_$zlevel_":loope^%mgsqln"
 k %zi,%zo,info,line,error
 s status=0,error="",%user=""
 s dbid=$$schema^%mgsql("")
 s %zi(0,"stmt")=$$read(.head,.cmnd,.size,.data)
 ; d logevent^%mgsqls("stmt="_%zi(0,"stmt")_"; cmnd="_cmnd_"; data="_data,"start","ODBC")
 i cmnd="i" s %user=$$info(dbid,data) g loop
 i cmnd="a" s status=$$typ^%mgsqln2(dbid,data,.%zi,.%zo) g loop
 i cmnd="s" s status=$$sql(dbid,data,.%zi,.%zo,%user,.info) i status=0 d send(%zo("xr"),$l(%zo("xr")),0,%zo("xc"),0) g loop
 i status=11 tstart  k info("tp",0,"start") s status=$$sql2(dbid,data,.%zi,.%zo,.info) i status=0 d send(%zo("xr"),$l(%zo("xr")),0,%zo("xc"),0) g loop
 i status=12 tstart  k info("tp",0,"start") d send(%zo("xr"),$l(%zo("xr")),0,%zo("xc"),0) g loop
 i status=13 tcommit  k info("tp",0,"commit") d send(%zo("xr"),$l(%zo("xr")),0,%zo("xc"),0) g loop
 i status=14 trollback  k info("tp",0,"rollback") d send(%zo("xr"),$l(%zo("xr")),0,%zo("xc"),0) g loop
 i cmnd="b" s status=$$prp(dbid,data,.%zi,.%zo,) g loop
 i cmnd="t" s status=$$tab^%mgsqln1(dbid,data,.%zi,.%zo) g loop
 i cmnd="h" s status=$$col^%mgsqln1(dbid,data,.%zi,.%zo) g loop
 i cmnd="n" s status=$$stt^%mgsqln1(dbid,data,.%zi,.%zo) g loop
 i cmnd="k" s status=$$pky^%mgsqln1(dbid,data,.%zi,.%zo) g loop
 i cmnd="m" s status=$$fky^%mgsqln1(dbid,data,.%zi,.%zo) g loop
 i cmnd="p" s status=$$prc^%mgsqln1(dbid,data,.%zi,.%zo) g loop
 i cmnd="q" s status=$$pcc^%mgsqln1(dbid,data,.%zi,.%zo) g loop
 i cmnd="f" s status=$$fetch(dbid,data,.%zi,.%zo) g loop
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
info(dbid,data) ; information
 n nv,uci,user,error
 new $ztrap set $ztrap="zgoto "_$zlevel_":infoee^%mgsqln"
 s error=""
 ; d logevent^%mgsqls(data,"Information","ODBC")
 d nv(data,.nv)
 s uci=$g(nv("UCI"))
 s user=$g(nv("User"))
 i uci'="" s rc=$$cuci^%mgsqls(uci)
 s data=""
 s data=data_"mgv="_$$v^%mgsql()_$c(13,10)
 s data=data_"$zv="_$zv_$c(13,10)
 s data=data_$c(13,10)
 d send(data,$l(data),0,"i",1) ; send data
 q user
infoe ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:info: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q ""
 ;
prp(dbid,data,%zi,%zo,%user) ; prepare sql
 n line,error
 new $ztrap set $ztrap="zgoto "_$zlevel_":prpe^%mgsqln"
 k ^mgsqls($j,%zi(0,"stmt"))
 d sqline(data,.line)
 d logarray^%mgsqls(.line,"prp() array","ODBC")
 s error=""
 s response=$$sql1(dbid,.line,.%zi,.%zo,%user,.info,.error) i $l(error) g prperror
 d send(response,$l(response),0,"b",0) ; send data
 q
prperror ; prepare sql error
 d logerror^%mgsqls(error,"SQL Error")
 d send(error,$l(error),0,"e",0)
 q
prpe ; M error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:prp: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q
 q
 ;
sql(dbid,data,%zi,%zo,%user,info) ; sql
 n at,tname,r,sn,dtyp,i,x,line,status,error
 s status=0,error=""
 d sqline(data,.line,.%zi)
 d logarray^%mgsqls(.line,"sql()","ODBC")
 s error=""
 s response=$$sql1(dbid,.line,.%zi,.%zo,%user,.info,.error) i $l(error) g sqlerror
 s %zo("xr")=response,%zo("xrl")=$l(response),%zo("xc")="s"
 i $d(info("tp",0)) d  i status=11 q status
 . i $d(info("tp",0,"start")),$g(%zo("routine"))'="" s status=11 q
 . i $d(info("tp",0,"start")) s status=12
 . i $d(info("tp",0,"commit")) s status=13
 . i $d(info("tp",0,"rollback")) s status=14
 . q
 i $g(%zo("routine"))="" q status
 s ok=$$sql2(dbid,data,.%zi,.%zo,.info)
 q status
sqlerror ; sql error
 d logerror^%mgsqls(error,"SQL Error")
 i $g(error(5))="" s error(5)="HY000"
 s %zo("xr")=":"_$g(error(5))_":"_error,%zo("xrl")=$l(error),%zo("xc")="e"
 ;d send(":"_$g(error(5))_":"_error,$l(error),0,"e",0)
 q status
 ;
sql1(dbid,line,%zi,%zo,%user,info,error) ; sql - compile query
 n i,x,qid,cname,cname,dtyp,ag,sn,response
 s error="",response=""
 k ^mgsqls($j,%zi(0,"stmt"))
 s %zo("routine")=$$main^%mgsqlx(dbid,.line,.info,.error)
 i $l(error) q error
 s qid=$g(info("qid")) i qid="" s response=response_$c(13,10) q response
 s x="" f  s x=$o(^mgsqlx(1,dbid,qid,"t",x)) q:x=""  i '$$acc(%user,"0",x,0,.error,.info) s error="No Permission",error(5)="42000" q
 i $l(error) q error
 s response="" f i=1:1 q:'$d(^mgsqlx(1,dbid,qid,"out",i))  d
 . s r=$g(^(i))
 . s cname=$p(r,"~",1)
 . s tname=$p(r,"~",2)
 . s dtyp=$p(r,"~",8)
 . i cname["(" d  q
 . . s ag=$p(cname,"("),cname=$p($p(cname,"(",2,999),")",1)
 . . i cname["." s cname=$p(cname,".",2)
 . . s ag=$$trim^%mgsqln(ag," ")
 . . s cname=$$trim^%mgsqln(cname," ")
 . . i cname="" s cname="col_"_i
 . . s cname=ag_"-"_cname
 . . s cname=$tr(cname,":","")
 . . q
 . i cname["." s cname=$p(cname,".",2)
 . i cname="" s cname="xxx"
 . s response=response_i_"~"_cname_"~"_cname_"~"_tname_$c(13,10)
 . q
 s sn=i-1,response=response_$c(13,10)
 q response
 ;
sql2(dbid,sql,%zi,%zo,info) ; sql - run compiled code
 n ok,rc,error,status
 new $ztrap set $ztrap="zgoto "_$zlevel_":sqle^%mgsqln"
 s error="",status=0
 i $d(info("sp")) d  g sql21
 . s ok=-1
 . s rc=$$so^%mgsqlz()
 . s @("ok=$$"_%zo("routine")_"(.%zi,.%zo)")
 . s rc=$$sc^%mgsqlz()
 . q
 i %zo("routine")'="" s @("ok=$$exec^"_%zo("routine")_"(.%zi,.%zo)")
 i $d(%zo("error")) s error=$g(%zo("error")),error(5)="HY000" g sqle1
sql21 ; sql success
 i $d(info("tp",0,"commit")) s status=13
 i $d(info("tp",0,"rollback")) s status=14
 ; d logevent^%mgsqls($g(zo("xr")),"sql2() response","ODBC")
 q status
sqle ; M error
 s error=$$error^%mgsqls(),error(5)="HY000"
sqle1 ; SQL error
 d logerror^%mgsqls("MGSQL:sql: "_error,"M Exception")
 s %zo("xr")=error,%zo("xrl")=$l(error),%zo("xc")="e"
 q status
 ;
fetch(dbid,data,%zi,%zo) ; get data
 n eod,rn,cn,val,line,error
 new $ztrap set $ztrap="zgoto "_$zlevel_":fetche^%mgsqln"
 s rn=$i(^mgsqls($j,%zi(0,"stmt"),0,-10))
 i '$d(^mgsqls($j,%zi(0,"stmt"),0,rn)) s line="",eod=1 g fetchx
 s line="",eod=0
 f cn=1:1 q:'$d(^mgsqls($j,%zi(0,"stmt"),0,rn,cn))  d
 . s val=$g(^mgsqls($j,%zi(0,"stmt"),0,rn,cn))
 . s line=line_$$esize($l(val),4,$$base())_val
 . q
fetchx ; dispatch result
 d send(line,$l(line),%zi(0,"stmt"),"f",eod) ; send data
 q 0
fetche ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d logerror^%mgsqls("MGSQL:fetch: "_error,"M Exception")
 d send(error,$l(error),0,"e",0)
 q 0
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
 w head_data d flush^%mgsqls()
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
sqline(sql,line,%zi)
 n i,x,y,ln
 s ln=0
 f i=1:1:$l(sql,$c(10))  s x=$p(sql,$c(10),i) s y=$p(x,$c(13),1) d
 . i y="" q
 . i y?1"$:iv"1n.n.e s %zi($p(y,":",2))=$p(y,":",5) q
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
 i '$d(%sql("op",%zi(0,"stmt"),op,type)) q res
 s in=val x %sql("op",%zi(0,"stmt"),op,type) s res=$g(out1)
 ; double decode ???
 i res="",in'="" s res=in
 q res
ope ; error
 q res
 ;
test ; test
 k
 s %user="cm"
 s %zi(0,"stmt")=0
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
accept(port) ; Concurrent TCP service (Cache, M21, MSM)
 new $ztrap set $ztrap="zgoto "_$zlevel_":accepth^%mgsqln"
 d seterror^%mgsqls("")
 s port=+$g(port)
 i 'port s port=7041
 s ^%mgsql("server",port)=$j 
 s dev="server$"_$j
 s errors=0
 s timeout=10
accept1 ; Main accept loop
 ; Set up Socket Server
 c dev
 ; open tcp server device
 open dev:(listen=port_":tcp":attach="server"):timeout:"socket"
 ;
 ; use tcp server device
 use dev
 write /listen(5) 
 ;
accept2 ; Accept connection
 new $ztrap set $ztrap="zgoto "_$zlevel_":accepte^%mgsqln"
 set %znsock="",%znfrom="",timeout=30
 s ok=1 f  d  q:ok  i $d(^%mgsql("stop")) s ok=0 k ^%mgsql("stop") q
 . write /wait(timeout)
 . i $key'="" s ok=1 q
 . s ok=0
 . q
 i 'ok g acceptx
 d logevent^%mgsqls("incoming connection from "_$piece($key,"|",3)_", starting child server process","Server","ODBC")
 s childsock=$p($key,"|",2)
 u dev:(detach=childsock)
 s childproc="child^%mgsqln(port,port):(output="_"""SOCKET:"_childsock_""""_":input="_"""SOCKET:"_childsock_""""_")"
 j @childproc ; fork a process to handle the detached socket
 ;
 s errors=0
 g accept2
acceptx ; Exit
 d logevent^%mgsqls("Closing Server","Server","ODBC")
 c dev
 q
 ;
accepte ; Error
 new $ztrap set $ztrap="zgoto "_$zlevel_":accepth^%mgsqln"
 s errors=errors+1
 I $$error^%mgsqls()["INT" h
 d logerror^%mgsqls("Accept Loop - Program Error: "_$$error^%mgsqls(),"ODBC Error")
 i errors>7 d logerror^%mgsqls("Accept Loop - Too many errors - Closing Down","ODBC Error") h
 i $g(dev)'="" u dev
 g accept2
accepth ; Halt
 h
 ;
child(pport,port) ; Child
 n nato,buf,x
 new $ztrap set $ztrap="zgoto "_$zlevel_":childe^%mgsqln"
 i 'pport g child2
 u $principal
 ;
 s nato=0
child2 ; Child request loop
 i '($d(nato)#10) s nato=0
child3 ; Read Request
 i 'nato r *x
 i nato r *x:nato i '$t g childh ; No-activity timeout
 i x=0 d accepth ; client disconnect
 s buf=$c(x) f  r *x q:x=10!(x=0)  s buf=buf_$c(x)
 i x=0 d accepth ; client disconnect
 i buf="xDBC" g main^%mgsqln
 i buf?1U.E1"HTTP/"1N1"."1N1C s buf=buf_$c(10) g main^%mgsqlw
 g childh
 ;
childe ; Error
 d logerror^%mgsqls($$error^%mgsqls(),"ODBC Error")
 i $$error^%mgsqls()["%gtm-e-ioeof" g childh
 ;
childh ; Halt
 h
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
