# Implementation Plan

1. **Setup**
   - Create `data/` and `plots/` directories (with `here::here()`).
   - Use `pacman::p_load()` to load `here`, `readxl`, `dplyr`, `ggplot2`, `usmap`, `scales`.

2. **Data acquisition**
   - Conditionally download the Excel file to `data/AP_2018_State_County_Inventory.xlsx` using `download.file(..., mode = "wb")`.

3. **Data ingestion**
   - Read **Output - State** with `readxl::read_excel(..., .name_repair = "unique_quiet")` wrapped in `suppressMessages()`.
   - Print a success message with the row count.

4. **Preprocessing**
   - Select `State` and `Total kg/person`.
   - Convert `Total kg/person` to numeric with `suppressWarnings(as.numeric(...))`.
   - Lower-case state names for robust joining (or pass `state` directly to `plot_usmap`).

5. **Map data**
   - Use `plot_usmap(regions = "states", data = df, values = ...)` for the choropleth base.

6. **Visualization**
   - Apply `scale_fill_gradientn()` with dark green → yellow → red.
   - Grey borders; white background.
   - Add title, subtitle, caption; remove axes.

7. **Export**
   - Save PNG to `plots/us_asphalt_emissions_2018.png` using `ggsave(..., bg = "white")`.

8. **Error handling & diagnostics**
   - `tryCatch` around folder creation, download, reading, plotting, and saving.
   - Warn about unmatched states after filtering.
