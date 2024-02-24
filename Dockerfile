# Use an official Rust image as a builder
FROM rust:1.75 as builder

# Create a new empty shell project
RUN USER=root cargo new --bin actix_web_app
WORKDIR /actix_web_app

# Copy everything
COPY . .

# Build the project
RUN cargo build --release

# Expose port 8080
EXPOSE 8080

# Define the default command to run
CMD cargo run

