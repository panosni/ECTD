# Income Tax Incentives for Electronic Payments: Evidence from Greece's Electronic Consumption Tax Discount

## Replication Code

This is a replication kit for *Income Tax Incentives for Electronic Payments,
Evidence from Greece's Electronic Consumption Tax Discount*. **ECTD** for short.

You can find the current version of the paper [here](https://panosni.github.io/publication/ectd/ECTD.pdf).

The code replicates the current version of the working paper in 2021. It will be
updated accordingly during the publication process.


## System Requirements

The code is written in Stata and has been tested to work with Stata 14 or higher.

Newer versions of Stata (16 or 17) are recommended, as well as, using git for replication.

For do file *003_event_study*, the following additional packages must be
installed before running the event studies:

* eventdd
* estout
* reghdfe
* ftools
* matsort


## Data Availability Statement

Replicating the repository requires access to the data.

The dataset consists of 50,000 anonymised, non-identifiable and randomly-drawn
tax units from the 2017-2018 taxpayer population in Greece.

These were provided by the Independent Authority of Public Revenue in
collaboration with the Greek Ministry of Finance in October 2018.

The data were drawn and anonymised at source, to ensure confidentiality. However, the anonymised data are still considered confidential and cannot be
shared publicly.

**Access to the data** for replication purposes or use in future projects can be
granted in a safe computer at either the Paris School of Economics or the Hertie
School, Berlin upon reasonable request. Access can also be possible at times in
Greece, Cyprus and the UK, subject to the author's presence.

In general, I am happy to consider replication requests and I will do my best to
accomodate colleagues or work on additional projects using the data. If you are
interested in accessing the data, simply write to me.

## Replication Instructions

All do files are concise and included in the DO folder.

### Data Preparation

The Do file 001_data_cleaning.do loads and cleans the .xls file. Please change
the working directory accordingly before running the file to your desired
location. All remaining folders are produced automatically in that directory.

The do file produces three .dta files:

SAMPLE_RAW.dta, SAMPLE_FIXED.dta and SAMPLE_PANEL.dta

* _SAMPLE_RAW_ formats the data from the initial .xls file given by the Tax
Authority and transforms it to .dta format for analysis in Stata.

* _SAMPLE_FIXED_ produces variables for analysis, such as income, income type,
family status, electronic payments, thresholds etc.

* _SAMPLE_PANEL_ strips the raw data and produces a panel of 50,000 individuals
and 19 months of electronic consumption.

The Fixed or Panel datasets can be used independendly based on the analysis.
Alternatively, the Fixed dataset can be merged into the Panel to utilise the
various individual variables during the Panel analysis.

For merging follow commands:

Load the Panel dataset first,

    use "DTA/SAMPLE_PANEL.dta"

Merge the Fixed dataset,

    merge m:1 N using "DTA/SAMPLE_FIXED.dta"


### Threshold-Targeting and Responses in the Reporting Margin

The analysis in the first part of the paper regards responses to thresholds.
Income and threshold information are prepared in the Fixed dataset.
Thresholds are personal and calculated in 001_data_cleaning.do lines 114-117.

Do file 002_thresholds_analysis calculates taxpayer mass on, below and above
the taxpayers' threshold and produces Figures A.1, 4.1, 4.2, 4.3 and 4.4, which
reveals threshold-targeting behaviour and responses on the reporting margin.

### Responses in the Electronic Consumption Margin

Electronic consumption changes due to the ECTD are documented using monthly
event studies. The 003_event_study.do seperates the sample to monthly cohorts,
runs monthly event studies and produces Table A.3 with regression results and
Figure 4.5 with event study figures.

### Remaining Tables and Additional Material

Do file 004_tableA2 produces sample statistics and outputs Table A.2 in
Appendix A. The last column includes the ECTD-eligible sample, single-filers
included in the analysis.

### A Note on Post-Estimation Editing

Figures and tables require some (but minimal) post-estimation editing.
