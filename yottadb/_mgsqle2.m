%mgsqle2 ;(CM) SQL : Compile code for an expression ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqle2") q
 ;
comp(en,outv,word,sqlfn,sqlex,code,error) ; compile expression
 n wrdl
 d lines(en,.word,.wrdl)
 d code(en,.wrdl,.sqlfn,.sqlex,outv,.code)
compe ; exit
 q
 ;
addline(code,line) ; add line of code
 s code($i(code))=line
 q
 ;
lines(en,word,wrdl) ; translate word array into line arrays for coding
 n wrd,lno,wno,wno1,obr,cbr
 s lno=0
lines1 s (wno,obr)=0,cbr=""
 f  s wno=$o(word(en,wno)) q:wno=""  s wrd=word(en,wno) q:wrd=")"  i wrd="(" s obr=wno
 k word(en,obr)
 s lno=lno+1
 s cbr=wno i $l(cbr) s word(en,cbr)=%z("de")_lno_%z("de")
 s wno1=0,wno=obr
 f  s wno=$o(word(en,wno)) q:wno=""!(wno=cbr)  s wno1=wno1+1,wrdl(lno,wno1)=word(en,wno) k word(en,wno)
 i obr=0 q
 g lines1
 ;
code(en,wrdl,sqlfn,sqlex,outv,code) ; generatate code for each line
 n ln,exp,expx,offs,tmp,line
 s ln=0,expx="",offs=$l(outv)+9
code1 s ln=ln+1 i '$d(wrdl(ln)) g code3
 s exp=$$line(ln,.wrdl,.sqlfn,.sqlex,.code,.error) i $l(error) q
 f  q:exp'[%z("de")  d code2(en,.exp,.tmp,offs)
 s tmp(ln)=exp
 g code1
code3 ; insert line(s) into routine
 s ln=ln-1
 s tmp(ln)=" "_"s"_" "_%z("dsv")_outv_%z("dsv")_"="_tmp(ln)
 s ln="" f  s ln=$o(tmp(ln)) q:ln=""  s line=tmp(ln) d addline(.code,line)
 q
 ;
code2(en,exp,tmp,offs) ; try to insert sub-lines into current line
 n ln
 s ln=$p(exp,%z("de"),2)
 i ($l(exp)+$l(tmp(ln))+offs)<240 s exp=$p(exp,%z("de"),1)_"("_tmp(ln)_")"_$p(exp,%z("de"),3,999) k tmp(ln) q
 s exp=$p(exp,%z("de"),1)_%z("pv")_"("_ln_")"_$p(exp,%z("de"),3,999)
 s tmp(ln)=" "_"s"_" "_%z("pv")_"("_ln_")="_tmp(ln)
 q
 ;
line(ln,wrdl,sqlfn,sqlex,code,error) ; process individual line
 n wno,wrd,exp
 s wno=0,exp=""
line1 s wno=wno+1 i '$d(wrdl(ln,wno)) q exp
 s wrd=wrdl(ln,wno)
 f  q:wrd'[%z("df")  s wrd=$$fun(wrd,.sqlfn) q:$l(error)
 i error'="" q exp
 i wrd?1a.u1"."1a.e!(wrd?1a.u1"("1a.e1")") d sqlex^%mgsqle1(0,.sqlex,wrd) s wrd=%z("dsv")_wrd_%z("dsv")
 s exp=exp_wrd
 g line1
 ;
fun(wrd,sqlfn) ; generate code for in-line functions
 n code,fn,pre,post
 s code=""
 s pre=$p(wrd,%z("df"),1),post=$p(wrd,%z("df"),3,999)
 s fn=$p(wrd,%z("df"),2)
 s fun=sqlfn(fn),fun=$p(fun,"(",1)
 i fun?1"$"1a.e s code=$$m(.sqlfn,fn)
 i fun?1"$$"1a.e s code=$$ext(.sqlfn,fn)
 s code=pre_code_post
 q code
 ;
ext(sqlfn,fn) ; generate code for m extrinsic function
 n line,sub,i,com
 s line=fun_"("
 s sub=fun_"("
 s com="" f i=1:1 q:'$d(sqlfn(fn,"p",i))  s sub=sub_com_sqlfn(fn,"p",i,1),com=","
 s sub=sub_")"
 s line=sub
 ;b
 q line
 ;
m(sqlfn,fn) ; m function
 n line,sub,i,com
 s line=fun_"("
 s sub=fun_"("
 s com="" f i=1:1 q:'$d(sqlfn(fn,"p",i))  s sub=sub_com_sqlfn(fn,"p",i,1),com=","
 s sub=sub_")"
 s line=sub
 q line
 q
 ;
