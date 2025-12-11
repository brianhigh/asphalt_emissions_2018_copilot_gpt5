# Task Checklist

- [x] Create `data/` and `plots/` folders with `here::here()`
- [x] Conditional download of EPA Excel (binary mode)
- [x] Read **Output - State** sheet quietly (`.name_repair = "unique_quiet"`)
- [x] Print success message after reading
- [x] Extract `State` and `Total kg/person`
- [x] Suppress warnings converting to numeric
- [x] Build base map with `usmap::plot_usmap()` (incl. AK & HI)
- [x] Use `scale_fill_gradientn()` for vivid colors
- [x] Grey borders; white background; no axes
- [x] Save PNG to `plots/`
- [x] Provide README, plan, tasks, walkthrough, prompt, `.gitignore`
- [x] Bundle into a zip for delivery
