create table users (
  id uuid primary key,
  email text not null unique,
  full_name text not null
);
