use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct ChartData {
   pub label: String,
   pub value: f64,
}

#[tauri::command]
pub async fn get_chart_data() -> Vec<ChartData> {
   // For now returning sample data, but this could be connected to a database
   vec![
      ChartData {
         label: "Jan".to_string(),
         value: 65.0,
      },
      ChartData {
         label: "Feb".to_string(),
         value: 45.0,
      },
      ChartData {
         label: "Mar".to_string(),
         value: 80.0,
      },
      ChartData {
         label: "Apr".to_string(),
         value: 30.0,
      },
      ChartData {
         label: "May".to_string(),
         value: 55.0,
      },
      ChartData {
         label: "Jun".to_string(),
         value: 70.0,
      },
   ]
}
