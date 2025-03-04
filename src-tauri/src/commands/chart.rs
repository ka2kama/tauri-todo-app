use std::collections::HashMap;

use serde::{Deserialize, Serialize};
use tauri::AppHandle;

const API_KEY: &str = "demo"; // Using demo API key for testing

#[derive(Debug, Serialize, Deserialize)]
pub struct ChartData {
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
pub async fn get_chart_data(_app: AppHandle) -> Result<Vec<ChartData>, String> {
   let url = format!(
      "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=IBM&apikey={}",
      API_KEY
   );

   // Since ureq is synchronous, we need to spawn a blocking task
   let result = tokio::task::spawn_blocking(move || {
      let response = ureq::get(&url).call().map_err(|e| e.to_string())?;

      let data: MonthlyTimeSeries = response.into_json().map_err(|e| e.to_string())?;
      Ok::<MonthlyTimeSeries, String>(data)
   })
   .await
   .map_err(|e| e.to_string())??;

   let mut chart_data: Vec<ChartData> = result
      .time_series
      .into_iter()
      .take(6) // Take only the last 6 months
      .map(|(date, monthly_data)| {
         let value = monthly_data.close.parse::<f64>().unwrap_or(0.0);
         let label = date.split('-').next().unwrap_or("").to_string();
         ChartData { label, value }
      })
      .collect();

   chart_data.reverse(); // Most recent data first
   Ok(chart_data)
}
