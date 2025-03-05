use sea_orm::{ActiveModelTrait, DatabaseConnection, EntityTrait, Set};
use serde::{Deserialize, Serialize};
use tauri::State;

use crate::models::{Todo, TodoActiveModel, TodoModel};

#[derive(Debug, Deserialize)]
pub struct AddTodoParams {
   pub title: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateTodoParams {
   pub id:        i32,
   pub title:     String,
   pub completed: bool,
}

#[derive(Debug, Deserialize)]
pub struct DeleteTodoParams {
   pub id: i32,
}

#[derive(Debug, Serialize)]
pub struct CommandResponse {
   pub status: String,
}

#[tauri::command]
pub async fn get_todos(db: State<'_, DatabaseConnection>) -> Result<Vec<TodoModel>, String> {
   Todo::find()
      .all(db.inner())
      .await
      .map_err(|e| e.to_string())
}

#[tauri::command]
pub async fn add_todo(
   db: State<'_, DatabaseConnection>,
   params: AddTodoParams,
) -> Result<CommandResponse, String> {
   let todo = TodoActiveModel {
      title: Set(params.title),
      completed: Set(false),
      ..Default::default()
   };

   todo
      .insert(db.inner())
      .await
      .map_err(|e| e.to_string())
      .map(|_| CommandResponse {
         status: "ok".to_string(),
      })
}

#[tauri::command]
pub async fn update_todo(
   db: State<'_, DatabaseConnection>,
   params: UpdateTodoParams,
) -> Result<CommandResponse, String> {
   let todo = TodoActiveModel {
      id:        Set(params.id),
      title:     Set(params.title),
      completed: Set(params.completed),
   };

   todo
      .update(db.inner())
      .await
      .map_err(|e| e.to_string())
      .map(|_| CommandResponse {
         status: "ok".to_string(),
      })
}

#[tauri::command]
pub async fn delete_todo(
   db: State<'_, DatabaseConnection>,
   params: DeleteTodoParams,
) -> Result<CommandResponse, String> {
   Todo::delete_by_id(params.id)
      .exec(db.inner())
      .await
      .map_err(|e| e.to_string())
      .map(|_| CommandResponse {
         status: "ok".to_string(),
      })
}
