

*********************************************************************************************
*Felix Bittmann, 2025
*felix.bittmann@lifbi.de
*Analyzing Large-Scale Freediving Competition Data With a Special Focus on Gender Differences
*SPRINT – Sports Research International
*********************************************************************************************

clear all
version 16.1
cap cd ""	                        //Working Path
set scheme plotplainblind			//Requires Ado, see below



*** Required Ados ***
*ssc install fre, replace
*ssc install estout, replace
*ssc install distplot, replace
*ssc install blindschemes, replace
*ssc install binscatter, replace
*ssc install scatterfit, replace //(https://github.com/leojahrens/scatterfit)



/*
Due to data protection issues, we have encrypted the datafile ("data.7zip"). You can get access by writing an email to the author
(felix.bittmann@lifbi.de or felix.bittmann@uni-bamberg.de). If possible, use your institutional email for contact.
*/
