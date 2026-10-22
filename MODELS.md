Benchmarks (train 1994–2022, test Jan 2023–Aug 2026): 
Best = SNaive, RMSE 0.91, MAE 0.75, MAPE 15.9%. 

This is the bar ETS/ARIMA must beat.



## ETS and ARIMA (06_ets_arima.R), first look
- Data now read from a local copy (SEAT653URN.csv); FRED was down for maintenance.
- ETS picked ETS(M,Ad,A): alpha ≈ 1 (follows last month), fixed seasonality, damped trend.
- ARIMA picked ARIMA(1,0,1)(0,0,2)[12] w/ mean: no differencing, ar1 = 0.89,
  reverts to a long-run mean of ~5.3% (matches the 5.2% Power BI average).
- Eyeball: ARIMA catches the 2025–26 rise in level but not seasonality;
  ETS looks like a slightly better SNaive. Accuracy table on Mon Oct 26.