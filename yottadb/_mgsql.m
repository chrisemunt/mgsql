%mgsql ;(CM) MGSQL Front end
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
a d vers("%mgsql") q
 ; 
v() ; version and date
 n v,r,d
 ;s v="1.0",r=1,d="1 December 2018"
 ;s v="1.0",r=2,d="26 March 2019"
 ;s v="1.0",r=3,d="10 May 2019"
 ;s v="1.0",r=4,d="11 May 2019"
 ;s v="1.0",r=5,d="14 May 2019"
 ;s v="1.0",r=6,d="7 June 2019"
 ;s v="1.0",r=7,d="13 June 2019"
 ;s v="1.0",r=8,d="1 November 2019"
 ;s v="1.1",r=9,d="15 January 2020"
 ;s v="1.2",r=10,d="14 April 2020"
 ;s v="1.2",r=11,d="28 May 2020"
 ;s v="1.2",r=12,d="3 January 2021"
 s v="1.2",r=13,d="5 January 2021"
 q v_"."_r_"."_d
 ;
vers(this) ; version information
 n v
 s v=$$v()
 w !,"MGSQL by M/Gateway Developments Ltd."
 w !,"Version: "_$P(v,".",1,2)_"; Revision "_$P(v,".",3)_" ("_$P(v,".",4)_")"_" "_this
 w !
 Q
 ;
upgrade(mode) ; upgrade this installation
 k ^mgsqlx,^mgtmp,^mgtemp
 q 0
 ;
exec(dbid,sql,%zi,%zo)
 n (dbid,sql,%zi,%zo)
 new $ztrap set $ztrap="zgoto "_$zlevel_":exece^%mgsql"
 ;d upgrade(0)
 s error="",ok=0
 s dbid=$$schema(dbid)
 s line(1)=sql
 s rou=$$main^%mgsqlx(dbid,.line,.info,.error)
 i error'="" s %zo("error")=error q -1
 i $d(info("sp")) d  g exec1
 . s ok=-1
 . s %zo("routine")=rou
 . s rc=$$so^%mgsqlz()
 . s @("ok=$$"_rou_"(.%zi,.%zo)")
 . s rc=$$sc^%mgsqlz()
 . q
 i rou'="" s %zo("routine")=rou,@("ok=$$exec^"_rou_"(.%zi,.%zo)")
exec1 ; exit
 q ok
 ;
exece ; error
 w !!,"error=",$$error^%mgsqls()
 q -1
 ;
inetd ; entry point from [x]inetd
xinetd ; someone is sure to use this label
 new $ztrap set $ztrap="zgoto "_$zlevel_":inetde^%mgsql"
 s buf="" f  r *x q:x=10  s buf=buf_$c(x)
 i buf="xDBC" d main^%mgsqln q
 i buf?1U.E1"HTTP/"1N1"."1N1C s buf=buf_$c(10) d main^%mgsqlw q
 q
inetde ; error
 w $$error^%mgsqls()
 q
 ;
schema(schema) ; schema
 i schema="" q "mgsql"
 q schema
 ;
start(port) ; Start daemon
 new $ztrap set $ztrap="zgoto "_$zlevel_":starte^%mgsql"
 s port=+$g(port)
 w !,"Not supported, use inetd or xinetd instead"
 q
starte ; Error
 w $ze
 q
 ;
killproc(pid) ; Stop this listener
 i '$l(pid) q
 w !,"stop: "_pid
 q
 ;
ylink ; link all routines
 ;;zlink "_mgsql.m"
 zlink "_mgsqlc.m"
 zlink "_mgsqlc1.m"
 zlink "_mgsqlc2.m"
 zlink "_mgsqlc3.m"
 zlink "_mgsqlc4.m"
 zlink "_mgsqlc5.m"
 zlink "_mgsqlc6.m"
 zlink "_mgsqlcd.m"
 zlink "_mgsqlci.m"
 zlink "_mgsqlct.m"
 zlink "_mgsqlcu.m"
 zlink "_mgsqld.m"
 zlink "_mgsqle.m"
 zlink "_mgsqle1.m"
 zlink "_mgsqle2.m"
 zlink "_mgsqln.m"
 zlink "_mgsqln1.m"
 zlink "_mgsqln2.m"
 zlink "_mgsqlo.m"
 zlink "_mgsqlo1.m"
 zlink "_mgsqlo2.m"
 zlink "_mgsqlp.m"
 zlink "_mgsqlp1.m"
 zlink "_mgsqlr.m"
 zlink "_mgsqls.m"
 zlink "_mgsqlv.m"
 zlink "_mgsqlv1.m"
 zlink "_mgsqlv2.m"
 zlink "_mgsqlv3.m"
 zlink "_mgsqlv4.m"
 zlink "_mgsqlv5.m"
 zlink "_mgsqlv6.m"
 zlink "_mgsqlw.m"
 zlink "_mgsqlx.m"
 zlink "_mgsqlz.m"
 q
 ;
 ;
 ; SQL samples
 ;
