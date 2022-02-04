%mgsqlp1 ;(CM) sql language processor ; 28 Jan 2022  10:02 AM
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2022 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqlp1") q
 ;
main(qnummax,sql2,wrk,sql,error) ; entry
 n blk
 d blks(qnummax,.sql2,.wrk,.blk,.error) i $l(error) g exit
 d subs(qnummax,.sql2,.blk,.error) i $l(error) g exit
 d extr(qnummax,.sql2,.blk,.tmp,.error) i $l(error) g exit
 d grpx(qnummax,.sql2,.blk,.tmp,.error) i $l(error) g exit
 d reds(qnummax,.sql2,.blk,.tmp,.error) i $l(error) g exit
 d logb(qnummax,.sql2,.blk,.tmp,.error) i $l(error) g exit
 d sqlb(qnummax,.sql2,.blk,.tmp,.sql,.error) i $l(error) g exit
 d updx(qnummax,.sql2,.blk,.tmp,.sql,.error) i $l(error) g exit
 d puts(qnummax,.sql,.error) i $l(error) g exit
 d unix(qnummax,.sql2,.blk,.sql,.error) i $l(error) g exit
exit ; exit
 q
 ;
blks(qnummax,sql2,wrk,blk,error) ; break query into logic blocks
 n i,x,ln,ln1,lna,lnz,txt,txt1,cn,cn1,cna,cnz,rem,blkno,obr,cbt,lobr,tcbr,char,no,delim,delimb,qnum
 s blkno=1000
 s qnum=qnummax i 'qnum g blks3
blks1 s delim=%z("dq")_qnum_%z("dq")
 s ln="" f  s ln=$o(wrk(ln)) q:ln=""  s txt=wrk(ln) i txt[delim q
 s lobr=0,txt1=$p(txt,delim,1),ln1=ln,cn1=$l(txt1)
 f  s:cn1=0 ln1=$o(wrk(ln1),-1),txt1=$s($l(ln1):wrk(ln1),1:""),cn1=$l(txt1) q:ln1=""  i cn1 s char=$e(txt1,cn1),cn1=cn1-1 q:char'=" "&(char'="(")  s:char="(" lobr=lobr+1,lobr(lobr,0)=ln1,lobr(lobr,1)=cn1+1
 s no=""
