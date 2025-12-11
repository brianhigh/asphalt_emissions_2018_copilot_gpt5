# Walkthrough

1. **Run the script**
   - From the project root: `source("asphalt_us_states_map.R")`.

2. **Folders**
   - The script creates `data/` and `plots/` as needed.

3. **Download**
   - If the Excel file is missing, it's downloaded in binary mode to `data/`.

4. **Read & clean**
   - The script reads **Output - State** quietly.
   - It selects `State` and `Total kg/person`, converts to numeric (warnings suppressed).

5. **Visualize**
   - `usmap::plot_usmap()` uses the provided `state` and values to build the choropleth.
   - Colors: dark green → yellow → red.
   - Background: white; axes removed.

6. **Export**
   - The plot is saved to `plots/us_asphalt_emissions_2018.png`.

7. **Troubleshooting**
   - If you see NA fills, an unmatched state name may be present (e.g., "United States" aggregate). The script filters common aggregates/territories and warns if others remain.
   - Ensure internet connectivity for the initial download.
