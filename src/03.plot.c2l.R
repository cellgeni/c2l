library(Seurat)
library(schard)
library(visutils)

setwd(dirname(dirname(dirname(dirname(rstudioapi::getSourceEditorContext()$path)))))
getwd()


# load data ########
#sids = sub('.h5ad','',list.files(paste0('processed/',tic,'/vis/')))
vs = h5ad2seurat_spatial('viss.h5ad',simplify = FALSE,load.X = FALSE,load.obsm = FALSE)
names(vs)

# load results from h5ad
c2lnames=list.dirs(paste0('pred/'),recursive = F,full.names = F)
#c2lnames = c2lnames[grep('XXXXXX',c2lnames)]
c2ls = lapply(c2lnames,function(n){
  r = schard::h5ad2data.frame(paste0('pred/',n,'/predmodel/sp.h5ad'),'obsm/q05_cell_abundance_w_sf',keep.rownames.as.column = FALSE)
  colnames(r) = sub('q05cell_abundance_w_sf_','',colnames(r))
  m = do.call(rbind,strsplit(rownames(r),'|',T))
  r$barcode = m[,2]
  r = split(r,m[,1])
  for(i in 1:length(r)){
    #rownames(r[[i]]) = r[[i]]$barcode
    r[[i]]$barcode = NULL
    r[[i]] = as.matrix(r[[i]])
  }
  r
})


# or from csv
# c2ls = lapply(c2lnames, function(a){
#   r = read.csv(paste0('pred/',a,'/predmodel/q05_cell_abundance_w_sf.csv'),row.names = 1,check.names = FALSE)
#   #rownames(r) = gsub('spaceranger130_count_39274_|_GRCh38-2020-A','',rownames(r))
#   colnames(r) = sub('q05cell_abundance_w_sf_','',colnames(r))
#   m = do.call(rbind,strsplit(rownames(r),'|',T))
#   r$barcode = m[,2]
#   r = split(r,m[,1])
#   #r = split(r,substr(rownames(r),20,10000))
#   for(i in 1:length(r)){
#     #rownames(r[[i]]) = r[[i]]$barcode
#     r[[i]]$barcode = NULL
#     r[[i]] = as.matrix(r[[i]])
#   }
#   r
# })
names(c2ls) = c2lnames
c2ls[[1]][[1]][1:4,]


vsf = list()
for(n in names(vs)){
  print(n)
  for(c in colnames(vs[[n]]@images[[1]]@coordinates))
    vs[[n]]@images[[1]]@coordinates[,c] = as.numeric(vs[[n]]@images[[1]]@coordinates[,c])
  #vs[[n]]@images[[1]]@image = enhanceImage(vs[[n]]@images[[1]]@image,qs = c(0.02,0.98))
  vsf[[n]] = vs[[n]][,rownames(c2ls[[1]][[n]])]
}
sapply(c2ls[[1]],dim)
sapply(vs,dim)
sapply(vsf,dim)


# plot tUMI ############
he.img.width = 300
fig.prefix = ''

pdf(paste0('figures/',fig.prefix,'tUMI.pdf'),w=4*3.5,h=2*3)
par(mfrow=c(2,4),mar=c(0.1,0.1,1.2,6),bty='n',oma=c(0,0,0,0))
for(n in names(vs)){
  plotVisium(vs[[n]],vs[[n]]$nCount_Spatial,zfun = log1p,main=n,cex = scaleTo(log1p(vs[[n]]$nCount_Spatial)),legend.args = list(title='tUMI'),he.img.width=he.img.width)
}
dev.off()


# cells.leg.order = names(sort(apply(do.call(rbind,c2ls[[1]]),2,mean),decreasing = T))
# ctcols = char2col(colnames(c2ls[[1]][[1]]),palette = T)
# ctcols[cells.leg.order[1:9]] = setNames(RColorBrewer::brewer.pal(9,'Set1'),cells.leg.order[1:9])

ctcols = getColoursByDistance(1-cor(do.call(rbind,c2ls[[1]])),orderBySim = T,use3D = F)
# to order in legend
cells.leg.order = names(ctcols)
ctcols = ctcols[colnames(c2ls[[1]][[1]])]


ncol=4
width = ncol*3+8
height = 3*3
omar = 45

