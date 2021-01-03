%mgsqlp ;(CM) sql language processor ; 14 aug 2002  6:16 pm
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
a d vers^%mgsql("%mgsqlp") q
 ;
main(sql,line,error) ; entry
 n sql2,wrk
 s error=""
 s qnummax=0
 k ^mgtmp($j,"translate")
main1 ; re-entry
 k ^mgtmp($j,"cmnd")
 ;k wrk,blk,tmp,sql,log,declare
 s error=""
 d cmnd(.sql2)
 d rips(.line,.wrk,.error) i $l(error) g exit
 s qnummax=$$cdel(.sql2,.wrk,.error) i $l(error) g exit
 d main^%mgsqlp1(qnummax,.sql2,.wrk,.sql,.error) i $l(error) g exit
 i $g(sql(1,2))="from "_%z("dq")_2_%z("dq")_" t0" d cog i ok g main1
exit k tmp,blk
 q qnummax
 ;
cmnd(sql2) ; sql2 commands
 n x
 k sql2
 f x="select","from","where","group","having","order","call" s sql2(x)=0
 f x="join","natural","outer","left","right","full","inner","cross","outer","as","on","using" s sql2(x)=1
 f x="exists","not","and","or","like","in","between" s sql2(x)=2
 f x="update","delete","insert","attributes","into","values","set" s sql2(x)=3
 f x="union","intersect","except" s sql2(x)=4
 f x="transaction","create","drop","by","all" s sql2(x)=5
 f x="commit","current_date","current_time","current_timestamp","start","stop" s sql2(x)=7
 f x="cursor","eof","last","notnull","rollback" s sql2(x)=7
 q
 ;
rips(line,wrk,error) ; rip out all literals and comments
 n ln,ln1,ln2,cn,cn1,cn2,char,charp,charn,txt,instring,sno,qno,mrk
 s ln="" f  s ln=$o(line(ln)) q:ln=""  s wrk(ln)=line(ln)
 s sno=0
rips0 k sno(0)
 s instring=0,string=""
 s ln=""