in(en,wrd,word,wn,obr,cbr,error) ; form expression for sql style 'in'
 n arg,i,op,andor,eq,obr1,cbr1,x,dlm,pre,post,arg,args,var,spc
 i obr'=1,'cbr s error="incorrect bracketing around arguments of the 'in' operator",error(5)="HY000" g inx
 s op=word(en,wn)
 i op="in" s andor="or",eq="="
 i op="not in" s andor="and",eq="'="
 s arg=wrd s args=$$arg^%mgsqle(arg,.args)
 s (obr1,cbr1)=0,var="",spc="" f wn=wn-1:-1:1 s x=word(en,wn) s:x="(" obr1=obr1+1 s:x=")" cbr1=cbr1+1 s var=x_spc_var,spc=" " i obr1=cbr1 s wn=wn-1 q
 s x="",dlm="" f i=1:1:args s x=x_dlm_var_" "_eq_" "_args(i),dlm=" "_andor_" "
 s x="( "_x_" )",pre=$p(lin," ",1,pn),post=$p(lin," ",pn+1,999)
 s lin=pre_" "_x i $l(post) s lin=lin_" "_post
inx ; exit
 q ""
 ;
between(en,wrd,word,wn,obr,cbr,error) ; form expression for sql style 'between'
 n arg,i,op,andor,eq1,eq2,obr1,cbr1,x,dlm,pre,post,arg,args,var,spc
 i obr'=1,'cbr s error="incorrect bracketing around arguments of the 'between' operator",error(5)="HY000" g betweenx
 s op=word(en,wn)
 i op="between" s andor="and",eq1=">=",eq2="<="
 i op="not between" s andor="or",eq1="<",eq2=">"
 s arg=wrd s args=$$arg^%mgsqle(arg,.args) i args<2 s error="the 'between' operator takes two arguments",error(5)="HY000" g betweenx
 s (obr1,cbr1)=0,var="",spc="" f wn=wn-1:-1:1 s x=word(en,wn) s:x="(" obr1=obr1+1 s:x=")" cbr1=cbr1+1 s var=x_spc_var,spc=" " i obr1=cbr1 s wn=wn-1 q
 s x="( "_var_" "_eq1_" "_args(1)_" "_andor_" "_var_" "_eq2_" "_args(2)_" )",pre=$p(lin," ",1,pn),post=$p(lin," ",pn+1,999)
 s lin=pre_" "_x i $l(post) s lin=lin_" "_post
betweenx ; exit
 q ""
 ;
like(wrd,error) ; form expression for sql style pattern-match
 n wrd1,chr,i
 i wrd'?1""""1e.e1"""",wrd'[%z("ds") s error="invalid 'like' argument "_wrd,error(5)="HY000" q ""
 s wrd1=$e(wrd,2,$l(wrd)-1),wrd=""
 f i=1:1:$l(wrd1) s chr=$e(wrd1,i) s wrd=wrd_$s(chr="_":"1e",chr="%":".e",1:1_$c(34)_chr_$c(34))
 q ""
 ;
mpm(wrd,error) ; form expression for m style pattern-match
 n cn,chr,pchr,x,i
 s cn=0,chr=""
mpm1 s pchr=chr,cn=cn+1 i cn>$l(wrd) g mpmx
 s chr=$e(wrd,cn)
 i chr="."!(chr?1n) f i=cn+1:1 s x=$e(wrd,i) q:x'?1n&(x'=".")  s cn=cn+1,chr=chr_x
 i chr?1u f i=cn+1:1 s x=$e(wrd,i) q:x'?1u  s cn=cn+1,chr=chr_x
 i chr?1a.u f i=1:1:$l(chr) s x=$e(chr,i) i "acelnpu"'[x s error="invalid pattern "_x_" in pattern match "_wrd,error(5)="HY000" q
 i $e(error) g mpmx
 i chr="""" f i=cn+1:1:$l(wrd) s x=$e(wrd,i) q:x'=""""&($l(chr,"""")#2)  s cn=cn+1,chr=chr_x
 i chr["""",'($l(chr,"""")#2) s error="invalid element "_chr_" in pattern match "_wrd,error(5)="HY000" g mpmx
 i pchr="",chr?.n.1".".n g mpm1
 i pchr'="",pchr?.n.1".".n,chr?1a.u!(chr["""") g mpm1
 i pchr'="",pchr?1a.u!(pchr[""""),chr?.n.1".".n g mpm1
 s error="invalid pattern match "_wrd,error(5)="HY000"
mpmx i chr'?1a.u,chr'["""" s error="invalid pattern match "_wrd,error(5)="HY000"
 q ""
 ;
 
