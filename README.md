
# Rust Actix Web App Dockerization

This guide provides instructions on how to containerize a simple Rust Actix web app using Docker.

## Prerequisites

- Rust and Cargo installed on your machine
- Docker installed on your machine

## Step 1: Create a Rust Actix Web App

1. **Create a new Rust project:**

   ```bash
   cargo new actix_web_app
   cd actix_web_app
   ```

2. **Add Actix Web dependency:**

   Add the following to your `Cargo.toml` file:

   ```toml
   [dependencies]
   actix-web = "4"
   ```

3. **Create a simple web server:**

   Replace the content of `src/main.rs` with the following:

   ```rust
   use actix_web::{web, App, HttpResponse, HttpServer};
   use std::sync::Mutex;
   // this function could be located in a different module
   fn scoped_config(cfg: &mut web::ServiceConfig) {
      cfg.service(
         web::resource("/test")
               .route(web::get().to(|| async { HttpResponse::Ok().body("test") }))
               .route(web::head().to(HttpResponse::MethodNotAllowed)),
      );
   }

   // this function could be located in a different module
   fn config(cfg: &mut web::ServiceConfig) {
      cfg.service(
         web::resource("/app")
               .route(web::get().to(|| async { HttpResponse::Ok().body("app") }))
               .route(web::head().to(HttpResponse::MethodNotAllowed)),
      );
   }
   struct AppStateWithCounter {
      counter: Mutex<i32>, // <- Mutex is necessary to mutate safely across threads
   }

   async fn index(data: web::Data<AppStateWithCounter>) -> String {
      let mut counter = data.counter.lock().unwrap(); // <- get counter's MutexGuard
      *counter += 1; // <- access counter inside MutexGuard

      format!("Request number: {counter}") // <- response with count
   }
   #[actix_web::main]
   async fn main() -> std::io::Result<()> {
      // Note: web::Data created _outside_ HttpServer::new closure
      let counter = web::Data::new(AppStateWithCounter {
         counter: Mutex::new(0),
      });
      HttpServer::new(move || {
         App::new()
               .app_data(counter.clone()) // <- register the created data
               .route("/", web::get().to(index))
               .configure(config)
               .service(web::scope("/api").configure(scoped_config))
               
      })
      .bind(("127.0.0.1", 8080))?
      .run()
      .await
   }
   ```

4. **Run the app locally to test:**

   ```bash
   cargo run
   ```

   Visit `http://localhost:8080` in your browser to see the message "Hello, Actix!".

## Step 2: Create a Dockerfile

1. **Choose a base image:**

   ```Dockerfile
   FROM rust:1.75 as builder
   ```

2. **Create a new Rust project:**

   ```Dockerfile
   RUN USER=root cargo new --bin actix_web_app
   WORKDIR /actix_web_app
   ```

3. **Copy the Cargo files:**

   ```Dockerfile
   COPY . .
   ```

4. **Build dependencies:**

   ```Dockerfile
   RUN cargo build --release
   ```

5. **Remove temporary source files:**

   ```Dockerfile
   RUN rm src/*.rs
   ```

6. **Copy the source code:**

   ```Dockerfile
   COPY ./src ./src
   ```

7. **Rebuild the application:**

   ```Dockerfile
   RUN rm ./target/release/deps/actix_web_app*
   RUN cargo build --release
   ```

8. **Prepare the final image:**

   ```Dockerfile
   FROM rust:1.75
   COPY --from=builder /rust_actix_web_app/target/release/rust_actix_web_app /usr/local/bin/rust_actix_web_app
   EXPOSE 8080
   CMD ["actix_web_app"]
   ```

## Step 3: Build the Docker Image

Build the Docker image with the following command:

```bash
docker build -t actix_web_app .
```

## Step 4: Run the Container Locally

Run the container with the following command:

```bash
docker run -p 8080:8080 actix_web_app
```

Visit `http://localhost:8080` in your browser to see the message "Hello, Actix!" served from the container.

![Image Description](./images/Screenshot%202024-02-23%20191341.png)
![Image Description](./images/Screenshot%202024-02-23%20191033.png)
![Image Description](./images/Screenshot%202024-02-23%20191736.png)