rips1 s ln=$o(wrk(ln)) i ln="" g rips3
 s txt=wrk(ln),char=" ",txt=$tr(txt,"'","""")
 s cn=0
rips2 s cn=cn+1,charp=char,char=$e(txt,cn),charn=$e(txt,cn+1) i char="" g rips1
 i 'instring,(charp_char)=" ;"!((charp_char_charn)=" --") s txt=$e(txt,1,cn-2) k wrk(ln) s:$l(txt) wrk(ln)=txt g rips2 ; remove comment
 i char=$c(34),'instring s sno=sno+1,qno=0,instring=1,sno(0,sno,0,0)=ln,sno(0,sno,0,1)=cn
 i char=$c(34),instring s qno=qno+1
 i char'=$c(34),instring,'(qno#2) s ^mgtmp($j,"string",sno)=string,instring=0,string="" g rips3
 i instring s string=string_char,sno(0,sno,1,0)=ln,sno(0,sno,1,1)=cn
 g rips2
rips3 i instring,'(qno#2) s ^mgtmp($j,"string",sno)=string,instring=0,string=""
 i instring s error="statement contains unterminated literal",error(5)="HY000" g ripsx
 s sno=$o(sno(0,"")) i '$l(sno) g ripsx
 s mrk=%z("ds")_sno_%z("ds")
 s ln1=sno(0,sno,0,0),cn1=sno(0,sno,0,1)
 s ln2=sno(0,sno,1,0),cn2=sno(0,sno,1,1)
 i ln1=ln2 s wrk(ln1)=$e(wrk(ln1),1,cn1-1)_mrk_$e(wrk(ln1),cn2+1,9999) g rips0
 s wrk(ln1)=$e(wrk(ln1),1,cn1-1)_mrk
 s ln=ln1 f  s ln=$o(wrk(ln)) q:ln=""!(ln'<ln2)  s wrk(ln)=""
 s wrk(ln2)=$e(wrk(ln2),cn2+1,9999)
 g rips0
ripsx ; exit
 q
 ;
rstring(line) ; put strings back into line
 f  q:line'[%z("ds")  s line=$p(line,%z("ds"),1)_^mgtmp($j,"string",$p(line,%z("ds"),2))_$p(line,%z("ds"),3,9999)
 q line
 ;
cdel(sql2,wrk,error) ; find and mark main commands
 n ln,lnd,dec,pn,wrd,wrd0,wrd1,pst,pre,txt,txt1,txtn,qnum
 s (qnum,lnd)=0,(dec,txtn)=""
 s ln=""
cdel1 s ln=$o(wrk(ln)) i ln="" g cdelx
 s txt=wrk(ln) d rems i '$l(txt) k wrk(ln) g cdel1
 s txt=$$cdel7(txt)
 s pn=0
cdel2 s pn=pn+1 i pn>$l(txt," ") g cdel1r
 s wrd=$p(txt," ",pn)
 i '$l(wrd) g cdel2 ; this shouldn't happen
 s pre="" f  q:"()"'[$e(wrd,1)  s pre=pre_$e(wrd,1),wrd=$e(wrd,2,9999) i '$l(wrd) q
 s pst="" f  q:"()"'[$e(wrd,$l(wrd))  s pst=$e(wrd,$l(wrd))_pst,wrd=$e(wrd,1,$l(wrd)-1) i '$l(wrd) q
 i wrd="" g cdel2r
 s wrd1=$$lcase^%mgsqls(wrd)
 i $l(wrd1)>128 g cdel2r
 i '$d(sql2(wrd1)) g cdel2r
 s (wrd0,wrd)=wrd1
 i wrd0="transaction" d cdel5 g cdel2
 i wrd0="select" s qnum=qnum+1,wrd=$s(qnum=1:"(",1:"")_%z("dq")_qnum_%z("dq")_%z("dc")_wrd_%z("dc")
 i wrd0'="select",$d(sql2(wrd)),"034"[sql2(wrd) d cdel3(.wrd,.qnum)
 s ^mgtmp($j,"cmnd",qnum,wrd0)=ln
cdel2r s txtn=txtn_" "_pre_wrd_pst
 g cdel2
cdel1r s txtn=$$trim^%mgsqls(txtn," ") i '$l(txtn) k wrk(ln) g cdel1
 s wrk(ln)=txtn,txtn=""
 g cdel1
cdelx ;
 s qnummax=qnum
 i qnummax s ln=$o(wrk(""),-1) i $l(ln) s wrk(ln)=wrk(ln)_")"
 q qnummax
 ;
cdel3(wrd,qnum) ; process main-line command
 s wrd=%z("dc")_wrd_%z("dc")
 i wrd["update" s wrd=%z("dc")_"from"_%z("dc")_" "_wrd
 i wrd["delete"!(wrd["update") s qnum=qnum+1,wrd=$s(qnum=1:"(",1:"")_%z("dq")_qnum_%z("dq")_%z("dc")_"select"_%z("dc")_" "_wrd
 q
 ;
cdel5 ; transaction processing command
 n cmnd,nam
 s cmnd=$p(txt," ",pn+1),nam=$p(txt," ",pn+2),txt=$p(txt," ",1,pn-1)_" "_$p(txt," ",pn+3,9999),pn=pn-1 d rems
 s cmnd=$$lcase^%mgsqls(cmnd)
 i cmnd'="start",cmnd'="commit",cmnd'="rollback" s error="invalid command '"_cmnd_"' for transaction processing",error(5)="HY000" q
 s sql("txp",0,cmnd)=nam i nam?1":"1a.e s inv($p(nam,":",2,9999))=""
 q
 ;
cdel7(line) ; remove ambiguous syntax
 n dlm,len,pn,pn1,pre,post,post1,obr,cbr,i,c,wrd,wrduc
 s dlm="substring"
 s len=$l(line,dlm)
 i len<2 q line
 s pn=len
cdel71 s pre=$p(line,dlm,1,pn-1),post=$p(line,dlm,pn,9999)
 i post'?." "1"("1e.e g cdel71
 s (obr,cbr)=0 f i=1:1 s c=$e(post,i) s:c="(" obr=obr+1 s:c=")" cbr=cbr+1 i obr,obr=cbr q
 i 'obr g cdel71
 i obr'=cbr g cdel71
 s post1=$e(post,i+1,99999)
 s post=$e(post,1,i)
 f pn1=1:1:$l(post," ") s wrd=$p(post," ",pn1) d
 . s wrduc=$$lcase^%mgsqls(wrd)
 . i wrduc="from"!(wrduc="for") s $p(post," ",pn1)=","
 . q
 s line=pre_dlm_post_post1
 s pn=pn-1 i pn>1 g cdel71
 q line
 ;
rems ; trim and remove surplus spaces from txt
 n pn,wrd,txt1
 i '$l(txt) q
 s txt=$$trim^%mgsqls(txt," ") i '$l(txt) q
 f pn=1:1:$l(txt," ") s txt1=$p(txt," ",pn+1,9999) i txt1?1" ".e s txt1=$$ltrim^%mgsqls(txt1," "),txt=$p(txt," ",1,pn)_" "_txt1
 q
 ;
remsc ; remove spaces from comma in context of natural separator
 n pn,wrd,txt1
 f pn=1:1 q:txt'[" "!(pn=$l(txt," "))  s wrd=$p(txt," ",pn) q:wrd=""  s txt1=$p(txt," ",pn+1,9999) i $e(wrd,$l(wrd))=","!($e(txt1,1)=",") s txt=$p(txt," ",1,pn)_$p(txt," ",pn+1,9999),pn=pn-1
 q
 ;
cog ; cognos translations
 s ok=0
 i $g(sql(1,1))'?1"select ".e q
 i $g(sql(2,1))'?1"select min(".e q
 i $g(sql(2,2))'?1"from ".e q
 s sel=$p($g(sql(1,1)),"select ",2)
 s cname=$p($p($g(sql(2,1)),"select min(",2),")",1)
 s sel1="",com="" f i=1:1:$l(sel,",") s x=$p(sel,",",i),sel1=sel1_com_cname_" "_$p(x," ",2),com=","
 k line
 s ok=1
 s line(1)="select distinct "_sel1
 s line(2)=sql(2,2)
 s line(3)="where "_cname_" > -7"
 m ^mgtmp($j,"translate")=line
 ;
 ;s line(1)="select distinct a.lab membercaption3, a.lab usevalue, a.lab membercaption6, a.lab displayvalue"
 ;s line(2)="from lab-test a"
 ;
 ;sql(0,1)=%z("dq"_"1"_%z("dq")
 ;sql(1,1)="select t0.c0 membercaption3,t0.c1 usevalue,t0.c0 membercaption6,t0.c1 displayvalue"
 ;sql(1,2)="from "_%z("dq")_"2"_%z("dq") t0"
 ;sql(1,3)="order by 4 asc"
 ;sql(2,1)="select min(lab-test.lab) c0,lab-test.lab c1"
 ;sql(2,2)="from lab-test lab-test"
 ;sql(2,3)="group by lab-test.lab,lab-test.lab"
 q
 ;
test ; test
 k
 d gvars^%mgsqlv("",.%z)
 g test2
 set line(1)="select  t0.c0 membercaption3 , t0.c1 usevalue , t0.c0 membercaption6 , t0.c1 displayvalue"
 set line(2)="from  ("
 set line(3)="select  min(lab-test.lab) c0 , lab-test.lab c1"
 set line(4)="from  lab-test lab-test"
 set line(5)="group  by lab-test.lab , lab-test.lab) t0"
 set line(6)="order  by 4 asc"
 s qnummax=$$main(.sql,.line)
 k %z
 q
test1 ;
 set line(1)="select a.pat-num,   a.pat-nam"
 set line(2)="into :xxx, :yyy"
 set line(3)="from patient a"
 set line(4)="where a.pat-num > :strt and a.pat-num [ ""xxx"""
 s qnummax=$$main(.sql,.line)
 k %z
 q
test2 ;
 s line(1)="select distinct a.num, a.name from patient a"
 s qnummax=$$main(.sql,.line)
 k %z
 q
 ;
 
