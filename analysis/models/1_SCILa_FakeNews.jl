# SCILa - FakeNews Project
# 2021-05-25

# SETUP - always needed
using RCall, DataFrames, MixedModels, Serialization, LinearAlgebra, StatsModels

dat = rcopy(R"readRDS('./data/SCILa_FakeNews_1.rds')");
describe(dat)
levels(dat.UNL)
dat[:, [:unl1, :unl2, :unl3, :unl4]]

contr = merge(
	   Dict(nm => Grouping() for nm in (:Subj, :Item)),
	   Dict(nm => EffectsCoding() for nm in (:Frame, :Truth, :Source, :See, :Che)),
           Dict(:Gen => EffectsCoding(base="F")),
           Dict(:Edu => EffectsCoding(base="6")),
           Dict(:UNL => HypothesisCoding( [ -3 -3 +2 +2 +2   # unl1: Conflict vs. no conflict [x frame x truth]
                                            +2  0  0 -1 -1   # unl2: Conflict (UA vs KZ users) [x frame] 
	         			    -2 +3 +3 -2 -2   # unl3: RU vs. (KZ+UA) [x  frame x loyalty]
	           			     0  0  0 +1 -1], # unl4: RU vs. UA language [x frame] | UA users
		                   levels=["kz ru ru", "ru kz ru", "ru ua ru", "ua ru ru", "ua ru ua"],
			           labels=["unl1", "unl2", "unl3", "unl4"])));
# Excursion: contr[:UNL]

## hypothesis matrix
using StatsModels, LinearAlgebra
cmat=
 [-3 -3 +2 +2 +2  
  +2  0  0 -1 -1  
  -2 +3 +3 -2 -2  
   0  0  0 +1 -1]

## pseudoinverse matrix = contrast matrix
cmat_pi = pinv(cmat)

cmat_pi_v2 =
StatsModels.ContrastsMatrix(HypothesisCoding(cmat), 
  ["kz_ru_ru", "ru_kz_ru", "ru_ua_ru", "ua_ru_ru", "ua_ru_ua"]).matrix

cmat_pi == cmat_pi_v2

## extract hypothesis matrix for constructed `ContrastMatrix`
cmat_v2 =
StatsModels.hypothesis_matrix(StatsModels.ContrastsMatrix(HypothesisCoding(cmat), 
  ["kz_ru_ru", "ru_kz_ru", "ru_ua_ru", "ua_ru_ru", "ua_ru_ua"]))

# MODEL SELECTION - may be skipped
# only-varying-intercepts LMM:  m_ovi - SELECTED (selection with lme4)
f_ovi = @formula(answer ~ 1 + UNL*Frame*Truth + UNL*Frame*Source + UNL*Truth*Source + Frame*Truth*Source +
                              p_loy_c*UNL*Frame +  age_c+Gen+edu1+edu2+See+Che+ 
                              (UNL+Frame+Truth) & (age_c+Gen+edu1+edu2+See) +
                              (1  | Subj) +  (1  | Item));
m_ovi = fit(MixedModel, f_ovi, dat, contrasts=contr);

# full zero-correlation parameter LMM: m_zcp1
f_zcp1 = @formula(answer ~ 1 + UNL*Frame*Truth + UNL*Frame*Source + UNL*Truth*Source + Frame*Truth*Source +
                               p_loy_c*UNL*Frame + age_c+Gen+edu1+edu2+See+Che+ 
                              (UNL+Frame+Truth) & (age_c+Gen+edu1+edu2+See) + 
                              zerocorr(1 + Frame + Truth + Source + See + Che | Subj) +  
                              zerocorr(1 + unl4 + p_loy_c + Source + Gen + edu1 + edu2 + See + Che | Item));
m_zcp1 = fit(MixedModel, f_zcp1, dat, contrasts=contr);
issingular(m_zcp1)
VarCorr(m_zcp1)

# reduced zero-correlation parameter LMM: m_zcp - SELECTED
f_zcp =  @formula(answer ~ 1 + UNL*Frame*Truth + UNL*Frame*Source + UNL*Truth*Source + Frame*Truth*Source +
                               p_loy_c*UNL*Frame + age_c+Gen+edu1+edu2+See+Che+ 
                              (UNL+Frame+Truth) & (age_c+Gen+edu1+edu2+See) + 
                              zerocorr(1 + Frame + Truth + See + Che | Subj) +  
                              zerocorr(1 + unl4 + p_loy_c + Gen + edu1 + edu2 + See + Che | Item));