blks2 s no=$o(lobr("")) i no="" g blks3
 s lna=lobr(no,0),cna=lobr(no,1)
 d blks4 i $l(error) q
 k tcbr s tcbr=0,txt1=wrk(lnz),ln1=lnz,cn1=cnz
 f  s char=$e(txt1,cn1) s:char="" ln1=$o(wrk(ln1)),txt1=$s($l(ln1):wrk(ln1),1:""),cn1=1,char=$e(txt1,cn1) q:ln1=""  s cn1=cn1+1 q:char'=" "&(char'=")")  s:char=")" tcbr=tcbr+1,tcbr(tcbr,0)=ln1,tcbr(tcbr,1)=cn1-1
 s rem=lobr i tcbr<lobr s rem=tcbr
 s x="" f i=1:1:rem s x=$o(lobr("")) q:x=""  s $e(wrk(lobr(x,0)),lobr(x,1))=" " k lobr(x)
 s x="" f i=1:1:rem s x=$o(tcbr("")) q:x=""  s $e(wrk(tcbr(x,0)),tcbr(x,1))=" " k tcbr(x)
 s blkno=blkno-1,blk=0,delimb=%z("dq")_"b"_blkno_%z("dq")
 i lna=lnz s txt=$e(wrk(lna),cna+1,cnz-1) d blksa s txt1=$e(wrk(lna),1,cna-1)_delimb_$e(wrk(lna),cnz+1,9999) k wrk(lna) i $l(txt1) s wrk(lna)=txt1 g blks21
 s txt=$e(wrk(lna),cna+1,9999) d blksa s txt1=$e(wrk(lna),1,cna-1)_delimb k wrk(lna) i $l(txt1) s wrk(lna)=txt1
 s ln1=lna f  s ln1=$o(wrk(ln1)) q:ln1=""!(ln1'<lnz)  s txt=wrk(ln1) d blksa k wrk(ln1)
 s txt=$e(wrk(lnz),1,cnz-1) d blksa s txt1=$e(wrk(lnz),cnz+1,9999) k wrk(lnz) i $l(txt1) s wrk(lnz)=txt1
blks21 g blks2
blks3 s qnum=qnum-1 i qnum>0 g blks1
 s blkno=0,blk=0,ln=""
 f  s ln=$o(wrk(ln)) q:ln=""  s txt=wrk(ln) d blksa
 q
 ;
blks4 ; mark out scope of logic block
 n ln1,cn1,cn0,txt1,char,obr,cbr,x
 s ln1=lna,txt1=wrk(ln1),cn0=cna
 s obr=0,cbr=0,(lnz,cnz)=0
blks41 f cn1=cn0:1:$l(txt1) s char=$e(txt1,cn1) s:char="(" obr=obr+1 s:char=")" cbr=cbr+1 i obr=cbr s cnz=cn1 q
 i 'cnz s x=$o(wrk(ln1)) i $l(x) s ln1=x,txt1=wrk(ln1),cn0=1 g blks41
 i 'cnz s error="error in the bracketing of sql statements",error(5)="HY000" q
 s lnz=ln1
 q
 ;
blksa ; add line to isolated block
 i txt="" q
 s blk=blk+1,blk(blkno,blk)=txt
 q
 ;
subs(qnummax,sql2,blk,error) ; restructure query wrt (sub) query bodies
 n delim,ok,blkno,ln,txt,qnum
 i 'qnummax q
 s qnum=qnummax
subs1 s delim=%z("dq")_qnum_%z("dq")
 s ok=0,blkno="" f  q:ok  s blkno=$o(blk(blkno)) q:blkno=""  s ln="" f  s ln=$o(blk(blkno,ln)) q:ln=""  s txt=blk(blkno,ln) i txt[delim s ok=1 q
 d subs4
 s qnum=qnum-1 i qnum>0 g subs1
 q
 ;
subs4 ; mark out block for (sub) query
 n ln1,lnz,cn1,cn0,cnz,txt1,char,ok,x,wrd
 s ln1=ln,txt1=blk(blkno,ln1),cn0=$l($p(txt1,delim,1))+1
 s ok=0,cnz=0,lnz=0
subs41 f cn1=cn0:1:$l(txt1) s char=$e(txt1,cn1) s:"{( "'[char lnz=ln1,cnz=cn1 i char="{",$e(txt1,cn1,cn1+$l(%z("dc"))-1)=%z("dc") s wrd=$p($e(txt1,cn1,9999),%z("dc"),2) i $l(wrd),$l(wrd)<128,$d(sql2(wrd)),sql2(wrd)=4 s ok=1 q
 i 'ok s x=$o(blk(blkno,ln1)) i $l(x) s ln1=x,txt1=blk(blkno,ln1),cn0=1 g subs41
 i 'ok s lnz=ln1,cnz=cn1
 s blk(blkno,lnz)=$e(blk(blkno,lnz),1,cnz)_delim_$e(blk(blkno,lnz),cnz+1,9999)
 q
 ;
extr(qnummax,sql2,blk,tmp,error) ; extract all (sub) queries
 n delim,ln,ln1,nodel,insub,txt,txt1,blkno,ok,qnum
 i qnummax=0 g extr4
 s qnum=qnummax
extr1 s delim=%z("dq")_qnum_%z("dq")
 s ok=0,blkno="" f  q:ok  s blkno=$o(blk(blkno)) q:blkno=""  s ln="" f  s ln=$o(blk(blkno,ln)) q:ln=""  s txt=blk(blkno,ln) i txt[delim s ok=1 q
 s insub=0,tmp=0
 s ln=ln-1
extr2 s ln=$o(blk(blkno,ln)) i ln="" g extr4
 s txt1=blk(blkno,ln),nodel=$l(txt1,delim)
 i nodel=3 s txt=$p(txt1,delim,2) d extra q:$l(error)  s txt1=$p(txt1,delim,1)_delim_$p(txt1,delim,3),blk(blkno,ln)=txt1 g extr3
 i nodel=2,'insub s insub=1 s txt=$p(txt1,delim,2) d extra q:$l(error)  s txt1=$p(txt1,delim,1)_delim,blk(blkno,ln)=txt1 g extr2
 i nodel=2,insub s txt=$p(txt1,delim,1) d extra q:$l(error)  s txt1=$p(txt1,delim,2),blk(blkno,ln)=txt1 g extr3
 i insub s txt=blk(blkno,ln) d extra q:$l(error)  k blk(blkno,ln)
 g extr2
extr3 s qnum=qnum-1,tmp=0 i qnum>0 g extr1
extr4 ; add update as 'subquery zero'
 s blkno=0,qnum=0,tmp=0,ln="" f  s ln=$o(blk(blkno,ln)) q:ln=""  s txt=blk(blkno,ln) d extra i $l(error) q
 q
 ;
extra ; add text to temporary (by (sub) query) array
 n i,n
 s txt=$$trim^%mgsqls(txt," ")
 i '$l(txt) q
 f i=2:2 s n=$p(txt,%z("dq"),i) q:n'?1n.n  i n<qnum s error="error in brackets with respect to sub-statements "_n_" and "_qnum,error(5)="HY000" q
 i $l(error) q
 s tmp=tmp+1,tmp(qnum,tmp)=txt,txt=""
 q
 ;
grpx(qnummax,sql2,blk,tmp,error) ; look out for group/order in wrong place and try to correct
 n ln,grp,ord,move,txt,qnum
 s qnum=0
grpx1 s qnum=qnum+1 i '$d(tmp(qnum)) q
 s ln=0,(grp,ord,move)=0
grpx2 s ln=ln+1 i '$d(tmp(qnum,ln)) g grpx3
 s txt=tmp(qnum,ln)
 i $e(txt,1,5+$l(%z("dc")))=(%z("dc")_"group") s grp=ln
 i $e(txt,1,5+$l(%z("dc")))=(%z("dc")_"order") s ord=ln
 i txt[%z("dq"),(ord!grp) s move=1
 g grpx2
grpx3 i 'move g grpx1
 i grp s tmp(qnum,ln)=tmp(qnum,grp),ln=ln+1 k tmp(qnum,grp)
 i ord s tmp(qnum,ln)=tmp(qnum,ord),ln=ln+1 k tmp(qnum,ord)
 g grpx1
 ;
reds(qnummax,sql2,blk,tmp,error) ; reduce query + logic block
 n blkno,blkno1,ln,qnum,qnum1,txt,txt1,pn,trans
 s blkno="" f  s blkno=$o(blk(blkno)) q:blkno=""  s ln="",blk=0 f  s ln=$o(blk(blkno,ln)) q:ln=""  s txt=$$rems^%mgsqlp(blk(blkno,ln)) k blk(blkno,ln) i $l(txt) s blk=blk+1,blk(blkno,blk)=txt
 s qnum="" f  s qnum=$o(tmp(qnum)) q:qnum=""  s ln="",tmp=0 f  s ln=$o(tmp(qnum,ln)) q:ln=""  s txt=$$rems^%mgsqlp(tmp(qnum,ln)) i $l(txt) s tmp=tmp+1,tmp(qnum,tmp)=txt
 s blkno=""
reds1 s blkno=$o(blk(blkno)) i blkno="" g reds4
 s ln=""
reds2 s ln=$o(blk(blkno,ln)) i ln="" g reds1
 s txt=blk(blkno,ln)
 s pn=0
reds3 s pn=pn+2,blkno1=$p(txt,%z("dq"),pn) i blkno1="" g reds2
 i blkno1'?1"b"1n.n g reds3
 s blkno1=$e(blkno1,2,9999)
 i $d(blk(blkno1,2)) g reds3
 s txt1=blk(blkno1,1) i txt1'[%z("dq")!(txt1[" ") g reds3
 s qnum1=$p(txt1,%z("dq"),2)
 s $p(txt,%z("dq"),pn)=qnum1,trans(blkno1)=qnum1,blk(blkno,ln)=txt k blk(blkno1)
 g reds3
reds4 s qnum=$o(tmp(qnum)) i qnum="" g redsx
 s ln=""
reds5 s ln=$o(tmp(qnum,ln)) i ln="" g reds4
 s txt=tmp(qnum,ln)
 s pn=0
reds6 s pn=pn+2,blkno1=$p(txt,%z("dq"),pn) i blkno1="" g reds5
 i blkno1'?1"b"1n.n g reds6
 s blkno1=$e(blkno1,2,9999)
 i $d(trans(blkno1)) s qnum1=trans(blkno1) g reds61
 i $d(blk(blkno1,2)) g reds6
 s txt1=blk(blkno1,1) i txt1'[%z("dq")!(txt1[" ") g reds6
 s qnum1=$p(txt1,%z("dq"),2)
reds61 s $p(txt,%z("dq"),pn)=qnum1,trans(blkno1)=qnum1,tmp(qnum,ln)=txt k blk(blkno1)
 g reds6
redsx ;
 q
 ;
logb(qnummax,sql2,blk,tmp,error) ; make easy to parse logic blocks
 n ln,txt,txt1,blkno,del,log
 s blkno=""
logb1 s blkno=$o(blk(blkno)) i blkno="" q
 s ln="",log=0,txt=""
logb2 s ln=$o(blk(blkno,ln)) i ln="" d logba g logb1
 s txt1=blk(blkno,ln)
logb3 s del=%z("dc") i $l($p(txt1,%z("dq"),1))<$l($p(txt1,%z("dc"),1)) s del=%z("dq")
 i txt1'[%z("dc"),txt1'[%z("dq") s txt=txt_" "_txt1 g logb2
 i del=%z("dq") s txt=txt_" "_$p(txt1,del,1) d logba s txt=del_$p(txt1,del,2)_del d logba s txt1=$p(txt1,del,3,9999) i txt1="" g logb2
 i del=%z("dc") s txt=txt_" "_$p(txt1,del,1) d logba s txt1=$p(txt1,del,2)_$p(txt1,del,3,9999) i txt1="" g logb2
 g logb3
 ;
logba ; add line to final logic block
 n i,n
 s txt=$$trim^%mgsqls(txt," ")
 i '$l(txt) q
 s log=log+1,log(blkno,log)=txt,txt=""
 q
 ;
sqlb(qnummax,sql2,blk,tmp,sql,error) ; make easy to parse sql blocks
 n ln,txt,txt1,qnum
 s qnum=-1
sqlb1 s qnum=qnum+1 i '$d(tmp(qnum)) q
 s ln="",sql=0,txt=""
sqlb2 s ln=$o(tmp(qnum,ln)) i ln="" d sqlba g sqlb1
 s txt1=tmp(qnum,ln)
sqlb3 i txt1'[%z("dc") s txt=txt_" "_txt1 g sqlb2
 s txt=txt_" "_$p(txt1,%z("dc"),1) d sqlba
 s txt1=$p(txt1,%z("dc"),2)_$p(txt1,%z("dc"),3,9999) i txt1="" g sqlb2
 g sqlb3
 ;
sqlba ; add line to final array
 n i,n
 f i=2:2 s n=$p(txt,%z("dq"),i) q:n'?1n.n  d sqlba1
 s txt=$$trim^%mgsqls(txt," ")
 i '$l(txt) q
 s sql=sql+1,sql(qnum,sql)=txt,txt=""
 q
 ;
sqlba1 ; remove redundant brackets from around sub-query link markers
 n pre,pst,len,cn,obr,obr1,cbr,cbr1,br,char
 s pre=$p(txt,%z("dq"),1,i-1),pst=$p(txt,%z("dq"),i+1,9999)
 s len=$l(pre),obr=0 f cn=len:-1 s char=$e(pre,cn) q:char'=" "&(char'="(")  s pre=$e(pre,1,cn-1) i char="(" s obr=obr+1
 s cbr=0 f  s char=$e(pst,1) q:char'=" "&(char'=")")  s pst=$e(pst,2,9999) i char=")" s cbr=cbr+1
 ;ref#19
 ;s br=obr i cbr<obr s br=cbr
 ;i obr=cbr s br=0
 ;s txt=pre_$s(br:" "_$e("((((((((((((",1,br),1:"")_" "_%z("dq")_n_%z("dq")_$s(br:" "_$e("))))))))))))",1,br),1:"")_" "_pst
 s (obr1,cbr1)=0
 i cbr>obr s cbr1=(cbr-obr)
 i obr>cbr s obr1=(obr-cbr)
 s txt=pre_$s(obr1:" "_$e("((((((((((((",1,obr1),1:"")_" "_%z("dq")_n_%z("dq")_$s(cbr1:" "_$e("))))))))))))",1,cbr1),1:"")_" "_pst
 q
 ;
updx(qnummax,sql2,blk,tmp,sql,error) ; now remove update command from body of formatted primary
 n i,x,y,upd,whr,atr,upda
 s (whr,upd,atr)=0,upda=""
 f i=1:1 q:'$d(sql(1,i))  s x=sql(1,i),y=$p(x," ",1) s:y="where" whr=1 s:y="attributes" atr=1 s:y="update" upda=$p(x," ",2,9999) i $l(y),$d(sql2(y)),sql2(y)=3 s upd=upd+1,upd(upd)=x k sql(1,i)
 s x="" f i=1:1 s x=$o(sql(1,x)) q:x=""  s y=sql(1,x) k sql(1,x) s sql(1,i)=y
 f i=1:1 q:'$d(sql(0,i))  s x=sql(0,i),y=$p(x," ",1) i $l(y),$d(sql2(y))!(x[%z("dq")) s upd=upd+1,upd(upd)=x
 k sql(0) f i=1:1 q:'$d(upd(i))  s sql(0,i)=upd(i)
 i atr,'whr k sql(1) f i=1:1 q:'$d(sql(0,i))  i sql(0,i)[%z("dq") k sql(0,i)
 i $d(sql(0,1)),$p(sql(0,1)," ",1)="update",$d(sql(1,2)),$p(sql(1,2)," ",1)="from" s sql(1,2)="from "_upda
 s i=$o(sql(0,""),-1) i i="" q
 s x=sql(0,i) i x'[" " q
 s y=$p(x," ",1) i y[%z("dq") q
 s y=$p(x," ",$l(x," ")) i y'[%z("dq") q
 s sql(0,i)=$p(x," ",1,$l(x," ")-1),sql(0,i+1)=y
 q
 ;
puts(qnummax,sql,error) ; tidy up lines of statement text
 n i,lnd,txt,qnum
 f qnum=0:1 q:'$d(sql(qnum))  f i=1:1 q:'$d(sql(qnum,i))  s txt=$$rems^%mgsqlp(sql(qnum,i)),txt=$$remsc^%mgsqlp(txt),sql(qnum,i)=txt ;$$rstring^%mgsqlp(txt)
 q
 ;
unix(qnummax,sql2,blk,sql,error) ; extract work units for old compiler
 n i,ln,blkno,txt,txt1,qnum,qnum1
 s qnum=-1
unix1 s qnum=qnum+1 i '$d(sql(qnum)) q
 s ln=0
unix2 s ln=ln+1 i '$d(sql(qnum,ln)) g unix1
 s txt=sql(qnum,ln)
 i txt'[(%z("dq")_"b") g unix2
 i qnum>0 s error="union, intersect, except operations not supported for sub-queries",error(5)="HY000" q
 s blkno=$e($p(txt,%z("dq"),2),2,9999)
 f blk=1:1 q:'$d(blk(blkno,blk))!$l(error)  s txt1=blk(blkno,blk) f i=2:2 s qnum1=$p(txt1,%z("dq"),i) q:qnum1=""  s sql("union",qnum1)="" i qnum1["b" s error="precedence not supported for set operations",error(5)="HY000" q
 i $l(error) q
 g unix2
 ;
