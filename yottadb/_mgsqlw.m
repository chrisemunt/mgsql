%mgsqlw ;(CM) MGSQL HTTP ; 17 dec 2003  3:15 pm
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
a d vers^%mgsql("%mgsqlw") q
 ;
main ; start
 n %zi,%zo,dbid,head,ok,cgi,data,nvp,error
 new $ztrap set $ztrap="zgoto "_$zlevel_":loope^%mgsqlw"
 k ^mgtmp($j)
 s dbid=$$init(.%zi)
 s head=buf
loop ; next command
 new $ztrap set $ztrap="zgoto "_$zlevel_":loope^%mgsqlw"
 s ok=$$read(.head,.cgi,.data)
 s ok=$$nvp($g(cgi("QUERY_STRING")),.nvp)
 i $g(cgi("CONTENT_TYPE"))="application/x-www-form-urlencoded" s ok=$$nvp($g(data),.nvp)
 i '$d(nvp("UCI")) s nvp("UCI")="USER"
 i $g(nvp("UCI"))'="" s ok=$$cuci^%mgsqls($g(nvp("UCI")))
 i $g(cgi("SCRIPT_NAME"))[".ico" d notfound g loop1
 i $d(nvp("SQL")) d sql(dbid,.%zi,$g(nvp("SQL"))) g loop1
 i $d(nvp("sql")) d sql(dbid,.%zi,$g(nvp("sql"))) g loop1
 i $d(nvp("QUERY")) d sql(dbid,.%zi,$g(nvp("QUERY"))) g loop1
 i $d(nvp("query")) d sql(dbid,.%zi,$g(nvp("query"))) g loop1
 i $g(cgi("CONTENT_TYPE"))["/sql" d sql(dbid,.%zi,data) g loop1
 d sqlform
loop1 ; request satisfied
 c $I
 h
loope ; error
 s error=$$error^%mgsqls(),error(5)="HY000"
 d servererror(error)
 d logerror^%mgsqls($$error^%mgsqls(),"M Exception")
 h
 ;
init(%zi) ; essential constants
 n dbid
 s dbid="mgsql"
 s %zi("df")=$c(1)
 s %zi("base")=10
 q dbid
 ;
read(head,cgi,data) ; read request
 n x,i,line,len,clen,pathinfo
 k cgi
 s data=""
 f  r *x s head=head_$c(x) q:head[$c(13,10,13,10)
 s head=$$rreplace^%mgsqls(head,"  "," ")
 s line=$p(head,$c(13,10),1)
 s cgi("REQUEST_METHOD")=$p(line," ",1)
 s cgi("SCRIPT_NAME")=$p($p(line," ",2),"?",1)
 s cgi("PATH_INFO")=$p(cgi("SCRIPT_NAME"),".sql",2,9999)
 s cgi("SCRIPT_NAME")=$p(cgi("SCRIPT_NAME"),".sql",1)_".sql"
 i line["?" s cgi("QUERY_STRING")=$p($p(line," ",2),"?",2,9999)
 s cgi("SERVER_PROTOCOL")=$p(line," ",3)
 f i=2:1 s line=$p(head,$c(13,10),i) q:line=""  d
 . s name=$tr($$ucase^%mgsqls($$rtrim^%mgsqls($p(line,":",1)," ")),"-","_")
 . i name="CONTENT_LENGTH"!(name="CONTENT_TYPE") s cgi(name)=$$ltrim^%mgsqls($p(line,":",2,999)," ") q
 . s cgi("HTTP_"_name)=$$ltrim^%mgsqls($p(line,":",2,999)," ")
 . q
 s clen=+$g(cgi("CONTENT_LENGTH")) i clen=0 q 1
 s data="",len=0 f  r x#(clen-len) s data=data_x,len=len+$l(x) i len=clen q
 q 1
reade ; Error
 q 0
 ;
nvp(qs,nvp) ; get name/value pairs for url-encoded content
 n i,p,name,value
 i qs="" q 1
 f i=1:1:$l(qs,"&") s p=$p(qs,"&",i) d
 . s name=$p(p,"=",1),value=$p(p,"=",2)
 . i name="" q
 . s nvp($$urldecode^%mgsqls(name))=$$urldecode^%mgsqls(value)
 . q
 q 1
nvpe ; Error
 q 0
 ;
sql(dbid,%zi,sql) ; run query
 n %zo,cols,stmt,error,line,info,rou,qid,i,r,cname,tname,dtyp,ag,ok,rc
 s dbid=$$schema^%mgsql("")
 s stmt=0
 s sql=$tr(sql,$c(13,10),"")
 s error=""
 s line(1)=sql
 s %zi(0,"stmt")=0
 s rou=$$main^%mgsqlx(dbid,.line,.info,.error)
 i rou="" s error="Invalid Query",error(5)="HY000"
 i error'="" g sql1
 s qid=$g(info("qid"))
 f i=1:1 q:'$d(^mgsqlx(1,dbid,qid,"out",i))  d
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
 . s cols(i)=cname
 . q
 i $d(info("sp")) d  g sql1
 . s ok=-1
 . s %zo("routine")=rou
 . s %zi(0,"stmt")=stmt
 . s rc=$$so^%mgsqlz()
 . s @("ok=$$"_rou_"(.%zi,.%zo)")
 . s rc=$$sc^%mgsqlz()
 . q
 i rou'="" s %zo("routine")=rou,@("ok=$$exec^"_rou_"(.%zi,.%zo)")
sql1 ; output result
 d json(.%zi,.%zo,.cols,.error)
 q
 ;
json(%zi,%zo,cols,error) ; output results as JSON document
 n %z,head,out,ecom,rn,cn,name,value,com
 d gvars^%mgsqlx(.%z)
 s head="HTTP/1.1 200 OK"_$c(13,10)
 ;s head=head_"Content-Type: text/plain"_$c(13,10)
 ;s head=head_"Content-Type: text/x-json"_$c(13,10)
 s head=head_"Content-Type: application/json"_$c(13,10)
 s head=head_"Connection: close"_$c(13,10)
 s head=head_$c(13,10)
 w head d flush^%mgsqls()
 i $g(error)'="" s out="{""sqlcode"": "_"-1"_", ""sqlstate"": """_$s($d(error(5)):error(5),1:"HY000")_""", ""error"": """_error_"""}" g json1
 s out="{""sqlcode"": "_"0"_", ""sqlstate"": """_"00000"_""", ""error"": "_""""""
 s out=out_", ""result"": [",ecom=""
 f rn=1:1 q:'$d(^mgsqls($j,%zi(0,"stmt"),0,rn))  d
 . s out=out_ecom_"{",com="",ecom=","
 . f cn=1:1 q:'$d(^mgsqls($j,%zi(0,"stmt"),0,rn,cn))  d
 .. s name=$g(cols(cn))
 .. i name[%z("dsv") s name=$p(name,%z("dsv"),2)
 .. s name=$tr(name,".","_")
 .. s value=$g(^mgsqls($j,%zi(0,"stmt"),0,rn,cn))
 .. s out=out_com_""""_name_""""_": """_value_"""",com=","
 .. q
 . s out=out_"}"
 . q
 s out=out_"]"
 s out=out_"}"
json1 ; response complete
 w out d flush^%mgsqls()
 q
 ;
sqlform ; output a simple form
 n head,out
 s head="HTTP/1.1 200 OK"_$c(13,10)
 s head=head_"Content-Type: text/html"_$c(13,10)
 s head=head_"Connection: close"_$c(13,10)
 s head=head_$c(13,10)
 w head d flush^%mgsqls()
 s out="<html>"_$c(13,10)
 s out=out_"<head><title>SQL Test Form</title></head>"_$c(13,10)
 s out=out_"<body>"_$c(13,10)
 s out=out_"<form method=POST>"_$c(13,10)
 s out=out_"<h2>SQL Test Form</h2>"_$c(13,10)
 s out=out_"<p></p>"_$c(13,10)
 s out=out_"<textarea name=SQL rows=20 cols=140></textarea>"_$c(13,10)
 s out=out_"<p></p>"_$c(13,10)
 s out=out_"<input type=SUBMIT value='Execute SQL'>"_$c(13,10)
 s out=out_"</form>"_$c(13,10)
 s out=out_"</body>"_$c(13,10)
 s out=out_"</html>"_$c(13,10)
 w out d flush^%mgsqls()
 q
 ;
notfound ; HTTP not found
 n head
 s head="HTTP/1.1 404 Not Found"_$c(13,10)
 s head=head_"Connection: close"_$c(13,10)
 s head=head_$c(13,10)
 w head d flush^%mgsqls()
 q
 ;
servererror(error) ; HTTP internal server error
 n head
 s head="HTTP/1.1 500 Internal Server Error"_$c(13,10)
 s head=head_"Connection: close"_$c(13,10)
 s head=head_$c(13,10)
 w head,error
 d flush^%mgsqls()
 q
 ;
test ; test harness
 k
 ;s sql="select * from patient a"
 s sql="call patient_getdata"
 d sql(sql)
 q
 ;
 
