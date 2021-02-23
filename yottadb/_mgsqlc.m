%mgsqlc ;(CM) sql compiler - main driver ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlc") q
 ;
main ; start
 s line=""
 s %zq("tagout")=%z("dl")_%z("pt")_"x"_%z("dl")
 i '$d(sql(0,1)) g exit
 s grp=2
 i $p(sql(0,1)," ",1)="insert",'$d(sql(1,1)) d main^%mgsqlci g main1
 i $p(sql(0,1)," ",1)="delete",'$d(sql(1,1)) d hilev^%mgsqlcd g main1
 s grp=5
 f count=1:1 s qnum=$g(^mgtmp($j,"subq",count)) q:qnum=""  d subq^%mgsqlc1 i $l(error) q
 i $l(error) g exit
 s grp=3,qnum=1
 d strtq
 d endq
 s grp=5
main1 ; second phase
 d query
 s grp=1
 d begin
 d sort
 d idx
 m ^mgtmp($j,"from")=from
 m ^mgtmp($j,"update")=update
exit ; exit
 k att,cond,count,line,done,f,tnum,tname,from,i,ii,j,l,lcom,lvar,n,pvar,qnum,rec,sdel,sel,select,v,vsub,x,y,z,sqin,seq,reset,endsq
 q
 ;
addend ; add line of code for end of query
 s endcode(el)=line,line="",el=el+1
 q
 ;
