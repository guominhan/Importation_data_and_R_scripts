rm(list = ls())
library(Hmisc)
library(pheatmap)
library(reshape2)
library(tidyr)

#批量读取文件
list <- dir('data',pattern = '.txt')
for(i in list){
  path <- paste('data/',i,sep = '')
  otu <- read.delim(path,row.names = 1,check.names = F)
  ###将绝对丰度转换为相对丰度
  ###注意：是微生物的相对含量，应该是每个组的微生物的相对含量
  otu <- t(otu)
  otu
  otu <- otu/rowSums(otu)
  otu <- t(otu)
  otu
  rowSums(otu)
  
  ####过滤掉一些低丰度的类群
  ####只保留相对丰度总和高于0.005的属
  otu <- otu[which(rowSums(otu)>=0.005),]
  otu
  dim(otu)
  
  ###只保留在5个及以上样本种出现的属
  genus <- otu
  new_genus <- genus
  new_genus[new_genus>0] <- 1
  new_genus
  genus <- genus[which(rowSums(new_genus)>=5),]
  genus
  dim(genus)
  
  
  ###计算两属之间是否存在丰度变化的相关性，以spearman相关系数为例
  genus_corr <- rcorr(t(genus),type = 'spearman')
  corr_r <- genus_corr$r
  corr_p <- genus_corr$P
  
  
  ###p值校正，这里使用BH法校正p值
  ###之所以需要校正p值是因为结果容易出现假阳性
  new_corr_p <- melt(corr_p)
  head(new_corr_p)
  new_corr_p$value <- p.adjust(new_corr_p$value,method = 'BH')
  new_corr_p <- spread(new_corr_p,Var2,value)
  rownames(new_corr_p) <- new_corr_p$Var1
  head(new_corr_p)
  new_corr_p <- new_corr_p[,-1]
  condition_p <- new_corr_p
  condition_p[is.na(condition_p)] <- 1
  
  ###绘制显著性标记
  #p<0.01-------------'**',0.01<p<0.05----------'*',p>0.05-------------''
  if(!is.null(new_corr_p)){
    sign_1 <- new_corr_p<0.01
    new_corr_p[sign_1] <- '**'
    sign_2 <- new_corr_p>0.01 & new_corr_p<0.05
    new_corr_p[sign_2] <- '*'
    new_corr_p[!sign_1 & !sign_2] <- ''
  }else{
    new_corr_p <- F
  }
  new_corr_p[is.na(new_corr_p)] <- ''
  ###将相关系数低于0.6和p值大于0.05的值赋为0
  ##这步操作建议不要再热图里使用，因为看不到趋势，网络图可以这样操作
  ##这一步其实可以没有，可以直接用后面校正后的P值
  # corr_r[new_corr_p>0.05|abs(corr_r)<0.6] <- 0
  
  #作图
  pic_name <- gsub('filter_gen_','',i)
  pic_name <- gsub('.txt','',pic_name)
  
  ##导出相关性网络绘制文件--------------> （节点文件和边文件）
  
  #这一步筛选特别的关键，阈值挑选的过于严格可能会导致最后没有边---->也就会报错（根据自己需要进行筛选）
  # corr_r[condition_p>0.05|abs(corr_r)<0.6] <- 0
  corr_r[condition_p>0.05|abs(corr_r)<0.1] <- 0
  
  ##由于这里已经对P值进行了筛选，所以网络文件就不必含有P值
  
  #将相关系数矩阵转换为长数据
  corr_data <- melt(corr_r)
  head(corr_data)
  corr_data
  
  ##首先要过滤掉R方为一的连线，因为他们是自身相关
  corr_data <- corr_data[which(corr_data$value != 1),]
  head(corr_data)
  
  #在过滤掉相关性为0的连线
  corr_data <- corr_data[which(corr_data$value != 0),]
  head(corr_data)
  
  #R方转换为正数，并且加上一列标注正负
  corr_data[which(corr_data$value > 0),'P/N'] <- 'P'
  corr_data[which(corr_data$value < 0),'P/N'] <- 'N'
  head(corr_data)
  colnames(corr_data)[1:3] <- c('source','target','cor')
  corr_data$cor <- abs(corr_data$cor)
  head(corr_data)
  
  #将边文件写出去
  edge_name <- paste(pic_name,'edge.txt',sep = '_')
  path_edge_name <- paste('result_data/',edge_name,sep = '')
  
  #这个corr_data有重复边，这里R语言处理暂时不会处理，后面用python去重
  
  write.table(corr_data,file = path_edge_name,sep = '\t',row.names = F,col.names = T,
              quote = F)
  
  #将节点文件写出去
  node <- corr_data[,1:2]
  node$target <- 'genus'
  head(node)
  colnames(node) <- c('Node','feature')
  node_name <- paste(pic_name,'node.txt',sep = '_')
  path_node_name <- paste('result_data/',node_name,sep = '')
  write.table(node,file = path_node_name,sep = '\t',row.names = F,col.names = T,
              quote = F)
}
