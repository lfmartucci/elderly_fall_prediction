#Helper functions

#Elder data adjustment ####
load_elder_dat_adj <- function(dat_path, elder_adj_path){
  
  elder_dat_raw <- file.path(dat_path, "41598_2021_91797_MOESM1_ESM.xlsx")
  
  elder_d1 <-
    readxl::read_excel(elder_dat_raw, skip = 1) %>% 
    mutate(Number = as.numeric(Number)) %>% 
    filter(!is.na(Number))
  elder_d2 <-  readxl::read_excel(elder_dat_raw, 
                                  sheet = "Environmental characteristics", 
                                  skip = 1) 
  
  
  elder_bind <- left_join(elder_d1, elder_d2) %>% 
    select(-c(`education year`, `Fall risk`)) 
  
  
  #Correcting variable type
  d_adj <- elder_bind %>% mutate(across(c(where(is.numeric), - "No_of_fall"), ~ if(max(.) <= 5) factor(.)))
  
  # Some variables where incorrectly selected
  index <- grepl("time|speed|length", colnames(d_adj))
  correct_vars <- colnames(d_adj)[!index]
  
  
  d_adj <- d_adj %>%
    select(all_of(correct_vars)) %>% 
    cbind(Number = elder_bind$Number)
  
  
  elder_adj <- elder_bind %>% select(-all_of(correct_vars)) %>% 
    left_join(d_adj, by="Number") %>% 
    mutate(across(where(is.factor), ~ paste0("lv", .)),
           across(where(is.character),as.factor),
           History_of_fall = ifelse(History_of_fall == "lv0", "No", "Yes"))
  
  # correcting names
  namessub <- gsub("%", "pct", colnames(elder_adj))
  namessub <- gsub("[\\(|\\) ]", "", namessub)
  names(elder_adj) <- namessub
  
  #Clean a little bit colnames
  elder_adj_final <-  
    elder_adj %>%
    rename_with(~ gsub("_per_.*|_s$|_m$|kg$|cm$|_mps$", "", .)) %>% 
    rename(physical_activity = total_physical_activity_MET_min_week)

  
  saveRDS(elder_adj_final, elder_adj_path)
  
  return(elder_adj_final)
}


elder_pref_spd <- function(elder_adj){
  # info about preferred speed
  pref_spd <-
    elder_adj %>% 
    select(Number:MMSE_score, contains("preferred"), Heightcm:No_of_fall)
  names(pref_spd) <- names(pref_spd) %>% gsub("preferred_", "", .)
  pref_spd <- pref_spd
  
  # elder long dataset by speed
  elder_long_df <- 
    map(c("preferred", "fast", "slow"), function(spd){
      
      spd_reg <- paste0(spd, "_")
      
      elder_adj %>% 
        select(Number, contains(spd)) %>% 
        pivot_longer(cols = c(everything(), - Number)) %>% 
        mutate(name = gsub(spd_reg, "", name),
               speed = spd)
    }) %>%
    plyr::ldply("tibble") %>% 
    #walking speed is 20% faster or slower, therefore doesn't add info
    filter(name != "walking_speed_mps") %>% 
    #gait strategy
    group_by(Number, name) %>% 
    reframe(pref.fast = value[speed == "preferred"] / value[speed == "fast"],
            pref.slow = value[speed == "preferred"] / value[speed == "slow"],
            fast.slow = value[speed == "fast"] / value[speed == "slow"]) %>% 
    pivot_longer(cols = pref.fast:fast.slow, 
                 names_to = "speed",
                 values_to = "ratio") %>% 
    mutate(name = paste0(speed, "_", name)) %>% 
    pivot_wider(id_cols = Number,
                values_from = ratio,
                names_from = name)
  
  elder_adj_final <- full_join(pref_spd, elder_long_df)
  
  
 
  
}

#Elder plots - Hex summary ####
plot_elder <- function(var1, var2, z){
  
  dat <-
    elder_adj %>%
    mutate(History_of_fall = ifelse(History_of_fall == "No", 0, 1))
  
  mid <- dat %>% 
    select({{z}}) %>%
    filter(is.finite({{z}})) %>% 
    unlist() %>%
    mean()
  
  title <- gsub("_", " ", substitute(z)) %>% str_to_title()
  title <- gsub("\\.", " vs. ", title) 
  xlab <- gsub("_", " ", substitute(var1)) %>% str_to_title()
  ylab <- gsub("_", " ", substitute(var2)) %>% str_to_title()
  
  dat %>%
    ggplot(aes({{var1}}, {{var2}}, z = {{z}})) +
    stat_summary_hex(bins = 20) +
    scale_fill_gradient2(low = "#9BBCD8",
                         mid = "#007CB8",
                         high = "#8B5897",
                         midpoint = mid) +
    plot_theme("dark", plot_type = "line") +
    labs(fill = "Mean", title = title, x = xlab, y = ylab) +
    theme(aspect.ratio = .8)
  
}


#Estimite perf tidy models #####
estimate_perf <- function(model, dat, outcome){
  cl <- match.call()
  obj_name <- as.character(cl$model)
  data_name <- as.character(cl$dat)
  data_name <- gsub(".*_", "", data_name)
  
  reg_metrics <- metric_set(mcc, accuracy, j_index, sensitivity, specificity)
  
  model %>% predict(dat) %>% 
    rename(.pred = 1) %>% 
    bind_cols(dat %>% select({{outcome}})) %>% 
    reg_metrics({{outcome}}, estimate = .pred) %>% 
    select(-.estimator) %>% 
    mutate(object = obj_name, data = data_name)
  
  
}