# plot summary ############
# _vector #####
for(a in names(c2ls)){
  print(a)
  pdf(paste0('figures/c2l.',fig.prefix,a,'.summary.pdf'),w=width,h=height)
  par(mfcol=c(3,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,omar))
  i = 1
  for(n in names(vs)){
    ctcols = ctcols[colnames(c2ls[[a]][[n]])]
    plotVisium(vs[[n]],vs[[n]]$nCount_Spatial,zfun = log1p,main=n,cex = scaleTo(log1p(vs[[n]]$nCount_Spatial)),legend.args = list(title='tUMI'),he.img.width=he.img.width)
    plotVisium(vsf[[n]],pie.fracs=c2ls[[a]][[n]],pie.cols=ctcols,pie.min.frac=0.01,main=a,cex = 1,plot.legend = F,he.img.width=he.img.width)
    plotVisiumMultyColours(vsf[[n]],c2ls[[a]][[n]],cols = ctcols,zfun = function(x)x^2,he.img.width=he.img.width,scale.per.colour = T,legend.ncol=0,min.opacity = 250)
    if(i %% ncol == 0 | i == length(vs))
      legend(grconvertX(1,'nfc','user'),grconvertY(1,'ndc','user'),xpd=NA,fill=ctcols[cells.leg.order],border=NA,legend=cells.leg.order,ncol=2,bty='n')
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
      png(paste0('figures/c2l.',fig.prefix,a,'.',100+i,'.summary.png'),w=width,h=height,units = 'in',res = 150)
      par(mfcol=c(3,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,omar))
    }
    ctcols = ctcols[colnames(c2ls[[a]][[n]])]
    plotVisium(vs[[n]],vs[[n]]$nCount_Spatial,zfun = log1p,main=n,cex = scaleTo(log1p(vs[[n]]$nCount_Spatial)),legend.args = list(title='tUMI'),he.img.width=he.img.width)
    plotVisium(vsf[[n]],pie.fracs=c2ls[[a]][[n]],pie.cols=ctcols,pie.min.frac=0.01,main=a,cex = 1,plot.legend = F,he.img.width=he.img.width)
    plotVisiumMultyColours(vsf[[n]],c2ls[[a]][[n]],cols = ctcols,zfun = function(x)x^2,he.img.width=he.img.width,scale.per.colour = T,legend.ncol=0,min.opacity = 250)
    if(i %% ncol == 0 | i == length(vs)){
      legend(grconvertX(1,'nfc','user'),grconvertY(1,'ndc','user'),xpd=NA,fill=ctcols[cells.leg.order],border=NA,legend=cells.leg.order,ncol=2,bty='n')
      dev.off()
    }
    i = i + 1
  }
  pngs = sort(list.files(paste0('figures'),pattern = '*.png',full.names = T))
  mergePNG2PFD(fls=pngs,pdfout = paste0('figures/c2l.',fig.prefix,a,'.summary.bitmap.pdf'),w=width,h=height)
  file.remove(pngs)
}



# plot per cell type #####
# _vector ########
he.grayscale  = TRUE
img.alpha = 0.4

majorcells = names(sort(apply(do.call(rbind,c2ls[[1]]),2,mean),decreasing = T))
celltypes = majorcells[1:min(40,length(majorcells))]
nrow=4
ncol=8

for(a in names(c2ls)){
  print(a)
  pdf(paste0('figures/c2l.',fig.prefix,'by.celltype.',a,'.pdf'),w=ncol*3.5,h=nrow*3)
  par(mfrow=c(nrow,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,0))
  for(ct in celltypes){
    for(sid in names(vsf)){
      plotVisium(vsf[[sid]],c2ls[[a]][[sid]][,ct],zfun = log1p,cex = scaleTo(log1p(c2ls[[a]][[sid]][,ct])),main=paste0(sid,'; ',ct),he.img.width=he.img.width,he.grayscale=he.grayscale,img.alpha=img.alpha)
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
        png(paste0('figures/c2l.',fig.prefix,'by.celltype.',a,'.',10000+i,'.png'),w=ncol*3.5,h=nrow*3,units = 'in',res = 100)
        par(mfrow=c(nrow,ncol),mar=c(0.1,0.1,1.2,4),bty='n',oma=c(0,0,0,0))
      }

      plotVisium(vsf[[sid]],c2ls[[a]][[sid]][,ct],zfun = log1p,cex = scaleTo(log1p(c2ls[[a]][[sid]][,ct])),main=paste0(sid,'; ',ct),he.img.width=he.img.width,he.grayscale=he.grayscale,img.alpha=img.alpha)

      if(i %% (ncol*nrow) == 0 | i == (length(vs)*length(celltypes))){
        dev.off()
      }
      i = i + 1
    }
  }
  pngs = sort(list.files(paste0('figures'),pattern = '*.png',full.names = T))
  pngs = pngs[grep(paste0('c2l.',fig.prefix,'by.celltype.',a),pngs)]
  mergePNG2PFD(fls=pngs,pdfout = paste0('figures/c2l.',fig.prefix,'by.celltype.',a,'.bitmap.pdf'),w=ncol*3.5,h=nrow*3)
  file.remove(pngs)
}
