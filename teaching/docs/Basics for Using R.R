#Some basics: The '#' sign is used for commenting. R will know to not
#execute the rest of a line after the '#' is used. This is helpful
#for annotations of code so it is easier to read later on.

#Right now there should be nothing loaded in the R environment.

# Working with numbers
# You can use R like a calculator
2+3
2*3
2*(7-3)^2

# You can define objects in R
A = 2+3
A
a              #error, R is case sensitive
B = 7
C = A+B
C

# Working with vectors
x = c(6,1,4,3,5,7) #create a vector, acts like 6x1
y = c(5,7,8,9,6,4)
x*10
x*y             #element by element
t(x) %*% y      #the t() command transposes
x     %*% t(y)
a = seq(1,10)   #a vector with elements 1 to 10, by 1
b = 1:10        #equivalent to b

# Working with matrices
z = matrix(c(1,2,3,4,5,6,7,8,9),ncol=3)
z %*% x   #error, non-conformable arguments. z is 3x3 and x is 6x1
          #check rules of Matrix Algebra if you do not see why R
          #gives an error
g = cbind(x,y,x) #combines vectors by columns
dim(g)           #indicates that g is 6x3
z %*% t(g)

# Some logic, important later on for problems you may encounter
7 > 3             #R can evaluate logical operators
1 > 4             #clearly a false statement and R returns a value of false
z == 7            #evaluates for all elements in z, returns T if true
z > 3 & z < 6     #combine two operators with and
z < 3 | z == 7    #or with the or command
z %in% 7          #equivalent to above, but more flexible
g %in% c(1,3,5)
a == b            #see, I told you they were equivalent.


#Reading data
rm(list=ls())     #This will remove all objects in the R environment. 
                  #download .csv from website
                  #http://www4.ncsu.edu/~rdinter/docs/mlbpayroll2012.csv

file = 'mlbpayroll2012.csv' #this needs to be the file location for the .csv
                            #One caveat with R, the file needs to be of the form:
                            # "C:/xxx/xxx/xxx" or "C:\\xxx\\xxx\\xxx". If you only
                            #have one backslash then R will spit out an error.

mlb <- read.csv(file, header= T) #the = and <- are equivalent. See blog posted
                                 #on website for more on this issue
#http://blog.revolutionanalytics.com/2008/12/use-equals-or-arrow-for-assignment.html

head(mlb)    #looks at first 6 observations

mlb[1:6,]    #equivalent to head. The brackets only work for objects and indicate values
             #to extract. mlb is a dataframe that can be thought of as a matrix
             #mlb[rows,columns]

str(mlb)     #structure of the data, this is similar to the describe command in STATA
             #also helpful in understanding what you can do with your data

summary(mlb) #summary statistics

hist(mlb$TOTAL.PAYROLL)   #produces a histogram of total payroll
hist(mlb[,7])
plot(mlb$TOTAL.PAYROLL, mlb$W)

#Functions
X = cbind(1, mlb$TOTAL.PAYROLL)
y = mlb$W
n = length(y)
k = ncol(X)
bhat     <- chol2inv(chol(t(X) %*% X)) %*% t(X) %*% y
bhat
ehat     <- y - X %*% bhat
s2       <- (t(ehat)%*%ehat)/(n-k)
var.b    <- s2[1,1]*chol2inv(chol(t(X)%*%X))
t.ratios <- bhat/sqrt(diag(var.b))
t.ratios

beta <- function(X,y){
  chol2inv(chol(t(X) %*% X)) %*% t(X) %*% y
}

?lm
help('lm')
lm(W ~ TOTAL.PAYROLL, mlb)
regression <- lm(W ~ TOTAL.PAYROLL, mlb)
class(regression)
summary(regression)
plot(mlb$TOTAL.PAYROLL,mlb$W)
abline(regression)

# Loops and simulation
for (i in 1:10) print(i) #loops will continue for however many elements you define

N       = 1000       #call this number of replications
trueb   = t(c(3,7))
k       = length(trueb)
simbeta = matrix(NA,ncol=2,nrow=N)
simse   = matrix(NA,ncol=2,nrow=N)
n = 100               #number of observations in each replication
set.seed(324)         #this allows for the random number generator in R to start at a given
                      #value. This is helpful for replication as you should get the same
                      #results with this given seed as everyone else running the following
                      #code.
for (i in 1:N){
X = matrix(rnorm(k*n), ncol=k, nrow=n)
y = X %*% t(trueb) + rnorm(n)

reg         <- lm(y ~ X -1)
simbeta[i,] <- reg$coefficients
simse[i,]   <- coef(summary(reg))[,2]
}

colMeans(simbeta)

par(mfrow=c(2,1)) #this tells R that we would like graphs to be shown on 
hist(simbeta[,1])
hist(simbeta[,2])

#Find out percentage of times that the 95% confidence interval does not include true value
sum(simbeta[,1]+1.96*simse[,1]>trueb[,1] & simbeta[,1]-1.96*simse[,1]<trueb[,1])
sum(simbeta[,2]+1.96*simse[,2]>trueb[,2] & simbeta[,2]-1.96*simse[,2]<trueb[,2])

# Saving data and workspace
save(simbeta,simse,file='Simulation.R') #save R objects as an R data file
rm(list=ls())
load('Simulation.R')
write.csv(simbeta,'Simbeta.csv')
write.csv(simse, 'Simse.csv')