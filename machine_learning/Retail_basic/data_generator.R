# Author: NattN
# Creation Date: Fri Dec 08 16:33:51 2017
# Modification Date: 
# Version: 1.0
# -------------- #
# Description: this is a script that generate datasets 
# -------------- #

#### Setup ####
library(dplyr); library(tidyr); library(jsonlite)
set.seed(1234)

#### Product dataset ####
product_master <- read.csv("https://raw.githubusercontent.com/NattN/public-dataset/master/machine_learning/Retail_basic/Groceries_detail.csv")
product_master$stock_ID <- sample(1:20, replace=TRUE, size=nrow(product_master))
product_master$stock_ID[c(1,8,20,6,50,60,143,133)] <- NA # add some NA


#### Branch dataset ####

loc_district <- fromJSON("https://raw.githubusercontent.com/NattN/public-dataset/master/thailand_geo/district/english.json", flatten=TRUE)
loc_subdostrict <- fromJSON("https://raw.githubusercontent.com/NattN/public-dataset/master/thailand_geo/subdistrict/english.json", flatten=TRUE)
loc_province <- fromJSON("https://raw.githubusercontent.com/NattN/public-dataset/master/thailand_geo/province/english.json", flatten=TRUE)
loc_name <- left_join(loc_province, loc_district, by = c("id" = "province_id")) %>% left_join(., loc_subdostrict, by = c("id.y" = "subdistrict_id"))
loc_name <- loc_name[which(loc_name$province_id == 10),] # 10 is bkk


branch_master <- data.frame("branch_ID" = 1:nrow(loc_name),
                            "Province" = loc_name$name.x,
                            "District" = loc_name$name.y,
                            "Sub_District" = loc_name$name)



#### Employee dataset ####
emp_n <- 600
emp_name = data.frame(randomNames::randomNames(emp_n, name.order="first.last", sample.with.replacement = F, ethnicity = "Asian"))
emp_name = data.frame(do.call('rbind', strsplit(as.character(emp_name[,1]),', ',fixed=TRUE)))

employee_master <- data.frame("emp_ID" = 1:emp_n,
                              "FNAME" = emp_name$X1,
                              "LNAME" = emp_name$X2,
                              "DOB" = sample(seq(as.Date('1987/01/01'), as.Date('1997/01/01'), by="day"), replace=TRUE, emp_n),
                              "SEX" = sample(c(1,2), replace=TRUE, size=emp_n),
                              "branch_ID" = sample(branch_master$branch_ID, replace=TRUE, size=emp_n))


#### Customer dataset ####
cus_n <- 10000
cus_name = data.frame(randomNames::randomNames(cus_n, name.order="first.last", sample.with.replacement = F, ethnicity = c("Black", "White")))
cus_name = data.frame(do.call('rbind', strsplit(as.character(cus_name[,1]),', ',fixed=TRUE)))
career_name = data.frame(lapply(read.csv("https://raw.githubusercontent.com/NattN/public-dataset/master/machine_learning/Retail_basic/Job_title-1.csv"),
                                function(x) {gsub(",", "-", x)} ))

customer_master <- data.frame("cus_ID" = 1:cus_n,
                              "FNAME" = cus_name$X1,
                              "LNAME" = cus_name$X2,
                              "SEX" = sample(c(1,2), replace=TRUE, size=cus_n),
                              "DOB" = sample(seq(as.Date('1950/01/01'), as.Date('2001/01/01'), by="day"), replace=TRUE, cus_n),
                              "Regis_date" = sample(seq(as.Date('2000/01/01'), as.Date('2017/08/08'), by="day"), replace=TRUE, cus_n),
                              "branch_ID" = sample(branch_master$branch_ID, replace=TRUE, size=cus_n),
                              "card_type" = sample(c("Gold", "Silver", "Blonze"), replace=TRUE, size=cus_n),
                              "career" = sample(career_name$Job_title, replace=TRUE, size=cus_n))


#### Transction dataset ####
# single product per transaction (one bill has many items)
ts_n = 2500000
ts_master <- data.frame("trans_ID" = paste0("ID", sample(1:77777, replace=TRUE, size=ts_n)),
                        "cus_ID" = sample(customer_master$cus_ID, replace=TRUE, size=ts_n),
                        "emp_ID" = sample(employee_master$emp_ID, replace=TRUE, size=ts_n),
                        "product_ID" = sample(product_master$product_ID, replace=TRUE, size=ts_n),
                        "branch_ID" = sample(branch_master$branch_ID, replace=TRUE, size=ts_n),
                        "purchase_date" = sample(seq(as.Date('2017/09/01'), as.Date('2017/12/31'), by="day"), replace=TRUE, ts_n),
                        "purchase_time" = paste(sprintf("%02d", sample(1:23, replace=TRUE, ts_n)), 
                                                sprintf("%02d", sample(1:59, replace=TRUE, ts_n)),
                                                sprintf("%02d", sample(1:59, replace=TRUE, ts_n)), 
                                                sep = ":"),
                        "amount" = sample(1:20, replace = TRUE, ts_n, prob = c(rep(0.75, 14), rep(0.5, 4), rep(0.2, 2))),
                        "remark_code" = sample(0:4, replace = TRUE, ts_n, prob = c(rep(0.75, 1), rep(0.5, 3), rep(0.2, 1))))


#### export csv ####
des_path <- "./public-dataset/machine_learning/Retail_basic"
write.csv(branch_master, paste0(des_path, "/master_branch.csv"), row.names = F, quote = F, na = "")
write.csv(customer_master, paste0(des_path, "/master_customer.csv"), row.names = F, quote = F, na = "")
write.csv(product_master, paste0(des_path, "/master_product.csv"), row.names = F, quote = F, na = "")
write.csv(ts_master, paste0(des_path, "/master_ts.csv"), row.names = F, quote = F, na = "")
write.csv(employee_master, paste0(des_path, "/master_employee.csv"), row.names = F, quote = F, na = "")















