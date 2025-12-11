# U.S. asphalt emissions choropleth (2018)
# Requirements: pacman, here, readxl, dplyr, ggplot2, usmap, scales

# --- Package loading ---
if (!require("pacman")) install.packages("pacman", repos = "https://cloud.r-project.org")
pacman::p_load(here, readxl, dplyr, ggplot2, usmap, scales)

# --- Paths & folders ---
project_root <- here::here()
data_dir     <- here::here("data")
plots_dir    <- here::here("plots")
excel_url    <- "https://pasteur.epa.gov/uploads/10.23719/1531683/AP_2018_State_County_Inventory.xlsx"
excel_path   <- here::here("data", "AP_2018_State_County_Inventory.xlsx")
plot_path    <- here::here("plots", "us_asphalt_emissions_2018.png")

# Create folders if they don't exist
tryCatch({
  if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(plots_dir)) dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)
}, error = function(e) {
  stop("Failed to create required folders: ", conditionMessage(e))
})

# --- Conditional download (binary mode) ---
if (!file.exists(excel_path)) {
  message("Data file not found. Downloading from EPA…")
  tryCatch({
    download.file(url = excel_url, destfile = excel_path, mode = "wb", quiet = TRUE)
    message("Download complete: ", excel_path)
  }, error = function(e) {
    stop("Failed to download EPA data: ", conditionMessage(e))
  })
}

# --- Read data (quietly) ---
emissions_raw <- tryCatch({
  suppressMessages(
    readxl::read_excel(
      path = excel_path,
      sheet = "Output - State",
      .name_repair = "unique_quiet"
    )
  )
}, error = function(e) {
  stop("Failed to read Excel sheet 'Output - State': ", conditionMessage(e))
})

message("Data read successfully: ", nrow(emissions_raw), " rows from 'Output - State'.")

# --- Validate required columns and prepare ---
required_cols <- c("State", "Total kg/person")
missing_cols <- setdiff(required_cols, names(emissions_raw))
if (length(missing_cols) > 0) {
  stop("Missing expected columns: ", paste(missing_cols, collapse = ", "))
}

# Prepare plotting DF expected by plot_usmap(): needs a column named 'state' + a values column
emissions_df <- emissions_raw |>
  dplyr::select(State, `Total kg/person`) |>
  dplyr::mutate(
    state = State,
    kg_per_person = suppressWarnings(as.numeric(`Total kg/person`))
  ) |>
  # Drop aggregate and territories not present in usmap states
  dplyr::filter(!tolower(state) %in% c(
    "united states", "puerto rico", "guam", "virgin islands", "american samoa", "northern mariana islands"
  )) |>
  dplyr::filter(!is.na(kg_per_person))

# Diagnostics: warn about unmatched states vs usmap
try({
  us_states <- usmap::us_map(regions = "states")
  full_lower <- tolower(us_states$full)
  unmatched <- setdiff(tolower(emissions_df$state), full_lower)
  if (length(unmatched) > 0) {
    warning("Unmatched states in emissions data (will appear as NA fill): ", paste(unmatched, collapse = ", "))
  }
})

# --- Build plot using plot_usmap (including AK/HI) ---
p <- tryCatch({
  usmap::plot_usmap(
    regions = "states",
    data = emissions_df,
    values = "kg_per_person",
    color = "grey",
    linewidth = 0.3
  ) +
    ggplot2::scale_fill_gradientn(
      colors = c("#006400", "#FFD700", "#FF0000"),
      na.value = "lightgrey",
      name = "Total kg/person"
    ) +
    ggplot2::labs(
      title = "U.S. asphalt-related emissions per capita by state (2018)",
      subtitle = "Per-capita total asphalt emissions (kg/person) from EPA State County Inventory, aggregated to states",
      caption = "Source: U.S. EPA State County Inventory (2018) — AP_2018_State_County_Inventory.xlsx"
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      legend.position = "right",
      plot.title = ggplot2::element_text(face = "bold"),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.caption.position = "plot",
      plot.caption = ggplot2::element_text(hjust = 0)
    )
}, error = function(e) {
  stop("Failed to construct the plot: ", conditionMessage(e))
})

# --- Save PNG ---
tryCatch({
  ggplot2::ggsave(
    filename = plot_path,
    plot = p,
    width = 11, height = 7, dpi = 300,
    bg = "white"
  )
  message("Saved choropleth map to ", plot_path)
}, error = function(e) {
  stop("Failed to save PNG: ", conditionMessage(e))
})
