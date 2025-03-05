use std::{fs, path::PathBuf};

use sea_orm::{ConnectionTrait, Database, DatabaseConnection, DbErr, Schema, Statement};
use sea_query::SqliteQueryBuilder;
use tauri::Manager;

pub async fn init_db(app_handle: &tauri::AppHandle) -> Result<DatabaseConnection, DbErr> {
   // Get the app data directory
   let app_data_dir = app_handle
      .path()
      .app_data_dir()
      .expect("Failed to get app data directory");

   // Create the directory if it doesn't exist
   fs::create_dir_all(&app_data_dir).expect("Failed to create app data directory");

   // Set up the database file path
   let db_path: PathBuf = app_data_dir.join("todo.db");
   let db_url = format!("sqlite://{}?mode=rwc", db_path.to_string_lossy());

   // Connect to the database
   let db = Database::connect(&db_url).await?;

   // Create tables if they don't exist
   let schema = Schema::new(sea_orm::DatabaseBackend::Sqlite);

   // Create todos table
   let todos_stmt = schema
      .create_table_from_entity(super::models::Todo)
      .if_not_exists()
      .to_string(SqliteQueryBuilder);

   db.execute(Statement::from_string(
      sea_orm::DatabaseBackend::Sqlite,
      todos_stmt,
   ))
   .await?;

   // Create counter table
   let counter_stmt = schema
      .create_table_from_entity(super::models::Counter)
      .if_not_exists()
      .to_string(SqliteQueryBuilder);

   db.execute(Statement::from_string(
      sea_orm::DatabaseBackend::Sqlite,
      counter_stmt,
   ))
   .await?;

   Ok(db)
}
