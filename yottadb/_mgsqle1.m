%mgsqle1 ;(CM) SQL : Bracket expression in word array ; 28 Jan 2022  10:00 AM
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
a d vers^%mgsql("%mgsqle1") q
 ;
sqlvar(ctx,word,var) ; sql variables in expression
 n no
 i $d(word("sqv",ctx,"x",var)) q
 s no=$i(word("sqv",ctx,"e"))
 s word("sqv",ctx,"e",no)=var,word("sqv",ctx,"x",var)=no
 q
 ;
exbr(tmp,ops,error) ; extract individual bracketed sub-statements and set in temporary array
 n sn,i,ok,wn1,wn2
 s sn=0
exbr1 i '$d(tmp("x",0,"(")) g exbrx
 s ok=0,wn1="" f  s wn1=$o(tmp("e",0,wn1)) q:wn1=""!ok  i tmp("e",0,wn1)="(" s wn2=wn1 f  s wn2=$o(tmp("e",0,wn2)) q:wn2=""  q:tmp("e",0,wn2)="("  i tmp("e",0,wn2)=")" s ok=1 q
 s wn1=wn1-1
 i 'ok s error="error in bracketing",error(5)="HY000" q
 s sn=sn+1,wn=0 s tmp("e",0,wn1)="{{"_sn_"{{" k tmp("x",0,"(",wn1)
 f  s wn1=$o(tmp("e",0,wn1)),wrd=tmp("e",0,wn1)  k tmp("e",0,wn1) d tmpxk(.tmp,0,wrd,wn1) q:wn1=wn2  s wn=wn+1,tmp("e",sn,wn)=wrd d tmpxs(.tmp,sn,wrd,wn,.ops)
 g exbr1
exbrx ; tidy up holes in primary expression (if necessary)
 i '$d(tmp("e",1)) q
 k tmp("x",0) s wn="" f i=1:1 s wn=$o(tmp("e",0,wn)) q:wn=""  s wrd=tmp("e",0,wn) k tmp("e",0,wn) s tmp("e",0,i)=wrd d tmpxs(.tmp,0,wrd,i,.ops)
 q
 ;
oper(tmp,ops,error) ; for each sub-statement parse operator string in order of precedence
 n sn,op,opn
 f sn=0:1 q:'$d(tmp("e",sn))  f opn=1:1:$l(ops,":") s op=$p(ops,":",opn) i op'="",op'="'" d oper1(.tmp,sn,op,.ops,.error)
 q
 ;
oper1(tmp,sn,op,ops,error) ; find all occurances of current operator in sub-statement
 n wn
 i '$d(tmp("x",sn,op)) q
 s wn="" f  s wn=$o(tmp("x",sn,op,wn)) q:wn=""  d obr(.tmp,sn,.wn),cbr(.tmp,sn,.wn)
 q
 ;
cbr(tmp,sn,wn) ; insert 'closed' bracket
 n obr,cbr,x,wrd
 s (obr,cbr)=0
 i '$d(tmp("e",sn,wn+1,"o")) f x=wn+1:1 q:'$d(tmp("e",sn,x))  s wrd=tmp("e",sn,x) s:$d(tmp("e",sn,x,"o")) obr=obr+tmp("e",sn,x,"o") s:$d(tmp("e",sn,x,"c")) cbr=cbr+tmp("e",sn,x,"c") i obr=cbr,ops'[(":"_wrd_":"),$d(tmp("e",sn,x+1)),tmp("e",sn,x+1)'=op q
 i $d(tmp("e",sn,wn+1,"o")) f x=wn+1:1 q:'$d(tmp("e",sn,x))  s wrd=tmp("e",sn,x) s:$d(tmp("e",sn,x,"o")) obr=obr+tmp("e",sn,x,"o") s:$d(tmp("e",sn,x,"c")) cbr=cbr+tmp("e",sn,x,"c") i obr>0,obr=cbr,$d(tmp("e",sn,x,"c")),$d(tmp("e",sn,x+1)),tmp("e",sn,x+1)'=op q
 i '$d(tmp("e",sn,x)) s x=x-1
 s tmp("e",sn,x,"c")=$s($d(tmp("e",sn,x,"c")):tmp("e",sn,x,"c")+1,1:1),wn=x
 q
 ;