begin ; code to be executed at start of query
 k %d,%t s %to="",%do=""
 s line=rou_" ; SQL "_qid_"; "_$$ddate^%mgsqls($h,2)_"; "_$$dtime^%mgsqls($h)_"; "_$h d addline(grp,.line)
 s line=" ;" d addline(grp,.line)
 s line="cols(%zo) ; columns" d addline(grp,.line)
 f i=1:1 q:'$d(^mgtmp($j,"outsel",1,i))  s var=$g(^(i)) d
 . i var[%z("dsv") s var=$p(var,%z("dsv"),2)
 . s alias=$p(var,".",1),cname=$p(var,".",2),tname=alias
 . i alias'="" s tno=$g(^mgtmp($j,"from","x",1,alias)) i tno'="" s tname=$p($g(^mgtmp($j,"from",1,tno)),"~",1)
 . s line=" s %zo(0,"_i_")="""_var_""""_",%zo(0,"_i_",0)="""_$$dtype^%mgsqld(dbid,tname,cname)_"""" d addline(grp,.line)
 . q
 s line=" q 0" d addline(grp,.line)
 s line=" ;" d addline(grp,.line)
 s line="exec(%zi,%zo) ; main entry point" d addline(grp,.line)
 s line=line_%z("pv")
 f i=1:1:vsub s line=line_","_%z("pv")_i
 s invs=$g(^mgtmp($j,"in")) i invs f i=1:1:invs s line=line_","_"iv"_i
 s line=" n "_line d addline(grp,.line)
 s line=" k "_%z("ctg")_"("_%z("cts")_")" d addline(grp,.line)
 s lvar="" f  s lvar=$o(^mgtmp($j,"in",lvar)) q:lvar=""  s pvar=$$subvar3(lvar),r=$g(^mgtmp($j,"in",lvar)) d
 . s pvar=$p(r,"~",1)
 . s line=" i '$d(%zi("""_lvar_""")) s %zo(""error"")=""<ERROR>input '"_lvar_"' not supplied"" q -1" d addline(grp,.line)
 . s line=" s "_pvar_"=$g(%zi("""_lvar_"""))" d addline(grp,.line)
 . q
 s line=" s "_%z("vok")_"=$$cols(.%zo)" d addline(grp,.line)
 s line=" s "_%z("vok")_"=$$so^%mgsqlz(.%zi,.%zo)" d addline(grp,.line)
 d trx
 i $d(sql("union",1)) d union
 q
 ;
union ; reserve variables for union in uvar
 n qnum
 s qnum="" f  s qnum=$o(sql("union",qnum)) q:qnum=""  f i=1:1:outsel s uvar=$p(^mgtmp($j,"sel",qnum,i),%z("dsv"),2) d union1
 k uvarx
 q
 ;
union1 ; assign union variable by position
 i uvar="" q
 d union2
 i '$d(uvarx(i)) s lvar="\\cmu"_i d subvar1^%mgsqlc s uvarx(i)=pvar
 s pvar=uvarx(i)
 i $l(pvaru) s uvar(0,qnum,pvar)=pvaru
 i $d(uvar(uvar)) s uvar(0,qnum,pvar)=uvar(uvar) q
 s uvar(uvar)=pvar
 s uvar=$p($p(uvar,")",1),"(",2) i uvar="" q
 d union2
 i '$d(uvarx(i,1)) s lvar="\\\cmu"_i d subvar1^%mgsqlc s uvarx(i,1)=pvar
 s pvar=uvarx(i,1)
 i $l(pvaru) s uvar(0,qnum,pvar)=pvaru
 i $d(uvar(uvar)) s uvar(0,qnum,pvar)=uvar(uvar) q
 s uvar(uvar)=pvar
 q
 ;
union2 ; check for pre-assigned variable from declare
 n lvar,pvar
 s lvar=uvar
 s pvaru=$$subvaru^%mgsqlc(lvar)
 q
 ;
strtq ; code to be executed at start of query
 n lab
 s ok=0 f i=1:1 q:'$d(^mgtmp($j,"from",i))!ok  f ii=1:1 q:'$d(^mgtmp($j,"from",i,ii))  i $p(^mgtmp($j,"from",i,ii),"~",1)["(" s ok=1 q
 i ok s line=" i '$d(%iv(""uci"")) s %iv(""uci"")=""""" d addline(grp,.line)
 i $d(^mgtmp($j,"create","index")) d klind^%mgsqlc5(grp,qnum)
 s line=" s "_%z("vrc")_"=0" d addline(grp,.line)
 s line=" s "_%z("vn")_"=0,"_%z("vnx")_"=0" d addline(grp,.line)
 i $d(^mgtmp($j,"order")) s line=" s "_%z("pv")_"n=0" d addline(grp,.line)
 s line="",com=""
 f i=1:1 q:'$d(^mgtmp($j,"subq",i))  s x=^mgtmp($j,"subq",i) i x'=1,x'="",'$d(^mgtmp($j,"corelx",x)),'$d(sql("union",x)) s line=line_com_%z("dl")_%z("pt")_x_"s"_%z("dl"),com=","
 i line'="" s line=" d "_line d addline(grp,.line)
 q
 ;
trx ; evaluate constants
 n wrd,arg,sqv,type
 s sqv="" f  s sqv=$o(^mgtmp($j,"trx",sqv)) q:sqv=""  d
 . s type=$g(^mgtmp($j,"trx",sqv))
 . s arg=$g(^mgtmp($j,"trx",sqv,1))
 . i arg?1":"1a.e s arg=%z("dev")_$e(arg,2,999)_%z("dev")
 . s line=" s "_%z("dsv")_sqv_%z("dsv")_"="_"$$edate^%mgsqls("_arg_",1)" d addline(grp,.line)
 q
 ;
endq ; code to be executed at end of query
 s tags1=0 s line=" g "_%z("dl")_%z("pt")_"1s",tags1=1 d addline(grp,.line)
 i 'tags1,$d(^mgtmp($j,"s",1)) s x=^mgtmp($j,"s",1),y=$p(x,"~",2),x=$p(x,"~",1) k @(code_",x,y)")
 k endcode s el=1
endq1 ; kill sql variables and exit query
 i $d(^mgtmp($j,"ktmp")) s line=" k "_%z("ctg")_"("_%z("cts")_")"
 s line=" s "_%z("vok")_"=$$sc^%mgsqlz(.%zi,.%zo)" d addend
 s line=" q "_%z("vok") d addend
 s endcode(1)=%z("dl")_%z("pt")_"x"_%z("dl")_endcode(1)
 f el=1:1 q:'$d(endcode(el))  s line=endcode(el) d addline(grp,.line)
 q
 ;
query ; insert query (text) and variable substitution into routine
 i $d(sql(1,1)) g query1
 s line=%z("dl")_%z("pt")_"x"_%z("dl")
 s line=line_" s "_%z("vok")_"=$$sc^%mgsqlz(.%zi,.%zo)" d addline(grp,.line)
 s line=line_" q "_%z("vok") d addline(grp,.line)
query1 s line=" ;" d addline(grp,.line) s line="query ;" d addline(grp,.line)
 f i=1:1 q:'$d(^mgsqlx(1,dbid,qid,"sql",i))  s line=" ; "_^(i) d addline(grp,.line)
 s line="var ;" d addline(grp,.line)
 s x="" f  s x=$o(^mgtmp($j,"vsub",x)) q:x=""  s v(^mgtmp($j,"vsub",x))=x
 f i=1:1 q:'$d(v(i))  s line=" ;    "_%z("pv")_i_" = "_v(i) d addline(grp,.line)
 q
 ;
idx ; index data
 n r
 f qnum=1:1 q:'$d(^mgtmp($j,"from",qnum))  f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))  d
 . n tname,alias,sqcname,sqcname1,cname,sel
 . s tname=$p(^mgtmp($j,"from",qnum,tnum),"~",1),alias=$p(^mgtmp($j,"from",qnum,tnum),"~",2)
 . s r=$s($d(^mgtmp($j,"sqlupd",tname)):^(tname),1:"~"),$p(r,"~",1)="r" i '($p(r,"~",2)) s $p(r,"~",2)=0
 . s sqcname="" f  s sqcname=$o(^mgtmp($j,"get",sqcname)) q:sqcname=""  d
 . . i $p(sqcname,".",1)'=alias q
 . . s cname=$p(sqcname,".",2) i cname="" q
 . . s sel=0 i qnum=1 f i=1:1 q:'$d(^mgtmp($j,"outsel",qnum,i))  s sqcname1=$p($g(^(i)),%z("dsv"),2) i sqcname1=sqcname s sel=1 q
 . . s ^mgtmp($j,"sqlupd",tname,cname)=sel
 . . q
 . s ^mgtmp($j,"sqlupd",tname)=r
 . q
 i $d(^mgtmp($j,"upd","insert")) d
 . n tname,alias,sqcname,sqcname1,cname,sel,i
 . s tname=$g(^mgtmp($j,"upd","insert")) i tname="" q
 . s r=$g(^mgtmp($j,"sqlupd",tname))
 . i r="" s r="~1"
 . s $p(r,"~",1)="i"
 . s cname="" f  s cname=$o(^mgtmp($j,"upd","attx",cname)) q:cname=""  s ^mgtmp($j,"sqlupd",tname,cname)=0
 . f i=1:1 q:'$d(^mgtmp($j,"upd","att",i))  s cname=$g(^mgtmp($j,"upd","att",i)) q:cname=""  s ^mgtmp($j,"sqlupd",tname,cname)=0
 . s ^mgtmp($j,"sqlupd",tname)=r
 . q
 i $d(^mgtmp($j,"upd","delete")) d
 . n tname,alias,sqcname,cname
 . s tname=$p($g(^mgtmp($j,"upd","delete"))," ",1) i tname="" q
 . s alias=$p($g(^mgtmp($j,"upd","delete"))," ",2) i alias="" s alias=tname q
 . s sqcname="" f  s sqcname=$o(^mgtmp($j,"get",sqcname)) q:sqcname=""  d
 . . i $p(sqcname,".",1)'=alias q
 . . s cname=$p(sqcname,".",2) i cname="" q
 . . s sel=1
 . . s ^mgtmp($j,"sqlupd",tname,cname)=sel
 . . q
 . s r=$g(^mgtmp($j,"sqlupd",tname))
 . s $p(r,"~",1)="d"
 . s ^mgtmp($j,"sqlupd",tname)=r
 . q
 i $d(^mgtmp($j,"upd","update")) d
 . n tname
 . s tname=$p($g(^mgtmp($j,"upd","update"))," ",1) i tname="" q
 . s r=$g(^mgtmp($j,"sqlupd",tname))
 . s $p(r,"~",1)="u"
 . s ^mgtmp($j,"sqlupd",tname)=r
 . q
 q
 ;
addline(grp,line) ; add line of code to routine
 n ln,lnr
 s lnr=$i(@(%zq("ccoder")_",grp)")),@(%zq("ccoder")_",grp,lnr)")=line
 i line[%z("dsv")!(line[%z("dev")) d subvar(.line)
 i line[%z("dl") d subtag(.line)
 i line?1" s ".e,$p(line,"=",2)=$p($p(line," s ",2),"=",1) s line="" q
 i line?1" set ".e,$p(line,"=",2)=$p($p(line," set ",2),"=",1) s line="" q
 s line=$$rstring^%mgsqlp(line)
 i line="" q
 s ln=$i(@(%zq("ccode")_",grp)"))
 s @(%zq("ccode")_",grp,ln)")=line,line=""
 q
 ;
subvar(line) ; substitute physical variables for logical variables
 n lvar,pvar,x,pn
 f  s lvar=$p(line,%z("dsv"),2) q:'$l(lvar)  s pvar=$$subvar1(lvar),line=$p(line,%z("dsv"),1)_pvar_$p(line,%z("dsv"),3,999) i lvar?1"___v".n d subvar4(lvar,pvar)
 i line'[%z("dev") q
 s pn=2 f  s lvar=$p(line,%z("dev"),pn) q:'$l(lvar)  s pvar=$$subvar3(lvar) s:pvar="" pn=pn+2 i $l(pvar) s line=$p(line,%z("dev"),1,pn-1)_pvar_$p(line,%z("dev"),pn+1,999)
 q
 ;
subvar1(lvar) ; physical variable
 i $$subvar2(lvar,.pvar) q pvar
 i $d(^mgtmp($j,"uvar",lvar)) s pvar=^mgtmp($j,"uvar",lvar) q pvar
 i '$d(^mgtmp($j,"vsub",lvar)) s vsub=$i(^mgtmp($j,"vsub")),^mgtmp($j,"vsub",lvar)=vsub
 q $$subvaru(lvar)
 ;
subvaru(lvar) ; entry point for pre-assigned variables in union
 n pvar
 i '$d(^mgtmp($j,"vsub",lvar)) s pvar="" q pvar
 s pvar=%z("pv")_^mgtmp($j,"vsub",lvar)
 q pvar
 ;
subvar2(lvar,pvar) ; determine if select variable interface can be eliminated
 s pvar="" i $d(^mgtmp($j,"trans",lvar)) s pvar=^(lvar) q 1
 q 0
 ;
subvar3(lvar) ; physical variable for manual input of constant
 n pvar,r,invs
 s pvar=""
 s r=$g(^mgtmp($j,"in",lvar))
 s pvar=$p(r,"~",1) i pvar'="" q pvar
 s invs=$i(^mgtmp($j,"in"))
 s pvar="iv"_invs
 s $p(r,"~",1)=pvar,^mgtmp($j,"in",lvar)=r
 q pvar
 ;
subvar4(lvar,pvar) ; add expression or function code
 n i,line,x
 s x=%z("dsv")_lvar_%z("dsv")
 f i=1:1 q:'$d(^mgtmp($j,"e",lvar,i))  s line=^(i) d
 . f  q:line'[x  s line=$p(line,x,1)_pvar_$p(line,x,2,999)
 . d addline(grp,.line)
 . q
 k ^mgtmp($j,"e",lvar)
 q
 ;
subtag(line) ; substitute physical line label for logical label
 n ltag,ptag
 f  q:line'[%z("dl")  s ltag=$p(line,%z("dl"),2),ptag=$$subtag1(ltag),line=$p(line,%z("dl"),1)_ptag_$p(line,%z("dl"),3,999)
 q
 ;
subtag1(ltag) ; physical line label
 n n,t,x,tsub,ptag
 s t="0123456789abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
 s n=$l(t)
 i '$d(^mgtmp($j,"tsub",ltag)) s tsub=$i(^mgtmp($j,"tsub")),^mgtmp($j,"tsub",ltag)=tsub
 s x=^mgtmp($j,"tsub",ltag),ptag=%z("pt")_$e(t,(x-1)\n)_$e(t,((x-1)#n)+1)
 q ptag
 ;
sort ; sort stand-alone sql code into contiguous routine
 s grp="",l=1 f  s grp=$o(@(%zq("ccode")_",grp)")) q:grp=""  s ln="" f  s ln=$o(@(%zq("ccode")_",grp,ln)")) q:ln=""  s line=^(ln) k ^(ln) s @(%zq("ccode")_",l)")=line,l=l+1
 s @(%zq("ccode")_")")=l-1
 q
 ;
 
 
