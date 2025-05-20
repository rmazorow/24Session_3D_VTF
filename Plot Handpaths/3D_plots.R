# Author: Rocky Mazorow
# Date Created: 9/28/2024

# Attempts at 3D raw movement plots


library(R.matlab)
library(plotly)

minLim <- -77
maxLim <- 77
minAx <- minLim + 1
maxAx <- maxLim - 1
alpha <- 1 # seq(0.2, 1, length.out = len)
thick <- 1.5


fTitle <- list(
  family = "Arial",
  size = 10,
  color = "black")
fAxis <- list(
  family = "Arial",
  size = 11,
  color = "black")

matlabFile   <- readMat('/consolidated_data/WS_002_perBlock.mat')
data1 <- matlabFile$N1[,,1]
data2 <- matlabFile$N22[,,1]
data3 <- matlabFile$T1[,,1]
data4 <- matlabFile$T22[,,1]

N1 <-  data.frame(X = data1$allX, Y = data1$allY, Z = data1$allZ)
N22 <- data.frame(X = data2$allX, Y = data2$allY, Z = data2$allZ)
T1 <-  data.frame(X = data3$allX, Y = data3$allY, Z = data3$allZ)
T22 <- data.frame(X = data4$allX, Y = data4$allY, Z = data4$allZ)

for (b in 1:4) {
  if (b==1) {
    dat <- N1
    col <-  '#D45C9E'
  }
  else if (b==2) {
    dat <- N22
    col <-  '#D45C9E'
  }
  else if (b==3) {
    dat <- T1
    col <-  '#6AB0D8'
  }
  else if (b==4) {
    dat <- T22
    col <- '#6AB0D8'
  }
  len <- length(unlist(dat$X[1]))
  sceneLab <- paste0("scene",b)
  
  p <- plot_ly(showlegend = F, , scene=sceneLab) %>% 
    # xz plane: z axis then x axis
    add_paths(data = dat, x = c(0,0), y = c(minAx,maxAx), z = c(minAx,minAx), line = list(color = "black", width = thick)) %>%
    add_paths(data = dat, x = c(minAx,maxAx), y = c(0,0), z = c(minAx,minAx), line = list(color = "black", width = thick)) 
  
  
  for (t in 1:nrow(dat)) {
    X <- unlist(dat$X[t])
    Y <- unlist(dat$Y[t])
    Z <- unlist(dat$Z[t])
    temp <-  data.frame(X = X, Y = Y, Z = Z)
    
    p <- p %>% 
      add_paths(data = temp, x = ~Z, y = ~X, z = minLim, opacity = alpha, line = list(color = col, width = thick)) %>% 
      add_paths(data = temp, x = ~Z, y = maxLim, z = ~Y, opacity = alpha, line = list(color = col, width = thick)) %>% 
      add_paths(data = temp, x = minLim, y = ~X, z = ~Y, opacity = alpha, line = list(color = col, width = thick))
  }
  
  p <- p %>%  
    # yz plane: z axis then y axis
    add_paths(data = dat, x = c(minAx,maxAx), y = c(maxAx,maxAx), z = c(0,0), line = list(color = "black", width = thick)) %>% 
    add_paths(data = dat, x = c(0,0), y = c(maxAx,maxAx), z = c(minAx,maxAx), line = list(color = "black", width = thick)) %>%
    # xy plane: y axis then x axis 
    add_paths(data = dat, x = c(minAx,minAx), y = c(minAx,maxAx), z = c(0,0), line = list(color = "black", width = thick)) %>% 
    add_paths(data = dat, x = c(minAx,minAx), y = c(0,0), z = c(minAx,maxAx), line = list(color = "black", width = thick))
  
  if (b==1) {
    n1_2 <- p
  }
  else if (b==2) {
    n22_2 <- p
  }
  else if (b==3) {
    t1_2 <- p
  }
  else if (b==4) {
    t22_2 <- p
  }
}

matlabFile   <- readMat('/consolidated_data/WS_005_perBlock.mat')
data1 <- matlabFile$N1[,,1]
data2 <- matlabFile$N22[,,1]
data3 <- matlabFile$T1[,,1]
data4 <- matlabFile$T22[,,1]

N1 <-  data.frame(X = data1$allX, Y = data1$allY, Z = data1$allZ)
N22 <- data.frame(X = data2$allX, Y = data2$allY, Z = data2$allZ)
T1 <-  data.frame(X = data3$allX, Y = data3$allY, Z = data3$allZ)
T22 <- data.frame(X = data4$allX, Y = data4$allY, Z = data4$allZ)

