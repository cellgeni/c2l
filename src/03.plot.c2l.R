library(Seurat)
library(visutils)
source('/nfs/cellgeni/pasham/rcode/misc.util.R')

setwd(dirname(dirname(dirname(dirname(rstudioapi::getSourceEditorContext()$path)))))
getwd()


# load data ########
#sids = sub('.h5ad','',list.files(paste0('processed/',tic,'/vis/')))
vs = myLoadH5AD_Spatials('viss.h5ad')
names(vs)

# edit rowname parsing accordingly
c2lnames=list.dirs(paste0('pred/'),recursive = F,full.names = F)
c2ls = lapply(c2lnames, function(a){
  r = read.csv(paste0('pred/',a,'/predmodel/q05_cell_abundance_w_sf.csv'),row.names = 1,check.names = FALSE)
  #rownames(r) = gsub('spaceranger130_count_39274_|_GRCh38-2020-A','',rownames(r))
  colnames(r) = sub('q05cell_abundance_w_sf_','',colnames(r))
  m = do.call(rbind,strsplit(rownames(r),'_',T))
  r$barcode = substr(m[,2],1,nchar(m[,2])-2)
  r = split(r,m[,1])
  #r = split(r,substr(rownames(r),20,10000))
  for(i in 1:length(r)){
    rownames(r[[i]]) = r[[i]]$barcode
    r[[i]]$barcode = NULL
    r[[i]] = as.matrix(r[[i]])
  }
  r
})
names(c2ls) = c2lnames
c2ls[[1]][[1]][1:4,]


vsf = list()
for(n in names(vs)){
  print(n)
  for(c in colnames(vs[[n]]@images$slice1@coordinates))
    vs[[n]]@images$slice1@coordinates[,c] = as.numeric(vs[[n]]@images$slice1@coordinates[,c])
  vs[[n]]@images$slice1@image = enhanceImage(vs[[n]]@images$slice1@image,qs = c(0.02,0.98))
  vsf[[n]] = vs[[n]][,rownames(c2ls[[1]][[n]])]
}
sapply(c2ls[[1]],dim)
sapply(vs,dim)
sapply(vsf,dim)


# plot tUMI ############
pdf(paste0('figures/tUMI.pdf'),w=3*3.5,h=2*3)
par(mfrow=c(2,3),mar=c(0.1,0.1,1.2,6),bty='n',oma=c(0,0,0,0))
for(n in names(vs)){
  plotVisium(vs[[n]],vs[[n]]$nCount_Spatial,zfun = log1p,main=n,cex = scaleTo(log1p(vs[[n]]$nCount_Spatial)),legend.args = list(title='tUMI'),he.img.width=400)
}
dev.off()


majorcells = names(sort(apply(do.call(rbind,c2ls[[1]]),2,mean),decreasing = T))
ctcols = char2col(colnames(c2ls[[1]][[1]]),palette = T)
ctcols[majorcells[1:9]] = setNames(RColorBrewer::brewer.pal(9,'Set1'),majorcells[1:9])


ncol=6
width = ncol*3+8
height = 3*3
omar = 45

# plot summary ############
# _vector #####
for(a in names(c2ls)){
  print(a)
  pdf(paste0('figures/c2l.',a,'.pie.pdf'),w=width,h=height)
  par(mfcol=c(3,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,omar))
  i = 1
  for(n in names(vs)){
    ctcols = ctcols[colnames(c2ls[[a]][[n]])]
    plotVisium(vs[[n]],vs[[n]]$nCount_Spatial,zfun = log1p,main=n,cex = scaleTo(log1p(vs[[n]]$nCount_Spatial)),legend.args = list(title='tUMI'),he.img.width=400)
    plotVisium(vsf[[n]],pie.fracs=c2ls[[a]][[n]],pie.cols=ctcols,pie.min.frac=0.01,main=a,cex = 1,plot.legend = F,he.img.width=400)
    plotVisiumMultyColours(vsf[[n]],c2ls[[a]][[n]],cols = ctcols,mode = 'mean',zfun = function(x)x^2,he.img.width=400,scale.per.colour = T,legend.ncol=0,min.opacity = 250)
    if(i %% ncol == 0 | i == length(vs))
      legend(grconvertX(1,'nfc','user'),grconvertY(1,'ndc','user'),xpd=NA,fill=ctcols[majorcells],border=NA,legend=majorcells,ncol=2)
    i = i + 1
  }
  dev.off()
}

