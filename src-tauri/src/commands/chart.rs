use std::collections::HashMap;

use serde::{Deserialize, Serialize};
use tauri::AppHandle;

const API_KEY: &str = "demo"; // Using demo API key for testing

#[derive(Debug, Serialize, Deserialize)]
pub struct StockPrice {
   pub label: String,
   pub value: f64,
}

#[derive(Debug, Deserialize)]
struct MonthlyTimeSeries {
   #[serde(rename = "Monthly Time Series")]
   time_series: HashMap<String, MonthlyData>,
}

#[derive(Debug, Deserialize)]
struct MonthlyData {
   #[serde(rename = "4. close")]
   close: String,
}

#[tauri::command]
pub async fn get_stock_prices(_app: AppHandle) -> Result<Vec<StockPrice>, String> {
   let url = format!(
      "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=IBM&apikey={}",
      API_KEY
   );

   let response = reqwest::get(&url).await.map_err(|e| e.to_string())?;
   let data: MonthlyTimeSeries = response.json().await.map_err(|e| e.to_string())?;

   let mut stock_prices: Vec<StockPrice> = data
      .time_series
      .into_iter()
      .take(6) // Take only the last 6 months
      .map(|(date, monthly_data)| {
         let value = monthly_data.close.parse::<f64>().unwrap_or(0.0);
         let label = date.split('-').next().unwrap_or("").to_string();
         StockPrice { label, value }
      })
      .collect();

   stock_prices.reverse(); // Most recent data first
   Ok(stock_prices)
}