for (b in 1:4) {
  if (b==1) {
    dat <- N1
    col <-  '#D45C9E'
  }
  else if (b==2) {
    dat <- N22
    col <-  '#D45C9E'
  }
  else if (b==3) {
    dat <- T1
    col <-  '#6AB0D8'
  }
  else if (b==4) {
    dat <- T22
    col <- '#6AB0D8'
  }
  len <- length(unlist(dat$X[1]))
  sceneLab <- paste0("scene",b+4)
  
  p <- plot_ly(showlegend = F, , scene=sceneLab) %>% 
    # xz plane: z axis then x axis
    add_paths(data = dat, x = c(0,0), y = c(minAx,maxAx), z = c(minAx,minAx), line = list(color = "black", width = thick)) %>%
    add_paths(data = dat, x = c(minAx,maxAx), y = c(0,0), z = c(minAx,minAx), line = list(color = "black", width = thick)) 
  
  
  for (t in 1:nrow(dat)) {
    X <- unlist(dat$X[t])
    Y <- unlist(dat$Y[t])
    Z <- unlist(dat$Z[t])
    temp <-  data.frame(X = X, Y = Y, Z = Z)
    
    p <- p %>% 
      add_paths(data = temp, x = ~Z, y = ~X, z = minLim, opacity = alpha, line = list(color = col, width = thick)) %>% 
      add_paths(data = temp, x = ~Z, y = maxLim, z = ~Y, opacity = alpha, line = list(color = col, width = thick)) %>% 
      add_paths(data = temp, x = minLim, y = ~X, z = ~Y, opacity = alpha, line = list(color = col, width = thick))
  }
  
  p <- p %>%  
    # yz plane: z axis then y axis
    add_paths(data = dat, x = c(minAx,maxAx), y = c(maxAx,maxAx), z = c(0,0), line = list(color = "black", width = thick)) %>% 
    add_paths(data = dat, x = c(0,0), y = c(maxAx,maxAx), z = c(minAx,maxAx), line = list(color = "black", width = thick)) %>%
    # xy plane: y axis then x axis 
    add_paths(data = dat, x = c(minAx,minAx), y = c(minAx,maxAx), z = c(0,0), line = list(color = "black", width = thick)) %>% 
    add_paths(data = dat, x = c(minAx,minAx), y = c(0,0), z = c(minAx,maxAx), line = list(color = "black", width = thick))
  
  if (b==1) {
    n1_5 <- p
  }
  else if (b==2) {
    n22_5 <- p
  }
  else if (b==3) {
    t1_5 <- p
  }
  else if (b==4) {
    t22_5 <- p
  }
}

fig <- subplot(n1_2, n22_2, t1_2, t22_2, n1_5, n22_5, t1_5, t22_5) %>% 
  layout(font=fAxis, margin = list(l = 0, r = 0, b = 0, t = 0),
         scene = list(domain=list(x=c(0,0.25),y=c(0.5,1)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'),
         scene2 = list(domain=list(x=c(0.25,0.5),y=c(0.5,1)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'),
         scene3 = list(domain=list(x=c(0.5,0.75),y=c(0.5,1)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'),
         scene4 = list(domain=list(x=c(0.75,1),y=c(0.5,1)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'),
         scene5 = list(domain=list(x=c(0,0.25),y=c(0,0.5)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'),
         scene6 = list(domain=list(x=c(0.25,0.5),y=c(0,0.5)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'),
         scene7 = list(domain=list(x=c(0.5,0.75),y=c(0,0.5)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'),
         scene8 = list(domain=list(x=c(0.75,1),y=c(0,0.5)),
                       xaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       yaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       zaxis = list(title = '', font=fTitle, showticklabels=FALSE,
                                    gridwidth = 2.5, range = c(minLim,maxLim), tickvals = c(-50,0,50)),
                       camera = list(eye = list(x = 2, y = -1.4, z = 1)),
                       aspectmode = 'cube'))
           
fig %>% htmlwidgets::onRender(
  "function(el, x) {
  var gd = document.getElementById(el.id);
  Plotly.downloadImage(gd, {format: 'svg', width: 705, height: 380, filename: 'ws2+5_handplot'});
  }"
)

# Restore viewer to old setting (e.g. RStudio)
options(viewer = fig$viewer)
