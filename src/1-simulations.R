if(!exists("prj")){
  stop("You need to create a object 'prj' that points to the top folder, 
       e.g. prj <- '/home/edisz/Documents/usetheglm'!")
} else {
  source(file.path(prj, "src", "0-load.R"))
}


### ----------------------------------------------------------------------------
### Simulation 1 -  Count data
### Written by Eduard Szöcs
### ----------------------------------------------------------------------------
# Settings
# sample sizes
N <- c(3, 6 ,9)
ctrl <- 2^(c(1:7))
# both as grid
todo_c <- expand.grid(N = N, ctrl = ctrl)
# fixed theta
theta  <- rep(4, 6)  

### ------------------------
### Power simulations
# create datasets
sims1_c <- NULL
# set.seed(seed)
for(i in seq_len(nrow(todo_c))){
  N <- todo_c[i, 'N']
  takectrl <- todo_c[i, 'ctrl']
  # reduce t2-t5 to 50%
  taketrt <- takectrl * 0.5
  mu <- c(rep(takectrl, each = 2), rep(taketrt, each = 4))
  sims1_c[[i]] <- dosim1(N = N, mu = mu, nsims = nsims, theta = theta)
}

# # plot one realisation of simulated data
# todo_c[13, ]
# df <- data.frame(x = sims1_c[[13]]$x, y = sims1_c[[13]]$y[ , 10])
# df$yt <- log(1 / min(df$y[df$y != 0]) * df$y + 1)
# dfm <- melt(df)
# levels(dfm$variable) <- c('y', 'ln(Ay + 1)')
# ggplot(dfm, aes(x = x, y = value)) +
#   geom_boxplot(fill = 'grey80') +
#   facet_wrap( ~variable, scales = 'free_y') +
#   scale_x_discrete(labels = c('C', 'T1', 'T2', 'T3', 'T4', 'T5')) +
#   labs(x = 'Treatment', y = 'Abundance') +
#   theme_bw(base_size = 12, 
#            base_family = "Helvetica") +
#   theme(panel.grid.major = element_blank(),
#         text = element_text(size = 14),
#         axis.text = element_text(size = 12),
#         axis.title = element_text(size = 14,face = "bold"))
# 
# # poster plot
# ggplot(dfm[dfm$variable == 'y', ], aes(x = x, y = value)) +
#   # geom_boxplot(fill = '#2A6491') + 
#   geom_point(size = 7, col = '#2A6491') + 
#   scale_x_discrete(labels = c('C', 'T1', 'T2', 'T3', 'T4', 'T5')) +
#   labs(x = 'Treatment', y = 'Abundance') +
#   theme_bw(base_size = 12, 
#            base_family = "Helvetica") +
#   theme(panel.grid.major = element_blank(),
#         text = element_text(size = 14),
#         axis.text = element_text(size = 25),
#         axis.title = element_text(size = 27,face = "bold")) +
#   annotate("text", x = 4.8, y = 50, label = "T2 - T5: Effect treatments (mean = 16)", size = 7)+
#   annotate("text", x = 1.5, y = 50, label = "C + T1: mean = 32", size = 7)



# run methods
if(sim1){
  if(parallel){
    # res1_c <-mclapply(sims1_c, resfoo1, npb = 1, mc.cores = ncores)
    res1_c <- mclapply(sims1_c, resfoo1, npb = 500,  verbose = FALSE, mc.cores = ncores, pb = pb)
  } else {
    res1_c <- lapply(sims1_c, resfoo1, npb = 500, pb = pb)
  }
  saveRDS(res1_c, file.path(cachedir, 'res1_c.rds'))
} 


### ------------------------
# Type1 Error simulations
# create simulate data
sims2_c <- NULL
# set.seed(seed)
for(i in seq_len(nrow(todo_c))){
  N <- todo_c[i, 'N']
  takectrl <- todo_c[i, 'ctrl']
  # all treatments with same mean
  taketrt <- takectrl * 1
  mu <- c(rep(takectrl, each = 2), rep(taketrt, each = 4))
  sims2_c[[i]] <- dosim1(N = N, mu = mu, nsims = nsims, theta = theta)
}

# run methods
if(sim1){
  if(parallel){
    res2_c <- mclapply(sims2_c, resfoo1, npb = 500, verbose = FALSE, mc.cores = ncores, pb = pb)
  } else {
    res2_c <- lapply(sims2_c, resfoo1, npb = 500, pb = pb)
  }

  saveRDS(res2_c, file.path(cachedir, 'res2_c.rds'))
} 



### ----------------------------------------------------------------------------
### Simulation 2 -  Binomial data
### Written by Eduard Szöcs
### ----------------------------------------------------------------------------
### ------------------------
### Power Simulations
# Settings
# sample sizes
N <- c(3, 6 ,9)
n_animals <- 10
# proportions in effect groups
pEs <- seq(0.6, 0.95, 0.05)
# both as grid
todo_p <- expand.grid(N = N, pE = pEs)

# create simulated data
sims1_p <- NULL
set.seed(1234)
for(i in seq_len(nrow(todo_p))){
  sims1_p[[i]] <- dosim2(N = todo_p[i, 'N'], 
                         pC = 0.95, pE = todo_p[i, 'pE'], 
                         nsim = nsims, n_animals = n_animals)
}

# # plot one realisation of simulated data
# df <- data.frame(x = sims1_p[[22]]$x, y = sims1_p[[22]]$y[ , 7] / 10)
# ggplot(df, aes(x = x, y = y)) +
#   geom_boxplot(fill = 'grey80') +
#   scale_x_discrete(labels = c('C', 'T1', 'T2', 'T3', 'T4', 'T5')) +
#   labs(x = 'Treatment', y = 'Prop. surv.') +
#   theme_bw(base_size = 12, 
#            base_family = "Helvetica") +
#   theme(panel.grid.major = element_blank(),
#         text = element_text(size=14),
#         axis.text=element_text(size=12),
#         axis.title=element_text(size=14,face="bold"))

# run methods
if(sim2){
  if(parallel){
    res1_p <- mclapply(sims1_p, resfoo2, verbose = FALSE, mc.cores = ncores)
  } else {
    res1_p <- lapply(sims1_p, resfoo2)
  }
  saveRDS(res1_p, file.path(cachedir, 'res1_p.rds'))
}

### ------------------------
# Type1 Error simulations

# create simulated data
sims2_p <- NULL
for(i in seq_len(nrow(todo_p))){
  sims2_p[[i]] <- dosim2(N = todo_p[i, 'N'], 
                         pC = todo_p[i, 'pE'], pE = todo_p[i, 'pE'],    # pC = CE
                         nsim = nsims, n_animals = n_animals)
}

# run methods
if(sim2){
  if(parallel){
    res2_p <- mclapply(sims2_p, resfoo2, verbose = FALSE, mc.cores = ncores)
  } else {
    res2_p <- lapply(sims2_p, resfoo2)
  }
  saveRDS(res2_p, file.path(cachedir, 'res2_p.rds'))
}

  
