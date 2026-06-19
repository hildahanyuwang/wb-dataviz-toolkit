*-------------------------------------------------------------------
* dime_scheme.do — reusable World Bank / DIME house style for Stata
*-------------------------------------------------------------------
* Encode the DIME chart style ONCE as a reusable program, so every
* future chart inherits it. Run this file once (do dime_scheme.do) to
* define the `dime_hbar` program, then call it from any driver.
*
* DIME Analytics chart conventions baked in here: direct data labels,
* zero baseline, no redundant gridlines, largest bar in Oxford Blue,
* mandatory source note. Base Stata only — no community add-ons.
*
* This file is the reusable ASSET that keeps every chart on-brand.
* Sample work — not an official World Bank publication.
*
* World Bank / DIME palette (exact hexes -> RGB for Stata):
*   Oxford Blue  #002244 -> 0 34 68      (primary / largest bar)
*   Mid Blue     #006C99 -> 0 108 153    (secondary bars)
*   Bright Blue  #009FDA -> 0 159 218    (accent)
*   Gold         #FDB714 -> 253 183 20   (sparing)
*   Text grey    #5A5A5A -> 90 90 90     (source note)
*-------------------------------------------------------------------

capture program drop dime_hbar
program define dime_hbar
    * Reusable DIME-style horizontal bar chart.
    * Syntax: dime_hbar valuevar labelvar , [ TITle(str) SUBtitle(str) ///
    *           FMT(str) SAVE(str) ]
    * - valuevar : numeric value to plot
    * - labelvar : string category label (e.g. "AFE (Cape Town, 2024)")
    syntax varname [if] [in] , Label(varname string) ///
        [ TITle(string) SUBtitle(string) FMT(string) SAVE(string) ]

    marksample touse, novarlist
    if "`fmt'" == ""   local fmt "%4.1f"
    if "`save'" == ""  local save "dime_hbar.png"

    tempvar val order ismax fin_other fin_max lbl
    quietly gen double `val' = `varlist' if `touse'

    * Sort so the largest bar renders at the top of the horizontal chart.
    gsort `val'
    quietly gen `order' = _n if !missing(`val')

    * Attach the category text as value labels on `order` (base Stata).
    quietly count if !missing(`val')
    local n = r(N)
    forvalues i = 1/`n' {
        local lab = `label'[`i']
        label define _dimelbl `i' "`lab'", add modify
    }
    label values `order' _dimelbl

    * Flag the largest bar so it can be coloured Oxford Blue.
    quietly summarize `val', meanonly
    quietly gen byte `ismax' = `val' == r(max) if !missing(`val')
    quietly gen double `fin_other' = `val' if `ismax' == 0
    quietly gen double `fin_max'   = `val' if `ismax' == 1
    quietly gen str `lbl' = string(`val', "`fmt'")

    twoway ///
        (bar `fin_other' `order', horizontal barwidth(0.62) color("0 108 153")) ///
        (bar `fin_max'   `order', horizontal barwidth(0.62) color("0 34 68"))   ///
        (scatter `order' `val', msymbol(none)                                   ///
            mlabel(`lbl') mlabposition(3) mlabcolor("0 34 68")                  ///
            mlabsize(medium) mlabgap(1.5)) ,                                    ///
        ylabel(1/`n', valuelabel angle(0) nogrid labsize(small))               ///
        yscale(noline) ytitle("")                                              ///
        xscale(range(0 .) noline) xlabel(none) xtitle("")                      ///
        title(`"`title'"', size(medium) color("0 34 68")                       ///
            position(11) justification(left))                                  ///
        subtitle(`"`subtitle'"', size(small) color("90 90 90")                 ///
            position(11) justification(left))                                  ///
        note("Source: World Bank Development Impact (DECDI), worldbank.org"     ///
             "Sample — not an official World Bank publication.",               ///
            size(vsmall) color("90 90 90"))                                    ///
        legend(off)                                                            ///
        graphregion(color(white) margin(medium)) plotregion(color(white))      ///
        scheme(s1mono)

    graph export "`save'", replace width(2700) height(1440)
    display "Wrote `save'"
end