obr(tmp,sn,wn) ; insert 'open' bracket
 n obr,cbr,x,wrd
 s (cbr,obr)=0
 i '$d(tmp("e",sn,wn-1,"c")) s x=wn-1
 i $d(tmp("e",sn,wn-1,"c")) f x=wn-1:-1:1 s:$d(tmp("e",sn,x,"c")) cbr=cbr+tmp("e",sn,x,"c") s:$d(tmp("e",sn,x,"o")) obr=obr+tmp("e",sn,x,"o") i cbr>0,cbr=obr q
 i '$d(tmp("e",sn,x)) q
 i $d(tmp("e",sn,x-1)),tmp("e",sn,x-1)="'" s x=x-1
 s tmp("e",sn,x,"o")=$s($d(tmp("e",sn,x,"o")):tmp("e",sn,x,"o")+1,1:1)
 q
 ;
asm(en,tmp,word) ; re-assemble complete statement from processed sub-statements
 n sn1,wn,wn1
 s sn1=0,wn1=0,wn=0
 d asm1(en,.tmp,.word,.wn,sn1,wn1)
 q
 ;
asm1(en,tmp,word,wn,sn1,wn1) ; assemble statement
 n wrd,i
asm11 s wn1=wn1+1 i '$d(tmp("e",sn1,wn1)) q
 s wrd=tmp("e",sn1,wn1)
 i $d(tmp("e",sn1,wn1,"o")) f i=1:1:tmp("e",sn1,wn1,"o") s wn=wn+1,word(en,wn)="("
 i $e(wrd,1,2)="{{" d asm2(en,.tmp,.word,.wn,wrd)
 i $e(wrd,1,2)'="{{" s wn=wn+1,word(en,wn)=wrd
 i $d(tmp("e",sn1,wn1,"c")) f i=1:1:tmp("e",sn1,wn1,"c") s wn=wn+1,word(en,wn)=")"
 g asm11
 ;
asm2(en,tmp,word,wn,wrd) ; swap out to nested sub expression
 n sn1,wn1
 s sn1=$p(wrd,"{{",2)
 s wn1=0
 d asm1(en,.tmp,.word,.wn,sn1,wn1)
 q
 ;
brac(en,word,ops,error) ; bracket expression in word array
 n i,tmp,wrd
 f i=1:1 q:'$d(word(en,i))  s wrd=word(en,i),tmp("e",0,i)=wrd d tmpxs(.tmp,0,wrd,i,.ops) k word(en,i)
 d exbr(.tmp,.ops,.error) i $l(error) g brace
 d oper(.tmp,.ops,.error)
 d asm(en,.tmp,.word)
brace ; exit
 q
 ;
word(en,ex,word,ops,error) ; generate word array from expression lines en(1->n)
 n lin,ln
 s lin="" f ln=1:1 q:'$d(ex(ln))  s lin=lin_ex(ln)
 d word1(lin,.word,.fun,.ops,.error)
 d type(en,.word)
 q
 ;
word1(lin,word,fun,ops,error) ; decompose line lin
 n pn,wn,i,wrd,wrd1,wrdlc,nwrd,obr,cbr,like,mpm,in,between,extvar,ok,in,like,mpm,between,wk,c,ca,cz,sa,sz
 f  q:$e(lin)'=" "  s lin=$e(lin,2,999)
 s wk=lin,lin="" f i=1:1:$l(wk) d
 . s c=$e(wk,i),sa="",sz=""
 . s ca=$s(i>1:$e(wk,i-1),1:"")
 . s cz=$e(wk,i+1)
 . i c="*",ca="(",cz=")" s lin=lin_c q
 . i c?1p,$d(ops(c)) d
 . . i ca'="",'$d(ops(ca)),ca'=" " s sa=" "
 . . i cz'="",'$d(ops(cz)),cz'=" " s sz=" "
 . . q
 . s lin=lin_sa_c_sz
 . q
 s pn=0,wn=0,in="",like="",mpm="",between=""
