httr2::request("https://data.usajobs.gov/api/search") |>
  httr2::req_url_query(Keyword = "Data Analyst", ResultsPerPage = 500) |>
  httr2::req_headers(
    Host = "data.usajobs.gov",
    "User-Agent" = "fmegahed@miamioh.edu",
    "Authorization-Key" = Sys.getenv("USAJOBS_API_KEY")
  ) |>
  httr2::req_perform() |>
  httr2::resp_body_string() |>
  jsonlite::fromJSON(flatten = TRUE) -> usa_jobs_list

usa_df = usa_jobs_list$SearchResult$SearchResultItems

jobs_small = usa_df |>
  dplyr::select(
    title = MatchedObjectDescriptor.PositionTitle,
    department = MatchedObjectDescriptor.DepartmentName,
    agency = MatchedObjectDescriptor.OrganizationName,
    location = MatchedObjectDescriptor.PositionLocationDisplay,
    closes = MatchedObjectDescriptor.ApplicationCloseDate
  )

## Answer Based on Query
nrow(jobs_small)
# returns a named vector
table(jobs_small$department) |> sort(decreasing = T) |> head(3)
# returns a df
jobs_small |> dplyr::count(department) |> dplyr::arrange(dplyr::desc(n)) |> head(3)

# answering Anna's question [note the no pipe; the & statement]
# there is probably more fancy ways of doing this but this is the easiest
# with no regular expressions
index_data_analyst = (
  stringr::str_detect(jobs_small$title, pattern = 'Data') & 
  stringr::str_detect(jobs_small$title, pattern = 'Analyst')
)


jobs = jobs_small[index_data_analyst, ]
table(jobs$department)
