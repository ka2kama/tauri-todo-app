use sea_orm::{ConnectionTrait, Database, DatabaseConnection, DbErr, Schema, Statement};
use sea_query::SqliteQueryBuilder;

pub async fn init_db(_app_handle: &tauri::AppHandle) -> Result<DatabaseConnection, DbErr> {
   let db_url = "sqlite::memory:".to_string();
   let db = Database::connect(&db_url).await?;

   // Create tables if they don't exist
   let schema = Schema::new(sea_orm::DatabaseBackend::Sqlite);
   let stmt = schema
      .create_table_from_entity(super::models::Entity)
      .if_not_exists()
      .to_string(SqliteQueryBuilder);

   db.execute(Statement::from_string(
      sea_orm::DatabaseBackend::Sqlite,
      stmt,
   ))
   .await?;

   Ok(db)
}
