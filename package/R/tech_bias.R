tech_bias=function(spikein_input, alleleA, alleleB, pdf=NULL){
  if(is.null(pdf)){pdf=TRUE}
  N=apply(alleleA+alleleB,2,sum)
  lib.size=N/mean(N)
  sampname=colnames(alleleA)
  spikein_mol=spikein_input[,1]
  spikein_length=spikein_input[,2]
  spikein_read=spikein_input[,3:ncol(spikein_input)]

  Y=rep(spikein_mol,ncol(spikein_read))
  lib.size.spikein=lib.size[match(colnames(spikein_input)[3:ncol(spikein_input)],sampname)]
  Q=as.vector(spikein_read/matrix(ncol=ncol(spikein_read),nrow=nrow(spikein_read),data=lib.size.spikein,byrow=T)/matrix(ncol=ncol(spikein_read),nrow=nrow(spikein_read),data=spikein_length))*50
  Y=Y[Q!=0]
  Q=Q[Q!=0]
  lmfit=lm(log(Q)~log(Y))
  alpha=lmfit$coefficients[1]
  beta=lmfit$coefficients[2]
  
  if(pdf==TRUE){
    pdf(file='technical_bias_abkt.pdf',height=5,width=8)
    par(mfrow=c(1,2))
    plot(log(Y),log(Q),xlab='Log(true # of molecules)',ylab='Log(observed # of reads)')
    abline(lmfit,col='blue',lwd=1.5)
    text(x=4,y=quantile(log(Q),0.9),paste('log(alpha) =',round(alpha,3)),col='blue')
    text(x=4,y=quantile(log(Q),0.8),paste('beta =',round(beta,3)),col='blue')
  }
  
  Y=rep(spikein_mol,ncol(spikein_read))
  lib.size.spikein=lib.size[match(colnames(spikein_input)[3:ncol(spikein_input)],sampname)]
  Q=as.vector(spikein_read/matrix(ncol=ncol(spikein_read),nrow=nrow(spikein_read),
                                  data=lib.size.spikein,byrow=TRUE)/matrix(ncol=ncol(spikein_read),nrow=nrow(spikein_read),data=spikein_length))*50
  lambda=exp(alpha)*(Y^beta)
  
  kappa.tau=c(-2,2)
  kappa.tau.opt=optim(par=kappa.tau,
                      function(kappa.tau){
                        kappa=kappa.tau[1]
                        tau=kappa.tau[2]
                        l=0
                        for(i in 1:length(Y)){
                          pi_i=expit(kappa+tau*log(Y[i]))
                          if(Q[i]==0){pi=dpois(round(Q[i]),(lambda[i]))*pi_i+1-pi_i;l=l+log(pi)
                          } else{l=l+dpois(round(Q[i]),(lambda[i]),log=TRUE)+log(pi_i)}
                        }
                        return(-l)
                      },
                      method = 'Nelder-Mead')
  kappa=kappa.tau.opt$par[1]
  tau=kappa.tau.opt$par[2]
  
  if(pdf==TRUE){
    Y.sim=1:10000/1000
    plot(Y.sim,1-expit(kappa+tau*Y.sim),type='l',
         ylim=c(0,1),xlab='Log(true expression)',ylab='Percentage of zero reads',col='blue',lwd=1.5)
    text(x=7,y=0.9,paste('kappa =',round(kappa,3)),col='blue')
    text(x=7,y=0.8,paste('tau =',round(tau,3)),col='blue')
    points(log(Y[1:8]),apply(as.matrix(spikein_input[,3:ncol(spikein_input)]),1,function(x){sum(x==0)/length(x)}))
    dev.off()
    par(mfrow=c(1,1)) 
  }
  abkt=round(c(alpha,beta,kappa,tau),4)
  names(abkt)=c('log(alpha)','beta','kappa','tau')
  return(abkt)
}
