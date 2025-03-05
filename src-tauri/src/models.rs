use sea_orm::entity::prelude::*;
use serde::{Deserialize, Serialize};

pub mod todo {
   use super::*;

   #[derive(Clone, Debug, PartialEq, DeriveEntityModel, Serialize, Deserialize)]
   #[sea_orm(table_name = "todos")]
   pub struct Model {
      #[sea_orm(primary_key)]
      pub id:        i32,
      pub title:     String,
      pub completed: bool,
   }

   #[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
   pub enum Relation {}

   impl ActiveModelBehavior for ActiveModel {}
}

pub mod counter {
   use super::*;

   #[derive(Clone, Debug, PartialEq, DeriveEntityModel, Serialize, Deserialize)]
   #[sea_orm(table_name = "counter")]
   pub struct Model {
      #[sea_orm(primary_key)]
      pub id:    i32,
      pub value: i32,
   }

   #[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
   pub enum Relation {}

   impl ActiveModelBehavior for ActiveModel {}
}

pub use counter::{ActiveModel as CounterActiveModel, Entity as Counter};
pub use todo::{ActiveModel as TodoActiveModel, Entity as Todo, Model as TodoModel};