m_zcp = fit(MixedModel, f_zcp, dat, contrasts=contr);
issingular(m_zcp)
VarCorr(m_zcp)

MixedModels.likelihoodratiotest(m_zcp, m_zcp1)

# complex LMM  m_cpx_subj_all does not converge correctly
f_cpx_subj_all =  @formula(answer ~ 1 + UNL*Frame*Truth + UNL*Frame*Source + UNL*Truth*Source + Frame*Truth*Source +
                                    p_loy_c*UNL*Frame + age_c+Gen+edu1+edu2+See+Che+ 
                                   (UNL+Frame+Truth) & (age_c+Gen+edu1+edu2+See) + 
                               (1 + Frame + Truth + See + Che | Subj) +  
                       zerocorr(1 + unl4 + p_loy_c + Gen + edu1 + edu2 + See + Che | Item));
m_cpx_subj_all = fit(MixedModel, f_cpx_subj_all, dat, contrasts=contr);
issingular(m_cpx_subj_all) # true
VarCorr(m_cpx_subj_all)

# complex LMM with only a subset of Subj CPs -- SELECTED 
f_cpx_subj =  @formula(answer ~ 1 + UNL*Frame*Truth + UNL*Frame*Source + UNL*Truth*Source + Frame*Truth*Source +
                                    p_loy_c*UNL*Frame + age_c+Gen+edu1+edu2+See+Che+ 
                                   (UNL+Frame+Truth) & (age_c+Gen+edu1+edu2+See) + 
                               (1 | Subj) + (0 + Frame + Truth + See + Che | Subj) +  
                       zerocorr(1 + unl4 + p_loy_c + Gen + edu1 + edu2 + See + Che | Item));
m_cpx_subj = fit(MixedModel, f_cpx_subj, dat, contrasts=contr);
issingular(m_cpx_subj) # false
VarCorr(m_cpx_subj)

# complex LMM with Item CPs added
f_cpx_subj_item =  @formula(answer ~ 1 + UNL*Frame*Truth + UNL*Frame*Source + UNL*Truth*Source + Frame*Truth*Source +
                                    p_loy_c*UNL*Frame + age_c+Gen+edu1+edu2+See+Che+ 
                                   (UNL+Frame+Truth) & (age_c+Gen+edu1+edu2+See) + 
                               (1 | Subj) + (0 + Frame + Truth + See + Che | Subj) +  
                               (1 + unl4 + p_loy_c + Gen + edu1 + edu2 + See + Che | Item));
m_cpx_subj_item = fit(MixedModel, f_cpx_subj_item, dat, contrasts=contr);
issingular(m_cpx_subj_item)  # true
VarCorr(m_cpx_subj_item)

# Compare LMMs: note m_cpx_subj_all did not converge correctly
MixedModels.likelihoodratiotest(m_ovi, m_zcp, m_cpx_subj, m_cpx_subj_all) 
MixedModels.likelihoodratiotest(m_ovi, m_zcp, m_cpx_subj, m_cpx_subj_item)
#=
─────────────────────────────────────────────────────
     model-dof    -2 logLik        χ²  χ²-dof  P(>χ²)
─────────────────────────────────────────────────────
[1]         85  236452.3222                          
[2]         95  236136.5412  315.7810      10  <1e-61
[3]        102  236108.1477   28.3935       7  0.0002
[4]        130  236063.1876   44.9601      28  0.0223
─────────────────────────────────────────────────────
=#
                        
lmms=[ "m_ovi", "m_zcp", "m_cpx_subj", "m_cpx_subj_item"];
mods = [m_ovi, m_zcp, m_cpx_subj, m_cpx_subj_item];
gof_summary = DataFrame(model=lmms, 
                        dof=dof.(mods), deviance=deviance.(mods),
                        AIC = aic.(mods), BIC = bic.(mods))

#=
 Row │ model            dof    deviance   AIC        BIC       
     │ String           Int64  Float64    Float64    Float64   
─────┼─────────────────────────────────────────────────────────
   1 │ m_ovi               85  2.36452e5  2.36622e5  2.37383e5
   2 │ m_zcp               95  2.36137e5  2.36327e5  2.37177e5
   3 │ m_cpx_subj         102  2.36108e5  2.36312e5  2.37225e5
   4 │ m_cpx_subj_item    130  2.36063e5  2.36323e5  2.37487e5
