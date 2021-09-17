# CPRD Aurum Pipeline

This is an open-source R package containing pipeline functions to clean and process patient-level CPRD Aurum, with the aim to produce analysis-ready datasets from raw text extracts from CPRD. In addition to this several functions will be included to aid analysis of this data.

#### Project Status: in progress

## Project Description

[Clinical Pracatice Research Datalink (CPRD) Aurum](https://www.cprd.com/article/data-resource-profile-cprd-aurum) is a database containing 
details of routinely collected primary care data from EMIS IT systems in consenting general practices across England and Northern Ireland.

CPRD Aurum captures diagnoses, symptoms, prescriptions, referrals and test for over 19 million patients (as of Sept 2018). This data has been linked to national secondary care databases as well as deprivation and death registration data (not currently processed by this pipeline).
Before it can be used for analysis, Aurum data requires processing and for additional variables to be derived. 
The complex record structure of Aurum, the large number of variables and the size of the data sets makes this a challenging task both from an analytical and computational point of view.

The semi-automated cleaning and processing workflow we are developing in this package is designed to ensure that the Aurum data is processed consistently and reproducibly, that the cleaning process is well documented and that each approved analysis project is based on the same clean data.

## Data Source

This study is based in part on data from the Clinical Practice Research Datalink obtained under license from the UK Medicines and Healthcare products Regulatory Agency (approved study protocol number #21_000333). The data is provided by patients and collected by the NHS as part of their care and support. The interpretation and and conclusions contained in this study are those of the author alone.

The data will be accessed in The Health Foundation's Secure Data Environment; a secure data analysis facility (accredited with the ISO27001 information security standard, and recognised for the NHS Digital Data Security and Protection Toolkit). No information that could directly identify a patient or other individual will be used.

## Documentation

This readme contains information on the CPRD Aurum data cleaning and processing protocol. 
A log file is created each time the pipeline is run in `.\data\log` that are created during the run that details 

*   Which text files and how many records in each were processed
*   What variables exist and what data class they were assigned (These can be requested to be       classed according to the user, otherwise `vroom::vroom` does a good job at guessing)
*   How much missing data there is in each field
*   How many dates don't make sense (for example, dates in the future)

There is documentation available for all the functions and package metadata by using `?functionname` once the package is loaded.

## How does it work?

As the Aurum data prepared in this pipeline is not publicly available, the code 
cannot be used to replicate the same clean data and database. However, the code 
can be used on similar extracts to prepare the datasets for analysis. This readme will detail the intended workflow to process the raw CPRD output using this pipeline.

The pipeline works by creating a specific file structure that defaults to within your project folder or working directory that is required to exist for some functions to work correctly. This is a partly a design decision to simplify calls to functions and data but also a requirement and benefit of using parquet files from the `arrow` package. For that reason then it is suggested to run the initial pipeline function `aurum_pipeline()` from within a new project and in it's base directory. The pipeline will create a data folder with subdirectories based on the number and size of the CPRD files you have in your sample.

Alternatively if multiple people are working on the same sample the data location can be specified and the structure mentioned above will be created there instead.

This allows easy loading of the data with the `opendt()` function, which is itself used within other functions quite often. If over time this becomes restrictive to users I am happy to revisit this structure.

If your project is also on GitHub or elsewhere you can keep your processed data safe by adding the `data` folder to `.gitignore` by adding a line with `data/`.

### Pipeline design and features 

The pipeline has been divided into a set of functions, many of which are optional based on the user need, but are required to run in a specific order. The first function to be run on a raw extract from CPRD will generally be [aurum_pipeline()](Man/aurum_pipeline.Rd).

This first stage of the pipeline can by run in two modes:

*   **Regular mode** creates a new set of parquet files from scratch (this is the default). 
*   **Check mode** creates the same set of parquet files but only using 100 records per raw text file (if `check = TRUE`), and within a subdirectory called `Data\Check`. 
*   In both modes this function will, for each table specified:

    + read in data from each file
    + coercing data types (optional)
    + cleaning variables
    + report on any missing data
    + save the data as parquet files partitioned by the number of raw files used
    
Once the parquet file structure has been created, the following functions can be used to access and modify them:

*   `opendt()`: A function to open the data from the parquet files created above. Used by the majority of other functions.
*   `check_vars()`: A function to report on missing data and dates from the output of `aurum_pipeline()`.
*   `check_patid_links()`: A function to check the proportion of all patient ids linking across expected datasets. It returns a proportion that link in the consolse.
*   `add_age()`: Adds age information to the patient table.
*   `add_ethnicity()`: Adds ethnicity information to the patient table. Requires a codelist with medcodeids and a number of categories as strings (can be 1 or more). This uses the modal ethnic medcode, or in the event of a tie, the most recent one.

I have codelist using functions in development including the QOF codelists from NHS Digital and the codelists developed by [Anna Head](github.com/annalhead/CPRD_multimorbidity_codelists) for multimorbidity.

*   `read_multimorb_codelists()`: Place all the medical condition codelists you wish to use in the the same folder and point this function at it to read them all in and set lookback times (in days) for each in the `read` column. (Feel free to edit that to change how far to look back for each condition)
*   `get_codes()`: Filter your observation or drugissue data to the relevent codelist(s) you have supplied, as well as date ranges.
*   `cond_medcodes()`: In long format create a dataset of conditions for each patient in your sample based on the codelist(s) and lookback times supplied.

Other functions are available in the `utils.R` script, and a script containing code to create basic descriptive charts and summaries of checks can be found in `create.R`. **currently removed**

## Installation

Download the Aurum Pipeline source code using one of these links:
[downloading](https://github.com/HFAnalyticsLab/aurumpipeline/archive/refs/heads/main.zip) 
or cloning the repo with 
[ssh](git@github.com:HFAnalyticsLab/aurumpipeline.git)
or [https](https://github.com/HFAnalyticsLab/aurumpipeline.git).

Alternatively install the package directly using the `devtools` package:

`devtools::install_github('HFAnalyticsLab/aurumpipeline')`

## Requirements

### Software and R packages

The CPRD Aurum pipeline was built under R version 4.0.3 (2020-10-10) -- "Bunny-Wunnies Freak Out".

The following R packages, which are available on CRAN, are required to run the Aurum pipeline:

*   arrow (3.0.0)
*   bit64 (4.0.5)
*   data.table (1.13.6)
*   DBI (1.1.1)
*   dplyr (1.0.4)
*   ggplot2 (3.3.3)
*   here (1.0.1)
*   logr (1.2.1)
*   lubridate (1.7.9.2)
*   magrittr (2.0.1)
*   purrr (0.3.4)
*   readr (1.4.0)
*   readxl (1.3.1)
*   reshape2 (1.4.4)
*   stringr (1.4.0)
*   tidyselect (1.1.0)
*   vroom (1.4.0)

The required functions from these packages will be imported when the `aurumpipeline` package is loaded. The whole of the package `data.table` will be imported as many of the processes in `aurumpipeline` make use of it.

There is one other package that the pipeline can make use of - `aurumLkup` which is available internally for Health Foundation staff. If you have that installed then it will enable the pipeline to use all the associated lookup files for CPRD Aurum without having to load them manually. 

If the `aurumLkup` package is not installed you can provide filepaths to your lookups instead (provided by CPRD) and the pipeline will use those. (In fact you can do that with the `aurumLkup` package loaded as well if you have more up to date versions of them).

### Storage capacity

The location where the database is created needs to have sufficient storage space available, roughly equivalent to the combined file size of the raw CPRD data extract (~50GB in our sample) plus the file size of the parquet data set (~18GB).

## Running the pipeline 

### Notes on filepaths and lookups

* `here()` is used extensively by large parts of the pipeline when a filepath is not explicitly given. The processed data will go to `\Data` (check mode will go to `Data\Check`), charts and other results will go to `Output`, and data processing results will go to `\Check`. Generally all references to files will be in a subdirectory (eg: `opendt('Patient')), however if a full path name is supplied then it can look outside of the project folder as well - for example looking at codelists or lookup files on another drive.

* Lookup files currently used by the pipeline are: (These are all available in `aurumLkup`)
  + EMIS medical dictionary
  + EMIS product dictionary
  + EMIS code categories
  + Consultation source
  + Staff job category
  + Observation type

There are other lookups commonly available but these are not currently referenced.

### Required arguments

There are only 2 required arguments for the `aurum_pipeline()` function:

* type: The table you want to process from your CPRD Aurum extract
* dataloc: A character path to your data directory

Optional arguments can be supplied if non-standard processing is required:

* cols: A character string to force data types to columns - use if a specific datatype is required or if the standard assigning by `vroom::vroom` is not correct
* saveloc: An alternative filepath to a location on disk where the Aurum parquet files will be created
* patids: If a specific sample of patients is known, supplying a vector of their patient ids will limit the processing to just these patients' data.
* check: Run in check mode as described above

A note on column types. The pipeline defaults to letting `vroom` assign data types and then overwrites any EMIS medical or product codes as `bit64::integer64`. This is to keep the accuracy when the id's are very large numbers. If you want to supply your own data types you can with the `cols` argument. It is a single string of letters, with each describing a column datatype in order. See the `vroom` documentation for more details

### Usage

Currently the pipeline is designed to run in an RStudio session. Once the package is installed (see above) load the contents in the usual way:

`> library("aurumpipeline")`

Then set the correct paths to locations described above. The first function to call is: `aurum_pipeline()`, providing as arguments the data type, the column data definitions (to be found in `tabledata`), and if required, and a boolean to enable check mode and a vector of patient ids to filter to. For example - to process the raw observation data:

```R
> obs <- aurum_pipeline(type = 'Observation'
                        , cols = 'ddidDDddIdiiddd')
                        , dataloc = 'pathtomy/data')
```
Using the metadata supplied in the package this can be written as:

```R
> obs <- aurum_pipeline(type = tabledata$table_name[1]
                        , cols = tabledata$cols[1]
                        , dataloc = 'pathtomy/data')
```

The data will be processed and saved as parquet files, and the results of the checks saved to the object obs. If all raw files are to be processed (a common use case), then run the pipeline function through a loop or your favourite vectorised operation. This can take a reasonably long time, system and raw extract size considered.

Example run using the pipeline on each table type in turn:

```R
res_checks <- data.frame()

for (j in 1:nrow(tabledata)){
  
  res <- aurum_pipeline(type = tabledata$table_name[j]
                        , cols =  tabledata$cols[j]
                        , dataloc = 'pathtomy/data'
                        , check = TRUE)
  res_checks <- rbind(res, res_checks)

} 
```

## Querying the Aurum parquet files

For guides on how to query parquet files from R, for example see the RStudio tutorial (Parquet using R)[add link].

The database can be queried by using functions from the `arrow` package, or with the function `opendt()`[opendt.Rd]. For example:

```R
# Example 1: Load in all patient ids only 
cohort <- opendt('Patient', cols_in = 'patid')

# Example 2: Load in all consultations in 2019
cons <- opendt('Consultation', date_in = 'consdate', 
                start_date = '2019-01-01', end_date = '2019-12-31')


# Option 3: Load in all observations for the first 10k patients in the cohort
patients <- cohort[1:10000]
obs <- opendt('Observation', patient_list = patients)
```

### Applying the codelist functions to flag conditions for each patient

```R
### example of using new pipeline codelist functions
## set location of codelists 
codeloc <- 'Path/to/your/codelist/folder'

## get all codelists
codelist <- read_multimorb_codelists(codeloc) %>%
            .[, .(disease, medcodeid, read, system)] ## disease is detailed info, system is grouped
                                                     ## and read is how far to look back in days


## get relevant observations
diag_obs <- get_codes('Path/to/your/observation/data'
                     , enddate = '2016-01-01'
                     , codelist = codelist) 

cond <- cond_medcodes(diag_obs ## data to use
                      , codelist ## codelist
                      , 'disease' ## var name of category required to flag for
                      , '2016-01-01') ## date to look back from

### then get results wide and add flag for each patient:
results <- cond[ #bind our tables
            , .(patid, disease, flag = 1)] %>% #restrict to required variables and add a flag variable in (to indicate the ref exists)
            reshape2::dcast(., ... ~ disease, value.var = 'flag', fill = 0) %>% ## cast long to wide with disease names as field headers
            setDT() ## back to data.table

```

## License

This project is licensed under the [MIT License](LICENSE)
