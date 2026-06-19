*-------------------------------------------------------------------
* leads_charts.do — DIME-style chart suite (Stata driver)
*-------------------------------------------------------------------
* A thin DRIVER. All house style lives in the reusable dime_scheme.do
* (which defines the `dime_hbar` program), so this file just: import a
* CSV, keep the rows to plot, and call dime_hbar. Point it at a different
* CSV and the same styled chart regenerates.
*
* Run:  cd into stata/ , then  do leads_charts.do
* Base Stata only — no community add-ons required.
* Sample work — not an official World Bank publication.
*-------------------------------------------------------------------

clear all
set more off

* --- 0. Load the reusable house-style asset (defines dime_hbar) ----
do dime_scheme.do

* --- 1. Import the tidy CSV (blanks -> missing) --------------------
import delimited "../data/leads_workshops.csv", clear varnames(1) ///
    case(preserve)

* --- 2. Keep workshops with published financing -------------------
drop if missing(financing_usd_bn)

* Build a readable label: "AFE (Cape Town, 2024)"
gen str label_full = workshop + " (" + city + ", " + string(year) + ")"

* --- 3. Build the chart from the reusable program -----------------
dime_hbar financing_usd_bn , label(label_full)                ///
    title("LEADS regional workshops mobilized billions in financing") ///
    subtitle("Development financing discussed, by workshop (US$ billions)") ///
    fmt("%4.1f") save("leads_financing.png")
