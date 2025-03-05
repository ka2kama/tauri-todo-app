use sea_orm::{ActiveModelTrait, DatabaseConnection, EntityTrait, Set};
use tauri::State;

use crate::models::{Counter, CounterActiveModel};

#[tauri::command]
pub async fn save_counter(value: i32, db: State<'_, DatabaseConnection>) -> Result<bool, String> {
   // Try to get existing counter
   let counter = Counter::find_by_id(1)
      .one(&*db)
      .await
      .map_err(|e| e.to_string())?;

   match counter {
      Some(_) => {
         // Update existing counter
         let mut counter: CounterActiveModel = counter.unwrap().into();
         counter.value = Set(value);
         counter.update(&*db).await.map_err(|e| e.to_string())?;
      }
      None => {
         // Create new counter
         let counter = CounterActiveModel {
            id:    Set(1),
            value: Set(value),
         };
         counter.insert(&*db).await.map_err(|e| e.to_string())?;
      }
   }

   Ok(true)
}

#[tauri::command]
pub async fn load_counter(db: State<'_, DatabaseConnection>) -> Result<i32, String> {
   let counter = Counter::find_by_id(1)
      .one(&*db)
      .await
      .map_err(|e| e.to_string())?;

   match counter {
      Some(counter) => Ok(counter.value),
      None => Ok(0), // Default value if no counter exists
   }
}
