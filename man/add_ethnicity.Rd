% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_ethnicity.R
\name{add_ethnicity}
\alias{add_ethnicity}
\title{Ethnicity Coding}
\usage{
add_ethnicity(obs, codelist, fieldnames)
}
\arguments{
\item{obs}{observation data (requires fields obsdate, medcodeid, patientid)}

\item{codelist}{code list of defined ethnicity medcodes (requires medcodeid and ethnicity columns)}

\item{fieldnames}{character vector of ethnicity columns to keep from codelist}
}
\value{
data.table() of matched patient ids with ethnicity columns
}
\description{
Ethnicity Coding
}