# _bitmap ##############
for(a in names(c2ls)){
  print(a)
  i = 1
  for(n in names(vs)){
    if(i %% ncol == 1){
      png(paste0('figures/c2l.',a,'.',100+i,'.pie.png'),w=width,h=height,units = 'in',res = 150)
      par(mfcol=c(3,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,omar))
    }
    ctcols = ctcols[colnames(c2ls[[a]][[n]])]
    plotVisium(vs[[n]],vs[[n]]$nCount_Spatial,zfun = log1p,main=n,cex = scaleTo(log1p(vs[[n]]$nCount_Spatial)),legend.args = list(title='tUMI'),he.img.width=400)
    plotVisium(vsf[[n]],pie.fracs=c2ls[[a]][[n]],pie.cols=ctcols,pie.min.frac=0.01,main=a,cex = 1,plot.legend = F,he.img.width=400)
    plotVisiumMultyColours(vsf[[n]],c2ls[[a]][[n]],cols = ctcols,mode = 'mean',zfun = function(x)x^2,he.img.width=400,scale.per.colour = T,legend.ncol=0,min.opacity = 250)
    if(i %% ncol == 0 | i == length(vs)){
      legend(grconvertX(1,'nfc','user'),grconvertY(1,'ndc','user'),xpd=NA,fill=ctcols[majorcells],border=NA,legend=majorcells,ncol=3,bty='n',)
      dev.off()
    }
    i = i + 1
  }
  pngs = sort(list.files(paste0('figures'),pattern = '*.png',full.names = T))
  mergePNG2PFD(fls=pngs,pdfout = paste0('figures/c2l.',a,'.pie.bitmap.pdf'),w=width,h=height)
  file.remove(pngs)
}



# plot per cell type #####
# _vector ########
celltypes = majorcells[1:min(18,length(celltypes))]
nrow=3
ncol=6

for(a in names(c2ls)){
  print(a)
  pdf(paste0('figures/c2l.by.celltype.',a,'.pdf'),w=ncol*3.5,h=nrow*3)
  par(mfrow=c(nrow,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,0))
  for(ct in celltypes){
    for(sid in names(vsf)){
      plotVisium(vsf[[sid]],c2ls[[a]][[sid]][,ct],zfun = log1p,cex = scaleTo(log1p(c2ls[[a]][[sid]][,ct])),main=paste0(sid,'; ',ct),he.img.width=400)
    }
  }
  dev.off()
}
# _bitmap ########
celltypes = majorcells

for(a in names(c2ls)){
  print(a)
  i = 1
  for(ct in celltypes){
    for(sid in names(vsf)){
      if(i %% (ncol*nrow) == 1){
        png(paste0('figures/c2l.by.celltype.',a,'.',100+i,'.pie.png'),w=ncol*3.5,h=nrow*3,units = 'in',res = 150)
        par(mfrow=c(nrow,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,0))
      }
      
      plotVisium(vsf[[sid]],c2ls[[a]][[sid]][,ct],zfun = log1p,cex = scaleTo(log1p(c2ls[[a]][[sid]][,ct])),main=paste0(sid,'; ',ct),he.img.width=400)
      
      if(i %% (ncol*nrow) == 0 | i == (length(vs)*length(celltypes))){
        dev.off()
      }
      i = i + 1
    }
  }
  pngs = sort(list.files(paste0('figures'),pattern = '*.png',full.names = T))
  pngs = pngs[grep("c2l.by.celltype.",pngs)]
  mergePNG2PFD(fls=pngs,pdfout = paste0('figures/c2l.by.celltype.',a,'.pie.bitmap.pdf'),w=ncol*3.5,h=nrow*3)
  file.remove(pngs)
}