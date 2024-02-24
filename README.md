
# Rust Actix Web App Dockerization

This guide provides instructions on how to containerize a simple Rust Actix web app using Docker.

## Prerequisites

- Rust and Cargo installed on your machine
- Docker installed on your machine

## Step 1: Create a Rust Actix Web App

1. **Create a new Rust project:**

   ```bash
   cargo new rust_actix_web_app
   cd rust_actix_web_app
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
   use actix_web::{web, App, HttpResponse, HttpServer, Responder};

   async fn greet() -> impl Responder {
       HttpResponse::Ok().body("Hello, Actix!")
   }

   #[actix_web::main]
   async fn main() -> std::io::Result<()> {
       HttpServer::new(|| {
           App::new()
               .route("/", web::get().to(greet))
       })
       .bind("0.0.0.0:8080")?
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
   FROM rust:1.64 as builder
   ```

2. **Create a new Rust project:**

   ```Dockerfile
   RUN USER=root cargo new --bin rust_actix_web_app
   WORKDIR /rust_actix_web_app
   ```

3. **Copy the Cargo files:**

   ```Dockerfile
   COPY ./Cargo.toml ./Cargo.toml
   COPY ./Cargo.lock ./Cargo.lock
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
   RUN rm ./target/release/deps/rust_actix_web_app*
   RUN cargo build --release
   ```

8. **Prepare the final image:**

   ```Dockerfile
   FROM debian:buster-slim
   COPY --from=builder /rust_actix_web_app/target/release/rust_actix_web_app /usr/local/bin/rust_actix_web_app
   EXPOSE 8080
   CMD ["rust_actix_web_app"]
   ```

## Step 3: Build the Docker Image

Build the Docker image with the following command:

```bash
docker build -t rust_actix_web_app .
```

## Step 4: Run the Container Locally

Run the container with the following command:

```bash
docker run -p 8080:8080 rust_actix_web_app
```

Visit `http://localhost:8080` in your browser to see the message "Hello, Actix!" served from the container.