drop ; drop tables
 k %zi,%zo
 s ok=$$exec^%mgsql("","drop table patient",.%zi,.%zo)
 s ok=$$exec^%mgsql("","drop table admission",.%zi,.%zo)
 s ok=$$exec^%mgsql("","drop table labtest",.%zi,.%zo)
 q
 ;
create ; create tables
 k %zi,%zo
 s sql="create table patient ("
 s sql=sql_" num int not null,"
 s sql=sql_" name varchar(255),"
 s sql=sql_" address varchar(255) separate ('address'),"
 s sql=sql_" dob date,"
 s sql=sql_" age int derived age^%mgsqls(dob),"
 s sql=sql_" constraint pk_patient primary key (num))"
 s sql=sql_" /*! global=mgpat, delimiter=# */"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 ;
 s sql="create table admission ("
 s sql=sql_" num int not null,"
 s sql=sql_" dadm date not null,"
 s sql=sql_" ward varchar(32),"
 s sql=sql_" con varchar(32),"
 s sql=sql_" constraint pk_admission primary key ('p', num, dadm))"
 s sql=sql_" /*! global=mgadm, delimiter=# */"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 ;
 s sql="create table labtest ("
 s sql=sql_" num int not null,"
 s sql=sql_" dtest date not null,"
 s sql=sql_" test varchar(32),"
 s sql=sql_" result int,"
 s sql=sql_" constraint pk_labtest primary key ('p', num, dtest, test))"
 s sql=sql_" /*! global=mgtst, delimiter=# */"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 q
 ;
index ; create index
 k %zi,%zo
 s sql="create index index1 on admission ('index1', dadm, num)"
 s sql=sql_" /*! global=mgadm */"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 q
 ;
delete ; delete records
 k %zi,%zo
 s ok=$$exec^%mgsql("","delete from patient",.%zi,.%zo)
 s ok=$$exec^%mgsql("","delete from admission",.%zi,.%zo)
 s ok=$$exec^%mgsql("","delete from labtest",.%zi,.%zo)
 q
 ;
insert ; insert records
 k %zi,%zo
 s sql="insert into patient (num, name, address, dob) values (:num, :name, :address, {d:dob})"
 s %zi("num")=1,%zi("name")="Peter Davis",%zi("address")="Banstead",%zi("dob")="1974-08-12",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=2,%zi("name")="Sarah Jones",%zi("address")="Redhill",%zi("dob")="1967-07-13",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=3,%zi("name")="John Smith",%zi("address")="London",%zi("dob")="2002-04-21",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=4,%zi("name")="Jane Doe",%zi("address")="Oxford",%zi("dob")="1997-11-10",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 ;
 k %zi,%zo
 s sql="insert into admission (num, dadm, ward, con) values (:num, {d:dadm}, :ward, :con)"
 s %zi("num")=1,%zi("dadm")="2012-02-20",%zi("ward")="B1",%zi("con")="IES",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=1,%zi("dadm")="2012-03-21",%zi("ward")="B3",%zi("con")="JM",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=1,%zi("dadm")="2015-01-17",%zi("ward")="B1",%zi("con")="TJP",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=1,%zi("dadm")="2016-01-01",%zi("ward")="B1",%zi("con")="IES",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=2,%zi("dadm")="2018-02-20",%zi("ward")="C1",%zi("con")="EW",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=3,%zi("dadm")="2018-04-21",%zi("ward")="D2",%zi("con")="RS",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=2,%zi("dadm")="2018-11-10",%zi("ward")="C3",%zi("con")="RP",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 ;
 k %zi,%zo
 s sql="insert into labtest (num, dtest, test, result) values (:num, {d:dtest}, :test, :result)"
 s %zi("num")=1,%zi("dtest")="2012-02-20",%zi("test")="HGB",%zi("result")="14.2",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=1,%zi("dtest")="2012-03-21",%zi("test")="HGB",%zi("result")="15.1",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=1,%zi("dtest")="2015-01-17",%zi("test")="HGB",%zi("result")="15.7",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=1,%zi("dtest")="2016-01-01",%zi("test")="HGB",%zi("result")="17.1",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=2,%zi("dtest")="2018-02-20",%zi("test")="HGB",%zi("result")="13.2",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=2,%zi("dtest")="2018-11-10",%zi("test")="HGB",%zi("result")="14.7",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 s %zi("num")=3,%zi("dtest")="2018-04-21",%zi("test")="HGB",%zi("result")="16.4",ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 q
 ;
