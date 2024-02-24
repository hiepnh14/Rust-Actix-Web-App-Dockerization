# Use an official Rust image as a builder
FROM rust:1.75 as builder

# Create a new empty shell project
RUN USER=root cargo new --bin actix_web_app
WORKDIR /actix_web_app

# Copy the Cargo.toml and Cargo.lock files and build dependencies
COPY . .
RUN cargo build --release
RUN rm src/*.rs

# Copy the source code and build the application
COPY ./src ./src
RUN rm ./target/release/deps/actix_web_app*
RUN cargo build --release

# Use the same Rust base image for the final image
FROM rust:1.75
COPY --from=builder /actix_web_app/target/release/actix_web_app /usr/local/bin/actix_web_app
EXPOSE 8080
CMD ["actix_web_app"]