word2 s pn=pn+1 i pn>$l(lin," ") q
 s wrd=$p(lin," ",pn)
 f i=pn+1:1 q:i>$l(lin," ")!($l(wrd,"""")#2)  s wrd=wrd_" "_$p(lin," ",i),pn=pn+1
 s obr=0 f i=1:1:$l(wrd) q:$e(wrd)'="("  s obr=obr+1,wrd=$e(wrd,2,999) i $d(in) q
 i wrd="" s cbr=0 g word3
 s wrdlc=$$lcase^%mgsqls(wrd)
 i wrd="missing_value" s wrd="$$mv^%mgsqls()"
 i wrd="current_date" s wrd="$$cdate^%mgsqls()"
 i wrd="current_time" s wrd="$$ctime^%mgsqls()"
 i wrd="current_timestamp" s wrd="$$ts^%mgsqls()"
 i wrdlc?1"lower(".e1")" s wrd="$$lcase^%mgsqls("_$e(wrd,7,9999)
 i wrdlc?1"upper(".e1")" s wrd="$$ucase^%mgsqls("_$e(wrd,7,9999)
 i wrdlc?1"trim(".e1")" s wrd="$$trim^%mgsqls("_$e(wrd,7,9999)
 i wrdlc?1"rtrim(".e1")" s wrd="$$rtrim^%mgsqls("_$e(wrd,7,9999)
 i wrdlc?1"ltrim(".e1")" s wrd="$$ltrim^%mgsqls("_$e(wrd,7,9999)
 i wrdlc?1"{d".e1"}" s wrd="$$edate^%mgsqls("_$e(wrd,3,$l(wrd)-1)_","""")"
 i wrd?1"$"1a.e1"("1e.e s wrd=$$func(lin,.pn,wrd,.error) i $l(error) q
 i wrd?1"$$"1a.e1"("1e.e s wrd=$$func(lin,.pn,wrd,.error) i $l(error) q
 i wrd?1a.a1"("1e.e1")".e s wrd1=$p(wrd,")",1)_")" d sqlvar(0,.word,wrd1) s wrd=%z("dsv")_wrd1_%z("dsv")_$p(wrd,")",2,999)
 s cbr=0 f i=$l(wrd)-1:1 q:$e(wrd,$l(wrd))'=")"  s wrd=$e(wrd,1,$l(wrd)-1),cbr=cbr+1 i $d(in) q
 i wrd=""!(wrd[%z("df"))!(wrd[%z("dev"))!(wrd[%z("dsv"))!(wrd[%z("dq")) g word3
 i wrd?1"{"1a.e,wrd=lin d sqlvar(1,.word,wrd) s wrd=%z("dev")_wrd_%z("dev") g word3
 ; translate logical operators into physical equivalents
 i wrdlc="is" s nwrd=$$ucase^%mgsqls($p(lin," ",pn+1)) i nwrd="not" s wrd=wrd_" "_nwrd,wrdlc=wrdlc_" "_nwrd,pn=pn+1
 i wrdlc="not" s nwrd=$$ucase^%mgsqls($p(lin," ",pn+1)) i nwrd="like"!(nwrd="in")!(nwrd="exists")!(nwrd="after")!(nwrd="before")!(nwrd="null") s wrd=wrd_" "_nwrd,wrdlc=wrdlc_" "_nwrd,pn=pn+1
 i like'="" s like=$$like^%mgsqle2(.wrd,.error) q:$l(error)  g word3
 i wrd="like"!(wrd="not like") s like=wn
 i mpm'="" s mpm=$$mpm^%mgsqle2(.wrd,.error) q:$l(error)  g word3
 i wrd="?"!(wrd="'?") s mpm=wn
 i in'="" s in=$$in^%mgsqle2(en,.wrd,.word,.wn,obr,cbr,.error) q:$l(error)  g word2
 i wrd="in"!(wrd="not in"),$p(lin," ",pn+1)'[%z("dq") s in=wn
 i between'="" s between=$$between^%mgsqle2(en,.wrd,.word,.wn,obr,cbr,.error) q:$l(error)  g word2
 i wrd="between"!(wrd="not between") s between=wn
 i wrdlc="is" s wrd="=" g word3
 i wrdlc="is not" s wrd="'=" g word3
 i wrdlc="null" s wrd="""""" g word3
 i wrd="<>"!(wrd="!=") s wrd="'=" g word3
 s wrd=$s(wrd=">=":"'<",wrd="<=":"'>",wrd="and":"&",wrd="or":"!",wrd="not":"'",wrd="like":"?",wrd="not like":"'?",1:wrd)
 i $d(ops(wrd)) g word3
 i wrd?1"""".e1"""",($l(wrd,"""")#2) g word3
 i wrd[%z("ds") g word3
 i wrd?.1"-".n.1"."1n.n g word3
 i $e(wrd)="[" s wrd=$e(wrd,2,999)
 i $e(wrd,$l(wrd))="]" s wrd=$e(wrd,1,$l(wrd)-1)
 i wrd?1a.e1"."1a.e!(wrd?.1"."1a.e) s extvar=0,ok=$$word4(wrd) i ok d sqlvar(0,.word,wrd) s wrd=%z("dsv")_wrd_%z("dsv") g word3
 i wrd?1a.e1"."1"{".e1"}"1"."1a.e d sqlvar(0,.word,wrd) s wrd=%z("dsv")_wrd_%z("dsv") g word3
 i wrd?1":"1a.e s wrd=$p(wrd,":",2,999),extvar=1,ok=$$word4(wrd) i ok d sqlvar(1,.word,wrd) s wrd=%z("dev")_wrd_%z("dev") g word3
 s error="invalid item "_wrd,error(5)="HY000" q
word3 ; valid word found
 f i=1:1:obr s wn=wn+1,word(en,wn)="("
 i wrd="exists"!(wrd="not exists") s wn=wn+1,word(en,wn)=1
 i $l(wrd) s wn=wn+1,word(en,wn)=wrd
 f i=1:1:cbr s wn=wn+1,word(en,wn)=")"
 g word2
 ;
word4(wrd) ; validate sql variable wrd
 n ok,wrd1
 s ok=0,wrd1=wrd
 s wrd1=$tr(wrd1,"-_","")
 f  q:wrd1'["."  s wrd1=$p(wrd1,".",1)_$p(wrd1,".",2,999)
 i 'extvar,wrd1["$" s wrd1=$p(wrd1,"$",1)_$p(wrd1,"$",2,999)
 i wrd1[";" s wrd1=$p(wrd1,";",1)_$p(wrd1,";",2,999)
 i wrd1?1a.an s ok=1 q ok
 q ok
 ;
func(lin,pn,wrd,error) ; extract function
 n lin1,spcn,funlin
 s spcn=$l(wrd," ")-1
 s funlin=wrd_" "_$p(lin," ",pn+1,999)
 s lin1=$e(funlin,$l(wrd)+1,999)
 s lin1=$p(lin1," ",1) i lin1'?.")" s error="error in syntax after function "_wrd,error(5)="HY000" q wrd
 s wrd=%z("df")_wrd_%z("df")_lin1,pn=pn+$l(wrd," ")-1-spcn
 q wrd
 ;
vrfy(en,word,ops,error) ; verify statement in word array
 n wn,wtyp,lwtyp,obr,cbr,wrd,wrd1
 s wn=0,(wtyp,lwtyp)="",(obr,cbr)=0
vrfy1 s wn=wn+1 i '$d(word(en,wn)) g vrfyx
 s wrd=word(en,wn)
 i wrd="(" s obr=obr+1 g vrfy1
 i wrd=")" s cbr=cbr+1 g:cbr'>obr vrfy1 s error="error in bracketing",error(5)="HY000" q
 i wrd="'" s wrd1="" s:$d(word(en,wn+1)) wrd1=word(en,wn+1) i wrd1'[%z("dev"),wrd1'[%z("dsv"),wrd1'[%z("df"),wrd1'="(" s error="the 'not' operator must preceed a variable or sub-expression",error(5)="HY000" q
 i wrd="'" g vrfy1
 s wtyp=$s($d(ops(wrd)):"o",1:"c")
 i wtyp="o",lwtyp'="c" s error=$$error(en,.word,wn,"an operator must be preceeded by a constant"),error(5)="HY000" q
 i wtyp="c",$l(lwtyp),lwtyp'="o" s error=$$error(en,.word,wn,"a constant must be preceeded by an operator"),error(5)="HY000" q
 i '$l(lwtyp),wtyp'="c" s error=$$error(en,.word,wn,"the first word in an expression should be a constant"),error(5)="HY000" q
 s lwtyp=wtyp
 g vrfy1
vrfyx ; line verification complete
 i lwtyp'="c" s error=$$error(en,.word,wn,"the last word in an expression should be a constant"),error(5)="HY000" q
 i cbr'=obr s error="the number of open and closed brackets should be equal",error(5)="HY000" q
 q
 ;
error(en,word,wn,error) ; form helpful error message
 n x,y,i
 s x="" f i=wn-5:1:wn+5 i $d(word(en,i)) s y=word(en,i) s:y[%z("dsv") y=$p(y,%z("dsv"),2) s:y[%z("dev") y=$p(y,%z("dev"),2) s x=x_" "_y
 s error=error_":"_x
 q error
 ;
type(en,word) ; work out pointer to data type
 n var,wrd
 s var="" f  s var=$o(word("sqv",1,"x",var)) q:var=""  i '$d(word("sqv",1,"type",var)) d type1(en,.word,var)
 q
 ;
type1(en,word,var) ; find variable in expression
 n wn,i,wrd,alias,tname,cname,qnum,ok
 f wn=1:1 q:'$d(word(en,wn))  i word(en,wn)[%z("dev"),$p(word(en,wn),%z("dev"),2)=var q
 i '$d(word(en,wn)) q
 s ok=0 f i=wn:1:1 q:'$d(word(en,i))  s wrd=word(en,i) q:wrd="&"!(wrd="!")  i wrd[%z("dsv") s wrd=$p(wrd,%z("dsv"),2) i wrd?1a.e1"."1a.e s ok=1 q
 i ok g type2
 s ok=0 f i=wn:-1:1 s wrd=word(en,i) q:wrd="&"!(wrd="!")  i wrd[%z("dsv") s wrd=$p(wrd,%z("dsv"),2) i wrd?1a.e1"."1a.e s ok=1 q
 i ok g type2
 q
type2 ; file type
 s alias=$p(wrd,".",1),cname=$p(wrd,".",2)
 s ok=0 f qnum=1:1 q:'$d(^mgtmp($j,"from","x",qnum))  i $d(^mgtmp($j,"from","x",qnum,alias)) s tname=$p(^mgtmp($j,"from",qnum,^mgtmp($j,"from","x",qnum,alias)),"~",1),ok=1 q
 i ok s word("sqv",1,"type",var)=tname_"."_cname
 q
 ;
tmpxs(tmp,sn,wrd,wn,ops) ; set node in snx array
 i $l(wrd)>32 q
 i '$d(ops(wrd)),wrd'="(",wrd'=")" q
 s tmp("x",sn,wrd,wn)=""
 q
 ;
tmpxk(tmp,sn,wrd,wn) ; remove node from snx array
 i $l(wrd)>32 q
 k tmp("x",sn,wrd,wn)
 q
 ;