update ; update a record
 k %zi,%zo
 s ok=$$exec^%mgsql("","update patient a set a.address = 'Cambridge' where a.num = 4",.%zi,.%zo)
 q
 ;
sel1 ; select all patient records
 k %zi,%zo
 s ok=$$exec^%mgsql("","select * from patient",.%zi,.%zo)
 q
 ;
sel2 ; select all admitted patients and their admission records (joining the tables using a 'where' statement)
 k %zi,%zo
 s ok=$$exec^%mgsql("","select a.num,a.name,b.dadm,b.ward,b.con from patient a, admission b where a.num = b.num",.%zi,.%zo)
 q
 ;
sel3 ; select all admitted patients and their admission records (using an 'inner join' construct)
 k %zi,%zo
 s ok=$$exec^%mgsql("","select a.num,a.name,b.dadm,b.ward,b.con from patient a inner join admission b using (num)",.%zi,.%zo)
 q
 ;
sel4 ; select all patients and any associated admission records (using an 'outer join' construct)
 k %zi,%zo
 s ok=$$exec^%mgsql("","select a.num,a.name,b.dadm,b.ward,b.con from patient a left join admission b using (num)",.%zi,.%zo)
 q
 ;
sel5 ; select all patients who have been admitted more than 3 times
 k %zi,%zo
 s sql="select a.num,a.name,b.dadm,b.ward,b.con from patient a, admission b"
 s sql=sql_" where a.num = b.num and 3 < select count(c.dadm) from admission c where c.num = a.num"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 q
 ;
sel6 ; count the number of times admitted patients have been admitted
 k %zi,%zo
 s sql="select a.num,a.name,count(b.dadm) from patient a, admission b"
 s sql=sql_" where a.num = b.num"
 s sql=sql_" group by a.num"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 q
 ;
sel7 ; select all patients who have been admitted more that 3 times
 k %zi,%zo
 s sql="select a.num,a.name,count(*) from patient a, admission b"
 s sql=sql_" where a.num = b.num"
 s sql=sql_" group by a.num,a.name"
 s sql=sql_" having count(*) > 3"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 q
 ;
sel8 ; select all patient records but just show each patient's surname
 k %zi,%zo
 s ok=$$exec^%mgsql("","select a.num,$p(a.name,"" "",2) from patient a",.%zi,.%zo)
 q
 ;
sel9 ; select all patients and any associated admission records, but only those for ward 'B3'
 k %zi,%zo
 s ok=$$exec^%mgsql("","select a.num,a.name,b.num,b.dadm,b.ward from patient a left join admission b on a.num = b.num and b.ward = 'B3'")
 q
 ;
sel10 ; select all patients older than 40.  Convert names to upper case
 k %zi,%zo
 s ok=$$exec^%mgsql("","select a.num,upper(a.name),a.dob,a.age from patient a where a.age > 40")
 q
 ;
sel11 ; select distinct patient names
 k %zi,%zo
 s ok=$$exec^%mgsql("","select distinct name from patient",.%zi,.%zo)
 q
 ;
sel12 ; select distinct patient names
 k %zi,%zo
 s ok=$$exec^%mgsql("","select distinct a.name from patient a where upper(a.address) like '%BANSTEAD%'",.%zi,.%zo)
 q
 ;
proc ; create stored procedures
 s ok=$$exec^%mgsql("","CREATE PROCEDURE patient_getdata (num int, name varchar(255), address varchar(255))",.%zi,.%zo)
 s ok=$$exec^%mgsql("","CREATE PROCEDURE SelectAllPatients AS SELECT * FROM patient GO;",.%zi,.%zo)
 q
 ;
 

