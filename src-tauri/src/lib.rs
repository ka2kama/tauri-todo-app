mod commands;
mod db;
mod models;

use commands::{
   chart::get_stock_prices,
   todo::{add_todo, delete_todo, get_todos, update_todo},
};
use tauri::Manager;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
   tauri::Builder::default()
      .plugin(tauri_plugin_opener::init())
      .setup(|app| {
         #[cfg(debug_assertions)] // only include this code on debug builds
         {
            let window = app.get_webview_window("main").unwrap();
            window.open_devtools();
            window.close_devtools();
         }

         tauri::async_runtime::block_on(async {
            let db = db::init_db(app.handle())
               .await
               .expect("Failed to initialize database");
            app.manage(db);
         });
         Ok(())
      })
      .invoke_handler(tauri::generate_handler![
         get_todos,
         add_todo,
         update_todo,
         delete_todo,
         get_stock_prices
      ])
      .run(tauri::generate_context!())
      .expect("error while running tauri application");
}