=#

# Final model selection
m_cpx = m_cpx_subj;

#show(stdout, m1)
show(MIME("text/markdown"), m_cpx)  # show(MIME("text/xelatex"), m1)
VarCorr(m_cpx)

# write to file
open("1_SCILa_FakeNewsParams_MM.md", "w") do io
    show(io, MIME("text/markdown"), m_ovi)
    show(io, MIME("text/markdown"), m_zcp)
    show(io, MIME("text/markdown"), m_cpx)
end

# Store lmms
serialize("./fits/m_ovi.jls", m_ovi)
serialize("./fits/m_zcp.jls", m_zcp)
serialize("./fits/m_cpx.jls", m_cpx)

#= FOLLOW-UP ANALYSES
2021-05-28: 4-covariate interaction "unl3 &  frm  & trth & p_loy_c" not sign.
2021-05-29:
=#

m_ovi = deserialize("./fits/m_ovi.jls");
m_zcp = deserialize("./fits/m_zcp.jls"); 
m_cpx = deserialize("./fits/m_cpx.jls"); # m_cpx = m_cpx_subj_2 !

MixedModels.likelihoodratiotest(m_ovi, m_zcp, m_cpx, m_cpx_subj_item)
                        
lmms=[ "m_ovi", "m_zcp", "m_cpx", "m_cpx_subj_item"];
mods = [m_ovi, m_zcp, m_cpx, m_cpx_subj_item];
gof_summary = DataFrame(model=lmms, dof=dof.(mods), deviance=deviance.(mods),
                        AIC = aic.(mods), BIC = bic.(mods))

#= Following up 2 three-variable interactions
  + unl1 x frame x poly_c  
  + unl1 x frame x truth
 =#

## Establish equivalence with f_cpx_subj_2 (renamed above to f_cpx)
f_cpx_2 =  @formula(answer ~ 1 + (unl1+unl2+unl3+unl4)*frm*trth + 
                                       (unl1+unl2+unl3+unl4)*frm*src + 
                                       (unl1+unl2+unl3+unl4)*trth*src + frm*trth*src +
                               p_loy_c*(unl1+unl2+unl3+unl4)*frm + age_c+gen+edu1+edu2+see+che+ 
                                       (unl1+unl2+unl3+unl4+frm+trth) & (age_c+gen+edu1+edu2+see) + 
                               (1 | Subj) + (0 + frm + trth + see + che | Subj) +  
                       zerocorr(1 + unl4 + p_loy_c + gen + edu1 + edu2 + see + che | Item));
m_cpx_2 = fit(MixedModel, f_cpx_2, dat, contrasts=contr);
m_cpx_2
issingular(m_cpx_2) # false
VarCorr(m_cpx_2)
VarCorr(m_cpx)
deviance.([m_cpx, m_cpx_2])

## Add four-variable interaction 
f_cpx_3 =  @formula(answer ~ 1 +      (unl1+unl2+unl3+unl4)*frm*trth + 
                                      (unl1+unl2+unl3+unl4)*frm*src + 
                                      (unl1+unl2+unl3+unl4)*trth*src + frm*trth*src +
                              p_loy_c*(unl1+unl2+unl3+unl4)*frm + age_c+gen+edu1+edu2+see+che+ 
                                      (unl1+unl2+unl3+unl4+frm+trth) & (age_c+gen+edu1+edu2+see) + 
                                       unl3 & frm & trth & p_loy_c  + 
                            (1 | Subj) + (0 + frm + trth + see + che | Subj)  +  
                    zerocorr(1 + unl4 + p_loy_c + gen + edu1 + edu2 + see + che | Item));


m_cpx_3 = fit(MixedModel, f_cpx_3, dat, contrasts=contr);
m_cpx_3
issingular(m_cpx_3)
VarCorr(m_cpx_3)

MixedModels.likelihoodratiotest( m_cpx_2, m_cpx_3)

#=
───────────────────────────────────────────────────
     model-dof    -2 logLik      χ²  χ²-dof  P(>χ²)
───────────────────────────────────────────────────
[1]         98  236112.9616                        
[2]         99  236112.9613  0.0003       1  0.9869
───────────────────────────────────────────────────
=#