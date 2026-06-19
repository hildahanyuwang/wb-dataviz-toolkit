*-------------------------------------------------------------------
* coefficient_plot.do — DIME-signature impact-evaluation charts (Stata)
*-------------------------------------------------------------------
* The two chart types that signal a credible impact evaluation:
*   1. Coefficient plot — point estimate + 95% CI per treatment, zero line.
*   2. Event study      — effect over time vs the program, with a CI band
*                         and a flat pre-trend before t = 0.
*
* A thin DRIVER. House palette + conventions come from dime_scheme.do; the
* numbers live in CSVs. Base Stata only — no community add-ons.
*
* Run:  cd into stata/ , then  do coefficient_plot.do
*
* The bundled data is an ILLUSTRATIVE example, not real evaluation results.
* Sample work — not an official World Bank publication.
*
* Palette (hex -> RGB): Oxford 0 34 68 · Mid 0 108 153 · Bright 0 159 218 ·
*                       Text grey 90 90 90
*-------------------------------------------------------------------

clear all
set more off

* Load the reusable house-style asset (palette + conventions).
do dime_scheme.do

local note1 "Illustrative example, not real evaluation results. Built to DIME Analytics conventions."
local note2 "Sample — not an official World Bank publication."

*--- 1. Coefficient plot -------------------------------------------
import delimited "../data/ie_coefficients.csv", clear varnames(1) case(preserve)

gsort estimate                         // largest estimate plots at the top
gen y = _n
gen byte sig = ci_low > 0              // CI clears zero -> emphasize

* Attach intervention names as value labels on the y axis.
forvalues i = 1/`=_N' {
    local nm = intervention[`i']
    label define ylbl `i' "`nm'", add modify
}
label values y ylbl

* Split the point estimate by significance so the two colours can differ.
gen est_sig  = estimate if sig == 1
gen est_nsig = estimate if sig == 0

twoway ///
    (rcap ci_low ci_high y if sig==1, horizontal lcolor("0 34 68")  lwidth(medthick)) ///
    (rcap ci_low ci_high y if sig==0, horizontal lcolor("90 90 90") lwidth(medthick)) ///
    (scatter y est_sig , msymbol(O) mcolor("0 159 218") msize(medlarge))              ///
    (scatter y est_nsig, msymbol(O) mcolor("90 90 90")  msize(medlarge)) ,            ///
    xline(0, lpattern(dash) lcolor("0 108 153"))                                      ///
    ylabel(1/`=_N', valuelabel angle(0) nogrid labsize(small))                        ///
    yscale(noline) ytitle("")                                                         ///
    xtitle("Effect size (std. dev.)", size(small) color("90 90 90"))                  ///
    title("Coefficient plot: estimated effect with 95% CI",                           ///
        size(medium) color("0 34 68") position(11) justification(left))               ///
    note("`note1'" "`note2'", size(vsmall) color("90 90 90"))                         ///
    legend(off) graphregion(color(white)) plotregion(color(white)) scheme(s1mono)

graph export "coefficient_plot.png", replace width(2700) height(1440)

*--- 2. Event study ------------------------------------------------
import delimited "../data/ie_eventstudy.csv", clear varnames(1) case(preserve)
gen lo = coef - 1.96*se
gen hi = coef + 1.96*se

twoway ///
    (rarea lo hi period, color("0 159 218%16") lwidth(none))               ///
    (line coef period, lcolor("0 159 218") lwidth(medthick))               ///
    (scatter coef period, msymbol(O) mcolor("0 34 68") msize(small)) ,     ///
    yline(0, lcolor("90 90 90"))                                           ///
    xline(0, lpattern(dash) lcolor("0 108 153"))                           ///
    xtitle("Quarters relative to program start", size(small) color("90 90 90")) ///
    ytitle("Effect", size(small) color("90 90 90"))                        ///
    title("Event study: effect over time, with a pre-trend check before t = 0", ///
        size(medium) color("0 34 68") position(11) justification(left))    ///
    note("`note1'" "`note2'", size(vsmall) color("90 90 90"))              ///
    legend(off) graphregion(color(white)) plotregion(color(white)) scheme(s1mono)

graph export "event_study.png", replace width(2700) height(1440)

display "Wrote coefficient_plot.png and event_study.png"
